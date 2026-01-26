"""
Sirius CUDA Test - Minimal package for testing PBP build pipeline.

This package tests CUDA availability at runtime without requiring
CUDA compilation during build.
"""

__version__ = "1.0.0"

import argparse
import sys


def check_cuda():
    """Check CUDA availability using various methods."""
    results = {
        "cuda_available": False,
        "device_count": 0,
        "devices": [],
        "method": None,
    }

    # Try PyTorch first
    try:
        import torch
        if torch.cuda.is_available():
            results["cuda_available"] = True
            results["device_count"] = torch.cuda.device_count()
            results["method"] = "pytorch"
            for i in range(results["device_count"]):
                results["devices"].append({
                    "index": i,
                    "name": torch.cuda.get_device_name(i),
                    "memory": torch.cuda.get_device_properties(i).total_memory,
                })
            return results
    except ImportError:
        pass

    # Try numba.cuda
    try:
        from numba import cuda
        if cuda.is_available():
            results["cuda_available"] = True
            results["method"] = "numba"
            devices = list(cuda.gpus)
            results["device_count"] = len(devices)
            for i, dev in enumerate(devices):
                results["devices"].append({
                    "index": i,
                    "name": dev.name.decode() if isinstance(dev.name, bytes) else dev.name,
                })
            return results
    except ImportError:
        pass

    # Try pycuda
    try:
        import pycuda.driver as cuda_driver
        import pycuda.autoinit
        results["cuda_available"] = True
        results["method"] = "pycuda"
        results["device_count"] = cuda_driver.Device.count()
        for i in range(results["device_count"]):
            dev = cuda_driver.Device(i)
            results["devices"].append({
                "index": i,
                "name": dev.name(),
                "memory": dev.total_memory(),
            })
        return results
    except ImportError:
        pass
    except Exception:
        pass

    # No CUDA library available - that's OK for testing the build pipeline
    results["method"] = "none"
    return results


def main():
    """Main entry point for the sirius-cuda-test command."""
    parser = argparse.ArgumentParser(
        description="Sirius CUDA Test - Check CUDA availability"
    )
    parser.add_argument(
        "--version", "-v",
        action="version",
        version=f"sirius-cuda-test {__version__}"
    )
    parser.add_argument(
        "--json", "-j",
        action="store_true",
        help="Output results as JSON"
    )

    args = parser.parse_args()

    print("Sirius CUDA Test v{}".format(__version__))
    print("=" * 40)
    print()

    results = check_cuda()

    if args.json:
        import json
        print(json.dumps(results, indent=2))
        return 0

    if results["cuda_available"]:
        print(f"CUDA Available: Yes (detected via {results['method']})")
        print(f"Device Count: {results['device_count']}")
        print()
        for dev in results["devices"]:
            print(f"Device {dev['index']}: {dev['name']}")
            if "memory" in dev:
                memory_gb = dev["memory"] / (1024**3)
                print(f"  Memory: {memory_gb:.2f} GB")
    else:
        print("CUDA Available: No")
        print()
        print("Note: This is expected if:")
        print("  - No NVIDIA GPU is present")
        print("  - CUDA drivers are not installed")
        print("  - No CUDA Python library (torch, numba, pycuda) is installed")
        print()
        print("The package was built and installed successfully.")

    print()
    print("Sirius CUDA Test completed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
