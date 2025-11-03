# 1. Mikä on Google Distributed Cloud Air-Gapped
## 1.1 Google Distributed Cloud Air-Gapped – tekninen arkkitehtuuri ja operatiivinen malli
Google Distributed Cloud Air-Gapped (GDC AG) on ratkaisu, joka mahdollistaa pilviteknologioiden hyödyntämisen täysin eristetyssä ympäristössä. Alusta on suunniteltu organisaatioille, joilla on tiukat tietoturva- ja sääntelyvaatimukset, kuten julkishallinto, puolustussektori ja kriittinen infrastruktuuri. GDC AG toimii ilman yhteyttä julkiseen internetiin tai Google Cloudiin, mikä eliminoi ulkoiset riippuvuudet ja mahdollistaa suvereenin hallinnan.

Alustan tekninen perusta rakentuu Kubernetesin ympärille, ja se hyödyntää GKE Enterprise -komponentteja. Hallintatoiminnot, kuten control plane ja API-server, sijaitsevat organisaation sisäisessä verkossa. Tämä mahdollistaa sovellusten ja palveluiden ajamisen paikallisesti, ilman ulkoista ohjausta tai päivitysriippuvuuksia. GDC AG tukee myös valikoituja Vertex AI -palveluita, kuten Gemini, OCR ja puheentunnistus, jotka voidaan ajaa eristetyssä ympäristössä ilman yhteyttä julkisiin pilvipalveluihin, mikä mahdollistaa AI-toimintojen hyödyntämisen täysin paikallisesti. AI-palveluiden käyttö edellyttää erillisen GPU kapasiteetin hankinnan ja sen liittämisen osaksi klusteria.

## 1.2 Sovellusten ja palveluiden käyttö alustalla
GDC Air-Gapped tarjoaa asiakasorganisaatiolle kaksi pääasiallista tapaa hyödyntää alustaa sovellusten ajamiseen: virtuaalikoneet (VM) ja Kubernetes-kontit. Virtuaalikoneet soveltuvat erityisesti perinteisiin työkuormiin, kuten monoliittisiin sovelluksiin tai järjestelmiin, joita ei ole konttimuotoistettu. Kubernetes-kontit puolestaan tukevat mikropalveluarkkitehtuuria ja mahdollistavat skaalautuvan, automatisoidun sovellusajon, joka hyödyntää alustan orkestrointikyvykkyyksiä.

Riippumatta käytetystä ajotavasta, sovellukset voidaan integroida GDC AG -alustan tarjoamiin sisäisiin palveluihin. Näihin kuuluvat muun muassa salausavainten hallinta (KMS), kuormantasaus, tietokantapalvelut, sisäinen DNS sekä auditointipalvelut. Palvelut ovat saatavilla organisaation sisäisessä verkossa, ja niiden käyttö tapahtuu hallitusti ilman ulkoisia riippuvuuksia.

Alustan tarjoamat PaaS-palvelut tukevat sovellusten turvallista ja tehokasta operointia. Esimerkiksi KMS mahdollistaa salausavainten hallinnan paikallisesti, ja kuormantasausratkaisut tukevat sovellusten saatavuutta ja skaalautuvuutta. Sovellukset voivat hyödyntää näitä palveluita joko suoraan tai välityspalveluiden kautta, riippuen käytetystä arkkitehtuurista ja verkkomallista.

Lisäksi GDC AG -ympäristössä on käytettävissä sisäinen Marketplace, josta asiakasorganisaatio voi ottaa käyttöön valmiita, luotettavasti paketoituja komponentteja. Marketplace tarjoaa esimerkiksi yleisesti käytettyjä tietokantaratkaisuja kuten Redis, MongoDB ja muita sovelluspalveluita, jotka on sovitettu toimimaan air-gapped-ympäristössä. Komponentit ovat valmiiksi skannattuja ja yhteensopivia alustan hallintamallien kanssa, mikä nopeuttaa käyttöönottoa ja vähentää konfigurointitarvetta. Marketplace toimii osana organisaation sisäistä ekosysteemiä, eikä vaadi yhteyttä ulkoisiin lähteisiin. Marketplace sisältö on BYOL tai opensource mallin mukaista.

# 2. Kokonaisarkkitehtuuri
Google Distributed Cloud Air-Gapped (GDC-AG) -ympäristössä infrastruktuuri on jaettu kolmeen hierarkkiseen tasoon: universe, region ja zone. Näiden avulla rakennetaan täysin eristetty, korkean saatavuuden ja vikasietoisuuden pilviympäristö, joka ei missään vaiheessa edellytä yhteyttä Google Cloudiin tai julkiseen internetiin.

## 2.1 GDC Universe
Universe on korkein looginen kokonaisuus, joka kokoaa yhteen useita zoneja ja mahdollisesti useita regioonia. Se jakaa yhteisen control planen ja sisäisen verkon, joiden kautta hallinta, resurssien koordinointi ja tietoliikenne tapahtuvat. Universe määrittää hallinnolliset ja tekniset rajat, joiden sisällä kaikki resurssit toimivat. Samassa universumissa olevat zonet voivat sijaita fyysisesti eri konesaleissa tai jopa eri maantieteellisillä alueilla, mutta ne pysyvät yhtenä kokonaisuutena yhteisen ohjausjärjestelmän kautta. Universe sisältää globaalit palvelut jotka on käytettävissä jokaisessa regioonassa ja zonessa. Näitä ovat: DNS, Kuormanjako, Resource manager, IAM.

## 2.2 Region
Region on universumin sisäinen looginen ryhmä, joka koostuu useista toisiinsa kytketyistä zoneista. Regioonia käytetään ensisijaisesti organisoimaan zonet maantieteellisesti ja latenssivaatimusten mukaisesti, ei tarjoamaan omia aluekohtaisia palveluita. GDC-AG:ssä region ei siis sisällä omia “region-scoped” palveluita, vaan toimii lähinnä hallinnollisena ja topologisena rakenteena. Regionin sisällä olevien zonien välinen etäisyys on tyypillisesti rajattu siten, että niiden välinen latenssi pysyy alhaisena. Yhden regioonan sisäisten zonejen keskinäinen maksimietäisyys on n. 50 kilometriä. Regioonat voivat olla satojen kilometrien päässä toisistaan.

## 2.3 Zone
Zone on GDC Air-Gapped -arkkitehtuurin perusyksikkö ja samalla itsenäinen fault- ja disaster-domain. Jokainen zone on täysimittainen GDC-instanssi, joka sisältää koko palvelualustan – laitteiston, infrastruktuurin, palvelukerroksen ja hallitut palvelut – ja toimii täysin ilman yhteyttä ulkoisiin verkkoihin tai Google Cloudiin. Mikäli ympäristössä on vain yksi zone, se muodostaa samalla koko regionin ja universen. Kun useita zoneja yhdistetään, ne jakavat yhteisen control planen ja verkon, jolloin saavutetaan korkea käytettävyys ja vikasietoisuus: yhden zonen vika ei pysäytä kokonaisuutta.

Universumiin voi kuulua enintään kuusi zonea ja yksi tai kaksi toimintakeskusta (operation center, hallintapiste). Jos zoneja on vain kaksi, automaattista palautusta ei ole käytettävissä, vaan toipuminen on tehtävä manuaalisesti. Siksi monizonemalli on suositeltu rakenne korkean saatavuuden ja automaattisen toipumisen mahdollistamiseksi. Region toimii lähinnä maantieteellisenä ryhmittelynä, mutta kaikki hallinta, ohjaus ja palvelut toteutetaan universumitasolla.

GDC Air-Gapped perustuu täydelliseen suvereniteettiin ja eristykseen: jokainen zone hallitsee itse omaa infrastruktuuriaan ja tarjoaa kaikki API- ja hallintatoiminnot paikallisen control planen kautta. Tämä tekee mallista erityisen soveltuvan korkean tietoturvan ympäristöihin, joissa edellytetään paikallista hallintaa, datan suvereniteettia ja tarkasti kontrolloitua päivitysprosessia.

[kuva rz]

## 2.4 GLobaalit ja Zonaalit palvelut
Google Distributed Cloud Air-Gapped -ympäristössä resurssit ja hallintakomponentit jakautuvat kahteen pääluokkaan: globaaleihin ja zonaaleihin. Tämä erottelu määrittää, missä laajuudessa resurssi on näkyvissä, hallittavissa ja käytettävissä.

## 2.5.1 Globaalit
Globaali tarkoittaa universumitasoista kokonaisuutta, joka kattaa kaikki kyseisen universumin zonet. Globaalit resurssit hallitaan yhteisen global API-palvelimen kautta, ja ne tarjoavat keskitetyn näkymän sekä yhtenäisen hallinnan kaikille zoneille. Niiden avulla voidaan ylläpitää koko ympäristön kattavia konfiguraatioita, kuten yhteisiä identiteetti-, verkko- tai politiikkamäärityksiä. Globaali taso tuo siten yhdenmukaisuuden ja mahdollistaa toipumisen myös yksittäisen zonen vikatilanteissa.

## 2.5.2 Zonaali
Zonaali puolestaan viittaa resursseihin ja palveluihin, jotka sijaitsevat ja toimivat yhdessä tietyssä zonessa. Jokaisella zonella on oma zonal API-palvelimensa, joka hallitsee kyseisen vyöhykkeen resursseja, kuten virtuaalikoneita, tallennusta ja paikallisia verkkoelementtejä. Zonaaliset resurssit ovat täysin itsenäisiä – jos zone vikaantuu, sen resurssit eivät ole käytettävissä muiden zonien kautta.

Yhdessä nämä kaksi tasoa muodostavat hallitun kokonaisuuden, jossa globaali ohjaus tarjoaa yhtenäisyyden ja keskitetyn hallinnan, kun taas zonaalit resurssit takaavat paikallisen eristyksen, itsenäisyyden ja vikasietoisuuden.

[kuva gz]

# 3. Hallintaroolit ja vastuunjako
GDC instanssin operointi jakautuu kolmeen päärooliin: kaksi rooleista kuuluu asiakasorganisaatiolle – **Platform Admin** ja **Application Admin** – ja kolmas, **Infrastructure Operator**, kuuluu palveluntuottajalle.

## 3.1 Platform Admin 
Vastaa GDC Air-Gapped -alustan teknisestä ylläpidosta ja konfiguroinnista. Tähän sisältyy työkuormia ajavien user klusterien hallinta, verkkoasetusten määrittely, identiteetinhallinnan integrointi (esimerkiksi Active Directory tai Keycloak), sekä IAM-roolien ja palvelutunnusten hallinta. Lisäksi Platform Admin huolehtii auditointiprosesseista ja turvallisuuspolitiikkojen toteutuksesta, jotka ovat keskeisiä eristetyssä ympäristössä.

## 3.2 Application Admin 
Keskittyy sovellusten ja palveluiden elinkaaren hallintaan GDC-alustalla. Tämä rooli kattaa sovellusten käyttöönoton, päivitykset, resurssien ja namespace-hallinnan sekä pääsynhallinnan toteutuksen RBAC-mallin mukaisesti. Application Admin vastaa myös lokituksen ja monitoroinnin konfiguroinnista sekä yhteistyöstä kehitystiimien kanssa.

## 3.3 Infrastructure Operator 
Toimii palveluntuottajan roolissa ja vastaa fyysisen infrastruktuurin ylläpidosta, mukaan lukien laitteiston asennus, verkon fyysinen konfigurointi ja yhteydenpito Googlen tai kumppanien kanssa esimerkiksi päivitysten ja huollon yhteydessä. Tämä rooli ei osallistu sovellusten tai klusterien sisällön hallintaan, vaan keskittyy alustan operatiiviseen jatkuvuuteen ja tekniseen toimivuuteen.

# 4. Infrastruktuurialusta
## 4.1 Fyysinen infrastruktuuri
Minimiasennus on yhden zonen GDC instanssi joka koostuu neljästä räkistä. Kolme räkkiä tuottaa kaiken pilvialustan laskenta- ja tallennuskapasiteetin joille pilvialustat muodostetaan. Nämä kolme räkkiä sisältävät myös kaikki tarvittavat tietoliikenne ja salaisuuksienhallintalaitteet. Neljäs räkki on tarkoitettu Infrastruktuuri operaattorin käyttöön ja sisältää kaikki tarvittavat hallinta- ja tukijärjestelmät. Näitä ovat mm. tietoturvatyökalut, PAW-hallintalaitteiden hallintaympäristöt yms.

GDC alustaa voidaan laajentaa horisontaalisti lisäämällä räkkeihin laajennososia tai vertikaalisti hankkimalla lisää räkkejä. Minimiasennus (3+1) mahdollistaa kolmen Organisaatiotenantin ajamisen.

[KUVA inf]

GDC Infrastruktuuri palvelut rakentuu kuberneteksen ympärille ja sisältää neljän tyyppisiä klustereita:
### 4.1.1 Root admin klusteri
- yksi jokaisessa GDC instassissa. Asennettu kolmen fyysisen noden päälle ja tässä ajetaan system manageria ja muita core-palveluita.
- Tämän klusterin provisioi HW-vendori
- Elinkaaresta ja käytöstä vastaa IO
- PA ja AO eivät näe tätä klusteria 

### 4.1.2 Org admin klusteri 
- Näitä on yksi jokaiselle organisaatiolle (tenantti) ja asennettu kolmen fyysisen noden päälle.
- Organisaation admin klusterin provisioi IO tenantin luonnin yhteydessä
- Elinikaaresta vastaa IO
- PA käyttää
- AO ei näe

### 4.1.3 System klusteri
- yksi jokaiselle organisaatiolle. System klusterin Control Plane on asennettu VM:lle organisaation admin klusteriin. Worker nodeina useita fyysisiä palvelimia. Tämä klusteri on tarkoitettu organisaation VM kuormille ja hallituille palveluille.
- Organisaation System klusterin provisioi IO tenantin luonnin yhteydessä
- Elinikaaresta vastaa IO
- PA käyttää
- AO ei näe

### 4.1.3 Kubernetes (user) kluster 
Neljäs klusteri tyyppi on tarkoitettu organisaation konttikuormien ajamiseen. Platform admin hallinnoi näitä ja tekee tarvittavan määrän. Näiden klustereiden control plane on organisaation admin klusterissa vm:n päällä. Worker nodet on vm:n päällä, mutta system klusterissa.
- User klustereita provisioi PA
- Elinikaaresta vastaa PA
- AO käyttää (deployaa kuormaa)
- AO voi luoda virtuaalipalvelimia ja vastaa niiden elinkaaresta ja hallinnasta
Tästä klusterista on enemmän tarinaa pilvialustaa kuvaavassa kappaleessa.

[tähän kuva]

### 4.1.4 Hardware
Tämän tekstit toisaalla.

### 4.1.5 infrastruktuurialusta tietoliikenne
..tämä osuus vaatii kuvausta ja kuvia...

## 4.2 IO-rooli ja operatiivinen malli
Kuten alussa todettiin, infratruktuuri operaattori (IO) toimii palveluntuottajan roolissa ja tukee GDC Air-Gapped -ympäristön infrastruktuurin toimitusta, vastaa konfiguroinnista ja jatkuvasta operoinnista universumitasolla. Ryhmä hallitsee koko infrastruktuurin elinkaaren aina laitteiston esiasennustestauksesta ja käyttöönotosta jatkuvaan ylläpitoon ja valvontaan asti.

Ryhmän tehtävänä on suunnitella ja toteuttaa alustan arkkitehtuuri, asentaa ja konfiguroida laskenta-, tallennus- ja verkkoinfrastruktuuri, sekä varmistaa järjestelmän toimintavarmuus ja turvallisuus kaikissa zoneissa. Ryhmä vastaa myös käyttöönoton aikaisista pipelineista, työkalukonfiguraatioista ja infrastruktuuripalveluiden (verkko, storage, compute) hallinnasta.

Operatiivisesti Infrastructure Operator tukee Platform Administrator -ryhmää ja tarjoaa keskitetyn teknisen tuen, valvoo ympäristön turvallisuutta, reagoi poikkeamiin ja suorittaa korjauspäivitykset ja haavoittuvuuksien korjaukset säännöllisesti. Lisäksi ryhmä dokumentoi yleiset ongelmat ja toimintamallit, ylläpitää laskutusrakenteita ja vastaa universumitasoisesta kapasiteetinhallinnasta sekä infrastruktuurin elinkaaren hallitusta kehittämisestä.

## 4.2 ylläpito ja päivitykset
GDC Air-Gapped -ympäristön ylläpito ja päivitykset perustuvat hallittuun, todennettuun ja täysin eristettyyn elinkaarimalliin. Koska ympäristö ei ole yhteydessä julkiseen internetiin tai Google Cloudiin, kaikki ylläpito- ja päivitystoimet suoritetaan kontrolloidun prosessin kautta, joka varmistaa eheyden, jäljitettävyyden ja turvallisuuden kaikissa vaiheissa.

Päivitykset toimitetaan Googlelta allekirjoitettuina binääreinä ja siirretään ympäristöön fyysisesti tai hyväksytyn siirtokanavan kautta — yleensä salatuilla medioilla tai dedikoidun data-diodin kautta. Infrastructure Operator vastaa pakettien vastaanotosta, tarkistuksesta ja käyttöönotosta. Jokainen päivityspaketti validoidaan kryptografisella allekirjoituksella ja checksum-tarkistuksilla ennen asennusta.

Prosessi on vaiheistettu: ensin testaus- ja validointivaihe erillisessä staging-ympäristössä, jonka jälkeen käyttöönotto suoritetaan hallitusti joko rolling- tai blue-green-mallilla. Tämä mahdollistaa palautuksen (rollback) ilman tuotantokatkosta.

Haavoittuvuusskannaukset, laite- ja ohjelmistopäivitykset sekä konfiguraatiovalidoinnit suoritetaan säännöllisesti ilman ulkoisia riippuvuuksia. Kaikki muutokset dokumentoidaan, hyväksytään ja auditoidaan ennen käyttöönottoa, ja tapahtumat tallentuvat observability- ja SIEM-alustoihin. Näin varmistetaan, että ympäristö pysyy suojattuna, todennettuna ja toimintavarmana koko elinkaarensa ajan.

## 4.3 Infratason observability ja tietoturvakontrollit
### 4.3.1 Observability platform - lokitus
GDC air-gapped -ympäristön infrastruktuurikerros sisältää erillisen observability-alustan, jonka ylläpidosta vastaa infrastruktuurioperaattori (IO) teknologiatoimittajan ohjeiden mukaisesti. Alusta tarjoaa näkyvyyden GDC-järjestelmän tilaan, suorituskykyyn ja tietoturvaan. Observability-komponentit keräävät loki- ja metriikkatietoa koko alustan tasolla – mukaan lukien Kubernetes-nodet, bare metal -koneet, verkko- ja tallennuslaitteet sekä hallitut palvelut.

Alustaan sisältyvä SIEM-järjestelmä (Splunk Enterprise) indeksoi ja analysoi turvallisuustietoa eri lähteistä, mahdollistaen uhkien havaitsemisen ja niihin reagoinnin. SIEM tukee erillisen SOC-valvomon toimintaa GDC-alustan tietoturvan valvonnassa. Splunk vaati oman lisenssin (BYOL)
  
### 4.3.2 Haavoittuvuuden hallinta
Haavoittuvuuksien hallinta GDC air-gapped -ympäristössä on monikerroksinen prosessi, joka kattaa sekä kehitysvaiheen että tuotantoympäristön. Ennen julkaisua suoritetaan useita haavoittuvuuksien tunnistusprosesseja esituotantoympäristössä, jotta CVE-haavoittuvuudet voidaan havaita ja korjata ajoissa.

Tuotantoympäristössä IO vastaa säännöllisistä skannauksista, jotka kohdistuvat erityisesti klusterin nodeihin ja bare metal -palvelimiin – eli niihin resursseihin, joihin IO-roolilla on näkyvyys. Skannaukset toteutetaan Tenable Security Center -alustalla, joka hyödyntää Nessus-teknologiaa. Kaikki löydökset integroidaan organisaation Security Operations (SecOps) -prosesseihin uhkien hallintaa ja riskien seurantaa varten. Nessus vaatii oman lisenssin (BYOL)

### 4.3.3 Runtime-suojaus (EDR)
IO vastaa myös alustan päätepisteiden suojaamisesta EDR-ratkaisujen avulla. Käytössä ovat Trellix HX, Windows Defender ja ClamAV, jotka muodostavat yhtenäisen tietoturva-alustan. Ne tarjoavat näkyvyyden klusterin nodeihin ja bare metal -palvelimiin, mahdollistaen uhkien havaitsemisen, analysoinnin ja niihin reagoinnin reaaliaikaisesti.

EDR-järjestelmät tukevat haittaohjelmien tunnistamista, poikkeamien seurantaa ja uhkien torjuntaa, ja ne integroituvat osaksi organisaation SecOps-prosesseja. Trellix vaatii oman lisenssin (BYOL)

# 5. Pilvialusta – organisaatiokohtainen tenantti
## 5.1 Resurssihierarkia: Organization – Project – Cluster
### 5.1.1 Organisaatio ja projektit
Organisaatio toimii GDC AG:n resurssihierarkian ylimpänä tasona, jonka alle sijoittuvat projektit ja klusterit. Se tarjoaa fyysisen ja loogisen eristyksen muista organisaatioista. Organisaatiolla on oma virtuaalinen verkko, joka sisältää sisäisen IP-alueen (vain organisaation sisäinen liikenne) ja ulkoisen IP-alueen, jonka kautta sallittu liikenne voidaan ohjata eksplisiittisesti (default deny). Tämä verkkomalli tukee segmentointia ja liikenteen kontrollointia organisaation sisällä.

Projektit toimivat organisaation sisällä loogisina yksikköinä, jotka vastaavat Kubernetes-namespacen käsitettä. Ne tarjoavat erottelun eri sovellusympäristöille (esim. kehitys, testaus, tuotanto) ja mahdollistavat resurssien, IAM-politiikkojen ja verkkoasetusten hallinnan projektikohtaisesti. Projektit toimivat samalla verkon aliverkkoina (subnet), ja niiden välinen liikenne on oletuksena estetty. Tarvittaessa liikenne voidaan sallia tarkasti määritellyillä ProjectNetworkPolicy-säännöillä.

Namespace-sameness-ominaisuus takaa sen, että projektin resurssit ja politiikat toimivat yhtenäisesti eri klustereissa. Tämä mahdollistaa skaalautuvan ja hallitun ympäristön, jossa projektien elinkaari ja käyttö voidaan hallita keskitetysti.

### 5.1.2 Organisaation suunnittelu [MUOTOILE TEKSTI]
Samaan organisaatioon tulee kasata vain sellaiset projektit jotka jakavat saman luottamuksen (trust boundary) tämä voi olla vaikka yhden omistajan yhden turvaluokan järjestelmät. Tästä johtuen yhdellä asiakasorganisaatiolla voi olla useita GDC organisaatioita (tenantteja). Millaiset järjestelmät (projektit) voivat jakaa saman organisaation:
- työkuormat voivat jakaa riippuvuuksia, tietolähteitä tai niitä on tarpeen integroida yhteen
- Järjestelmillä voi olla sama ylläpitäjä (platform admin)
- Järjestelmät voivat jakaa alla olevan fyysisen infrastruktuurin keskenään
- Järjestelmät kuuluvat samaan budjetaariseen kokonaisuuteen (sama maksaja)
- Järjestelmille soveltuu sama saatavuusvaatimus

### 5.1.3 Projektien suunnittelu [MUOTOILE TEKSTI]
Projektien avulla järjestelmät eriytetään toisistaan loogisesti verkon ja käyttöoikeuksien osalta. Kun projektia suunnitellaan, kannattaa ajatella suurinta mahdollista kokonaisuutta joka voi jakaa resursseja keskenään, niiden käyttöoikeuksille on samat vaatimukset, niitä voi tai pitää valvoa kokonaisuutena. Kubernetes termein projekti on namespace ja tämä namespace on jaettu kaikkien organisaation klustereiden kesken. Tämä ei kuitenkaan tarkoita sitä että kyseisen namespacen podi on scheduloitu kaikkiin klustereihin vaan sitä että namespace nimi on uniikki organisaatiolle. Käyttöoikeudet määritetään tekemällä rolebinding roolin ja projektin välillä.

Rolebindingt tehdää projektitasolle ja niillä määritetään kuka voi tehdä ja mitä projektin resursseille. Projektitasolla määritetään myös network policyt joilla määritetään mihin ja kenen kanssa projektin resurrsit voivat jutella. Oletuksena projektin sisällä resurssit voivat keskustella, mutta projektien välinen on estetty.  

[PIIRRÄ REFEKUVA PROJEKTEISTA]

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
## 5.3 Työkuormat: VM:t ja Kubernetes
Asiakasorganisaatio voi rakentaa projekteihin VM-pohjaisia resursseja ja kontti-pohjaisia resursseja. VM-pohjainen työkuorma elää VM:n sisässä ja konttipohjainen kubernetes klusterissa. Tämä tuottaa samalla loogisen erottelun näiden kahden työkuorman välillä. 
[kuva aa]

## 5.3.1 VM
GDC alusta sisältää Ubuntu ja Rocky linux imaget ja tukee RHEL, SUSE, Windows Server 2019 ja Windows 10 OS imageja. IO voi tehdä ja julkaista organisaatioiden käyttöön räätälöityjä imageja. GDC alusta sisältää useita vaihtoehtoja virtualikoneen kooksi, jolloin tarvittava CPU, RAM ja GPU voidaan valita tarkoitukseen sopivaksi. Virtuaalikoneita ajetaan organisaation infratrukruuriklusterissa jossa on myös organisaation control ja data plane sekä managed palvaluita.

## 5.3.2 Konttipohjaiset kuormat
Containereita ajetaan podeissa, jotka kuuluvat namespaceen (projekti) ja näitä ajetaan Kubernetes klusterissa. Organisaatiolla voi olla useita kubernetes klustereita joka mahdollistaa järjestelmien tai ympäristöjen (dev, test, prod) eriyttämisen. Klusterissa voi olla useita node-pooleja ja jokaisen podin osalta määritetään missä poolissa sitä ajetaan. Tämä mahdollistaa sen, että konttia voidaan tarpeen mukaan ajaa poolissa jossa on esim. muisti tai GPU optimoidut nodet. Klusterit ovat aina zonaaleja eli elävät yksittäisessä GDC instanssissa. Projekti, eli kubernetes namespace, on kuitenkin globaali ja mahdollistaa järjestelmän hajauttamisen useaan klusteriin (availability zone ja/tai regioona).

[kuva ab]

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

### 5.7.1 Policy-as-Code, Compliance-as-Code ja CSPM
Compliance-as-Code on menetelmä, jossa sääntelyvaatimukset ja organisaation sisäiset turvallisuusstandardit mallinnetaan ohjelmallisesti konfiguraatioina, jotka voidaan tarkistaa automaattisesti osana infrastruktuurin ja sovellusten elinkaarta. GDC Air-Gapped -ympäristössä tämä lähestymistapa tukee jatkuvaa vaatimustenmukaisuutta ilman ulkoisia riippuvuuksia, mikä on erityisen tärkeää eristetyissä ja säädellyissä käyttöympäristöissä.

Menetelmä perustuu siihen, että vaatimukset – esimerkiksi ISO 27001:n, NIST SP 800-53:n tai SOC II:n mukaiset kontrollit – kuvataan koneellisesti luettavassa muodossa, kuten YAML- tai JSON-tiedostoina. Näitä sääntöjä voidaan soveltaa infrastruktuurin määrittelyyn (IaC), käyttöoikeuspolitiikkoihin, auditointikonfiguraatioihin ja sovelluskohtaisiin asetuksiin. Compliance-as-Code mahdollistaa politiikkojen automaattisen validoinnin esimerkiksi CI/CD-putkessa, jolloin virheelliset tai puutteelliset konfiguraatiot voidaan estää ennen käyttöönottoa.
GDC AG -ympäristössä Compliance-as-Code voidaan toteuttaa esimerkiksi seuraavilla tavoilla:
- OPA Gatekeeperin avulla voidaan enforce-tyyppisesti valvoa, että resurssit noudattavat vaadittuja sääntöjä.
- Sovelluskuvien skannaus voidaan konfiguroida tarkistamaan, että ne eivät sisällä tunnettuja haavoittuvuuksia tai rikko sääntelyvaatimuksia.
- VM-imaget voidaan validoida kovennusprosessin jälkeen automaattisesti, varmistaen että ne täyttävät organisaation turvallisuusvaatimukset ennen käyttöönottoa.
- Auditointilokit ja käyttöoikeuspolitiikat voidaan konfiguroida osana IaC-malleja, jolloin ne ovat osa infrastruktuurin määrittelyä eikä erillinen vaihe.

Compliance-as-Code tukee myös dokumentaation automatisointia: jokainen julkaisu, konfiguraatiomuutos tai resurssin käyttöönotto voidaan liittää auditointitietoon, joka toimii todisteena vaatimustenmukaisuudesta. Tämä on erityisen arvokasta ympäristöissä, joissa ulkoinen auditointi on rajattua tai tapahtuu harvoin.

### 5.7.2 Salaus, avainhallinta ja varmistus
### 5.7.3 DevSecOps & CI/CD air-gapped-ympäristössä
## 5.8 Tietoturvavalvonta ja SOC-integraatiot
