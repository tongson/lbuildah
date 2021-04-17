# buildah.lua
buildah wrapper. <br />
Containers in Lua. A Dockerfile alternative.

# EXAMPLE
Creates Alpine Linux container with nginx as ENTRYPOINT then save to containers-storage.

    #!/usr/bin/env ll
    require"buildah"
    FROM "docker://docker.io/library/alpine:edge"
    RUN "/sbin/apk upgrade --no-cache --available --no-progress"
    RUN "/sbin/apk add --no-cache nginx"
    RM "/var/cache/apk"
    ENTRYPOINT "/usr/sbin/nginx"
    ARCHIVE "alpine"
