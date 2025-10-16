# Building the Builder
Tavoitteena on rakentaa turvallinen ja kevyt pohjaimage (builder-base) ja tallentaa se yksityiseen rekisteriin. Tallennettu base-image allekirjoitetaan ja siitä generoidaan SBOM. Tätä builder-base imagea käytetään GitLab CI/CD runnerin peruskuvana ja siihen pohjautuen voidaan tehdä muita spesifiin käyttöön tarkoitettuja buildereita (esim. builder-checkov ja builder-trivy) yms.

## Builder-base imagen ominaisuuksia ja toteutuksessa huomioitavia rajoitteita
- Builder-base rakennetaan CICD-jobissa, jonka runnerina ajetaan builder-zero imagea. Tämä image sisältää kaikki tarvittavat työkalut.
- Builder-base pohjautuu kevyeen ja luotettavaan imageen jonka versio lukittu (esim. Bookworm-slim)
- Tähän pohjaan asennetaan vain ne yhteiset työkalut, joita muissa myöhemmin rakennettavissa buildereissa käytetään. esim. AWS CLI, Bats, jq yms. Asennettavien komponenttien eheys pitää tarkistaa (SHA Checksum)
- Käytetään AWS ECR ja KMS palveluita
- Käytössä GitLab CI/CD joka OIDC integroitu AWS:ään
- Gitlabilla käytössä AWS rooli, johon on liitetty policy, joka mahdollistaa ECR ja KMS palveluiden käytön
- Käytetään GitLab CICD Variableja välittämään tietoa runnerissa ajettaville scripteille
- Allekirjoitukseen käytetään Cosignia joka hyödyntää AWS KMS palvelussa olevaa CMK-avainta
- SBOM generoidaa SYFT:lla

## builder-zero
Mikä “builder-zero” on?
Builder-zero on erillinen jobi-image, joka sisältää kaikki tarvittavat työkalut builder-base-imagen rakentamiseen ja toimitusketjun koventamiseen. Se toimii CI/CD-pipelinejen rakennusvaiheen alustana, mutta ei ole sama asia kuin varsinainen builder-base, jota käytetään myöhemmin runnereiden peruskuvana (muissa pipelineissä).

Sisältää mm.:
- BuildKit / buildx
- AWS CLI
- Cosign (allekirjoitukseen)
- Syft (SBOM-generointiin)
- jq, bats, yms.

### Trivy
Builder base image halutaan pitää mahdollisimman puhtaana ja vähemmän muuttuvana. Tämän takia Trivy skanneria ei sisällytetä builder-zeroon vaan siihen käytetään AquaSecurity virallista trivy image joka peilataan omaan rekisteriin ja pinnataan digestillä.

Hyödyt erillisestä Trivy-jobista:
- Turvallisuus: Builder-zero pysyy puhtaana ja vähemmän muuttuvana, mikä helpottaa sen auditointia ja allekirjoitusta.
- Modulaarisuus: Trivy voidaan päivittää tai konfiguroida erikseen ilman, että builder-zeroa tarvitsee rebuildata.
- Koko ja nopeus: Trivy tuo mukanaan riippuvuuksia (mm. Go-binaarit, tietokantapäivitykset), jotka kasvattavat imagea ja hidastavat buildia.
- Toimitusketjun hallinta: Kun Trivy on omassa imagessaan, sen SBOM ja allekirjoitus voidaan hallita erikseen.

### Miten builder-zero rakennetaan?
1. Turvallisella bastion-koneella paikallisesti
2. Lataa Dockerfile versionhallinnasta
   - Käytä lukittua pohjaimagea (FROM debian@sha256:<digest>)
   - Perustelut: toistettavuus, turvallisuus, auditointi
3. Buildaa image
   - Varmista komponenttien eheys (SHA256 checksum)
4. Skannaa Trivyllä
   - Korjaa haavoittuvuudet
5. Puske ECR:ään
   - Versioi esim. `builder-zero:2025.10`
6. Allekirjoita Cosignilla
   - Käytä AWS KMS:n CMK-avainta
7. Generoi SBOM Syftillä
8. Tallenna signature ja SBOM
   - Cosign tallentaa signaturet OCI-artifaktien viereen ECR:ään
   - SBOM tallennetaan JSON-muodossa OCI-attestationina, sidottuna builder-base:stable@sha256:<digest> -referenssiin.

## builder-base
Pipelinen stage/jobi rakenne on seuraava:
stages:
1. preflight
2. build
3. scan
4. sbom
5. sign
6. publish

### preflight
- Varmistaa että GitLab OIDC toimii ja AWS-rooli on käytettävissä
- Tarkistaa että tarvittavat GitLab CI/CD -muuttujat on asetettu
- Testaa ECR-login ja KMS-yhteyden

### build
- Rakentaa builder-base imagen Dockerfilestä käyttäen builder-zeroa runnerina

### scan
Skannataan haavoittuvuudet yms. Tämä poikkeaa muista vaiheista siten, että se ajetaan erillisellä aquasecurity trivy imagella.

### sbom
- Generoi SBOM Syftillä ja liittää sen OCI-attestationina

### sign
- Allekirjoittaa builder-base imaget Cosignilla käyttäen AWS KMS -avainta

### publish
- Puskee imaget ECR:ään ja varmistaa että signature ja SBOM ovat mukana

## builder-aws
Tuleva image, joka pohjautuu builder-baseen ja sisältää AWS-spesifisiä työkaluja (esim. aws-vault, eksctl, sam-cli). builder-aws versioidaan muodossa builder-aws:2025.10 ja allekirjoitetaan samalla tavalla.


## Avoimia asioita
- Builder-zero versionhallinta: käytetäänkö digestin lisäksi myös semanttista versiota?
- Cosignin verify-vaihe: tehdäänkö verify pipelineen?
- Builder-base päivitysprosessi: miten hallitaan päivitykset ja rollbackit?
- Trivy-skannauksen tulosten käsittely: miten haavoittuvuudet raportoidaan ja estetäänkö julkaisu tietyillä CVSS-kynnyksillä?

