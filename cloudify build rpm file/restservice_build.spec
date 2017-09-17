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
pip=$(which pip)
set -e

[ ! -z $pip ] || sudo curl --show-error --silent --retry 5 https://bootstrap.pypa.io/get-pip.py | sudo python
sudo yum install -y git python-devel postgresql-devel openldap-devel gcc gcc-c++
sudo pip install virtualenv
sudo virtualenv /tmp/env
sudo /tmp/env/bin/pip install -I pip==9.0.1 && \
sudo /tmp/env/bin/pip install -I setuptools==32.3.0 && \
sudo /tmp/env/bin/pip install -I wheel==0.24.0 && \
%build
%install

export REST_SERVICE_BUILD=True
default_version=%{CORE_TAG_NAME}
destination="/tmp/${RANDOM}.file"
curl --retry 10 --fail --silent --show-error --location  http://%{GITHUB_USERNAME}:%{GITHUB_PASSWORD}@git.vnpt-technology.vn/rest/archive/latest/projects/SSDC_NFVCLOUD/repos/cloudify-manager/archive?format=tgz --create-dirs --output $destination && \
tar -xzf $destination -C "/tmp" 
sudo mkdir -p %{buildroot}/opt/manager/resources/
sudo cp -R "/tmp/resources/rest-service/cloudify/" "%{buildroot}/opt/manager/resources/"

# ldappy is being install without a specific version, until it'll be stable..

sudo /tmp/env/bin/pip wheel virtualenv --wheel-dir %{buildroot}/var/wheels/%{name} && \
sudo /tmp/env/bin/pip wheel --wheel-dir=%{buildroot}/var/wheels/%{name} --find-links=%{buildroot}/var/wheels/%{name} http://%{GITHUB_USERNAME}:%{GITHUB_PASSWORD}@git.vnpt-technology.vn/rest/archive/latest/projects/SSDC_NFVCLOUD/repos/cloudify-dsl-parser/archive?format=tgz && \
sudo /tmp/env/bin/pip wheel --wheel-dir=%{buildroot}/var/wheels/%{name} --find-links=%{buildroot}/var/wheels/%{name} http://%{GITHUB_USERNAME}:%{GITHUB_PASSWORD}@git.vnpt-technology.vn/rest/archive/latest/projects/SSDC_NFVCLOUD/repos/cloudify-ldappy-master/archive?format=tgz && \
sudo -E /tmp/env/bin/pip wheel --wheel-dir=%{buildroot}/var/wheels/%{name} --find-links=%{buildroot}/var/wheels/%{name} /tmp/rest-service
cd %{buildroot}/var/wheels/%{name}
destination="%{buildroot}/var/wheels/%{name}/cloudify-premium-packages-4.1.tar.gz"
curl --retry 10 --fail --silent --show-error --location http://%{GITHUB_USERNAME}:%{GITHUB_PASSWORD}@git.vnpt-technology.vn/rest/archive/latest/projects/SSDC_NFVCLOUD/repos/cloudify-premium-packages/archive?format=tgz --create-dirs --output $destination


%pre
%post

export REST_SERVICE_BUILD=True

pip install --use-wheel --no-index --find-links=/var/wheels/%{name} virtualenv && \
if [ ! -d "/opt/manager/env" ]; then virtualenv /opt/manager/env; fi && \
/opt/manager/env/bin/pip install --upgrade --force-reinstall --use-wheel --no-index --find-links=/var/wheels/%{name} cloudify-dsl-parser --pre && \
/opt/manager/env/bin/pip install --upgrade --force-reinstall --use-wheel --no-index --find-links=/var/wheels/%{name} ldappy --pre && \
/opt/manager/env/bin/pip install --upgrade --force-reinstall --use-wheel --no-index --find-links=/var/wheels/%{name} cloudify-rest-service --pre
sudo usermod -a -G cfyuser cfyuser
sudo mkdir /var/wheels/%{name}/cloudify-premium-packages-4.1
cd /var/wheels/%{name}
sudo tar -zxvf cloudify-premium-packages-4.1.tar.gz -C cloudify-premium-packages-4.1 && sudo rm -f cloudify-premium-packages-4.1.tar.gz
sudo mv /var/wheels/%{name}/cloudify-premium-packages-4.1/create_cluster_node /opt/manager/env/bin/
sudo chown root:cfyuser  /opt/manager/env/bin/create_cluster_node  && sudo chmod 755 /opt/manager/env/bin/create_cluster_node
sudo mv /var/wheels/%{name}/cloudify-premium-packages-4.1/consul_watcher /opt/manager/env/bin/ 
sudo chown root:cfyuser  /opt/manager/env/bin/consul_watcher  && sudo chmod 755 /opt/manager/env/bin/consul_watcher
sudo mv /var/wheels/%{name}/cloudify-premium-packages-4.1/handler_runner /opt/manager/env/bin/
sudo chown root:cfyuser  /opt/manager/env/bin/handler_runner  && sudo chmod 755 /opt/manager/env/bin/handler_runner
sudo mv /var/wheels/%{name}/cloudify-premium-packages-4.1/recovery_watcher /opt/manager/env/bin/
sudo chown root:cfyuser  /opt/manager/env/bin/recovery_watcher  && sudo chmod 755 /opt/manager/env/bin/recovery_watcher
sudo mv /var/wheels/%{name}/cloudify-premium-packages-4.1/monotonic.py /opt/manager/env/lib/python2.7/site-packages/
sudo chown root:cfyuser  /opt/manager/env/lib/python2.7/site-packages/monotonic.py && sudo chmod 664 /opt/manager/env/lib/python2.7/site-packages/monotonic.py  
sudo cp -rap /var/wheels/%{name}/cloudify-premium-packages-4.1/* /opt/manager/env/lib/python2.7/site-packages/
sudo chown root:cfyuser -R /opt/manager/env/lib/python2.7/site-packages/ && sudo chmod 755 $(find /opt/manager/env/lib/python2.7/site-packages/ -type d) &&sudo chmod 664 $(find /opt/manager/env/lib/python2.7/site-packages/ -type f)


%preun
%postun

rm -rf /opt/manager/resources
rm -rf /var/wheels/${name}


%files

%defattr(-,root,root)
/var/wheels/%{name}/*.whl
/var/wheels/%{name}/cloudify-premium-packages-4.1.tar.gz
/opt/manager/resources

