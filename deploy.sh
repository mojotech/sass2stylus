sed -i.bak 's/\*\/public\/\*//' .gitignore
rm .gitignore.bak
npm run-script compile
git checkout -b deploy
git add front_end
git commit -m 'deploy'
git push -f heroku deploy:master
git checkout master
git branch -D deploy
git reset --hard
