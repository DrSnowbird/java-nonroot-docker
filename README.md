# Java 11 OpenJDK with no root access 
* A Java 11 base Container with `no root access` (except using `sudo ...` and you can remove it using `sudo apt-get remove sudo` to protect your Container). 
```
If [ you are looking for such a common requirement as a base Container ]:
   Then [ this one may be for you ]
```

# Components:
* OpenJDK Java 11 base image
* No root setup: using /home/developer 
  * It has sudo for dev phase usage. You can "sudo apt-get remove sudo" to finalize the product image.
  * Note, you should consult Docker security experts in how to secure your Container for your production use!)

# Build (do this first!)
```
./build.sh
```

# Run (recommended for easy-start)
```
./run.sh
```


# Pull image from Docker Repository

```
docker pull openkbs/java11-non-root
```

# Create your own image from this

```
FROM openkbs/java11-non-root
```

# Quick commands
* build.sh - build local image
* logs.sh - see logs of container
* run.sh - run the container
* shell.sh - shell into the container
* stop.sh - stop the container
