# check status
git status

# basic commit
lab #my bash alias to cd git root.
git add .
git commit -m "deployment experiments"
git push


# DelDemo - Gitin käyttö selkosuomeksi
## Peruskäyttö
### Tiivistelmä
git pull
git pull origin master
git add .
git commit -m "commitoidaan paikalliset muutokset verkkoon"
git push 
git branch
git checkout main #vaihtaa branchin 
git checkout -b uusibranchi  
git push origin uusibranchi  #tämä komento puskee tuon paikallisen haaran githubiin  
git status 
git log 

### Ympäristön konfigurointi
git config --global user.name "Etunimi Sukunimi"   
git config --global user.email "etu.suku@mail.com"      

### Uuden readme filen luonti konsolista ja upload main branchiin
echo "# DelDemo" >> README.md   
git init
git add README.md
git commit -m "first commit"   
git branch -M main

### Liitetään paikallinen git GitHubin online repoon ja pusketaan commitoidut
git remote add origin git@github.com:DelDolor/DelDemo.git 
git push -u origin main

### muokatun paikallisen tiedoston vieminen verkossa olevaan Git repoon
git add README.md
git commit README.md -m "jee"
git push

### Päivitä paikallinen reposi ajantasalle
git pull

### Hae klooni toisesta reposta, poista sen .git tiedot ja lisää osaksi omaa repoasi
git clone https://github.com/kangasta/week-53
rm -rf week-53/.git  
git add week-53/
commit -m "add week53 exmaple"

### muita hyödyllisiä
git status #näyttää statuksen
git log #näyttää commit historian
git checkout <commit-id> #voit palauttaa vanhan commitin aikaisen tilanteen. luo uuden branchin  

# branchien kanssa puuhailua
### Näytä ja vaihda branchia
git branch
git checkout main

### Lataa (checkout) online repon sisält suoraan uuteen branchiin. 
git checkout -b uusibranchi  #vaihtaa samalla sinut tähän uuteen branchiin.

### Päivitä paikallinen repo halutun branchin osalta
git pull origin master

### Luo manuaalisesti uusi branch ja puskse se Githubiin
git branch branhcname #tai 
git checkout -b uusibranchi
git push origin branchname # tämä komento puskee tuon paikallisen haaran githubiin  


