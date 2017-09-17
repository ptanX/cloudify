#!/bin/bash


function prepare_rest_service_build_file()
{
if [ -f "$build_spec_tmp_file" ]; then
    echo "build.spec already exist"
    cat "" > $build_spec_tmp_file
else
    echo "create new file build.spec"
    touch $build_spec_tmp_file 
fi
cat << EOF > $build_spec_tmp_file
%define _rpmdir /tmp


Name:           cloudify-rest-service
Version:        %{VERSION}
Release:        %{PRERELEASE}
Summary:        Cloudify's REST Service
Group:          Applications/Multimedia
License:        Apache 2.0
URL:            https://github.com/cloudify-cosmo/cloudify-manager
Vendor:         Gigaspaces Inc.
Prefix:         %{_prefix}
Packager:       Gigaspaces Inc.
BuildRoot:      %{_tmppath}/%{name}-root



%description
Cloudify's REST Service.



%prep

set +e
pip=\$(which pip)
set -e

[ ! -z \$pip ] || sudo curl --show-error --silent --retry 5 https://bootstrap.pypa.io/get-pip.py | sudo python
sudo yum install -y git python-devel postgresql-devel openldap-devel gcc gcc-c++
sudo pip install virtualenv
sudo virtualenv /tmp/env
sudo /tmp/env/bin/pip install -U pip==9.0.1 && \\
sudo /tmp/env/bin/pip install setuptools==32.3.0 && \\
sudo /tmp/env/bin/pip install wheel==0.24.0 && \\

%build
%install

export REST_SERVICE_BUILD=True
default_version=%{CORE_TAG_NAME}
destination="/tmp/\${RANDOM}.file"
curl --retry 10 --fail --silent --show-error --location http://10.84.20.220/cloudify_package_resource/cloudify-manager-4.1.tar.gz --create-dirs --output \$destination && \\
tar -xzf \$destination --strip-components=1 -C "/tmp" && \\

mkdir -p %{buildroot}/opt/manager/resources/
sudo cp -R "/tmp/resources/rest-service/cloudify/" "%{buildroot}/opt/manager/resources/"

# ldappy is being install without a specific version, until it'll be stable..

sudo /tmp/env/bin/pip wheel virtualenv --wheel-dir %{buildroot}/var/wheels/%{name} && \\
sudo /tmp/env/bin/pip wheel --wheel-dir=%{buildroot}/var/wheels/%{name} --find-links=%{buildroot}/var/wheels/%{name} http://10.84.20.220/cloudify_package_resource/cloudify-dsl-parser-4.1.tar.gz && \\
sudo /tmp/env/bin/pip wheel --wheel-dir=%{buildroot}/var/wheels/%{name} --find-links=%{buildroot}/var/wheels/%{name} http://10.84.20.220/cloudify_package_resource/ldappy-master.tar.gz && \\
if [ "%{REPO}" != "cloudify-versions" ]; then
    sudo /tmp/env/bin/pip wheel --wheel-dir=%{buildroot}/var/wheels/%{name} --find-links=%{buildroot}/var/wheels/%{name} \\ 
    https://%{GITHUB_USERNAME}:%{GITHUB_PASSWORD}@github.com/cloudify-cosmo/cloudify-premium/archive/%{CORE_TAG_NAME}.tar.gz
fi
sudo -E /tmp/env/bin/pip wheel --wheel-dir=%{buildroot}/var/wheels/%{name} --find-links=%{buildroot}/var/wheels/%{name} /tmp/rest-service


%pre
%post

export REST_SERVICE_BUILD=True

pip install --use-wheel --no-index --find-links=/var/wheels/%{name} virtualenv && \\
if [ ! -d "/opt/manager/env" ]; then virtualenv /opt/manager/env; fi && \\
/opt/manager/env/bin/pip install --upgrade --force-reinstall --use-wheel --no-index --find-links=/var/wheels/%{name} cloudify-dsl-parser --pre && \\
/opt/manager/env/bin/pip install --upgrade --force-reinstall --use-wheel --no-index --find-links=/var/wheels/%{name} ldappy --pre && \\
/opt/manager/env/bin/pip install --upgrade --force-reinstall --use-wheel --no-index --find-links=/var/wheels/%{name} cloudify-rest-service --pre
if [ "%{REPO}" != "cloudify-versions" ]; then
    /opt/manager/env/bin/pip install --upgrade --force-reinstall --use-wheel --no-index --find-links=/var/wheels/%{name} cloudify-premium --pre
fi
# sudo cp -R "/tmp/resources/rest-service/cloudify/" "/opt/manager/resources/"


%preun
%postun

rm -rf /opt/manager/resources
rm -rf /var/wheels/\${name}


%files

%defattr(-,root,root)
/var/wheels/%{name}/*.whl
/opt/manager/resources
EOF
}

function build_rest_service_rpm_file()
{
if [ ! -d $build_spec_home_dir ]; then
    mkdir -p $build_spec_home_dir
fi
if [ ! -f $build_spec_home_file ]; then
    cp $build_spec_tmp_file $build_spec_home_file 
else
    echo $user_password|sudo -S rm -f $build_spec_home_file && cp $build_spec_tmp_file $build_spec_home_file
fi
if [ -f $rest_service_rpm_file ]; then
    echo $user_password|sudo -S rm -f $rest_service_rpm_file
fi
echo $user_password|sudo -S yum install -y rpm-build 
echo $user_password|sudo -S rpmbuild -ba /home/centos/rpmbuild/SPECS/build.spec --define "VERSION $VERSION" --define "PRERELEASE $PRERELEASE"  --define "REPO $REPO"
echo $user_password|sudo -S rm -f /tmp/tmp* 
}

export VERSION="4.1"
export PRERELEASE="ga"
export REPO="cloudify-versions"
export build_spec_tmp_file="/tmp/build.spec"
export build_spec_home_dir='/home/centos/rpmbuild/SPECS/'
export build_spec_home_file='/home/centos/rpmbuild/SPECS/build.spec'
export user_password='welcome123'
export rest_service_rpm_file='/tmp/x86_64/cloudify-rest-service-*'

prepare_rest_service_build_file
build_rest_service_rpm_file
