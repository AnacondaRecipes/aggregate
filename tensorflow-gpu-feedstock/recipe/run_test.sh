# LD_LIBRARY_PATH needs to be adjusted to find the libcuda.so file
# This may change depending on the system configuration.  
# This path is for the nvidia/cuda:7.5-cudnn5-devel-centos6 container
LD_LIBRARY_PATH="/usr/local/nvidia/lib64:$LD_LIBRARY_PATH" python gpu_test.py
