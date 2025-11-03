# Lähteet
2025-11-02
https://cloud.google.com/distributed-cloud/hosted/docs/latest/gdch/platform/pa-user/clusters

# Google Distributed Cloud Air-Gapped – tekninen arkkitehtuuri ja operatiivinen malli
    Google Distributed Cloud Air-Gapped (GDC AG) on ratkaisu, joka mahdollistaa pilviteknologioiden hyödyntämisen täysin eristetyssä ympäristössä. Alusta on suunniteltu organisaatioille, joilla on tiukat tietoturva- ja sääntelyvaatimukset, kuten julkishallinto, puolustussektori ja kriittinen infrastruktuuri. GDC AG toimii ilman yhteyttä julkiseen internetiin tai Google Cloudiin, mikä eliminoi ulkoiset riippuvuudet ja mahdollistaa suvereenin hallinnan.

    Alustan tekninen perusta rakentuu Kubernetesin ympärille, ja se hyödyntää GKE Enterprise -komponentteja. Hallintatoiminnot, kuten control plane ja API-server, sijaitsevat organisaation sisäisessä verkossa. Tämä mahdollistaa sovellusten ja palveluiden ajamisen paikallisesti, ilman ulkoista ohjausta tai päivitysriippuvuuksia. GDC AG tukee myös valikoituja Vertex AI -palveluita, kuten Gemini, OCR ja puheentunnistus, jotka voidaan ajaa eristetyssä ympäristössä ilman yhteyttä julkisiin pilvipalveluihin, mikä mahdollistaa AI-toimintojen hyödyntämisen täysin paikallisesti. AI-palveluiden käyttö edellyttää erillisen GPU kapasiteetin hankinnan ja sen liittämisen osaksi klusteria.

## Sovellusten ja palveluiden käyttö alustalla
    GDC Air-Gapped tarjoaa asiakasorganisaatiolle kaksi pääasiallista tapaa hyödyntää alustaa sovellusten ajamiseen: virtuaalikoneet (VM) ja Kubernetes-kontit. Virtuaalikoneet soveltuvat erityisesti perinteisiin työkuormiin, kuten monoliittisiin sovelluksiin tai järjestelmiin, joita ei ole konttimuotoistettu. Kubernetes-kontit puolestaan tukevat mikropalveluarkkitehtuuria ja mahdollistavat skaalautuvan, automatisoidun sovellusajon, joka hyödyntää alustan orkestrointikyvykkyyksiä.

    Riippumatta käytetystä ajotavasta, sovellukset voidaan integroida GDC AG -alustan tarjoamiin sisäisiin palveluihin. Näihin kuuluvat muun muassa salausavainten hallinta (KMS), kuormantasaus, tietokantapalvelut, sisäinen DNS sekä auditointipalvelut. Palvelut ovat saatavilla organisaation sisäisessä verkossa, ja niiden käyttö tapahtuu hallitusti ilman ulkoisia riippuvuuksia.

    Alustan tarjoamat PaaS-palvelut tukevat sovellusten turvallista ja tehokasta operointia. Esimerkiksi KMS mahdollistaa salausavainten hallinnan paikallisesti, ja kuormantasausratkaisut tukevat sovellusten saatavuutta ja skaalautuvuutta. Sovellukset voivat hyödyntää näitä palveluita joko suoraan tai välityspalveluiden kautta, riippuen käytetystä arkkitehtuurista ja verkkomallista.

    Lisäksi GDC AG -ympäristössä on käytettävissä sisäinen Marketplace, josta asiakasorganisaatio voi ottaa käyttöön valmiita, luotettavasti paketoituja komponentteja. Marketplace tarjoaa esimerkiksi yleisesti käytettyjä tietokantaratkaisuja kuten Redis, MongoDB ja muita sovelluspalveluita, jotka on sovitettu toimimaan air-gapped-ympäristössä. Komponentit ovat valmiiksi skannattuja ja yhteensopivia alustan hallintamallien kanssa, mikä nopeuttaa käyttöönottoa ja vähentää konfigurointitarvetta. Marketplace toimii osana organisaation sisäistä ekosysteemiä, eikä vaadi yhteyttä ulkoisiin lähteisiin. Marketplace sisältö on BYOL tai opensource mallin mukaista.

## Hallintaroolit ja vastuunjako
    Alustan operointi jakautuu kolmeen päärooliin: kaksi rooleista kuuluu asiakasorganisaatiolle – **Platform Admin** ja **Application Admin** – ja kolmas, **Infrastructure Operator**, kuuluu palveluntuottajalle.

    Platform Admin vastaa GDC Air-Gapped -alustan teknisestä ylläpidosta ja konfiguroinnista. Tähän sisältyy työkuormia ajavien user klusterien hallinta, verkkoasetusten määrittely, identiteetinhallinnan integrointi (esimerkiksi Active Directory tai Keycloak), sekä IAM-roolien ja palvelutunnusten hallinta. Lisäksi Platform Admin huolehtii auditointiprosesseista ja turvallisuuspolitiikkojen toteutuksesta, jotka ovat keskeisiä eristetyssä ympäristössä.

    Application Admin keskittyy sovellusten ja palveluiden elinkaaren hallintaan GDC-alustalla. Tämä rooli kattaa sovellusten käyttöönoton, päivitykset, resurssien ja namespace-hallinnan sekä pääsynhallinnan toteutuksen RBAC-mallin mukaisesti. Application Admin vastaa myös lokituksen ja monitoroinnin konfiguroinnista sekä yhteistyöstä kehitystiimien kanssa.

    Infrastructure Operator toimii palveluntuottajan roolissa ja vastaa fyysisen infrastruktuurin ylläpidosta, mukaan lukien laitteiston asennus, verkon fyysinen konfigurointi ja yhteydenpito Googlen tai kumppanien kanssa esimerkiksi päivitysten ja huollon yhteydessä. Tämä rooli ei osallistu sovellusten tai klusterien sisällön hallintaan, vaan keskittyy alustan operatiiviseen jatkuvuuteen ja tekniseen toimivuuteen.

## Organisaatio ja projektit
    Organisaatio toimii GDC AG:n resurssihierarkian ylimpänä tasona, jonka alle sijoittuvat projektit ja klusterit. Se tarjoaa fyysisen ja loogisen eristyksen muista organisaatioista. Organisaatiolla on oma virtuaalinen verkko, joka sisältää sisäisen IP-alueen (vain organisaation sisäinen liikenne) ja ulkoisen IP-alueen, jonka kautta sallittu liikenne voidaan ohjata eksplisiittisesti (default deny). Tämä verkkomalli tukee segmentointia ja liikenteen kontrollointia organisaation sisällä.

    Projektit toimivat organisaation sisällä loogisina yksikköinä, jotka vastaavat Kubernetes-namespacen käsitettä. Ne tarjoavat erottelun eri sovellusympäristöille (esim. kehitys, testaus, tuotanto) ja mahdollistavat resurssien, IAM-politiikkojen ja verkkoasetusten hallinnan projektikohtaisesti. Projektit toimivat samalla verkon aliverkkoina (subnet), ja niiden välinen liikenne on oletuksena estetty. Tarvittaessa liikenne voidaan sallia tarkasti määritellyillä ProjectNetworkPolicy-säännöillä.

    Namespace-sameness-ominaisuus takaa sen, että projektin resurssit ja politiikat toimivat yhtenäisesti eri klustereissa. Tämä mahdollistaa skaalautuvan ja hallitun ympäristön, jossa projektien elinkaari ja käyttö voidaan hallita keskitetysti.

### Organisaation suunnittelu [MUOTOILE TEKSTI]
    Samaan organisaatioon tulee kasata vain sellaiset projektit jotka jakavat saman luottamuksen (trust boundary) tämä voi olla vaikka yhden omistajan yhden turvaluokan järjestelmät. Tästä johtuen yhdellä asiakasorganisaatiolla voi olla useita GDC organisaatioita (tenantteja). Millaiset järjestelmät (projektit) voivat jakaa saman organisaation:
    - työkuormat voivat jakaa riippuvuuksia, tietolähteitä tai niitä on tarpeen integroida yhteen
    - Järjestelmillä voi olla sama ylläpitäjä (platform admin)
    - Järjestelmät voivat jakaa alla olevan fyysisen infrastruktuurin keskenään
    - Järjestelmät kuuluvat samaan budjetaariseen kokonaisuuteen (sama maksaja)
    - Järjestelmille soveltuu sama saatavuusvaatimus

### Projektien suunnittelu [MUOTOILE TEKSTI]
    Projektien avulla järjestelmät eriytetään toisistaan loogisesti verkon ja käyttöoikeuksien osalta. Kun projektia suunnitellaan, kannattaa ajatella suurinta mahdollista kokonaisuutta joka voi jakaa resursseja keskenään, niiden käyttöoikeuksille on samat vaatimukset, niitä voi tai pitää valvoa kokonaisuutena. Kubernetes termein projekti on namespace ja tämä namespace on jaettu kaikkien organisaation klustereiden kesken. Tämä ei kuitenkaan tarkoita sitä että kyseisen namespacen podi on scheduloitu kaikkiin klustereihin vaan sitä että namespace nimi on uniikki organisaatiolle. Käyttöoikeudet määritetään tekemällä rolebinding roolin ja projektin välillä.

    Rolebindingt tehdää projektitasolle ja niillä määritetään kuka voi tehdä ja mitä projektin resursseille. Projektitasolla määritetään myös network policyt joilla määritetään mihin ja kenen kanssa projektin resurrsit voivat jutella. Oletuksena projektin sisällä resurssit voivat keskustella, mutta projektien välinen on estetty.  

    [PIIRRÄ REFEKUVA PROJEKTEISTA]

## Klusterit ja kapasiteettirajoitteet
    Organisaation perustamisen yhteydessä infrastruktuurioperaattori luo infrastruktuuriklusterin, joka sisältää organisaation control plane -komponentit sekä Management API -palvelimen. Tämä klusteri hallinnoi palveluita ja kuormia, joita ei ajeta konttipohjaisesti.

    Lisäksi organisaatiolla voi olla useita Kubernetes-klustereita (user cluster), jotka ovat GKE Enterprise -hallittuja ja sovitettu GDC AG -alustaan. Klusterit voivat olla joko yksittäisille projekteille dedikoituja tai jaettuja useiden projektien kesken. Klusterien määrää ja kapasiteettia rajoitetaan seuraavasti:
    - Enintään 16 klusteria per organisaatio
    - Klusterissa 3–42 nodea
    - Maksimissaan 4620 podia per klusteri
    - Yhdellä nodella enintään 110 podia

## Projektien ja klusterien yhteiskäyttö
    Projektien ja klusterien välinen suhde on joustava. Klusteri voi olla dedikoitu yhdelle projektille, mutta projekti voi myös ulottua useisiin klustereihin. Namespace-sameness takaa yhtenäisen hallinnan, mikä tukee ympäristöjen erottelua ja resurssien tehokasta käyttöä. Verkkoerottelu projektien välillä on oletuksena voimassa, ja liikenteen salliminen edellyttää eksplisiittistä määrittelyä.

## Klusterin sisäinen rakenne
    Kunkin klusterin control plane vastaa keskeisistä toiminnoista, kuten Kubernetesin API-palvelimen, schedulerin ja resurssien hallintakomponenttien toiminnasta. API-server toimii klusterin keskuskomponenttina, joka vastaanottaa tilatiedot ja ohjaa klusterin toimintaa niiden mukaisesti.

    Node on virtuaalikone, joka sisältää container runtimen ja kubelet-agentin. Kubelet kommunikoi control planen kanssa ja vastaa konttien käynnistämisestä ja ajamisesta nodella. Lisäksi jokaisella nodella ajetaan järjestelmäkontteja DaemonSet-muodossa, jotka huolehtivat esimerkiksi lokien keruusta ja klusterin sisäisestä verkkoyhteydestä.

### Suositeltu klusterimalli
    - Erottele ympäristöt omiin klustereihin (dev, test, prod)
    - Suosi muutamaa isoa klusteria usean pienen sijaan. Jokainen klusteri vaatii oman control planen joka vie kapasiteettia
    - Tee klusterin sisään useita laajoja node pooleja usean pienen sijaan
    - Uusia klustereita voidaan tehdä myös silloin jos on tarvetta ajaa eri versioita Kuberneteksesta

    [kuva pd]


## Työkuormat
    Asiakasorganisaatio voi rakentaa projekteihin VM-pohjaisia resursseja ja kontti-pohjaisia resursseja. VM-pohjainen työkuorma elää VM:n sisässä ja konttipohjainen kubernetes klusterissa. Tämä tuottaa samalla loogisen erottelun näiden kahden työkuorman välillä. 
    [kuva aa]

### VM
    GDC alusta sisältää Ubuntu ja Rocky linux imaget ja tukee RHEL, SUSE, Windows Server 2019 ja Windows 10 OS imageja. IO voi tehdä ja julkaista organisaatioiden käyttöön räätälöityjä imageja. GDC alusta sisältää useita vaihtoehtoja virtualikoneen kooksi, jolloin tarvittava CPU, RAM ja GPU voidaan valita tarkoitukseen sopivaksi. Virtuaalikoneita ajetaan organisaation infratrukruuriklusterissa jossa on myös organisaation control ja data plane sekä managed palvaluita.

### Konttipohjaiset kuormat
    Containereita ajetaan podeissa, jotka kuuluvat namespaceen (projekti) ja näitä ajetaan Kubernetes klusterissa. Organisaatiolla voi olla useita kubernetes klustereita joka mahdollistaa järjestelmien tai ympäristöjen (dev, test, prod) eriyttämisen. Klusterissa voi olla useita node-pooleja ja jokaisen podin osalta määritetään missä poolissa sitä ajetaan. Tämä mahdollistaa sen, että konttia voidaan tarpeen mukaan ajaa poolissa jossa on esim. muisti tai GPU optimoidut nodet. Klusterit ovat aina zonaaleja eli elävät yksittäisessä GDC instanssissa. Projekti, eli kubernetes namespace, on kuitenkin globaali ja mahdollistaa järjestelmän hajauttamisen useaan klusteriin (availability zone ja/tai regioona).

    [kuva ab]