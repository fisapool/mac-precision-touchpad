using System;
using System.Runtime.InteropServices;
using System.Threading;
using Microsoft.Win32.SafeHandles;

namespace MacTrackpadTest
{
    /// <summary>
    /// Mock implementation of driver interface for testing without an actual driver
    /// </summary>
    public class MockDriverInterface : IDisposable
    {
        private readonly TestLogger _logger;
        private readonly AutoResetEvent _responseEvent = new AutoResetEvent(false);
        private bool _disposed = false;
        private bool _mockConnected = false;
        
        public MockDriverInterface(TestLogger? logger = null)
        {
            _logger = logger ?? new TestLogger("MockDriverLog.txt");
            _logger.LogInfo("Initialized mock driver interface");
        }
        
        public bool Connect()
        {
            _logger.LogInfo("Mock: Connecting to driver (simulated)");
            // Always succeed in mock mode
            _mockConnected = true;
            return true;
        }
        
        public bool IsConnected()
        {
            return _mockConnected;
        }
        
        public bool SendCommand(byte commandId, byte[]? data = null)
        {
            if (!_mockConnected)
            {
                _logger.LogError("Mock: Cannot send command - not connected");
                return false;
            }
            
            _logger.LogInfo($"Mock: Sending command {commandId} with {data?.Length ?? 0} bytes");
            // Simulate successful command execution
            Thread.Sleep(50); // Simulate processing time
            _responseEvent.Set();
            return true;
        }
        
        public byte[]? ReadResponse(int timeoutMs = 1000)
        {
            if (!_mockConnected)
            {
                _logger.LogError("Mock: Cannot read response - not connected");
                return null;
            }
            
            bool signaled = _responseEvent.WaitOne(timeoutMs);
            if (!signaled)
            {
                _logger.LogError("Mock: Response timeout");
                return null;
            }
            
            // Return a mock response
            _logger.LogInfo("Mock: Received response");
            return new byte[] { 0x00, 0xFF, 0xAA, 0x55 }; // Mock data pattern
        }
        
        public void Disconnect()
        {
            _logger.LogInfo("Mock: Disconnecting from driver");
            _mockConnected = false;
        }
        
        public void Dispose()
        {
            if (!_disposed)
            {
                _disposed = true;
                Disconnect();
                _responseEvent.Dispose();
            }
        }
    }
} 