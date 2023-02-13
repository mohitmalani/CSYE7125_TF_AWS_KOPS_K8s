# Terraform for Kubernetes Cluster Setup using KOPS with Private Networking and a Bastion Host

## Prerequisites
- Configured AWS CLI.
- Install Terraform, kubectl and kops
- export configured AWS_PROFILE
- export "S3" URL of your bucket: 
```export KOPS_STATE_STORE=s3://<bucket-name>```
- Local ssh key ready
- have S3 bucket created to Kops State

## KOPS PRIVATE CLUSTER CREATION:

Let's first create our cluster ensuring a multi-master setup with 3 masters in a multi-az setup, three worker nodes also in a multi-az setup, and using both private networking and a bastion server:

```bash
kops create cluster \
--kubernetes-version=1.22.15 \
--cloud=aws \
--master-zones=us-east-1a,us-east-1b,us-east-1c \
--zones=us-east-1a,us-east-1b,us-east-1c \
--master-count=3 \
--node-count=3 \
--topology private \
--networking amazonvpc \
--node-size=t3.micro \
--master-size=t2.medium \
--state=s3://<bucket-name>
--bastion=true
--name=<cluster-name>
--ssh-public-key=<ssh-key-path>
--yes
```

## KOPS PRIVATE CLUSTER DEPLOYMENT:

Let's deploy our cluster:

```bash
kops update cluster --name=<cluster-name> --state=s3://<bucket-name>  --yes
```

## KOPS PRIVATE CLUSTER VALIDATION:

```bash
kops validate cluster --name=<cluster-name> --state=s3://<bucket-name>
```

### Above three steps of cluster creation, deployment and validation using Terraform code in this repo

```bash
> terraform init
> terraform validate
> terraform plan
> terraform apply --auto-aprrove -var-file="variables.tfvars"
```

## KOPS PRIVATE CLUSTER DELETION:

Finally, let's destroy our cluster:

```bash
kops delete cluster --name=<cluster-name> --state=s3://<bucket-name> --yes
```

### Cluster deletion using Terraform code in this repo

```bash
> terraform destroy --auto-aprrove -var-file="variables.tfvars"
```
