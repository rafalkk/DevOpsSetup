import subprocess
import os
import json

# Define the Ansible inventory file (relative to the Ansible folder)
INVENTORY_FILE = "inventory/inventory.ini"

# Get the current working directory
MAIN_DIR = os.getcwd()
INVENTORY_FOLDER = MAIN_DIR + "/ansible/inventory"

# Check if the inventory folder exists, and create it if not
if not os.path.exists(INVENTORY_FOLDER):
    os.makedirs(INVENTORY_FOLDER)

# Change the working directory to the Terraform folder
os.chdir(MAIN_DIR + "/terraform")

# Run Terraform to get the instance IPs as JSON
command = subprocess.run(['terraform', 'output', '-json', 'instances_public_ips'], capture_output=True, text=True)
terraform_output = command.stdout

# Load JSON to array of IPs
instance_ips = json.loads(terraform_output)

# Change the working directory back to Ansible folder
os.chdir(MAIN_DIR + "/ansible")

# Create the Ansible inventory file in the Ansible inventory folder
with open(INVENTORY_FILE, "w") as inventory:
    inventory.write("[OCI]\n")

    for ip in instance_ips:
        inventory.write(f"{ip}\n")

print(f"Ansible inventory file '{INVENTORY_FILE}' created successfully.")
