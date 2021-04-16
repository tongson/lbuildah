-- Requires buildah, skopeo
local F = string.format
local C = table.concat
local G = string.gmatch
local ok = require("stdout").info
local stderr = require("stderr")
local panic = function(ret, msg, tbl)
	if not ret then
		stderr.error(msg, tbl)
		os.exit(1)
	end
end
local ID = require("uid").new()
local USER = os.getenv("USER")
local HOME = os.getenv("HOME")
local CREDS
do
	local ruser = os.getenv("BUILDAH_USER")
	local rpass = os.getenv("BUILDAH_PASSWORD")
	CREDS = ruser .. ":" .. rpass
end
local from = function(base, cid, assets)
	assets = assets or fs.currentdir()
	local util_buildah = assets .. "/util-buildah.20210415"
	local buildah = exec.ctx("buildah")
	buildah.env = { USER = USER, HOME = HOME }
	local name = cid or ID
	if not cid then
		local r, so, se = buildah({
			"from",
			"--name",
			name,
			base,
		})
		panic(r, "Unable to pull image", {
			image = base,
			name = name,
			stdout = so,
			stderr = se,
		})
		ok("Base image pulled", {
			image = base,
		})
	else
		ok("Reusing existing container", {
			name = name,
		})
	end
	local mount
	do
		local r, so, se = buildah{
			"mount",
			name,
		}
    panic(r, "Unable to mount", {
			name = name,
			stdout = so,
			stderr = se,
		})
	  ok("Mounted", {
			name = name,
		})
	  mount = so
	end
	local env = {}
	setmetatable(env, {
		__index = function(_, value)
			return rawget(env, value)
				or rawget(_G, value)
				or panic(nil, "Unknown command or variable", { string = value })
		end,
	})
	env.ADD = function(src, dest, og)
		og = og or "root:root"
		local r, so, se = buildah({
			"add",
			"--chown",
			og,
			name,
			src,
			dest,
		})
		panic(r, "ADD", {
			source = src,
			destination = dest,
			stdout = so,
			stderr = se,
		})
		ok("ADD", {
			source = src,
			destination = dest,
		})
	end
	env.RUN = function(v)
		local a = {
			"run",
			name,
			"--",
		}
		local run = {}
		for k in G(v, "%S+") do
			run[#run + 1] = k
			a[#a + 1] = k
		end
		local r, so, se = buildah(a)
		panic(r, "RUN", {
			id = name,
			command = C(run, " "),
			stdout = so,
			stderr = se,
		})
		ok("RUN", {
			command = C(run, " "),
		})
	end
	env.SCRIPT = function(a)
		local r, so, se = buildah({
			"run",
			"--volume",
			F("%s/%s:/%s", assets, a, a),
			name,
			"--",
			"/bin/sh",
			F("/%s", a),
		})
		panic(r, "SCRIPT", {
			script = a,
			stdout = so,
			stderr = se,
		})
		ok("SCRIPT: Success", {
			script = a,
		})
	end
	env.APT_GET = function(v)
		local a = {
			"run",
			name,
			"--",
			"/usr/bin/env",
			"LC_ALL=C",
			"DEBIAN_FRONTEND=noninteractive",
			"apt-get",
			"-qq",
			"--no-install-recommends",
			"-o",
			"APT::Install-Suggests=0",
			"-o",
			"APT::Get::AutomaticRemove=1",
			"-o",
			"Dpkg::Use-Pty=0",
			"-o",
			[[Dpkg::Options::='--force-confnew']],
			"-o",
			[[DPkg::options::='--force-unsafe-io']],
		}
		local run = {}
		for k in G(v, "%S+") do
			run[#run + 1] = k
			a[#a + 1] = k
		end
		local r, so, se = buildah(a)
		panic(r, "APT_GET", {
			command = run[1],
			arg = C(run, " ", 2),
			stdout = so,
			stderr = se,
		})
		ok("APT_GET", {
			command = run[1],
			arg = C(run, " ", 2),
		})
	end
	env.APT_PURGE = function(a)
		local r, so, se = buildah({
			"run",
			name,
			"--",
			"dpkg",
			"--purge",
			"--no-triggers",
			"--force-remove-essential",
			"--force-breaks",
			"--force-unsafe-io",
			a,
		})
		panic(r, "APT_PURGE", {
			arg = a,
			stdout = so,
			stderr = se,
		})
		ok("APT_PURGE", {
			arg = a,
		})
	end
	env.COPY = function(src, dest, og)
		og = og or "root:root"
		local r, so, se = buildah({
			"copy",
			"--chown",
			og,
			name,
			src,
			dest,
		})
		panic(r, "COPY", {
			source = src,
			destination = dest,
			stdout = so,
			stderr = se,
		})
		ok("COPY", {
			source = src,
			destination = dest,
		})
	end
	env.MKDIR = function(d, m)
		m = m or ""
		local r, so, se = buildah({
			"run",
			"--volume",
			F("%s:/ub", util_buildah),
			name,
			"--",
			"/ub",
			"mkdir",
			d,
			m,
		})
		panic(r, "MKDIR", {
			directory = d,
			mode = m,
			stdout = so,
			stderr = se,
		})
		ok("MKDIR", {
			directory = d,
			mode = m,
		})
	end
	env.RM = function(f)
		local rm = function(ff)
			local r, so, se = buildah({
				"run",
				"--volume",
				F("%s:/ub", util_buildah),
				name,
				"--",
				"/ub",
				"rm",
				ff,
			})
			panic(r, "RM", {
				file = ff,
				stdout = so,
				stderr = se,
			})
			ok("RM", {
				file = ff,
			})
		end
		if type(f) == "table" and next(f) then
			for _, r in ipairs(f) do
				rm(r)
			end
		else
			rm(f)
		end
	end
	env.CONFIG = function(config)
		for k, v in pairs(config) do
			local r, so, se = buildah({
				"config",
				F("--%s", k),
				F([['%s']], v),
				name,
			})
			panic(r, "CONFIG", {
				config = k,
				value = v,
				stdout = so,
				stderr = se,
			})
			ok("CONFIG", {
				config = k,
				value = v,
			})
		end
	end
	env.ENTRYPOINT = function(entrypoint)
		local r, so, se = buildah({
			"config",
			"--entrypoint",
			F([['[\"%s\"]']], entrypoint),
			name,
		})
		panic(r, "ENTRYPOINT(exe)", {
			entrypoint = entrypoint,
			stdout = so,
			stderr = se,
		})
		ok("ENTRYPOINT(exe)", {
			entrypoint = entrypoint,
		})
		r, so, se = buildah({
			"config",
			"--cmd",
			[['']],
			name,
		})
		panic(r, "ENTRYPOINT(cmd)", {
			cmd = [['']],
			stdout = so,
			stderr = se,
		})
		ok("ENTRYPOINT(cmd)", {
			cmd = [['']],
		})
		r, so, se = buildah({
			"config",
			"--stop-signal",
			"TERM",
			name,
		})
		panic(r, "ENTRYPOINT(term)", {
			term = "TERM",
			stdout = so,
			stderr = se,
		})
		ok("ENTRYPOINT(term)", {
			term = "TERM",
		})
	end
	env.ARCHIVE = function(cname)
		local r, so, se = buildah({
			"commit",
			"--rm",
			"--squash",
			name,
			F("oci-archive:%s", cname),
		})
		panic(r, "ARCHIVE", {
			name = cname,
			stdout = so,
			stderr = se,
		})
		ok("ARCHIVE", {
			name = cname,
		})
	end
	env.PURGE = function(a)
		if a == "directories" then
			buildah({
				"run",
				"--volume",
				F("%s:/ub", util_buildah),
				name,
				"--",
				"/ub",
				"purge-directories",
			})
			ok("PURGE(directories)", {})
		end
		if a == "debian" or a == "dpkg" then
			buildah({
				"run",
				"--volume",
				F("%s:/ub", util_buildah),
				name,
				"--",
				"/ub",
				"purge-dpkg",
			})
			ok("PURGE(apt/dpkg and dependencies)", {})
		end
		if a == "perl" then
			buildah({
				"run",
				"--volume",
				F("%s:/ub", util_buildah),
				name,
				"--",
				"/ub",
				"purge-perl",
			})
			ok("PURGE(perl)", {})
		end
		if a == "userland" then
			buildah({
				"run",
				"--volume",
				F("%s:/ub", util_buildah),
				name,
				"--",
				"/ub",
				"purge-userland",
			})
			ok("PURGE(perl)", {})
		end
		if a == "docs" or a == "documentation" then
			buildah({
				"run",
				"--volume",
				F("%s:/ub", util_buildah),
				name,
				"--",
				"/ub",
				"purge-docs",
			})
			ok("PURGE(docs)", {})
		end
		if a == "shell" or a == "sh" then
			buildah({
				"run",
				"--volume",
				F("%s:/ub", util_buildah),
				name,
				"--",
				"/ub",
				"purge-sh",
			})
			ok("PURGE(sh)", {})
		end
	end
	setfenv(2, env)
end

return {
	from = from,
}
