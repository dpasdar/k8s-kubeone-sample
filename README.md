# Hetzner Terraform integration 
KubeOne can be used to create and maintain a set of controllers/workers using Hetzner. The resulting cluster is integrated with the Hetzner controller manager, making it easy to use hetzner specific features such as private networks and load balancers.

## Create a Kubernetes Cluster using Terraform
The provided sample creates a K8s cluster with HighAvailability(odd=3 number of master nodes). Make sure `terraform` and `kubeone` are already installed.
1. Make sure a proper SSH key is provided. The existing keys in Hetzner can not be re-used. Update the key path in `terraform.tfvars` file.
2. Go to the hetzner directory
3. Load the `HCLOUD_TOKEN` env variable somehow, e.g. with the awesome [direnv](https://direnv.net/) tool.
4. Adjust the `terraform.tfvars` accordingly
5. Adjust the `kubeone.yaml` with the correct version of k8s
6. Run the following commands to create the controllers

```
terraform init
terraform apply
```
4. `output.tf` is a template file indicating the necessary output fields required by kubeone. Run the following command to create the required kubeone input from terraform:

```
terraform output -json > tf.json
```

5. Feed the resulting `tf.json` file to kubeone, that way kubeone can automagically understand the infrastructure created with the terraform(or some other tooling) and install/configure Kubernetes accordingly.

```
kubeone apply --manifest kubeone.yaml -t tf.json
```

6. kubectl config will be generated. It has to be copied to/merged with `~/.kube/config`
7. The default config creates only one worker node, to scale use the following command:

```
kubectl get machinedeployment -n kube-system
kubectl scale machinedeployment/<<name of the machine deployment>> --replicas=<<number of replicas>> -n kube-system
```

## Trying the Load Balancers for applications
1. Use `lb-test.yaml` to create a sample deployment with two nginx instances, and the access from outside using Hetzner loadbalancers.

```
kubectl create -f lb-test.yaml
``` 

2. Go to the hetzner cloud console and find the generated load-balancer(it has a cryptic name), and note the IP-Address. Use that `IP:8080` to access nginx.

## Trying the external volumes
1. Create a secret for hetzner cloud with the API Token:

```
apiVersion: v1
kind: Secret
metadata:
  name: hcloud-csi
  namespace: kube-system
stringData:
  token: YOURTOKEN
```

2. Install the CSI Driver:

```
kubectl apply -f https://raw.githubusercontent.com/hetznercloud/csi-driver/master/deploy/kubernetes/hcloud-csi.yml
```

3. Create the PVC for hetzner:

```
kubectl create -f hetzner-pvc.yaml
```

4. Create a mongodb deployment to test if everything works:

```
kubectl create -f mongo.yaml
```
5. Go to the hetzner cloud and observe the generated Volume.

6. Once the mongodb is created, you can access the container and create a mongodb object inside, just to make sure persistance works.

```
kubectl exec -it mongo -- sh
mongo
db.local.insertOne({"something": "another"})
db.local.find()
```

7. Remove the pod, scale the nodes to 0 or do all sort of destructive operations to make sure there is no trace of the mongo infrastructure created(other than the pvc volume in hetzner)
8. Recreate the pod and use the following commands to make sure the data still exists:

```
kubectl exec -it mongo -- sh
mongo
db.local.find()
```
