# TODO list

## Create roles ansible roles for:

- [confd] that use etcd
- ~~[etcd]~~
- [gogs]
- ~~[Kubernetes]~~
- Kubernetes dashboard

## Incoperate into ansible roles:

- [Suricata]
- [Sysdig Falco]
- [Sysdig Inspect]
- [Sysdig]
- [testssl.sh]
- ~~[Hashicorp Vault]~~ Hashicorp Vault is shit.

## Learn more about:

- [BOSH]
- [Cillium]
- [Conjur]
- [ELK]
- [Fluentd]
- [Grafana]
- [Graphite]
- [Harbor]
- [Helm]
- [Influxdb]
- [Istio]
- [Knative]
- [Kubeflow]
- [KubeMQ]
- [netbox]
- [Nexus Repository OSS]
- [OKD]
- [OpenVSwitch]
- [Prometheus]
- [Pulp]
- [Fission]
- [Tekton]
- [Terraform]
- [traefik]
- ~~[OpenStack]~~
- Kubernetes based artifact repositories
- [Clair]
- [Gitolite]

## Evaluate if ...

- it's worth using [Molecule]
- ~~it's worth using [Vagrant]~~ - No its obsolete after the introduction of Docker and OpenStack
- sysdig is compatible with selinux
- ~~apparmor or selinux works best with containers~~ - Security Enhanced Linux is preferred
- ~~to use OWASP ZAP or Metasploit~~ Neither! Use [Cillium]

[bosh]: https://bosh.io/
[cillium]: https://github.com/cilium/cilium
[clair]: https://github.com/quay/clair
[confd]: https://github.com/kelseyhightower/confd/blob/master/docs/installation.md
[conjur]: https://www.conjur.org/
[elk]: https://www.elastic.co
[etcd]: https://etcd.io/
[fission]: https://fission.io
[fluentd]: https://fluentd.org
[gitolite]: https://gitolite.com
[gogs]: https://github.com/gogits/gogs
[grafana]: https://grafana.com/
[graphite]: https://graphiteapp.org/
[harbor]: https://goharbor.io/
[hashicorp vault]: https://www.vaultproject.io/
[helm]: https://helm.sh/
[influxdb]: https://www.influxdata.com/
[istio]: https://istio.io
[knative]: https://knative.dev/
[kubeflow]: https://www.kubeflow.org/
[kubemq]: https://kubemq.io/
[kubernetes]: https://kubernetes.io/docs/setup/independent/install-kubeadm/
[molecule]: https://molecule.readthedocs.io/en/latest/installation.html
[netbox]: https://netbox.readthedocs.io/en/stable/installation/
[nexus repository oss]: https://www.sonatype.com/nexus-repository-oss
[okd]: https://www.okd.io/
[openstack]: https://www.openstack.org/software/start/
[openvswitch]: http://docs.openvswitch.org/en/latest/
[prometheus]: https://prometheus.io/
[pulp]: https://pulpproject.org/
[suricata]: https://suricata-ids.org/docs/
[sysdig]: https://www.sysdig.org/install/
[sysdig falco]: https://github.com/draios/falco/wiki/How-to-Install-Falco-for-Linux
[sysdig inspect]: https://github.com/draios/sysdig-inspect
[tekton]: https://tekton.dev/
[terraform]: https://www.terraform.io/
[testssl.sh]: https://testssl.sh/
[traefik]: https://docs.traefik.io/
[vagrant]: https://www.vagrantup.com/downloads.html
