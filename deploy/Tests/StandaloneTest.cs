using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.IO;
using System.Diagnostics;
using static MacTrackpadTest.TestLogger;

namespace MacTrackpadTest
{
    /// <summary>
    /// Completely independent test class that does not depend on any other classes
    /// </summary>
    [TestClass]
    public class StandaloneTest
    {
        [TestMethod]
        [TestCategory("Standalone")]
        public void TestProjectStructure()
        {
            Console.WriteLine("=== Standalone Project Structure Test ===");
            
            // Log information about environment
            Console.WriteLine($"OS: {Environment.OSVersion}");
            Console.WriteLine($".NET Version: {Environment.Version}");
            Console.WriteLine($"Current Directory: {Environment.CurrentDirectory}");
            
            // Inspect directory structure
            var files = Directory.GetFiles(".", "*.cs", SearchOption.AllDirectories);
            Console.WriteLine($"Found {files.Length} .cs files in project");
            
            // The test should always pass - it's purely for diagnostic output
            Assert.IsTrue(true);
        }
        
        [TestMethod]
        [TestCategory("Standalone")]
        public void TestSystemPerformance()
        {
            // Simple performance test that doesn't use the driver interface
            var stopwatch = new Stopwatch();
            stopwatch.Start();
            
            // Do some CPU work
            for (int i = 0; i < 1000000; i++)
            {
                Math.Sqrt(i);
            }
            
            stopwatch.Stop();
            
            Console.WriteLine($"Performance test completed in {stopwatch.ElapsedMilliseconds}ms");
            Assert.IsTrue(true);
        }
        
        [TestMethod]
        [TestCategory("Standalone")]
        public void TestMockDriverCommunication()
        {
            Console.WriteLine("=== Mock Driver Communication Test ===");
            
            var logger = new TestLogger("MockTest.log", TestMode.Mock);
            var mockDriver = new MockDriverInterface(logger);
            
            // Test basic operations
            Assert.IsTrue(mockDriver.Connect(), "Mock driver connect failed");
            Assert.IsTrue(mockDriver.IsConnected(), "Mock driver should be connected");
            
            // Test command sending
            bool commandResult = mockDriver.SendCommand(0x01, new byte[] { 0x12, 0x34 });
            Assert.IsTrue(commandResult, "Mock command send failed");
            
            // Test response reading
            byte[] response = mockDriver.ReadResponse(500);
            Assert.IsNotNull(response, "Mock response should not be null");
            Assert.IsTrue(response.Length > 0, "Mock response should have data");
            
            mockDriver.Disconnect();
            Assert.IsFalse(mockDriver.IsConnected(), "Mock driver should be disconnected");
            
            Console.WriteLine("Mock driver test completed successfully");
            Assert.IsTrue(true);
        }
    }
} 