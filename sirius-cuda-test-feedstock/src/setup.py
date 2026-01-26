from setuptools import setup, find_packages

setup(
    name="sirius-cuda-test",
    version="1.0.0",
    packages=find_packages(),
    entry_points={
        "console_scripts": [
            "sirius-cuda-test=sirius_cuda_test:main",
        ],
    },
    python_requires=">=3.8",
    author="Sirius QA Team",
    author_email="sirius-qa@anaconda.com",
    description="Minimal CUDA test package for Sirius QA testing",
    license="BSD-3-Clause",
)
