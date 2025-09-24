package com.ghosten.videoplayer

import android.annotation.SuppressLint
import android.app.Activity
import android.app.PictureInPictureParams
import android.content.Context
import android.graphics.Matrix
import android.os.Build
import android.util.Log
import android.view.SurfaceHolder
import android.view.SurfaceView
import android.widget.FrameLayout
import com.ghosten.videoplayer.MPVLib.mpvFormat.MPV_FORMAT_DOUBLE
import com.ghosten.videoplayer.MPVLib.mpvFormat.MPV_FORMAT_FLAG
import com.ghosten.videoplayer.MPVLib.mpvFormat.MPV_FORMAT_INT64
import com.ghosten.videoplayer.MPVLib.mpvFormat.MPV_FORMAT_NONE
import com.ghosten.videoplayer.MPVLib.mpvFormat.MPV_FORMAT_STRING
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import java.io.File
import java.io.FileNotFoundException

class MPVPlayerView(
    private val context: Context,
    private val activity: Activity,
    private val mChannel: MethodChannel,
    private val hwdec: Boolean? = true,
    language: String?,
    private val width: Int?,
    private val height: Int?,
    private val top: Int?,
    private val left: Int?,
    private val version: String,
) : SurfaceView(context), SurfaceHolder.Callback, BasePlayerView, MPVLib.EventObserver {
    companion object {
        private const val TAG = "mpv"
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
    }

    private val mRootView: FrameLayout = activity.findViewById(android.R.id.content)
    private var coreIdle: Boolean = false
    private var pause: Boolean = false
    private var pausedForCache: Boolean = false
    private var seeking: Boolean = false
    private var videoAspectRatio: Double = 1.0
    private var isFullscreen = width == null && height == null

    init {
        if (mpvLibsDownloaded(version)) {
            loadMpvLibs()

            MPVLib.create(context)

            initOptions(language)

            MPVLib.init()

            MPVLib.setOptionString("save-position-on-quit", "no")
            MPVLib.setOptionString("force-window", "no")
            MPVLib.setOptionString("idle", "yes")

            holder.addCallback(this)
            observeProperties()

            mRootView.addView(this, 0)
            addObserver(this)
            mChannel.invokeMethod("isInitialized", null)

            fullscreen(false)
        }
    }

    @SuppressLint("UnsafeDynamicallyLoadedCode")
    private fun loadMpvLibs() {
        val dir = File(context.filesDir.path.plus("/mpv/$version"))
        val manifest = File(dir, "manifest.json")
        if (!manifest.exists()) {
            throw FileNotFoundException("MPV is not installed")
        }
        val libs = manifest.bufferedReader().use { JSONArray(it.readText()) }
        for (i in 0..<libs.length()) {
            val lib = libs.getString(i)
            System.load(File(dir, "$lib.so").path)
        }
    }

    private fun mpvLibsDownloaded(version: String): Boolean {
        val dir = File(context.filesDir.path.plus("/mpv/$version"))
        return dir.exists()
    }

    private fun initOptions(language: String?) {
        MPVLib.setOptionString("config", "yes")
        MPVLib.setOptionString("config-dir", context.filesDir.path.plus("/mpv/$version"))
        for (opt in arrayOf("gpu-shader-cache-dir", "icc-cache-dir"))
            MPVLib.setOptionString(opt, context.cacheDir.path)

        MPVLib.setOptionString("profile", "fast")

        MPVLib.setOptionString("ytdl", "no")
        MPVLib.setOptionString("osd-on-seek", "no")
        if (language != null) {
            MPVLib.setOptionString("alang", language)
            MPVLib.setOptionString("slang", language)
        }
        MPVLib.setOptionString("resume-playback", "no")

        MPVLib.setOptionString("vo", "gpu")

        MPVLib.setOptionString("gpu-context", "android")
        MPVLib.setOptionString("opengl-es", "yes")
        if (hwdec == true) {
            MPVLib.setOptionString("hwdec", "auto")
            MPVLib.setOptionString("hwdec-codecs", "h264,hevc,mpeg4,mpeg2video,vp8,vp9,av1")
        } else {
            MPVLib.setOptionString("hwdec", "no")
        }
        MPVLib.setOptionString("ao", "audiotrack,opensles")
        MPVLib.setOptionString("input-default-bindings", "no")
        val cacheMegs = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) 64 else 32
        MPVLib.setOptionString("demuxer-max-bytes", "${cacheMegs * 1024 * 1024}")
        MPVLib.setOptionString("demuxer-max-back-bytes", "${cacheMegs * 1024 * 1024}")
        MPVLib.setOptionString("sub-back-color", "#000000")

        MPVLib.setOptionString("vd-lavc-film-grain", "cpu")
    }

    private fun observeProperties() {
        MPVLib.observeProperty("time-pos/full", MPV_FORMAT_INT64)
        MPVLib.observeProperty("duration/full", MPV_FORMAT_DOUBLE)
        MPVLib.observeProperty("playlist-playing-pos", MPV_FORMAT_INT64)
        MPVLib.observeProperty("pause", MPV_FORMAT_FLAG)
        MPVLib.observeProperty("core-idle", MPV_FORMAT_FLAG)
        MPVLib.observeProperty("paused-for-cache", MPV_FORMAT_FLAG)
        MPVLib.observeProperty("seeking", MPV_FORMAT_FLAG)
        MPVLib.observeProperty("speed", MPV_FORMAT_STRING)
        MPVLib.observeProperty("track-list", MPV_FORMAT_NONE)
        MPVLib.observeProperty("video-params/aspect", MPV_FORMAT_DOUBLE)
        MPVLib.observeProperty("video-params/rotate", MPV_FORMAT_DOUBLE)
        MPVLib.observeProperty("playlist-pos", MPV_FORMAT_INT64)
        MPVLib.observeProperty("playlist-count", MPV_FORMAT_INT64)
        MPVLib.observeProperty("current-tracks/video/image", MPV_FORMAT_NONE)
        MPVLib.observeProperty("media-title", MPV_FORMAT_STRING)
        MPVLib.observeProperty("metadata", MPV_FORMAT_NONE)
        MPVLib.observeProperty("loop-playlist", MPV_FORMAT_NONE)
        MPVLib.observeProperty("loop-file", MPV_FORMAT_NONE)
        MPVLib.observeProperty("shuffle", MPV_FORMAT_FLAG)
        MPVLib.observeProperty("hwdec-current", MPV_FORMAT_NONE)
        MPVLib.observeProperty("cache-speed", MPV_FORMAT_INT64)
        MPVLib.observeProperty("estimated-vf-fps", MPV_FORMAT_DOUBLE)
        MPVLib.observeProperty("end-file/error", MPV_FORMAT_STRING)

    }

    private fun addObserver(o: MPVLib.EventObserver) {
        MPVLib.addObserver(o)
    }

    private fun removeObserver(o: MPVLib.EventObserver) {
        MPVLib.removeObserver(o)
    }

    private fun updateStatus() {
        Log.d("updateStatus", "$coreIdle,$pause,$pausedForCache,$seeking")
        activity.runOnUiThread {
            mChannel.invokeMethod(
                "updateStatus", if (pausedForCache || seeking) {
                    "buffering"
                } else if (pause) {
                    "paused"
                } else if (coreIdle) {
                    "idle"
                } else {
                    "playing"
                }
            )
        }
    }

    private fun loadTracks() {
        val count = MPVLib.getPropertyInt("track-list/count")!!

        val tracksList = mutableListOf<java.util.HashMap<String, Any?>>()
        val tracks = arrayOf("audio", "video", "sub")

        for (i in 0 until count) {
            val type = MPVLib.getPropertyString("track-list/$i/type") ?: continue
            if (!tracks.contains(type)) {
                Log.w(TAG, "Got unknown track type: $type")
                continue
            }
            val mpvId = MPVLib.getPropertyInt("track-list/$i/id") ?: continue
//            val lang = MPVLib.getPropertyString("track-list/$i/lang")
            val title = MPVLib.getPropertyString("track-list/$i/title")
            val isSelected = MPVLib.getPropertyBoolean("track-list/$i/selected")

            val track = java.util.HashMap<String, Any?>().apply {
                this["selected"] = isSelected
                this["label"] = title
                this["type"] = type
                this["id"] = mpvId
            }
            tracksList.add(track)
        }
        activity.runOnUiThread {
            mChannel.invokeMethod("tracksChanged", tracksList.toList())
        }

    }


    override fun surfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
        MPVLib.setPropertyString("android-surface-size", "${width}x$height")
    }

    override fun surfaceCreated(holder: SurfaceHolder) {
        Log.w(TAG, "attaching surface")
        MPVLib.attachSurface(holder.surface)
        MPVLib.setOptionString("force-window", "yes")
    }

    override fun surfaceDestroyed(holder: SurfaceHolder) {
        Log.w(TAG, "detaching surface")
        MPVLib.setPropertyString("vo", "null")
        MPVLib.setOptionString("force-window", "no")
        MPVLib.detachSurface()
    }

    override fun play() {
        MPVLib.setOptionString("pause", "no")
    }

    override fun pause() {
        MPVLib.setOptionString("pause", "yes")
    }

    override fun next(index: Int) {
        MPVLib.command(arrayOf("playlist-play-index", index.toString()))
    }

    override fun seekTo(position: Long) {
        MPVLib.command(arrayOf("seek", (position / 1000).toString(), "absolute"))
    }

    override fun updateSource(data: HashMap<String, Any>) {
    }

    override fun setSource(data: HashMap<String, Any>?) {
        if (data != null) {
            val video = Video(
                data[URL] as String,
                data[MIME_TYPE] as String?,
                data[TITLE] as String?,
                data[DESCRIPTION] as String?,
                data[POSTER] as String?,
                (data[SUBTITLE] as List<java.util.HashMap<String, Any>>?)?.map {
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
            val commands = mutableListOf(
                "loadfile",
                video.url,
                "replace",
                "0",
                "start=${video.startPosition / 1000}",
            )
            MPVLib.command(commands.toTypedArray())

        }
    }

    override fun setTransform(matrix: ArrayList<Double>) {
        this.animationMatrix = Matrix().apply {
            setValues(matrix.map { it.toFloat() }.toFloatArray())
        }
    }

    override fun setAspectRatio(aspectRatio: Float?) {
        MPVLib.setPropertyString("video-aspect-override", aspectRatio?.toString() ?: "-1")
    }

    override fun fullscreen(flag: Boolean) {
        if (flag) {
            layoutParams.width = FrameLayout.LayoutParams.MATCH_PARENT
            layoutParams.height = FrameLayout.LayoutParams.MATCH_PARENT
            (layoutParams as FrameLayout.LayoutParams).topMargin = 0
            (layoutParams as FrameLayout.LayoutParams).leftMargin = 0
            requestLayout()
        } else {
            if (width != null) (layoutParams as FrameLayout.LayoutParams).width = width
            if (height != null) (layoutParams as FrameLayout.LayoutParams).height = height
            if (top != null) (layoutParams as FrameLayout.LayoutParams).topMargin = top
            if (left != null) (layoutParams as FrameLayout.LayoutParams).leftMargin = left
            requestLayout()
        }
        isFullscreen = flag
    }

    override fun dispose() {
        removeObserver(this)
        holder.removeCallback(this)
        MPVLib.destroy()
        mRootView.removeView(this)
    }

    override fun setTrack(trackType: String?, trackId: String?) {
        val property = when (trackType) {
            "video" -> "vid"
            "audio" -> "aid"
            "sub" -> "sid"
            else -> return
        }
        if (trackId == null) {
            MPVLib.setPropertyString(property, "no")
        } else {
            MPVLib.setPropertyString(property, trackId)
        }
    }

    override fun getVideoThumbnail(result: MethodChannel.Result, timeMs: Long) {
    }

    override fun setPlaybackSpeed(speed: Float) {
        MPVLib.setPropertyDouble("speed", speed.toDouble())
    }

    override fun getPictureInPictureParams(): PictureInPictureParams? {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                PictureInPictureParams.Builder()
                    .setAutoEnterEnabled(!pause && isFullscreen)
                    .build()
            } else {
                PictureInPictureParams.Builder()
                    .build()
            }
        }
        return null
    }

    override fun canEnterPictureInPicture(): Boolean {
        return !pause
    }

    override fun setPlayerOption(name: String, value: Any) {
    }

    override fun setSubtitleStyle(style: List<Int>) {
    }

    override fun eventProperty(property: String) {
        when (property) {
            "track-list" -> loadTracks()
        }
    }

    override fun eventProperty(property: String, value: Long) {
        activity.runOnUiThread {
            when (property) {
                "time-pos/full" -> mChannel.invokeMethod("position", value * 1000)
                "cache-speed" -> mChannel.invokeMethod("networkSpeed", value)
                "playlist-playing-pos" -> {
                    if (value >= 0) {
                        mChannel.invokeMethod("mediaChanged", java.util.HashMap<String, Any?>().apply {
                            this["index"] = value
                            this["position"] = 0L
                        })

                    }
                }
            }
        }
    }

    override fun eventProperty(property: String, value: Boolean) {
        when (property) {
            "paused-for-cache" -> {
                pausedForCache = value
                updateStatus()
            }

            "pause" -> {
                pause = value
                updateStatus()
            }

            "core-idle" -> {
                coreIdle = value
                updateStatus()
            }

            "seeking" -> {
                seeking = value
                updateStatus()
            }
        }
    }

    override fun eventProperty(property: String, value: String) {
        Log.d("eventProperty", "$property: $value")

    }

    override fun eventProperty(property: String, value: Double) {
        Log.d("eventProperty", "$property: $value")
        activity.runOnUiThread {
            when (property) {
                "duration/full" -> mChannel.invokeMethod("duration", (value * 1000).toLong())
                "video-params/aspect" -> {
                    videoAspectRatio = value
                    Log.d(TAG, "video-params/aspect $value")
                }

                "estimated-vf-fps" -> {
                    Log.d(TAG, "estimated-vf-fps $value")
                }
            }
        }
    }

    override fun event(eventId: Int) {
        Log.d("event", "eventId: $eventId")
    }
}
