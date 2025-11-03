Tämä dokumentti on osa tiivistelmä Google Distributed Cloud air-gapped pilvialustasta. Tiivistelmä perustuu Googlen julkaisemaan julkiseen dokumentaatioon. https://cloud.google.com/distributed-cloud/hosted/docs/latest/gdch/overview

# 4. Infrastruktuurialusta
Tämä osio kuvaa Google Distributed Cloud (GDC) Air-Gapped -alustan infrastruktuurikerroksen rakenteen ja hallintamallin sellaisena kuin se on kuvattu Googlen julkisessa dokumentaatiossa. Kuvaus keskittyy tekniseen arkkitehtuuriin, ei asiakaskohtaisiin toteutuksiin.

## 4.1 Fyysinen infrastruktuuri
GDC-instanssin minimiasennus muodostuu yhdestä zonesta, joka koostuu neljästä fyysisestä räkistä. Kolme räkkiä tuottavat pilvialustan laskenta- ja tallennuskapasiteetin, ja niihin sijoitetaan myös kaikki tarvittavat tietoliikenne- ja salaisuuksienhallintalaitteet. Neljäs räkki on varattu infrastruktuurioperaattorin käyttöön, ja se sisältää hallinta- ja tukijärjestelmät, kuten tietoturvatyökalut ja PAW-hallintaympäristöt.

[KUVA inf]

Alustaa voidaan laajentaa horisontaalisesti lisäämällä laajennusosia olemassa oleviin räkkeihin tai vertikaalisesti hankkimalla uusia räkkejä. Minimiasennus (3+1) tukee enintään kolmen organisaatiotenantin ajamista.

GDC:n infrastruktuuripalvelut rakentuvat Kubernetesin ympärille ja muodostuvat neljästä klusterityypistä.

[tähän kuva]


### 4.1.1 Root Admin -klusteri
Jokaisessa GDC-instanssissa on yksi Root Admin -klusteri, joka on asennettu kolmen bare metal -palvelimen päälle. Se muodostaa koko GDC-instanssin hallinnallisen juuren ja vastaa infrastruktuurin perustason orkestroinnista ja valvonnasta. Klusterissa ajetaan system manager ja muut keskeiset alustapalvelut. Klusterin provisioinnista vastaa laitevalmistaja, ja sen elinkaarta hallinnoi Infrastructure Operator. Platform Admin ja Application Admin eivät näe tätä klusteria.

### 4.1.2 Org Admin -klusteri 
Jokaisella organisaatiolla (tenantilla) on oma Org Admin -klusteri, joka on asennettu kolmen bare metal -palvelimen päälle.Klusteri sisältää käyttöliittymät, control plane palvelimet yms. Infrastructure Operator provisioi klusterin tenantin luonnin yhteydessä ja vastaa sen elinkaaresta. Platform Admin käyttää klusteria, mutta Application Adminilla ei ole siihen näkyvyyttä.

### 4.1.3 System-klusteri
System-klusteri on organisaatiokohtainen ja sen Control Plane sijaitsee virtuaalikoneella Org Admin -klusterissa. Worker-nodet ovat fyysisiä baremetal palvelimia. System-klusteri toimii GDC:n sisäisen IaaS-kerroksen toteutuksena ja tarjoaa resurssit virtuaalikonepohjaisille työkuormille sekä hallituille palveluille. Infrastructure Operator provisioi klusterin ja hallinnoi sen elinkaarta. Platform Admin käyttää klusteria, mutta Application Admin ei näe sitä.

### 4.1.4 Kubernetes (user) kluster 
User-klusterit on tarkoitettu organisaation konttipohjaisten työkuormien ajamiseen. Platform Admin hallinnoi näitä ja voi luoda tarvittavan määrän klustereita. Control Plane sijaitsee virtuaalikoneella Org Admin -klusterissa, ja Worker-nodet ovat virtuaalikoneita System-klusterissa. Platform Admin vastaa klusterien elinkaaresta, ja Application Admin käyttää niitä sovellusten deployaukseen sekä virtuaalipalvelimien hallintaan. Näistä klustereista kerrotaan tarkemmin pilvialustaa käsittelevässä osiossa.

Organisaatiokohtaiset fyysiset palvelimet tuovat hyvän erottelun organisaatioiden välille. Organisaation sisällä projektit erotellaan toisistaan loogisesti.
[tähän kuva]

### 4.1.5 Hardware
Tämän tekstit toisaalla.

### 4.1.6 infrastruktuurialustan tietoliikenne
Miten zonet liitetään toisiin? miten GDC liitetään internettiin (jos tarve)? miten IO räkissä olevilta hyppäreiltä hallinoidaan klustereita? Miten IO:n emergency pääsy organisaatioiden puolelle toimii käytännössä?
..tämän kuvaamiseen ei riittänyt aikaa mutta materiaalia löytyy... 

## 4.2 IO-rooli ja operatiivinen malli
### 4.2.1 Vastuut ja roolit
Kuten alussa todettiin, infratruktuuri operaattori (IO) toimii palveluntuottajan roolissa ja tuottaa GDC Air-Gapped -ympäristön infrastruktuuria palveluna asiakasorganisaatioille. IO vastaa konfiguroinnista ja jatkuvasta operoinnista universe-tasolla. Ryhmä hallitsee koko infrastruktuurin elinkaaren aina laitteiston esiasennustestauksesta ja käyttöönotosta jatkuvaan ylläpitoon ja valvontaan asti.

Infrastructure Operator toimii ainoana tahona, jolla on universe-tason hallintaoikeudet. Platform- ja Application-Admin-roolit operoivat sen yläpuolella rajatuin oikeuksin.

### 4.2.2 Päivittäinen operointi ja tukiprosessit
Ryhmän tehtävänä on suunnitella ja toteuttaa alustan arkkitehtuuri, asentaa ja konfiguroida laskenta-, tallennus- ja verkkoinfrastruktuuri, sekä varmistaa järjestelmän toimintavarmuus ja turvallisuus kaikissa zoneissa. Ryhmä vastaa myös käyttöönoton aikaisista pipelineista, työkalukonfiguraatioista ja infrastruktuuripalveluiden (verkko, storage, compute) hallinnasta.

Operatiivisesti Infrastructure Operator tukee Platform Administrator -ryhmää ja tarjoaa keskitetyn teknisen tuen, valvoo ympäristön turvallisuutta, reagoi poikkeamiin ja suorittaa korjauspäivitykset ja haavoittuvuuksien korjaukset säännöllisesti. Lisäksi ryhmä dokumentoi yleiset ongelmat ja toimintamallit, ylläpitää laskutusrakenteita ja vastaa universumitasoisesta kapasiteetinhallinnasta sekä infrastruktuurin elinkaaren hallitusta kehittämisestä.

## 4.2 ylläpito ja päivitykset
GDC Air-Gapped -ympäristön ylläpito ja päivitykset perustuvat hallittuun, todennettuun ja täysin eristettyyn elinkaarimalliin. Koska ympäristö ei ole yhteydessä julkiseen internetiin tai Google Cloudiin, kaikki ylläpito- ja päivitystoimet suoritetaan kontrolloidun prosessin mukaisesti, joka varmistaa järjestelmän eheyden, jäljitettävyyden ja tietoturvan kaikissa vaiheissa.

Päivitykset toimitetaan Googlelta kryptografisesti allekirjoitettuina binääreinä, ja ne siirretään ympäristöön joko fyysisesti tai hyväksytyn siirtokanavan kautta – tyypillisesti salatuilla medioilla tai dedikoidun data-diodin välityksellä. Päivitykset kattavat kaiken tarvittavan ohjelmisto- ja laiteohjelmistotason: GDC:n omat komponentit, nodejen käyttöjärjestelmät, haittaohjelmatunnisteet, tallennus- ja verkkolaitteiden ohjelmistot sekä muut binääripäivitykset.

Infrastructure Operator vastaa päivityspakettien vastaanotosta, validoinnista ja käyttöönotosta. Ennen asennusta jokainen paketti tarkistetaan kryptografisen allekirjoituksen ja checksum-tarkistusten avulla, mikä varmistaa sen alkuperän ja eheyden.

### 4.2.1 Muutostenhallinta – Infrastructure as Code
GDC Air-Gapped -ympäristössä infrastruktuurin konfigurointi ja käyttöönotto toteutetaan Infrastructure as Code -mallilla. Tämä mahdollistaa muutosten automatisoinnin, versionhallinnan ja valvonnan. Muutokset käyvät läpi monivaiheisen tarkastus- ja hyväksymisprosessin, jossa vastuut on selkeästi eroteltu – esimerkiksi muutosehdotuksen ja sen hyväksynnän välillä.
Kaikki konfiguraatiot tarkistetaan ennen käyttöönottoa, mikä parantaa muutosten yhdenmukaisuutta, vähentää virheitä ja mahdollistaa auditoinnin. Malli tukee turvallista ja todennettavaa operointia myös täysin eristetyssä ympäristössä.

IO-ryhmän vastuulla on deployata Googlelta tulevat IaC-paketit GDC instanssiin.

### 4.2.1 Sovellustason tietoturva
Kaikki ohjelmistot rakennetaan SLSA-viitekehyksen mukaisesti, mikä varmistaa toimitusketjun eheyden. Julkaisut rakennetaan Googlen eristetyissä build-ympäristöissä, skannataan monivaiheisesti, allekirjoitetaan kryptografisesti ja julkaistaan SBOM-tietueineen.

### 4.2.2 Vaatimustenmukaisuus ja jatkuva valvonta
GDC Air-Gapped -ympäristö täyttää yleisimmät vaatimustenmukaisuusstandardit, kuten NIST 800-53, SOC 2 ja FIPS 140-2/3. Tämän lisäksi GDC käy läpi useita sertifiointeja joilla Google-tason tietoturvastandardit. Google suorittaa tuotteeseen jatkuvaa seurantaa, säännöllisiä skannauksia ja pentestausta.

## 4.3 Infratason observability ja tietoturvakontrollit
Tämä osio kuvaa GDC Air-Gapped -ympäristön valvonta-, haavoittuvuudenhallinta- ja runtime-suojauksen kokonaisuuden.

### 4.3.1 Observability alusta - lokitusjärjestelmä
GDC Air-Gapped -ympäristön infrastruktuurikerros sisältää erillisen observability- ja tietoturvavalvonta-alustan, jota ylläpitää Infrastructure Operator teknologiatoimittajan ohjeiden mukaisesti. Alusta kerää loki- ja metriikkatietoa koko järjestelmästä – mukaan lukien Kubernetes-nodet, fyysiset palvelimet, verkko- ja tallennuslaitteet sekä hallitut palvelut.

Tietoturvavalvonta perustuu kerättyyn lokidataan ja Splunk Enterprise -järjestelmään, joka tukee SOC-toimintaa ja DFIR-prosessia (detect, triage, containment, investigation, response, recovery). SecOps-toiminta nojaa dokumentoituihin prosesseihin ja runbookeihin, jotka mahdollistavat jatkuvan valvonnan myös täysin eristetyssä ympäristössä. Splunkin valvontasäännöt pohjautuvat Mandiantin uhkatietoon ja päivittyvät Googlen toimittamien pakettien mukana.


### 4.3.2 Haavoittuvuuden hallinta
GDC Air-Gapped -ympäristössä haavoittuvuuksien hallinta kattaa sekä kehitysvaiheen että tuotantoympäristön. Ennen julkaisua Googlen toimesta suoritetaan useita tunnistusprosesseja esituotantoympäristössä, jotta CVE-haavoittuvuudet voidaan havaita ja korjata ajoissa. Kaikki GDC-ohjelmisto kehitetään SLSA-viitekehyksen mukaisesti, joka suojaa ohjelmistohankintaketjun hyökkäyksiltä.

Tuotantoympäristössä Infrastructure Operator vastaa säännöllisistä skannauksista, jotka kohdistuvat klusterin nodeihin ja bare metal -palvelimiin. Skannaukset toteutetaan Tenable Security Center -alustalla (Nessus), ja löydökset integroidaan organisaation SecOps-prosesseihin uhkien hallintaa ja riskien seurantaa varten.
Kaikki muutokset – mukaan lukien päivitykset ja konfiguraatiot – validoidaan, dokumentoidaan ja auditoidaan ennen käyttöönottoa. Tapahtumat tallentuvat observability- ja SIEM-järjestelmiin, mikä varmistaa ympäristön jatkuvan turvallisuuden ja toimintavarmuuden.
Nessus vaatii erillisen lisenssin (BYOL).


### 4.3.3 Runtime-suojaus (EDR)
Google toimittaa GDC:n mukana haittaohjelmien torjuntaohjelmistot nodejen käyttöjärjestelmiin ja tallennusjärjestelmiin. Näiden työkalujen päivitykset sisältyvät Googlen toimittamiin järjestelmäpäivityksiin, jotka Infrastructure Operator ottaa käyttöön osana GDC:n hallittua päivitysprosessia.

Käytössä ovat Trellix HX, Windows Defender ja ClamAV, jotka muodostavat yhtenäisen tietoturva-alustan. Ne tarjoavat näkyvyyden klusterin nodeihin ja bare metal -palvelimiin sekä mahdollistavat uhkien tunnistamisen, torjunnan ja analysoinnin reaaliaikaisesti. Trellix edellyttää erillisen lisenssin (BYOL).

Havaitut poikkeamat raportoidaan suoraan Infrastructure Operatorille SIEM-järjestelmän kautta. Lisäksi käytössä on eheysvalvonta ja tamperoinnin tunnistustyökalut, jotka suojaavat järjestelmää tahattomilta tai luvattomilta muutoksilta, ja tukevat ympäristön jatkuvaa suojausta ja todennettavuutta.