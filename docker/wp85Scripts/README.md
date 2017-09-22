# Scripts to install Portal on Docker

Edit `properties.sh` to define your environment

## Running order
1. `01createNetwork.sh` to create a user defined network
2. `02createUbuntuContainer.sh` will create a ubuntu:trusty container, and install Portal inside it.


## The following scripts are called by *createUbuntuContainer.sh*
* `03configureJava8.sh`
* `04createRuntimeUser.sh`
* `05installIM.sh`
* `06installWAS.sh`
* `07installWPCF.sh`
* `08installWP.sh`
* `09installWPCF.sh`
* `10configureJava8.sh`
* `11-commitUbuntuContainer.sh`
* `12-runWpContainer.sh`

## Old Centos specific scripts
* `centos/createCentosContainer.sh`
* `centos/prepareCentos.sh`
* `centos/installWpCentos.sh`

## Scripts that are copied to container during creation
* `add-proxyenv.sh`
