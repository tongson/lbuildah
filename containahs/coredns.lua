FROM("gcr.io/distroless/static", "coredns")
UPLOAD("coredns.v1.8.3", "/coredns")
ENTRYPOINT("/coredns", "-conf", "/config/Corefile")
COMMIT("coredns:1.8.3")
