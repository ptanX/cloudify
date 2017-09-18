export VERSION="4.1"
export PRERELEASE="sp"
export GITHUB_USERNAME="username"
export GITHUB_PASSWORD="password"
sudo rpmbuild -ba /home/centos/rpmbuild/SPECS/build.spec \
        --define "VERSION $VERSION" \
        --define "PRERELEASE $PRERELEASE" \
        --define "GITHUB_USERNAME $GITHUB_USERNAME"\
        --define "GITHUB_PASSWORD $GITHUB_PASSWORD"\