ARG BASE_IMAGE=${BASE_IMAGE:-openjdk:11}
FROM ${BASE_IMAGE}

MAINTAINER DrSnowbird "DrSnowbird@openkbs.org"

##################################
#### ---- Tools: setup   ---- ####
##################################
ENV LANG C.UTF-8
ARG LIB_DEV_LIST="apt-utils"
ARG LIB_BASIC_LIST="curl wget unzip ca-certificates"
ARG LIB_COMMON_LIST="sudo bzip2 git xz-utils unzip vim net-tools" # coreutils gettext pwgen tini;
ARG LIB_TOOL_LIST="graphviz"

RUN set -eux; \
    apt-get update -y && \
    apt-get install -y --no-install-recommends ${LIB_DEV_LIST}  ${LIB_BASIC_LIST}  ${LIB_COMMON_LIST} ${LIB_TOOL_LIST} && \
    apt-get clean -y && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* && \
    echo "vm.max_map_count=262144" | tee -a /etc/sysctl.conf
    
##############################################
#### ---- Installation Directories   ---- ####
##############################################
ENV INSTALL_DIR=${INSTALL_DIR:-/usr}
ENV SCRIPT_DIR=${SCRIPT_DIR:-$INSTALL_DIR/scripts}

############################################
##### ---- System: certificates : ---- #####
##### ---- Corporate Proxy      : ---- #####
############################################
COPY ./scripts ${SCRIPT_DIR}
COPY certificates /certificates
RUN ${SCRIPT_DIR}/setup_system_certificates.sh
RUN ${SCRIPT_DIR}/setup_system_proxy.sh

###################################
#### ---- Install Maven 3 ---- ####
###################################
ENV MAVEN_VERSION=${MAVEN_VERSION:-3.8.5}
ENV MAVEN_HOME=/usr/apache-maven-${MAVEN_VERSION}
ENV PATH=${PATH}:${MAVEN_HOME}/bin

RUN export MAVEN_PACKAGE_URL=$(curl -s https://maven.apache.org/download.cgi | grep -e "apache-maven.*bin.tar.gz" | head -1|cut -d'"' -f2) && \
    export MAVEN_VERSION=$(echo ${MAVEN_PACKAGE_URL}| cut -d'/' -f6) && \
    export MAVEN_HOME=/usr/apache-maven-${MAVEN_VERSION} && \
    export PATH=${PATH}:${MAVEN_HOME}/bin && \
    curl -k -sL ${MAVEN_PACKAGE_URL} | gunzip | tar x -C /usr/ && \
    ln -s ${MAVEN_HOME} /usr/maven

###################################
#### ---- Install Gradle ---- #####
###################################
# Ref: https://gradle.org/releases/

ENV GRADLE_INSTALL_BASE=${GRADLE_INSTALL_BASE:-/opt/gradle}
ENV GRADLE_VERSION=${GRADLE_VERSION:-7.4.1}
ENV GRADLE_HOME=${GRADLE_INSTALL_BASE}/gradle-${GRADLE_VERSION}
ENV GRADLE_PACKAGE=gradle-${GRADLE_VERSION}-bin.zip
ENV GRADLE_PACKAGE_URL=https://services.gradle.org/distributions/${GRADLE_PACKAGE}

RUN mkdir -p ${GRADLE_INSTALL_BASE} && \
    cd ${GRADLE_INSTALL_BASE} && \
    export GRADLE_VERSION=$(curl -k -s https://gradle.org/releases/ | grep "Download: " | head -1 | cut -d'-' -f2) && \
    export GRADLE_HOME=${GRADLE_INSTALL_BASE}/gradle-${GRADLE_VERSION} && \
    export GRADLE_PACKAGE_URL=$(curl -k -s https://gradle.org/releases/ | grep "Download: " | head -1 | cut -d'"' -f4) && \
    export GRADLE_PACKAGE=gradle-${GRADLE_VERSION}-bin.zip && \
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

############################################
##### ---- System: certificates : ---- #####
############################################
COPY --chown=${USER}:${USER} scripts /scripts
COPY --chown=${USER}:${USER} certificates /certificates
RUN /scripts/setup_system_certificates.sh

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

