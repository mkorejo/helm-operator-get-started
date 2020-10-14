# Managing Helm Releases the GitOps Way

Forked from [fluxcd/helm-operator-get-started](https://github.com/fluxcd/helm-operator-get-started).

## Notes
### Create `registry-creds` seed secret
[This operator](https://github.com/alexellis/registry-creds) allows us to define image pull secrets once per cluster, i.e. all namespaces in the cluster can reference the image pull secret. We install `registry-creds` in the `adm` namespace (see `flux/adm`).

The cluster should be bootstraped with the `ClusterPullSecret` CRD *before installing Flux*, perhaps using [a separate Helm chart](https://github.com/mkorejo/helm_charts/tree/master/src/crds), in order for Flux to apply [this resource](./flux/adm/registry-creds-seed-secret.yaml) that accompanies the seed secret.
```
export PW=mypassword

kubectl create secret docker-registry registry-creds-secret \
  --namespace adm \
  --docker-username=mkorejo \
  --docker-password=$PW \
  --docker-email=mkorejo@gmail.com
```

### CI
```
cd hack && ./ci-mock.sh -r mkorejo/podinfo -b dev
           ./ci-mock.sh -r mkorejo/podinfo -b stg
```
