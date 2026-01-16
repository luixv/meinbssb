package de.bssb.meinbssb

import android.os.Build
import android.os.Bundle
import androidx.activity.enableEdgeToEdge
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Enable edge-to-edge display for Android 11 (API 30) and above
        // Required for proper inset handling on Android 15+ while maintaining Android 10 compatibility
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            enableEdgeToEdge()
        }
        super.onCreate(savedInstanceState)
    }
}
