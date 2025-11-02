# Lähteet
2025-11-02
https://cloud.google.com/distributed-cloud/hosted/docs/latest/gdch/platform/pa-user/iam/connect-identity
https://cloud.google.com/distributed-cloud/hosted/docs/latest/gdch/platform/pa-user/iam/sign-in
https://cloud.google.com/distributed-cloud/hosted/docs/latest/gdch/platform/pa-user/service-identity
https://cloud.google.com/distributed-cloud/hosted/docs/latest/gdch/platform/pa-user/iam/set-up-role-bindings
https://cloud.google.com/distributed-cloud/hosted/docs/latest/gdch/platform/pa-user/iam/role-descriptions
https://cloud.google.com/distributed-cloud/hosted/docs/latest/gdch/platform/pa-user/iam/role-definitions
https://cloud.google.com/distributed-cloud/hosted/docs/latest/gdch/platform/pa-user/iam/custom-roles
https://cloud.google.com/distributed-cloud/hosted/docs/latest/gdch/platform/pa-user/iam/secure-service-account-keys


# Käyttäjän ja pääsynhallinta
IAM-ratkaisu perustuu alustan natiiviin Google Distributed Cloud (GDC) IAM-palveluun, joka hallinnoi käyttöoikeuksia, rooleja ja palvelutunnuksia. Tämän lisäksi toteutetaan identiteetin tarjoaja (IdP), joka vastaa käyttäjien autentikoinnista. IdP integroituu GDC:hen joko OpenID Connect (OIDC)- tai SAML-protokollan avulla.

GDC voidaan yhdistää organisaation olemassa olevaan identiteetinhallintajärjestelmään, jolloin käyttäjät voivat kirjautua omilla organisaatiotunnuksillaan. Mikäli IdP halutaan eristää samaan air-gapped alustaan ilman ulkoisia riippuvuuksia, tulee sinne toteuttaa oma IdP-ratkaisu. Kaksi vaihtoehtoa tähän ovat:

- Active Directory (AD)
Jos projektiin toteutetaan AD esimerkiksi päätelaitehallinnan tai muun infrastruktuurin tarpeisiin, sen hyödyntäminen IdP:nä on järkevää. AD voidaan integroida GDC:hen SAML- tai OIDC-välikerroksen kautta.


- Keycloak
Jos AD:ta ei toteuteta, Keycloak on kevyt ja helposti hallittava vaihtoehto pelkästään GDC:n IAM-tarpeisiin. Keycloak on avoimen lähdekoodin IAM-ratkaisu, joka tukee OIDC:ta ja voidaan asentaa täysin paikallisesti. Se tarjoaa SSO-toiminnallisuudet, roolipohjaisen pääsynhallinnan ja graafisen hallintakäyttöliittymän.

PIIRRÄ KUVA OIDC FLOWsta

## Käyttäjien kirjautuminen
Käyttäjät voivat kirjautua GDC-palveluihin seuraavilla tavoilla:
- GDC Console (selainpohjainen käyttöliittymä)
- gdcloud CLI
- kubectl CLI (vaatii kubeconfig-tiedoston luomisen ennen käyttöä)

## Palvelutunnukset ja salaisuudet
Palvelutunnukset (service accounts) mahdollistavat sovellusten ja automaation pääsyn GDC-resursseihin. Jokaiselle palvelutunnukselle voidaan luoda avaimet (service account keys), jotka tulee säilyttää turvallisesti. GDC tarjoaa mekanismit avainten hallintaan ja suojaamiseen, mukaan lukien:

- Salaus KMS:n avulla: Avaimet voidaan salata GDC:n sisäisellä Key Management Service (KMS)-palvelulla.
- HSM-integraatio: KMS voi hyödyntää Hardware Security Module (HSM)-ratkaisuja, jotka tarjoavat FIPS 140-2 Level 3 -sertifioidun laitteistopohjaisen avainten suojauksen.
- Avainten hallinta: KMS tukee avainten luontia, rotaatiota, tuontia ja vientiä sekä kryptografisia operaatioita (salaus, allekirjoitus).
- RBAC-pohjainen käyttöoikeus: Vain valtuutetut käyttäjät voivat luoda, käyttää tai kierrättää avaimia.

# RBAC ja autorisointi
GDC käyttää Role-Based Access Control (RBAC)-mallia, jossa käyttöoikeudet määritellään:
- Laajuuden mukaan: organisaatio, projekti/namespace
- Verbeillä: esim. get, list, create, delete
Tällöin voidaan määrittää tarkasti mitä kukin saa tehdä mihinkin kohteeseen.

## Valmiit roolit
GDC tarjoaa esivalmisteltuja rooleja, kuten:
- Organization Admin
- Project Admin
- Viewer
- Cluster Admin

Roolit sisältävät yhden tai useampia käyttöoikeuksia.

## Mukautetut roolit
Organisaatio voi luoda custom role -määritelmiä, jotka yhdistävät tarvittavat oikeudet. Tämä mahdollistaa tarkan hallinnan eri tiimien ja palveluiden tarpeisiin.