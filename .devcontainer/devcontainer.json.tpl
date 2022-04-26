{
  "name": "devcontainer",
  "dockerFile": "../Dockerfile",
  "context": "..",
  "remoteUser": "default",
  // "workspaceFolder": "/tee-poc/mnist-cpp",
  // "workspaceMount": "source=/path/to/tee-poc,target=/tee-poc,type=bind,consistency=default",
  "extensions": [
    "ms-vscode.cpptools",
    "ms-vscode.cpptools-extension-pack",
    "ms-vscode.cpptools-themes",
    "exiasr.hadolint",
    "yzhang.markdown-all-in-one",
    "ms-python.python",
    "ms-toolsai.jupyter",
    "ms-azuretools.vscode-docker"
  ],
  "mounts": [
    "source=/var/run/docker.sock,target=/var/run/docker.sock,type=bind,consistency=default",
  ],
  "runArgs": [
    "--net=host",
    "--privileged"
  ],
  "forwardPorts": [
    8090,
    9000,
    9001,
    8081
  ],
  // "containerEnv": {
  //   "HOST_WRKSPC_DIR": "/path/to/tee-poc/mnist-cpp",
  //   "HOST_DATA_DIR": "/path/to/tee-poc/mnist-cpp/data",
  // }
}