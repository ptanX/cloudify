#!/bin/bash


function prepare_amqp_influx_service_build_file()
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


Name:           cloudify-amqp-influx
Version:        %{VERSION}
Release:        %{PRERELEASE}
Summary:        Cloudify's AMQP InfluxDB Broker
Group:          Applications/Multimedia
License:        Apache 2.0
URL:            https://github.com/cloudify-cosmo/cloudify-amqp-influxdb
Vendor:         Gigaspaces Inc.
Prefix:         %{_prefix}
Packager:       Gigaspaces Inc.
BuildRoot:      %{_tmppath}/%{name}-root



%description
Cloudify's Broker pulls Cloudify formatted Metrics from RabbitMQ and posts them in InfluxDB.



%prep

set +e
pip=\$(which pip)
set -e

[ ! -z \$pip ] || sudo curl --show-error --silent --retry 5 https://bootstrap.pypa.io/get-pip.py | sudo python
sudo yum install -y git python-devel gcc
sudo pip install virtualenv
sudo virtualenv /tmp/env
sudo /tmp/env/bin/pip install setuptools==18.1 && \\
sudo /tmp/env/bin/pip install wheel==0.24.0 && \\

%build
%install

sudo /tmp/env/bin/pip wheel virtualenv --wheel-dir %{buildroot}/var/wheels/%{name} && \\
sudo /tmp/env/bin/pip wheel --wheel-dir=%{buildroot}/var/wheels/%{name} --find-links=%{buildroot}/var/wheels/%{name} http://10.84.20.220/cloudify_package_resource/cloudify-amqp-influxdb-master.tar.gz && \\



%pre
%post

pip install --use-wheel --no-index --find-links=/var/wheels/%{name} virtualenv && \\
if [ ! -d "/opt/amqpinflux/env" ]; then virtualenv /opt/amqpinflux/env; fi && \\
/opt/amqpinflux/env/bin/pip install --upgrade --force-reinstall --use-wheel --no-index --find-links=/var/wheels/%{name} cloudify-amqp-influxdb --pre


%preun
%postun

rm -rf /var/wheels/\${name}



%files

%defattr(-,root,root)
/var/wheels/%{name}/*.whl

EOF
}

function build_amqp_influx_service_rpm_file()
{
if [ ! -d $build_spec_home_dir ]; then
    mkdir -p $build_spec_home_dir
fi
if [ ! -f $build_spec_home_file ]; then
    cp $build_spec_tmp_file $build_spec_home_file 
else
    echo $user_password|sudo -S rm -f $build_spec_home_file && cp $build_spec_tmp_file $build_spec_home_file
fi
if [ -f $amqp_influx_service_rpm_file ]; then
    echo $user_password|sudo -S rm -f $amqp_influx_service_rpm_file
fi
echo 'Start building cloudify amqp-influxdb rpm file'
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
export amqp_influx_service_rpm_file='/tmp/x86_64/cloudify-cloudify-amqp-influx-*'

prepare_amqp_influx_service_build_file
build_amqp_influx_service_rpm_file


