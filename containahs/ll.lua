FROM("devel", "ll")
UPLOAD("ll/init", "/usr/bin/init")
UPLOAD("ll/kapow.v0.7.0", "/usr/bin/kapow")
UPLOAD("ll/resolv.conf", "/etc/resolv.conf")
UPLOAD("ll/rr", "/usr/bin/rr")
UPLOAD("ll/preinit", "/usr/bin/preinit")
ENTRYPOINT("/usr/bin/init")
CONFIG.CMD = [[-pre "/usr/bin/preinit" -main "/usr/bin/kapow server --debug --control-reachable-addr 127.0.0.1:60081 --bind 127.0.0.1:60080 --control-bind 127.0.0.1:60081 --data-bind 127.0.0.1:60082 /LadyLua/tests/kapow/index.pow"]]
COMMIT("ll:latest")
