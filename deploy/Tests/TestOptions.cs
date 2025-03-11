namespace MacTrackpadTest
{
    /// <summary>
    /// Global test configuration options
    /// </summary>
    public static class TestOptions
    {
        /// <summary>
        /// When true, tests will use mock implementations that don't require actual hardware
        /// </summary>
        public static bool UseMockDriver { get; set; } = true;
        
        /// <summary>
        /// When true, tests will skip operations that require administrator privileges
        /// </summary>
        public static bool SkipAdminOperations { get; set; } = true;
        
        /// <summary>
        /// When true, tests will output more detailed logs
        /// </summary>
        public static bool VerboseLogging { get; set; } = true;
        
        /// <summary>
        /// When true, tests will suspend on errors for debugging
        /// </summary>
        public static bool SuspendOnError { get; set; } = false;
        
        /// <summary>
        /// Configure test options for running without admin rights or hardware
        /// </summary>
        public static void ConfigureForCITesting()
        {
            UseMockDriver = true;
            SkipAdminOperations = true;
            VerboseLogging = true;
            SuspendOnError = false;
        }
        
        /// <summary>
        /// Configure test options for running with hardware
        /// </summary>
        public static void ConfigureForHardwareTesting()
        {
            UseMockDriver = false;
            SkipAdminOperations = false;
            VerboseLogging = true;
            SuspendOnError = true;
        }

        // Add this static constructor to check environment variables
        static TestOptions()
        {
            string envMockDriver = Environment.GetEnvironmentVariable("DOTNET_MOCK_DRIVER");
            if (!string.IsNullOrEmpty(envMockDriver) && 
                (envMockDriver.Equals("true", StringComparison.OrdinalIgnoreCase) || 
                 envMockDriver.Equals("1", StringComparison.OrdinalIgnoreCase)))
            {
                UseMockDriver = true;
            }
        }
    }
} 