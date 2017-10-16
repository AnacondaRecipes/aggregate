To build a conda tensorflow package with GPU support

* Install nvidia-docker on the host machine:
    https://github.com/NVIDIA/nvidia-docker

* Build the pkg_build_nvidia_centos6_dt2 Docker container:

    https://github.com/jjhelmus/docker-images

* Start the docker container using:

    ```
    nvidia-docker run -v `pwd`:/io -it pkg_build_nvidia_centos6_dt2 /bin/bash
    ```

* Inside the container build the packages using:

    ```
    cd /io
    conda build -c jjh_cio_testing --perl 5.22 --python 2.7 --numpy 1.12 .
    conda build -c jjh_cio_testing --perl 5.22 --python 3.5 --numpy 1.12 .
    conda build -c jjh_cio_testing --perl 5.22 --python 3.6 --numpy 1.12 .
    ```
