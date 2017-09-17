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
pip=$(which pip)
set -e

[ ! -z $pip ] || sudo curl --show-error --silent --retry 5 https://bootstrap.pypa.io/get-pip.py | sudo python
sudo yum install -y git python-devel postgresql-devel gcc gcc-c++
sudo pip install virtualenv
sudo virtualenv /tmp/env
sudo /tmp/env/bin/pip install -I setuptools==18.1 && \
sudo /tmp/env/bin/pip install -I wheel==0.24.0 && \

%build
%install

destination="/tmp/${RANDOM}.file"
curl --retry 10 --fail --silent --show-error --location http://%{GITHUB_USERNAME}:%{GITHUB_PASSWORD}@git.vnpt-technology.vn/rest/archive/latest/projects/SSDC_NFVCLOUD/repos/cloudify-manager/archive?format=tgz --create-dirs --output $destination && \
tar -xzf $destination -C "/tmp" && \

sudo /tmp/env/bin/pip wheel virtualenv --wheel-dir %{buildroot}/var/wheels/%{name} && \
sudo /tmp/env/bin/pip wheel --wheel-dir=%{buildroot}/var/wheels/%{name} --find-links=%{buildroot}/var/wheels/%{name} http://%{GITHUB_USERNAME}:%{GITHUB_PASSWORD}@git.vnpt-technology.vn/rest/archive/latest/projects/SSDC_NFVCLOUD/repos/cloudify-rest-client/archive?format=tgz && \
sudo /tmp/env/bin/pip wheel --wheel-dir=%{buildroot}/var/wheels/%{name} --find-links=%{buildroot}/var/wheels/%{name} http://%{GITHUB_USERNAME}:%{GITHUB_PASSWORD}@git.vnpt-technology.vn/rest/archive/latest/projects/SSDC_NFVCLOUD/repos/cloudify-plugins-common/archive?format=tgz && \
sudo /tmp/env/bin/pip wheel --wheel-dir=%{buildroot}/var/wheels/%{name} --find-links=%{buildroot}/var/wheels/%{name} http://%{GITHUB_USERNAME}:%{GITHUB_PASSWORD}@git.vnpt-technology.vn/rest/archive/latest/projects/SSDC_NFVCLOUD/repos/cloudify-plugins-script/archive?format=tgz && \
sudo /tmp/env/bin/pip wheel --wheel-dir=%{buildroot}/var/wheels/%{name} --find-links=%{buildroot}/var/wheels/%{name} http://%{GITHUB_USERNAME}:%{GITHUB_PASSWORD}@git.vnpt-technology.vn/rest/archive/latest/projects/SSDC_NFVCLOUD/repos/cloudify-agent/archive?format=tgz && \
sudo /tmp/env/bin/pip wheel --wheel-dir=%{buildroot}/var/wheels/%{name} --find-links=%{buildroot}/var/wheels/%{name} http://%{GITHUB_USERNAME}:%{GITHUB_PASSWORD}@git.vnpt-technology.vn/rest/archive/latest/projects/SSDC_NFVCLOUD/repos/cloudify-psycopg/archive?format=zip && \
sudo /tmp/env/bin/pip wheel --wheel-dir=%{buildroot}/var/wheels/%{name} --find-links=%{buildroot}/var/wheels/%{name} /tmp/plugins/riemann-controller
sudo /tmp/env/bin/pip wheel --wheel-dir=%{buildroot}/var/wheels/%{name} --find-links=%{buildroot}/var/wheels/%{name} /tmp/workflows




%pre
%post

pip install --use-wheel --no-index --find-links=/var/wheels/%{name} virtualenv && \
if [ ! -d "/opt/mgmtworker/env" ]; then virtualenv /opt/mgmtworker/env; fi && \
/opt/mgmtworker/env/bin/pip install --upgrade --force-reinstall --use-wheel --no-index --find-links=/var/wheels/%{name} cloudify-rest-client --pre && \
/opt/mgmtworker/env/bin/pip install --upgrade --force-reinstall --use-wheel --no-index --find-links=/var/wheels/%{name} cloudify-plugins-common --pre && \
/opt/mgmtworker/env/bin/pip install --upgrade --force-reinstall --use-wheel --no-index --find-links=/var/wheels/%{name} cloudify-script-plugin --pre && \
/opt/mgmtworker/env/bin/pip install --upgrade --force-reinstall --use-wheel --no-index --find-links=/var/wheels/%{name} cloudify-agent --pre && \
/opt/mgmtworker/env/bin/pip install --upgrade --force-reinstall --use-wheel --no-index --find-links=/var/wheels/%{name} psycopg2 --pre && \
/opt/mgmtworker/env/bin/pip install --upgrade --force-reinstall --use-wheel --no-index --find-links=/var/wheels/%{name} cloudify-riemann-controller-plugin --pre && \
/opt/mgmtworker/env/bin/pip install --upgrade --force-reinstall --use-wheel --no-index --find-links=/var/wheels/%{name} cloudify-workflows --pre





%preun
%postun

rm -rf /var/wheels/${name}


%files

%defattr(-,root,root)
/var/wheels/%{name}/*.whl
