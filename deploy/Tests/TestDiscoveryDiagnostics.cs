using System;
using System.IO;
using System.Reflection;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MacTrackpadTest.Diagnostics
{
    [TestClass]
    public class TestDiscoveryDiagnostics
    {
        [TestMethod]
        [TestCategory("Diagnostics")]
        public void ListAllTestsInAssembly()
        {
            // This test will list all test methods in the assembly
            // to help diagnose test discovery issues

            var assembly = typeof(TestDiscoveryDiagnostics).Assembly;
            var testClasses = assembly.GetTypes()
                .Where(t => t.GetCustomAttributes<TestClassAttribute>(true).Any());
            
            Console.WriteLine($"Found {testClasses.Count()} test classes:");
            
            foreach (var testClass in testClasses)
            {
                Console.WriteLine($"- {testClass.FullName}");
                
                var testMethods = testClass.GetMethods()
                    .Where(m => m.GetCustomAttributes<TestMethodAttribute>(true).Any());
                
                foreach (var method in testMethods)
                {
                    Console.WriteLine($"  - {method.Name}");
                }
            }
            
            // This test always passes - it's just for diagnostic output
            Assert.IsTrue(true);
        }
        
        [TestMethod]
        [TestCategory("Diagnostics")]
        [TestCategory("DiagnosticOnly")]
        public void VerifyTestEnvironment()
        {
            // Output information about the test environment
            Console.WriteLine($"OS: {Environment.OSVersion}");
            Console.WriteLine($".NET Version: {Environment.Version}");
            Console.WriteLine($"64-bit OS: {Environment.Is64BitOperatingSystem}");
            Console.WriteLine($"64-bit Process: {Environment.Is64BitProcess}");
            Console.WriteLine($"Current Directory: {Environment.CurrentDirectory}");
            Console.WriteLine($"Working Directory: {Directory.GetCurrentDirectory()}");
            
            Assert.IsTrue(true);
        }
    }
} 