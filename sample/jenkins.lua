require("buildah")
FROM("docker://docker.io/adoptopenjdk/openjdk11:jdk-11.0.10_9-debianslim-slim")
APT_GET("update")
APT_GET("upgrade")
APT_GET("install git git-lfs curl gpg gnupg-agent unzip libfreetype6 libfontconfig1")
RUN("git lfs install")
RM("/var/lib/apt/lists/")

user = "jenkins"
group = "jenkins"
uid = 1000
gid = 1000
http_port = 8080
agent_port = 50000
JENKINS_HOME = "/var/jenkins_home"
REF = "/usr/share/jenkins/ref"

CONFIG.ENV = "JENKINS_HOME=%s" % JENKINS_HOME
CONFIG.ENV = "JENKINS_SLAVE_AGENT_PORT=%s" % agent_port
CONFIG.ENV = "REF=%s" % REF

-- Jenkins is run with user `jenkins`, uid = 1000
-- If you bind mount a volume from the host or a data container,
-- ensure you use the same uid
MKDIR(JENKINS_HOME)
RUN("chown %s:%s %s" % { uid, gid, JENKINS_HOME })
RUN("groupadd -g %s %s" % { gid, group })
RUN("useradd -d %s -u %s -g %s -m -s /bin/bash %s" % { JENKINS_HOME, uid, gid, user })

-- Jenkins home directory is a volume, so configuration and build history
-- can be persisted and survive image upgrades
CONFIG.VOLUME = JENKINS_HOME

-- $REF (defaults to `/usr/share/jenkins/ref/`) contains all reference configuration we want
-- to set on a fresh new installation. Use it to bundle additional plugins
-- or config file with your custom jenkins Docker image.
MKDIR("%s/init.groovy.d" % REF)

-- Use tini as subreaper in Docker container to adopt zombie processes
COPY("tini_pub.gpg")
install_tini = [[
set -efu
TINI_VERSION=v0.16.1
curl -fsSL https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static-$(dpkg --print-architecture) -o /sbin/tini
curl -fsSL https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static-$(dpkg --print-architecture).asc -o /sbin/tini.asc 
gpg --no-tty --import /tini_pub.gpg 
gpg --verify /sbin/tini.asc
rm -rf /sbin/tini.asc /root/.gnupg
chmod +x /sbin/tini
rm /tini_pub.gpg
]]
SH(install_tini)

-- jenkins version being bundled in this docker image
JENKINS_VERSION = "2.235.4"
CONFIG.ENV = "JENKINS_VERSION=%s" % JENKINS_VERSION

-- jenkins.war checksum, download will be validated using it
JENKINS_SHA = "e5688a8f07cc3d79ba3afa3cab367d083dd90daab77cebd461ba8e83a1e3c177"

-- Can be used to customize where jenkins.war get downloaded from
JENKINS_URL = "https://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/%s/jenkins-war-%s.war"
	% { JENKINS_VERSION, JENKINS_VERSION }

-- could use ADD but this one does not check Last-Modified header neither does it allow to control checksum
-- see https://github.com/docker/docker/issues/8331
RUN("curl -fsSL %s -o /usr/share/jenkins/jenkins.war" % JENKINS_URL)
SH([[echo "%s" /usr/share/jenkins/jenkins.war | sha256sum -c -]] % JENKINS_SHA)

CONFIG.ENV = "JENKINS_UC=https://updates.jenkins.io"
CONFIG.ENV = "JENKINS_UC_EXPERIMENTAL=https://updates.jenkins.io/experimental"
CONFIG.ENV = "JENKINS_INCREMENTALS_REPO_MIRROR=https://repo.jenkins-ci.org/incrementals"
RUN("chown -R %s %s %s" % { user, JENKINS_HOME, REF })

PLUGIN_CLI_URL =
	"https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.9.0/jenkins-plugin-manager-2.9.0.jar"
RUN("curl -fsSL %s -o /usr/lib/jenkins-plugin-manager.jar" % PLUGIN_CLI_URL)

-- for main web interface:
CONFIG.PORT = http_port
CONFIG.PORT = agent_port

CONFIG.ENV = "COPY_REFERENCE_FILE_LOG=%s/copy_reference_file.log" % JENKINS_HOME
CONFIG.USER = user

COPY("jenkins-support", "/usr/local/bin/jenkins-support")
COPY("jenkins.sh", "/usr/local/bin/jenkins.sh")
COPY("tini-shim.sh", "/bin/tini")
COPY("jenkins-plugin-cli.sh", "/bin/jenkins-plugin-cli")

ENTRYPOINT("/sbin/tini", "--", "/usr/local/bin/jenkins.sh")

-- from a derived Dockerfile, can use `RUN install-plugins.sh active.txt` to setup $REF/plugins from a support bundle
COPY("install-plugins.sh", "/usr/local/bin/install-plugins.sh")
COMMIT("jenkins:test")

