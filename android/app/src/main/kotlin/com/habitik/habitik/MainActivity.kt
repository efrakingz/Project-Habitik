package com.habitik.habitik

import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Forzar 120Hz en pantallas de alta tasa de refresco (Samsung Galaxy S23, etc.)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val currentDisplay = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                display
            } else {
                @Suppress("DEPRECATION")
                windowManager.defaultDisplay
            }

            val modes = currentDisplay?.supportedModes
            val highRefreshMode = modes?.maxByOrNull { it.refreshRate }

            if (highRefreshMode != null && highRefreshMode.refreshRate >= 90f) {
                val params = window.attributes
                params.preferredDisplayModeId = highRefreshMode.modeId
                window.attributes = params
            }
        }
    }
}
