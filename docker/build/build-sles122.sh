##############################################################################
# Create SLES12 base image
sle2docker activate sles12sp2-docker.x86_64-1.0.0-Build3.2
cd /srv/git/ibm-docker/build/sles122
cat /net/main/srv/common-setup/ssl/cacert.pem > ExampleCA.crt
(cd /net/main/srv/bin; tar --verbose --create --file ${OLDPWD}/sles12-repositories.tar.gz --gzip add-sles12-SLE-*)
DATE=$(date +%Y%m%d)
time docker build --build-arg DATE=$DATE --build-arg http_proxy=$http_proxy --build-arg https_proxy=$https_proxy --build-arg ftp_proxy=$ftp_proxy --build-arg no_proxy=$no_proxy --tag registry.example.com:5000/sles122:$DATE --tag registry.example.com:5000/sles122:latest --file ./Dockerfile . 2>&1 | tee /tmp/docker_file_sles122.$(date +"%Y%m%d_%H%M%S").txt.out
docker image push registry.example.com:5000/sles122:$DATE
docker image push registry.example.com:5000/sles122:latest

##############################################################################
# Installing IM 1.8.5.0
cd /srv/git/ibm-docker/build/sles122-imga
time docker build --tag registry.example.com:5000/sles122-im:1850 --file ./Dockerfile . 2>&1 | tee /tmp/docker_file_sles122-im.$(date +"%Y%m%d_%H%M%S").txt.out
docker image push registry.example.com:5000/sles122-im:1850

##############################################################################
# Installing IMFPS 1.8.7.0
cd /srv/git/ibm-docker/build/sles122-imfp
export IM_FP=1870
time docker build --build-arg IM_FP=$IM_FP --tag registry.example.com:5000/sles122-im:$IM_FP --tag registry.example.com:5000/sles122-im:latest --file ./Dockerfile . 2>&1 | tee /tmp/docker_file_sles122-im.$(date +"%Y%m%d_%H%M%S").txt.out
docker image push registry.example.com:5000/sles122-im:$IM_FP
docker image push registry.example.com:5000/sles122-im:latest

##############################################################################
# Installing WAS 8.5.5.0 (GA)
cd /srv/git/ibm-docker/build/sles122-was855ga
time docker build --tag registry.example.com:5000/sles122-was:8550 --file ./Dockerfile . 2>&1 | tee /tmp/docker_file_sles122-wasga.$(date +"%Y%m%d_%H%M%S").txt.out
docker image push registry.example.com:5000/sles122-was:8550

##############################################################################
# Installing WAS 8.5.5 FPS
cd /srv/git/ibm-docker/build/sles122-was855fp

##############################################################################
# Installing 8.5.5.11 (Fixpack 11)
export WAS_FP_TAG=85511
time docker build --build-arg WAS_FP_TAG=$WAS_FP_TAG --build-arg WAS_FP=85511 --build-arg JDK70_FP=70960 --build-arg JDK71_FP=71360 --build-arg JDK80_FP=80320 --tag registry.example.com:5000/sles122-was:$WAS_FP_TAG --tag registry.example.com:5000/sles122-was:latest --file ./Dockerfile . 2>&1 | tee /tmp/docker_file_sles122-was.$(date +"%Y%m%d_%H%M%S").txt.out
docker image push registry.example.com:5000/sles122-was:$WAS_FP_TAG
docker image push registry.example.com:5000/sles122-was:latest

##############################################################################
# Installing 8.5.5.12 (Fixpack 12)
export WAS_FP_TAG=85512
time docker build --build-arg WAS_FP_TAG=$WAS_FP_TAG --build-arg WAS_FP=85512 --build-arg JDK70_FP=70105 --build-arg JDK71_FP=7145 --build-arg JDK80_FP=8045 --tag registry.example.com:5000/sles122-was:$WAS_FP_TAG --tag registry.example.com:5000/sles122-was:latest --file ./Dockerfile . 2>&1 | tee /tmp/docker_file_sles122-was.$(date +"%Y%m%d_%H%M%S").txt.out
docker image push registry.example.com:5000/sles122-was:$WAS_FP_TAG
docker image push registry.example.com:5000/sles122-was:latest

##############################################################################
# Installing IHS 8.5.5.0 (GA)
cd /srv/git/ibm-docker/build/sles122-ihs855ga
time docker build --tag registry.example.com:5000/sles122-ihs:8550 --file ./Dockerfile . 2>&1 | tee /tmp/docker_file_sles122-ihs855.$(date +"%Y%m%d_%H%M%S").txt.out
docker image push registry.example.com:5000/sles122-ihs:8550

##############################################################################
# Installing IHS 8.5.5 FPS
cd /srv/git/ibm-docker/build/sles122-ihs855fp

##############################################################################
# Installing 8.5.5.11 (Fixpack 11)
export IHS_FP_TAG=85511
time docker build --build-arg IHS_FP_TAG=$IHS_FP_TAG --build-arg IHS_FP=85511 --build-arg PLG_FP=85511 --build-arg WCT_FP=85511 --tag registry.example.com:5000/sles122-ihs:$IHS_FP_TAG --tag registry.example.com:5000/sles122-ihs:latest --file ./Dockerfile . 2>&1 | tee /tmp/docker_file_sles122-ihs855.$(date +"%Y%m%d_%H%M%S").txt.out
docker image push registry.example.com:5000/sles122-ihs:$IHS_FP_TAG
docker image push registry.example.com:5000/sles122-ihs:latest

##############################################################################
# Installing 8.5.5.12 (Fixpack 12)
export IHS_FP_TAG=85512
time docker build --build-arg IHS_FP_TAG=$IHS_FP_TAG --build-arg IHS_FP=85512 --build-arg PLG_FP=85512 --build-arg WCT_FP=85512 --tag registry.example.com:5000/sles122-ihs:$IHS_FP_TAG --tag registry.example.com:5000/sles122-ihs:latest --file ./Dockerfile . 2>&1 | tee /tmp/docker_file_sles122-ihs855.$(date +"%Y%m%d_%H%M%S").txt.out
docker image push registry.example.com:5000/sles122-ihs:$IHS_FP_TAG
docker image push registry.example.com:5000/sles122-ihs:latest

##############################################################################
# Installing creating primary node
cd /srv/git/ibm-docker/build/sles122-was-primary-node
export VERSION=85512
time docker build --build-arg VERSION=$VERSION --tag registry.example.com:5000/sles122-was-primary-node:$VERSION --tag registry.example.com:5000/sles122-was-primary-node:latest --file ./Dockerfile . 2>&1 | tee /tmp/docker_file_sles122-was-primary-node.$(date +"%Y%m%d_%H%M%S").txt.out
docker image push registry.example.com:5000/sles122-was-primary-node:$VERSION
docker image push registry.example.com:5000/sles122-was-primary-node:latest

