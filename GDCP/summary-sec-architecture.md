# lähteet

# muita kovennusohjeita yms.
https://docs.github.com/en/actions/reference/security/secure-use

# Tietoturvan perusperiaatteet

Erottelu: työkuormat, käyttäjät, projektit
Vähimmän oikeuden periaate (least privilege)
Organisaatioiden ja tenanttien eristys

## Tietoturva osana infrastruktuuria ja kehitystä

Infrastructure-as-Code (IaC)
DevSecOps ja CI/CD
Julkaisuautomaatio ja todennettavuus

## Konttien ja VM:ien turvallinen käyttö

Konttien skannaus ja hyväksyntä
VM-imaget: lähteet, kovennus, validointi
Sisäiset rekisterit ja luotetut komponentit

## Policy-as-Code ja OPA Gatekeeper

Sääntöjen enforce-malli
Käyttörajoitukset: resurssit, metadata, verkko

## Compliance-as-Code

Sääntelyvaatimusten mallinnus
Automatisoitu validointi ja auditointi
Dokumentaation generointi

## IAM ja Access Boundaries

RBAC ja palvelutunnukset
Access Boundary: kontekstisidonnainen pääsynhallinta
Fail-closed -periaate

## CSPM ja jatkuva valvonta

Cloud Security Posture Management (CSPM)
Auditointi, lokitus, monitorointi



# Tietoturva-arkkitehtuuri
    GDC tietoturva-arkkitehtuuri perustuu työkuormien ja käyttäjien erotteluun siten, että pienimpien käyttöoikeuksien periaate toteutuu. Työkuormina toimivat resurssit voidaan erotella toisistaan projekteihin. Käyttäjille ja palvelutunnuksille määritetään rbac-roolien kautta mitä ne voivat tehdä ja mihin.

    GDC Air-Gapped -ympäristön tietoturva-arkkitehtuuri perustuu periaatteeseen, jossa infrastruktuuri ja sovelluskehitys toteutetaan hallitusti, todennettavasti ja automaattisesti. Tämä saavutetaan yhdistämällä Infrastructure-as-Code (IaC) ja DevSecOps-menetelmät, jotka mahdollistavat turvallisuusvaatimusten sisällyttämisen osaksi koko kehitys- ja julkaisuketjua.

    Julkaisuautomaatio perustuu luotettuun pohjaan, jossa kaikki resurssit – kuten klusterit, verkot, palvelut ja käyttöoikeudet – määritellään koodina ja versionhallitaan. Tämä mahdollistaa toistettavan ja auditoitavan infrastruktuurin käyttöönoton. Sovelluskehityksessä DevSecOps-malli varmistaa, että tietoturva ei ole erillinen vaihe, vaan osa jatkuvaa integraatiota ja toimitusta (CI/CD).
    User-klustereissa voidaan käyttää OPA Gatekeeper -politiikkamoottoria, joka mahdollistaa Policy-as-Code-periaatteella toteutettujen sääntöjen enforce-tyyppisen valvonnan. Tämän avulla voidaan rajoittaa esimerkiksi:

    - Mitä resursseja sovellukset voivat käyttää
    - Minkä tyyppisiä kontteja voidaan ajaa
    - Miten verkko- ja tallennuspolitiikat toteutetaan
    - Onko metadata ja merkinnät (labels, annotations) vaaditussa muodossa

    Konttipohjaiset työkuormat skannataan ennen käyttöönottoa haittaohjelmien, haavoittuvuuksien ja konfiguraatiovirheiden varalta. Skannaus integroidaan CI/CD-putkeen, ja tulokset voidaan validoida automaattisesti ennen julkaisua. Käytettävät konttikuvat voivat olla organisaation itse tuottamia tai peräisin luotetusta sisäisestä rekisteristä, joka toimii air-gapped-ympäristössä.
    Virtuaalikoneet (VM) perustuvat valmiisiin imagetiedostoihin, jotka toimitetaan organisaatiolle joko fyysisesti tai suojatun siirtokanavan kautta. Ennen käyttöönottoa imaget kovennetaan (hardening) organisaation tietoturvapolitiikan mukaisesti. Kovennus sisältää esimerkiksi:
    - Tarpeettomien palveluiden poistamisen
    - Käyttöoikeuksien rajoittamisen
    - Auditointilokien ja monitoroinnin konfiguroinnin
    - Vahvan salauksen ja avainhallinnan käyttöönoton

    Yhdessä nämä menetelmät muodostavat GDC Air-Gapped -ympäristön tietoturva-arkkitehtuurin perustan, jossa infrastruktuuri ja sovellukset ovat hallittuja, todennettavia ja sääntelyvaatimusten mukaisia. Tietoturva ei ole erillinen osa, vaan sisäänrakennettu ominaisuus koko alustan toiminnassa.

## Compliance-as-Code
    Compliance-as-Code on menetelmä, jossa sääntelyvaatimukset ja organisaation sisäiset turvallisuusstandardit mallinnetaan ohjelmallisesti konfiguraatioina, jotka voidaan tarkistaa automaattisesti osana infrastruktuurin ja sovellusten elinkaarta. GDC Air-Gapped -ympäristössä tämä lähestymistapa tukee jatkuvaa vaatimustenmukaisuutta ilman ulkoisia riippuvuuksia, mikä on erityisen tärkeää eristetyissä ja säädellyissä käyttöympäristöissä.

    Menetelmä perustuu siihen, että vaatimukset – esimerkiksi ISO 27001:n, NIST SP 800-53:n tai SOC II:n mukaiset kontrollit – kuvataan koneellisesti luettavassa muodossa, kuten YAML- tai JSON-tiedostoina. Näitä sääntöjä voidaan soveltaa infrastruktuurin määrittelyyn (IaC), käyttöoikeuspolitiikkoihin, auditointikonfiguraatioihin ja sovelluskohtaisiin asetuksiin. Compliance-as-Code mahdollistaa politiikkojen automaattisen validoinnin esimerkiksi CI/CD-putkessa, jolloin virheelliset tai puutteelliset konfiguraatiot voidaan estää ennen käyttöönottoa.
    GDC AG -ympäristössä Compliance-as-Code voidaan toteuttaa esimerkiksi seuraavilla tavoilla:
    - OPA Gatekeeperin avulla voidaan enforce-tyyppisesti valvoa, että resurssit noudattavat vaadittuja sääntöjä.
    - Sovelluskuvien skannaus voidaan konfiguroida tarkistamaan, että ne eivät sisällä tunnettuja haavoittuvuuksia tai rikko sääntelyvaatimuksia.
    - VM-imaget voidaan validoida kovennusprosessin jälkeen automaattisesti, varmistaen että ne täyttävät organisaation turvallisuusvaatimukset ennen käyttöönottoa.
    - Auditointilokit ja käyttöoikeuspolitiikat voidaan konfiguroida osana IaC-malleja, jolloin ne ovat osa infrastruktuurin määrittelyä eikä erillinen vaihe.

    Compliance-as-Code tukee myös dokumentaation automatisointia: jokainen julkaisu, konfiguraatiomuutos tai resurssin käyttöönotto voidaan liittää auditointitietoon, joka toimii todisteena vaatimustenmukaisuudesta. Tämä on erityisen arvokasta ympäristöissä, joissa ulkoinen auditointi on rajattua tai tapahtuu harvoin.

## DevSecOps

## CICD-pipeline
### Gitlab
https://cloud.google.com/static/distributed-cloud/hosted/docs/latest/gdch/application/ao-user/partner-guides/gitlab-deployment-guide-on-google-distributed-cloud-air-gapped.pdf

## VM Imaget ja niiden julkaisu

## OPA gatekeeper policyt

## CSPM

## access boundaries
https://cloud.google.com/distributed-cloud/hosted/docs/latest/gdch/resources/access-boundaries

Organisaatio on päätason erottelu. Yksittäisellä käyttäjäorganisaatiolla voi olla yksi tai useampi GDC organisaatioita (tenantteja) käytössä riippuen miten resurssit ja tieto halutaan erotella. Normaalisti yksi GDC organisaatio on riittävä.