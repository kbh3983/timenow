package com.example.timenow

import android.content.Context
import androidx.lifecycle.LifecycleOwner
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class TimenowCameraViewFactory(
    private val messenger: BinaryMessenger,
    private val lifecycleOwner: LifecycleOwner
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val params = args as? Map<*, *>
        val isFront = params?.get("isFrontCamera") as? Boolean ?: false
        return TimenowCameraView(context, messenger, viewId, lifecycleOwner, isFront)
    }
}
