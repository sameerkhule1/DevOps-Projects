# run ansible playbook
ansible-playbook -i inventory ansible-nginx.yml

# ping all vm
ansible all -i inventory -m ping
