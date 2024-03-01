# Java latest (default 23) OpenJDK with no root access 
* A Java 11 base Container with `no root access` (except using `sudo ...` and you can remove it using `sudo apt-get remove sudo` to protect your Container). 
```
If [ you are looking for such a common requirement as a base Container ]:
   Then [ this one may be for you ]
```

# Key Features
##### (**NEW**) `Auto detect & enable GPU/CUDA`
##### (**NEW**) `Auto Corporate Proxy/SSL Certificates setup`
##### (**NEW**) `Auto APP Container project creation`
##### (**Safety**) `Non-root access inside Container`
* For deployment, you can disable it for security with (`sudo apt-get remove -y sudo`)


# Components:
* OpenJDK Java 11 base image
* No root setup: using /home/developer 
  * It has sudo for dev phase usage. You can "sudo apt-get remove sudo" to finalize the product image.
  * Note, you should consult Docker security experts on how to secure your Container for your production use!)

# Change OpenJDK version

* To change to a different OpenJDK version, e.g., `openjdk:18`, just update the 1st like of the Dockerfile:
```
ARG BASE_IMAGE=${BASE_IMAGE:-openjdk:18}
```
# Build
* Due to Docker Hub not allowing free hosting services of pre-built images, you have to make a local build to use in your environment
    ```
    ./build.sh
    ```

# Build/Run Container Inside Corporate Proxy or Networks
`(New!)` With this automation for setup proxy and corporate certificate for allowing the 'build and run' the Container behind your corporate networks!
* Step-1-A: Setup Corporate Proxy environment variables:
    If your corporate use a proxy to access the internet, then you can set up your proxy (in your Host's User environment variable ), e.g.,
    ```
    (in your $HOME/.bashrc profile)
    export http_proxy=proxy.openkbs.org:8080
    export https_proxy=proxy.openkbs.org:8443
    ```
    
* Step-1-B: If your corporate use zero-trust VPN, e.g., ZScaler, then just find and download your ZScaler and/or additional Corporate SSL/HTTPS certificates, e.g., my-corporate.crt, and then save it in the folder './certificates/', e.g.,
    ```
    (in folder ./certificates)
    ├── certificates
    │   └── my-corporate.crt
    ```
* Step-2: That's it! (Done!) Let the automation scripts be chained by Dockerfile for building and running your local version of the Container instance behind your Corporate Networks.

# Run (recommended for easy-start)
* Simply,
    ```
    ./run.sh
    ```

# Stop Running
* Just `CTRL+C` (if you use ./run.sh), or,
    ```
    ./stop.sh
    or
    make down
    ```
# `Generate an APP Container project from this Base Container`
You can use one command, `bin/generate-new-project.sh`, to automatically create a fully build/run-able/test APP-container in seconds:
```
bin/generate-new-project.sh <folder_for_your_APP>
e.g.
bin/generate-new-project.sh ../my-app-docker
```
That's it! It will automatically create a fully (literally!) complete APP-Container project folder with everything from the build, run, and Makefile (for make build, make up, or make down, etc.)

# Create your own image from this
```
FROM openkbs/python-nonroot-docker
```

# Quick commands
* Makefile - makefile for build, run, down, etc.
* build.sh - build local image
* logs.sh - see logs of container
* run.sh - run the container
* shell.sh - shell into the container
* stop.sh - stop the container


# Create your own image from this

```
FROM openkbs/java11-non-root
```


