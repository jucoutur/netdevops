FROM phusion/baseimage:0.10.1
LABEL maintainer="jucoutur@cisco.com"

CMD ["/bin/bash"]

# Dependencies & tools
RUN apt-get -y update && apt-get -y install \
	apt-utils \
	dialog \
	software-properties-common \
	python-pip \
	python-dnspython \
	python-netaddr \
	vim \
	net-tools \
	inetutils-ping \
	git \
	ssh-client \
	python-pip \
	gdebi-core \
	python3-dev \
	python-dev \
	libtool-bin \
	wget \
	subversion
RUN echo 'upgrade pip to latest' 
RUN pip install --upgrade pip
RUN pip install scp requests

# Ansible install
RUN apt-add-repository -y ppa:ansible/ansible && apt-get update && apt-get install -y ansible

# Avi Networks // install required packages, roles, sdk
RUN pip install avisdk
RUN git clone https://github.com/avinetworks/devops.git
RUN ansible-galaxy install avinetworks.avisdk
RUN ansible-galaxy install avinetworks.aviconfig
RUN ansible-galaxy install avinetworks.avicontroller

## ACI // install dependencies required when using aci_rest ansible module with XML payload
RUN pip install lxml && pip install xmljson

## VMware // install pyvmomi for vSphere automation
RUN pip install pyvmomi

# No caching from now on to always force latest files to be downloaded
ADD http://worldclockapi.com/api/json/utc/now /tmp/timestamp.json

# NX-OS // get NX-API CLI scripts
RUN mkdir /root/NX-API_CLI && \
	svn checkout "https://github.com/jucoutur/netdevops/trunk/NX-API_CLI" /root/NX-API_CLI

# Ansible // create a base folder for playbooks
RUN mkdir /root/playbooks

# NX-OS // get Ansible playbooks & Ansible config files
RUN mkdir /root/playbooks/nxos && \
	svn checkout "https://github.com/jucoutur/netdevops/trunk/Ansible/2.5" /root/playbooks/nxos && \
	svn checkout "https://github.com/jucoutur/netdevops/trunk/Ansible/Config" /etc/ansible/

# NX-OS // overwrite existing Ansible config files
RUN	curl 'https://raw.githubusercontent.com/jucoutur/netdevops/master/Ansible/Config/hosts' > /etc/ansible/hosts  && \
	curl 'https://raw.githubusercontent.com/jucoutur/netdevops/master/Ansible/Config/ansible.cfg' > /etc/ansible/ansible.cfg

# ACI // get ACI-AVI Ansible playbooks
RUN mkdir /root/playbooks/aci && \
	svn checkout "https://github.com/jucoutur/netdevops/trunk/Ansible/ACI" /root/playbooks/aci

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
