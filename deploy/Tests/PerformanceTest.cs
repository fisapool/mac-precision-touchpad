using System;
using System.Diagnostics;
using System.Threading;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MacTrackpadTest
{
    /// <summary>
    /// Tests driver performance including response time and resource usage
    /// </summary>
    public class PerformanceTest
    {
        private readonly DriverTestInterface _driverInterface;
        private readonly TestLogger _logger;
        
        // Performance thresholds
        private const int MAX_RESPONSE_TIME_MS = 10;
        private const int MAX_CPU_PERCENT = 5;
        private const int MAX_MEMORY_MB = 50;
        
        public PerformanceTest(DriverTestInterface driverInterface, TestLogger logger)
        {
            _driverInterface = driverInterface ?? throw new ArgumentNullException(nameof(driverInterface));
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        }
        
        /// <summary>
        /// Measures the response time for various driver operations
        /// </summary>
        public void TestResponseTime()
        {
            _logger.LogInfo("Testing driver response time");
            
            // Ensure driver is connected
            bool connected = _driverInterface.InitializeDriver();
            if (!connected)
            {
                _logger.LogError("Failed to connect to driver");
                throw new AssertFailedException("Failed to connect to driver for response time test");
            }
            
            // Measure response time for single touch
            var stopwatch = new Stopwatch();
            stopwatch.Start();
            _driverInterface.SimulateSingleTouch(100, 100);
            bool responded = _driverInterface.WaitForResponse(100);
            stopwatch.Stop();
            
            if (!responded)
            {
                _logger.LogError("Driver did not respond to touch within timeout");
                throw new AssertFailedException("Driver did not respond within timeout period");
            }
            
            double touchResponseTime = stopwatch.Elapsed.TotalMilliseconds;
            _logger.LogInfo($"Single touch response time: {touchResponseTime}ms");
            
            if (touchResponseTime > 20)
            {
                _logger.LogWarning($"Touch response time ({touchResponseTime}ms) exceeds 20ms threshold");
                throw new AssertFailedException($"Response time ({touchResponseTime}ms) exceeds 20ms threshold");
            }
            
            // Measure response time for gesture
            stopwatch.Restart();
            _driverInterface.SimulateGesture(50, 50, 150, 50);
            responded = _driverInterface.WaitForResponse(100);
            stopwatch.Stop();
            
            if (!responded)
            {
                _logger.LogError("Driver did not respond to gesture within timeout");
                throw new AssertFailedException("Driver did not respond to gesture within timeout period");
            }
            
            double gestureResponseTime = stopwatch.Elapsed.TotalMilliseconds;
            _logger.LogInfo($"Gesture response time: {gestureResponseTime}ms");
            
            if (gestureResponseTime > 25)
            {
                _logger.LogWarning($"Gesture response time ({gestureResponseTime}ms) exceeds 25ms threshold");
                throw new AssertFailedException($"Gesture response time ({gestureResponseTime}ms) exceeds 25ms threshold");
            }
        }
        
        /// <summary>
        /// Tests the driver's ability to handle continuous operation
        /// </summary>
        /// <param name="duration">Duration of the test</param>
        /// <param name="successThreshold">Minimum acceptable success rate (0-100)</param>
        public void TestContinuousOperation(TimeSpan duration = default, double successThreshold = 95)
        {
            _logger.LogInfo("Testing continuous operation");
            
            // Use default duration of 1 minute if not specified
            if (duration == default)
                duration = TimeSpan.FromMinutes(1);
            
            // Ensure driver is connected
            bool connected = _driverInterface.InitializeDriver();
            if (!connected)
            {
                _logger.LogError("Failed to connect to driver");
                throw new AssertFailedException("Failed to connect to driver for continuous operation test");
            }
            
            int operationCount = 0;
            int successCount = 0;
            
            DateTime startTime = DateTime.Now;
            DateTime endTime = startTime + duration;
            
            // Run operations until the specified duration has elapsed
            while (DateTime.Now < endTime)
            {
                operationCount++;
                
                // Alternate between single touch and gestures
                if (operationCount % 2 == 0)
                    _driverInterface.SimulateSingleTouch(operationCount % 200, operationCount % 200);
                else
                    _driverInterface.SimulateGesture(50, 50, 150, 50);
                    
                if (_driverInterface.WaitForResponse(10))
                {
                    successCount++;
                }
                
                Thread.Sleep(5); // Small delay between operations
            }
            
            double successRate = (double)successCount / operationCount * 100;
            _logger.LogInfo($"Continuous operation success rate: {successRate}% ({successCount}/{operationCount})");
            
            if (successRate < successThreshold)
            {
                _logger.LogError($"Success rate ({successRate}%) below threshold ({successThreshold}%)");
                throw new AssertFailedException($"Success rate ({successRate}%) below threshold ({successThreshold}%)");
            }
        }
        
        /// <summary>
        /// Tests for memory leaks during extended operation
        /// </summary>
        public void TestMemoryUsage(int cycleCount = 10)
        {
            _logger.LogInfo("Testing for memory leaks");
            
            // Record initial memory usage
            var initialMemory = Process.GetCurrentProcess().WorkingSet64;
            _logger.LogInfo($"Initial memory usage: {initialMemory / 1024 / 1024}MB");
            
            // Run multiple cycles of operations
            for (int cycle = 0; cycle < cycleCount; cycle++)
            {
                _logger.LogInfo($"Starting memory test cycle {cycle + 1}");
                
                // Run a series of operations
                TestContinuousOperation(TimeSpan.FromMinutes(1), 90);
                
                // Force garbage collection
                GC.Collect();
                GC.WaitForPendingFinalizers();
                Thread.Sleep(100);
            }
            
            // Record final memory usage
            var finalMemory = Process.GetCurrentProcess().WorkingSet64;
            _logger.LogInfo($"Final memory usage: {finalMemory / 1024 / 1024}MB");
            
            // Calculate growth
            var memoryGrowth = finalMemory - initialMemory;
            _logger.LogInfo($"Memory growth: {memoryGrowth / 1024 / 1024}MB");
            
            // Allow for some memory growth, but not excessive
            long maxAcceptableGrowth = 10 * 1024 * 1024; // 10MB
            if (memoryGrowth > maxAcceptableGrowth)
            {
                _logger.LogWarning($"Memory growth ({memoryGrowth / 1024 / 1024}MB) exceeds threshold (10MB)");
                throw new AssertFailedException($"Memory growth ({memoryGrowth / 1024 / 1024}MB) exceeds threshold (10MB)");
            }
        }
        
        public void TestCpuUsage()
        {
            _logger.LogInfo("Testing CPU usage");
            
            // Measure CPU usage during typical operation
            double cpuUsage = MeasureCpuUsage();
            
            _logger.LogInfo($"CPU usage: {cpuUsage:F2}%");
            Assert.IsTrue(cpuUsage < MAX_CPU_PERCENT,
                $"CPU usage ({cpuUsage}%) exceeds maximum allowed ({MAX_CPU_PERCENT}%)");
        }
        
        private double MeasureCpuUsage()
        {
            // Get driver process
            Process driverProcess = GetDriverProcess();
            
            if (driverProcess != null)
            {
                // Start CPU measurement
                TimeSpan startCpuTime = driverProcess.TotalProcessorTime;
                DateTime startTime = DateTime.Now;
                
                // Wait a bit to measure
                Thread.Sleep(1000);
                
                // Measure again
                driverProcess.Refresh();
                TimeSpan endCpuTime = driverProcess.TotalProcessorTime;
                DateTime endTime = DateTime.Now;
                
                // Calculate CPU percentage
                TimeSpan cpuUsed = endCpuTime.Subtract(startCpuTime);
                TimeSpan totalTime = endTime.Subtract(startTime);
                
                return cpuUsed.TotalMilliseconds / (Environment.ProcessorCount * totalTime.TotalMilliseconds) * 100;
            }
            
            return 0;
        }
        
        private Process GetDriverProcess()
        {
            // Find driver process
            // This would need to be adapted to find the actual driver process
            Process[] processes = Process.GetProcessesByName("AmtPtpDriver");
            return processes.Length > 0 ? processes[0] : null;
        }
    }
} 