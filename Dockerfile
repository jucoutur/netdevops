FROM phusion/baseimage:0.10.1
LABEL maintainer="julien.coutur@gmail.com"

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
RUN pip install scp

# Ansible install
RUN apt-add-repository -y ppa:ansible/ansible && apt-get update && apt-get install -y ansible

# Avi Networks // install required packages, roles, sdk
RUN pip install avisdk
RUN git clone https://github.com/avinetworks/devops.git
RUN ansible-galaxy install avinetworks.avisdk
RUN ansible-galaxy install avinetworks.aviconfig
RUN ansible-galaxy install avinetworks.avicontroller

## ACI // install dependencies required when using aci_rest ansible module with XML payload
RUN echo 'install lxml and xmljson package' 
RUN pip install lxml && pip install xmljson

## VMwware // install pyvmomi for vSphere automation
RUN echo 'install pyvmomi' 
RUN pip install pyvmomi

# No caching from now on to always force latest files to be downloaded
ADD http://worldclockapi.com/api/json/utc/now timestamp.json

# NX-OS // copy NX-API CLI scripts from Github repo
RUN pip install requests && \
	mkdir /root/NX-API_CLI && \
	svn checkout "https://github.com/jucoutur/nx-os-programmability/trunk/NX-API_CLI" /root/NX-API_CLI

# NX-OS // copy Ansible playbooks & Ansible config files from Github repo
RUN echo 'adding Open NX-OS config files & playbooks' 
RUN mkdir /root/playbooks && mkdir /root/playbooks/nxos && \
	svn checkout "https://github.com/jucoutur/nx-os-programmability/trunk/Ansible/2.5" /root/playbooks/nxos && \
	svn checkout "https://github.com/jucoutur/nx-os-programmability/trunk/Ansible/Config" /etc/ansible/

# NX-OS // overwrite Ansible config files from Github repo
RUN	curl 'https://raw.githubusercontent.com/jucoutur/nx-os-programmability/master/Ansible/Config/hosts' > /etc/ansible/hosts  && \
	curl 'https://raw.githubusercontent.com/jucoutur/nx-os-programmability/master/Ansible/Config/ansible.cfg' > /etc/ansible/ansible.cfg

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
