# MNIST example - Pytorch C++
This is an example of the classic MNIST hand-written text recognition task using FEDn with the PyTorch C++ API.

## Table of Contents
- [MNIST example - Pytorch C++](#mnist-example---pytorch-c)
  - [Table of Contents](#table-of-contents)
  - [Prerequisites](#prerequisites)
  - [Running the example (pseudo-distributed)](#running-the-example-pseudo-distributed)
  - [Clean up](#clean-up)
  - [Running in Trusted Execution Environment (TEE)](#running-in-trusted-execution-environment-tee)
    - [Compute package in Intel SGX](#compute-package-in-intel-sgx)
    - [Reducer and combiner in Intel SGX](#reducer-and-combiner-in-intel-sgx)
    - [Running in AMD SEV](#running-in-amd-sev)

## Prerequisites
The working environment for this example makes use of [VSC remote containers](https://code.visualstudio.com/docs/remote/containers). The development container is defined by the following files:

1. `Dockerfile` defines the development container along with its dependencies.
2. `.devontainer/devcontainer.json.tpl` defines how VSC will access and create the developmet container. The teplate need to be copied to `.devontainer/devcontainer.json` and edited. Please refer to this document for more information: https://code.visualstudio.com/docs/remote/devcontainerjson-reference.
3. You may need to login into Scaleout's GitHub registry if the Dockerfile is based on `ghcr.io/scaleoutsystems/tee-gc/fedn:latest`.
 
## Running the example (pseudo-distributed)

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
> **Note** If you are running on a remote container, you need to setup the remote host data path: `echo "HOST_DATA_DIR=/path/to/tee-mnist/data"  > .env`.
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

### Compute package in Intel SGX
The compute package in this example supports running training and validation in [Intel SGX TEE](https://www.intel.com/content/www/us/en/developer/tools/software-guard-extensions/overview.html) via [Gramine](https://grapheneproject.io). The code was tested using [Azure Confidential Computing](https://azure.microsoft.com/en-us/solutions/confidential-compute). To enable this running mode, you can run: `echo "LOADER=gramine-sgx" >> .env` and repeat all of the seps.

### Reducer and combiner in Intel SGX
To run reducer and combiner in Intel SGX you can use `docker-compose-tee.yaml` to start FEDn, as it follows.

```
sudo docker-compose -f docker-compose-tee.yaml up -d
```

Next steps are the same as running without Intel SGX but it may take a bit longer for the clients to connect.

### Running in AMD SEV
This codebase has also been tested in [AMD SEV](https://developer.amd.com/sev) with [Azure Confidential VMs](https://docs.microsoft.com/en-us/azure/confidential-computing/virtual-machine-solutions-amd). The steps to follow don't change in this case as the whole VM memory is automatically encypted by the Azure service via AMD SEV.
