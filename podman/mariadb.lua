require("lopper")
NOTIFY("START")
require("podman")({
	NAME = "mariadb",
	URL = "docker://docker.io/library/mariadb",
	TAG = "10.5",
	CPUS = "1",
})
NOTIFY("END")
