# Mac Trackpad Driver Installation Guide

This guide will walk you through installing the Mac Trackpad driver for Windows.

## System Requirements

- Windows 10 (1809 or later) or Windows 11
- Administrator privileges
- A supported Apple Magic Trackpad or MacBook Pro trackpad

## Installation Steps

### Automatic Installation

1. Extract the deployment package to a folder on your computer
2. Right-click on `Tools\Install.bat` and select "Run as administrator"
3. Follow the on-screen instructions
4. Restart your computer when prompted

### Manual Installation

If the automatic installer doesn't work, you can install the driver manually:

1. Open Device Manager
2. Locate your trackpad (it may appear as "Unknown device" or "HID-compliant mouse")
3. Right-click and select "Update driver"
4. Choose "Browse my computer for driver software"
5. Navigate to the extracted `Driver` folder
6. Follow the on-screen instructions
7. Restart your computer

## Dashboard Installation

The Mac Trackpad Dashboard provides a user-friendly interface to configure your trackpad:

1. After installing the driver, navigate to the `Dashboard` folder
2. Run `Setup.exe` to install the dashboard application
3. The dashboard will start automatically after installation

## Verifying Installation

After rebooting:

1. Open Device Manager
2. Expand the "Human Interface Devices" category
3. You should see "Apple Magic Trackpad" or similar device listed
4. The trackpad should work with multi-touch gestures

## Troubleshooting

If you encounter issues:

1. Check the Windows Event Viewer for any driver-related errors
2. Run the diagnostic tool: `Tools\Diagnose.bat`
3. If problems persist, collect logs using `Tools\CollectLogs.bat` and contact support

## Uninstallation

To remove the driver:

1. Run `Tools\Uninstall.bat` as administrator
2. Restart your computer

## Support

For technical support, please visit our GitHub repository or contact us via email. 