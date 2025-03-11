using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.IO;

namespace MacTrackpadTest
{
    /// <summary>
    /// Minimal diagnostic test class with no dependencies
    /// </summary>
    [TestClass]
    public class SimpleDiagnosticTest
    {
        [TestMethod]
        [TestCategory("DiagnosticOnly")]
        public void TestBasicFunctionality()
        {
            Console.WriteLine("=== Basic Diagnostic Test ===");
            Console.WriteLine($"OS: {Environment.OSVersion}");
            Console.WriteLine($".NET Version: {Environment.Version}");
            Console.WriteLine($"Current Directory: {Environment.CurrentDirectory}");
            Console.WriteLine($"Assembly: {GetType().Assembly.Location}");
            
            // This should always pass
            Assert.IsTrue(true);
        }
    }
} 