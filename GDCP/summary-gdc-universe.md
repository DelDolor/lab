    Google Distributed Cloud Air-Gapped (GDC-AG) -ympäristössä infrastruktuuri on jaettu kolmeen hierarkkiseen tasoon: universe, region ja zone. Näiden avulla rakennetaan täysin eristetty, korkean saatavuuden ja vikasietoisuuden pilviympäristö, joka ei missään vaiheessa edellytä yhteyttä Google Cloudiin tai julkiseen internetiin.

# GDC Universe
    Universe on korkein looginen kokonaisuus, joka kokoaa yhteen useita zoneja ja mahdollisesti useita regioonia. Se jakaa yhteisen control planen ja sisäisen verkon, joiden kautta hallinta, resurssien koordinointi ja tietoliikenne tapahtuvat. Universe määrittää hallinnolliset ja tekniset rajat, joiden sisällä kaikki resurssit toimivat. Samassa universumissa olevat zonet voivat sijaita fyysisesti eri konesaleissa tai jopa eri maantieteellisillä alueilla, mutta ne pysyvät yhtenä kokonaisuutena yhteisen ohjausjärjestelmän kautta. Universe sisältää globaalit palvelut jotka on käytettävissä jokaisessa regioonassa ja zonessa. Näitä ovat: DNS, Kuormanjako, Resource manager, IAM.

# Region
    Region on universumin sisäinen looginen ryhmä, joka koostuu useista toisiinsa kytketyistä zoneista. Regioonia käytetään ensisijaisesti organisoimaan zonet maantieteellisesti ja latenssivaatimusten mukaisesti, ei tarjoamaan omia aluekohtaisia palveluita. GDC-AG:ssä region ei siis sisällä omia “region-scoped” palveluita, vaan toimii lähinnä hallinnollisena ja topologisena rakenteena. Regionin sisällä olevien zonien välinen etäisyys on tyypillisesti rajattu siten, että niiden välinen latenssi pysyy alhaisena. Yhden regioonan sisäisten zonejen keskinäinen maksimietäisyys on n. 50 kilometriä. Regioonat voivat olla satojen kilometrien päässä toisistaan.

# Zone
    Zone on GDC Air-Gapped -arkkitehtuurin perusyksikkö ja samalla itsenäinen fault- ja disaster-domain. Jokainen zone on täysimittainen GDC-instanssi, joka sisältää koko palvelualustan – laitteiston, infrastruktuurin, palvelukerroksen ja hallitut palvelut – ja toimii täysin ilman yhteyttä ulkoisiin verkkoihin tai Google Cloudiin. Mikäli ympäristössä on vain yksi zone, se muodostaa samalla koko regionin ja universen. Kun useita zoneja yhdistetään, ne jakavat yhteisen control planen ja verkon, jolloin saavutetaan korkea käytettävyys ja vikasietoisuus: yhden zonen vika ei pysäytä kokonaisuutta.

    Universumiin voi kuulua enintään kuusi zonea ja yksi tai kaksi toimintakeskusta (operation center, hallintapiste). Jos zoneja on vain kaksi, automaattista palautusta ei ole käytettävissä, vaan toipuminen on tehtävä manuaalisesti. Siksi monizonemalli on suositeltu rakenne korkean saatavuuden ja automaattisen toipumisen mahdollistamiseksi. Region toimii lähinnä maantieteellisenä ryhmittelynä, mutta kaikki hallinta, ohjaus ja palvelut toteutetaan universumitasolla.

    GDC Air-Gapped perustuu täydelliseen suvereniteettiin ja eristykseen: jokainen zone hallitsee itse omaa infrastruktuuriaan ja tarjoaa kaikki API- ja hallintatoiminnot paikallisen control planen kautta. Tämä tekee mallista erityisen soveltuvan korkean tietoturvan ympäristöihin, joissa edellytetään paikallista hallintaa, datan suvereniteettia ja tarkasti kontrolloitua päivitysprosessia.

    [kuva rz]

# GLobaalit ja Zonaalit palvelut
    Google Distributed Cloud Air-Gapped -ympäristössä resurssit ja hallintakomponentit jakautuvat kahteen pääluokkaan: globaaleihin ja zonaaleihin. Tämä erottelu määrittää, missä laajuudessa resurssi on näkyvissä, hallittavissa ja käytettävissä.

## Globaalit
    Globaali tarkoittaa universumitasoista kokonaisuutta, joka kattaa kaikki kyseisen universumin zonet. Globaalit resurssit hallitaan yhteisen global API-palvelimen kautta, ja ne tarjoavat keskitetyn näkymän sekä yhtenäisen hallinnan kaikille zoneille. Niiden avulla voidaan ylläpitää koko ympäristön kattavia konfiguraatioita, kuten yhteisiä identiteetti-, verkko- tai politiikkamäärityksiä. Globaali taso tuo siten yhdenmukaisuuden ja mahdollistaa toipumisen myös yksittäisen zonen vikatilanteissa.

## Zonaali
    Zonaali puolestaan viittaa resursseihin ja palveluihin, jotka sijaitsevat ja toimivat yhdessä tietyssä zonessa. Jokaisella zonella on oma zonal API-palvelimensa, joka hallitsee kyseisen vyöhykkeen resursseja, kuten virtuaalikoneita, tallennusta ja paikallisia verkkoelementtejä. Zonaaliset resurssit ovat täysin itsenäisiä – jos zone vikaantuu, sen resurssit eivät ole käytettävissä muiden zonien kautta.

    Yhdessä nämä kaksi tasoa muodostavat hallitun kokonaisuuden, jossa globaali ohjaus tarjoaa yhtenäisyyden ja keskitetyn hallinnan, kun taas zonaalit resurssit takaavat paikallisen eristyksen, itsenäisyyden ja vikasietoisuuden.

    [kuva gz]