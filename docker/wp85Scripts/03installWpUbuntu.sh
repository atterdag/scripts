#!/bin/bash

/host/bin/04prepareUbuntu.sh && \
/host/bin/05createRuntimeUser.sh && \
/host/bin/06installIM.sh && \
/host/bin/07installWAS.sh && \
/host/bin/08installWP.sh && \
/host/bin/09installWPCF.sh && \
/host/bin/10configureJava8.sh
