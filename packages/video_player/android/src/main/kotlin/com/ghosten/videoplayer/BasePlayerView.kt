package com.ghosten.videoplayer

import android.app.PictureInPictureParams
import androidx.media3.exoplayer.PlayerMessage
import io.flutter.plugin.common.MethodChannel

interface BasePlayerView {
    fun play()
    fun pause()
    fun next(index: Int)
    fun seekTo(position: Long)
    fun updateSource(data: HashMap<String, Any>)
    fun setSource(data: HashMap<String, Any>?)
    fun setTransform(matrix: ArrayList<Double>)
    fun setAspectRatio(aspectRatio: Float?)
    fun fullscreen(flag: Boolean)
    fun dispose()
    fun setTrack(trackType: String?, trackId: String?)
    fun getVideoThumbnail(result: MethodChannel.Result, timeMs: Long)
    fun setPlaybackSpeed(speed: Float)
    fun getPictureInPictureParams(): PictureInPictureParams?
    fun canEnterPictureInPicture(): Boolean
    fun setPlayerOption(name: String, value: Any)
    fun setSubtitleStyle(style: List<Int>)
}

internal class Video(
    val url: String,
    val mimeType: String?,
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
    val selected: Boolean,
    val label: String?,
)