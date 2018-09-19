# TODO list

## Create roles ansible roles for:

- ~~[Kubernetes]~~
- Kubernetes dashboard
- [confd]
- [gogs]

## Incoperate into ansible roles:

- [Hashicorp Vault]
- [testssl.sh]
- [Suricata]
- [Sysdig]
- [Sysdig Falco]
- [Sysdig Inspect]

## Learn more about:

- ~~[OpenStack]~~
- [OpenVSwitch]
- [ELK]
- [Influxdb]
- [Grafana]
- [Graphite]
- [Cillium]
- [Fluentd]
- [Prometheus]
- [Terraform]
- [BOSH]
- [Nexus Repository OSS]
- [Istio]

## Evaluate if ...

- it's worth using [Molecule]
- ~~it's worth using [Vagrant]~~ - No its obsolete after the introduction of Docker and OpenStack
- sysdig is compatible with selinux
- ~~apparmor or selinux works best with containers~~ - Security Enhanced Linux is preferred
- ~~to use OWASP ZAP or Metasploit~~ Neither! Use [Cillium]

[bosh]: https://bosh.io/
[cillium]: https://github.com/cilium/cilium
[confd]: https://github.com/kelseyhightower/confd/blob/master/docs/installation.md
[elk]: https://www.elastic.co
[fluentd]: https://fluentd.io
[gogs]: https://github.com/gogits/gogs
[grafana]: https://grafana.com/
[graphite]: https://graphiteapp.org/
[hashicorp vault]: https://www.vaultproject.io/
[helm]: https://helm.sh/
[influxdb]: https://www.influxdata.com/
[istio]: https://istio.io
[kubernetes]: https://kubernetes.io/docs/setup/independent/install-kubeadm/
[molecule]: https://molecule.readthedocs.io/en/latest/installation.html
[nexus repository oss]: https://www.sonatype.com/nexus-repository-oss
[openstack]: https://www.openstack.org/software/start/
[openvswitch]: http://docs.openvswitch.org/en/latest/
[prometheus]: https://prometheus.io/
[suricata]: https://suricata-ids.org/docs/
[sysdig]: https://www.sysdig.org/install/
[sysdig falco]: https://github.com/draios/falco/wiki/How-to-Install-Falco-for-Linux
[sysdig inspect]: https://github.com/draios/sysdig-inspect
[terraform]: https://www.terraform.io/
[testssl.sh]: https://testssl.sh/
[vagrant]: https://www.vagrantup.com/downloads.html
