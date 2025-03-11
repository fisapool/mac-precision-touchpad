using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MacTrackpadTest
{
    /// <summary>
    /// Helper methods for tests
    /// </summary>
    public static class TestHelper
    {
        /// <summary>
        /// Runs a test in the appropriate mode (mock or real)
        /// </summary>
        public static void RunTest(TestContext context, Action realTest, Action mockTest)
        {
            bool useMock = TestOptions.UseMockDriver || 
                          (Environment.GetEnvironmentVariable("DOTNET_MOCK_DRIVER") ?? "").Equals("true", StringComparison.OrdinalIgnoreCase);
            
            if (useMock)
            {
                Console.WriteLine($"Running {context.TestName} in MOCK mode");
                mockTest();
            }
            else
            {
                Console.WriteLine($"Running {context.TestName} with REAL driver");
                realTest();
            }
        }
        
        /// <summary>
        /// Checks if we should skip a test that requires administrator rights
        /// </summary>
        public static bool ShouldSkipAdminTest()
        {
            if (TestOptions.SkipAdminOperations)
            {
                Console.WriteLine("Skipping test that requires administrator rights");
                return true;
            }
            return false;
        }
        
        /// <summary>
        /// Checks if hardware is needed and available
        /// </summary>
        public static bool IsHardwareAvailable()
        {
            // In a real implementation, this would check if Mac touchpad hardware is present
            return !TestOptions.UseMockDriver;
        }
    }
} 