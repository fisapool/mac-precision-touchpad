# Mac-Trackpad

## Mac Trackpad Driver Testing Environment

This repository contains a testing environment for the Mac Trackpad Driver. Since building the actual driver requires the Windows Driver Kit (WDK), this environment provides mock files and simulations to test the driver's functionality without requiring a full build.

## Table of Contents

- [Setup](#setup)
- [Running Tests](#running-tests)
- [Testing Workflow](#testing-workflow)
- [Mock Files](#mock-files)
- [Troubleshooting](#troubleshooting)

## Setup

To set up the testing environment, run:

```
.\one_click_setup.bat
```

This script will:
1. Create necessary directories
2. Generate mock driver files
3. Set up test configurations
4. Create test scripts

## Running Tests

### Basic Tests

To run basic functionality tests:

```
.\run_tests.bat
```

### Installation Simulation

To simulate driver installation:

```
.\run_install.bat
```

### Uninstallation Simulation

To simulate driver uninstallation:

```
.\run_uninstall.bat
```

### Control Panel

To access all tools through a menu interface:

```
.\mac_trackpad_tools_enhanced.bat
```

## Testing Workflow

A typical testing workflow consists of:

1. Setting up the environment
2. Running installation simulation
3. Running functionality tests
4. Running uninstallation simulation
5. Viewing the dashboard

## Mock Files

The following mock files are included:

- `src\MacTrackpadSetup\SimulateInstall.cmd` - Installation simulation
- `src\MacTrackpadSetup\SimulateUninstall.cmd` - Uninstallation simulation
- `src\MacTrackpadTest\RunMockedTests.cmd` - Mock test runner

## Troubleshooting

### Installation Issues

If you encounter issues with mock installation:

1. Ensure you're running the script with administrator privileges
2. Check if the mock files exist in the correct locations
3. Run `verify_and_repair.bat` to fix missing components

### Visual Studio Code Configuration

If you encounter issues with VS Code:

1. Run `fix_vscode_config.bat` to update your configuration
2. This will create a simplified C/C++ properties file without WDK paths

### Building the Dashboard

If you want to build the C# dashboard:

1. Make sure you have .NET SDK installed
2. Run `launch_dashboard.bat` which will build and launch the application
