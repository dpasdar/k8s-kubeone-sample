#!/usr/bin/env bash
ssh-add ~/.ssh/terraform_rsa
terraform init
terraform apply -auto-approve
terraform output -json > tf.json
kubeone apply --manifest kubeone.yaml -t tf.json -y
