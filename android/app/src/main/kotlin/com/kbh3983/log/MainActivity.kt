package com.kbh3983.log

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.platformViewsController.registry.registerViewFactory(
            "timenow_camera_view",
            TimenowCameraViewFactory(flutterEngine.dartExecutor.binaryMessenger, this)
        )
    }
}
