export VERSION="4.1"
export PRERELEASE="sp"
export GITHUB_USERNAME="binhnt5"
export GITHUB_PASSWORD="654321Nyh"
sudo rpmbuild -ba /home/centos/rpmbuild/SPECS/build.spec \
        --define "VERSION $VERSION" \
        --define "PRERELEASE $PRERELEASE" \
        --define "GITHUB_USERNAME $GITHUB_USERNAME"\
        --define "GITHUB_PASSWORD $GITHUB_PASSWORD"\