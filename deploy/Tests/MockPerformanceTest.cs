using System;
using System.Threading;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MacTrackpadTest
{
    /// <summary>
    /// Mock implementation for performance tests
    /// </summary>
    public class MockPerformanceTest
    {
        private readonly TestLogger _logger;
        
        public MockPerformanceTest(TestLogger logger)
        {
            _logger = logger;
            _logger.LogInfo("Initialized mock performance test");
        }
        
        public bool TestResponseTime()
        {
            _logger.LogInfo("Mock: Testing response time");
            // Simulate a small delay
            Thread.Sleep(50);
            _logger.LogInfo("Mock: Response time test passed");
            return true;
        }
        
        public bool TestContinuousOperation()
        {
            _logger.LogInfo("Mock: Testing continuous operation");
            // Simulate a longer operation
            for (int i = 0; i < 5; i++)
            {
                _logger.LogInfo($"Mock: Continuous operation cycle {i+1}/5");
                Thread.Sleep(100);
            }
            _logger.LogInfo("Mock: Continuous operation test passed");
            return true;
        }
        
        public bool TestMemoryUsage()
        {
            _logger.LogInfo("Mock: Testing memory usage");
            _logger.LogInfo("Mock: Memory usage test passed");
            return true;
        }
        
        public bool TestCpuUsage()
        {
            _logger.LogInfo("Mock: Testing CPU usage");
            _logger.LogInfo("Mock: CPU usage test passed");
            return true;
        }
    }
} 