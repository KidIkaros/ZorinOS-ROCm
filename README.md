# ROCm on Zorin OS

A comprehensive guide and automation scripts for installing AMD ROCm on Zorin OS and other Ubuntu-based distributions.

## Overview

This repository provides solutions for installing AMD ROCm (Radeon Open Compute platform) on Zorin OS and other Ubuntu-based Linux distributions that are not officially supported by the ROCm installer.

## Files

- [`ROCm-Zorin-OS-Installation-Guide.md`](ROCm-Zorin-OS-Installation-Guide.md) - Complete step-by-step installation guide
- [`install-rocm-zorin.sh`](install-rocm-zorin.sh) - Automated installation script
- [`README.md`](README.md) - This file

## Quick Start

### Option 1: Automated Installation (Recommended)

```bash
# Download the installation script
wget https://raw.githubusercontent.com/your-username/ROCm-Zorin-OS/main/install-rocm-zorin.sh

# Make it executable
chmod +x install-rocm-zorin.sh

# Run the installation
./install-rocm-zorin.sh
```

### Option 2: Manual Installation

Follow the detailed steps in [ROCm-Zorin-OS-Installation-Guide.md](ROCm-Zorin-OS-Installation-Guide.md).

## System Requirements

- **OS**: Zorin OS 18 or other Ubuntu 24.04-based distributions
- **GPU**: AMD GPU supported by ROCm 7.2.0
- **Storage**: 30GB free disk space
- **RAM**: 8GB+ recommended
- **Privileges**: Sudo/administrator access

## Supported GPUs

ROCm 7.2.0 supports AMD GPUs including:
- Radeon RX 7000 series (RDNA 3)
- Radeon RX 6000 series (RDNA 2)  
- Radeon RX 5000 series (RDNA)
- AMD Instinct accelerators
- Other ROCm-compatible AMD GPUs

For the complete list, see the [official ROCm GPU support page](https://rocm.docs.amd.com/projects/install-on-linux/en/latest/reference/gpu-support.html).

## What Gets Installed

- **ROCm Core**: Runtime and development environment
- **HIP**: Heterogeneous-compute Interface for Portability
- **Libraries**: rocBLAS, rocFFT, rocRAND, rocSOLVER, etc.
- **Tools**: Compilers, debuggers, profilers, system utilities
- **Documentation**: API references and guides

## Post-Installation Usage

### Verify Installation
```bash
# Check GPU detection
rocminfo

# Check compiler version  
hipcc --version

# Monitor GPU status
rocm-smi
```

### Compile Your First HIP Program
```bash
# Create a test program
cat > test.cpp << 'EOF'
#include <hip/hip_runtime.h>
#include <iostream>

int main() {
    int deviceCount = 0;
    hipGetDeviceCount(&deviceCount);
    std::cout << "Found " << deviceCount << " HIP devices" << std::endl;
    return 0;
}
EOF

# Compile and run
hipcc test.cpp -o test
./test
```

## Troubleshooting

### Common Issues

1. **"zorin is not a supported OS"**
   - Ensure OS identification is properly modified before installation
   - Check that the installation script completed successfully

2. **GPU not detected**
   - Verify your GPU is ROCm-compatible
   - Check amdgpu driver: `lsmod | grep amdgpu`
   - Ensure proper permissions: `groups $USER` (should include render/video)

3. **Compilation errors**
   - Source environment: `source ~/.bashrc`
   - Check PATH includes ROCm binaries
   - Verify library paths are correct

### Getting Help

- Check the [ROCm Documentation](https://rocm.docs.amd.com/)
- Review the [Installation Guide](ROCm-Zorin-OS-Installation-Guide.md)
- Open an issue on this repository

## Compatibility

This solution has been tested with:
- **Zorin OS 18** with ROCm 7.2.0
- **AMD Radeon RX 9060 XT** GPU

It should also work with:
- Other Ubuntu 24.04-based distributions
- Other ROCm-supported AMD GPUs
- Different ROCm versions (may require URL adjustments)

## Security Notes

- The installation script temporarily modifies `/etc/os-release` and restores it automatically
- All modifications are safely reverted after installation
- No sensitive system information is stored or transmitted
- Downloads are from official AMD repositories

## Contributing

Contributions are welcome! Please:
1. Fork this repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### Areas for Contribution

- Support for additional Ubuntu-based distributions
- Support for different ROCm versions
- Enhanced error handling and logging
- Additional verification tests
- Documentation improvements

## License

This project is provided as-is for educational and development purposes. Please refer to the official AMD ROCm license terms for the ROCm software itself.

## Disclaimer

This is not an official AMD project. The ROCm software is provided by AMD, and this guide only addresses installation on unsupported distributions. Use at your own risk.

## References

- [ROCm Official Documentation](https://rocm.docs.amd.com/)
- [ROCm Installation Guide](https://rocm.docs.amd.com/projects/install-on-linux/en/latest/)
- [HIP Programming Guide](https://rocm.docs.amd.com/projects/HIP/en/latest/)
- [AMD GPU Support List](https://rocm.docs.amd.com/projects/install-on-linux/en/latest/reference/gpu-support.html)

---

**Note**: Always refer to the official ROCm documentation for the most up-to-date information and official support channels.
