using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Reflection;

namespace MacTrackpadTest
{
    /// <summary>
    /// Simple verification tests to diagnose project issues
    /// </summary>
    [TestClass]
    public class SimpleVerification
    {
        [TestMethod]
        [TestCategory("Verification")]
        public void TestProjectVerification()
        {
            Console.WriteLine("=== Project Verification ===");
            Console.WriteLine($"Current directory: {Environment.CurrentDirectory}");
            Console.WriteLine($"Assembly location: {Assembly.GetExecutingAssembly().Location}");
            
            // Verify key assemblies are loaded
            ReportAssemblyStatus("MSTest.TestFramework");
            ReportAssemblyStatus("Microsoft.NET.Test.Sdk");
            
            // Check project structure
            ReportFileExists("MacTrackpadTest.dll");
            ReportFileExists("MacTrackpadTest.pdb");
            ReportFileExists("MacTrackpadTest.deps.json");
            
            Console.WriteLine("--- Test verification complete ---");
            Assert.IsTrue(true);
        }
        
        private void ReportAssemblyStatus(string assemblyName)
        {
            try
            {
                var loadedAssembly = Assembly.Load(new AssemblyName(assemblyName));
                Console.WriteLine($"✓ Assembly loaded: {assemblyName} ({loadedAssembly.GetName().Version})");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"✗ Failed to load: {assemblyName}. Error: {ex.Message}");
            }
        }
        
        private void ReportFileExists(string fileName)
        {
            bool exists = File.Exists(fileName);
            Console.WriteLine($"{(exists ? "✓" : "✗")} File {fileName}: {(exists ? "Found" : "Missing")}");
        }
        
        [TestMethod]
        [TestCategory("Verification")]
        public void TestDotNetEnvironment()
        {
            // Run dotnet --info to get detailed environment info
            var process = new Process
            {
                StartInfo = new ProcessStartInfo
                {
                    FileName = "dotnet",
                    Arguments = "--info",
                    RedirectStandardOutput = true,
                    UseShellExecute = false,
                    CreateNoWindow = true
                }
            };
            
            process.Start();
            string output = process.StandardOutput.ReadToEnd();
            process.WaitForExit();
            
            Console.WriteLine("=== .NET Environment ===");
            Console.WriteLine(output);
            
            Assert.IsTrue(true);
        }
    }
} 