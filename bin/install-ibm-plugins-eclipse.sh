IBM Diagnostic Tool Framework for Java
http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/dtfj/
IBM Extensions for Memory Analyzer
http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/iema/
IBM Monitoring and Diagnostic Tools
http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools

Garbage Collection and Memory Visualizer
http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/gcmv/
Health Center
http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/healthcenter/
Interactive Diagnostic Data Explorer
http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/idde/

/opt/mat/MemoryAnalyzer -debug -console -nosplash -application org.eclipse.equinox.p2.director -repository http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/iema/ -destination /opt/mat -installIU com.ibm.java.diagnostics.memory.analyzer.ctg.feature.feature.group -consoleLog
/opt/mat/MemoryAnalyzer -debug -console -nosplash -application org.eclipse.equinox.p2.director -repository http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/iema/ -destination /opt/mat -installIU com.ibm.java.diagnostics.memory.analyzer.cognosbi.feature.feature.group -consoleLog
/opt/mat/MemoryAnalyzer -debug -console -nosplash -application org.eclipse.equinox.p2.director -repository http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/iema/ -destination /opt/mat -installIU com.ibm.java.diagnostics.memory.analyzer.jse.feature.feature.group -consoleLog
/opt/mat/MemoryAnalyzer -debug -console -nosplash -application org.eclipse.equinox.p2.director -repository http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/iema/ -destination /opt/mat -installIU com.ibm.java.diagnostics.memory.analyzer.util.feature.feature.group -consoleLog
/opt/mat/MemoryAnalyzer -debug -console -nosplash -application org.eclipse.equinox.p2.director -repository http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/iema/ -destination /opt/mat -installIU com.ibm.java.diagnostics.memory.analyzer.was.feature.feature.group -consoleLog
/opt/mat/MemoryAnalyzer -debug -console -nosplash -application org.eclipse.equinox.p2.director -repository http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/iema/ -destination /opt/mat -installIU com.ibm.java.diagnostics.memory.analyzer.wesb.feature.feature.group -consoleLog
/opt/mat/MemoryAnalyzer -debug -console -nosplash -application org.eclipse.equinox.p2.director -repository http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/iema/ -destination /opt/mat -installIU com.ibm.java.diagnostics.memory.analyzer.wps.feature.feature.group -consoleLog

/opt/mat/MemoryAnalyzer -debug -console -nosplash -application org.eclipse.equinox.p2.director -repository http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/iema/ -destination /opt/mat -installIU com.ibm.iema.feature.feature.group -consoleLog

/opt/mat/MemoryAnalyzer -debug -console -nosplash -application org.eclipse.equinox.p2.director -repository http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/ -destination /opt/mat -installIU com.ibm.java.diagnostics.healthcenter.gui.feature.feature.group -consoleLog

wget http://eclipse.bluemix.net/packages/oxygen/data/eclipse-java-oxygen-R-linux-gtk-x86_64.tar.gz -O /tmp/eclipse-java-oxygen-R-linux-gtk-x86_64.tar.gz
tar zxf /tmp/eclipse-java-oxygen-R-linux-gtk-x86_64.tar.gz -C /opt
/opt/eclipse/eclipse -debug -console -nosplash -application org.eclipse.equinox.p2.director -repository http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/ -destination /opt/mat -installIU com.ibm.java.diagnostics.healthcenter.gui.feature.feature.group -consoleLog
