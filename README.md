# Mac Trackpad Driver Testing Environment

This repository contains a testing environment for the Mac Trackpad Driver. Since building the actual driver requires the Windows Driver Kit (WDK), this environment provides mock files and simulations to test the driver's functionality without requiring a full build.

## Table of Contents

- [Setup](#setup)
- [Running Tests](#running-tests)
- [Testing Workflow](#testing-workflow)
- [Mock Files](#mock-files)
- [Troubleshooting](#troubleshooting)

## Setup

To set up the testing environment, run:

```powershell
.\setup_build_env.ps1
```

This script will:
1. Create necessary directories
2. Generate mock driver files
3. Set up test configurations
4. Create test scripts

If you want to set up a real build environment with the Windows Driver Kit, follow the instructions in the WDK documentation.

## Running Tests

### Basic Tests

To run basic functionality tests:

```powershell
.\src\MacTrackpadTest\RunMockedTests.cmd
```

### Installation Simulation

To simulate driver installation:

```powershell
.\src\MacTrackpadSetup\SimulateInstall.cmd
```

### Uninstallation Simulation

To simulate driver uninstallation:

```powershell
.\src\MacTrackpadSetup\SimulateUninstall.cmd
```

### Master Test Script

To run all tests and generate reports:

```powershell
.\master_test.ps1 -RunAllTests -GenerateReport
```

## Testing Workflow

A typical testing workflow consists of:

1. Setting up the environment
2. Running installation simulation
3. Running functionality tests
4. Running uninstallation simulation
5. Generating test reports

## Mock Files

The following mock files are generated:

- `bin\x64\Release\AmtPtpDevice.sys` - Mock driver system file
- `bin\x64\Release\AmtPtpDevice.inf` - Mock driver information file
- `bin\x64\Release\AmtPtpDevice.cat` - Mock catalog file

These files are also copied to `src\MacTrackpadSetup\Driver\` for installation testing.

## Troubleshooting

### Installation Issues

If you encounter issues with mock installation:

1. Ensure you're running the script with administrator privileges
2. Check if the mock files exist in the correct locations
3. Review the simulation logs

### Test Failures

If tests fail:

1. Check if all mock files are present
2. Ensure the test configuration is correct
3. Run the `check_structure.ps1` script to verify your environment 