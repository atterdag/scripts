cd /srv/git/ibm-docker/build/ubuntu-trusty && \
cat /net/main/srv/common-setup/ssl/cacert.pem > ExampleCA.crt && \
DATE=$(date +%Y%m%d) && \
time docker build --build-arg DATE=$DATE --build-arg http_proxy=$http_proxy --build-arg https_proxy=$https_proxy --build-arg ftp_proxy=$ftp_proxy --build-arg no_proxy=$no_proxy --tag registry.example.com:5000/ubuntu-trusty:$DATE --tag registry.example.com:5000/ubuntu-trusty:latest --file ./Dockerfile . 2>&1 | tee /tmp/docker_file_ubuntu-trusty.$(date +"%Y%m%d_%H%M%S").txt.out && \
docker image push registry.example.com:5000/ubuntu-trusty:$DATE && \
docker image push registry.example.com:5000/ubuntu-trusty:latest && \
cd /srv/git/ibm-docker/build/ubuntu-trusty-was855ga && \
time docker build --tag registry.example.com:5000/ubuntu-trusty-was:8550 --tag registry.example.com:5000/ubuntu-trusty-was855:ga --file ./Dockerfile . 2>&1 | tee /tmp/docker_file_ubuntu-trusty-was855ga.$(date +"%Y%m%d_%H%M%S").txt.out && \
docker image push registry.example.com:5000/ubuntu-trusty-was855:0 && \
docker image push registry.example.com:5000/ubuntu-trusty-was855:ga && \
cd /srv/git/ibm-docker/build/ubuntu-trusty-was855fp && \
export WAS_FP_TAG=11 && \
time docker build --build-arg WAS_FP_TAG=$WAS_FP_TAG --build-arg WAS_FP=85511 --build-arg JDK70_FP=70960 --build-arg JDK71_FP=71360 --build-arg JDK80_FP=80320 --tag registry.example.com:5000/ubuntu-trusty-was855:$WAS_FP_TAG --tag registry.example.com:5000/ubuntu-trusty-was855:latest --file ./Dockerfile . 2>&1 | tee /tmp/docker_file_ubuntu-trusty-was855.$(date +"%Y%m%d_%H%M%S").txt.out && \
docker image push registry.example.com:5000/ubuntu-trusty-was855:$WAS_FP_TAG && \
export WAS_FP_TAG=12 && \
time docker build --build-arg WAS_FP_TAG=$WAS_FP_TAG --build-arg WAS_FP=85512 --build-arg JDK70_FP=70105 --build-arg JDK71_FP=7145 --build-arg JDK80_FP=8045 --tag registry.example.com:5000/ubuntu-trusty-was855:$WAS_FP_TAG --tag registry.example.com:5000/ubuntu-trusty-was855:latest --file ./Dockerfile . 2>&1 | tee /tmp/docker_file_ubuntu-trusty-was855.$(date +"%Y%m%d_%H%M%S").txt.out
docker image push registry.example.com:5000/ubuntu-trusty-was855:$WAS_FP_TAG && \
docker image push registry.example.com:5000/ubuntu-trusty-was855:latest && \
cd /srv/git/ibm-docker/build/ubuntu-trusty-ihs855ga && \
time docker build --tag registry.example.com:5000/ubuntu-trusty-ihs855:ga --tag registry.example.com:5000/ubuntu-trusty-ihs855:0 --file ./Dockerfile . 2>&1 | tee /tmp/docker_file_ubuntu-trusty-ihs855.$(date +"%Y%m%d_%H%M%S").txt.out && \
docker image push registry.example.com:5000/ubuntu-trusty-ihs855:0 && \
docker image push registry.example.com:5000/ubuntu-trusty-ihs855:ga && \
cd /srv/git/ibm-docker/build/ubuntu-trusty-ihs855fp && \
export IHS_FP_TAG=11 && \
time docker build --build-arg IHS_FP_TAG=$IHS_FP_TAG --build-arg IHS_FP=85511 --tag registry.example.com:5000/ubuntu-trusty-ihs855:$IHS_FP_TAG --tag registry.example.com:5000/ubuntu-trusty-ihs855:latest --file ./Dockerfile . 2>&1 | tee /tmp/docker_file_ubuntu-trusty-was855.$(date +"%Y%m%d_%H%M%S").txt.out && \
docker image push registry.example.com:5000/ubuntu-trusty-ihs855:$IHS_FP_TAG && \
docker image push registry.example.com:5000/ubuntu-trusty-ihs855:latest && \
export IHS_FP_TAG=12 && \
time docker build --build-arg IHS_FP_TAG=$IHS_FP_TAG --build-arg IHS_FP=85512 --tag registry.example.com:5000/ubuntu-trusty-ihs855:$IHS_FP_TAG --tag registry.example.com:5000/ubuntu-trusty-ihs855:latest --file ./Dockerfile . 2>&1 | tee /tmp/docker_file_ubuntu-trusty-was855.$(date +"%Y%m%d_%H%M%S").txt.out && \
docker image push registry.example.com:5000/ubuntu-trusty-ihs855:$IHS_FP_TAG && \
docker image push registry.example.com:5000/ubuntu-trusty-ihs855:latest
