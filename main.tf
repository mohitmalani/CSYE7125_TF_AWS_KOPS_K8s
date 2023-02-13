
resource "aws_iam_policy_attachment" "kops-policy-attach" {
    name = "kops-policy-attach"
    users = ["${var.kops_user}"]
    count = "${length(var.iam_policy_arn)}"
    policy_arn = "${var.iam_policy_arn[count.index]}"

}

data "aws_availability_zones" "available_zones" {
    filter {
        name   = "region-name"
        values = ["${var.region}"]
    }
    filter {
        name   = "opt-in-status"
        values = ["opt-in-not-required"]
    }
}

locals {
    count = length(data.aws_availability_zones.available_zones.names) > 3 ? 3 : length(data.aws_availability_zones.available_zones.names)
    azs = join(",",[
            for i, name in data.aws_availability_zones.available_zones.names : name if i < local.count
        ])
}

resource "null_resource" "kops_create_cluster" {
  provisioner "local-exec" {
    command = <<-EOF
    kops create cluster \
    --kubernetes-version=${var.k8s_version} \
    --cloud=aws \
    --master-zones="${local.azs}" \
    --zones="${local.azs}" \
    --master-count=3 \
    --node-count="${var.compute_node_count}" \
    --topology private \
    --networking amazonvpc \
    --node-size="${var.compute_node_size}" \
    --master-size="${var.master_node_size}" \
    --state="s3://${var.bucket_name}" \
    --bastion=true \
    --name="${var.cluster_name}" \
    --ssh-public-key="${var.ssh_key}" \
    --yes
    EOF
  
    environment = {
      AWS_PROFILE = "${var.k8s-profile}"
      KOPS_CLUSTER_NAME = "${var.cluster_name}"
      KOPS_STATE_STORE = "s3://${var.bucket_name}"
    }
  }
  depends_on = [
    data.aws_availability_zones.available_zones,
    aws_iam_policy_attachment.kops-policy-attach,
  ]


}

resource "null_resource" "kops_update_cluster" {
  provisioner "local-exec" {
    when = create
    command = <<-EOF
    kops update cluster \
    --name="${var.cluster_name}" \
    --state="s3://${var.bucket_name}" \
    --yes
    EOF
  
    environment = {
      AWS_PROFILE = "${var.k8s-profile}"
      KOPS_CLUSTER_NAME = "${var.cluster_name}"
      KOPS_STATE_STORE = "s3://${var.bucket_name}"
    }
  }

  depends_on = [
    null_resource.kops_create_cluster
  ]
}

resource "time_sleep" "wait_15_minutes" {
  depends_on = [null_resource.kops_update_cluster]
  create_duration = "15m"
}

resource "null_resource" "kops_validate_cluster" {
  provisioner "local-exec" {
    when = create
    command = <<-EOF
    kops validate cluster \
    --name="${var.cluster_name}" \
    --state="s3://${var.bucket_name}"
    EOF
    on_failure = continue
    environment = {
      AWS_PROFILE = "${var.k8s-profile}"
      KOPS_CLUSTER_NAME = "${var.cluster_name}"
      KOPS_STATE_STORE = "s3://${var.bucket_name}"

    }
  }
  depends_on = [
    time_sleep.wait_15_minutes,
  ]
}

resource "null_resource" "kops_destroy_cluster" {

  triggers = {
    aws_profile = var.k8s-profile
    kops_cluster_name = var.cluster_name
    kops_state_store = var.bucket_name
  }
  
  provisioner "local-exec" {
    when = destroy
    command = <<-EOF
    kops delete cluster \
    --name="${self.triggers.kops_cluster_name}" \
    --state="s3://${self.triggers.kops_state_store}" \
    --yes
    EOF
  
    environment = {
      AWS_PROFILE = "${self.triggers.aws_profile}"
      KOPS_CLUSTER_NAME = "${self.triggers.kops_cluster_name}"
      KOPS_STATE_STORE = "s3://${self.triggers.kops_state_store}"

    }
  }

  depends_on = [
    aws_iam_policy_attachment.kops-policy-attach,
  ]
}