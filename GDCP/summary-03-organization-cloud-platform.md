# 5. Pilvialusta – organisaatiokohtainen tenantti
## 5.1 Resurssihierarkia: Organization – Project – Cluster
### 5.1.1 Organisaatio ja projektit
Edellisestä dokumentista tuttu IO-ryhmä provisioi asiakasorganisaatiolle muista asiakkaista eriytetyn pilvialustan. Googlen sanastossa tämä pilvialusta tai tenantti on nimeltään organisaatio.

Organisaatio toimii GDC AG:n resurssihierarkian ylimpänä tasona, jonka alle sijoittuvat projektit ja klusterit. Se tarjoaa fyysisen ja loogisen eristyksen muista organisaatioista. Organisaatiolla on oma virtuaalinen verkko, joka sisältää sisäisen IP-alueen (vain organisaation sisäinen liikenne) ja ulkoisen IP-alueen, jonka kautta sallittu liikenne voidaan ohjata eksplisiittisesti (default deny). Tämä verkkomalli tukee segmentointia ja liikenteen kontrollointia organisaation sisällä.

Projektit toimivat organisaation sisällä loogisina yksikköinä, jotka vastaavat Kubernetes-namespacen käsitettä. Ne tarjoavat erottelun eri sovellusympäristöille (esim. kehitys, testaus, tuotanto) ja mahdollistavat resurssien, IAM-politiikkojen ja verkkoasetusten hallinnan projektikohtaisesti. Projektit toimivat samalla verkon aliverkkoina (subnet), ja niiden välinen liikenne on oletuksena estetty. Tarvittaessa liikenne voidaan sallia tarkasti määritellyillä ProjectNetworkPolicy-säännöillä.

Namespace-sameness-ominaisuus takaa sen, että projektin resurssit ja politiikat toimivat yhtenäisesti eri klustereissa. Tämä mahdollistaa skaalautuvan ja hallitun ympäristön, jossa projektien elinkaari ja käyttö voidaan hallita keskitetysti.

### 5.1.2 Organisaation suunnittelu
Organisaatio (tenantti) on GDC AG -pilvialustan ensisijainen erottelu- ja luottamusraja. Yhteen organisaatioon kootaan vain projektit, jotka jakavat saman trust boundaryn, hallintamallin ja vaatimustason (esim. omistajuus, tietoturvaluokka). Yhdellä asiakasorganisaatiolla voi olla useita GDC-organisaatioita, jos erilliset luottamusrajat, sääntely tai tekniset vaatimukset sitä edellyttävät.

Suositus: sijoita samaan organisaatioon vain projektit, jotka täyttävät useimmat näistä kriteereistä:
- Yhteiset riippuvuudet ja integraatiot: työkuormat hyödyntävät samoja tietolähteitä, palveluja tai niitä on tarkoituksenmukaista integroida keskenään.
- Yhtenäinen hallinta: sama Platform Admin -tiimi vastaa projektien hallinnasta, IAM:stä ja verkkomallista.
- Jaettu infrastruktuuri: projektit voidaan toteuttaa saman alla olevan kapasiteetin (compute/storage/network) varaan ilman erillistä eristystarvetta.
- Budjetointi ja laskutus: projektit kuuluvat samaan budjettikokonaisuuteen ja talousseurantaan.
- Saatavuus- ja palautumistavoitteet: projekteilla on yhteneväiset SLO/SLI-, RPO/RTO- ja geoerotteluvaatimukset.

Mikäli jokin edellä mainituista poikkeaa merkittävästi (esim. eri turvallisuusluokka, erillinen omistaja tai jyrkempi segmentointi- ja pääsynhallintatarve), projekti kannattaa sijoittaa omaan organisaatioonsa. Tämä yksinkertaistaa IAM:ää, vähentää ristikkäisiä verkko- ja politiikkapoikkeuksia ja selkeyttää auditointia.

[tähän kuva jossa näkyy organisaatioden välinen fyysinen erottelu]

### 5.1.3 Projektien suunnittelu
Projektit muodostavat GDC Air-Gapped -alustassa organisaation sisäisen loogisen erottelutason, jonka avulla järjestelmät ja työkuormat eriytetään toisistaan verkko- ja käyttöoikeusmallin tasolla. Projektin suunnittelussa keskeistä on tunnistaa ne työkuormat, joilla on yhteneväiset käyttöoikeusvaatimukset, valvontatarpeet ja resurssiriippuvuudet. Yhteen projektiin tulisi koota vain ne sovellukset ja palvelut, joita on tarkoituksenmukaista hallita, valvoa ja auditoida yhtenä kokonaisuutena.

Käytännössä projekti vastaa Kubernetesin namespacea, joka on jaettu kaikkien organisaation klustereiden kesken. Tämä ei tarkoita, että kyseisen projektin podit ajettaisiin kaikissa klustereissa, vaan että namespace-nimi on organisaatiotasolla uniikki, mahdollistaen yhdenmukaisen hallinnan ja politiikat klusterien välillä.

Käyttöoikeudet määritellään rolebindingien avulla, joissa roolit sidotaan projektikohtaisesti käyttäjiin ja palvelutunnuksiin. Näin voidaan hallita tarkasti, kuka voi luoda, muokata tai poistaa projektin resursseja.

Verkollinen erottelu toteutetaan NetworkPolicy-säännöillä, joilla määritetään, mihin kohteisiin projektin resurssit voivat muodostaa yhteyksiä ja mitkä lähteet voivat tavoittaa ne. Oletuksena projektin sisäinen liikenne on sallittu, mutta projektien välinen liikenne on estetty. Liikennettä voidaan avata vain eksplisiittisesti määritellyillä säännöillä, mikä tukee vähimmän oikeuden periaatetta ja vahvistaa eristystä organisaation sisällä. 

### 5.1.4 Klusterit ja kapasiteettirajoitteet
Organisaation perustamisen yhteydessä infrastruktuurioperaattori luo infrastruktuuriklusterin, joka sisältää organisaation control plane -komponentit sekä Management API -palvelimen. Tämä klusteri hallinnoi palveluita ja kuormia, joita ei ajeta konttipohjaisesti.

Lisäksi organisaatiolla voi olla useita Kubernetes-klustereita (user cluster), jotka ovat GKE Enterprise -hallittuja ja sovitettu GDC AG -alustaan. Klusterit voivat olla joko yksittäisille projekteille dedikoituja tai jaettuja useiden projektien kesken. Klusterien määrää ja kapasiteettia rajoitetaan seuraavasti:
- Enintään 16 klusteria per organisaatio
- Klusterissa 3–42 nodea
- Maksimissaan 4620 podia per klusteri
- Yhdellä nodella enintään 110 podia

### 5.1.5 Projektien ja klusterien yhteiskäyttö
Projektien ja klusterien välinen suhde on joustava. Klusteri voi olla dedikoitu yhdelle projektille, mutta projekti voi myös ulottua useisiin klustereihin. Namespace-sameness takaa yhtenäisen hallinnan, mikä tukee ympäristöjen erottelua ja resurssien tehokasta käyttöä. Verkkoerottelu projektien välillä on oletuksena voimassa, ja liikenteen salliminen edellyttää eksplisiittistä määrittelyä.

### 5.1.6 Klusterin sisäinen rakenne
Kunkin klusterin control plane vastaa keskeisistä toiminnoista, kuten Kubernetesin API-palvelimen, schedulerin ja resurssien hallintakomponenttien toiminnasta. API-server toimii klusterin keskuskomponenttina, joka vastaanottaa tilatiedot ja ohjaa klusterin toimintaa niiden mukaisesti.

Node on virtuaalikone, joka sisältää container runtimen ja kubelet-agentin. Kubelet kommunikoi control planen kanssa ja vastaa konttien käynnistämisestä ja ajamisesta nodella. Lisäksi jokaisella nodella ajetaan järjestelmäkontteja DaemonSet-muodossa, jotka huolehtivat esimerkiksi lokien keruusta ja klusterin sisäisestä verkkoyhteydestä.

### 5.1.7 Suositeltu klusterimalli
- Erottele ympäristöt omiin klustereihin (dev, test, prod)
- Suosi muutamaa isoa klusteria usean pienen sijaan. Jokainen klusteri vaatii oman control planen joka vie kapasiteettia
- Tee klusterin sisään useita laajoja node pooleja usean pienen sijaan
- Uusia klustereita voidaan tehdä myös silloin jos on tarvetta ajaa eri versioita Kuberneteksesta

[kuva pd]

## 5.2 Platform-palvelut ja verkkomalli (julkaisu, segmentointi)
GDC Air-Gapped -alustan verkkomalli perustuu vahvaan segmentointiin ja “default deny” -periaatteeseen. Liikenne jaetaan north–south (palveluiden julkaisu ja ulkoinen pääsy) ja east–west (sisäinen liikenne projektien ja klusterien välillä) -suuntiin.

North–south: Julkinen tai sisäinen liikenne ohjataan L4/L7-kuormantasaajien kautta. Ingress-resurssit hallitsevat julkaisua, ja niihin liitetään ProjectNetworkPolicy-säännöt, jotka rajaavat sallitut lähde- ja kohdeverkot.

East–west: Projektien ja klusterien välistä liikennettä hallitaan NetworkPolicy- ja ProjectNetworkPolicy-resursseilla. Niillä voidaan rajata yhteydet sovellus- ja porttitasolla, mikä mahdollistaa mikrosegmentoinnin ja liikenteen valvonnan.

Kuormanjako tukee sekä L4- että L7-tason palveluita, ja se voidaan toteuttaa zonaalisesti tai globaalisti usean zonen yli. Verkkoerottelu perustuu projektikohtaisiin AccessBoundary-määrittelyihin, jotka estävät luvattoman liikenteen projektien ja klustereiden välillä.

## 5.3 Työkuormat: VM:t ja Kubernetes
Asiakasorganisaatio voi rakentaa projekteihin VM-pohjaisia resursseja ja kontti-pohjaisia resursseja. VM-pohjainen työkuorma elää VM:n sisässä ja konttipohjainen kubernetes klusterissa. Tämä tuottaa samalla loogisen erottelun näiden kahden työkuorman välillä. 
[kuva aa]

## 5.3.1 VM
GDC alusta sisältää Ubuntu ja Rocky linux imaget ja tukee RHEL, SUSE, Windows Server 2019 ja Windows 10 OS imageja. IO voi tehdä ja julkaista organisaatioiden käyttöön räätälöityjä imageja. GDC alusta sisältää useita vaihtoehtoja virtualikoneen kooksi, jolloin tarvittava CPU, RAM ja GPU voidaan valita tarkoitukseen sopivaksi. Virtuaalikoneita ajetaan organisaation infrastrukruuriklusterissa jossa on myös organisaation control ja data plane sekä managed palveluita.

## 5.3.2 Konttipohjaiset kuormat
Containereita ajetaan podeissa, jotka kuuluvat namespaceen (projekti) ja näitä ajetaan Kubernetes klusterissa. Organisaatiolla voi olla useita kubernetes klustereita joka mahdollistaa järjestelmien tai ympäristöjen (dev, test, prod) eriyttämisen. Klusterissa voi olla useita node-pooleja ja jokaisen podin osalta määritetään missä poolissa sitä ajetaan. Tämä mahdollistaa sen, että konttia voidaan tarpeen mukaan ajaa poolissa jossa on esim. muisti tai GPU optimoidut nodet. Klusterit ovat aina zonaaleja eli elävät yksittäisessä GDC instanssissa. Projekti, eli kubernetes namespace, on kuitenkin globaali ja mahdollistaa järjestelmän hajauttamisen useaan klusteriin (availability zone ja/tai regioona).

[kuva ab]

## 5.3.3 Varmuuskopionti ja palauttaminen
GDC alustan varmistuspalvelu tukee Kubernetes (user) klusterin varmistusta (Deployments, StatefulSets, Secrets, ConfigMaps), virtuaalipalvelimia (levykuvat ja levyt) sekä Harbor-rekistereitä, joiden varmistus toteutetaan erillisenä tehtävänä HarborInstanceBackup-resurssien avulla.

Varmistuspoliitikoilla voidaan automatisoida ja aikatauluttaa varmistukset. Kaikki varmistettava materiaali salataan HSM-pohjaisella KMS-avaimella ja tallennetaan S3-yhteensopivaan Object Storageen, joka voi sijaita paikallisesti tai toisella zonella.

GDC tukee valmiita palautussuunnitelmia, ja esimerkiksi VM:n osalta palautus voidaan kohdistaa yksittäisiin levyihin. Harbor-instanssin palautus edellyttää koko instanssin palauttamista, ei yksittäisten repo- tai kuvatasojen palautusta. 

## 5.4 IAM ja pääsynhallinta (IdP, RBAC, palvelutunnukset)
IAM-ratkaisu perustuu alustan natiiviin Google Distributed Cloud (GDC) IAM-palveluun, joka hallinnoi käyttöoikeuksia, rooleja ja palvelutunnuksia. Tämän lisäksi toteutetaan identiteetin tarjoaja (IdP), joka vastaa käyttäjien autentikoinnista. IdP integroituu GDC:hen joko OpenID Connect (OIDC)- tai SAML-protokollan avulla.

GDC voidaan yhdistää organisaation olemassa olevaan identiteetinhallintajärjestelmään, jolloin käyttäjät voivat kirjautua omilla organisaatiotunnuksillaan. Mikäli IdP halutaan eristää samaan air-gapped alustaan ilman ulkoisia riippuvuuksia, tulee sinne toteuttaa oma IdP-ratkaisu. Kaksi esimerkki vaihtoehtoa tähän ovat:

- Active Directory (AD)
Jos projektiin toteutetaan AD esimerkiksi päätelaitehallinnan tai muun infrastruktuurin tarpeisiin, sen hyödyntäminen IdP:nä on järkevää. AD voidaan integroida GDC:hen SAML- tai OIDC-välikerroksen kautta.

- Keycloak
Jos AD:ta ei toteuteta, Keycloak on kevyt ja helposti hallittava vaihtoehto pelkästään GDC:n IAM-tarpeisiin. Keycloak on avoimen lähdekoodin IAM-ratkaisu, joka tukee OIDC:ta ja voidaan asentaa täysin paikallisesti. Se tarjoaa SSO-toiminnallisuudet, roolipohjaisen pääsynhallinnan ja graafisen hallintakäyttöliittymän.

PIIRRÄ KUVA OIDC FLOWsta

### 5.4.1 Käyttäjien kirjautuminen
Käyttäjät voivat kirjautua GDC-palveluihin seuraavilla tavoilla:
- GDC Console (selainpohjainen käyttöliittymä)
- gdcloud CLI
- kubectl CLI (vaatii kubeconfig-tiedoston luomisen ennen käyttöä)

### 5.4.2 Palvelutunnukset ja salaisuudet
Palvelutunnukset (service accounts) mahdollistavat sovellusten ja automaation pääsyn GDC-resursseihin. Jokaiselle palvelutunnukselle voidaan luoda avaimet (service account keys), jotka tulee säilyttää turvallisesti. GDC tarjoaa mekanismit avainten hallintaan ja suojaamiseen, mukaan lukien:

- Salaus KMS:n avulla: Avaimet voidaan salata GDC:n sisäisellä Key Management Service (KMS)-palvelulla.
- HSM-integraatio: KMS voi hyödyntää Hardware Security Module (HSM)-ratkaisuja, jotka tarjoavat FIPS 140-2 Level 3 -sertifioidun laitteistopohjaisen avainten suojauksen.
- Avainten hallinta: KMS tukee avainten luontia, rotaatiota, tuontia ja vientiä sekä kryptografisia operaatioita (salaus, allekirjoitus).
- RBAC-pohjainen käyttöoikeus: Vain valtuutetut käyttäjät voivat luoda, käyttää tai kierrättää avaimia.

### 5.4.3 RBAC ja autorisointi
GDC käyttää Role-Based Access Control (RBAC)-mallia, jossa käyttöoikeudet määritellään:
- Laajuuden mukaan: organisaatio, projekti/namespace
- Verbeillä: esim. get, list, create, delete
Tällöin voidaan määrittää tarkasti mitä kukin saa tehdä mihinkin kohteeseen.

### 5.4.4 Valmiit roolit
GDC tarjoaa esivalmisteltuja rooleja, kuten:
- Organization Admin
- Project Admin
- Viewer
- Cluster Admin

Roolit sisältävät yhden tai useampia käyttöoikeuksia.

### 5.4.5 Mukautetut roolit
Organisaatio voi luoda custom role -määritelmiä, jotka yhdistävät tarvittavat oikeudet. Tämä mahdollistaa tarkan hallinnan eri tiimien ja palveluiden tarpeisiin.

## 5.5 Roolit: Platform Admin & Application Admin
Kuten alussa todettiin, on platform tasolla kaksi käyttäjäryhmää **Platform admin** ja **Application admin**.

### 5.5.1 Platform Admin 
Platform Administrator -ryhmä vastaa GDC Air-Gapped -ympäristön (organisaation oman tenantin) hallinnasta ja operoinnista käyttöönoton jälkeen. Ryhmä toimii sekä organisaatio- että projektitasolla ja vastaa koko alustan rakenteellisesta ja toiminnallisesta eheydestä. Sen keskeinen tehtävä on varmistaa, että resurssit, verkot ja hallintapolitiikat tukevat sovellusten turvallista ja tehokasta käyttöä useissa zoneissa ilman ulkoisia riippuvuuksia.

Ryhmä suunnittelee ja ylläpitää resurssihierarkian organisaation rakenteen mukaisesti, hallitsee käyttöoikeudet ja verkkoerottelun, määrittää kiintiöt ja politiikat sekä huolehtii infrastruktuurin konfiguroinnista ja valvonnasta. Vastuualueisiin kuuluu myös tietoturvatoimien toteutus air-gapped-ympäristössä, jatkuva suorituskyvyn ja luotettavuuden seuranta sekä DevSecOps-mallia tukevien automaatio- ja julkaisuputkien rakentaminen.

Platform Administrator -ryhmä koostuu tyypillisesti IT- ja verkkoasiantuntijoista, tietokanta- ja tietoturva-asiantuntijoista sekä käyttöoikeus- ja compliance-vastaavista, jotka yhdessä muodostavat alustan teknisen hallinnan ja turvallisuuden ydinryhmän.

### 5.5.2 Application operator 
Application Operator -ryhmä vastaa projektitasolla sovellusten ja työkuormien elinkaaren hallinnasta GDC Air-Gapped -ympäristössä. Sen tehtävänä on varmistaa, että sovellukset ja palvelut toimitetaan luotettavasti, tehokkaasti ja organisaation turvallisuusvaatimusten mukaisesti täysin eristetyssä ympäristössä.

Ryhmä vastaa sovellusten kehittämisestä, testauksesta ja käyttöönotosta air-gapped-olosuhteissa, palveluiden ja sovellusten suorituskyvyn ja käytettävyyden valvonnasta sekä häiriötilanteiden analysoinnista ja korjaamisesta. Lisäksi se optimoi sovellusten toimintaa ja resurssien käyttöä GDC:n sisällä, hyödyntäen klusteri- ja projektikohtaisia konfiguraatioita.

Application Operator -ryhmään kuuluu tyypillisesti sovelluskehittäjiä, DevOps-asiantuntijoita, data- ja analytiikkaosaajia sekä koneoppimisen (ML) ja tekoälyn parissa työskenteleviä asiantuntijoita, jotka yhdessä vastaavat sovellusten elinkaaren hallinnasta ja tuotantoympäristön jatkuvasta parantamisesta.


## 5.6 Lokitus, auditointi ja monitorointi (asiakasnäkymä)
Pilvialustan lokitus ja valvonta perustuu laajasti käytettyihin open source projekteihin kuten Loki, Grafana ja Prometheus.

### 5.6.1 Metriikkalokit
Metriikkalokeja kerätään järjestelmän ja sovellusten suorituskyvyn, tilan ja resurssien käytön seuraamiseksi. Ne tarjoavat näkyvyyttä infrastruktuurin ylläpitäjille, sovelluskehittäjille ja tietoturvatiimeille, tukien kapasiteettisuunnittelua, vianmääritystä ja poikkeamien havaitsemista. Metriikkalokit ovat tyypillisesti valvottavan kohteen pistemäisiä lukuarvoja tiettynä ajanhetkenä. Niiden avulla myös NOC-valvomo voi seurata alustan ja palveluiden tilaa reaaliaikaisesti.

Pilvialustan valvontaratkaisu perustuu Prometheus-teknologiaan ja on suunniteltu toimimaan air-gapped-ympäristössä. Se mahdollistaa metriikkatietojen keruun ja analysoinnin infrastruktuurista ja sovelluksista. Metriikkalokit ovat kvantitatiivisia mittauksia, jotka kuvaavat järjestelmän toimintaa ja resurssien käyttöä.

Metriikkatietojen käyttöä voidaan rajoittaa Kubernetesin RBAC-mekanismilla, määrittämällä tarkasti, kenellä on oikeus tarkastella, kysellä tai hallita metriikkadatan resursseja kuten MonitoringTarget, MonitoringRule ja Dashboard.


#### 5.6.1.1 Keskeiset komponentit ja toimintamalli
- MonitoringTarget: Määrittää, mistä sovelluksista ja komponenteista metriikat kerätään, sekä scraping-taajuuden ja endpointin.
- Prometheus: Kerää ja tallentaa metriikkatiedot analysoitavaksi.
- Cortex: Skaalautuva tallennus- ja kyselypalvelu Prometheus-metriikoille, tarjoaa HTTP-rajapinnan integraatioihin.
- Grafana: Visualisointialusta dashboardien ja analyysin toteuttamiseen.

#### 5.6.1.2 Keruu ja hallinta
Metriikat kerätään automaattisesti GDC:n ydinkomponenteista, ja käyttäjät voivat määrittää omia keruukohteita sovelluksilleen. Keruu tapahtuu HTTP-endpointin kautta Prometheus-muodossa (esim. OpenMetrics). Metriikkatiedot voidaan:

- Labeloida: Lisätä tunnisteita kuten klusteri, palvelu tai versio.
- Relabeloida: Ohjata metriikat toiseen projektiin (_gdch_project-label).
- Salata: mTLS-salaus suojaa tiedonsiirron.

#### 5.6.1.4 Johdetut metriikat ja dashboardit
- MonitoringRule-resurssilla voidaan laskea uusia metriikkoja olemassa olevista tiedoista, mikä nopeuttaa dashboardien ja hälytysten toimintaa.
- Käyttäjät voivat luoda omia dashboardeja ConfigMap- ja Dashboard-resursseilla, jotka tukevat päätöksentekoa, vianmääritystä ja kapasiteettisuunnittelua.

### 5.6.2 Audit- ja operatiiviset lokit
Audit- ja operatiivisia lokitietoja kerätään järjestelmän ja sovellusten toiminnan, turvallisuuden ja käyttäjätoimintojen seuraamiseksi. Audit-lokit dokumentoivat käyttäjien ja järjestelmänvalvojien toimet, erityisesti korotetuilla oikeuksilla tehdyt operaatiot, ja tukevat vaatimustenmukaisuutta sekä jäljitettävyyttä. Operatiiviset lokit kuvaavat järjestelmäkomponenttien ja sovellusten tilaa, virheitä ja tapahtumia, ja niitä hyödynnetään vianmäärityksessä, suorituskyvyn seurannassa ja operatiivisessa valvonnassa. Lokitiedon avulla SOC-valvomo voi seurata alustan tietoturvaa ja reagoida poikkeamiin.

Pilvialustan lokitusratkaisu toimii air-gapped-ympäristössä ja perustuu Fluent Bit -agentteihin, jotka keräävät lokitiedot ja ohjaavat ne Loki-järjestelmään. Loki mahdollistaa lokien keskitetyn tallennuksen, suodatuksen ja kyselyn. Lokit voidaan rikastaa metatiedoilla, kuten projektitunnisteilla, klusterin nimillä ja aikaleimoilla, mikä tukee tarkkaa analyysiä ja suodatusta. Lokitietoja tarkastellaan Grafana-käyttöliittymän kautta, joka tarjoaa tehokkaat hakutoiminnot, visualisointipaneelit ja hälytykset.

Lokit kerätään projektikohtaisesti (namespace) ja niistä voidaan laskea johdettuja metrikkoja esimerkiksi virheiden määrästä tai vasteajoista. Näitä voidaan hyödyntää hälytyksissä ja dashboardeilla LoggingRule-resurssien avulla.
Lokitietojen käyttöä voidaan rajoittaa Kubernetesin RBAC-mekanismilla, määrittämällä tarkasti, kenellä on oikeus tarkastella, hakea tai hallita lokiresursseja kuten LoggingRule, LogSink ja Dashboard.

#### 5.6.2.1 Keskeiset komponentit
- Fluent Bit: Kerää lokit sovelluksista, järjestelmäkomponenteista ja Kubernetesista.
- Loki: Tallentaa ja mahdollistaa lokien kyselyn ja analysoinnin.
- LogSink: Reitittää lokitiedot esimerkiksi paikalliseen tallennukseen tai ulkoiseen SIEM-järjestelmään.
- Logging pipeline: Toteuttaa lokien keruun ja tallennuksen air-gapped-ympäristössä.
- Grafana: Visualisoi ja analysoi lokitietoja dashboardien avulla.

#### 5.6.2.2 Kerättävät lokityypit
Lokitusratkaisu tukee lokitietojen viennin ulkoiseen SIEM-järjestelmään, mahdollistaen keskitetyn tietoturva-analyysin myös eristetyssä ympäristössä. Integraatio toteutetaan SIEMOrgForwarder-resurssin avulla, joka määrittää yhteyden, autentikoinnin ja logityypin. Tokenit ja salaisuudet tallennetaan Kubernetesin Secret-resursseina. Yhteys SIEM-järjestelmään voidaan suojata TLS-salauksella, ja infrastruktuurioperaattori voi tarvittaessa avata yhteyden asiakasverkkoon.

#### 5.6.3 Analysointi ja visualisointi
Metriikkatietoja voidaan tarkastella:

- Grafana-dashboardeilla: Mukautettavat näkymät esim. CPU-kuormasta, muistin käytöstä ja verkon aktiivisuudesta.
- Cortex-rajapinnan kautta: Ohjelmallinen pääsy metriikkatietoihin curl-komennolla, tukien automatisointia.

Audit- ja operatiivisten lokien visualisointia voidaan tehdä Grafanan kautta. Grafana mahdollistaa lokihaut ja lokipohjaiset hälytykset. Laajempaa tietoturvavalvontaa varten lokitiedot kannattaa viedä erilliseen SIEM-järjestelmään.

## 5.7 Tietoturva-arkkitehtuuri
GDC Air-Gapped -ympäristön tietoturva-arkkitehtuuri perustuu eristämiseen, vähimpien oikeuksien periaatteeseen ja automaatioon. Työkuormat, käyttäjät ja hallintakomponentit on erotettu loogisesti, ja kaikki käyttöoikeudet hallitaan RBAC- ja IAM-mekanismeilla.

Tietoturva on sisäänrakennettu osaksi infrastruktuurin ja sovellusten elinkaarta. Ympäristö hyödyntää Infrastructure-as-Code (IaC)- ja DevSecOps-periaatteita, joilla varmistetaan, että kaikki resurssit – kuten klusterit, verkot, palvelut ja käyttöoikeudet – määritellään koodina, versionhallitaan ja auditoidaan. Tämä mahdollistaa toistettavan, valvottavan ja vaatimustenmukaisen käyttöönoton.

Kubernetes-tasolla tietoturvavalvonta toteutetaan OPA Gatekeeper -politiikkamoottorilla, joka mahdollistaa Policy-as-Code -periaatteella määritettyjen sääntöjen enforce-valvonnan. Gatekeeperin avulla voidaan hallita resurssien käyttöä, konttien tyyppiä, verkko- ja tallennuspolitiikkoja sekä metatietojen yhdenmukaisuutta.

Kaikki konttipohjaiset työkuormat skannataan ennen käyttöönottoa haittaohjelmien, haavoittuvuuksien ja konfiguraatiovirheiden varalta. Skannaus integroidaan CI/CD-putkeen, ja hyväksyntä tapahtuu automaattisesti ennen julkaisuja. Konttikuvat ovat aina peräisin luotetusta, air-gapped-ympäristössä toimivasta rekisteristä.

Virtuaalikoneet (VM) toimitetaan ja kovennetaan (hardening) organisaation tietoturvapolitiikan mukaisesti ennen käyttöönottoa. Kovennus sisältää tarpeettomien palveluiden poistamisen, käyttöoikeuksien rajoittamisen, auditoinnin ja salauksen käyttöönoton.

### 5.7.1 Policy-as-Code, Compliance-as-Code ja CSPM
GDC Air-Gapped -ympäristössä turvallisuus- ja vaatimustenmukaisuussäännöt toteutetaan ohjelmallisesti osana infrastruktuurin ja sovellusten elinkaarta.

Policy-as-Code tarkoittaa, että organisaation turvallisuus- ja hallintavaatimukset kuvataan eksplisiittisinä politiikkoina (esim. YAML/JSON-säännöstöinä), jotka otetaan enforce-tilassa käyttöön itse ympäristössä. Näin politiikat eivät ole vain dokumentaatiota, vaan suoraan käytössä olevia rajoitteita, jotka määrittävät esimerkiksi resurssien käyttöoikeudet, verkon erottelusäännöt ja konttikuvien hyväksynnän. Politiikat toteutetaan esim. OPA Gatekeeper-moottorilla, ja niiden toteutuminen muodostaa perustan myös jatkuvalle compliance-seurannalle.

Compliance-as-Code puolestaan varmistaa, että nämä samat politiikat ja standardit (esim. ISO 27001, NIST SP 800-53, SOC 2) täyttyvät jo ennen käyttöönottoa. CI/CD-putkessa suoritetaan automaattiset tarkistukset, jotka estävät commitin tai deploymentin etenemisen, jos konfiguraatio ei vastaa hyväksyttyjä politiikoita. Näin tietoturva- ja sääntelyvaatimukset toteutuvat “shift-left”-periaatteella, ennen kuin resursseja tai sovelluksia julkaistaan.

CSPM (Cloud Security Posture Management) toimii taustakerroksena, joka analysoi IaC-malleja, konfiguraatioita ja politiikkatoteumia kokonaisuutena. Se tunnistaa poikkeamat, seuraa muutoksia ja mahdollistaa jatkuvan riskienhallinnan air-gapped-ympäristössä. On käytännössä realiaikainen raportti ympäristön vaatimustenmukaisuuteen ja tietoturvan tilaan.

### 5.7.2 Salaus, avainhallinta, PKI
GDC Air-Gapped -ympäristön salaus- ja avainhallintamalli perustuu monikerroksiseen suojausperiaatteeseen, jossa kaikki data on oletusarvoisesti salattu sekä levossa (at rest) että siirrossa (in transit). Salausmekanismit ovat erillisiä mutta toisiaan täydentäviä infrastruktuuri-, verkko- ja sovellustasoilla.

#### 5.7.2.1 HSM ja KMS
Avainhallinta toteutetaan GDC:n sisäisellä Key Management Service (KMS) -ratkaisulla, joka tarjoaa keskitetyn hallinnan, rotaation ja käyttöoikeusvalvonnan. KMS integroituu Hardware Security Module (HSM) -laitteisiin, jotka täyttävät FIPS 140-2/3 -vaatimukset ja varmistavat avainten laitteistopohjaisen suojauksen. Avainten käyttö, luonti ja tuonti tapahtuvat air-gapped-prosessissa, eikä avainmateriaalia koskaan viedä ulos ympäristöstä.

Kaikki GDC-komponentit – mukaan lukien tallennus, metatiedot ja lokit – hyödyntävät vahvoja salaustoteutuksia, kuten AES-256 ja TLS 1.3. Lisäksi asiakasorganisaatiot voivat määrittää omat asiakasavaimet (Customer-Managed Keys, CMEK), mikä mahdollistaa avainten hallinnan täyden suvereniteetin.

Organisaatiot voivat siis käyttää joko GDC:n hallinnoimia tai omia (CMEK) avaimiaan; molemmat hallitaan KMS:n kautta, mutta CMEK:t säilyttävät avainmateriaalin täyden hallinnan asiakkaalla.

#### 5.7.2.2 PKI
GDC Air-Gapped sisältää sisäänrakennetun PKI-arkkitehtuurin, joka mahdollistaa sertifikaattien hallinnan ja turvallisen TLS-viestinnän täysin eristetyssä ympäristössä. Ratkaisu tukee useita käyttömalleja: Fully-Managed, Bring Your Own Certificates, BYO with ACME sekä BYO with SubCA.

Sertifikaatteja hallitaan Kubernetes-resursseina (Certificate, CertificateIssuer, CertificateRequest), ja niiden luonti, allekirjoitus ja jakelu tapahtuu GDC:n sisäisen PKI Security API:n kautta (pki.security.gdc.goog/v1). Myönnetyt sertifikaatit tallennetaan Kubernetes Secrets -resursseihin, joita sovellukset voivat hyödyntää suoraan esimerkiksi ingress-palveluissa.

PKI-infrastruktuuri tukee Hardware Security Module (HSM) -laitteita avainten suojaamiseen ja toimii kokonaan air-gapped-prosessina ilman ulkoisia riippuvuuksia. Sertifikaattien elinkaari (luonti, uusiminen, rotaatio ja peruutus) on hallittavissa API-rajapinnan kautta, ja kaikki tapahtumat auditoidaan GDC:n sisäisessä loki-infrastruktuurissa.

### 5.7.3 DevSecOps & CI/CD air-gapped-ympäristössä
GDC Air-Gapped -alusta tukee täysimittaisesti DevSecOps-mallia, jossa kehitys, tietoturva ja operointi yhdistyvät yhdeksi todennettavaksi prosessiksi. Kaikki CI/CD-toiminnot tapahtuvat eristetyssä verkossa ilman ulkoisia riippuvuuksia, ja tietoturva sisältyy automaattisesti kaikkiin vaiheisiin.

Infrastruktuuria hallitaan API-rajapintojen kautta käyttäen Terraformia, kubectl- ja gdcloud CLI -työkaluja. CI/CD voidaan toteuttaa GitLab Marketplace -ratkaisulla, joka toimii koodivarastona, pipeline-moottorina ja tehtävienhallintana.

Rakennus- ja julkaisuprosessit hyödyntävät ennakkoon hyväksyttyjä ja allekirjoitettuja base imageja, joiden eheys varmistetaan KMS/HSM-allekirjoituksilla. Pipelinessa suoritetaan automaattisesti haavoittuvuusskannaus, SBOM-generointi ja Policy-as-Code-validointi, jotka estävät virheellisten muutosten etenemisen tuotantoon.

Julkaisuvaiheessa resurssit viedään hallittuihin Kubernetes-klustereihin tai virtuaalikoneisiin roolipohjaisesti ja auditoidusti. Kaikki pipeline-tapahtumat ovat jäljitettävissä ja kytkeytyvät Compliance-as-Code -raportointiin.

## 5.8 Tietoturvavalvonta ja SOC-integraatiot
GDC Air-Gapped -alusta sisältää sisäisen Logging Platform -ratkaisun (Loki, Prometheus, Grafana), jota voidaan hyödyntää tietoturvavalvontaan ja poikkeamien havaitsemiseen. Lokit kattavat infrastruktuurin, klusterit, sovellukset ja käyttäjätoiminnan, ja ne kerätään Fluent Bit -agenttien avulla keskitetysti.

Laajempaa näkyvyyttä varten ympäristöön voidaan rakentaa erillinen SOC-alusta, joka kokoaa ja analysoi tiedon useista lähteistä. Tämä sisältää:

haavoittuvuusskannerien (esim. Nessus, Trivy) tulokset

runtime-suojauksen ja EDR-agenttien havainnot

Control Plane -API-lokit ja audit-lokit

Managed-palveluiden tuottamat tietoturva- ja käyttölogit

SOC-alusta toimii tiedon korrelaatiokerroksena, joka yhdistää eri lähteiden tapahtumat kokonaisvaltaiseksi uhkakuvaksi. Tietoa rikastetaan kontekstilla, kuten projektilla, klusterilla ja käyttäjätunnisteilla, mikä tukee nopeaa analyysia ja priorisointia.

Valvontaa tukevat automatisoidut hälytykset ja dashboardit, jotka seuraavat järjestelmän eheyteen, poikkeaviin kirjautumisiin, epäonnistuneisiin Policy-as-Code -tarkistuksiin ja CI/CD-putkien poikkeamiin liittyviä tapahtumia.

Yhdistettynä tämä muodostaa kokonaisvaltaisen valvontamallin, jossa infrastruktuurin, sovellusten ja kehitysprosessien tietoturva nähdään yhtenä ekosysteeminä — mahdollistaen sekä reaaliaikaisen reagoinnin että jatkuvan parantamisen.