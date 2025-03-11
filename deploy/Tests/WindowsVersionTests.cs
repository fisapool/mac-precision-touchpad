using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;

namespace MacTrackpadTest
{
    [TestClass]
    public class WindowsVersionTests
    {
        private DriverTestInterface _driverInterface;
        private TestLogger _logger;
        
        [TestInitialize]
        public void Setup()
        {
            _logger = new TestLogger("WindowsVersionTests.log");
            _driverInterface = new DriverTestInterface(_logger);
            bool connected = _driverInterface.InitializeDriver();
            Assert.IsTrue(connected, "Failed to connect to driver");
        }
        
        [TestMethod]
        [TestCategory("Windows11")]
        public void TestWindows11SpecificFeatures()
        {
            if (Environment.OSVersion.Version.Build < 22000)
            {
                Assert.Inconclusive("This test requires Windows 11");
                return;
            }
            
            var test = new WindowsVersionTest(_driverInterface, _logger);
            test.TestWindows11Features();
        }
        
        [TestMethod]
        [TestCategory("Windows11")]
        public void TestWindows11Compatibility()
        {
            if (Environment.OSVersion.Version.Build < 22000)
            {
                Assert.Inconclusive("This test requires Windows 11");
                return;
            }
            
            var test = new WindowsVersionTest(_driverInterface, _logger);
            test.TestWindows11Compatibility();
        }
        
        [TestMethod]
        [TestCategory("Windows10")]
        [Description("Verifies the driver works on Windows 10")]
        public void TestWindows10Compatibility()
        {
            // Skip test if not running on Windows 10
            var osVersion = Environment.OSVersion.Version;
            if (osVersion.Major != 10)
            {
                Assert.Inconclusive("This test is only for Windows 10");
                return;
            }

            // Test basic functionality on Windows 10
            _driverInterface.SimulateSingleTouch(100, 100);
            Assert.IsTrue(_driverInterface.WaitForResponse(1000), "Driver did not respond to touch");
        }
        
        [TestCleanup]
        public void Cleanup()
        {
            _driverInterface?.Dispose();
        }
    }
} 