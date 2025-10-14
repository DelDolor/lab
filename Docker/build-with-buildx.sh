# Asenna buildx plugin (jos ei jo ole)
# Ubuntu/Docker CE repoissa se on yleensä mukana nimellä docker-buildx-plugin
docker buildx version

# Luo ja ota käyttöön builder
docker buildx create --name localbuilder --use
docker buildx inspect --bootstrap

# Rakenna
docker buildx build --progress=plain \
  --build-arg VERSION=1.0.0 \
  --build-arg VCS_REF=$(git rev-parse HEAD) \
  --build-arg BUILD_DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ) \
  -t valt-cyber-base:1.0.0 .

# Skannaa lokaalisti trivyllä
## Asenna jos puuttuu ja päivitä CVE-tietokanta
sudo snap install trivy
trivy image --download-db-only

## tallenne iamge tarriksi jotta snap-trivy voi skannata sen ja skannaa perustiedot
docker save valt-cyber-base:1.0.0 -o image.tar
trivy image --scanners vuln,secret,config,license --input image.tar


# Työnnä rekkariin
docker buildx build --push -t 3283....ecr.eu-north-1.amazonaws.com/valtcyb/dev-cicd-repo:valt-cyber-base-1.0.0 .

# testaa lokaalisti
docker run --rm -it valt-cyber-base:1.0.0 bash
