package com.ghosten.videoplayer

import android.os.SystemClock
import android.util.Log
import androidx.media3.common.*
import androidx.media3.common.util.Util
import androidx.media3.exoplayer.DecoderCounters
import androidx.media3.exoplayer.DecoderReuseEvaluation
import androidx.media3.exoplayer.analytics.AnalyticsListener
import androidx.media3.exoplayer.analytics.AnalyticsListener.EventTime
import androidx.media3.exoplayer.audio.AudioSink
import androidx.media3.exoplayer.audio.AudioSink.AudioTrackConfig
import androidx.media3.exoplayer.source.LoadEventInfo
import androidx.media3.exoplayer.source.MediaLoadData
import java.io.IOException
import java.text.NumberFormat
import kotlin.math.min

interface EventLoggerHandler {
    fun onLog(level: Int, message: String)
}

class EventLogger(private val handler: EventLoggerHandler) : AnalyticsListener {
    private val startTimeMs: Long = SystemClock.elapsedRealtime()
    private val period = Timeline.Period();

    fun log(level: Int, eventTime: AnalyticsListener.EventTime, eventName: String, message: String) {
        handler.onLog(level, "Media3: " + eventName + "\n" + getEventTimeString(eventTime) + "\n" + message)
    }

    fun logi(eventTime: AnalyticsListener.EventTime, eventName: String) {
        log(3, eventTime, eventName, "")
    }

    fun logi(eventTime: AnalyticsListener.EventTime, eventName: String, message: String) {
        log(3, eventTime, eventName, message)
    }

    fun logd(eventTime: AnalyticsListener.EventTime, eventName: String) {
        log(4, eventTime, eventName, "")
    }

    fun logd(eventTime: AnalyticsListener.EventTime, eventName: String, message: String) {
        log(4, eventTime, eventName, message)
    }

    fun loge(eventTime: AnalyticsListener.EventTime, eventName: String, error: String) {
        log(1, eventTime, eventName, error)
    }

    fun loge(eventTime: AnalyticsListener.EventTime, eventName: String, error: IOException) {
        log(1, eventTime, eventName, error.message + "\n" + Log.getStackTraceString(error))
    }

    fun loge(eventTime: AnalyticsListener.EventTime, eventName: String, error: Exception) {
        log(1, eventTime, eventName, error.message + "\n" + Log.getStackTraceString(error))
    }

    fun loge(eventTime: AnalyticsListener.EventTime, eventName: String, error: PlaybackException) {
        log(
            1, eventTime, eventName, error.errorCodeName + " " + error.message + "\n" + Log.getStackTraceString(error)
        )
    }

    private fun getTimeString(timeMs: Long): String {
        return if (timeMs == -9223372036854775807L) "?" else TIME_FORMAT.format((timeMs.toFloat() / 1000.0f).toDouble())
    }

    private fun getEventTimeString(eventTime: EventTime): String {
        var windowPeriodString = "window=" + eventTime.windowIndex
        if (eventTime.mediaPeriodId != null) {
            windowPeriodString =
                windowPeriodString + ", period=" + eventTime.timeline.getIndexOfPeriod(eventTime.mediaPeriodId!!.periodUid)
            if (eventTime.mediaPeriodId!!.isAd) {
                windowPeriodString = windowPeriodString + ", adGroup=" + eventTime.mediaPeriodId!!.adGroupIndex
                windowPeriodString = windowPeriodString + ", ad=" + eventTime.mediaPeriodId!!.adIndexInAdGroup
            }
        }

        return "eventTime=" + getTimeString(eventTime.realtimeMs - this.startTimeMs) + ", mediaPos=" + getTimeString(
            eventTime.eventPlaybackPositionMs
        ) + ", " + windowPeriodString
    }

    private fun getStateString(state: Int): String {
        return when (state) {
            1 -> "IDLE"
            2 -> "BUFFERING"
            3 -> "READY"
            4 -> "ENDED"
            else -> "?"
        }
    }

    private fun getPlayWhenReadyChangeReasonString(reason: Int): String {
        return when (reason) {
            1 -> "USER_REQUEST"
            2 -> "AUDIO_FOCUS_LOSS"
            3 -> "AUDIO_BECOMING_NOISY"
            4 -> "REMOTE"
            5 -> "END_OF_MEDIA_ITEM"
            else -> "?"
        }
    }

    private fun getPlaybackSuppressionReasonString(playbackSuppressionReason: Int): String {
        return when (playbackSuppressionReason) {
            0 -> "NONE"
            1 -> "TRANSIENT_AUDIO_FOCUS_LOSS"
            else -> "?"
        }
    }

    private fun getMediaItemTransitionReasonString(reason: Int): String {
        return when (reason) {
            0 -> "REPEAT"
            1 -> "AUTO"
            2 -> "SEEK"
            3 -> "PLAYLIST_CHANGED"
            else -> "?"
        }
    }

    private fun getDiscontinuityReasonString(reason: Int): String {
        return when (reason) {
            0 -> "AUTO_TRANSITION"
            1 -> "SEEK"
            2 -> "SEEK_ADJUSTMENT"
            3 -> "SKIP"
            4 -> "REMOVE"
            5 -> "INTERNAL"
            6 -> "SILENCE_SKIP"
            else -> "?"
        }
    }

    private fun getRepeatModeString(repeatMode: Int): String {
        return when (repeatMode) {
            0 -> "OFF"
            1 -> "ONE"
            2 -> "ALL"
            else -> "?"
        }
    }

    private fun getTimelineChangeReasonString(reason: Int): String {
        return when (reason) {
            0 -> "PLAYLIST_CHANGED"
            1 -> "SOURCE_UPDATE"
            else -> "?"
        }
    }

    private fun getAudioTrackConfigString(audioTrackConfig: AudioTrackConfig): String {
        return audioTrackConfig.encoding.toString() + "," + audioTrackConfig.channelConfig + "," + audioTrackConfig.sampleRate + "," + audioTrackConfig.tunneling + "," + audioTrackConfig.offload + "," + audioTrackConfig.bufferSize
    }

    private fun getTrackStatusString(selected: Boolean): String {
        return if (selected) "[X]" else "[ ]"
    }

    override fun onPlaybackStateChanged(eventTime: AnalyticsListener.EventTime, state: Int) {
        logi(eventTime, "state", getStateString(state))
    }

    override fun onPlayWhenReadyChanged(eventTime: AnalyticsListener.EventTime, playWhenReady: Boolean, reason: Int) {
        logi(
            eventTime,
            "playWhenReady",
            playWhenReady.toString() + ", " + getPlayWhenReadyChangeReasonString(reason)
        )
    }

    override fun onPlaybackSuppressionReasonChanged(
        eventTime: AnalyticsListener.EventTime,
        playbackSuppressionReason: Int
    ) {
        logd(
            eventTime,
            "playbackSuppressionReason",
            getPlaybackSuppressionReasonString(playbackSuppressionReason)
        )
    }

    override fun onIsPlayingChanged(eventTime: AnalyticsListener.EventTime, isPlaying: Boolean) {
        logi(eventTime, "isPlaying", isPlaying.toString())
    }

    override fun onTimelineChanged(eventTime: AnalyticsListener.EventTime, reason: Int) {
        val periodCount = eventTime.timeline.periodCount
        val windowCount = eventTime.timeline.windowCount
        val builder = StringBuilder()
        builder.append(
            "[" + this.getEventTimeString(eventTime) + ", periodCount=" + periodCount + ", windowCount=" + windowCount + ", reason=" + getTimelineChangeReasonString(
                reason
            )
        )
        builder.appendLine()

        for (i in 0 until min(periodCount, 3)) {
            eventTime.timeline.getPeriod(i, this.period)
            builder.append("  period [" + getTimeString(this.period.getDurationMs()) + "]")
            builder.appendLine()
        }

        if (periodCount > 3) {
            builder.append("  ...")
            builder.appendLine()
        }

        builder.append("]")
        logi(eventTime, "timeline", builder.toString())
    }

    override fun onMediaItemTransition(eventTime: AnalyticsListener.EventTime, mediaItem: MediaItem?, reason: Int) {
        logi(
            eventTime, "MediaItemTransition", "reason=" + getMediaItemTransitionReasonString(reason)
        )
    }

    override fun onPositionDiscontinuity(
        eventTime: AnalyticsListener.EventTime,
        oldPosition: Player.PositionInfo,
        newPosition: Player.PositionInfo,
        reason: Int
    ) {
        val builder = StringBuilder()
        builder.append("reason=").append(getDiscontinuityReasonString(reason))
            .append(", PositionInfo:old [").append("mediaItem=").append(oldPosition.mediaItemIndex).append(", period=")
            .append(oldPosition.periodIndex).append(", pos=").append(oldPosition.positionMs)
        if (oldPosition.adGroupIndex != -1) {
            builder.append(", contentPos=").append(oldPosition.contentPositionMs).append(", adGroup=")
                .append(oldPosition.adGroupIndex).append(", ad=").append(oldPosition.adIndexInAdGroup)
        }

        builder.append("], PositionInfo:new [").append("mediaItem=").append(newPosition.mediaItemIndex)
            .append(", period=").append(newPosition.periodIndex).append(", pos=").append(newPosition.positionMs)
        if (newPosition.adGroupIndex != -1) {
            builder.append(", contentPos=").append(newPosition.contentPositionMs).append(", adGroup=")
                .append(newPosition.adGroupIndex).append(", ad=").append(newPosition.adIndexInAdGroup)
        }

        builder.append("]")
        logi(eventTime, "positionDiscontinuity", builder.toString())
    }

    override fun onPlaybackParametersChanged(
        eventTime: AnalyticsListener.EventTime,
        playbackParameters: PlaybackParameters
    ) {
        logd(eventTime, "playbackParameters", playbackParameters.toString())
    }

    override fun onRepeatModeChanged(eventTime: AnalyticsListener.EventTime, repeatMode: Int) {
        logd(eventTime, "repeatMode", getRepeatModeString(repeatMode))
    }

    override fun onShuffleModeChanged(eventTime: AnalyticsListener.EventTime, shuffleModeEnabled: Boolean) {
        logd(eventTime, "shuffleModeEnabled", shuffleModeEnabled.toString())
    }

    override fun onIsLoadingChanged(eventTime: AnalyticsListener.EventTime, isLoading: Boolean) {
        logi(eventTime, "loading", isLoading.toString())
    }

    override fun onPlayerError(eventTime: AnalyticsListener.EventTime, error: PlaybackException) {
        this.loge(eventTime, "playerFailed", error)
    }

    override fun onTracksChanged(eventTime: AnalyticsListener.EventTime, tracks: Tracks) {
        val builder = StringBuilder()

        builder.append(getEventTimeString(eventTime))
        builder.appendLine()
        val trackGroups = tracks.groups

        for (groupIndex in trackGroups.indices) {
            val trackGroup = trackGroups[groupIndex] as Tracks.Group
            builder.append("  group [")
            builder.appendLine()
            for (trackIndex in 0 until trackGroup.length) {
                val status = getTrackStatusString(trackGroup.isTrackSelected(trackIndex))
                val formatSupport = Util.getFormatSupportString(trackGroup.getTrackSupport(trackIndex))
                builder.append(
                    "    " + status + " Track:" + trackIndex + ", " + Format.toLogString(
                        trackGroup.getTrackFormat(
                            trackIndex
                        )
                    ) + ", supported=" + formatSupport
                )
                builder.appendLine()
            }
            builder.append("  ]")
            builder.appendLine()
        }

        var loggedMetadata = false

        for (trackGroup in trackGroups) {
            if (loggedMetadata) {
                break
            }
            var trackIndex = 0
            while (!loggedMetadata && trackIndex < trackGroup.length) {
                if (trackGroup.isTrackSelected(trackIndex)) {
                    val metadata = trackGroup.getTrackFormat(trackIndex).metadata
                    if (metadata != null && metadata.length() > 0) {
                        builder.append("  Metadata [")
                        builder.appendLine()
                        for (i in 0 until metadata.length()) {
                            builder.append("    " + metadata[i])
                            builder.appendLine()
                        }
                        builder.append("  ]")
                        builder.appendLine()
                        loggedMetadata = true
                    }
                }
                ++trackIndex
            }
        }

        builder.append("]")
        logi(eventTime, "tracks", builder.toString())
    }

    override fun onLoadError(
        eventTime: AnalyticsListener.EventTime,
        loadEventInfo: LoadEventInfo,
        mediaLoadData: MediaLoadData,
        error: IOException,
        wasCanceled: Boolean
    ) {
        loge(eventTime, "loadError", error)
    }

    override fun onDownstreamFormatChanged(eventTime: AnalyticsListener.EventTime, mediaLoadData: MediaLoadData) {
        logd(eventTime, "downstreamFormat", Format.toLogString(mediaLoadData.trackFormat))
    }

    override fun onUpstreamDiscarded(eventTime: AnalyticsListener.EventTime, mediaLoadData: MediaLoadData) {
        logd(eventTime, "upstreamDiscarded", Format.toLogString(mediaLoadData.trackFormat))
    }

    override fun onMetadata(eventTime: AnalyticsListener.EventTime, metadata: Metadata) {
        val builder = StringBuilder()

        for (i in 0 until metadata.length()) {
            builder.append(metadata[i].toString() + "\n")
        }
        logd(eventTime, "metadata", builder.toString())
    }

    override fun onAudioEnabled(eventTime: AnalyticsListener.EventTime, decoderCounters: DecoderCounters) {
        logd(eventTime, "audioEnabled", "")
    }

    override fun onAudioDecoderInitialized(
        eventTime: AnalyticsListener.EventTime,
        decoderName: String,
        initializedTimestampMs: Long,
        initializationDurationMs: Long
    ) {
        logd(eventTime, "audioDecoderInitialized", decoderName)
    }

    override fun onAudioInputFormatChanged(
        eventTime: AnalyticsListener.EventTime,
        format: Format,
        decoderReuseEvaluation: DecoderReuseEvaluation?
    ) {
        logd(eventTime, "audioInputFormat", Format.toLogString(format))
    }

    override fun onAudioUnderrun(
        eventTime: AnalyticsListener.EventTime,
        bufferSize: Int,
        bufferSizeMs: Long,
        elapsedSinceLastFeedMs: Long
    ) {
        loge(eventTime, "audioTrackUnderrun", "$bufferSize, $bufferSizeMs, $elapsedSinceLastFeedMs")
    }

    override fun onAudioDecoderReleased(eventTime: AnalyticsListener.EventTime, decoderName: String) {
        logd(eventTime, "audioDecoderReleased", decoderName)
    }

    override fun onAudioDisabled(eventTime: AnalyticsListener.EventTime, decoderCounters: DecoderCounters) {
        logd(eventTime, "audioDisabled", "")
    }

    override fun onAudioSessionIdChanged(eventTime: AnalyticsListener.EventTime, audioSessionId: Int) {
        logd(eventTime, "audioSessionId", audioSessionId.toString())
    }

    override fun onAudioAttributesChanged(eventTime: AnalyticsListener.EventTime, audioAttributes: AudioAttributes) {
        logd(
            eventTime,
            "audioAttributes",
            audioAttributes.contentType.toString() + "," + audioAttributes.flags + "," + audioAttributes.usage + "," + audioAttributes.allowedCapturePolicy
        )
    }

    override fun onSkipSilenceEnabledChanged(eventTime: AnalyticsListener.EventTime, skipSilenceEnabled: Boolean) {
        logd(eventTime, "skipSilenceEnabled", skipSilenceEnabled.toString())
    }

    override fun onAudioTrackInitialized(
        eventTime: AnalyticsListener.EventTime,
        audioTrackConfig: AudioSink.AudioTrackConfig
    ) {
        logd(eventTime, "audioTrackInit", getAudioTrackConfigString(audioTrackConfig))

    }

    override fun onAudioTrackReleased(
        eventTime: AnalyticsListener.EventTime,
        audioTrackConfig: AudioSink.AudioTrackConfig
    ) {
        logd(eventTime, "audioTrackReleased", getAudioTrackConfigString(audioTrackConfig))
    }

    override fun onVolumeChanged(eventTime: AnalyticsListener.EventTime, volume: Float) {
        logd(eventTime, "volume", volume.toString())
    }

    override fun onVideoEnabled(eventTime: AnalyticsListener.EventTime, decoderCounters: DecoderCounters) {
        logd(eventTime, "videoEnabled")
    }

    override fun onVideoDecoderInitialized(
        eventTime: AnalyticsListener.EventTime,
        decoderName: String,
        initializedTimestampMs: Long,
        initializationDurationMs: Long
    ) {
        logd(eventTime, "videoDecoderInitialized", decoderName)
    }

    override fun onVideoInputFormatChanged(
        eventTime: AnalyticsListener.EventTime,
        format: Format,
        decoderReuseEvaluation: DecoderReuseEvaluation?
    ) {
        logd(eventTime, "videoInputFormat", Format.toLogString(format))
    }

    override fun onDroppedVideoFrames(eventTime: AnalyticsListener.EventTime, droppedFrames: Int, elapsedMs: Long) {
        logd(eventTime, "droppedFrames", droppedFrames.toString())
    }

    override fun onVideoDecoderReleased(eventTime: AnalyticsListener.EventTime, decoderName: String) {
        logd(eventTime, "videoDecoderReleased", decoderName)
    }

    override fun onVideoDisabled(eventTime: AnalyticsListener.EventTime, decoderCounters: DecoderCounters) {
        logd(eventTime, "videoDisabled")
    }

    override fun onRenderedFirstFrame(eventTime: AnalyticsListener.EventTime, output: Any, renderTimeMs: Long) {
        logi(eventTime, "renderedFirstFrame", output.toString())
    }

    override fun onVideoSizeChanged(eventTime: AnalyticsListener.EventTime, videoSize: VideoSize) {
        logd(eventTime, "videoSize", videoSize.width.toString() + ", " + videoSize.height)
    }

    override fun onSurfaceSizeChanged(eventTime: AnalyticsListener.EventTime, width: Int, height: Int) {
        logd(eventTime, "surfaceSize", "$width, $height")
    }

    override fun onDrmSessionAcquired(eventTime: AnalyticsListener.EventTime, state: Int) {
        logd(eventTime, "drmSessionAcquired", "state=$state")
    }

    override fun onDrmKeysLoaded(eventTime: AnalyticsListener.EventTime) {
        logd(eventTime, "drmKeysLoaded")
    }

    override fun onDrmSessionManagerError(eventTime: AnalyticsListener.EventTime, error: Exception) {
        loge(eventTime, "drmSessionManagerError", error)
    }

    override fun onDrmKeysRestored(eventTime: AnalyticsListener.EventTime) {
        logd(eventTime, "drmKeysRestored")
    }

    override fun onDrmKeysRemoved(eventTime: AnalyticsListener.EventTime) {
        logd(eventTime, "drmKeysRemoved")
    }

    override fun onDrmSessionReleased(eventTime: AnalyticsListener.EventTime) {
        logd(eventTime, "drmSessionReleased")
    }

    companion object {
        val TIME_FORMAT = NumberFormat.getInstance(java.util.Locale.US)

        init {
            TIME_FORMAT.setMinimumFractionDigits(2)
            TIME_FORMAT.setMaximumFractionDigits(2)
            TIME_FORMAT.setGroupingUsed(false)
        }
    }
}


