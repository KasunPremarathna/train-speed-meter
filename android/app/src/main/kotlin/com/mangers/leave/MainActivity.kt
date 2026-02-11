package com.mangers.leave

import android.location.GnssStatus
import android.location.LocationManager
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.mangers.leave/gnss"
    private var gnssStatus: GnssStatus? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getGnssStatus") {
                val statusMap = mutableMapOf<String, Int>()
                var inView = 0
                var usedInFix = 0

                gnssStatus?.let {
                    inView = it.satelliteCount
                    for (i in 0 until inView) {
                        if (it.usedInFix(i)) {
                            usedInFix++
                        }
                    }
                }

                statusMap["inView"] = inView
                statusMap["usedInFix"] = usedInFix
                result.success(statusMap)
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val locationManager = getSystemService(LOCATION_SERVICE) as LocationManager
        val gnssStatusCallback = object : GnssStatus.Callback() {
            override fun onSatelliteStatusChanged(status: GnssStatus) {
                gnssStatus = status
            }
        }

        try {
            locationManager.registerGnssStatusCallback(gnssStatusCallback, null)
        } catch (e: SecurityException) {
            // Permission not granted yet
        }
    }
}
