# Managing Helm Releases the GitOps Way
Forked from [fluxcd/helm-operator-get-started](https://github.com/fluxcd/helm-operator-get-started).

## Why?
The goal is not to run Kubernetes, use Terraform or Flux, or do GitOps. The goal is to streamline IT operations:
* Consolidate
* Standardize
* Automate

## How?
Kubernetes is purposefully-built to streamline IT operations. Imperative to Kubernetes are control loops: control loops are executed by controllers, and there is a controller for almost every type of Kubernetes resource. Controllers read desired state from the Kubernetes datastore and continuously work to reconcile desired state with current state. This enables the following workflow:
1. **Run Kubernetes**
   - Abstract multiple, heterogenous infrastructure pools (compute, network, and storage) into one.
   - Terraform can drive infrastructure provisioning and cluster bootstrapping.
2. **Tell the Kubernetes API exactly what you want**
   - Resource definitions include container image/runtime specifications, storage requirements, reverse proxy configuration, labels/metadata/annotations, etc. There are different requirements and options for different types of resources.
   - There are several [native K8s resources](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.19/) and these are serviced by [`kube-controller-manager`](https://kubernetes.io/docs/concepts/overview/components/#kube-controller-manager). We can define custom resources and build custom controllers, i.e. [use operators](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/), to further abstract complexity.
   - [`helm`](https://helm.sh/) is hugely valuable for packaging and templating resource definitions. [Flux](https://fluxcd.io/) provides a Kubernetes operator for `HelmRelease` resources.
3. **Profit**
   - Kubernetes will fulfill your request upon acceptance or otherwise describe why the request cannot be fulfilled.

## Requirements
Looking at #1 and #2, some prerequisites emerge:
* Capture all configurations as source code.
* We must be able to *plug* existing infrastructure into Kubernetes, e.g. VMs or physical servers for the Kubernetes workers, external storage devices for persistent volumes, and load balancers for ingress.
* Workloads running on Kubernetes workers must be containerized and and source images must be pulled from a registry.
  - Note that containerized workloads can then drive actions outside of Kubernetes via API calls (see [HashiCorp's](https://www.hashicorp.com/blog/creating-workspaces-with-the-hashicorp-terraform-operator-for-kubernetes) or [Rancher's](https://github.com/rancher/terraform-controller) Terraform operators, the [AWS Service Operator](https://aws.amazon.com/blogs/opensource/aws-service-operator-kubernetes-available/), or [KubeVirt](https://kubevirt.io/)).

Huge strides have been made to standardize all the interfaces at play here, so meeting the prerequisites is not too difficult. The technology is there, Kubernetes is everywhere, and you only need to get started.

## Scaling
How do you manage multiple production and non-production clusters across the globe? Let's revisit #1 and #2 above:
1. **Run a lot of Kubernetes**
   - Automate cluster provisioning and bootstrapping.
   - Establish control and observability across all clusters such that you can _monitor_ node health, Kubernetes versions, current workloads, and scaling activity in one place, as well as _manage_ the provisioning and teardown of clusters consistently.
2. **Tell a lot Kubernetes API endpoints what you want**
   - Efficiently manage state across multiple clusters.
   - Ensure that standard cluster add-ons and services are deployed to all clusters and that configurations are kept in sync.
   - Enable self-serviceability for application teams to deploy their own workloads without causing an issue.

Enabling self-serviceability with minimal risk requires automation, secrets management, and use of Kubernetes namespaces, RBAC, quotas, and [admission controllers](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/).
