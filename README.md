# Java latest (default 23) OpenJDK with no root access 
* A latest OpenJDK Java base Container with `no root access` (except using `sudo ...` and you can remove it using `sudo apt-get remove sudo` to protect your Container). 
```
If [ you are looking for such a common requirement as a base Container ]:
   Then [ this one may be for you ]
```

# Key Features:
##### (**NEW**) `Auto detect & enable GPU/CUDA`
##### (**NEW**) `Auto Corporate Proxy/SSL Certificates setup`
##### (**NEW**) `Auto APP Container project creation`
##### (**Safety**) `Non-root access inside Container`
* For deployment, you can disable it for security with (`sudo apt-get remove -y sudo`)

# Components:
* OpenJDK Java latest (v23 as default).
* No root setup: using /home/developer:
  * It has sudo for dev phase usage. You can "sudo apt-get remove sudo" to finalize the product image.
  * Note, you should consult Docker security experts on how to secure your Container for your production use!)

# Change OpenJDK version:
* To change to a different OpenJDK version, e.g., `openjdk:18`, just modify the the Makefile as:
    ```
    # (Makefile) - Recommended!
    # -- Java base image versions to build: --
    # -- Only the last value will be designated as the ":latest" tag!
    JAVA_VERSION_LIST=23-slim-bullseye 23-jdk-slim-bullseye
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
FROM openkbs/java-nonroot-docker
```

# Versions of Components
```
~/app$ /usr/scripts/printVersions.sh 

JAVA_HOME=/usr/local/openjdk-23
java: /usr/local/openjdk-23/bin/java

/usr/local/openjdk-23/bin/java
openjdk version "23-ea" 2024-09-17
OpenJDK Runtime Environment (build 23-ea+12-893)
OpenJDK 64-Bit Server VM (build 23-ea+12-893, mixed mode, sharing)
/usr/bin/mvn
Apache Maven 3.9.6 (bc0240f3c744dd6b6ec2920b3cd08dcc295161ae)
Maven home: /usr/apache-maven-3.9.6
Java version: 23-ea, vendor: Oracle Corporation, runtime: /usr/local/openjdk-23
Default locale: en, platform encoding: UTF-8
OS name: "linux", version: "6.5.0-21-generic", arch: "amd64", family: "unix"
/usr/bin/gradle

Welcome to Gradle 7.6.4!

Here are the highlights of this release:
 - Added support for Java 19.
 - Introduced `--rerun` flag for individual task rerun.
 - Improved dependency block for test suites to be strongly typed.
 - Added a pluggable system for Java toolchains provisioning.

For more details see https://docs.gradle.org/7.6.4/release-notes.html


------------------------------------------------------------
Gradle 7.6.4
------------------------------------------------------------

Build time:   2024-02-05 14:29:18 UTC
Revision:     e0bb3fc8cefad8432c9033cdfb12dc14facc9dd9

Kotlin:       1.7.10
Groovy:       3.0.13
Ant:          Apache Ant(TM) version 1.10.13 compiled on January 4 2023
JVM:          23-ea (Oracle Corporation 23-ea+12-893)
OS:           Linux 6.5.0-21-generic amd64

PRETTY_NAME="Debian GNU/Linux 11 (bullseye)"
NAME="Debian GNU/Linux"
VERSION_ID="11"
VERSION="11 (bullseye)"
VERSION_CODENAME=bullseye
ID=debian
HOME_URL="https://www.debian.org/"
SUPPORT_URL="https://www.debian.org/support"
BUG_REPORT_URL="https://bugs.debian.org/"
```
