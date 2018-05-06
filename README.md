# UnstoppableForce
Collection of Packer/Ansible/Terraform scripts to automate deployment to DigitalOcean Droplets

When an immutable object meets an unstoppable force, only good things can result

# Steps

1. Edit scripts/Packing/copy_into.yaml `src: /path/to/website/folder` with the path of your development environment on disk
2. Edit scripts/Kubernetes/main.tf --> `"kubectl run dep1 --image=a:a --port 5000 --command -- python3 /path/to/website.py --image-pull-policy=Never"` with the path to the startup file
3. packer build template.json
4. terraform apply 
