############################################################
# Dockerfile to run Atlassian Bamboo
# Based on phusion/baseimage image
############################################################

FROM phusion/baseimage:latest

MAINTAINER Jan Kubat "jan.kubat@release.cz"

# Set environment 
ENV BAMBOO_VERSION 5.7.2
ENV BAMBOO_INSTALL /opt/atlassian/bamboo
ENV BAMBOO_HOME    /home/bamboo

# Expose ports
EXPOSE 8085

# Update system
RUN apt-get update && apt-get upgrade --yes

# install wget for late use
RUN apt-get install --yes wget

# Install JDK 7 and VCS tools //thanks to hwuethrich/bamboo-server
RUN apt-get install -yq python-software-properties && add-apt-repository ppa:webupd8team/java -y && apt-get update
RUN echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN apt-get install -yq oracle-java7-installer git subversion

# download and extract bamboo
RUN useradd --create-home -c "Bamboo role account" -s /bin/bash bamboo \
    && mkdir -p "${BAMBOO_INSTALL}" \
    && wget -qO- "https://www.atlassian.com/software/bamboo/downloads/binary/atlassian-bamboo-${BAMBOO_VERSION}.tar.gz" | tar -xz --directory="${BAMBOO_INSTALL}" \
    && echo "set bamboo.home = ${BAMBOO_HOME}" > "${BAMBOO_INSTALL}/atlassian-bamboo-${BAMBOO_VERSION}/atlassian-bamboo/WEB-INF/classes/bamboo-init.properties"

# Download and install mysql jdbc driver
RUN wget -qO- http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.34.tar.gz | tar -xz --directory="${BAMBOO_INSTALL}/atlassian-bamboo-${BAMBOO_VERSION}/atlassian-bamboo/WEB-INF/lib/" "mysql-connector-java-5.1.34/mysql-connector-java-5.1.34-bin.jar"

# Fix permissions
RUN chown -R bamboo:bamboo "${BAMBOO_INSTALL}"

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set bamboo user
USER bamboo:bamboo

ENTRYPOINT ${BAMBOO_INSTALL}/atlassian-bamboo-${BAMBOO_VERSION}/bin/start-bamboo.sh -fg
