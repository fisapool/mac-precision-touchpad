using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MacTrackpadTest
{
    [TestClass]
    public class BasicTests
    {
        [TestMethod]
        public void SimpleTest_ShouldPass()
        {
            // A very basic test that should always pass
            Assert.IsTrue(true, "This test should always pass");
        }
        
        [TestMethod]
        [TestCategory("SampleCategory")]
        public void CategoryTest_ShouldAlsoPass()
        {
            // Test with a category to verify category filtering
            Assert.IsTrue(true, "This categorized test should pass");
        }
    }
} 