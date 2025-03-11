using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MacTrackpadTest
{
    [TestClass]
    public class MockModeAssemblyInitializer
    {
        [AssemblyInitialize]
        public static void AssemblyInit(TestContext context)
        {
            // Check for mock mode environment variable
            string envMockDriver = Environment.GetEnvironmentVariable("DOTNET_MOCK_DRIVER");
            if (!string.IsNullOrEmpty(envMockDriver) && 
                (envMockDriver.Equals("true", StringComparison.OrdinalIgnoreCase) || 
                 envMockDriver.Equals("1", StringComparison.OrdinalIgnoreCase)))
            {
                Console.WriteLine("==================================");
                Console.WriteLine("MOCK DRIVER MODE ENABLED GLOBALLY");
                Console.WriteLine("==================================");
                TestOptions.UseMockDriver = true;
                TestOptions.SkipAdminOperations = true;
            }
        }
    }
} 