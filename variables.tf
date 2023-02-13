variable "region" {
  default = "us-east-1"
}

variable "awscli-profile" {
  default = "default awscli profile - either dev or prod"
}

variable "kops_user" {
   default = "User created for kops"
}

variable "iam_policy_arn" {
    description = "IAM Policy to be attached to role"
    type = list
    default = [
        "arn:aws:iam::aws:policy/AmazonEC2FullAccess", 
        "arn:aws:iam::aws:policy/AmazonRoute53FullAccess",
        "arn:aws:iam::aws:policy/AmazonS3FullAccess",
        "arn:aws:iam::aws:policy/IAMFullAccess",
        "arn:aws:iam::aws:policy/AmazonVPCFullAccess",
        "arn:aws:iam::aws:policy/AmazonSQSFullAccess",
        "arn:aws:iam::aws:policy/AmazonEventBridgeFullAccess",
    ]
}

variable "k8s_version" {
  default = "1.22.15"
}

variable "compute_node_count" {
  default = 3
}

variable "compute_node_size" {
  default = "t3.micro"
}

variable "master_node_size" {
  default = "t2.medium"
}

variable "cluster_name" {
  default = "Generally your subdomain name"
}

variable "bucket_name" {
  default = "S3 Bucket where KOPS state will be stored"
}

variable "ssh_key" {
  default = "Absolute path with key name"
}

variable "k8s-profile" {
  default = "k8s user profile"
}