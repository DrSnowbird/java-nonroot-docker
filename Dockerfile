ARG BASE=${BASE:-openjdk:11}
FROM ${BASE}

MAINTAINER DrSnowbird "DrSnowbird@openkbs.org"

##################################
#### ---- Tools: setup   ---- ####
##################################
ENV LANG C.UTF-8
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
       sudo bash curl wget unzip ca-certificates findutils coreutils gettext pwgen tini; \
    apt-get autoremove; \
    rm -rf /var/lib/apt/lists/* && \
    echo "vm.max_map_count=262144" | tee -a /etc/sysctl.conf

###################################
#### ---- Install Maven 3 ---- ####
###################################
ENV MAVEN_VERSION=${MAVEN_VERSION:-3.8.4}
ENV MAVEN_HOME=/usr/apache-maven-${MAVEN_VERSION}
ENV PATH=${PATH}:${MAVEN_HOME}/bin
RUN curl -sL http://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  | gunzip \
  | tar x -C /usr/ \
  && ln -s ${MAVEN_HOME} /usr/maven

###################################
#### ---- Install Gradle ---- #####
###################################
# Ref: https://gradle.org/releases/

ARG GRADLE_INSTALL_BASE=${GRADLE_INSTALL_BASE:-/opt/gradle}
ARG GRADLE_VERSION=${GRADLE_VERSION:-7.3}
ARG GRADLE_HOME=${GRADLE_INSTALL_BASE}/gradle-${GRADLE_VERSION}
ENV GRADLE_HOME=${GRADLE_HOME}
ARG GRADLE_PACKAGE=gradle-${GRADLE_VERSION}-bin.zip
ARG GRADLE_PACKAGE_URL=https://services.gradle.org/distributions/${GRADLE_PACKAGE}

RUN mkdir -p ${GRADLE_INSTALL_BASE} && \
    cd ${GRADLE_INSTALL_BASE} && \
    wget -q --no-check-certificate -c ${GRADLE_PACKAGE_URL} && \
    unzip -d ${GRADLE_INSTALL_BASE} ${GRADLE_PACKAGE} && \
    ls -al ${GRADLE_HOME} && \
    ln -s ${GRADLE_HOME}/bin/gradle /usr/bin/gradle && \
    ${GRADLE_HOME}/bin/gradle -v && \
    rm -f ${GRADLE_PACKAGE}

###################################
#### ---- user: developer ---- ####
###################################
ENV USER_ID=${USER_ID:-1000}
ENV GROUP_ID=${GROUP_ID:-1000}
ENV USER=${USER:-developer}
ENV HOME=/home/${USER}

RUN apt-get update && apt-get install -y sudo && \
    useradd -ms /bin/bash ${USER} && \
    export uid=${USER_ID} gid=${GROUP_ID} && \
    mkdir -p /home/${USER} && \
    mkdir -p /home/${USER}/workspace && \
    mkdir -p /etc/sudoers.d && \
    echo "${USER}:x:${USER_ID}:${GROUP_ID}:${USER},,,:/home/${USER}:/bin/bash" >> /etc/passwd && \
    echo "${USER}:x:${USER_ID}:" >> /etc/group && \
    echo "${USER} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USER} && \
    chmod 0440 /etc/sudoers.d/${USER} && \
    chown ${USER}:${USER} -R /home/${USER}

#########################################
##### ---- Docker Entrypoint : ---- #####
#########################################
COPY --chown=${USER}:${USER} docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

#####################################
##### ---- user: developer ---- #####
#####################################
WORKDIR ${HOME}
USER ${USER}

######################
#### (Test only) #####
######################
#CMD ["/bin/bash"]
CMD ["java",  "-version"]
