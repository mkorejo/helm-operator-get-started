# Notes
## Authorize Flux using its public SSH key
The public SSH identity for a Flux installation is generated on startup. Check the start of the logs for `fluxcd` in your cluster or use `fluxctl identity --k8s-fwd-ns fluxcd` to obtain the public key. Add the public key as a SSH authorized key in your Git provider.

## Build new images
```
cd hack && ./ci-mock.sh -r mkorejo/podinfo -b dev
           ./ci-mock.sh -r mkorejo/podinfo -b stg
           ./ci-mock.sh -r mkorejo/podinfo -v 5.0.2
```

## Create seed secret for `registry-creds`
[This operator](https://github.com/alexellis/registry-creds) allows us to define image pull secrets once per cluster, i.e. all namespaces in the cluster can reference the image pull secret. We install `registry-creds` in the `adm` namespace (see `flux/adm`).

The cluster should be bootstrapped with the `ClusterPullSecret` CRD *before installing Flux*, perhaps using [a separate Helm chart](https://github.com/mkorejo/helm_charts/tree/master/src/crds), in order for Flux to apply [this resource](./flux/adm/registry-creds-seed-secret.yaml) that accompanies the seed secret:
```
export PW=mypassword

kubectl create secret docker-registry registry-creds-secret \
  --namespace adm \
  --docker-username=mkorejo \
  --docker-password=$PW \
  --docker-email=mkorejo@gmail.com
```

## Grafeas setup
Use `openssl` to generate the SSL artifacts. See [here](https://github.com/grafeas/grafeas/blob/master/docs/running_grafeas.md#use-grafeas-with-self-signed-certificate).

Setup Grafeas project and note:
```
curl http://grafeas.devops.coda.run/v1beta1/projects

curl -X POST http://grafeas.devops.coda.run/v1beta1/projects \
  --data '{"name":"projects/image-signing"}'

cat > note.json <<EOF
{
  "name": "projects/image-signing/notes/production",
  "kind": "ATTESTATION",
  "shortDescription": "All production-approved image signatures",
  "longDescription": "All production-approved image signatures",
  "attestationAuthority": {
    "hint": {
      "humanReadableName": "production"
    }
  }
}
EOF

curl -X POST http://grafeas.devops.coda.run/v1beta1/projects/image-signing/notes?noteId=production \
  --data @note.json
```


