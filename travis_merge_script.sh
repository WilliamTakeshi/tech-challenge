if [ "$TRAVIS_BRANCH" != "dev" ]; then 
    exit 0;
fi
export GIT_COMMITTER_EMAIL="ramondelemos@gmail.com"
export GIT_COMMITTER_NAME="Ramon de Lemos"
git config --add remote.origin.fetch +refs/heads/*:refs/remotes/origin/* || exit
git fetch --all || exit
git checkout master || exit
git merge --no-ff "$TRAVIS_COMMIT" || exit
git commit --amend -am "Travis CI commit."
git push @github.com/">https://${GITHUB_TOKEN}@github.com/ramondelemos/tech-challenge.git