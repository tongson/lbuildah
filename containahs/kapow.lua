FROM("gcr.io/distroless/static", "kapow")
UPLOAD("kapow.v0.7.0", "/kapow")
UPLOAD("/usr/bin/ll", "/usr/bin/ll")
ENTRYPOINT("/kapow", "server")
COMMIT("kapow:0.7.0")
