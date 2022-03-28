ARG BASE_IMAGE=${BASE_IMAGE:-openjdk:11}
FROM ${BASE_IMAGE}

MAINTAINER DrSnowbird "DrSnowbird@openkbs.org"

##############################################
#### ---- Installation Directories   ---- ####
##############################################
ENV INSTALL_DIR=${INSTALL_DIR:-/usr}
ENV SCRIPT_DIR=${SCRIPT_DIR:-$INSTALL_DIR/scripts}

############################################
##### ---- System: certificates : ---- #####
##### ---- Corporate Proxy      : ---- #####
############################################
ENV LANG C.UTF-8
ARG LIB_BASIC_LIST="curl wget unzip ca-certificates"
RUN set -eux; \
    apt-get update -y && \
    apt-get install -y ${LIB_BASIC_LIST} 
    
COPY ./scripts ${SCRIPT_DIR}
COPY certificates /certificates
RUN ${SCRIPT_DIR}/setup_system_certificates.sh
RUN ${SCRIPT_DIR}/setup_system_proxy.sh

##################################
#### ---- Tools: setup   ---- ####
##################################
ARG LIB_DEV_LIST="apt-utils"
ARG LIB_COMMON_LIST="sudo bzip2 git xz-utils unzip vim net-tools"
ARG LIB_TOOL_LIST="graphviz"

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends ${LIB_DEV_LIST} ${LIB_COMMON_LIST} ${LIB_TOOL_LIST} && \
    apt-get clean -y && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* && \
    echo "vm.max_map_count=262144" | tee -a /etc/sysctl.conf

###################################
#### ---- Install Maven 3 ---- ####
###################################
ENV MAVEN_VERSION=${MAVEN_VERSION:-3.8.5}
ENV MAVEN_HOME=/usr/apache-maven-${MAVEN_VERSION}
ENV MAVEN_PACKAGE=apache-maven-${MAVEN_VERSION}-bin.tar.gz
ENV PATH=${PATH}:${MAVEN_HOME}/bin
## -- Auto tracking (by parsing product release page) the latest release -- ##
# https://dlcdn.apache.org/maven/maven-3/3.8.5/binaries/apache-maven-3.8.5-bin.tar.gz
RUN export MAVEN_PACKAGE_URL=$(curl -s https://maven.apache.org/download.cgi | grep -e "apache-maven.*bin.tar.gz" | head -1|cut -d'"' -f2) && \
    export MAVEN_PACKAGE=$(basename $MAVEN_PACKAGE_URL) && \
    export MAVEN_VERSION=$(echo ${MAVEN_PACKAGE}|cut -d'-' -f3) && \
    export MAVEN_HOME=/usr/apache-maven-${MAVEN_VERSION} && \
    export PATH=${PATH}:${MAVEN_HOME}/bin && \
    curl -k -sL ${MAVEN_PACKAGE_URL} | gunzip | tar x -C /usr/ && \
    ln -s ${MAVEN_HOME}/bin/mvn /usr/bin/mvn && \
    ${MAVEN_HOME}/bin/mvn -v && \
    rm -f ${MAVEN_PACKAGE}

###################################
#### ---- Install Gradle ---- #####
###################################
# Ref: https://gradle.org/releases/

ENV GRADLE_INSTALL_BASE=${GRADLE_INSTALL_BASE:-/opt/gradle}
ENV GRADLE_VERSION=${GRADLE_VERSION:-7.4.1}
ENV GRADLE_HOME=${GRADLE_INSTALL_BASE}/gradle-${GRADLE_VERSION}
ENV GRADLE_PACKAGE=gradle-${GRADLE_VERSION}-bin.zip
ENV GRADLE_PACKAGE_URL=https://services.gradle.org/distributions/${GRADLE_PACKAGE}
ENV PATH=${PATH}:${GRADLE_HOME}/bin
## -- Auto tracking (by parsing product release page) the latest release -- ##
RUN mkdir -p ${GRADLE_INSTALL_BASE} && \
    cd ${GRADLE_INSTALL_BASE} && \
    export GRADLE_PACKAGE_URL=$(curl -k -s https://gradle.org/releases/ | grep "Download: " | head -1 | cut -d'"' -f4) && \
    export GRADLE_VERSION=$(curl -k -s https://gradle.org/releases/ | grep "Download: " | head -1 | cut -d'-' -f2) && \
    export GRADLE_HOME=${GRADLE_INSTALL_BASE}/gradle-${GRADLE_VERSION} && \
    export GRADLE_PACKAGE=gradle-${GRADLE_VERSION}-bin.zip && \
    export PATH=${PATH}:${GRADLE_HOME}/bin && \
    wget -q --no-check-certificate -c ${GRADLE_PACKAGE_URL} && \
    unzip -d ${GRADLE_INSTALL_BASE} ${GRADLE_PACKAGE} && \
    find ${GRADLE_INSTALL_BASE} && \
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

ENV APP_HOME=${APP_HOME:-$HOME/app}
ENV APP_MAIN=${APP_MAIN:-setup.sh}

#########################
#### ---- App:  ---- ####
#########################
COPY --chown=$USER:$USER ./app $HOME/app

#########################################
##### ---- Setup: Entry Files  ---- #####
#########################################
COPY --chown=${USER}:${USER} docker-entrypoint.sh /
COPY --chown=${USER}:${USER} ${APP_MAIN} ${APP_HOME}/setup.sh
RUN sudo chmod +x /docker-entrypoint.sh ${APP_HOME}/setup.sh 

#########################################
##### ---- Docker Entrypoint : ---- #####
#########################################
ENTRYPOINT ["/docker-entrypoint.sh"]

#####################################
##### ---- user: developer ---- #####
#####################################
WORKDIR ${APP_HOME}
USER ${USER}

######################
#### (Test only) #####
######################
#CMD ["/bin/bash"]
######################
#### (RUN setup) #####
######################
CMD ["setup.sh"]

