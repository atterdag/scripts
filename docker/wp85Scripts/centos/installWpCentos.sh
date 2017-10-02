#!/bin/bash

/host/bin/prepareCentos.sh && \
/host/bin/createRuntimeUser.sh && \
/host/bin/installIM.sh && \
/host/bin/installWAS.sh && \
/host/bin/installWP.sh && \
/host/bin/installWPCF.sh && \
/host/bin/configureJava8.sh