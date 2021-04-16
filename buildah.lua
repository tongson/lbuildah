-- Requires buildah, skopeo
local stdin_docs = [[
usr/share/doc
usr/share/man
usr/share/menu
usr/share/groff
usr/share/info
usr/share/lintian
usr/share/linda
usr/share/bug
usr/share/locale
usr/share/bash-completion
var/cache/man
]]
local Format = string.format
local Concat = table.concat
local Gmatch = string.gmatch
local Sub = string.sub
local Ok = require("stdout").info
local Panic = require("stderr").error
local buildah = exec.ctx("buildah")
local Buildah = function(a, msg, tbl)
	buildah.env = { USER = os.getenv("USER"), HOME = os.getenv("HOME") }
	local r, so, se = buildah(a)
	if not r then
		tbl.stdout = so
		tbl.stderr = se
		Panic(msg, tbl)
		os.exit(1)
	else
		Ok(msg, tbl)
	end
end
local Mount = function(n)
	local r, so, se = buildah({
		"mount",
		n,
	})
	if not r or (so == "/") then
		Panic("buildah mount", {
			name = n,
			stdout = so,
			stderr = se,
		})
	end
	return so
end
local Unmount = function(n)
	local r, so, se = buildah({
		"unmount",
		n,
	})
	if not r then
		Panic("buildah unmount", {
			name = n,
			stdout = so,
			stderr = se,
		})
	end
	return true
end
local creds
do
	local ruser = os.getenv("BUILDAH_USER")
	local rpass = os.getenv("BUILDAH_PASSWORD")
	creds = ruser .. ":" .. rpass
end
local FROM = function(base, cid, assets)
	assets = assets or fs.currentdir()
	local name = cid or require("uid").new()
	if not cid then
		local a = {
			"from",
			"--name",
			name,
			base,
		}
		Buildah(a, "FROM", {
			image = base,
			name = name,
		})
	else
		Ok("Reusing existing container", {
			name = name,
		})
	end
	local env = {}
	setmetatable(env, {
		__index = function(_, value)
			return rawget(env, value)
				or rawget(_G, value)
				or Panic("Unknown command or variable", { string = value })
		end,
	})
	env.ADD = function(src, dest, og)
		og = og or "root:root"
		local a = {
			"add",
			"--chown",
			og,
			name,
			src,
			dest,
		}
		Buildah(a, "ADD", {
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
		for k in Gmatch(v, "%S+") do
			run[#run + 1] = k
			a[#a + 1] = k
		end
		Buildah(a, "RUN", {
			id = name,
			command = Concat(run, " "),
		})
	end
	env.SCRIPT = function(s)
		local a = {
			"run",
			"--volume",
			Format("%s/%s:/%s", assets, s, s),
			name,
			"--",
			"/bin/sh",
			Format("/%s", s),
		}
		Buildah(a, "SCRIPT", {
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
		for k in Gmatch(v, "%S+") do
			run[#run + 1] = k
			a[#a + 1] = k
		end
		Buildah(a, "APT_GET", {
			command = run[1],
			arg = Concat(run, " ", 2),
		})
	end
	env.APT_PURGE = function(p)
		local a = {
			"run",
			name,
			"--",
			"dpkg",
			"--purge",
			"--no-triggers",
			"--force-remove-essential",
			"--force-breaks",
			"--force-unsafe-io",
			p,
		}
		Buildah(a, "APT_PURGE", {
			package = p,
		})
	end
	env.COPY = function(src, dest, og)
		og = og or "root:root"
		local a = {
			"copy",
			"--chown",
			og,
			name,
			src,
			dest,
		}
		Buildah(a, "COPY", {
			source = src,
			destination = dest,
		})
	end
	env.MKDIR = function(d, mode)
		mode = mode or "0700"
		local mkdir = exec.ctx("mkdir")
		mkdir.cwd = Mount(name)
		local r, so, se = mkdir({
			"-m",
			mode,
			"-p",
			Sub(d, 2),
		})
		Unmount(name)
		if r then
			Ok("MKDIR", {
				directory = d,
			})
		else
			Panic("MKDIR", {
				directory = d,
				stdout = so,
				stderr = se,
			})
		end
	end
	env.CHMOD = function(mode, p)
		local chmod = exec.ctx("chmod")
		chmod.cwd = Mount(name)
		local r, so, se = chmod({
			mode,
			Sub(p, 2),
		})
		Unmount(name)
		if r then
			Ok("CHMOD", {
				path = p,
			})
		else
			Panic("CHMOD", {
				path = p,
				stdout = so,
				stderr = se,
			})
		end
	end
	env.RM = function(f)
		local rm = exec.ctx("rm")
		rm.cwd = Mount(name)
		local frm = function(ff)
			local r, so, se = rm({
				"-r",
				"-f",
				Sub(ff, 2),
			})
			if r then
				Ok("RM", {
					file = ff,
				})
			else
				Unmount(name)
				Panic("RM", {
					file = ff,
					stdout = so,
					stderr = se,
				})
			end
		end
		if type(f) == "table" and next(f) then
			for _, r in ipairs(f) do
				frm(r)
			end
		else
			frm(f)
		end
		Unmount(name)
	end
	env.CONFIG = function(config)
		for k, v in pairs(config) do
			local a = {
				"config",
				Format("--%s", k),
				Format([['%s']], v),
				name,
			}
			Buildah(a, "CONFIG", {
				config = k,
				value = v,
			})
		end
	end
	env.ENTRYPOINT = function(entrypoint)
		local a = {
			"config",
			"--entrypoint",
			Format([['[\"%s\"]']], entrypoint),
			name,
		}
		Buildah(a, "ENTRYPOINT(exe)", {
			entrypoint = entrypoint,
		})
		a = {
			"config",
			"--cmd",
			[['']],
			name,
		}
		Buildah(a, "ENTRYPOINT(cmd)", {
			cmd = [['']],
		})
		a = {
			"config",
			"--stop-signal",
			"TERM",
			name,
		}
		Buildah(a, "ENTRYPOINT(term)", {
			term = "TERM",
		})
	end
	env.ARCHIVE = function(cname)
		local a = {
			"commit",
			"--rm",
			"--squash",
			name,
			Format("oci-archive:%s", cname),
		}
		Buildah(a, "ARCHIVE", {
			name = cname,
		})
	end
	env.PURGE = function(a)
		if a == "directories" then
		end
		if a == "debian" or a == "dpkg" then
		end
		if a == "perl" then
		end
		if a == "userland" then
		end
		if a == "docs" or a == "documentation" then
			local xargs = exec.ctx("xargs")
			xargs.cwd = Mount(name)
			xargs.stdin = stdin_docs
			local r, so, se = xargs({ "rm", "-r", "-f" })
			Unmount(name)
			if r then
				Ok("PURGE(docs)", {})
			else
				Panic("PURGE(docs)", {
					stdout = so,
					stderr = se,
				})
			end
		end
		if a == "shell" or a == "sh" then
		end
	end
	setfenv(2, env)
end

return {
	FROM = FROM,
}
