package de.bssb.meinbssb

import android.os.Build
import android.os.Bundle
import androidx.activity.enableEdgeToEdge
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Only enable edge-to-edge on Android 11 (API 30) and above
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            enableEdgeToEdge()
        }
        super.onCreate(savedInstanceState)
    }
}
