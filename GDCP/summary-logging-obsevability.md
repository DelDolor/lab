# Lähteet:
2025-11-02
- https://cloud.google.com/distributed-cloud/hosted/docs/latest/gdch/platform/pa-user/obs-overview
- https://cloud.google.com/distributed-cloud/hosted/docs/latest/gdch/security
- https://cloud.google.com/distributed-cloud/hosted/docs/latest/gdch/resources/glossary

# Infrastruktuurialusta
## Observability platform - lokitus
    GDC air-gapped -ympäristön infrastruktuurikerros sisältää erillisen observability-alustan, jonka ylläpidosta vastaa infrastruktuurioperaattori (IO) teknologiatoimittajan ohjeiden mukaisesti. Alusta tarjoaa näkyvyyden GDC-järjestelmän tilaan, suorituskykyyn ja tietoturvaan. Observability-komponentit keräävät loki- ja metriikkatietoa koko alustan tasolla – mukaan lukien Kubernetes-nodet, bare metal -koneet, verkko- ja tallennuslaitteet sekä hallitut palvelut.

    Alustaan sisältyvä SIEM-järjestelmä (Splunk Enterprise) indeksoi ja analysoi turvallisuustietoa eri lähteistä, mahdollistaen uhkien havaitsemisen ja niihin reagoinnin. SIEM tukee erillisen SOC-valvomon toimintaa GDC-alustan tietoturvan valvonnassa.
  
### Haavoittuvuuden hallinta
    Haavoittuvuuksien hallinta GDC air-gapped -ympäristössä on monikerroksinen prosessi, joka kattaa sekä kehitysvaiheen että tuotantoympäristön. Ennen julkaisua suoritetaan useita haavoittuvuuksien tunnistusprosesseja esituotantoympäristössä, jotta CVE-haavoittuvuudet voidaan havaita ja korjata ajoissa.

    Tuotantoympäristössä IO vastaa säännöllisistä skannauksista, jotka kohdistuvat erityisesti klusterin nodeihin ja bare metal -palvelimiin – eli niihin resursseihin, joihin IO-roolilla on näkyvyys. Skannaukset toteutetaan Tenable Security Center -alustalla, joka hyödyntää Nessus-teknologiaa. Kaikki löydökset integroidaan organisaation Security Operations (SecOps) -prosesseihin uhkien hallintaa ja riskien seurantaa varten.

    ### Runtime-suojaus (EDR)
    IO vastaa myös alustan päätepisteiden suojaamisesta EDR-ratkaisujen avulla. Käytössä ovat Trellix HX, Windows Defender ja ClamAV, jotka muodostavat yhtenäisen tietoturva-alustan. Ne tarjoavat näkyvyyden klusterin nodeihin ja bare metal -palvelimiin, mahdollistaen uhkien havaitsemisen, analysoinnin ja niihin reagoinnin reaaliaikaisesti.

    EDR-järjestelmät tukevat haittaohjelmien tunnistamista, poikkeamien seurantaa ja uhkien torjuntaa, ja ne integroituvat osaksi organisaation SecOps-prosesseja.

########################################################
# Organisaatiokohtaisen pilvialustan lokitus ja valvonta
## Metriikkalokit
    Metriikkalokeja kerätään järjestelmän ja sovellusten suorituskyvyn, tilan ja resurssien käytön seuraamiseksi. Ne tarjoavat näkyvyyttä infrastruktuurin ylläpitäjille, sovelluskehittäjille ja tietoturvatiimeille, tukien kapasiteettisuunnittelua, vianmääritystä ja poikkeamien havaitsemista. Metriikkalokit ovat tyypillisesti valvottavan kohteen pistemäisiä lukuarvoja tiettynä ajanhetkenä. Niiden avulla myös NOC-valvomo voi seurata alustan ja palveluiden tilaa reaaliaikaisesti.

    Pilvialustan valvontaratkaisu perustuu Prometheus-teknologiaan ja on suunniteltu toimimaan air-gapped-ympäristössä. Se mahdollistaa metriikkatietojen keruun ja analysoinnin infrastruktuurista ja sovelluksista. Metriikkalokit ovat kvantitatiivisia mittauksia, jotka kuvaavat järjestelmän toimintaa ja resurssien käyttöä.

    Metriikkatietojen käyttöä voidaan rajoittaa Kubernetesin RBAC-mekanismilla, määrittämällä tarkasti, kenellä on oikeus tarkastella, kysellä tai hallita metriikkadatan resursseja kuten MonitoringTarget, MonitoringRule ja Dashboard.


### Keskeiset komponentit ja toimintamalli
    - MonitoringTarget: Määrittää, mistä sovelluksista ja komponenteista metriikat kerätään, sekä scraping-taajuuden ja endpointin.
    - Prometheus: Kerää ja tallentaa metriikkatiedot analysoitavaksi.
    - Cortex: Skaalautuva tallennus- ja kyselypalvelu Prometheus-metriikoille, tarjoaa HTTP-rajapinnan integraatioihin.
    - Grafana: Visualisointialusta dashboardien ja analyysin toteuttamiseen.

### Keruu ja hallinta
    Metriikat kerätään automaattisesti GDC:n ydinkomponenteista, ja käyttäjät voivat määrittää omia keruukohteita sovelluksilleen. Keruu tapahtuu HTTP-endpointin kautta Prometheus-muodossa (esim. OpenMetrics). Metriikkatiedot voidaan:

    - Labeloida: Lisätä tunnisteita kuten klusteri, palvelu tai versio.
    - Relabeloida: Ohjata metriikat toiseen projektiin (_gdch_project-label).
    - Salata: mTLS-salaus suojaa tiedonsiirron.

### Analysointi ja visualisointi
    Metriikkatietoja voidaan tarkastella:

    - Grafana-dashboardeilla: Mukautettavat näkymät esim. CPU-kuormasta, muistin käytöstä ja verkon aktiivisuudesta.
    - Cortex-rajapinnan kautta: Ohjelmallinen pääsy metriikkatietoihin curl-komennolla, tukien automatisointia.

### JJohdetut metriikat ja dashboardit
    - MonitoringRule-resurssilla voidaan laskea uusia metriikkoja olemassa olevista tiedoista, mikä nopeuttaa dashboardien ja hälytysten toimintaa.
    - Käyttäjät voivat luoda omia dashboardeja ConfigMap- ja Dashboard-resursseilla, jotka tukevat päätöksentekoa, vianmääritystä ja kapasiteettisuunnittelua.

########################################################
## Audit- ja operatiiviset lokit
    Audit- ja operatiivisia lokitietoja kerätään järjestelmän ja sovellusten toiminnan, turvallisuuden ja käyttäjätoimintojen seuraamiseksi. Audit-lokit dokumentoivat käyttäjien ja järjestelmänvalvojien toimet, erityisesti korotetuilla oikeuksilla tehdyt operaatiot, ja tukevat vaatimustenmukaisuutta sekä jäljitettävyyttä. Operatiiviset lokit kuvaavat järjestelmäkomponenttien ja sovellusten tilaa, virheitä ja tapahtumia, ja niitä hyödynnetään vianmäärityksessä, suorituskyvyn seurannassa ja operatiivisessa valvonnassa. Lokitiedon avulla SOC-valvomo voi seurata alustan tietoturvaa ja reagoida poikkeamiin.

    Pilvialustan lokitusratkaisu toimii air-gapped-ympäristössä ja perustuu Fluent Bit -agentteihin, jotka keräävät lokitiedot ja ohjaavat ne Loki-järjestelmään. Loki mahdollistaa lokien keskitetyn tallennuksen, suodatuksen ja kyselyn. Lokit voidaan rikastaa metatiedoilla, kuten projektitunnisteilla, klusterin nimillä ja aikaleimoilla, mikä tukee tarkkaa analyysiä ja suodatusta. Lokitietoja tarkastellaan Grafana-käyttöliittymän kautta, joka tarjoaa tehokkaat hakutoiminnot, visualisointipaneelit ja hälytykset.

    Lokit kerätään projektikohtaisesti (namespace) ja niistä voidaan laskea johdettuja metrikkoja esimerkiksi virheiden määrästä tai vasteajoista. Näitä voidaan hyödyntää hälytyksissä ja dashboardeilla LoggingRule-resurssien avulla.
    Lokitietojen käyttöä voidaan rajoittaa Kubernetesin RBAC-mekanismilla, määrittämällä tarkasti, kenellä on oikeus tarkastella, hakea tai hallita lokiresursseja kuten LoggingRule, LogSink ja Dashboard.

### Keskeiset komponentit
    - Fluent Bit: Kerää lokit sovelluksista, järjestelmäkomponenteista ja Kubernetesista.
    - Loki: Tallentaa ja mahdollistaa lokien kyselyn ja analysoinnin.
    - LogSink: Reitittää lokitiedot esimerkiksi paikalliseen tallennukseen tai ulkoiseen SIEM-järjestelmään.
    - Logging pipeline: Toteuttaa lokien keruun ja tallennuksen air-gapped-ympäristössä.
    - Grafana: Visualisoi ja analysoi lokitietoja dashboardien avulla.

### Kerättävät lokityypit
    Lokitusratkaisu tukee lokitietojen viennin ulkoiseen SIEM-järjestelmään, mahdollistaen keskitetyn tietoturva-analyysin myös eristetyssä ympäristössä. Integraatio toteutetaan SIEMOrgForwarder-resurssin avulla, joka määrittää yhteyden, autentikoinnin ja logityypin. Tokenit ja salaisuudet tallennetaan Kubernetesin Secret-resursseina. Yhteys SIEM-järjestelmään voidaan suojata TLS-salauksella, ja infrastruktuurioperaattori voi tarvittaessa avata yhteyden asiakasverkkoon.

