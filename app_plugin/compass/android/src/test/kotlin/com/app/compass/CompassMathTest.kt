package com.app.compass

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class CompassMathTest {
    @Test
    fun normalizesNegativeAndWrappedHeadings() {
        assertEquals(359.0, CompassMath.normalizeDegrees(-1.0), 0.0)
        assertEquals(0.0, CompassMath.normalizeDegrees(360.0), 0.0)
        assertEquals(1.5, CompassMath.normalizeDegrees(721.5), 0.0)
        assertEquals(0.0, CompassMath.normalizeDegrees(-720.0), 0.0)
    }

    @Test
    fun remapsAllFourDisplayRotations() {
        assertEquals(1 to 2, CompassMath.axesFor(0))
        assertEquals(2 to 129, CompassMath.axesFor(1))
        assertEquals(129 to 130, CompassMath.axesFor(2))
        assertEquals(130 to 1, CompassMath.axesFor(3))
    }

    @Test
    fun onlyMediumAndHighAccuracyProduceReadyReadings() {
        for (accuracy in listOf(2, 3)) {
            val reading = CompassMath.reading(15.0, accuracy)
            assertEquals("ready", reading["status"])
            assertEquals(15.0, reading["magneticHeadingDegrees"])
            assertNull(reading["accuracyDegrees"])
            assertNull(reading["unavailableReason"])
        }
        assertEquals("medium", CompassMath.sensorAccuracy(2))
        assertEquals("high", CompassMath.sensorAccuracy(3))
    }

    @Test
    fun lowAndUnknownQualityRetainHeadingWithoutClaimingReady() {
        for (accuracy in listOf(1, null, -1, 4)) {
            val reading = CompassMath.reading(-1.0, accuracy)
            assertEquals("calibrating", reading["status"])
            assertEquals(359.0, reading["magneticHeadingDegrees"])
            assertNull(reading["accuracyDegrees"])
        }
        assertEquals("low", CompassMath.sensorAccuracy(1))
        assertEquals("unknown", CompassMath.sensorAccuracy(null))
    }

    @Test
    fun unreliableAndInvalidSamplesNeverInventNorth() {
        assertNull(CompassMath.reading(15.0, 0)["magneticHeadingDegrees"])
        assertEquals("unreliable", CompassMath.sensorAccuracy(0))
        for (heading in listOf(null, Double.NaN, Double.POSITIVE_INFINITY)) {
            val reading = CompassMath.reading(heading, 3)
            assertEquals("calibrating", reading["status"])
            assertNull(reading["magneticHeadingDegrees"])
        }
    }

    @Test
    fun rotationVectorIsPreferredWithoutRegisteringFallback() {
        var fallbackCalls = 0
        val selected = CompassMath.selectSensors(
            true, true, true, { true }, { fallbackCalls++; true }, {},
        )
        assertEquals(CompassSensorMode.ROTATION_VECTOR, selected.mode)
        assertNull(selected.unavailableReason)
        assertEquals(0, fallbackCalls)
    }

    @Test
    fun failedRotationVectorIsCleanedBeforeFallbackRegistration() {
        val calls = mutableListOf<String>()
        val selected = CompassMath.selectSensors(
            true, true, true,
            { calls.add("rotation"); false },
            { calls.add("fallback"); true },
            { calls.add("unregister") },
        )
        assertEquals(listOf("rotation", "unregister", "fallback"), calls)
        assertEquals(CompassSensorMode.FALLBACK, selected.mode)
    }

    @Test
    fun absentRotationVectorUsesAvailableFallback() {
        val selected = CompassMath.selectSensors(
            false, true, true, { throw AssertionError("No rotation sensor") }, { true }, {},
        )
        assertEquals(CompassSensorMode.FALLBACK, selected.mode)
    }

    @Test
    fun incompleteFallbackReportsMissingHardwareWithoutRegistration() {
        for (hardware in listOf(false to true, true to false, false to false)) {
            val selected = CompassMath.selectSensors(
                false, hardware.first, hardware.second, { false },
                { throw AssertionError("Incomplete fallback") }, {},
            )
            assertNull(selected.mode)
            assertEquals("sensorNotFound", selected.unavailableReason)
        }
    }

    @Test
    fun failedAvailableRotationVectorReportsFailureWhenFallbackIsIncomplete() {
        for (hardware in listOf(false to true, true to false, false to false)) {
            var cleaned = false
            val selected = CompassMath.selectSensors(
                true, hardware.first, hardware.second, { false },
                { throw AssertionError("Incomplete fallback") }, { cleaned = true },
            )
            assertTrue(cleaned)
            assertNull(selected.mode)
            assertEquals("sensorFailure", selected.unavailableReason)
        }
    }

    @Test
    fun failedFallbackClearsPartialRegistrationAndReportsFailure() {
        var cleaned = false
        val selected = CompassMath.selectSensors(
            false, true, true, { false }, { false }, { cleaned = true },
        )
        assertTrue(cleaned)
        assertNull(selected.mode)
        assertEquals("sensorFailure", selected.unavailableReason)
    }
}
