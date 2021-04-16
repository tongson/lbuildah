-- Requires buildah, skopeo
local stdin_userland = [[
bin/sh
bin/dash
bin/bash
bin/cat
bin/chgrp
bin/chmod
bin/chown
bin/cp
bin/date
bin/dd
bin/df
bin/dir
bin/echo
bin/false
bin/ln
bin/ls
bin/mkdir
bin/mknod
bin/mktemp
bin/mv
bin/pwd
bin/readlink
bin/rm
bin/rmdir
bin/sleep
bin/stty
bin/sync
bin/touch
bin/true
bin/uname
bin/vdir
usr/bin/[
usr/bin/arch
usr/bin/b2sum
usr/bin/base32
usr/bin/base64
usr/bin/basename
usr/bin/chcon
usr/bin/cksum
usr/bin/comm
usr/bin/csplit
usr/bin/cut
usr/bin/dircolors
usr/bin/dirname
usr/bin/du
usr/bin/env
usr/bin/expand
usr/bin/expr
usr/bin/factor
usr/bin/fmt
usr/bin/fold
usr/bin/groups
usr/bin/head
usr/bin/hostid
usr/bin/id
usr/bin/install
usr/bin/join
usr/bin/link
usr/bin/logname
usr/bin/md5sum
usr/bin/md5sum.textutils
usr/bin/mkfifo
usr/bin/nice
usr/bin/nl
usr/bin/nohup
usr/bin/nproc
usr/bin/numfmt
usr/bin/od
usr/bin/paste
usr/bin/pathchk
usr/bin/pinky
usr/bin/pr
usr/bin/printenv
usr/bin/printf
usr/bin/ptx
usr/bin/realpath
usr/bin/runcon
usr/bin/seq
usr/bin/sha1sum
usr/bin/sha224sum
usr/bin/sha256sum
usr/bin/sha384sum
usr/bin/sha512sum
usr/bin/shred
usr/bin/shuf
usr/bin/sort
usr/bin/split
usr/bin/stat
usr/bin/stdbuf
usr/bin/sum
usr/bin/tac
usr/bin/tail
usr/bin/tee
usr/bin/test
usr/bin/timeout
usr/bin/tr
usr/bin/truncate
usr/bin/tsort
usr/bin/tty
usr/bin/unexpand
usr/bin/uniq
usr/bin/unlink
usr/bin/users
usr/bin/wc
usr/bin/who
usr/bin/whoami
usr/bin/yes
usr/lib/x86_64-linux-gnu/coreutils/libstdbuf.so
usr/sbin/chroot
bin/egrep
bin/fgrep
bin/grep
usr/bin/rgrep
bin/gunzip
bin/gzexe
bin/gzip
bin/uncompress
bin/zcat
bin/zcmp
bin/zdiff
bin/zegrep
bin/zfgrep
bin/zforce
bin/zgrep
bin/zless
bin/zmore
bin/znew
sbin/shadowconfig
usr/bin/chage
usr/bin/chfn
usr/bin/chsh
usr/bin/expiry
usr/bin/gpasswd
usr/bin/passwd
usr/lib/tmpfiles.d/passwd.conf
usr/sbin/chgpasswd
usr/sbin/chpasswd
usr/sbin/cpgr
usr/sbin/cppw
usr/sbin/groupadd
usr/sbin/groupdel
usr/sbin/groupmems
usr/sbin/groupmod
usr/sbin/grpck
usr/sbin/grpconv
usr/sbin/grpunconv
usr/sbin/newusers
usr/sbin/pwck
usr/sbin/pwconv
usr/sbin/pwunconv
usr/sbin/useradd
usr/sbin/userdel
usr/sbin/usermod
usr/sbin/vigr
usr/sbin/vipw
sbin/mkhomedir_helper
sbin/pam_tally
sbin/pam_tally2
sbin/unix_chkpwd
sbin/unix_update
usr/sbin/pam_timestamp_check
usr/sbin/pam-auth-update
usr/sbin/pam_getenv
usr/sbin/addgroup
usr/sbin/adduser
usr/sbin/delgroup
usr/sbin/deluser
usr/share/adduser/adduser.conf
usr/sbin/update-passwd
usr/share/base-passwd/group.master
usr/share/base-passwd/passwd.master
bin/sed
usr/bin/find
usr/bin/xargs
usr/bin/mawk
bin/tar
usr/lib/mime/packages/tar
usr/sbin/rmt-tar
usr/sbin/tarcat
usr/bin/cmp
usr/bin/diff
usr/bin/diff3
usr/bin/sdiff
sbin/ldconfig
usr/bin/catchsegv
usr/bin/getconf
usr/bin/getent
usr/bin/iconv
usr/bin/ldd
usr/bin/locale
usr/bin/localedef
usr/bin/pldd
usr/bin/tzselect
usr/bin/zdump
usr/sbin/iconvconfig
usr/sbin/zic
]]
local stdin_dpkg = [[
usr/bin/dpkg
usr/bin/dpkg-deb
usr/bin/dpkg-divert
usr/bin/dpkg-maintscript-helper
usr/bin/dpkg-query
usr/bin/dpkg-split
usr/bin/dpkg-statoverride
usr/bin/dpkg-trigger
usr/bin/update-alternatives
usr/share/dpkg
etc/dpkg
usr/lib/dpkg
usr/bin/apt
usr/bin/apt-cache
usr/bin/apt-cdrom
usr/bin/apt-config
usr/bin/apt-get
usr/bin/apt-key
usr/bin/apt-mark
usr/lib/apt
usr/bin/debsig-verify
sbin/start-stop-daemon
etc/apt
usr/bin/deb-systemd-helper
usr/bin/deb-systemd-invoke
usr/sbin/invoke-rc.d
usr/sbin/service
usr/sbin/update-rc.d
usr/bin/gpgv
bin/run-parts
bin/tempfile
bin/which
sbin/installkernel
usr/bin/ischroot
usr/bin/savelog
usr/sbin/add-shell
usr/sbin/remove-shell
usr/share/debianutils/shells
etc/apt/apt.conf.d/01autoremove
etc/cron.daily/apt-compat
etc/kernel/postinst.d/apt-auto-removal
etc/logrotate.d/apt
lib/systemd/system/apt-daily-upgrade.service
lib/systemd/system/apt-daily-upgrade.timer
lib/systemd/system/apt-daily.service
lib/systemd/system/apt-daily.timer
usr/bin/apt
usr/bin/apt-cache
usr/bin/apt-cdrom
usr/bin/apt-config
usr/bin/apt-get
usr/bin/apt-key
usr/bin/apt-mark
usr/lib/apt
usr/lib/dpkg
usr/lib/s390x-linux-gnu/libapt-private.so.0.0
usr/lib/s390x-linux-gnu/libapt-private.so.0.0.0
usr/share/bash-completion/completions/apt
etc/debconf.conf
usr/bin/debconf
usr/bin/debconf-apt-progress
usr/bin/debconf-communicate
usr/bin/debconf-copydb
usr/bin/debconf-escape
usr/bin/debconf-set-selections
usr/bin/debconf-show
usr/sbin/dpkg-preconfigure
usr/sbin/dpkg-reconfigure
usr/share/debconf
usr/share/perl5/Debconf
usr/share/perl5/Debian
usr/share/pixmaps/debian-logo.pngG
]]
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
local list_perl = {
	"usr/bin/perl*",
	"usr/lib/*/perl*",
}
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
local creds
do
	local ruser = os.getenv("BUILDAH_USER")
	local rpass = os.getenv("BUILDAH_PASSWORD")
	creds = ruser .. ":" .. rpass
end
local FROM = function(base, cid, assets)
	assets = assets or fs.currentdir()
	local Name = cid or require("uid").new()
	local Mount = function()
		local r, so, se = buildah({
			"mount",
			Name,
		})
		if not r or (so == "/") then
			Panic("buildah mount", {
				name = Name,
				stdout = so,
				stderr = se,
			})
		end
		return so
	end
	local Unmount = function()
		local r, so, se = buildah({
			"unmount",
			Name,
		})
		if not r then
			Panic("buildah unmount", {
				name = Name,
				stdout = so,
				stderr = se,
			})
		end
		return true
	end
	local Try = function(fn, args, msg)
		local tbl = {}
		local r, so, se = fn(args)
		Unmount()
		if not r then
			tbl.stdout = so
			tbl.stderr = se
			Panic(msg, tbl)
		end
	end
	local Epilogue = function()
		local rm = exec.ctx("rm")
		rm.cwd = Mount()
		local mkdir = exec.ctx("mkdir")
		mkdir.cwd = Mount()
		local msg = "epilogue"
		Try(rm, { "-r", "-f", "tmp" }, msg)
		Try(mkdir, { "-m", "017777", "tmp" }, msg)
		Try(rm, { "-r", "-f", "var/tmp" }, msg)
		Try(mkdir, { "-m", "017777", "var/tmp" }, msg)
		Try(rm, { "-r", "-f", "var/log" }, msg)
		Try(mkdir, { "-m", "0755", "var/log" }, msg)
		Try(rm, { "-r", "-f", "var/cache" }, msg)
		Try(mkdir, { "-m", "0755", "var/cache" }, msg)
		Unmount()
	end

	if not cid then
		local a = {
			"from",
			"--name",
			Name,
			base,
		}
		Buildah(a, "FROM", {
			image = base,
			name = Name,
		})
	else
		Ok("Reusing existing container", {
			name = Name,
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
			Name,
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
			Name,
			"--",
		}
		local run = {}
		for k in Gmatch(v, "%S+") do
			run[#run + 1] = k
			a[#a + 1] = k
		end
		Buildah(a, "RUN", {
			name = Name,
			command = Concat(run, " "),
		})
	end
	env.SCRIPT = function(s)
		local a = {
			"run",
			"--volume",
			Format("%s/%s:/%s", assets, s, s),
			Name,
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
			Name,
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
			Name,
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
			Name,
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
		mkdir.cwd = Mount()
		local r, so, se = mkdir({
			"-m",
			mode,
			"-p",
			Sub(d, 2),
		})
		Unmount()
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
		chmod.cwd = Mount()
		local r, so, se = chmod({
			mode,
			Sub(p, 2),
		})
		Unmount()
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
		rm.cwd = Mount()
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
				Unmount()
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
		Unmount()
	end
	env.CONFIG = function(config)
		for k, v in pairs(config) do
			local a = {
				"config",
				Format("--%s", k),
				Format([['%s']], v),
				Name,
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
			Name,
		}
		Buildah(a, "ENTRYPOINT(exe)", {
			entrypoint = entrypoint,
		})
		a = {
			"config",
			"--cmd",
			[['']],
			Name,
		}
		Buildah(a, "ENTRYPOINT(cmd)", {
			cmd = [['']],
		})
		a = {
			"config",
			"--stop-signal",
			"TERM",
			Name,
		}
		Buildah(a, "ENTRYPOINT(term)", {
			term = "TERM",
		})
	end
	env.ARCHIVE = function(cname)
		Epilogue()
		local a = {
			"commit",
			"--rm",
			"--squash",
			Name,
			Format("oci-archive:%s", cname),
		}
		Buildah(a, "ARCHIVE", {
			name = cname,
		})
	end
	env.DIR = function(dirname)
		Epilogue()
		local a = {
			"commit",
			"--rm",
			"--squash",
			Name,
			Format("dir:%s", dirname),
		}
		Buildah(a, "DIR", {
			name = Name,
			path = dirname,
		})
	end
	env.PURGE = function(a, opts)
		if a == "debian" or a == "dpkg" then
			local xargs = exec.ctx("xargs")
			xargs.cwd = Mount()
			xargs.stdin = stdin_dpkg
			local r, so, se = xargs({ "rm", "-r", "-f" })
			Unmount()
			if r then
				Ok("PURGE(dpkg)", {})
			else
				Panic("PURGE(dpkg)", {
					stdout = so,
					stderr = se,
				})
			end
		end
		if a == "perl" then
			local sh = exec.ctx("sh")
			sh.cwd = Mount()
			for _, v in ipairs(list_perl) do
				Try(sh, { "-c", Format([[rm -rf -- %s]], v) }, "PURGE(perl)")
			end
			Unmount()
			Ok("PURGE(perl)", {})
		end
		if a == "userland" then
			local sh = exec.ctx("sh")
			sh.cwd = Mount()
			local tbl = stdin_userland:to_map()
			if opts then
				for _, f in ipairs(opts) do
					tbl[f] = nil
				end
			end
			for v in next, tbl do
				Try(sh, { "-c", Format([[rm -rf -- %s]], v) }, "PURGE(userland)")
			end
			Unmount()
			Ok("PURGE(userland)", {})
		end
		if a == "docs" or a == "documentation" then
			local xargs = exec.ctx("xargs")
			xargs.cwd = Mount()
			xargs.stdin = stdin_docs
			local r, so, se = xargs({ "rm", "-r", "-f" })
			Unmount()
			if r then
				Ok("PURGE(docs)", {})
			else
				Panic("PURGE(docs)", {
					stdout = so,
					stderr = se,
				})
			end
		end
	end
	setfenv(2, env)
end

return {
	FROM = FROM,
}

