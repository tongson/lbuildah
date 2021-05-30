FROM("gcr.io/distroless/static", "pod")
MKDIR("/etc/coredns")
UPLOAD("pod/Corefile", "/etc/coredns/Corefile")
UPLOAD("pod/coredns", "/bin/coredns")
UPLOAD("pod/dhclient", "/bin/dhclient")
UPLOAD("pod/init", "/bin/init")
ENTRYPOINT("/bin/init")
CONFIG.CMD = [[-pre "/bin/dhclient -d -v 4 -r 99 -i lan0" -main "/bin/coredns -conf /etc/coredns/Corefile"]]
COMMIT("pod:latest")
