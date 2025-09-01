# save all modification temporarily
git stash push -m "oma keskeneräinen työ"

# Vedä uusimmat main-haaran muutokset
git fetch origin
git checkout main
git pull

# Palaa takaisin feature-haaraasi
git checkout feature/prowler-custom

# Yhdistä main tähän
git merge main

# Palauta stashi
git stash pop