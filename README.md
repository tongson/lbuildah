# buildah.lua
opinionated buildah wrapper for MoonScript(LuaJIT/Lua 5.1).


# EXAMPLE
Creates Alpine Linux container with nginx as ENTRYPOINT then save to containers-storage.

    #!/usr/bin/env moon
    base = "docker://docker.io/library/alpine:edge"
    buildah = require"buildah".from base
    RUN     "/sbin/apk upgrade --no-cache --available --no-progress"
    RUN     "/sbin/apk add --no-cache nginx"
    RM      "/var/cache/apk"
    START   "/usr/sbin/nginx"
    STORAGE "alpine"
