# MNIST example - Pytorch C++
This is an example of the classic MNIST hand-written text recognition task using FEDn with the PyTorch C++ API.

## Table of Contents
- [MNIST example - Pytorch C++](#mnist-example---pytorch-c)
  - [Table of Contents](#table-of-contents)
  - [Prerequisites](#prerequisites)
  - [Running the example](#running-the-example)
  - [Clean up](#clean-up)
  - [Running in Trusted Execution Environment (TEE)](#running-in-trusted-execution-environment-tee)

## Prerequisites
The only prerequisite to run this example is [Docker](https://www.docker.com).

## Running the example

Start the Docker environment:
```
bin/launch.sh
```
> This may take a few minutes.

Download the data:
```
bin/download_data.sh
```

Build the compute package and train the seed model:
```
bin/build.sh
```
> This may take a few minutes. After completion `package.tgz` and `seed.npz` should be built in your current working directory.

Start FEDn:
```
sudo docker-compose up -d
```
> This may take a few minutes. After this is done you should be able to access the reducer interface at https://localhost:8090.

Now navigate to https://localhost:8090 and upload `package.tgz` and `seed.npz`. Alternatively, you can upload seed and package using the REST API as it follows.
```
# Upload package
curl -k -X POST \
    -F file=@package.tar.gz \
    -F helper="pytorch" \
    https://localhost:8090/context

# Upload seed
curl -k -X POST \
    -F seed=@seed.npz \
    https://localhost:8090/models
```

Finally, you can navigate again to https://localhost:8090 and start the experiment from the "control" tab. Alternatively, you can start the experiment using the REST API as it follows.
```
# Start experiment
curl -k -X POST \
    -F rounds=3 \
    -F validate=True \
    https://localhost:8090/control
```

## Clean up
To clean up you can run: `sudo docker-compose down`. To exit the Docker environment simply run `exit`.

## Running in Trusted Execution Environment (TEE)
The compute package in this example supports running training and validation in [Intel SGX TEE](https://www.intel.com/content/www/us/en/developer/tools/software-guard-extensions/overview.html) via [Gramine](https://grapheneproject.io). The code was tested using [Azure Confidential Computing](https://azure.microsoft.com/en-us/solutions/confidential-compute). To enable this running mode, after starting the development container with `bin/launch.sh` you can run: `echo "LOADER=gramine-sgx" >> .env` and repeat all of the subsequent seps.