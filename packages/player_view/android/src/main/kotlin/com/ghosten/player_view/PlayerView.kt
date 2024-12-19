package com.ghosten.player_view

import android.app.*
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.media.AudioManager
import android.media.MediaMetadataRetriever
import android.net.TrafficStats
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.view.View
import android.widget.FrameLayout
import android.widget.Toast
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.media3.common.*
import androidx.media3.common.util.Log
import androidx.media3.datasource.DefaultDataSource
import androidx.media3.datasource.DefaultHttpDataSource
import androidx.media3.datasource.FileDataSource
import androidx.media3.datasource.HttpDataSource
import androidx.media3.exoplayer.DefaultRenderersFactory
import androidx.media3.exoplayer.ExoPlaybackException
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.exoplayer.PlayerMessage
import androidx.media3.exoplayer.hls.HlsMediaSource
import androidx.media3.exoplayer.mediacodec.MediaCodecDecoderException
import androidx.media3.exoplayer.mediacodec.MediaCodecRenderer.DecoderInitializationException
import androidx.media3.exoplayer.source.BehindLiveWindowException
import androidx.media3.exoplayer.source.DefaultMediaSourceFactory
import androidx.media3.exoplayer.source.ProgressiveMediaSource
import androidx.media3.exoplayer.source.UnrecognizedInputFormatException
import androidx.media3.exoplayer.upstream.Loader
import androidx.media3.session.MediaSession
import androidx.media3.session.MediaStyleNotificationHelper
import androidx.media3.ui.DefaultTrackNameProvider
import androidx.media3.ui.TrackNameProvider
import com.google.common.util.concurrent.MoreExecutors
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileNotFoundException
import java.io.FileOutputStream
import java.util.*
import java.util.concurrent.ExecutionException
import kotlin.math.roundToInt

class PlayerView(
    private val context: Context,
    private val activity: Activity,
    private val mChannel: MethodChannel,
    extensionRendererMode: Int?,
    enableDecoderFallback: Boolean?,
    language: String?
) : Player.Listener {
    private val mRootView: FrameLayout = activity.findViewById<FrameLayout>(android.R.id.content)
    private val mNativeView: View = View.inflate(context, R.layout.player_view, null)
    private var httpDataSourceFactory = DefaultHttpDataSource.Factory().setUserAgent(USER_AGENT)
        .setAllowCrossProtocolRedirects(true)
    private var mPlaylist: Array<Video> = arrayOf()
    private var trackNameProvider: TrackNameProvider = DefaultTrackNameProvider(context.resources)
    private val handler = Handler(Looper.getMainLooper())
    private var player: ExoPlayer = ExoPlayer.Builder(context)
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
        .build()
    private val mediaSession = MediaSession.Builder(context, player).build()
    private val mAudioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager;
    private val mMaxVolume = mAudioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
    private val mCurrentVolume = mAudioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
    private var mLastTotalRxBytes: Long? = null;
    private val playerDB: PlayerDatabaseHelper = PlayerDatabaseHelper(context)
    private var thumbnailThread: ThumbnailThread = ThumbnailThread()

    init {
        if (language != null) {
            player.trackSelectionParameters = player.trackSelectionParameters
                .buildUpon()
                .setPreferredTextLanguages(language)
                .setPreferredAudioLanguages(language)
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
        mRootView.addView(mNativeView, 0)

        mChannel.invokeMethod("isInitialized", null)
        mChannel.invokeMethod("volumeChanged", mCurrentVolume.toFloat() / mMaxVolume.toFloat())
        checkPlaybackPosition(1000)
        thumbnailThread.start()
        createNotificationChannel()
    }

    fun getVideoThumbnail(result: MethodChannel.Result, timeMs: Long) {
        val url = mPlaylist[player.currentMediaItemIndex].url
        var path: String? = playerDB.queryPath(url, timeMs)
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

    inner class ThumbnailThread : Thread() {
        private val tasks: MutableList<() -> Unit> = mutableListOf()
        private var shouldLoop = true;
        private var currentVideo: Video? = null
        private var retriever: MediaMetadataRetriever? = null
        private var url: String? = null
        override fun run() {
            while (shouldLoop) {
                if (tasks.size == 0) {
                    Thread.sleep(1000L)
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
            if (video.type != C.CONTENT_TYPE_OTHER && video.type != 5) {
                return activity.runOnUiThread { result.success(null) }
            }
            val task = {
                if (video.url != url) {
                    url = video.url
                    retriever?.release()
                    retriever = MediaMetadataRetriever()
                    try {
                        if (video.type == 5) {
                            if (url!!.startsWith("content://", ignoreCase = true)) {
                                retriever?.setDataSource(context, Uri.parse(url))
                            } else {
                                retriever?.setDataSource(url)
                            }
                        } else {
                            retriever?.setDataSource(url, HashMap<String, String>())
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

    fun dispose() {
        mRootView.removeView(mNativeView)
        player.release()
        mediaSession.release()
        cancelNotification()
        setPictureInPictureParams()
        handler.removeCallbacksAndMessages(null)
        playerDB.close()
        thumbnailThread.cancel()
    }

    override fun onIsPlayingChanged(isPlaying: Boolean) {
        setPictureInPictureParams()
        if (player.playbackState == Player.STATE_BUFFERING) {
            return
        }
        mChannel.invokeMethod("updateStatus", if (isPlaying) "playing" else "paused")
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
                NotificationChannel(context.getString(CHANNEL_ID), name, NotificationManager.IMPORTANCE_LOW).apply {
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

    fun createAction(ac: String, icon: Int, title: String): NotificationCompat.Action {
        val intent = Intent(context, ActionBroadcastReceiver::class.java).apply {
            action = Intent.ACTION_MEDIA_BUTTON
            putExtra("EXTRA_NOTIFICATION_ID", ac)
        }
        val pendingIntent: PendingIntent =
            PendingIntent.getBroadcast(context, 0, intent, PENDING_INTENT_FLAG_MUTABLE)
        return NotificationCompat.Action(icon, title, pendingIntent)
    }

    fun showNotification(mediaMetadata: MediaMetadata) {
        fun show(bitmap: Bitmap?) {
            var builder = NotificationCompat.Builder(context, context.getString(CHANNEL_ID))
                .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                .setSmallIcon(androidx.media3.session.R.drawable.media3_icon_circular_play)
                .addAction(
                    createAction(
                        "Seek to previous item",
                        androidx.media3.ui.R.drawable.exo_icon_previous,
                        "Seek to previous item"
                    )
                )
                .addAction(createAction("pause", androidx.media3.ui.R.drawable.exo_icon_pause, "Pause"))
                .addAction(
                    createAction(
                        "Seek to next item",
                        androidx.media3.ui.R.drawable.exo_icon_next,
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
                    } catch (e: ExecutionException) {
                    }

                } else {
                    show(null)
                }
            }, MoreExecutors.directExecutor())
        }
    }

    fun cancelNotification() {
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
                    player.trackSelectionParameters = player.trackSelectionParameters
                        .buildUpon()
                        .setTrackTypeDisabled(C.TRACK_TYPE_AUDIO, false)
                        .setTrackTypeDisabled(C.TRACK_TYPE_TEXT, false)
                        .setTrackTypeDisabled(C.TRACK_TYPE_VIDEO, false)
                        .setTrackTypeDisabled(C.TRACK_TYPE_IMAGE, false)
                        .setTrackTypeDisabled(C.TRACK_TYPE_METADATA, false)
                        .build()
                    player.seekTo(mPlaylist[newPosition.mediaItemIndex].startPosition)
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
                mChannel.invokeMethod("updateStatus", "idle")
            }

            Player.STATE_BUFFERING -> {
                mChannel.invokeMethod("updateStatus", "buffering")
                mChannel.invokeMethod("bufferingUpdate", player.bufferedPosition)
            }

            Player.STATE_READY -> {
                mChannel.invokeMethod("updateStatus", if (player.isPlaying) "playing" else "paused")
                val mediaInfo = HashMap<String, Any?>().apply {
                    this["videoCodecs"] = player.videoFormat?.codecs
                    this["videoMime"] = player.videoFormat?.sampleMimeType
                    this["videoFPS"] = player.videoFormat?.frameRate
                    this["videoSize"] = "${player.videoSize.width} * ${player.videoSize.height}"
                    this["audioCodecs"] = player.audioFormat?.codecs
                    this["audioMime"] = player.audioFormat?.sampleMimeType
                    this["audioBitrate"] = player.audioFormat?.averageBitrate
                }
                mChannel.invokeMethod("mediaInfo", mediaInfo)
                mChannel.invokeMethod("duration", if (player.duration == C.TIME_UNSET) 0 else player.duration)
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
                            metadataBuilder = metadataBuilder.setArtworkUri(Uri.parse(item.poster))
                        }
                        val mediaItem = player.currentMediaItem!!.buildUpon()
                            .setMediaMetadata(metadataBuilder.build())
                            .build()
                        player.replaceMediaItem(player.currentMediaItemIndex, mediaItem)
                    }
                }
            }

            Player.STATE_ENDED -> {
                mChannel.invokeMethod("updateStatus", "ended")
            }

        }
    }

    override fun onPlayerError(error: PlaybackException) {
        super.onPlayerError(error)
        when (error) {
            is ExoPlaybackException -> {
                when (val cause = error.cause) {
                    is HttpDataSource.InvalidResponseCodeException -> {
                        mChannel.invokeMethod("fatalError", cause.responseBody.decodeToString())
                    }

                    is HttpDataSource.HttpDataSourceException -> {
                        mChannel.invokeMethod("fatalError", cause.message)
                    }

                    is FileDataSource.FileDataSourceException -> {
                        when (cause.cause) {
                            is FileNotFoundException -> {
                                mChannel.invokeMethod("fatalError", "This File is Not Found")
                            }

                            else -> {
                                Toast.makeText(context, "播放错误", Toast.LENGTH_SHORT).show()
                                mChannel.invokeMethod("fatalError", cause.message)
                            }
                        }
                    }


                    is MediaCodecDecoderException, is DecoderInitializationException -> {
                        player.trackSelectionParameters = player.trackSelectionParameters
                            .buildUpon()
                            .setTrackTypeDisabled(player.getRenderer(error.rendererIndex).trackType, true)
                            .build()
                        player.prepare()
                        mChannel.invokeMethod("error", cause.message)
                        mChannel.invokeMethod("fatalError", cause.message)
                    }

                    is UnrecognizedInputFormatException -> {
                        mChannel.invokeMethod("fatalError", "None of the available extractors could read the stream.")
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
                                mChannel.invokeMethod("error", cause.message)
                                player.seekTo(player.currentPosition + 1000)
                                play()
                            }

                            is IllegalStateException -> {
                                if (player.currentMediaItemIndex < player.mediaItemCount - 1) {
                                    next(player.currentMediaItemIndex + 1)
                                    play()
                                }
                                mChannel.invokeMethod("error", loaderCause.message)
                            }

                            else -> {
                                Toast.makeText(context, loaderCause.toString(), Toast.LENGTH_SHORT).show()
                                mChannel.invokeMethod("fatalError", loaderCause?.message)
                            }
                        }

                    }

                    else -> {
                        Toast.makeText(context, cause.toString(), Toast.LENGTH_SHORT).show()
                        mChannel.invokeMethod("fatalError", cause?.message)
                    }
                }
            }

            else -> {
                Toast.makeText(context, error.toString(), Toast.LENGTH_SHORT).show()
                mChannel.invokeMethod("fatalError", error.cause?.message)
            }
        }

        mChannel.invokeMethod("updateStatus", "error")
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
        val uri = Uri.parse(video.url)
        return when (video.type) {
            C.CONTENT_TYPE_HLS -> HlsMediaSource.Factory(httpDataSourceFactory)
                .createMediaSource(MediaItem.fromUri(uri)).mediaItem

            C.CONTENT_TYPE_OTHER -> {
                var mediaItem = ProgressiveMediaSource.Factory(httpDataSourceFactory)
                    .createMediaSource(MediaItem.fromUri(uri))
                    .mediaItem
                if (video.subtitle != null) {
                    mediaItem = mediaItem.buildUpon().setSubtitleConfigurations(video.subtitle.map {
                        MediaItem.SubtitleConfiguration.Builder(Uri.parse(it.url))
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
                            .build()
                    }).build()
                }
                mediaItem
            }

            5 -> {
                var mediaItem = MediaItem.fromUri(uri)
                if (video.subtitle != null) {
                    mediaItem = mediaItem.buildUpon().setSubtitleConfigurations(video.subtitle.map {
                        MediaItem.SubtitleConfiguration.Builder(Uri.parse(it.url))
                            .setMimeType(
                                when (it.mimeType) {
                                    "xml" -> "application/ttml+xml"
                                    "vtt" -> "text/vtt"
                                    "ass" -> "text/x-ssa"
                                    else -> throw Exception("Unknown Subtitle Mime Type")
                                }
                            )
                            .setLanguage(it.language)
                            .build()
                    }).build()
                }
                mediaItem
            }

            else -> throw IllegalStateException("Unsupported type: ${video.type}")
        }
    }

    private fun setPictureInPictureParams() {
        val params = getPictureInPictureParams()
        if (params != null) activity.setPictureInPictureParams(params)
    }

    fun getPictureInPictureParams(): PictureInPictureParams? {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                PictureInPictureParams.Builder()
                    .setAutoEnterEnabled(player.isPlaying)
                    .build()
            } else {
                PictureInPictureParams.Builder()
                    .build()
            }
        }
        return null
    }

    fun canEnterPictureInPicture(): Boolean {
        return when (player.playbackState) {
            Player.STATE_BUFFERING, Player.STATE_READY -> true
            else -> false
        }
    }

    fun setTrack(trackType: Int, trackId: String?) {
        for (trackGroup in player.currentTracks.groups) {
            if (trackGroup.type == trackType) {
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
                        player.trackSelectionParameters = player.trackSelectionParameters.buildUpon()
                            .setTrackTypeDisabled(trackGroup.mediaTrackGroup.type, false)
                            .setOverrideForType(TrackSelectionOverride(trackGroup.mediaTrackGroup, i))
                            .build()
                        break
                    }
                }

            }
        }
    }

    fun setSkipPosition(skipType: String, list: List<Int>) {
        for (i in list.indices) {
            when (skipType) {
                "start" -> {
                    mPlaylist[i].startPosition = list[i].toLong()
                }

                "end" -> {
                    mPlaylist[i].endPosition = list[i].toLong()
                }
            }
        }
    }

    fun play() {
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

    fun pause() {
        player.pause()
    }

    fun next(index: Int) {
        if (index >= player.mediaItemCount) {
            player.seekTo(player.duration)
            return
        }
        if (index < 0) {
            return
        }
        player.seekTo(index, mPlaylist[index].startPosition)
    }

    fun previous() {
        player.seekToPreviousMediaItem()
    }

    fun seekTo(position: Long) {
        player.seekTo(position)
    }

    fun setSources(data: List<HashMap<String, Any>>, index: Int) {
        val playlist = data.map { item ->
            Video(
                when (item[TYPE]) {
                    "hls" -> C.CONTENT_TYPE_HLS
                    "dash" -> C.CONTENT_TYPE_DASH
                    "ss" -> C.CONTENT_TYPE_SS
                    "local" -> 5
                    else -> C.CONTENT_TYPE_OTHER
                },
                item[URL] as String,
                item[TITLE] as String?,
                item[DESCRIPTION] as String?,
                item[POSTER] as String?,
                (item[SUBTITLE] as List<HashMap<String, Any>>?)?.map {
                    Subtitle(it[URL] as String, it[MIME_TYPE] as String, it[LANGUAGE] as String?)
                },
                (item[START_POSITION] as Int? ?: 0).toLong(),
                (item[END_POSITION] as Int? ?: 0).toLong(),
            )
        }.toTypedArray()

        mPlaylist = playlist
        player.setMediaItems(playlist.map {
            buildMediaItem(it)
        }.toList(), index, playlist[index].startPosition)

        player.playWhenReady = true
        player.prepare()
    }

    fun updateSource(data: HashMap<String, Any>, index: Int) {
        val video = Video(
            when (data[TYPE]) {
                "hls" -> C.CONTENT_TYPE_HLS
                "dash" -> C.CONTENT_TYPE_DASH
                "ss" -> C.CONTENT_TYPE_SS
                "local" -> 5
                else -> C.CONTENT_TYPE_OTHER
            },
            data[URL] as String,
            data[TITLE] as String?,
            data[DESCRIPTION] as String?,
            data[POSTER] as String?,
            (data[SUBTITLE] as List<HashMap<String, Any>>?)?.map {
                Subtitle(it[URL] as String, it[MIME_TYPE] as String, it[LANGUAGE] as String?)
            },
            (data[START_POSITION] as Int? ?: 0).toLong(),
            (data[END_POSITION] as Int? ?: 0).toLong(),
        )
        mPlaylist[index] = video
        player.replaceMediaItem(index, buildMediaItem(video))
        player.prepare()
    }

    fun setPlaybackSpeed(speed: Float) {
        player.setPlaybackSpeed(speed)
    }

    fun setVolume(volume: Float) {
        mAudioManager.setStreamVolume(
            AudioManager.STREAM_MUSIC,
            (volume * mMaxVolume).roundToInt(),
            AudioManager.FLAG_SHOW_UI
        )
    }

    internal class Video(
        val type: Int,
        val url: String,
        val title: String?,
        val description: String?,
        val poster: String?,
        val subtitle: List<Subtitle>?,
        var startPosition: Long,
        var endPosition: Long,
    ) {
        var skipEnd: PlayerMessage? = null
        var skipEndTip: PlayerMessage? = null
    }

    internal class Subtitle(
        val url: String,
        val mimeType: String,
        val language: String?,
    )

    companion object {
        const val TYPE: String = "type"
        const val URL: String = "url"
        const val TITLE: String = "title"
        const val DESCRIPTION: String = "description"
        const val POSTER: String = "poster"
        const val SUBTITLE: String = "subtitle"
        const val START_POSITION: String = "start"
        const val END_POSITION: String = "end"
        const val LANGUAGE: String = "language"
        const val MIME_TYPE: String = "mimeType"
        const val NOTIFICATION_ID = 3423523
        const val USER_AGENT =
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.83 Safari/537.36"
        val CHANNEL_ID = R.string.default_player_channel_id
        val PENDING_INTENT_FLAG_MUTABLE =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) android.app.PendingIntent.FLAG_MUTABLE else 0;
    }
}