using System;
using System.IO;
using System.Threading;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MacTrackpadTest
{
    /// <summary>
    /// Provides logging functionality for tests
    /// </summary>
    public class TestLogger
    {
        private readonly string _logFilePath;
        private readonly object _lockObj = new object();
        private static TestLogger _instance;

        public enum TestMode
        {
            Normal,
            Mock
        }

        private TestMode _testMode = TestMode.Normal;

        public TestMode Mode
        {
            get { return _testMode; }
            set { _testMode = value; LogInfo($"Test mode set to {_testMode}"); }
        }

        public static TestLogger Instance
        {
            get
            {
                if (_instance == null)
                {
                    _instance = new TestLogger("DefaultTestLog.log");
                }
                return _instance;
            }
        }

        public TestLogger(string logFileName)
        {
            string logsDir = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "TestLogs");
            
            // Create logs directory if it doesn't exist
            if (!Directory.Exists(logsDir))
            {
                Directory.CreateDirectory(logsDir);
            }
            
            _logFilePath = Path.Combine(logsDir, logFileName);
            
            // Initialize with timestamp
            LogInfo($"Test log started at {DateTime.Now}");
        }

        public TestLogger(string logFile, TestMode mode)
            : this(logFile)
        {
            _testMode = mode;
            LogInfo($"Test logger initialized in {_testMode} mode");
        }

        public void LogInfo(string message)
        {
            Log($"[INFO] {message}");
        }

        public void LogWarning(string message)
        {
            Log($"[WARNING] {message}");
        }

        public void LogError(string message)
        {
            Log($"[ERROR] {message}");
        }

        private void Log(string message)
        {
            string timestampedMessage = $"{DateTime.Now:yyyy-MM-dd HH:mm:ss.fff} - {message}";
            Console.WriteLine(timestampedMessage);
            
            lock (_lockObj)
            {
                try
                {
                    File.AppendAllText(_logFilePath, timestampedMessage + Environment.NewLine);
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Failed to write to log file: {ex.Message}");
                }
            }
        }

        public void LogTestStart(TestContext testContext)
        {
            LogInfo($"Starting test: {testContext?.TestName}");
        }

        public void LogTestEnd(TestContext testContext, bool passed)
        {
            var status = passed ? "PASSED" : "FAILED";
            LogInfo($"Test {testContext?.TestName} {status}");
        }

        public void LogException(Exception ex)
        {
            LogError($"Exception: {ex.Message}");
            LogError($"Stack trace: {ex.StackTrace}");
        }
    }
} 