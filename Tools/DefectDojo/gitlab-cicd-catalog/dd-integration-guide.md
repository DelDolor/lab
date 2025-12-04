# DefectDojo GitLab CI/CD Integration - Käyttöohje
Mostly AI Generated so be carefull when using!

## Pika-aloitus (5 min)

### 1. Luo DefectDojo API-avain

```bash
# Kirjaudu DefectDojoon
https://ddd.domain.fi

# Navigate to: [Profiili] → API Key
# Kopioi avain talteen
```

### 2. Lisää API-avain GitLabiin

```
GitLab → [Your Project] → Settings → CI/CD → Variables → Expand

Add variable:
  Key: DEFECTDOJO_API_KEY
  Value: <your-api-key-here>
  Type: Variable
  Flags: ✓ Protected ✓ Masked
  
Save variables
```

### 3. Luo tuote DefectDojossa

```
DefectDojo → Products → Add New Product

Name: täsmälleen sama kuin GitLab projektin path
  Esim: security/my-application
  
Product Type: valitse sopiva
Lifecycle: Active
```

### 4. Julkaise template CI/CD katalogiin

```bash
# Luo uusi projekti GitLabiin:
group: your-group
project: cicd-templates

# Rakenne:
cicd-templates/
├── templates/
│   └── defectdojo/
│       └── template.yml    # Tuo artifact-tiedosto
└── README.md
```

### 5. Käytä projektissasi

```yaml
# .gitlab-ci.yml
include:
  - project: 'your-group/cicd-templates'
    file: '/templates/defectdojo/template.yml'

stages:
  - test
  - scan
  - .post

# Esimerkki: Trivy container scan
trivy-scan:
  stage: scan
  image: aquasec/trivy:latest
  script:
    - trivy image --format json --output trivy-report.json myapp:latest
  artifacts:
    paths:
      - trivy-report.json
    expire_in: 1 week

# DefectDojo job ajetaan automaattisesti .post stagessa
```

---

## Edistynyt käyttö

### Mukauta asetuksia

```yaml
include:
  - project: 'your-group/cicd-templates'
    file: '/templates/defectdojo/template.yml'
    inputs:
      # Muuta oletusarvoja
      server-url: 'https://ddd.hunajapurkki.fi'
      timezone: 'Europe/Helsinki'
      
      # Aktivoi non-production haaroille
      noprod-enabled: true
      
      # Aktivoi product grade -tarkistus
      evaluate-product-grade: true
      
      # Email-ilmoitukset
      smtp-server: 'smtp.gmail.com:587'
      notification-severities: 'Critical,High'
      
      # Määritä scanner-raportit
      trivy-reports: 'security/trivy-*.json'
      gitleaks-reports: 'security/gitleaks-*.json'
```

### Täysi esimerkki: Multi-scanner pipeline

```yaml
# .gitlab-ci.yml
include:
  - project: 'your-group/cicd-templates'
    file: '/templates/defectdojo/template.yml'
    inputs:
      evaluate-product-grade: true
      noprod-enabled: false  # Vain production

variables:
  CONTAINER_IMAGE: ${CI_REGISTRY_IMAGE}:${CI_COMMIT_SHORT_SHA}

stages:
  - build
  - scan
  - .post

# Build
build:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker build -t ${CONTAINER_IMAGE} .
    - docker push ${CONTAINER_IMAGE}

# Container Security Scan
trivy-container:
  stage: scan
  image: aquasec/trivy:latest
  script:
    - trivy image --format json --output trivy-container.json ${CONTAINER_IMAGE}
  artifacts:
    paths:
      - trivy-container.json
    expire_in: 1 week

# Filesystem Security Scan
trivy-fs:
  stage: scan
  image: aquasec/trivy:latest
  script:
    - trivy fs --format json --output trivy-fs.json .
  artifacts:
    paths:
      - trivy-fs.json
    expire_in: 1 week

# Secret Scanning
gitleaks:
  stage: scan
  image: zricethezav/gitleaks:latest
  script:
    - gitleaks detect --report-format json --report-path gitleaks-report.json || true
  artifacts:
    paths:
      - gitleaks-report.json
    expire_in: 1 week

# Python Security
bandit:
  stage: scan
  image: python:3.11
  before_script:
    - pip install bandit[toml]
  script:
    - bandit -r . -f json -o bandit-report.json || true
  artifacts:
    paths:
      - bandit-report.json
    expire_in: 1 week
  only:
    - main
    - merge_requests

# SAST
semgrep:
  stage: scan
  image: returntocorp/semgrep:latest
  script:
    - semgrep --config auto --json --output semgrep-report.json . || true
  artifacts:
    paths:
      - semgrep-report.json
    expire_in: 1 week

# Dockerfile Linting
hadolint:
  stage: scan
  image: hadolint/hadolint:latest-alpine
  script:
    - hadolint Dockerfile --format json > hadolint-report.json || true
  artifacts:
    paths:
      - hadolint-report.json
    expire_in: 1 week

# DefectDojo auto-upload (runs in .post stage)
# Needs no configuration - uses artifacts from scan jobs
```

---

## Tuetut scannerit ja raporttimuodot

| Skanneri | DefectDojo Parser | Oletuspolku | Formaatti |
|----------|-------------------|-------------|-----------|
| **Trivy** | Trivy Scan | `trivy/*.json` | JSON |
| **Gitleaks** | Gitleaks Scan | `gitleaks/*.json` | JSON |
| **Bandit** | Bandit Scan | `bandit*.json` | JSON |
| **Semgrep** | Semgrep JSON Report | `reports/*semgrep*.json` | JSON |
| **Hadolint** | Hadolint Dockerfile check | `reports/*hadolint*.json` | JSON |
| **ZAP** | ZAP Scan | `reports/*zap*.xml` | XML |
| **CycloneDX** | CycloneDX Scan | `*.cyclonedx.json` | JSON |
| **SARIF** | SARIF | `*.sarif` | SARIF |
| **Dependency Check** | Dependency Check Scan | `dependency-check*.xml` | XML |
| **NPM Audit** | NPM Audit Scan | `npm-audit*.json` | JSON |

### Scanner-kohtaiset esimerkit

#### Trivy (Container & Filesystem)
```yaml
trivy-scan:
  stage: scan
  image: aquasec/trivy:latest
  script:
    # Container image scan
    - trivy image --format json --output trivy-image.json ${IMAGE}
    # Filesystem scan
    - trivy fs --format json --output trivy-fs.json .
  artifacts:
    paths:
      - trivy-*.json
```

#### Gitleaks (Secret scanning)
```yaml
gitleaks:
  stage: scan
  image: zricethezav/gitleaks:latest
  script:
    - gitleaks detect --report-format json --report-path gitleaks/report.json || true
  artifacts:
    paths:
      - gitleaks/
```

#### Bandit (Python SAST)
```yaml
bandit:
  stage: scan
  image: python:3.11-slim
  before_script:
    - pip install bandit[toml]
  script:
    - bandit -r src/ -f json -o bandit-report.json || true
  artifacts:
    paths:
      - bandit-report.json
```

#### Semgrep (Multi-language SAST)
```yaml
semgrep:
  stage: scan
  image: returntocorp/semgrep:latest
  script:
    - semgrep --config auto --json --output reports/semgrep.json .
  artifacts:
    paths:
      - reports/
```

#### OWASP Dependency Check (Java/Maven)
```yaml
dependency-check:
  stage: scan
  image: maven:3.9-eclipse-temurin-17
  script:
    - mvn org.owasp:dependency-check-maven:check -DfailBuildOnCVSS=0
  artifacts:
    paths:
      - target/dependency-check-report.xml
```

#### OWASP ZAP (DAST)
```yaml
zap-scan:
  stage: scan
  image: owasp/zap2docker-stable
  script:
    - mkdir -p reports
    - zap-baseline.py -t https://your-app.com -r reports/zap-report.xml || true
  artifacts:
    paths:
      - reports/
```

---

## Product Grade Health Monitoring

DefectDojo voi arvioida projektin turvallisuuden "terveyspistemäärällä" (1-100).

### Käyttöönotto

1. **Määritä kynnysarvot DefectDojossa:**
```
DefectDojo → Products → [Your Product] → Settings → Product Custom Fields

Lisää custom fieldit:
  - product_grade_failure (tyyppi: Number)
    Value: 60  (alle tämän = buildi failaa)
  
  - product_grade_warning (tyyppi: Number)
    Value: 75  (alle tämän = varoitus)
```

2. **Aktivoi pipelinessa:**
```yaml
include:
  - project: 'your-group/cicd-templates'
    file: '/templates/defectdojo/template.yml'
    inputs:
      evaluate-product-grade: true
      product-grade-failure: 'product_grade_failure'
      product-grade-warning: 'product_grade_warning'
```

### Toiminta

- **Grade ≥ warning threshold**: ✅ Pipeline onnistuu
- **Grade < warning, ≥ failure**: ⚠️ Pipeline onnistuu varoituksella (exit 142)
- **Grade < failure threshold**: ❌ Pipeline failaa

---

## Email-ilmoitukset

### SMTP-konfiguraatio

```yaml
include:
  - project: 'your-group/cicd-templates'
    file: '/templates/defectdojo/template.yml'
    inputs:
      smtp-server: 'smtp.gmail.com:587'
      notification-severities: 'Critical,High,Medium'
```

### Gmail-esimerkki (App Password)

1. Luo App Password: https://myaccount.google.com/apppasswords
2. Lisää GitLab CI/CD variableksi:
```
SMTP_USER: your-email@gmail.com
SMTP_PASSWORD: <app-password>
```

3. Muokkaa templatea käyttämään autentikaatiota (tarvittaessa)

---

## Troubleshooting

### Ongelma: "Product not found"

**Ratkaisu:**
```
DefectDojo → Products → Add New Product
Name: TÄSMÄLLEEN sama kuin CI_PROJECT_PATH
  Esim. GitLab: group/subgroup/project
       DefectDojo: group/subgroup/project
```

### Ongelma: "Invalid API key"

**Ratkaisu:**
```bash
# Tarkista API-avain
curl -H "Authorization: Token YOUR_API_KEY" \
  https://ddd.hunajapurkki.fi/api/v2/user_profile

# Jos virhe, luo uusi avain DefectDojossa
```

### Ongelma: "No reports found"

**Ratkaisu:**
```yaml
# Varmista että scanner-jobit tuottavat artifactit:
scanner-job:
  artifacts:
    paths:
      - trivy-report.json  # Polun pitää täsmätä
    expire_in: 1 week

# Tarkista polut:
defectdojo:
  before_script:
    - find . -name "*.json" -o -name "*.xml"  # Listaa kaikki raportit
```

### Ongelma: "Connection timeout"

**Ratkaisu:**
```bash
# Tarkista että runner pääsee DefectDojoon
# Jos käytät private runneria:

# 1. AWS Security Group: salli lähtevä HTTPS (443)
# 2. Tarkista DNS
curl -v https://ddd.hunajapurkki.fi/api/v2/user_profile

# 3. Jos ALB/proxy edessä, varmista että backend pääsee läpi
```

### Ongelma: "Import failed"

**Ratkaisu:**
```bash
# Tarkista raportin formaatti
cat trivy-report.json | jq .

# Onko oikea DefectDojo parser?
# Lista parsereista:
curl -H "Authorization: Token YOUR_API_KEY" \
  https://ddd.hunajapurkki.fi/api/v2/test_types/ | jq '.results[].name'
```

---

## Best Practices

### 1. Raportoi vain production-haarasta
```yaml
inputs:
  noprod-enabled: false  # Oletus
```
**Syy:** Välttää turhaa dataa dev-haaroista

### 2. Käytä protected variableja
```
GitLab Variables:
  ✓ Protected (vain protected branches)
  ✓ Masked (piilotetaan logeista)
```

### 3. Aseta artifact-expiration
```yaml
artifacts:
  expire_in: 1 week  # Säästää storagea
```

### 4. Yhdistä samantyyppisten scannerien raportit
```yaml
# Huono: 5 erillistä Trivy-jobia
# Hyvä: 1 job, skannaa kaikki containerit
trivy-all:
  script:
    - for img in app nginx postgres; do
        trivy image --format json --output trivy-${img}.json ${img}:latest
      done
```

### 5. Käytä manual triggeriä dev-haaroissa
```yaml
# Template käyttää automaattisesti tätä logiikkaa:
rules:
  - if: '$CI_COMMIT_REF_NAME =~ /^(master|main|production)$/'
    when: always
  - when: manual
```

### 6. Seuraa trendejä DefectDojossa
```
DefectDojo → Metrics → Security Metrics
- Seuraa avoinna olevia findingseja ajan yli
- Aseta tavoitteet (esim. 0 Critical, <5 High)
```

---

## CI/CD Catalog Publishing

Jos haluat julkaista templaten GitLab CI/CD Catalogiin:

### 1. Projektirakenteen vaatimukset
```
cicd-templates/
├── templates/
│   └── defectdojo/
│       └── template.yml
├── README.md
└── .gitlab-ci.yml (optional)
```

### 2. Lisää metadata
```yaml
# templates/defectdojo/template.yml alkuun:
# DefectDojo Security Scan Integration
# Version: 1.0.0
# Maintainer: Security Team
# Description: Automated security scan result upload to DefectDojo
```

### 3. Julkaise catalog
```
GitLab → [Project] → Settings → General → Visibility
  → CI/CD Catalog resource
  → Enable
```

### 4. Käytä catalogista
```yaml
include:
  - component: your-instance.com/your-group/cicd-templates/defectdojo@1.0.0
```

---

## Kehityssuunnitelma

Tulevat ominaisuudet:

- [ ] Automaattinen tuotteen luonti DefectDojoon
- [ ] SonarQube-integraatio
- [ ] Slack/Teams-notifikaatiot
- [ ] Findings-deduplication parannus
- [ ] Dockerfile security check
- [ ] IaC scanning (Terraform, CloudFormation)

---

## Tuki ja yhteystiedot

**Dokumentaatio:**
- DefectDojo API: https://ddd.hunajapurkki.fi/api/v2/doc/
- DefectDojo parsers: https://documentation.defectdojo.com/integrations/parsers/

**Ongelmatilanteissa:**
1. Tarkista troubleshooting-osio
2. Tarkista GitLab job logit
3. Tarkista DefectDojo system logs
4. Ota yhteyttä security-tiimiin

---

## Lisäresurssit

### Esimerkki: Full Python Project

```yaml
# .gitlab-ci.yml (Python-projekti)
include:
  - project: 'security/cicd-templates'
    file: '/templates/defectdojo/template.yml'
    inputs:
      evaluate-product-grade: true
      smtp-server: 'smtp.company.com:587'

variables:
  PIP_CACHE_DIR: "$CI_PROJECT_DIR/.cache/pip"
  CONTAINER_IMAGE: ${CI_REGISTRY_IMAGE}:${CI_COMMIT_SHORT_SHA}

stages:
  - test
  - build
  - scan
  - .post

# Unit tests
pytest:
  stage: test
  image: python:3.11
  script:
    - pip install -r requirements.txt
    - pytest tests/ --cov

# Build container
build:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker build -t ${CONTAINER_IMAGE} .
    - docker push ${CONTAINER_IMAGE}
  only:
    - main
    - merge_requests

# Security scans
trivy-container:
  stage: scan
  image: aquasec/trivy:latest
  script:
    - trivy image --format json -o trivy-container.json ${CONTAINER_IMAGE}
  artifacts:
    paths:
      - trivy-container.json

trivy-deps:
  stage: scan
  image: aquasec/trivy:latest
  script:
    - trivy fs --format json -o trivy-deps.json .
  artifacts:
    paths:
      - trivy-deps.json

bandit:
  stage: scan
  image: python:3.11-slim
  before_script:
    - pip install bandit[toml]
  script:
    - bandit -r src/ -f json -o bandit-report.json || true
  artifacts:
    paths:
      - bandit-report.json

gitleaks:
  stage: scan
  image: zricethezav/gitleaks:latest
  script:
    - mkdir -p gitleaks
    - gitleaks detect --report-format json --report-path gitleaks/report.json || true
  artifacts:
    paths:
      - gitleaks/

semgrep:
  stage: scan
  image: returntocorp/semgrep:latest
  script:
    - mkdir -p reports
    - semgrep --config auto --json --output reports/semgrep.json . || true
  artifacts:
    paths:
      - reports/

# DefectDojo uploads automatically in .post stage
```

### Esimerkki: Docker-only Project

```yaml
# .gitlab-ci.yml (Container-projekti)
include:
  - project: 'security/cicd-templates'
    file: '/templates/defectdojo/template.yml'

variables:
  CONTAINER_IMAGE: ${CI_REGISTRY_IMAGE}:${CI_COMMIT_SHORT_SHA}

stages:
  - build
  - scan
  - .post

build:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker build -t ${CONTAINER_IMAGE} .
    - docker push ${CONTAINER_IMAGE}

trivy:
  stage: scan
  image: aquasec/trivy:latest
  script:
    - trivy image --format json -o trivy-report.json ${CONTAINER_IMAGE}
  artifacts:
    paths:
      - trivy-report.json

hadolint:
  stage: scan
  image: hadolint/hadolint:latest-alpine
  script:
    - mkdir -p reports
    - hadolint Dockerfile --format json > reports/hadolint.json || true
  artifacts:
    paths:
      - reports/
```

Valmista! 🎉