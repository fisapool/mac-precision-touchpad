using System;
using System.Diagnostics;
using System.IO;
using System.Threading.Tasks;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MacTrackpadTest.Tests;
using static MacTrackpadTest.TestLogger;

namespace MacTrackpadTest
{
    /// <summary>
    /// Core test framework for MacTrackpad driver testing
    /// </summary>
    public class TestFramework
    {
        private readonly TestLogger _logger;
        private readonly DriverTestInterface _driverInterface;
        
        public TestFramework(bool useMockMode = true)
        {
            _logger = new TestLogger("TestLog.txt", useMockMode ? TestMode.Mock : TestMode.Normal);
            _driverInterface = new DriverTestInterface(_logger, useMockMode);
            
            _logger.LogInfo($"Test framework initialized (Mock Mode: {useMockMode})");
            TestOptions.UseMockDriver = useMockMode;
        }
        
        /// <summary>
        /// Runs the complete test suite
        /// </summary>
        public async Task RunAllTests()
        {
            _logger.LogInfo("Starting MacTrackpad test suite");
            
            try
            {
                // Driver installation tests
                await RunDriverInstallationTests();
                
                // Driver communication tests
                RunDriverCommunicationTests();
                
                // Gesture recognition tests
                RunGestureRecognitionTests();
                
                // Settings persistence tests
                RunSettingsPersistenceTests();
                
                // Performance tests
                RunPerformanceTests();
                
                // Windows version compatibility tests
                RunWindowsVersionTests();
                
                _logger.LogInfo("All tests completed successfully");
            }
            catch (Exception ex)
            {
                _logger.LogError($"Test suite failed: {ex.Message}");
                throw;
            }
        }
        
        private async Task RunDriverInstallationTests()
        {
            _logger.LogInfo("Running driver installation tests");
            
            // Test clean installation
            var cleanInstallTest = new DriverInstallationTest(_logger, true);
            await cleanInstallTest.RunTest();
            
            // Test upgrade installation
            var upgradeTest = new DriverInstallationTest(_logger, false);
            await upgradeTest.RunTest();
        }
        
        private void RunDriverCommunicationTests()
        {
            _logger.LogInfo("Running driver communication tests");
            
            // Basic connectivity
            var connectivityTest = new DriverConnectivityTest(_driverInterface, _logger);
            connectivityTest.TestConnection();
            
            // Command sending
            var commandTest = new DriverCommandTest(_driverInterface, _logger);
            commandTest.TestCommand();
            
            // Event handling
            var eventTest = new DriverEventTest(_driverInterface, _logger);
            eventTest.TestEventHandling();
        }
        
        private void RunGestureRecognitionTests()
        {
            _logger.LogInfo("Running gesture recognition tests");
            
            // Simulates touch input to test gesture recognition
            var gestureTest = new GestureRecognitionTest(_driverInterface, _logger);
            
            // Two-finger scroll test
            gestureTest.TestTwoFingerScroll();
            
            // Three-finger swipe test
            gestureTest.TestThreeFingerSwipe();
            
            // Pinch test
            gestureTest.TestPinchGesture();
            
            // Rotation test
            gestureTest.TestRotationGesture();
            
            gestureTest.TestGestureRecognition();
        }
        
        private void RunSettingsPersistenceTests()
        {
            _logger.LogInfo("Running settings persistence tests");
            
            var settingsTest = new SettingsPersistenceTest(_logger);
            settingsTest.TestSettingsPersistence();
            settingsTest.TestSettingsSave();
            settingsTest.TestSettingsLoad();
            settingsTest.TestSettingsApply();
            settingsTest.TestProfileManagement();
        }
        
        private void RunPerformanceTests()
        {
            _logger.LogInfo("Running performance tests");
            
            var perfTest = new PerformanceTest(_driverInterface, _logger);
            perfTest.TestResponseTime();
            perfTest.TestContinuousOperation();
            perfTest.TestMemoryUsage();
            perfTest.TestCpuUsage();
        }
        
        private void RunWindowsVersionTests()
        {
            _logger.LogInfo("Running Windows version compatibility tests");
            
            var winVerTest = new WindowsVersionTest(_driverInterface, _logger);
            
            // Windows 11 tests
            if (IsWindows11())
            {
                winVerTest.TestWindows11Compatibility();
                winVerTest.TestWindows11Features();
            }
            
            // Windows 10 tests (for backward compatibility)
            if (IsWindows10())
            {
                winVerTest.TestWindows10Compatibility();
            }
        }
        
        private bool IsWindows11()
        {
            return Environment.OSVersion.Version.Build >= 22000;
        }
        
        private bool IsWindows10()
        {
            var version = Environment.OSVersion.Version;
            return version.Major == 10 && version.Build < 22000;
        }
    }
} 