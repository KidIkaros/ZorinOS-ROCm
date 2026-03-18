# Installing ROCm 7.2.0 on Zorin OS 18

A step-by-step guide to install AMD ROCm 7.2.0 on Zorin OS 18 (Ubuntu 24.04-based) using the runfile installer.

## Overview

Zorin OS is not officially supported by the ROCm installer, but since it's Ubuntu-based, we can successfully install ROCm by making the installer recognize Zorin OS as Ubuntu.

## Prerequisites

- Zorin OS 18 (or other Ubuntu 24.04-based distributions)
- AMD GPU supported by ROCm
- Sudo/administrator privileges
- ~30GB of free disk space

## Installation Steps

### 1. Download ROCm Runfile Installer

```bash
# Download the Ubuntu 24.04 version of ROCm 7.2.0
wget https://repo.radeon.com/rocm/installer/rocm-runfile-installer/rocm-rel-7.2/ubuntu/24.04/rocm-installer_1.2.5.70200-25-43~24.04.run
```

### 2. Temporarily Modify OS Detection

The ROCm installer checks for specific operating systems. We'll temporarily make it identify Zorin OS as Ubuntu:

```bash
# Backup the original os-release file
sudo cp /etc/os-release /etc/os-release.backup

# Modify OS identification for installer
sudo sed 's/^ID=zorin/ID=ubuntu/' /etc/os-release.backup | sudo tee /etc/os-release
sudo sed 's/^VERSION_ID="18"/VERSION_ID="24.04"/' /etc/os-release | sudo tee /etc/os-release
```

### 3. Run the ROCm Installer

```bash
# Install ROCm with dependencies
bash rocm-installer_1.2.5.70200-25-43~24.04.run deps=install force rocm
```

The installation will:
- Install required dependencies automatically
- Install ROCm 7.2.0 to `/home/username/rocm-installer/rocm-7.2.0/`
- Detect and configure your AMD GPU

### 4. Restore Original OS Configuration

```bash
# Restore the original os-release file
sudo mv /etc/os-release.backup /etc/os-release
```

### 5. Configure Environment

Add ROCm to your shell environment:

```bash
# Add ROCm binaries and libraries to PATH
echo 'export PATH=$HOME/rocm-installer/rocm-7.2.0/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=$HOME/rocm-installer/rocm-7.2.0/lib:$LD_LIBRARY_PATH' >> ~/.bashrc

# Reload shell configuration
source ~/.bashrc
```

### 6. Verify Installation

```bash
# Check GPU detection
rocminfo

# Check HIP compiler version
hipcc --version

# Check ROCm SMI (System Management Interface)
rocm-smi
```

## Expected Output

### rocminfo should show:
```
*** Detected Agent(s) ***
Agent 1
  Name:                    AMD Radeon RX [Your GPU Model]
  Vendor Name:             AMD
  Device Type:             GPU
  ...
*** Done ***
```

### hipcc --version should show:
```
HIP version: 7.2.26015
AMD clang version 22.0.0git
Target: x86_64-unknown-linux-gnu
...
```

## Troubleshooting

### "zorin is not a supported OS" Error
If you encounter this error, ensure the OS identification steps were completed correctly before running the installer.

### Version Mismatch Error
Make sure both `ID` and `VERSION_ID` in `/etc/os-release` are properly modified to match Ubuntu 24.04.

### Permission Issues
Ensure you have sudo privileges for the installation process.

### GPU Not Detected
- Verify your AMD GPU is supported by ROCm 7.2.0
- Check that the amdgpu driver is loaded: `lsmod | grep amdgpu`
- Ensure proper GPU access permissions

## What Gets Installed

The installation includes:
- ROCm Core components
- HIP (Heterogeneous-compute Interface for Portability)
- ROCm mathematical libraries (rocBLAS, rocFFT, rocRAND, etc.)
- Development tools (hipcc, rocm-cmake, debuggers)
- GPU management tools (rocm-smi, rocminfo)

## Post-Installation Usage

### Compile a HIP Program
```bash
# Create a simple HIP test program
cat > hip_test.cpp << 'EOF'
#include <hip/hip_runtime.h>
#include <iostream>

int main() {
    int deviceCount = 0;
    hipGetDeviceCount(&deviceCount);
    std::cout << "Found " << deviceCount << " HIP devices" << std::endl;
    
    for (int i = 0; i < deviceCount; i++) {
        hipDeviceProp_t prop;
        hipGetDeviceProperties(&prop, i);
        std::cout << "Device " << i << ": " << prop.name << std::endl;
    }
    
    return 0;
}
EOF

# Compile and run
hipcc hip_test.cpp -o hip_test
./hip_test
```

### Check GPU Status
```bash
# Monitor GPU status
rocm-smi

# Detailed GPU information
rocminfo
```

## Notes

- This method works for other Ubuntu-based distributions that aren't officially supported
- The installation requires ~30GB of disk space
- ROCm is installed in your home directory, not system-wide
- Remember to restore the original `/etc/os-release` file after installation

## Compatibility

This guide has been tested with:
- **OS**: Zorin OS 18
- **ROCm Version**: 7.2.0
- **GPU**: AMD Radeon RX 9060 XT (should work with other supported AMD GPUs)

## References

- [ROCm Official Documentation](https://rocm.docs.amd.com/)
- [ROCm Installation Guide](https://rocm.docs.amd.com/projects/install-on-linux/en/latest/)
- [Supported AMD GPUs](https://rocm.docs.amd.com/projects/install-on-linux/en/latest/reference/gpu-support.html)

## License

This guide is provided as-is for educational purposes. Please refer to the official ROCm documentation for the most up-to-date information.
