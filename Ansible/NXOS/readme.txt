### Make sure you have the following files/content before running the playbooks :

more /etc/ansible/hosts'
[nxos_vteps_cli]
<switch_IP>
<switch_IP>
...

more /etc/ansible/group_vars/nxos_vteps_cli'
ansible_network_os: nxos
ansible_connection: network_cli
ansible_ssh_user: <your_login>
ansible_ssh_pass: <your_password>