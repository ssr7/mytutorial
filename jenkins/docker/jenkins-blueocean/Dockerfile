FROM jenkins/jenkins:latest
USER root
#RUN sed -i s/deb.debian.org/archive.debian.org/g /etc/apt/sources.list
#RUN sed -i 's|security.debian.org|archive.debian.org/|g' /etc/apt/sources.list
#RUN sed -i '/stretch-updates/d' /etc/apt/sources.list
RUN apt-get update 
#RUN apt -y  install tsocks
RUN apt-get install -y lsb-release apt-transport-https
RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
  https://download.docker.com/linux/debian/gpg
RUN echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
  https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -y docker-ce-cli
USER jenkins
