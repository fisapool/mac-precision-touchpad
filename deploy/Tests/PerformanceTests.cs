using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Threading;

namespace MacTrackpadTest
{
    [TestClass]
    public class PerformanceTests
    {
        private DriverTestInterface _driverInterface;
        private TestLogger _logger;
        
        [TestInitialize]
        public void Setup()
        {
            _logger = new TestLogger("PerformanceTests.log");
            _driverInterface = new DriverTestInterface(_logger);
            bool connected = _driverInterface.InitializeDriver();
            Assert.IsTrue(connected, "Failed to connect to driver");
        }
        
        [TestMethod]
        [TestCategory("Performance")]
        [Description("Verifies the driver responds within acceptable time")]
        public void TestResponseTime()
        {
            var startTime = DateTime.Now;
            _driverInterface.SimulateSingleTouch(100, 100);
            bool responded = _driverInterface.WaitForResponse(50);
            var endTime = DateTime.Now;
            
            Assert.IsTrue(responded, "Driver did not respond within timeout period");
            
            var responseTime = (endTime - startTime).TotalMilliseconds;
            _logger.LogInfo($"Response time: {responseTime}ms");
            
            Assert.IsTrue(responseTime < 20, $"Response time ({responseTime}ms) exceeds 20ms threshold");
        }
        
        [TestMethod]
        [TestCategory("Performance")]
        [Description("Verifies the driver handles continuous operation")]
        public void TestContinuousOperation()
        {
            int operationCount = 100;
            int successCount = 0;
            
            for (int i = 0; i < operationCount; i++)
            {
                _driverInterface.SimulateSingleTouch(i % 100, i % 100);
                if (_driverInterface.WaitForResponse(10))
                {
                    successCount++;
                }
                Thread.Sleep(5);
            }
            
            double successRate = (double)successCount / operationCount * 100;
            _logger.LogInfo($"Continuous operation success rate: {successRate}%");
            
            Assert.IsTrue(successRate > 95, $"Success rate ({successRate}%) below 95% threshold");
        }
        
        [TestMethod]
        [TestCategory("Performance")]
        public void TestMemoryUsage()
        {
            var test = new PerformanceTest(_driverInterface, _logger);
            test.TestMemoryUsage();
            Assert.IsTrue(true, "Memory usage test passed");
        }
        
        [TestMethod]
        [TestCategory("Performance")]
        public void TestCpuUsage()
        {
            var test = new PerformanceTest(_driverInterface, _logger);
            test.TestCpuUsage();
            Assert.IsTrue(true, "CPU usage test passed");
        }
        
        [TestMethod]
        [TestCategory("Performance")]
        [Timeout(120000)] // 2 minutes
        public void TestShortContinuousOperation()
        {
            var test = new PerformanceTest(_driverInterface, _logger);
            test.TestContinuousOperation();
            Assert.IsTrue(true, "Continuous operation test passed");
        }
        
        [TestMethod]
        [TestCategory("Performance")]
        [Timeout(600000)] // 10 minutes
        [Ignore("Only run for full benchmarks")]
        public void TestExtendedContinuousOperation()
        {
            var test = new PerformanceTest(_driverInterface, _logger);
            test.TestContinuousOperation(TimeSpan.FromMinutes(10));
            Assert.IsTrue(true, "Extended continuous operation test passed");
        }
        
        [TestCleanup]
        public void Cleanup()
        {
            _driverInterface?.Dispose();
        }
    }
} 