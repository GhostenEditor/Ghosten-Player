package com.ghosten.videoplayer

import android.app.Activity
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.PictureInPictureParams
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Matrix
import android.media.MediaMetadataRetriever
import android.net.TrafficStats
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.view.View
import android.widget.FrameLayout
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.net.toUri
import androidx.media3.common.C
import androidx.media3.common.MediaItem
import androidx.media3.common.MediaMetadata
import androidx.media3.common.MimeTypes
import androidx.media3.common.PlaybackException
import androidx.media3.common.Player
import androidx.media3.common.TrackSelectionOverride
import androidx.media3.common.Tracks
import androidx.media3.common.util.Log
import androidx.media3.common.util.UnstableApi
import androidx.media3.datasource.DefaultDataSource
import androidx.media3.datasource.DefaultHttpDataSource
import androidx.media3.datasource.FileDataSource
import androidx.media3.datasource.HttpDataSource
import androidx.media3.exoplayer.DefaultRenderersFactory
import androidx.media3.exoplayer.ExoPlaybackException
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.exoplayer.SeekParameters
import androidx.media3.exoplayer.mediacodec.MediaCodecDecoderException
import androidx.media3.exoplayer.mediacodec.MediaCodecRenderer.DecoderInitializationException
import androidx.media3.exoplayer.source.BehindLiveWindowException
import androidx.media3.exoplayer.source.DefaultMediaSourceFactory
import androidx.media3.exoplayer.source.UnrecognizedInputFormatException
import androidx.media3.exoplayer.upstream.Loader
import androidx.media3.session.MediaSession
import androidx.media3.session.MediaStyleNotificationHelper
import androidx.media3.ui.AspectRatioFrameLayout
import androidx.media3.ui.CaptionStyleCompat
import androidx.media3.ui.DefaultTrackNameProvider
import androidx.media3.ui.TrackNameProvider
import com.google.common.util.concurrent.MoreExecutors
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileNotFoundException
import java.io.FileOutputStream
import java.net.HttpURLConnection
import java.net.SocketTimeoutException
import java.util.UUID
import java.util.concurrent.ExecutionException

@UnstableApi
class Media3PlayerView(
    private val context: Context,
    private val activity: Activity,
    private val mChannel: MethodChannel,
    private var extensionRendererMode: Int?,
    private var enableDecoderFallback: Boolean?,
    private var language: String?,
    subtitleStyle: List<Int>?,
    private val width: Int?,
    private val height: Int?,
    private val top: Int?,
    private val left: Int?,
    private val autoPip: Boolean,
) : Player.Listener, BasePlayerView {
    private val mRootView: FrameLayout = activity.findViewById(android.R.id.content)
    private val mNativeView: View = View.inflate(context, R.layout.player_view, null)
    private var httpDataSourceFactory = DefaultHttpDataSource.Factory()
//        .setUserAgent(USER_AGENT)
        .setAllowCrossProtocolRedirects(true)
    private var mPlaylist: Array<Video> = arrayOf()
    private var trackNameProvider: TrackNameProvider = DefaultTrackNameProvider(context.resources)
    private val handler = Handler(Looper.getMainLooper())
    private var player: ExoPlayer
    private var mediaSession: MediaSession
    private var mLastTotalRxBytes: Long? = null
    private val playerDB: PlayerDatabaseHelper = PlayerDatabaseHelper(context)
    private var thumbnailThread: ThumbnailThread = ThumbnailThread()
    private var isFullscreen = width == null && height == null
    private var lastStatus: String = "idle"

    init {
        mRootView.addView(mNativeView, 0)
        thumbnailThread.start()
        createNotificationChannel()
        player = initPlayer()
        if (subtitleStyle?.size == 4) {
            setSubtitleStyle(subtitleStyle)
        }
        fullscreen(false)
        mediaSession = MediaSession.Builder(context, player).build()
        checkPlaybackPosition(1000)
    }

    inner class ThumbnailThread : Thread() {
        private val tasks: MutableList<() -> Unit> = mutableListOf()
        private var shouldLoop = true
        private var retriever: MediaMetadataRetriever? = null
        private var url: String? = null
        override fun run() {
            while (shouldLoop) {
                if (tasks.size == 0) {
                    sleep(1000L)
                }
                while (shouldLoop && tasks.size > 0) {
                    Log.d("Retriever Tasks Count", tasks.size.toString())
                    val task = tasks[0]
                    task()
                    tasks.remove(task)
                }
            }
        }

        fun add(result: MethodChannel.Result, timeMs: Long) {
            val video = mPlaylist[player.currentMediaItemIndex]
            val task = {
                if (video.url != url) {
                    url = video.url
                    retriever?.release()
                    retriever = MediaMetadataRetriever()
                    try {
                        if (url!!.startsWith("content://", ignoreCase = true)) {
                            retriever?.setDataSource(context, url!!.toUri())
                        } else if (url!!.startsWith("file://", ignoreCase = true)) {
                            retriever?.setDataSource(url)
                        } else {
                            retriever?.setDataSource(url, HashMap())

                        }
                    } catch (e: Exception) {
                        retriever = null
                        Log.e("MediaMetadataRetriever", e.toString())
                    }
                }

                val thumbnailBitmap = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
                    retriever?.getScaledFrameAtTime(
                        timeMs * 1000,
                        MediaMetadataRetriever.OPTION_CLOSEST_SYNC,
                        600,
                        400
                    )
                } else {
                    retriever?.getFrameAtTime(
                        timeMs * 1000,
                        MediaMetadataRetriever.OPTION_CLOSEST_SYNC,
                    )
                }

                val path = thumbnailBitmap?.let {
                    val filename = UUID.randomUUID().toString() + ".jpg"
                    val file = File(context.cacheDir, filename)
                    val fos = FileOutputStream(file)
                    it.compress(Bitmap.CompressFormat.JPEG, 75, fos)
                    fos.flush()
                    fos.close()
                    playerDB.insert(url!!, timeMs, filename)
                    context.cacheDir.toString() + "/" + filename
                }
                activity.runOnUiThread { result.success(path) }
            }
            if (tasks.size > 3) {
                for (i in 3 until tasks.size) {
                    tasks.removeAt(i)
                }
            }
            tasks.add(0, task)
        }

        fun clear() {
            tasks.clear()
        }

        fun cancel() {
            shouldLoop = false
            retriever?.release()
            retriever = null
            tasks.clear()
        }
    }

    private fun initPlayer(): ExoPlayer {
        val player = ExoPlayer.Builder(context)
            .setRenderersFactory(
                DefaultRenderersFactory(context)
                    .setEnableDecoderFallback(enableDecoderFallback ?: false)
                    .setExtensionRendererMode(
                        extensionRendererMode
                            ?: DefaultRenderersFactory.EXTENSION_RENDERER_MODE_ON
                    )
                    .forceEnableMediaCodecAsynchronousQueueing()
            )
            .setMediaSourceFactory(
                DefaultMediaSourceFactory(context).setDataSourceFactory(
                    DefaultDataSource.Factory(context, httpDataSourceFactory)
                )
            )
            .setSeekParameters(SeekParameters(3000000, 3000000))
            .build()

        if (language != null) {
            player.trackSelectionParameters = player.trackSelectionParameters
                .buildUpon()
                .setPreferredTextLanguages(language!!)
                .setPreferredAudioLanguages(language!!)
                .setMaxVideoSizeSd()
                .build()
        } else {
            player.trackSelectionParameters = player.trackSelectionParameters
                .buildUpon()
                .setMaxVideoSizeSd()
                .build()
        }
        player.addListener(this)
        player.addAnalyticsListener(EventLogger(object : EventLoggerHandler {
            override fun onLog(level: Int, message: String) {
                mChannel.invokeMethod("log", HashMap<String, Any?>().apply {
                    this["level"] = level
                    this["message"] = message
                })
            }
        }))
        mNativeView.findViewById<androidx.media3.ui.PlayerView>(R.id.video_view).player = player
        return player
    }

    private fun resetPlayer() {
        val index = player.currentMediaItemIndex
        val isPlaying = player.isPlaying
        mPlaylist[index].startPosition = player.currentPosition
        player.release()
        mediaSession.release()
        player = initPlayer()
        mediaSession = MediaSession.Builder(context, player).build()

        player.setMediaItem(buildMediaItem(mPlaylist[0]), mPlaylist[index].startPosition)
        if (isPlaying) {
            player.playWhenReady = true
            player.prepare()
        }
    }

    private fun checkPlaybackPosition(delayMs: Long): Boolean {
        return handler.postDelayed(
            {
                if (player.isPlaying) {
                    mChannel.invokeMethod("position", player.currentPosition)
                    mChannel.invokeMethod("bufferingUpdate", player.bufferedPosition)
                }
                val currentTotalRxBytes = TrafficStats.getTotalRxBytes()
                if (mLastTotalRxBytes != null) {
                    mChannel.invokeMethod("networkSpeed", currentTotalRxBytes - mLastTotalRxBytes!!)
                }
                mLastTotalRxBytes = currentTotalRxBytes
                checkPlaybackPosition(delayMs)
            },
            delayMs
        )
    }

    override fun onIsPlayingChanged(isPlaying: Boolean) {
        setPictureInPictureParams()
        if (player.playbackState == Player.STATE_BUFFERING || player.playbackState == Player.STATE_IDLE) {
            return
        }
        lastStatus = if (isPlaying) "playing" else "paused"
        mChannel.invokeMethod("updateStatus", lastStatus)
        super.onIsPlayingChanged(isPlaying)
    }

    override fun onMediaItemTransition(mediaItem: MediaItem?, reason: Int) {
        mChannel.invokeMethod("mediaChanged", HashMap<String, Any?>().apply {
            this["index"] = player.currentMediaItemIndex
            this["position"] = player.currentPosition
        })
        thumbnailThread.clear()
        super.onMediaItemTransition(mediaItem, reason)
    }

    override fun onMediaMetadataChanged(mediaMetadata: MediaMetadata) {
        super.onMediaMetadataChanged(mediaMetadata)
        showNotification(mediaMetadata)
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "Now Playing"
            val descriptionText = "Now Playing"
            val channel =
                NotificationChannel(
                    context.getString(CHANNEL_ID),
                    name,
                    NotificationManager.IMPORTANCE_LOW
                ).apply {
                    description = descriptionText
                }
            val notificationManager: NotificationManager =
                context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    class ActionBroadcastReceiver : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
        }
    }

    private fun createAction(ac: String, icon: Int, title: String): NotificationCompat.Action {
        val intent = Intent(context, ActionBroadcastReceiver::class.java).apply {
            action = Intent.ACTION_MEDIA_BUTTON
            putExtra("EXTRA_NOTIFICATION_ID", ac)
        }
        val pendingIntent: PendingIntent =
            PendingIntent.getBroadcast(context, 0, intent, PENDING_INTENT_FLAG_MUTABLE)
        return NotificationCompat.Action(icon, title, pendingIntent)
    }

    private fun showNotification(mediaMetadata: MediaMetadata) {
        fun show(bitmap: Bitmap?) {
            var builder = NotificationCompat.Builder(context, context.getString(CHANNEL_ID))
                .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                .setSmallIcon(androidx.media3.session.R.drawable.media3_icon_circular_play)
                .addAction(
                    createAction(
                        "Seek to previous item",
                        androidx.media3.session.R.drawable.media3_icon_previous,
                        "Seek to previous item"
                    )
                )
                .addAction(
                    createAction(
                        "pause",
                        androidx.media3.session.R.drawable.media3_icon_pause,
                        "Pause"
                    )
                )
                .addAction(
                    createAction(
                        "Seek to next item",
                        androidx.media3.session.R.drawable.media3_icon_next,
                        "Seek to next item"
                    )
                )
                .setStyle(
                    MediaStyleNotificationHelper.MediaStyle(mediaSession)
                        .setShowActionsInCompactView(0, 1, 2)
                )
                .setContentTitle(mediaMetadata.title)
                .setContentText(mediaMetadata.artist)
            if (bitmap != null) {
                builder = builder.setLargeIcon(bitmap)
            }

            with(NotificationManagerCompat.from(context)) {
                notify(NOTIFICATION_ID, builder.build())
            }
        }

        if (mediaMetadata.artworkUri == null) {
            show(null)
        } else {
            val bitmapFuture = mediaSession.bitmapLoader.loadBitmap(mediaMetadata.artworkUri!!)
            bitmapFuture.addListener({
                if (bitmapFuture.isDone) {
                    try {
                        val bitmap = bitmapFuture.get()
                        show(bitmap)
                    } catch (_: ExecutionException) {
                    }

                } else {
                    show(null)
                }
            }, MoreExecutors.directExecutor())
        }
    }

    private fun cancelNotification() {
        with(NotificationManagerCompat.from(context)) {
            cancel(NOTIFICATION_ID)
        }
    }

    override fun onPositionDiscontinuity(
        oldPosition: Player.PositionInfo,
        newPosition: Player.PositionInfo,
        reason: Int
    ) {
        when (reason) {
            Player.DISCONTINUITY_REASON_AUTO_TRANSITION, Player.DISCONTINUITY_REASON_SEEK -> {
                if (oldPosition.mediaItemIndex != newPosition.mediaItemIndex) {
                    mChannel.invokeMethod("beforeMediaChange", HashMap<String, Any?>().apply {
                        this["index"] = oldPosition.mediaItemIndex
                        this["position"] = oldPosition.positionMs
                    })
                    mPlaylist[oldPosition.mediaItemIndex].startPosition = oldPosition.positionMs
                    player.trackSelectionParameters = player.trackSelectionParameters
                        .buildUpon()
                        .setTrackTypeDisabled(C.TRACK_TYPE_AUDIO, false)
                        .setTrackTypeDisabled(C.TRACK_TYPE_TEXT, false)
                        .setTrackTypeDisabled(C.TRACK_TYPE_VIDEO, false)
                        .setTrackTypeDisabled(C.TRACK_TYPE_IMAGE, false)
                        .setTrackTypeDisabled(C.TRACK_TYPE_METADATA, false)
                        .build()
                    if (mPlaylist[newPosition.mediaItemIndex].startPosition < player.duration * 0.95) {
                        player.seekTo(mPlaylist[newPosition.mediaItemIndex].startPosition)
                    }
                }
                mChannel.invokeMethod("position", newPosition.positionMs)
            }

            else -> {
            }
        }
        super.onPositionDiscontinuity(oldPosition, newPosition, reason)
    }

    override fun onPlaybackStateChanged(playbackState: Int) {
        super.onPlaybackStateChanged(playbackState)
        when (playbackState) {
            Player.STATE_IDLE -> {
                if (lastStatus != "error") {
                    lastStatus = "idle"
                    mChannel.invokeMethod("updateStatus", lastStatus)
                }
            }

            Player.STATE_BUFFERING -> {
                lastStatus = "buffering"
                mChannel.invokeMethod("updateStatus", lastStatus)
                mChannel.invokeMethod("bufferingUpdate", player.bufferedPosition)
            }

            Player.STATE_READY -> {
                lastStatus = if (player.isPlaying) "playing" else "paused"
                mChannel.invokeMethod("updateStatus", lastStatus)
                val mediaInfo = HashMap<String, Any?>().apply {
                    this["videoCodecs"] = player.videoFormat?.codecs
                    this["videoMime"] = player.videoFormat?.sampleMimeType
                    this["videoFPS"] = player.videoFormat?.frameRate
                    this["videoBitrate"] = player.videoFormat?.averageBitrate
                    this["videoSize"] = "${player.videoSize.width} * ${player.videoSize.height}"
                    this["audioCodecs"] = player.audioFormat?.codecs
                    this["audioMime"] = player.audioFormat?.sampleMimeType
                    this["audioBitrate"] = player.audioFormat?.averageBitrate
                }
                mChannel.invokeMethod("mediaInfo", mediaInfo)
                mChannel.invokeMethod(
                    "duration",
                    if (player.duration == C.TIME_UNSET) 0 else player.duration
                )
                setMediaSkipEnd()
                player.mediaMetadata.also { mediaMetadata ->
                    if (mediaMetadata.title == null || mediaMetadata.artist == null) {
                        val item = mPlaylist[player.currentMediaItemIndex]
                        var metadataBuilder = mediaMetadata.buildUpon()
                            .setTitle(
                                mediaMetadata.title
                                    ?: item.title
                            )
                            .setArtist(
                                mediaMetadata.artist
                                    ?: item.description
                            )
                        if (item.poster != null) {
                            metadataBuilder = metadataBuilder.setArtworkUri(item.poster.toUri())
                        }
                        val mediaItem = player.currentMediaItem!!.buildUpon()
                            .setMediaMetadata(metadataBuilder.build())
                            .build()
                        player.replaceMediaItem(player.currentMediaItemIndex, mediaItem)
                    }
                }
            }

            Player.STATE_ENDED -> {
                if (mPlaylist.isNotEmpty()) {
                    lastStatus = "ended"
                    mChannel.invokeMethod("updateStatus", lastStatus)
                }
            }

        }
    }

    override fun onPlayerError(error: PlaybackException) {
        super.onPlayerError(error)
        when (error) {
            is ExoPlaybackException -> {
                when (val cause = error.cause) {
                    is HttpDataSource.InvalidResponseCodeException -> {
                        if (cause.responseCode == HttpURLConnection.HTTP_FORBIDDEN) {
                            val host = cause.dataSpec.uri.host
                            if (host != null && (host.endsWith("aliyuncs.com") || host.endsWith("aliyundrive.net"))) {
                                play()
                            } else {
                                mChannel.invokeMethod(
                                    "fatalError",
                                    "${cause.responseCode} ${cause.responseBody.decodeToString()}"
                                )
                            }
                        } else {
                            mChannel.invokeMethod(
                                "fatalError",
                                "${cause.responseCode} ${cause.responseBody.decodeToString()}"
                            )
                        }
                    }

                    is HttpDataSource.HttpDataSourceException -> {
                        when (val httpCause = cause.cause) {
                            is SocketTimeoutException -> {
                                mChannel.invokeMethod("fatalError", "Connection Timeout")
                            }

                            else -> {
                                mChannel.invokeMethod("fatalError", httpCause?.message)
                            }
                        }
                    }

                    is FileDataSource.FileDataSourceException -> {
                        when (cause.cause) {
                            is FileNotFoundException -> {
                                mChannel.invokeMethod("fatalError", "This File is Not Found")
                            }

                            else -> {
                                mChannel.invokeMethod("fatalError", cause.message)
                            }
                        }
                    }


                    is MediaCodecDecoderException, is DecoderInitializationException -> {
                        player.trackSelectionParameters = player.trackSelectionParameters
                            .buildUpon()
                            .setTrackTypeDisabled(
                                player.getRenderer(error.rendererIndex).trackType,
                                true
                            )
                            .build()
                        player.prepare()
                        mChannel.invokeMethod("error", cause.message)
                        mChannel.invokeMethod("fatalError", cause.message)
                    }

                    is UnrecognizedInputFormatException -> {
                        mChannel.invokeMethod(
                            "fatalError",
                            "None of the available extractors could read the stream."
                        )
                    }

                    is BehindLiveWindowException -> {
                        player.prepare()
                        player.play()
                        mChannel.invokeMethod("error", cause.message)
                        mChannel.invokeMethod("fatalError", cause.message)
                    }

                    is Loader.UnexpectedLoaderException -> {
                        when (val loaderCause = cause.cause) {
                            is SecurityException -> {
                                mChannel.invokeMethod("fatalError", loaderCause.message)
                            }

                            is IllegalArgumentException -> {
                                mChannel.invokeMethod("fatalError", cause.message)
                            }

                            is IllegalStateException -> {
                                if (player.currentMediaItemIndex < player.mediaItemCount - 1) {
                                    next(player.currentMediaItemIndex + 1)
                                    play()
                                }
                                mChannel.invokeMethod("error", loaderCause.message)
                            }

                            else -> {
                                mChannel.invokeMethod("fatalError", loaderCause?.message)
                            }
                        }

                    }

                    else -> {
                        mChannel.invokeMethod("fatalError", cause?.message)
                    }
                }
            }

            else -> {
                mChannel.invokeMethod("fatalError", error.cause?.message)
            }
        }
        lastStatus = "error"
        mChannel.invokeMethod("updateStatus", lastStatus)
    }

    override fun onTracksChanged(tracks: Tracks) {
        val tracksList = mutableListOf<HashMap<String, Any?>>()
        for (trackGroup in player.currentTracks.groups) {
            val trackType = trackGroup.type
            for (i in 0 until trackGroup.length) {
                val isSupported = trackGroup.isTrackSupported(i)
                val isSelected = trackGroup.isTrackSelected(i)
                val trackFormat = trackGroup.getTrackFormat(i)
                if (isSupported) {
                    val track = HashMap<String, Any?>().apply {
                        this["selected"] = isSelected
                        this["label"] = trackNameProvider.getTrackName(trackFormat)
                        this["type"] = when (trackType) {
                            C.TRACK_TYPE_AUDIO -> "audio"
                            C.TRACK_TYPE_VIDEO -> "video"
                            C.TRACK_TYPE_TEXT -> "sub"
                            else -> {
                                null
                            }
                        } ?: ""
                        this["id"] = trackFormat.id
                    }
                    if (track["type"] != null) {
                        tracksList.add(track)
                    }
                }
            }
        }
        mChannel.invokeMethod("tracksChanged", tracksList.toList())
        super.onTracksChanged(tracks)
    }

    private fun setMediaSkipEnd() {
        val index = player.currentMediaItemIndex
        val item = mPlaylist[index]
        val endPosition = item.endPosition
        if (player.duration != C.TIME_UNSET && endPosition > 0 && player.duration > endPosition) {
            if (item.skipEnd != null && !item.skipEnd!!.isCanceled) {
                item.skipEnd!!.cancel()
            }
            item.skipEnd = player
                .createMessage { _: Int, payload: Any? ->
                    next(payload as Int)
                }
                .setLooper(Looper.getMainLooper())
                .setPosition(index, player.duration - endPosition)
                .setPayload(index + 1)
                .setDeleteAfterDelivery(true)
                .send()
            if (item.skipEndTip != null && !item.skipEndTip!!.isCanceled) {
                item.skipEndTip!!.cancel()
            }
            item.skipEndTip = player
                .createMessage { _: Int, _: Any? ->
                    mChannel.invokeMethod("willSkip", null)
                }
                .setLooper(Looper.getMainLooper())
                .setPosition(index, player.duration - endPosition - 15000)
                .setPayload(index + 1)
                .setDeleteAfterDelivery(true)
                .send()
        }
    }

    private fun buildMediaItem(video: Video): MediaItem {
        return MediaItem.Builder()
            .setUri(video.url)
            .setMimeType(video.mimeType)
            .setSubtitleConfigurations((video.subtitle ?: listOf()).map {
                MediaItem.SubtitleConfiguration.Builder(it.url.toUri())
                    .setMimeType(
                        when (it.mimeType) {
                            "xml" -> MimeTypes.APPLICATION_TTML
                            "vtt" -> MimeTypes.TEXT_VTT
                            "ass" -> MimeTypes.TEXT_SSA
                            "srt" -> MimeTypes.APPLICATION_SUBRIP
                            else -> throw Exception("Unknown Subtitle Mime Type")
                        }
                    )
                    .setLanguage(it.language)
                    .setLabel(it.label)
                    .setSelectionFlags(
                        if (it.selected) {
                            C.SELECTION_FLAG_AUTOSELECT
                        } else {
                            C.SELECTION_FLAG_DEFAULT
                        }
                    )
                    .build()
            })
            .build()
    }

    private fun setPictureInPictureParams() {
        if (!autoPip) return
        val params = getPictureInPictureParams()
        if (params != null) activity.setPictureInPictureParams(params)
    }

    override fun getPictureInPictureParams(): PictureInPictureParams? {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                PictureInPictureParams.Builder()
                    .setAutoEnterEnabled(player.isPlaying && isFullscreen)
                    .build()
            } else {
                PictureInPictureParams.Builder()
                    .build()
            }
        }
        return null
    }

    override fun canEnterPictureInPicture(): Boolean {
        return when (player.playbackState) {
            Player.STATE_BUFFERING, Player.STATE_READY -> true
            else -> false
        }
    }

    override fun setPlayerOption(name: String, value: Any) {
        when (name) {
            "extensionRendererMode" -> {
                extensionRendererMode = value as Int
                resetPlayer()
            }

            "enableDecoderFallback" -> {
                enableDecoderFallback = value as Boolean
                resetPlayer()
            }
        }
    }

    override fun setSubtitleStyle(style: List<Int>) {
        if (style.size != 4) return
        val playerView = mNativeView.findViewById<androidx.media3.ui.PlayerView>(R.id.video_view)
        val subtitle =
            playerView.findViewById<androidx.media3.ui.SubtitleView>(androidx.media3.ui.R.id.exo_subtitles)
        subtitle.setStyle(
            CaptionStyleCompat(
                style[0],
                style[1],
                style[2],
                CaptionStyleCompat.EDGE_TYPE_OUTLINE,
                style[3],
                null
            )
        )
    }

    override fun getVideoThumbnail(result: MethodChannel.Result, timeMs: Long) {
        val url = mPlaylist[player.currentMediaItemIndex].url
        val path: String? = playerDB.queryPath(url, timeMs)
        if (path != null) {
            if (File(context.cacheDir, path).exists()) {
                result.success(context.cacheDir.toString() + "/" + path)
            } else {
                playerDB.delete(url, timeMs)
                thumbnailThread.add(result, timeMs)
            }
        } else {
            thumbnailThread.add(result, timeMs)
        }
    }

    override fun dispose() {
        mRootView.removeView(mNativeView)
        player.release()
        mediaSession.release()
        cancelNotification()
        setPictureInPictureParams()
        handler.removeCallbacksAndMessages(null)
        playerDB.close()
        thumbnailThread.cancel()
    }

    override fun setTrack(trackType: String?, trackId: String?) {
        val type = when (trackType) {
            "video" -> C.TRACK_TYPE_VIDEO
            "audio" -> C.TRACK_TYPE_AUDIO
            "sub" -> C.TRACK_TYPE_TEXT
            else -> return
        }
        for (trackGroup in player.currentTracks.groups) {
            if (trackGroup.type == type) {
                if (trackId == null) {
                    player.trackSelectionParameters = player.trackSelectionParameters.buildUpon()
                        .setTrackTypeDisabled(trackGroup.type, true)
                        .build()
                    return
                }
                for (i in 0 until trackGroup.length) {
                    val isSupported = trackGroup.isTrackSupported(i)
                    val trackFormat = trackGroup.getTrackFormat(i)
                    if (isSupported && trackFormat.id == trackId) {
                        player.trackSelectionParameters =
                            player.trackSelectionParameters.buildUpon()
                                .setTrackTypeDisabled(trackGroup.mediaTrackGroup.type, false)
                                .setOverrideForType(
                                    TrackSelectionOverride(
                                        trackGroup.mediaTrackGroup,
                                        i
                                    )
                                )
                                .build()
                        break
                    }
                }

            }
        }
    }

    override fun play() {
        when (player.playbackState) {
            Player.STATE_BUFFERING -> {
                player.play()
            }

            Player.STATE_ENDED -> {
                player.seekTo(0, mPlaylist[0].startPosition)
            }

            Player.STATE_IDLE -> {
                player.prepare()
                player.play()
            }

            Player.STATE_READY -> {
                player.play()
            }
        }
    }

    override fun pause() {
        player.pause()
    }

    override fun next(index: Int) {
        if (index >= player.mediaItemCount) {
            player.seekTo(player.duration)
            return
        }
        if (index < 0) {
            return
        }
        player.seekTo(index, mPlaylist[index].startPosition)
        if (player.playbackState == Player.STATE_IDLE) {
            player.prepare()
            player.play()
        }
    }

    override fun seekTo(position: Long) {
        player.seekTo(position)
    }

    override fun setSource(data: HashMap<String, Any>?) {
        if (data != null) {
            val video = Video(
                data[URL] as String,
                data[MIME_TYPE] as String?,
                data[TITLE] as String?,
                data[DESCRIPTION] as String?,
                data[POSTER] as String?,
                (data[SUBTITLE] as List<HashMap<String, Any>>?)?.map {
                    Subtitle(
                        it[URL] as String,
                        it[MIME_TYPE] as String,
                        it[LANGUAGE] as String?,
                        it[SELECTED] as Boolean,
                        it[LABEL] as String?
                    )
                },
                (data[START_POSITION] as Int? ?: 0).toLong(),
                (data[END_POSITION] as Int? ?: 0).toLong(),
            )
            mPlaylist = arrayOf(video)
            player.setMediaItem(buildMediaItem(video), video.startPosition)
        } else {
            mPlaylist = arrayOf()
            player.clearMediaItems()
        }
    }

    override fun updateSource(data: HashMap<String, Any>) {
        val video = Video(
            data[URL] as String,
            data[MIME_TYPE] as String?,
            data[TITLE] as String?,
            data[DESCRIPTION] as String?,
            data[POSTER] as String?,
            (data[SUBTITLE] as List<HashMap<String, Any>>?)?.map {
                Subtitle(
                    it[URL] as String,
                    it[MIME_TYPE] as String,
                    it[LANGUAGE] as String?,
                    it[SELECTED] as Boolean,
                    it[LABEL] as String?
                )
            },
            (data[START_POSITION] as Int? ?: 0).toLong(),
            (data[END_POSITION] as Int? ?: 0).toLong(),
        )
        mPlaylist = arrayOf(video)
        player.setMediaItem(buildMediaItem(video), video.startPosition)
    }

    override fun setTransform(matrix: ArrayList<Double>) {
        val videoView = mNativeView.findViewById<androidx.media3.ui.PlayerView>(R.id.video_view)
        videoView.animationMatrix = Matrix().apply {
            setValues(matrix.map { it.toFloat() }.toFloatArray())
        }
    }

    override fun setAspectRatio(aspectRatio: Float?) {
        val contentFrame =
            mNativeView.findViewById<AspectRatioFrameLayout>(androidx.media3.ui.R.id.exo_content_frame)
        contentFrame.setAspectRatio(
            aspectRatio ?: if (player.videoSize.height == 0) {
                1.778f
            } else {
                player.videoSize.width.toFloat() / player.videoSize.height.toFloat()
            }
        )
    }

    override fun fullscreen(flag: Boolean) {
        if (flag) {
            (mNativeView.layoutParams as FrameLayout.LayoutParams).width =
                FrameLayout.LayoutParams.MATCH_PARENT
            (mNativeView.layoutParams as FrameLayout.LayoutParams).height =
                FrameLayout.LayoutParams.MATCH_PARENT
            (mNativeView.layoutParams as FrameLayout.LayoutParams).topMargin = 0
            (mNativeView.layoutParams as FrameLayout.LayoutParams).leftMargin = 0
            mNativeView.requestLayout()
        } else {
            if (width != null) (mNativeView.layoutParams as FrameLayout.LayoutParams).width = width
            if (height != null) (mNativeView.layoutParams as FrameLayout.LayoutParams).height =
                height
            if (top != null) (mNativeView.layoutParams as FrameLayout.LayoutParams).topMargin = top
            if (left != null) (mNativeView.layoutParams as FrameLayout.LayoutParams).leftMargin =
                left
            mNativeView.requestLayout()
        }
        isFullscreen = flag
        setPictureInPictureParams()
    }


    override fun setPlaybackSpeed(speed: Float) {
        player.setPlaybackSpeed(speed)
    }

    companion object {
        private const val URL: String = "url"
        private const val TITLE: String = "title"
        private const val DESCRIPTION: String = "description"
        private const val POSTER: String = "poster"
        private const val SUBTITLE: String = "subtitle"
        private const val START_POSITION: String = "start"
        private const val END_POSITION: String = "end"
        private const val LANGUAGE: String = "language"
        private const val MIME_TYPE: String = "mimeType"
        private const val SELECTED: String = "selected"
        private const val LABEL: String = "label"
        private const val NOTIFICATION_ID = 3423523
        private val CHANNEL_ID = R.string.default_player_channel_id
        private val PENDING_INTENT_FLAG_MUTABLE =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) PendingIntent.FLAG_MUTABLE else 0
//        private const val USER_AGENT =
//            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.83 Safari/537.36"
    }
}
