require("buildah")
FROM("gcr.io/distroless/static", "traefik")
UPLOAD("traefik.v2.4.8", "/traefik")
ENTRYPOINT("/traefik", "--config", "/config/traefik.json")
COMMIT("traefik:2.4.8")


