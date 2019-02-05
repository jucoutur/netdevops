FROM phusion/baseimage:0.10.1
MAINTAINER Julien Couturier <jucoutur@cisco.com>
# credits to Nicolas Delecroix <ndelecro@cisco.com> & Stef Benfredj <stefb12@gmail.com>

CMD ["/bin/bash"]

# Dependencies & tools
RUN apt-get -y update
RUN apt-get -y install \
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

RUN pip install --upgrade pip
RUN pip install scp \
	requests \
	lxml \
	xmljson \
	pyvmomi \
	avisdk

# Ansible install
RUN apt-add-repository -y ppa:ansible/ansible && apt-get update && apt-get install -y ansible

# Avi Networks // install required packages, roles, sdk
RUN ansible-galaxy install avinetworks.avisdk avinetworks.aviconfig avinetworks.avicontroller

# No caching from now on to always force latest files to be downloaded
ADD http://worldclockapi.com/api/json/utc/now /tmp/timestamp.json

# Ansible // create a base folder for playbooks
RUN mkdir /root/ansible

# ACI // get ACI-AVI Ansible playbooks
RUN mkdir /root/ansible/aci && \
	svn checkout "https://github.com/jucoutur/netdevops/trunk/Ansible/ACI" /root/ansible/aci

# NX-OS // get NX-OS Ansible playbooks for VXLAN-EVPN overlay provisioning
RUN mkdir /root/ansible/nxos && mkdir /root/ansible/nxos/vxlan-evpn-overlay && \
	svn checkout "https://github.com/jucoutur/netdevops/trunk/Ansible/NXOS" /root/ansible/nxos/vxlan-evpn-overlay

# Clean up APT when done
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
