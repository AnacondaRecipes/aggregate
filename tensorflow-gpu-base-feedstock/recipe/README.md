To build a conda tensorflow package with GPU support

* Build the required Docker containers:

    Dockerfiles can be found at: https://github.com/jjhelmus/docker-images

    CUDA 8.0, CuDNN 6: pkg_build_cuda80_cudnn6_centos6_dt2
    CUDA 8.0, CuDNN 7: pkg_build_cuda80_cudnn7_centos6_dt2
    CUDA 9.0, CuDNN 7: pkg_build_cuda90_cudnn7_centos6_notoolset

* Start the docker container using:

    ```
    docker run -v `pwd`:/io -it pkg_build_cuda80_cudnn7_centos6_dt2 /bin/bash
    ```

* Create a symlink for libcuda.so.1

    ```
    ln -s /usr/local/cuda/lib64/stubs/libcuda.so /usr/local/cuda/lib64/stubs/libcuda.so.1
    ```

* For CUDA 8 support one file needs to be copied:

    ```
    cp /usr/local/cuda-8.0/nvvm/libdevice/libdevice.compute_50.10.bc /usr/local/cuda-8.0/nvvm/libdevice/libdevice.10.bc
    ```

    see: https://github.com/tensorflow/tensorflow/issues/17801

* Update conda and conda-build, and navigate to the recipe root folder.

    Modify conda_build_config.yaml in this directory to specifiy the
    CUDA, CuDNN, and python versions.

    To start a build use:

    ```
    conda build --no-test -c jjhelmus/label/sles11_cuda_toolchain .
    ```

    To log the build output use:
    ```
    conda build --no-test -c jjhelmus/label/sles11_cuda_toolchain .  2>&1 | tee ../tf_gpu_build.log
    ```
