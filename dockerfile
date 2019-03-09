#Ubuntu + Java + Maven + Git

# Ubuntu 16.04
# Oracle Java 1.8.0_201 64 bit
# Maven 3.3.9

FROM ubuntu:16.04

MAINTAINER  Vivek

# this is a non-interactive automated build - avoid some warning messages
ENV DEBIAN_FRONTEND noninteractive

# update dpkg repositories
RUN apt-get update 

# install wget
RUN apt-get install -y wget

# get maven 3.3.9
RUN wget --no-verbose -O /tmp/apache-maven-3.3.9.tar.gz http://archive.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz

# verify checksum
RUN echo "516923b3955b6035ba6b0a5b031fbd8b /tmp/apache-maven-3.3.9.tar.gz" | md5sum -c

# install maven
RUN tar xzf /tmp/apache-maven-3.3.9.tar.gz -C /opt/
RUN ln -s /opt/apache-maven-3.3.9 /opt/maven
RUN ln -s /opt/maven/bin/mvn /usr/local/bin
RUN rm -f /tmp/apache-maven-3.3.9.tar.gz
ENV MAVEN_HOME /opt/maven

# remove download archive files
RUN apt-get clean

RUN apt-get install git -y

# set shell variables for java installation
ENV java_version 1.8.0_201
ENV filename jdk-8u201-linux-x64.tar.gz
#ENV downloadlink http://download.oracle.com/otn-pub/java/jdk/8u101-b13/$filename
ENV downloadlink https://download.oracle.com/otn-pub/java/jdk/8u201-b09/42970487e3af4f5aa5bca3f542482c60/jdk-8u201-linux-x64.tar.gz

# download java, accepting the license agreement
RUN wget --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" -O /tmp/$filename $downloadlink 

# unpack java
RUN mkdir /opt/java-oracle && tar -zxf /tmp/$filename -C /opt/java-oracle/
ENV JAVA_HOME /opt/java-oracle/jdk$java_version
ENV PATH $JAVA_HOME/bin:$PATH

# configure symbolic links for the java and javac executables
RUN update-alternatives --install /usr/bin/java java $JAVA_HOME/bin/java 20000 && update-alternatives --install /usr/bin/javac javac $JAVA_HOME/bin/javac 20000


# Make ssh dir
RUN mkdir /root/.ssh/

RUN  echo "    IdentityFile ~/.ssh/id_rsa" >> /etc/ssh/ssh_config

RUN  echo "    IdentityFile ~/.ssh/id_rsa" >> id_rsa

# Copy over private key, and set permissions
# Warning! Anyone who gets their hands on this image will be able
# to retrieve this private key file from the corresponding image layer
ADD id_rsa /root/.ssh/id_rsa

# Create known_hosts
RUN touch /root/.ssh/known_hosts
# Add bitbuckets key
RUN ssh-keyscan github.build.ge.com >> /root/.ssh/known_hosts

RUN git clone git@github.build.ge.com:CAF-Analytics/legit-caf-svc.git

RUN cd legit-caf-svc

RUN mvn clean install -s menlo_settings.xml




#CMD ["/bin/sh", ""]
