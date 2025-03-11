using System;
using System.Runtime.InteropServices;
using System.Threading;
using Microsoft.Win32.SafeHandles;

namespace MacTrackpadTest
{
    /// <summary>
    /// Interface for testing the driver by simulating input and receiving events
    /// </summary>
    public class DriverTestInterface : IDisposable
    {
        private SafeFileHandle _driverHandle;
        private bool _connected = false;
        private readonly TestLogger _logger;
        private readonly AutoResetEvent _responseEvent = new AutoResetEvent(false);
        
        private string? _devicePath = string.Empty;
        
        // IOCTL codes for testing
        private const uint IOCTL_TEST_CONNECTION = 0x223000;
        private const uint IOCTL_SIMULATE_TOUCH = 0x223004;
        private const uint IOCTL_SIMULATE_GESTURE = 0x223008;
        
        private readonly bool _useMockMode;
        private MockDriverInterface _mockDriver;
        private MockInstallationTest _mockInstallation;
        private MockPerformanceTest _mockPerformance;
        
        [StructLayout(LayoutKind.Sequential)]
        private struct TouchSimulationData
        {
            public int FingerCount;
            public int X;
            public int Y;
            public int DeltaX;
            public int DeltaY;
            public uint Flags;
        }
        
        public DriverTestInterface(TestLogger logger = null, bool useMockMode = false)
        {
            _logger = logger ?? new TestLogger("DriverTestLog.txt");
            _useMockMode = useMockMode;
            
            if (_useMockMode)
            {
                _mockDriver = new MockDriverInterface(_logger);
                _mockInstallation = new MockInstallationTest(_logger);
                _mockPerformance = new MockPerformanceTest(_logger);
                _logger.LogInfo("Using mock driver interface");
            }
            else
            {
                _logger.LogInfo("Using real driver interface");
            }
        }
        
        public bool InitializeDriver(string? devicePath = "")
        {
            try
            {
                _devicePath = devicePath ?? string.Empty;
                if (_connected)
                    return true;
                
                _driverHandle = CreateFile(
                    _devicePath,
                    FileAccess.ReadWrite,
                    FileShare.ReadWrite,
                    IntPtr.Zero,
                    FileMode.Open,
                    FileAttributes.Normal,
                    IntPtr.Zero
                );
                
                if (_driverHandle.IsInvalid)
                {
                    _logger.LogError($"Failed to connect to driver: {Marshal.GetLastWin32Error()}");
                    return false;
                }
                
                // Test connection
                bool testSuccess = SendIOControl(IOCTL_TEST_CONNECTION, IntPtr.Zero, 0);
                if (!testSuccess)
                {
                    _logger.LogError("Driver connection test failed");
                    return false;
                }
                
                _connected = true;
                _logger.LogInfo("Successfully connected to driver");
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Connection error: {ex.Message}");
                return false;
            }
        }
        
        public void SimulateSingleTouch(int x, int y)
        {
            if (!EnsureConnected())
                return;
            
            var data = new TouchSimulationData
            {
                FingerCount = 1,
                X = x,
                Y = y,
                Flags = 1 // Contact
            };
            
            SendTouchData(data);
        }
        
        public void SimulateTwoFingerSwipe(int deltaX, int deltaY)
        {
            if (!EnsureConnected())
                return;
            
            var data = new TouchSimulationData
            {
                FingerCount = 2,
                DeltaX = deltaX,
                DeltaY = deltaY,
                Flags = 2 // Swipe gesture
            };
            
            SendTouchData(data);
        }
        
        public void SimulateThreeFingerSwipe(int deltaX, int deltaY)
        {
            if (!EnsureConnected())
                return;
            
            var data = new TouchSimulationData
            {
                FingerCount = 3,
                DeltaX = deltaX,
                DeltaY = deltaY,
                Flags = 2 // Swipe gesture
            };
            
            SendTouchData(data);
        }
        
        public bool SimulateGesture(int startX, int startY, int endX, int endY, uint flags = 0)
        {
            if (!EnsureConnected())
                return false;
            
            // Create gesture data structure
            var data = new TouchSimulationData
            {
                FingerCount = 1,
                X = startX,
                Y = startY,
                DeltaX = endX - startX,
                DeltaY = endY - startY,
                Flags = flags
            };
            
            // Allocate buffer for data
            IntPtr buffer = Marshal.AllocHGlobal(Marshal.SizeOf(data));
            try
            {
                // Copy data to buffer
                Marshal.StructureToPtr(data, buffer, false);
                
                // Send IOCTL command
                bool success = SendIOControl(IOCTL_SIMULATE_GESTURE, buffer, (uint)Marshal.SizeOf(data));
                
                // Signal response for test waiting
                if (success)
                    _responseEvent.Set();
                
                return success;
            }
            catch (Exception ex)
            {
                _logger.LogException(ex);
                return false;
            }
            finally
            {
                Marshal.FreeHGlobal(buffer);
            }
        }
        
        public bool SimulateThreeFingerSwipeUp()
        {
            return SimulateGesture(100, 300, 100, 100, 0x02); // Flag for 3 fingers
        }
        
        public bool SimulateFourFingerSwipeLeft()
        {
            return SimulateGesture(300, 200, 100, 200, 0x03); // Flag for 4 fingers
        }
        
        public bool WaitForResponse(int timeout)
        {
            // In a real implementation, this would wait for some event 
            // signaling the driver has processed the input
            return _responseEvent.WaitOne(timeout);
        }
        
        private void SendTouchData(TouchSimulationData data)
        {
            int size = Marshal.SizeOf(data);
            IntPtr buffer = Marshal.AllocHGlobal(size);
            
            try
            {
                Marshal.StructureToPtr(data, buffer, false);
                bool success = SendIOControl(IOCTL_SIMULATE_TOUCH, buffer, (uint)size);
                
                if (!success)
                {
                    _logger.LogError("Failed to send touch simulation data");
                }
            }
            finally
            {
                Marshal.FreeHGlobal(buffer);
            }
        }
        
        private bool EnsureConnected()
        {
            if (!_connected)
                return InitializeDriver();
            
            return _connected;
        }
        
        private bool SendIOControl(uint controlCode, IntPtr inBuffer, uint inBufferSize)
        {
            if (_driverHandle == null || _driverHandle.IsInvalid)
                return false;
            
            uint bytesReturned = 0;
            
            bool success = DeviceIoControl(
                _driverHandle,
                controlCode,
                inBuffer,
                inBufferSize,
                IntPtr.Zero,
                0,
                ref bytesReturned,
                IntPtr.Zero
            );
            
            return success;
        }
        
        public void Dispose()
        {
            if (_driverHandle != null && !_driverHandle.IsInvalid)
            {
                _driverHandle.Dispose();
                _driverHandle = null!;
            }
        }
        
        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern SafeFileHandle CreateFile(
            string lpFileName,
            [MarshalAs(UnmanagedType.U4)] FileAccess dwDesiredAccess,
            [MarshalAs(UnmanagedType.U4)] FileShare dwShareMode,
            IntPtr lpSecurityAttributes,
            [MarshalAs(UnmanagedType.U4)] FileMode dwCreationDisposition,
            [MarshalAs(UnmanagedType.U4)] FileAttributes dwFlagsAndAttributes,
            IntPtr hTemplateFile
        );
        
        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern bool DeviceIoControl(
            SafeFileHandle hDevice,
            uint dwIoControlCode,
            IntPtr lpInBuffer,
            uint nInBufferSize,
            IntPtr lpOutBuffer,
            uint nOutBufferSize,
            ref uint lpBytesReturned,
            IntPtr lpOverlapped
        );
        
        public bool Connect()
        {
            if (_useMockMode)
            {
                return _mockDriver.Connect();
            }
            
            return InitializeDriver();
        }
        
        public MockInstallationTest GetMockInstallation()
        {
            return _mockInstallation;
        }
        
        public MockPerformanceTest GetMockPerformance()
        {
            return _mockPerformance;
        }
        
        public bool IsInMockMode()
        {
            return _useMockMode;
        }
    }
} 