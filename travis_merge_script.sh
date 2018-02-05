if [ "$TRAVIS_BRANCH" != "dev" ]; then 
    exit 0;
fi
export GIT_COMMITTER_EMAIL="ramondelemos@gmail.com"
export GIT_COMMITTER_NAME="Ramon de Lemos"
rev=$(git rev-parse --short HEAD)
git config user.name "ramondelemos@gmail.com"
git config user.password "${GITHUB_TOKEN}"
git config --add remote.origin.fetch +refs/heads/*:refs/remotes/origin/* || exit
git fetch --all || exit
git stash
git checkout master || exit
git merge --no-ff "$TRAVIS_COMMIT" || exit
git stash pop
msg=$(git log --format=%B -n1)
git commit --amend -am "${msg} - commit from Travis CI - rev: ${rev}"
#git push https://${GITHUB_TOKEN}@github.com/ramondelemos/tech-challenge.git
git push origin master