# Troubleshooting Guide

This guide addresses common issues when installing and using ROCm on Zorin OS and other Ubuntu-based distributions.

## 🔧 Installation Issues

### "zorin is not a supported OS"
**Problem**: ROCm installer doesn't recognize Zorin OS
**Solution**: 
1. Use the automated installation script
2. Or manually modify `/etc/os-release` temporarily
3. See main installation guide

### "ROCk module is NOT loaded"
**Problem**: amdgpu kernel module not loaded
**Causes**: 
- Secure Boot enabled
- Driver not properly installed
- Kernel module signing issues

**Solutions**:
1. **Disable Secure Boot** (easiest)
   ```bash
   sudo mokutil --disable-validation
   # Reboot and follow prompts
   ```

2. **Enroll MOK Keys** (keep Secure Boot)
   ```bash
   # Create MOK key
   openssl req -new -x509 -newkey rsa:2048 -keyout MOK.priv -outform DER -out MOK.der -nodes -days 36500 -subj "/CN=ROCm modules/"
   
   # Enroll key
   sudo mokutil --import MOK.der
   # Reboot and follow prompts
   ```

### "Key was rejected by service"
**Problem**: Secure Boot blocking kernel module
**Solution**: Disable Secure Boot or enroll proper keys (see above)

## 🚀 Runtime Issues

### HIP Compilation Errors
**Problem**: `hipcc` command not found or compilation fails
**Solutions**:
1. **Check Environment**:
   ```bash
   source ~/.bashrc
   which hipcc
   hipcc --version
   ```

2. **Check Installation**:
   ```bash
   ls /home/mo/rocm-installer/rocm-7.2.0/bin/hipcc
   ```

3. **Manual Path**:
   ```bash
   /home/mo/rocm-installer/rocm-7.2.0/bin/hipcc your_file.cpp
   ```

### "GPU not detected"
**Problem**: `rocminfo` shows no GPU
**Causes**:
- amdgpu driver not loaded
- GPU not supported
- Hardware issues

**Solutions**:
1. **Check Driver**:
   ```bash
   lsmod | grep amdgpu
   sudo modprobe amdgpu
   ```

2. **Check GPU Support**:
   ```bash
   lspci | grep -i vga
   # Verify GPU is supported by ROCm
   ```

3. **Check Hardware**:
   ```bash
   sudo lshw -C display
   dmesg | grep -i amdgpu
   ```

### Memory/Performance Issues
**Problem**: Poor performance or memory errors
**Solutions**:
1. **Monitor GPU**:
   ```bash
   rocm-smi
   watch -n 1 rocm-smi
   ```

2. **Check Memory Usage**:
   ```bash
   free -h
   cat /proc/meminfo | grep -E "(MemTotal|MemAvailable)"
   ```

3. **Thermal Throttling**:
   ```bash
   rocm-smi --showtemp
   # Ensure adequate cooling
   ```

## 📚 Library-Specific Issues

### ROCBLAS Issues
**Problem**: `error: rocblas/rocblas.h: No such file or directory`
**Solution**:
```bash
# Include proper headers
hipcc your_code.cpp -I/home/mo/rocm-installer/rocm-7.2.0/include -lrocblas
```

### ROCRAND Issues
**Problem**: Random number generation fails
**Solutions**:
1. **Check Generator Creation**:
   ```cpp
   rocrand_status status = rocrand_create_generator(&generator, ROCRAND_RNG_PSEUDO_XORWOW);
   if (status != ROCRAND_STATUS_SUCCESS) {
       // Handle error
   }
   ```

2. **Seed Generator**:
   ```cpp
   rocrand_set_seed(generator, 12345ULL);
   ```

### HIP Kernel Launch Failures
**Problem**: Kernel execution fails
**Solutions**:
1. **Check GPU Memory**:
   ```bash
   rocm-smi --showmeminfo
   ```

2. **Validate Kernel Parameters**:
   ```cpp
   // Check grid and block dimensions
   size_t maxThreadsPerBlock;
   hipDeviceGetAttribute(&maxThreadsPerBlock, hipDeviceAttributeMaxThreadsPerBlock, 0);
   ```

3. **Error Checking**:
   ```cpp
   hipError_t err = hipLaunchKernel(kernel, grid, block, shared_mem, stream, args);
   if (err != hipSuccess) {
       printf("Kernel launch failed: %s\n", hipGetErrorString(err));
   }
   ```

## 🔍 Debugging Tools

### ROCm Debugging
```bash
# GPU monitoring
rocm-smi

# GPU information
rocminfo

# Performance profiling
rocprof --hip-trace ./your_program

# Debug agent
export HSA_ENABLE_DEBUG=1
export AMD_SERIALIZE_KERNEL=3
./your_program
```

### System Diagnostics
```bash
# Kernel messages
dmesg | grep -i amdgpu

# PCI devices
lspci -vnn | grep -i vga

# System information
uname -r
lsb_release -a

# Memory info
free -h
cat /proc/meminfo
```

## 🛠️ Common Fixes

### Reinstall ROCm
```bash
# Remove existing installation
sudo apt remove --purge rocm* amdgpu-dkms
rm -rf /home/mo/rocm-installer

# Reinstall using script
./install-rocm-zorin.sh
```

### Reset Environment
```bash
# Reset shell environment
source ~/.bashrc

# Manually set paths
export PATH=$HOME/rocm-installer/rocm-7.2.0/bin:$PATH
export LD_LIBRARY_PATH=$HOME/rocm-installer/rocm-7.2.0/lib:$LD_LIBRARY_PATH
```

### Update System
```bash
# Update system packages
sudo apt update && sudo apt upgrade

# Update kernel
sudo apt install linux-generic

# Reboot after updates
sudo reboot
```

## 📞 Getting Help

### Check Logs
```bash
# ROCm logs
ls /home/mo/rocm-installer/logs/
cat /home/mo/rocm-installer/logs/install_*.log

# System logs
journalctl -xe | grep -i amdgpu
journalctl -xe | grep -i rocm
```

### Community Resources
- [ROCm GitHub Issues](https://github.com/RadeonOpenCompute/ROCm/issues)
- [ROCm Documentation](https://rocm.docs.amd.com/)
- [AMD Community Forums](https://community.amd.com/)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/rocm)

### Report Issues
When reporting issues, include:
1. System information (`uname -a`)
2. GPU information (`lspci | grep VGA`)
3. ROCm version (`rocminfo | head -10`)
4. Error messages
5. Steps to reproduce

## 🎯 Prevention Tips

1. **Regular Updates**: Keep system and ROCm updated
2. **Monitor System**: Use `rocm-smi` to monitor GPU health
3. **Backup Configuration**: Save working configurations
4. **Test Changes**: Test changes in small increments
5. **Document Setup**: Keep notes of working configurations

This troubleshooting guide should help resolve most common ROCm issues on Zorin OS.
