# Provisioning of Project Infrastructure using Terraform

This guide shows how to provision the required infrastructure for javawebapp project using Terraform.
This will provision kube-adm cluster with a Master Node & 2 worker nodes.

steps include,
  * Install Terraform
  * Configure AWS Credentials
  * Clone this repo
  * Provision the infrastructure
  * Joining the Worker Nodes

## Get Started

  Let's go ahead and get the infrastructure built!

## Install Terraform

Install Terraform on any OS of your choice using the following link:
[Click here](https://developer.hashicorp.com/terraform/install)

## Configure AWS Credentials

To configure your aws creds you will need `aws-cli` installed on your system.
You can Install or update to the latest version of the AWS CLI using the following link:
[Click here](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

```bash
aws configure
```
Terraform files in this repo are written to work with `us-east-1`, so while configuring your aws credentials set, 
`Default region name [None]: us-east-1`
```
AWS Access Key ID [None]:
AWS Secret Access Key [None]:
Default region name [None]: us-east-1
Default output format [None]:
```

## Clone this repo

```bash
git clone https://github.com/devopsProjects24/microservice_deploy.git
```

Now change into the `microservice_deploy/terraform` directory

```bash
cd microservice_deploy/terraform
```
## Update The key_pair Name
* Choose one of your key pairs. See [EC2 console](https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#KeyPairs:).
* Update the below command with your own key pair name,
  Replace "your_key" with your own key pair name from AWS console.
  
```bash
sed -i 's/project_key/your_key/g' k8s_master.tf
```

## Provision the infrastructure

* Run the terraform

    ```bash
    terraform init
    terraform plan
    terraform apply
    ```

    This should take about half a minute. If this all runs correctly, you will see something like the following at the end of all the output.

    ```
    Apply complete! Resources: 22 added, 0 changed, 0 destroyed.
* Wait for all instances to be ready (Instance state - `running`, Status check - `2/2 checks passed`). This will take 1-2 minutes. See [EC2 console](https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#Instances:instanceState=running).

## Joining the Worker Nodes

* Login to Master and all the Worker Nodes.

* On Master Node: Generate Join Token
```bash
kubeadm token create --print-join-command
```
* On Worker Nodes: Apply the Token
```bash
sudo <token>
```
* Back On Master Node: List the Nodes
```bash
kubectl get nodes
```
* If Provisioned successfully, terraform will create the required infrastructure for javawebapp Project.
