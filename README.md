# AWS EKS cluster Deployment + Karpenter with Terraform

## Overview

This Terraform configuration deploys an Amazon EKS (Elastic Kubernetes Service) cluster within an existing AWS VPC. It utilizes the terraform-aws-modules/eks module to provision the cluster and integrates [Karpenter](https://karpenter.sh/) for efficient node autoscaling.

## Features

- Deploys an EKS cluster with version 1.32.
- Utilizes AWS managed node groups for running Karpenter.
- Configures Karpenter to provision both x86 and ARM-based nodes.
- Uses Helm to deploy the Karpenter chart.
- Sets up IAM permissions and security groups for Karpenter.
- Creates multiple NodePools for instance provisioning.

## Prerequisites

Before running this Terraform configuration, ensure you have:
- AWS CLI installed and configured.
- Terraform installed (version 1.x recommended).
- An existing VPC in AWS with required subnets.
- IAM permissions to create EKS clusters, EC2 instances, and IAM roles.

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Once the cluster is up and running, you can check that Karpenter is functioning as intended with the following command:

```bash
# First, make sure you have updated your local kubeconfig
aws eks --region eu-west-1 update-kubeconfig --name eks-dev-eu-west-1

# Run a deployment on x86-based instances
kubectl apply -f deployment-x86.yaml

# Run a deployment on Graviton instances
kubectl apply -f deployment-graviton.yaml

# You can watch Karpenter's controller logs with
kubectl logs -f -n karpenter -l app.kubernetes.io/name=karpenter -c controller
```

There are two different nodePools, one for Graviton instances and other for x86-based. The default nodePool is for x86-based instances. For Graviton nodePool it contain taint and only workloads that contain toleration can be assigned to these nodes:
```bash
tolerations:
  - key: "graviton"
    operator: "Equal"
    value: "enabled"
    effect: "NoSchedule"
```

### Tear Down & Clean-Up

Because Karpenter manages the state of node resources outside of Terraform, Karpenter created resources will need to be de-provisioned first before removing the remaining resources with Terraform.

1. Remove the example deployment created above and any nodes created by Karpenter

```bash
kubectl delete deployment busybox-graviton|busybox-x86
kubectl delete node -l karpenter.sh/provisioner-name=default
```

2. Remove the resources created by Terraform

```bash
terraform destroy
```

Note that this example may create resources which cost money. Run `terraform destroy` when you don't need these resources.

## Future Development Plans

To enhance workload management and streamline deployments, future development will introduce GitOps-based automation using FluxCD. This transition will move the management of workloads—including Helm charts, HelmReleases, Helm repositories, and Kustomization resources—entirely to FluxCD. Terraform will remain responsible for provisioning and maintaining the EKS cluster infrastructure, while FluxCD will ensure automated, continuous delivery of workloads, improving deployment consistency and operational efficiency.

An example structure demonstrating this approach is present in the `flux/` directory, which represents a Git repository where FluxCD will synchronize the desired state of workloads in the cluster.


