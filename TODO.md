# TODO list

## Create roles ansible roles for:

- ~~[Kubernetes]~~
- Kubernetes dashboard
- [confd]
- [gogs]

## Incoperate into ansible roles:
- Hashicorp vault
- [testssl.sh]
- [Suricata]
- [Sysdig]
- [Sysdig Falco]
- [Sysdig Inspect]

## Learn more about:
- [OpenStack]
- [OpenVSwitch]
- [Kibana]
- [Elk]
- [Cillium]
- [Fluentd]
- Prometheus
- Terraform
- BOSH

## Evaluate if ...
- it's worth using [Molecule]
- ~~it's worth using [Vagrant]~~ - No its obsolete after the introduction of Docker and OpenStack
- sysdig is compatible with selinux
- ~~apparmor or selinux works best with containers~~ - Security Enhanced Linux is preferred
-  ~~to use OWASP ZAP or Metasploit~~ Neither! Use [Cillium]

[Kubernetes]: https://kubernetes.io/docs/setup/independent/install-kubeadm/
[confd]: https://github.com/kelseyhightower/confd/blob/master/docs/installation.md
[gogs]: https://github.com/gogits/gogs
[testssl.sh]: https://testssl.sh/
[Suricata]: https://suricata-ids.org/docs/
[Sysdig]: https://www.sysdig.org/install/
[Sysdig Falco]: https://github.com/draios/falco/wiki/How-to-Install-Falco-for-Linux
[Sysdig Inspect]: https://github.com/draios/sysdig-inspect
[OpenStack]: https://www.openstack.org/software/start/
[OpenVSwitch]: http://docs.openvswitch.org/en/latest/
[Molecule]: http://docs.openvswitch.org/en/latest/
[Vagrant]: http://docs.openvswitch.org/en/latest/
[Molecule]: https://molecule.readthedocs.io/en/latest/installation.html
[Vagrant]: https://www.vagrantup.com/downloads.html
[Cillium]: https://github.com/cilium/cilium
[Fluentd]: https://fluentd.io
