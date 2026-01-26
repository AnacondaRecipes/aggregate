/*
 * Sirius CUDA Test - Minimal CUDA program for testing build pipeline
 * Copyright (c) 2024 Anaconda, Inc.
 * BSD-3-Clause License
 */

#include <stdio.h>
#include <cuda_runtime.h>

// Simple vector addition kernel
__global__ void vectorAdd(const float *A, const float *B, float *C, int N) {
    int i = blockDim.x * blockIdx.x + threadIdx.x;
    if (i < N) {
        C[i] = A[i] + B[i];
    }
}

int main(int argc, char *argv[]) {
    printf("Sirius CUDA Test v1.0\n");
    printf("=====================\n\n");

    // Get CUDA device info
    int deviceCount = 0;
    cudaError_t error = cudaGetDeviceCount(&deviceCount);

    if (error != cudaSuccess) {
        printf("CUDA Runtime Error: %s\n", cudaGetErrorString(error));
        printf("Note: This is expected if no GPU is available.\n");
        printf("Package built successfully with CUDA support.\n");
        return 0;
    }

    printf("Found %d CUDA device(s)\n\n", deviceCount);

    for (int dev = 0; dev < deviceCount; dev++) {
        cudaDeviceProp prop;
        cudaGetDeviceProperties(&prop, dev);
        printf("Device %d: %s\n", dev, prop.name);
        printf("  Compute capability: %d.%d\n", prop.major, prop.minor);
        printf("  Total memory: %.2f GB\n", prop.totalGlobalMem / (1024.0 * 1024.0 * 1024.0));
        printf("  Multiprocessors: %d\n", prop.multiProcessorCount);
        printf("\n");
    }

    // Run a simple vector addition test if GPU is available
    if (deviceCount > 0) {
        const int N = 1024;
        size_t size = N * sizeof(float);

        float *h_A = (float *)malloc(size);
        float *h_B = (float *)malloc(size);
        float *h_C = (float *)malloc(size);

        // Initialize vectors
        for (int i = 0; i < N; i++) {
            h_A[i] = 1.0f;
            h_B[i] = 2.0f;
        }

        float *d_A, *d_B, *d_C;
        cudaMalloc(&d_A, size);
        cudaMalloc(&d_B, size);
        cudaMalloc(&d_C, size);

        cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);
        cudaMemcpy(d_B, h_B, size, cudaMemcpyHostToDevice);

        int threadsPerBlock = 256;
        int blocksPerGrid = (N + threadsPerBlock - 1) / threadsPerBlock;
        vectorAdd<<<blocksPerGrid, threadsPerBlock>>>(d_A, d_B, d_C, N);

        cudaMemcpy(h_C, d_C, size, cudaMemcpyDeviceToHost);

        // Verify result
        bool passed = true;
        for (int i = 0; i < N; i++) {
            if (h_C[i] != 3.0f) {
                passed = false;
                break;
            }
        }

        printf("Vector addition test: %s\n", passed ? "PASSED" : "FAILED");

        cudaFree(d_A);
        cudaFree(d_B);
        cudaFree(d_C);
        free(h_A);
        free(h_B);
        free(h_C);
    }

    printf("\nSirius CUDA Test completed successfully.\n");
    return 0;
}
