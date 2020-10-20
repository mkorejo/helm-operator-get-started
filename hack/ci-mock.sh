#!/usr/bin/env bash

repository="stefanprodan/podinfo"
branch="master"
version=""
commit=$(cat /dev/urandom | env LC_CTYPE=C tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1 | awk '{print tolower($0)}')
gpg_key_id="CEA5E6BE"

while getopts :r:b:v: o; do
    case "${o}" in
        r)
            repository=${OPTARG}
            ;;
        b)
            branch=${OPTARG}
            ;;
        v)
            version=${OPTARG}
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${version}" ]; then
    image="${repository}:${branch}-${commit}"
    version="0.4.0"
else
    image="${repository}:${version}"
fi

echo ">>>>>>>> Building image ${image} <<<<<<<<"
docker build --build-arg GITCOMMIT=${commit} --build-arg VERSION=${version} -t ${image} -f Dockerfile.ci .

echo ">>>>>>>> Pushing image ${image} <<<<<<<<"
docker push ${image}

echo ">>>>>>>> Signing image ${image} <<<<<<<<"

digest=$(docker inspect --format='{{index .RepoDigests 0}}' ${image} | cut -d '@' -f 2)
echo "Digest for ${image} is ${digest}"
echo ${digest} > image-digest.txt
gpg -u mkorejo@gmail.com \
    --armor \
    --clearsign \
    --yes \
    --output=signature.gpg \
    image-digest.txt
gpg --output - --verify signature.gpg

echo ">>>>>>>> Creating occurrence for ${image} <<<<<<<<"

gpg_signature=$(cat signature.gpg | base64)
resource_url="https://${repository}@${digest}"
echo "Signature encoding is ${gpg_signature}"
echo "Resource URL is ${resource_url}"

cat > occurrence.json <<EOF
{
  "noteName": "projects/image-signing/notes/all",
  "kind": "ATTESTATION",
  "resource": {
    "name": "${image}",
    "uri": "${resource_url}"
  },
  "attestation": {
    "attestation": {
      "pgpSignedAttestation": {
        "signature": "${gpg_signature}",
        "contentType": "SIMPLE_SIGNING_JSON",
        "pgpKeyId": "${gpg_key_id}"
      }
    }
  }
}
EOF

curl -X POST http://grafeas.devops.coda.run/v1beta1/projects/image-signing/occurrences \
    --data @occurrence.json

rm *.json image-digest.txt signature.gpg
