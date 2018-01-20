Instruction for building caffe-gpu conda packages

Build the pkg_build_cuda80_centos6_notoolset Docker image from:
    https://github.com/jjhelmus/docker-images

Start the docker container:
    nvidia-docker run --net=host -v `pwd`:/io -it pkg_build_cuda80_centos6_notoolset /bin/bash

Navigate the to recipe, adjust conda_build_config.yaml and start the build:
    conda build caffe-gpu -c default -c rdonnelly
