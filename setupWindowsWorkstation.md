# Install Windows Features

```
Enable-WindowsOptionalFeature -Online -FeatureName:Microsoft-Hyper-V -All
Enable-WindowsOptionalFeature -Online -FeatureName:Microsoft-Windows-Subsystem-Linux -All
Enable-WindowsOptionalFeature -Online -FeatureName:TelnetClient -All
```

# Install Chocolatey

```
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
```

## Install Git Chocolatey package

```
choco install git --params="'/GitAndUnixToolsOnPath /NoAutoCrlf'" -y
```

## Install additional Chocolatey packages

```
choco install -y git-lfs logitech-options vcxsrv ConEmu TortoiseGit putty winscp docker-for-windows minikube Atom kubernetes-cli notepadplusplus googlechrome atom 7zip sysinternals nodejs docker-kitematic vscode-docker VisualStudioCode vscode-icons vscode-gitignore vscode-gitattributes vscode-powershell vscode-editorconfig openinvscode python2 eclipse jdk8 jre8 maven groovy tightvnc jmeter openvpn rsync curl StrawberryPerl findandreplace
```

Configure Git to use plink as SSH command (i.e. so that it supports PuTTY Pageant)

```
setx /M GIT_SSH "%ProgramFiles%\PuTTY\plink.exe"
```

# Install ansible

```
pip install ansible
```

# Install Atom packages

```
apm install atom-jinja2 autocomplete-json autocomplete-python browse busy-signal column-select console-panel duplicate-line-or-selection edit-in-new-tab highlight-selected intentions language-ansible language-docker language-ini linter linter-perl linter-ui-default logo-file-icons markdown-preview-plus markdown-toc markdown-writer minimap minimap-linter minimap-selection minimap-split-diff modular-snippets perltidy pretty-json Remote-FTP set-syntax split-diff tidy-markdown toggler tool-bar
```

# Installing [Eclipse Memory Analyzer] (MAT)

```
wget "http://www.eclipse.org/downloads/download.php?file=/mat/1.7/rcp/MemoryAnalyzer-1.7.0.20170613-linux.gtk.x86_64.zip&mirror_id=1" -O /tmp/MemoryAnalyzer-1.7.0.20170613-linux.gtk.x86_64.zip
unzip -d /opt /tmp/MemoryAnalyzer-1.7.0.20170613-linux.gtk.x86_64.zip
```

Installing [IBM Diagnostic Tool Framework for Java] plugins

```
/opt/mat/MemoryAnalyzer -debug -console -nosplash -application org.eclipse.equinox.p2.director -repository http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/dtfj/ -destination /opt/mat -installIU com.ibm.dtfj.feature.feature.group -consoleLog
```

Installing [IBM Extensions for Memory Analyzer] plugins

```
/opt/mat/MemoryAnalyzer -debug -console -nosplash -application org.eclipse.equinox.p2.director -repository http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/iema/ -destination /opt/mat -installIU com.ibm.java.diagnostics.memory.analyzer.ctg.feature.feature.group -consoleLog
/opt/mat/MemoryAnalyzer -debug -console -nosplash -application org.eclipse.equinox.p2.director -repository http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/iema/ -destination /opt/mat -installIU com.ibm.java.diagnostics.memory.analyzer.cognosbi.feature.feature.group -consoleLog
/opt/mat/MemoryAnalyzer -debug -console -nosplash -application org.eclipse.equinox.p2.director -repository http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/iema/ -destination /opt/mat -installIU com.ibm.java.diagnostics.memory.analyzer.jse.feature.feature.group -consoleLog
/opt/mat/MemoryAnalyzer -debug -console -nosplash -application org.eclipse.equinox.p2.director -repository http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/iema/ -destination /opt/mat -installIU com.ibm.java.diagnostics.memory.analyzer.util.feature.feature.group -consoleLog
/opt/mat/MemoryAnalyzer -debug -console -nosplash -application org.eclipse.equinox.p2.director -repository http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/iema/ -destination /opt/mat -installIU com.ibm.java.diagnostics.memory.analyzer.was.feature.feature.group -consoleLog
/opt/mat/MemoryAnalyzer -debug -console -nosplash -application org.eclipse.equinox.p2.director -repository http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/iema/ -destination /opt/mat -installIU com.ibm.java.diagnostics.memory.analyzer.wesb.feature.feature.group -consoleLog
/opt/mat/MemoryAnalyzer -debug -console -nosplash -application org.eclipse.equinox.p2.director -repository http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/iema/ -destination /opt/mat -installIU com.ibm.java.diagnostics.memory.analyzer.wps.feature.feature.group -consoleLog
```

Increase the maximum HEAP size for MAT

```
sed -i 's/-Xmx.*/-Xmx4096m/' /opt/mat/MemoryAnalyzer.ini
```

Install [IBM Health Center] plugin in Eclipse

```
/opt/eclipse/eclipse -debug -console -nosplash -application org.eclipse.equinox.p2.director -repository http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/ -destination /opt/mat -installIU com.ibm.java.diagnostics.healthcenter.gui.feature.feature.group -consoleLog
```

```
/opt/mat/MemoryAnalyzer -debug -console -nosplash -application org.eclipse.equinox.p2.director -repository http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/iema/ -destination /opt/mat -installIU com.ibm.iema.feature.feature.group -consoleLog
```

- [IBM Garbage Collection and Memory Visualizer]
- [IBM Monitoring and Diagnostic Tools]
- [IBM Interactive Diagnostic Data Explorer]

[ibm diagnostic tool framework for java]: http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/dtfj/
[ibm extensions for memory analyzer]: http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/iema/
[ibm garbage collection and memory visualizer]: http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/gcmv/
[ibm health center]: http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/healthcenter/
[ibm interactive diagnostic data explorer]: http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/idde/
[ibm monitoring and diagnostic tools]: http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools
