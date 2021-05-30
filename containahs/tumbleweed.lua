FROM("docker://docker.io/opensuse/tumbleweed:latest", "devel")
RUN("zypper dup -y")
RUN("zypper install -y -t pattern devel_basis")
RUN("zypper install -y --no-recommends pcre-devel libopenssl-devel curl git go1.16 neovim")
SH("echo -n 'nameserver 127.255.255.53' > /etc/resolv.conf")
TAR("devel.tar")
COMMIT("devel:latest")

