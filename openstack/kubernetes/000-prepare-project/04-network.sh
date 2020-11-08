#!/bin/bash

openstack network create \
  --dns-domain os.se.lemche.net. \
  --internal \
  --no-default \
  --no-share \
  --project k8s_project \
  --tag kubernetes \
  k8s_network
