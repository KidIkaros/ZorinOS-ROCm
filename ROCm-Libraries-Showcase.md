# ROCm Libraries Showcase

This document showcases the various ROCm libraries available and their capabilities on your AMD Radeon RX 9060 XT.

## 🚀 Performance Benchmarks

### ROCBLAS (Basic Linear Algebra Subprograms)
- **Function**: Matrix multiplication (SGEMM)
- **Performance**: **4,057 GFLOPS**
- **Use Case**: Deep learning, scientific computing
- **Test Command**: `hipcc test_rocblas.cpp -lrocblas -o test_rocblas && ./test_rocblas`

### ROCRAND (Random Number Generation)
- **Function**: Uniform random number generation
- **Performance**: **35.8 G numbers/sec**
- **Memory Bandwidth**: **133.2 GB/s**
- **Use Case**: Monte Carlo simulations, machine learning
- **Test Command**: `hipcc test_rocrand.cpp -lrocrand -o test_rocrand && ./test_rocrand`

### HIP (Heterogeneous-compute Interface for Portability)
- **Function**: General GPU computing
- **Memory Bandwidth**: **283.7 GB/s**
- **Matrix Performance**: **363.6 GFLOPS**
- **Use Case**: Custom GPU kernels, parallel computing
- **Test Command**: `hipcc rocm_benchmark.cpp -o rocm_benchmark && ./rocm_benchmark`

## 📚 Available ROCm Libraries

### Core Libraries
| Library | Function | Performance | Use Cases |
|---------|----------|-------------|-----------|
| **ROCBLAS** | Linear Algebra | 4+ TFLOPS | Deep Learning, HPC |
| **ROCFFT** | Fast Fourier Transform | High | Signal Processing |
| **ROCRAND** | Random Numbers | 35+ G/sec | Monte Carlo, ML |
| **ROCSOLVER** | Dense Linear Solvers | High | Scientific Computing |
| **ROCSPARSE** | Sparse Linear Algebra | High | Graph Algorithms |
| **HIP** | GPU Computing | 283+ GB/s | General Purpose |

### Vision & Media Libraries
| Library | Function | Use Cases |
|---------|----------|-----------|
| **MIVisionX** | Computer Vision | Image Processing, ML |
| **ROCJPEG** | JPEG Encoding/Decoding | Media Applications |
| **ROCDecode** | Video Decoding | Media Streaming |

### Profiling & Debugging
| Library | Function | Use Cases |
|---------|----------|-----------|
| **ROCProfiler** | Performance Profiling | Optimization |
| **ROCTracer** | API Tracing | Debugging |
| **ROCdebug-agent** | Debug Support | Development |
| **ROCm-SMI** | System Monitoring | System Management |

## 🛠️ Library Usage Examples

### ROCBLAS Example
```cpp
#include <rocblas/rocblas.h>

rocblas_handle handle;
rocblas_create_handle(&handle);

// Matrix multiplication C = alpha * A * B + beta * C
rocblas_sgemm(handle, 
               rocblas_operation_none, rocblas_operation_none,
               M, N, K, &alpha, d_A, M, d_B, K, &beta, d_C, M);
```

### ROCRAND Example
```cpp
#include <rocrand/rocrand.h>

rocrand_generator generator;
rocrand_create_generator(&generator, ROCRAND_RNG_PSEUDO_XORWOW);
rocrand_set_seed(generator, 12345ULL);

// Generate uniform random numbers
rocrand_generate_uniform(generator, d_random, N);
```

### HIP Example
```cpp
__global__ void myKernel(float* data, int n) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < n) {
        data[idx] *= 2.0f;
    }
}

myKernel<<<blocks, threads>>>(d_data, n);
```

## 📊 Performance Summary

| Metric | Value | Unit |
|--------|-------|------|
| **GPU** | AMD Radeon RX 9060 XT | - |
| **Architecture** | gfx1200 | - |
| **Memory** | 16 GB | GDDR6 |
| **Compute Units** | 32 | - |
| **Peak Memory Bandwidth** | 283.7 | GB/s |
| **Peak Matrix Performance** | 4,057 | GFLOPS |
| **Random Generation** | 35.8 | G numbers/sec |

## 🎯 Recommended Applications

### Deep Learning
- **ROCBLAS**: Matrix operations for neural networks
- **HIP**: Custom kernel development
- **ROCRAND**: Weight initialization, dropout

### Scientific Computing
- **ROCBLAS**: Linear algebra operations
- **ROCSOLVER**: Matrix decompositions
- **ROCFFT**: Spectral analysis

### Signal Processing
- **ROCFFT**: FFT operations
- **ROCBLAS**: Filter operations
- **HIP**: Custom algorithms

### Computer Vision
- **MIVisionX**: Image processing pipelines
- **ROCJPEG**: Image compression
- **HIP**: Custom vision algorithms

## 🔧 Integration Tips

1. **Link Libraries**: Use `-l<library>` when compiling
2. **Header Files**: Located in `/home/mo/rocm-installer/rocm-7.2.0/include/`
3. **Shared Libraries**: Located in `/home/mo/rocm-installer/rocm-7.2.0/lib/`
4. **Performance**: Always benchmark on your specific hardware

## 📖 Additional Resources

- [ROCm Documentation](https://rocm.docs.amd.com/)
- [HIP Programming Guide](https://rocm.docs.amd.com/projects/HIP/en/latest/)
- [ROCm GitHub](https://github.com/RadeonOpenCompute)

## 🚀 Getting Started

1. **Environment Setup**: Source your `~/.bashrc` or restart terminal
2. **Choose Library**: Select appropriate library for your use case
3. **Compile**: Use `hipcc` with appropriate `-l` flags
4. **Test**: Start with provided examples
5. **Optimize**: Use ROCProfiler for performance tuning

Your AMD Radeon RX 9060 XT with ROCm 7.2.0 provides excellent performance for a wide range of GPU computing applications!
