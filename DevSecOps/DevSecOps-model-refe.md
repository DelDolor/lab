
# 1. DevSecOps toimintamalli
DevSecOps on hallintamalli, jossa kehitys, tietoturva ja operointi kytketään yhdeksi automatisoiduksi julkaisuketjuksi. Malli sopii myös perinteisesti toimiville organisaatioille: se standardoi työvaiheet, vähentää käsityötä ja virheitä, ja tekee muutoksista todennettavia.

Mallin etuja on:
- Skaalautuvuus ja tehokkuus: Toistettavat putket, vähemmän manuaalia, nopeampi läpimeno.
- Laadun ja riskien hallinta: Shift-left-skannaukset, vertaisarvioinnit ja hyväksyntäpolut estävät virheet ennen tuotantoa.
- Turvallisuus oletuksena: Salaisuuksien hallinta, allekirjoitetut artefaktit ja SBOM varmistavat eheyden.
- Continuous Compliance: Kontrollit on koodattu putkiin; CSPM ja lokitus tuottavat reaaliaikaisen näkyvyyden.
- Täydellinen audit trail: Jokainen commit, tarkastus ja hyväksyntä tallentuu; jäljitettävyys on sisäänrakennettu.

Tuloksena organisaatio tietää aina mitä on asennettu, miksi ja milloin—sekä pystyy reagoimaan haavoittuvuuksiin nopeasti ja toistettavasti. Seuraava luku kuvaa vaihevetoisesti, miten julkaisuprosessi toteutetaan käytännössä.

# 2. Käytettävät työkalut
DevSecOps-mallin toteutus perustuu yhteisiin työkalu- ja hallintaperiaatteisiin, jotka mahdollistavat toistettavan ja auditoitavan kehitys- ja julkaisuprosessin.

DevSecOps-prosessin ydin toteutetaan GitLabin ja Terraformin avulla. GitLab toimii keskitettynä versiohallinta-, automaatio- ja hyväksyntäalustana, joka ohjaa koko julkaisuketjua aina koodin kehityksestä tuotantoon. Kaikki muutokset – niin sovelluksiin kuin infrastruktuuriin – kulkevat GitLabin CI/CD-putkien kautta, joissa määritetyt tietoturvakontrollit, skannerit ja hyväksyntäpolut suoritetaan automaattisesti.

Infrastruktuuri määritellään ja hallitaan Terraformilla, joka toimii organisaation Infrastructure as Code (IaC) -ratkaisuna. Terraformin avulla ympäristöt, verkot, tallennusresurssit ja tietoturvakomponentit rakennetaan ja versioidaan samalla tavalla kuin sovelluskoodi. Tämä mahdollistaa toistettavat, tarkastettavat ja palautettavat ympäristömuutokset.

Sovelluskoodaus toteutetaan eri ohjelmointikielillä projektikohtaisesti, mutta kaikki noudattavat samaa CI/CD- ja hyväksyntämallia. Rakennetut artefaktit tallennetaan AWS/Azure/GCP/GDC-alustan tarjoamaan artifaktirekisteriin, ja salaisuuksien sekä allekirjoitusavainten hallinta tapahtuu AWS/Azure/GCP/GDC:n sisäisessä avaintenhallintapalvelussa.

Vaihtoehtoisesti organisaatio voi hyödyntää HashiCorp Vaultia, joka on saatavilla GDC:n Marketplace-palvelusta. Vault tarjoaa laajennettavan, politiikkapohjaisen tavan hallita salaisuuksia, dynaamisia tunnuksia ja salausavaimia myös moniprojektiympäristöissä.

# 3. DevSecOps-prosessin vaiheet
DevSecOps mallin vaiheet vaihtelevat projekteittain, mutta noudattavat kuitenkin karkeasti kuvan viisi portaista mallia. Vaiheet on purettu auki kuvan jälkeen.
[kuva dso]



## 3.1 Vaihe 1: Pre-Merge – turvallinen kehityksen aloitus
Ensimmäinen vaihe on Pre-merge, joka tapahtuu ennen kehitystöiden aloittamista ja jatkuu koodin kirjoituksen ajan aina siihen pisteeseen, että kehittäjä on valmis lähettämään koodinsa yhteiseen repositoryyn. Vaihe alkaa siitä, että kehityskohde kirjataan tehtävienhallintaan ja hyväksytään kehitettäväksi. Kehityksen alussa kehitettävälle kohteelle tehdään uhka-arvio, jossa käydään läpi mitä ollaan tekemässä ja millaisia uhkia siihen kohdistuu tai miten se vaikuttaa ympäristöön jonne se tullaan asentamaan. Uhka-arvion lopputuloksena tunnistetaan onko kyseessä standardi muutos vai korkean riskin muutos joka vaatii CAB-käsittelyä.

Uhka-arvion jälkeen alkaa kehitystyöt jotka tapahtuvat suurelta osin kehittäjän työasemassa ja käytettävässä IDE:ssä. Teknisinä suojakeinoina IDEen asennetaan plugineina koodiskannereita, jotka tarkastavat koodia realiaikaisesti ja antavat kehittäjälle palautetta ja osaa skannereista ajetaan manuaalisesti ennen git commitointia. Näiden kontrollien tarkoituksena ei ole tarjota aukotonta suojaa, vaan ennen kaikkea antaa kehittäjälle nopeaa palautetta jotta korjaukset saadaan tehtyä jo ennen kuin myöhemmät kontrollit estää etenemisen.

Organsaation hallitsemia kontrolleja tässä vaiheeessa ovat branch-protection ja codeowner, joiden avulla kontrolloidaan kuka voi muokata mitäkin koodia ja kenen hyväksyntöjä tarvitaan ennen kuin koodi pääsee repositoryn päähaaraan. Periaatteena on, että koodia kirjoitetaan aina feature-haaraan ja kun se on valmis, liitetään hyväksytty ja testattu koodi päähaaraan. Tällä varmistetaan se, että päähaarassa on aina toimiva koodi, jolla ympäristöt ja järjestelmät voidaan rakentaa tarvittaessa uudelleen. Ennen committia koodille voidaan vaatia vertaisarviontia ja hyväksyntää jolla varmistetaan koodin laatu, koodauskäytänteiden noudattaminen, ja samalla siirretään hiljaista tietoa kun koodiin perehtyy joku toinenkin.

## 3.2 Vaihe 2: Merge – kontrolloitu yhdistäminen ja automaattinen tarkastus
Seuraava vaihe on merge, jonka lopputuloksena kehitetty feature liitetään päähaaraan. Merge vaihe käynnistyy kun kehittäjä lähettää git commit pyynnön, jossa koodi siirtyy kehittäjän työasemasta GitLabiin ja muodostaa merge-request pyynnön (mr). GitLabissa määritetään projektikohtaisesti kuka/ketkä mr-pyynnöt hyväksyy. 

Hyväksynnän jälkeen käynnistyy GitLabin CICD-pipeline, joka ajaa organisaation tähän vaiheeseen määrittämät skannerit. Käytettävät skannerit riippuu kehityskohteesta ja voivat sisältää esim. IaC-skannereita jotka tarkistavat, että koodina kirjoitettu infrastruktuuri noudattaa organisaation määrittämää politiikkaa (compliance-as-code), muita tyypillisiä skannereita ovat haavoittuvuusskannerit ja salaisuusskannerit, joiden tehtävänä on estää haavoittuvia kirjastoja ja riippuvuuksia sisältävän koodin pääsy päähaaraan ja sitä kautta tuotantoon ajettavaksi ja salasanoja ja muita credentiaaleja päätymästä repositoryyn varastettavaksi. Skannereiden tulokset viedään organisaation haavoittuvuuden hallinta järjestelmään.

mr-pipeline skannereiden tarkoitus on olla nopeita ja tuottaa varmoja tuloksia. Tämän takia syvempi tarkastus tehdään myöhemmässä vaiheessa.

## 3.3 Vaihe 3: Acceptance & Build – syväanalyysi ja tuotantovalmius
Seuraavassa vaiheessa koodi on päähaarassa ja sitä aletaan valmistelemaan asennettavaksi. Tämä vaatii jälleen hyväksynnän, jonka jälkeen käynnistyy uusi CICD-pipeline. Pipelinen aikana koodille ajetaan syvemmät ja skannerit ja mikäli skannaus tuloksissa löytyy korjattavaa joka ylittää määritetyn turvarajan, keskeytyy pipelinen suoritus tähän ja kehittäjälle lähtee korjauspyyntö. 

Kun kaikki on kunnossa ja pipeline jatkuu, tehdään tarvittavat käännökset ja imagejen rakennukset. Käännetyt artifaktit skannataan vielä erikseen haavoittuvuuksien varalta. Artifakteista luodaan automaattisesti SBOM (software bill of material), joka sisältää listan ohjelmiston komponenteista versioineen. Artifakti ja SBOM tallennetaan organisaation yksityiseen rekisteriin ja allekirjoitetaan digitaalisesti. Kaikki täällä vaiheessa syntyvät testiraportit viedään organisaation haavoittuvuuden hallinta järjestelmään.

## 3.4 Vaihe 4: Deploy – luotettava ja hallittu julkaisu
Seuraavassa vaiheessa tarkastettu koodi ja käännetyt artifaktit asennetaan testiympäristöön. Ennen asennusta artifaktit ladataan rekisteristä ja allekirjoitus tarkistetaan. Asennustapa vaihtelee ympäristön ja asennettavan koodin osalta. Vaihtoehtoja ovat mm. blue/green, canary ja dark launch. Asennuksen päätteeksi pipeline voi ajaa vielä automaattiset smoketestit. Tämän jälkeen prosessi jatkuu asentamalla sama paketti tuotantoon. Ennen tuotantoasennusta voidaan vaatia manuaalista testausta ja erillistä hyväksyntää tuotantoasennukselle. 

## 3.5 Vaihe 5: Operation – jatkuva valvonta ja reagointi
Viimeinen vaihe on operation, joka tarkoittaa käytännässö tuotantokäyttöä. Operation vaiheessa tehdään jatkuvaa haavoittuvuuksien seurantaa, eli käytännössä ajossa olevia artifakteja skannataan siltä varalta, että niissä oleviin komponentteihin on tullut uusia haavoittuvuuksia julkaisuvaiheessa tehdyn skannauksen jälkeen. Muita tämän vaiheen tietoturvakontrolleja ovat asennettua järjestelmää suojaavat muut komponentit, kuten WAF, DDoS, EDR. Viimeinen turva kun kaikki muu on pettänyt on tietoturvavalvomo SOC joka valvoo tuotannon toimintaa ja reagoi tapahtumiin.

[tähän prosessi kuva]

# 4. Infrastruktuurin hallinta
DevSecOps-mallissa infrastruktuuri on uudelleenasennettavaa ja ohjelmoitavaa, ei pysyvää. Kaikkea ei tarvitse varmistaa, sillä palvelimet ja kontit voidaan rakentaa uudelleen suoraan koodista. Riittää, että data ja konfiguraatio – eli GitLab-repossa oleva lähdekoodi sekä Terraform- ja Ansible-koodit – ovat turvassa ja versionhallinnassa.

Päivitykset ja korjaukset tehdään muuttamalla koodia ja ajamalla muutokset hallitusti CI/CD-putken kautta, ei kirjautumalla palvelimiin käsin. Näin ympäristö pysyy yhdenmukaisena, todennettavana ja helposti palautettavana.

Tämä lähestymistapa tukee jatkuvaa kehittämistä, nopeaa toipumista ja varautumista: jos ympäristö menetetään, se voidaan pystyttää uudelleen hallitusti ja todennettavasti samoilla IaC-määrityksillä.