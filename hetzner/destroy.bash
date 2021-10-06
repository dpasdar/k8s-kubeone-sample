#!/usr/bin/env bash
kubeone reset --manifest kubeone.yaml -t tf.json -y
terraform destroy -auto-approve
