# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "awxkit",
# ]
# ///
import os
import json
from awxkit import config
from awxkit.api import ApiV2, job_templates
from awxkit.api.resources import resources

config.base_url = os.environ["TOWER_HOST"]
awx_token = os.environ["CONTROLLER_OAUTH_TOKEN"]

client = ApiV2()
client.connection.login(token=awx_token)
client.get(resources)

organization = client.organizations.get(name="Default").results[0]

inventory_name = "Pods Inventory"
inventory = next((inv for inv in client.inventory.get(organization=organization.id).results if inv.name == inventory_name), None)

if not inventory:
    inventory = client.inventory.post({
        "name": inventory_name,
        "organization": organization.id,
        "description": "Inventory for Kubernetes pod SSH access"
    })

hosts = [
    {
        "name": "container-a",
        "variables": {
            "ansible_host": f"service-a",
            "ansible_user": "user",
            "ansible_password": "user",
            "ansible_port": 22,
            "ansible_connection": "ssh"
        }
    },
    {
        "name": "container-b",
        "variables": {
            "ansible_host": f"service-b",
            "ansible_user": "user",
            "ansible_password": "user",
            "ansible_port": 22,
            "ansible_connection": "ssh"
        }
    }
]

for host in hosts:
    existing_host = next((h for h in client.hosts.get(inventory=inventory.id).results if h.name == host["name"]), None)
    if not existing_host:
        client.hosts.post({
            "name": host["name"],
            "inventory": inventory.id,
            "variables": json.dumps(host["variables"])
        })