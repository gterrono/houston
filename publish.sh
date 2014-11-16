function current_branch {
  echo $(git symbolic-ref HEAD 2>/dev/null | cut -d"/" -f 3)
}

function handle_error () {
  if [ "$?" != "0" ]; then
    echo "$1"
    exit 1
  fi
}
NEW_VERSION=$1

test "master" == $(current_branch)
handle_error "If you're publishing a new branch, you should be on master!"
# takes new argument, version in the style of "1.3.1"
echo $NEW_VERSION | grep -e '\d\.\d\.\d' > /dev/null
handle_error "New version needs to be in the first argument, style of 'major.minor.patch' (IE, 1.5.5)"
# check that there are no changes in git
test -z "`git status --porcelain --untracked-files=no`"
handle_error "Make sure your current branch is clean before publishing"

mv package.js package.js.temp
handle_error "couldn't create pckage.js.temp"
echo "_RELEASE_VERSION = \"$NEW_VERSION\"" > package.js
handle_error "couldn't write version to package.js"
tail -n +2 package.js.temp >> package.js
handle_error "couldn't write old package into package.js"
rm package.js.temp
handle_error "couldn't remove old package.js.temp"
# package.js = same as package.js but without first list and with

git add package.js
git commit -m "bumped version to $NEW_VERSION"
handle_error "couldn't make version bump commit"
git tag v$NEW_VERSION
handle_error "couldn't create new version tag"
git push origin master
handle_error "couldn't push release to master"
git push --tags
handle_error "couldn't push tags to master"
meteor publish
handle_error "couldn't push to meteor

echo "...Looks like that worked! You just published $NEW_VERSION"
open https://atmospherejs.com/houston/admin
