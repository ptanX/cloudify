#!/bin/bash


function prepare_management_worker_service_build_file()
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


Name:           cloudify-management-worker
Version:        %{VERSION}
Release:        %{PRERELEASE}
Summary:        Cloudify's Management Worker
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
sudo yum install -y git python-devel postgresql-devel gcc gcc-c++
sudo pip install virtualenv
sudo virtualenv /tmp/env
sudo /tmp/env/bin/pip install setuptools==18.1 && \\
sudo /tmp/env/bin/pip install wheel==0.24.0 && \\

%build
%install

destination="/tmp/\${RANDOM}.file"
curl --retry 10 --fail --silent --show-error --location http://10.84.20.220/cloudify_package_resource/cloudify-manager-4.1.tar.gz --create-dirs --output \$destination && \\
tar -xzf \$destination --strip-components=1 -C "/tmp" && \\

sudo /tmp/env/bin/pip wheel virtualenv --wheel-dir %{buildroot}/var/wheels/%{name} && \\
sudo /tmp/env/bin/pip wheel --wheel-dir=%{buildroot}/var/wheels/%{name} --find-links=%{buildroot}/var/wheels/%{name} http://10.84.20.220/cloudify_package_resource/cloudify-rest-client-4.1.tar.gz && \\
sudo /tmp/env/bin/pip wheel --wheel-dir=%{buildroot}/var/wheels/%{name} --find-links=%{buildroot}/var/wheels/%{name} http://10.84.20.220/cloudify_package_resource/cloudify-plugins-common-4.1.tar.gz && \\
sudo /tmp/env/bin/pip wheel --wheel-dir=%{buildroot}/var/wheels/%{name} --find-links=%{buildroot}/var/wheels/%{name} http://10.84.20.220/cloudify_package_resource/cloudify-script-plugin-1.4.tar.gz && \\
sudo /tmp/env/bin/pip wheel --wheel-dir=%{buildroot}/var/wheels/%{name} --find-links=%{buildroot}/var/wheels/%{name} http://10.84.20.220/cloudify_package_resource/cloudify-agent-4.1.tar.gz && \\
sudo /tmp/env/bin/pip wheel --wheel-dir=%{buildroot}/var/wheels/%{name} --find-links=%{buildroot}/var/wheels/%{name} http://10.84.20.220/cloudify_package_resource/psycopg2-2_6_2.tar.gz && \\
sudo /tmp/env/bin/pip wheel --wheel-dir=%{buildroot}/var/wheels/%{name} --find-links=%{buildroot}/var/wheels/%{name} /tmp/plugins/riemann-controller
sudo /tmp/env/bin/pip wheel --wheel-dir=%{buildroot}/var/wheels/%{name} --find-links=%{buildroot}/var/wheels/%{name} /tmp/workflows




%pre
%post

pip install --use-wheel --no-index --find-links=/var/wheels/%{name} virtualenv && \\
if [ ! -d "/opt/mgmtworker/env" ]; then virtualenv /opt/mgmtworker/env; fi && \\
/opt/mgmtworker/env/bin/pip install --upgrade --force-reinstall --use-wheel --no-index --find-links=/var/wheels/%{name} cloudify-rest-client --pre && \\
/opt/mgmtworker/env/bin/pip install --upgrade --force-reinstall --use-wheel --no-index --find-links=/var/wheels/%{name} cloudify-plugins-common --pre && \\
/opt/mgmtworker/env/bin/pip install --upgrade --force-reinstall --use-wheel --no-index --find-links=/var/wheels/%{name} cloudify-script-plugin --pre && \\
/opt/mgmtworker/env/bin/pip install --upgrade --force-reinstall --use-wheel --no-index --find-links=/var/wheels/%{name} cloudify-agent --pre && \\
/opt/mgmtworker/env/bin/pip install --upgrade --force-reinstall --use-wheel --no-index --find-links=/var/wheels/%{name} psycopg2 --pre && \\
/opt/mgmtworker/env/bin/pip install --upgrade --force-reinstall --use-wheel --no-index --find-links=/var/wheels/%{name} cloudify-riemann-controller-plugin --pre && \\
/opt/mgmtworker/env/bin/pip install --upgrade --force-reinstall --use-wheel --no-index --find-links=/var/wheels/%{name} cloudify-workflows --pre





%preun
%postun

rm -rf /var/wheels/\${name}


%files

%defattr(-,root,root)
/var/wheels/%{name}/*.whl
EOF
}

function build_management_worker_service_rpm_file()
{
if [ ! -d $build_spec_home_dir ]; then
    mkdir -p $build_spec_home_dir
fi
if [ ! -f $build_spec_home_file ]; then
    cp $build_spec_tmp_file $build_spec_home_file 
else
    echo $user_password|sudo -S rm -f $build_spec_home_file && cp $build_spec_tmp_file $build_spec_home_file
fi
if [ -f $management_worker_service_rpm_file ]; then
    echo $user_password|sudo -S rm -f $management_worker_service_rpm_file
fi
echo 'Start building cloudify management worker rpm file'
echo $user_password|sudo -S yum install -y rpm-build
echo $user_password|sudo -S rpmbuild -ba /home/centos/rpmbuild/SPECS/build.spec --define "VERSION $VERSION" --define "PRERELEASE $PRERELEASE"
echo $user_password|sudo -S rm -f /tmp/tmp* 
}

export VERSION='4.1'
export PRERELEASE='ga'
export build_spec_tmp_file='/tmp/build.spec'
export build_spec_home_dir='/home/centos/rpmbuild/SPECS/'
export build_spec_home_file='/home/centos/rpmbuild/SPECS/build.spec'
export user_password='welcome123'
export management_worker_service_rpm_file='/tmp/x86_64/cloudify-management-worker-*'

prepare_management_worker_service_build_file
build_management_worker_service_rpm_file

