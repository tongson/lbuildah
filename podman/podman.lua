local DSL = "podman"
local lopper = require("lopper")
local json = require("json")
local ok = function(msg, tbl)
	tbl._module = DSL
	return lopper.Ok(msg, tbl)
end
local panic = function(ret, msg, tbl)
	if not ret then
		tbl._module = DSL
		return lopper.Panic(msg, tbl)
	end
end
local M = {}
local podman = exec.ctx("podman")
local start = function(name, unit, cpus, iid)
	local systemctl = exec.ctx("systemctl")
	systemctl({
		"disable",
		"--no-block",
		"--now",
		("%s.service"):format(name),
	})
	local fname = ("/etc/systemd/system/%s.service"):format(name)
	local changed
	unit, changed = unit:gsub("__ID__", iid)
	panic((changed == 1), "unable to interpolate image ID", {
		what = "string.gsub",
		changed = false,
		to = iid,
	})
	unit, changed = unit:gsub("__CPUS__", cpus)
	panic((changed == 1), "unable to interpolate cpuset-cpus", {
		what = "string.gsub",
		changed = false,
		to = cpus,
	})
	panic(fs.write(fname, unit), "unable to write unit", {
		what = "fs.write",
		file = fname,
	})
	local r, so, se = systemctl({
		"enable",
		"--no-block",
		"--now",
		("%s.service"):format(name),
	})
	panic(r, "unable to start service", {
		what = "systemctl",
		command = "enable",
		service = name,
		stdout = so,
		stderr = se,
	})
end
local id = function(u, t)
	local r, so, se = podman({
		"images",
		"--format",
		"json",
	})
	panic(r, "unable to list images", {
		what = "podman",
		command = "images",
		stdout = so,
		stderr = se,
	})
	local j = json.decode(so)
	u = u:gsub("docker://", "")
	local name = ("%s:%s"):format(u, t)
	for i = 1, #j do
		for _, v in ipairs(j[i].Names) do
			if v == name then
				return j[i].Id
			end
		end
	end
	return nil, "Container image not found."
end
local pull = function(u, t)
	local r, so, se = podman({
		"pull",
		"--tls-verify",
		("%s:%s"):format(u, t),
	})
	panic(r, "unable to pull image", {
		what = "podman",
		command = "pull",
		url = u,
		tag = t,
		stdout = so,
		stderr = se,
	})
end
local volume = function(vt)
	local volumes = function(n)
		local ret, so, se = podman({
			"volume",
			"inspect",
			"--all",
		})
		panic(ret, "Failure listing volumes", {
			what = "podman",
			command = "volume-ls",
			stdout = so,
			stderr = se,
		})
		local j = json.decode(so)
		local found = {}
		for _, v in ipairs(j) do
			if n and v.Name == n then
				return v.Mountpoint
			end
			found[v.Name] = v.Mountpoint
		end
		return found
	end
	local found = volumes()
	for x, y in pairs(vt) do
		if not found[x] then
			local ret, so, se = podman({ "volume", "create", x })
			panic(ret, "unable to create volume", {
				what = "podman",
				command = "volume-create",
				stdout = so,
				stderr = se,
			})
			local mountpoint = volumes(x)
			local sh = exec.ctx("sh")
			for _, cmd in ipairs(y) do
				ret, so, se = sh({ "-c", cmd:gsub("__MOUNTPOINT__", mountpoint) })
				panic(ret, "error executing volume command", {
					what = "sh",
					command = "volume-command",
					stdout = so,
					stderr = se,
				})
			end
		end
	end
end
setmetatable(M, {
	__call = function(_, p)
		local param = {
			NAME = "Unit name.",
			URL = "Image URL.",
			TAG = "Image tag.",
			CPUS = "Argument to podman --cpuset-cpus.",
			always_update = "Boolean flag, if `true` always pull the image.",
		}
		M.param = {}
		M.reg = {}
		for k in pairs(p) do
			if not param[k] then
				panic(nil, "Invalid parameter given.", {
					parameter = k,
				})
			else
				M.param[k] = p[k]
			end
		end

		local systemd = require("systemd." .. M.param.NAME)
		M.reg.unit = systemd.unit
		if next(systemd.volumes) then
			volume(systemd.volumes)
			for vn in pairs(systemd.volumes) do
				ok("Checked volume", {
					name = vn,
				})
			end
		end

		-- pull
		M.reg.id = id(M.param.URL, M.param.TAG)
		if M.param.always_update or not M.reg.id then
			pull(M.param.URL, M.param.TAG)
			ok("Pulled image", {
				url = M.param.URL,
				tag = M.param.TAG,
			})
			M.reg.id = id(M.param.URL, M.param.TAG)
			ok("Got image ID", {
				id = M.reg.id,
			})
		end
		-- start
		start(M.param.NAME, M.reg.unit, M.param.CPUS, M.reg.id)
		ok("Started systemd unit", {
			name = M.param.NAME,
		})
	end,
})
return M
