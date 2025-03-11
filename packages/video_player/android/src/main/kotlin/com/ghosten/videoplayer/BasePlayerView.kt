package com.ghosten.videoplayer

import android.app.PictureInPictureParams
import androidx.media3.exoplayer.PlayerMessage
import io.flutter.plugin.common.MethodChannel

interface BasePlayerView {
    fun play()
    fun pause()
    fun next(index: Int)
    fun seekTo(position: Long)
    fun updateSource(data: HashMap<String, Any>, index: Int)
    fun setSources(data: List<HashMap<String, Any>>, index: Int)
    fun setTransform(matrix: ArrayList<Double>)
    fun setAspectRatio(aspectRatio: Float?)
    fun fullscreen(flag: Boolean)
    fun dispose()
    fun setTrack(trackType: String?, trackId: String?)
    fun setSkipPosition(skipType: String, list: List<Int>)
    fun getVideoThumbnail(result: MethodChannel.Result, timeMs: Long)
    fun setPlaybackSpeed(speed: Float)
    fun getPictureInPictureParams(): PictureInPictureParams?
    fun canEnterPictureInPicture(): Boolean
    fun setPlayerOption(name: String, value: Any)
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