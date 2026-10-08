package com.app.compass

import android.hardware.SensorManager
import android.view.Surface

internal enum class CompassSensorMode { ROTATION_VECTOR, FALLBACK }

internal data class CompassSensorSelection(
    val mode: CompassSensorMode?,
    val unavailableReason: String? = null,
)

internal object CompassMath {
    fun normalizeDegrees(value: Double): Double = ((value % 360.0) + 360.0) % 360.0

    fun axesFor(rotation: Int): Pair<Int, Int> = when (rotation) {
        Surface.ROTATION_90 -> SensorManager.AXIS_Y to SensorManager.AXIS_MINUS_X
        Surface.ROTATION_180 -> SensorManager.AXIS_MINUS_X to SensorManager.AXIS_MINUS_Y
        Surface.ROTATION_270 -> SensorManager.AXIS_MINUS_Y to SensorManager.AXIS_X
        else -> SensorManager.AXIS_X to SensorManager.AXIS_Y
    }

    fun sensorAccuracy(accuracy: Int?): String = when (accuracy) {
        SensorManager.SENSOR_STATUS_UNRELIABLE -> "unreliable"
        SensorManager.SENSOR_STATUS_ACCURACY_LOW -> "low"
        SensorManager.SENSOR_STATUS_ACCURACY_MEDIUM -> "medium"
        SensorManager.SENSOR_STATUS_ACCURACY_HIGH -> "high"
        else -> "unknown"
    }

    fun reading(heading: Double?, accuracy: Int?): Map<String, Any?> {
        val quality = sensorAccuracy(accuracy)
        val validHeading = heading?.takeIf { it.isFinite() && quality != "unreliable" }
            ?.let(::normalizeDegrees)
        return mapOf(
            "status" to if (validHeading != null && (quality == "medium" || quality == "high")) {
                "ready"
            } else {
                "calibrating"
            },
            "magneticHeadingDegrees" to validHeading,
            "accuracyDegrees" to null,
            "sensorAccuracy" to quality,
            "unavailableReason" to null,
        )
    }

    fun selectSensors(
        rotationVectorAvailable: Boolean,
        accelerometerAvailable: Boolean,
        magneticFieldAvailable: Boolean,
        registerRotationVector: () -> Boolean,
        registerFallback: () -> Boolean,
        unregister: () -> Unit,
    ): CompassSensorSelection {
        if (rotationVectorAvailable) {
            if (registerRotationVector()) {
                return CompassSensorSelection(CompassSensorMode.ROTATION_VECTOR)
            }
            unregister()
        }
        if (!accelerometerAvailable || !magneticFieldAvailable) {
            return CompassSensorSelection(
                null, if (rotationVectorAvailable) "sensorFailure" else "sensorNotFound",
            )
        }
        if (registerFallback()) return CompassSensorSelection(CompassSensorMode.FALLBACK)
        unregister()
        return CompassSensorSelection(null, "sensorFailure")
    }
}
