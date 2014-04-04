sed -i.bak 's/\*\/public\/\*//' .gitignore
rm .gitignore.bak
cd front_end
roots compile
cd ..
git checkout -b deploy
git add front_end
git commit -m 'deploy'
git push -f heroku deploy:master
git checkout master
git branch -D deploy
git reset --hard
