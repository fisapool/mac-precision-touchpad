using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.IO;

namespace MacTrackpadTest
{
    [TestClass]
    public class EmergencyTests
    {
        [TestMethod]
        [TestCategory("Emergency")]
        public void TestEnvironmentInfo()
        {
            // This test should always pass and provide diagnostic info
            Console.WriteLine("=== MacTrackpad Emergency Test ===");
            Console.WriteLine($"OS: {Environment.OSVersion}");
            Console.WriteLine($".NET Version: {Environment.Version}");
            Console.WriteLine($"Current Directory: {Environment.CurrentDirectory}");
            
            // Check for critical files
            var filesExist = new[] {
                "MacTrackpadTest.dll",
                "MacTrackpadTest.deps.json",
                "MacTrackpadTest.runtimeconfig.json"
            };
            
            foreach (var file in filesExist)
            {
                bool exists = File.Exists(file);
                Console.WriteLine($"File '{file}' exists: {exists}");
            }
            
            Assert.IsTrue(true, "Emergency test completed");
        }
    }
} 