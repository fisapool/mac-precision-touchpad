using System;
using System.Linq;
using System.Reflection;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MacTrackpadTest
{
    /// <summary>
    /// Dynamically disables real tests when running in mock mode
    /// </summary>
    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Method, AllowMultiple = false)]
    public class DisableInMockModeAttribute : Attribute, ITestFilter
    {
        public bool Match(object sender)
        {
            // Check if we're in mock mode
            bool isMockMode = TestOptions.UseMockDriver || 
                (Environment.GetEnvironmentVariable("DOTNET_MOCK_DRIVER") ?? "")
                .Equals("true", StringComparison.OrdinalIgnoreCase);
                
            // Return true to skip test when in mock mode
            return isMockMode;
        }
    }
}

namespace Microsoft.VisualStudio.TestTools.UnitTesting
{
    // Add the ITestFilter interface to MSTest namespace
    public interface ITestFilter
    {
        bool Match(object sender);
    }
} 