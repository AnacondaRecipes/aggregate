To build a conda tensorflow package

* Build the pkg_build_centos6_dt2 Docker container:

    https://github.com/jjhelmus/docker-images

* Start the docker container using:

    ```
    docker run -v `pwd`:/io -v -it pkg_build_centos6_dt2 /bin/bash
    ```

* Inside the container build the packages using:

    ```
    cd /io/tensorflow-base/recipe
    conda build -c jjh_cio_testing --python 2.7 .
    conda build -c jjh_cio_testing --python 3.5 .
    conda build -c jjh_cio_testing --python 3.6 .
    ```
