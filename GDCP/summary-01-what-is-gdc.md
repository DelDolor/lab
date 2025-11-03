Tämä dokumentti on osa tiivistelmä Google Distributed Cloud air-gapped pilvialustasta. Tiivistelmä perustuu Googlen julkaisemaan julkiseen dokumentaatioon. https://cloud.google.com/distributed-cloud/hosted/docs/latest/gdch/overview

# 1. Mikä on Google Distributed Cloud Air-Gapped?
## 1.1 Google Distributed Cloud Air-Gapped – tekninen arkkitehtuuri ja operatiivinen malli
Google Distributed Cloud Air-Gapped (GDC AG) on ratkaisu, joka mahdollistaa pilviteknologioiden hyödyntämisen täysin eristetyssä ympäristössä. Alusta on suunniteltu organisaatioille, joilla on tiukat tietoturva- ja sääntelyvaatimukset, kuten julkishallinto, puolustussektori ja kriittinen infrastruktuuri. GDC AG toimii ilman yhteyttä julkiseen internetiin tai Google Cloudiin, mikä eliminoi ulkoiset riippuvuudet ja mahdollistaa suvereenin hallinnan.

Alustan tekninen perusta rakentuu Kubernetesin ympärille, ja se hyödyntää GKE Enterprise -komponentteja. Hallintatoiminnot, kuten control plane ja API-server, sijaitsevat organisaation sisäisessä verkossa. Tämä mahdollistaa sovellusten ja palveluiden ajamisen paikallisesti, ilman ulkoista ohjausta tai päivitysriippuvuuksia. GDC AG tukee myös valikoituja Vertex AI -palveluita, kuten Gemini, OCR ja puheentunnistus, jotka voidaan ajaa eristetyssä ympäristössä ilman yhteyttä julkisiin pilvipalveluihin, mikä mahdollistaa AI-toimintojen hyödyntämisen täysin paikallisesti. AI-palveluiden käyttö edellyttää erillisen GPU kapasiteetin hankinnan ja sen liittämisen osaksi klusteria.

## 1.2 Sovellusten ja palveluiden käyttö alustalla
GDC Air-Gapped tarjoaa asiakasorganisaatiolle kaksi pääasiallista tapaa hyödyntää alustaa sovellusten ajamiseen: virtuaalikoneet (VM) ja Kubernetes-kontit. Virtuaalikoneet soveltuvat erityisesti perinteisiin työkuormiin, kuten monoliittisiin sovelluksiin tai järjestelmiin, joita ei ole konttimuotoistettu. Kubernetes-kontit puolestaan tukevat mikropalveluarkkitehtuuria ja mahdollistavat skaalautuvan, automatisoidun sovellusajon, joka hyödyntää alustan orkestrointikyvykkyyksiä.

Riippumatta käytetystä ajotavasta, sovellukset voidaan integroida GDC AG -alustan tarjoamiin sisäisiin palveluihin. Näihin kuuluvat muun muassa salausavainten hallinta (KMS), kuormantasaus, tietokantapalvelut, sisäinen DNS sekä auditointipalvelut. Palvelut ovat saatavilla organisaation sisäisessä verkossa, ja niiden käyttö tapahtuu hallitusti ilman ulkoisia riippuvuuksia.

Alustan tarjoamat PaaS-palvelut tukevat sovellusten turvallista ja tehokasta operointia. Esimerkiksi KMS mahdollistaa salausavainten hallinnan paikallisesti, ja kuormantasausratkaisut tukevat sovellusten saatavuutta ja skaalautuvuutta. Sovellukset voivat hyödyntää näitä palveluita joko suoraan tai välityspalveluiden kautta, riippuen käytetystä arkkitehtuurista ja verkkomallista.

Lisäksi GDC AG -ympäristössä on käytettävissä sisäinen Marketplace, josta asiakasorganisaatio voi ottaa käyttöön valmiita, luotettavasti paketoituja komponentteja. Marketplace tarjoaa esimerkiksi yleisesti käytettyjä tietokantaratkaisuja kuten Redis, MongoDB ja muita sovelluspalveluita, jotka on sovitettu toimimaan air-gapped-ympäristössä. Komponentit ovat valmiiksi skannattuja ja yhteensopivia alustan hallintamallien kanssa, mikä nopeuttaa käyttöönottoa ja vähentää konfigurointitarvetta. Marketplace toimii osana organisaation sisäistä ekosysteemiä, eikä vaadi yhteyttä ulkoisiin lähteisiin. Marketplace sisältö on BYOL tai opensource mallin mukaista.

[tähän se nelikerros kuva]

# 2. Kokonaisarkkitehtuuri
Google Distributed Cloud Air-Gapped (GDC-AG) -ympäristössä infrastruktuuri on jaettu kolmeen hierarkkiseen tasoon: zone, regioona ja universe.

## 2.1 Zone
Zone on GDC Air-Gapped -arkkitehtuurin perusyksikkö ja samalla itsenäinen fault- ja disaster-domain. Jokainen GDC-instanssi on täysimittainen zone (saatavuusalue) , joka sisältää koko palvelualustan – laitteiston, infrastruktuurin, palvelukerroksen ja hallitut palvelut – ja toimii täysin ilman yhteyttä ulkoisiin verkkoihin tai Google Cloudiin. GDC instanssi on hajautettu zonen sisällä useille fyysisille laitteille.

## 2.2 Regioona
Kun samalla maantieteellisellä alueella olevia zoneja (alle 50km toisiinsa) liitetään yhteen, puhutaan regioonasta. Regioonia käytetään ensisijaisesti organisoimaan zonet maantieteellisesti ja latenssivaatimusten mukaisesti, ei tarjoamaan omia aluekohtaisia palveluita. GDC-AG:ssä regioona ei siis sisällä omia “region-scoped” palveluita, vaan toimii lähinnä hallinnollisena ja topologisena rakenteena.

## 2.3 GDC Universe
GDC sanastossa universe on korkein looginen kokonaisuus, joka kokoaa yhteen zonet ja regioonat. Pienimmillään universe voi olla yhden zonen laajuinen, mutta suosituksena on vähintään kolme zonea (yhdellä tai useammalla regioonalla), jolloin saavutetaan korkea käytettävyys ja vikasietoisuus jossa yhden zonen vika ei pysäytä kokonaisuutta. Universe jakaa yhteisen control planen ja sisäisen verkon, joiden kautta hallinta, resurssien koordinointi ja tietoliikenne tapahtuvat. Universe sisältää globaalit palvelut jotka on käytettävissä jokaisessa regioonassa ja zonessa. Näitä ovat: DNS, Kuormanjako, Resource manager, IAM.

Mikäli ympäristössä on vain yksi zone, se muodostaa samalla regionaan ja universen. 

Universumiin voi kuulua enintään kuusi zonea ja yksi tai kaksi toimintakeskusta (operation center, hallintapiste). Jos zoneja on vain kaksi, automaattinen palautus ei ole käytettävissä, vaan toipuminen on tehtävä manuaalisesti. Kolmen tai useamman zonen malli kykenee palautumaan automaatisesti.

[kuva rz]

## 2.4 GLobaalit ja Zonaalit palvelut
Google Distributed Cloud Air-Gapped -ympäristössä resurssit ja hallintakomponentit jakautuvat kahteen pääluokkaan: globaaleihin ja zonaaleihin. Tämä määrittää, missä laajuudessa resurssi on näkyvissä, hallittavissa ja käytettävissä.

## 2.5.1 Globaalit
Globaali tarkoittaa universe-tasoista kokonaisuutta, joka kattaa kaikki siihen liitetyt zonet. Globaalit resurssit hallitaan yhteisen global API-palvelimen kautta, ja ne tarjoavat keskitetyn näkymän sekä yhtenäisen hallinnan kaikille zoneille. Niiden avulla voidaan ylläpitää koko ympäristön kattavia konfiguraatioita, kuten yhteisiä identiteetti-, verkko- tai politiikkamäärityksiä.

## 2.5.2 Zonaali
Zonaalit palvelut sijaitsevat ja toimivat yhdessä tietyssä zonessa. Jokaisella zonella on oma zonal API-palvelimensa, joka hallitsee kyseisen vyöhykkeen resursseja, kuten virtuaalikoneita, tallennusta ja paikallisia verkkoelementtejä. Zonaaliset resurssit ovat täysin itsenäisiä – jos zone vikaantuu, sen resurssit eivät ole käytettävissä muiden zonien kautta. Tarkoittaa käytännössä sitä, että geohajauttaminen on huomioitava järjestelmien arkkitehtuurissa.

Yhdessä nämä kaksi tasoa muodostavat hallitun kokonaisuuden, jossa globaali ohjaus tarjoaa yhtenäisyyden ja keskitetyn hallinnan, kun taas zonaalit resurssit takaavat paikallisen eristyksen, itsenäisyyden ja vikasietoisuuden.

[kuva gz]

# 3. Hallintaroolit ja vastuunjako
GDC Air-Gapped -instanssin operointi jakautuu kolmeen päärooliin:
- Infrastructure Operator (IO): Palveluntuottajan rooli, joka vastaa fyysisen infrastruktuurin sekä universumi- ja zonetason arkkitehtuurin suunnittelusta ja ylläpidosta.
- Platform Admin (PA): Asiakasorganisaation rooli, joka hallinnoi pilvialustan rakenteita, verkkoja ja käyttöoikeuksia.
- Application Admin (AO): Asiakasorganisaation rooli, joka vastaa sovellusten ja työkuormien elinkaaren hallinnasta.

Roolit ja työkalut on tarkoituksella eriytetty: IO ei käsittele pilvialustan loogista kerrosta tai dataa, ja PA/AO eivät pääse käsiksi fyysiseen infrastruktuuriin. Tämä erottelu tukee tietoturvaa, vastuunjakoa ja sääntelyvaatimusten täyttämistä.

Roolit käydään myöhemmin tarkemmin läpi.