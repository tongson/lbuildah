-- Requires buildah, skopeo
local F = string.format
local C = table.concat
local I = table.insert
local ok = require 'stdout'.info
local stderr = require 'stderr'
local panic = function(ret, msg, tbl)
  if not ret then
    stderr.error(msg, tbl)
    os.exit(1)
  end
end
local ID = require 'uid'.new()
local USER = os.getenv "USER"
local HOME = os.getenv "HOME"
--# == buildah.from(base, [assets])
--# Returns a function that executes the *main* `buildah` routine containing the `buildah` DSL.
--#
--# *base* is a required string indicating the container image to base from.
--#     example: `docker://docker.io/library/debian:stable-slim`
--# *assets* is an optional string that corresponds to the assets directory.
--#
--# === DSL
local from = function(base, cid, assets)
  assets = assets or '.'
  local util_buildah = assets.."/util-buildah.20210415"
  local buildah = exec.ctx 'buildah'
  buildah.env = { USER = USER, HOME = HOME }
  local name = cid or ID
  if not cid then
    buildah{
      'rm';
      '-a';
    }
    local r, so, se = buildah{
      'from';
      '--name';
      name;
      base;
    }
    panic(r, 'Unable to pull image', {
      image = base;
      name = name;
      stdout = so;
      stderr = se;
    })
    ok('Base image pulled', {
      image = base;
    })
  else
    ok('Reusing existing container', {
      name = name;
    })
  end
  local env = {}
  setmetatable(env, {__index = function(_, value)
      return rawget(env, value) or rawget(_G, value)
  end})
  --# === RUN(command)
  --# Runs the *command* within the container.
  --#
  env.RUN = function(...)
    local a = buildah{
      'run';
      name;
      '--';
    }
    for _, v in ipairs({...}) do
      I(a, v)
    end
    local r, so, se = buildah(a)
    panic(r, 'RUN', {
      id = name;
      command = C({...})
      stdout = so;
      stderr = se;
    })
    ok('RUN: Success', {
      command = C({...})
    })
  end
  --++ ### SCRIPT(file)
  --++ Runs the *file* within the container as a shell script.
  --++
  env.SCRIPT = function(a)
    local r, so, se = buildah{
      'run';
      '--volume';
      F('%s/%s:/%s', assets, a, a);
      name;
      '--';
      '/bin/sh';
      F('/%s', a);
    }
    panic(r, 'SCRIPT', {
      script = a;
      stdout = so;
      stderr = se;
    })
    ok('SCRIPT: Success', {
      script = a;
    })
  end
  --++ ### APT_GET(arguments)
  --++ Wraps the /Debian/ `apt-get` command.
  --++ Usually used installing packages (.e.g. `APT_GET install build-essential`)
  --++
  env.APT_GET = function(command, ...)
    local a = buildah{
      'run';
      name;
      '--';
      '/usr/bin/env';
      'LC_ALL=C';
      'DEBIAN_FRONTEND=noninteractive';
      'apt-get';
      '-qq';
      '--no-install-recommends';
      '-o';
      'APT::Install-Suggests=0';
      '-o';
      'APT::Get::AutomaticRemove=1';
      '-o';
      'Dpkg::Use-Pty=0';
      '-o';
      [[Dpkg::Options::='--force-confnew']];
      '-o';
      [[DPkg::options::='--force-unsafe-io']];
      command;
    }
    for _, v in ipairs({...}) do
      I(a, v)
    end
    local r, so, se = buildah(a)
    panic(r, 'APT_GET', {
      command = command;
      arg = C({...});
      stdout = so;
      stderr = se;
    })
    ok('APT_GET', {
      command = command;
      arg = C({...});
    })
  end
  --++ ### APT_PURGE(arguments)
  --++ Wraps dpkg command to purge a package.
  --++
  env.APT_PURGE = function(a)
    local r, so, se = buildah{
      'run';
      name;
      '--';
      'dpkg';
      '--purge';
      '--no-triggers';
      '--force-remove-essential';
      '--force-breaks';
      '--force-unsafe-io';
      a;
    }
    panic(r, 'APT_PURGE', {
      arg = a;
      stdout = so;
      stderr = se;
    })
    ok('APT_PURGE', {
      arg = a;
    })
  end
  --++ ### COPY(source, destination)
  --++ Copies the *source* file from the current directory to the the optional argument *destination*.
  --++ Writes to the root('/') directory if *destination* is not given.
  --++
  env.COPY = function(src, dest)
    dest = dest or '/'..src
    local r, so, se = buildah{
      'copy';
      name;
      F('%s/%s', assets, src);
      dest;
    }
    panic(r, 'COPY', {
      source = src;
      destination = dest;
      stdout = so;
      stderr = se;
    })
    ok('COPY', {
      source = src;
      destination = dest;
    })
  end
  --++ ### MKDIR(directory, [mode])
  --++ Create directory within container.
  --++
  --++ Optional directory mode in octal. Default is 0755.
  --++
  env.MKDIR = function(d, m)
    m = m or ""
    local r, so, se = buildah{
      'run';
      '--volume';
      F('%s:/ub', util_buildah);
      name;
      '--';
      '/ub';
      'mkdir';
      d;
      m;
    }
    panic(r, 'MKDIR', {
      directory = d;
      mode = m;
      stdout = so;
      stderr = se;
    })
    ok('MKDIR', {
      directory = d;
      mode = m;
    })
  end
  --++ ### RM(file)
  --++ Deletes the string *file*.
  --++ If a list(table) is given, then each file(string) is deleted.
  --++
  env.RM = function(f)
    local rm = function(ff)
      local r, so, se = buildah{
        'run';
        '--volume';
        F('%s:/ub', util_buildah);
        name;
        '--';
        '/ub';
        'rm';
        ff;
      }
      panic(r, 'RM', {
        file = ff;
        stdout = so;
        stderr = se;
      })
      ok('RM', {
        file = ff;
      })
    end
    if type(f) == 'table' and next(f) then
      for _, r in ipairs(f) do
        rm(r)
      end
    else
      rm(f)
    end
  end
  --++ ### ENTRYPOINT(executable)
  --++ Sets the container entrypoint.
  --++ NOTE: Only accepts a single entrypoint item, usually the executable.
  --++
  env.CONFIG = function(entrypoint, cmd, term)
    cmd = cmd or [['']]
    term = term or 'TERM'
    local r, so, se = buildah{
      'config';
      '--entrypoint';
      F([['[\"%s\"]']], entrypoint);
      name;
    }
    panic(r, 'CONFIG(entrypoint)', {
      entrypoint = entrypoint;
      stdout = so;
      stderr = se;
    })
    ok('CONFIG(entrypoint)', {
      entrypoint = entrypoint;
    })
    r, so, se = buildah{
      'config';
      '--cmd';
      cmd;
      name;
    }
    panic(r, 'CONFIG(cmd)', {
      cmd = cmd;
      stdout = so;
      stderr = se;
    })
    ok('CONFIG(cmd)', {
      cmd = cmd;
    })
    r, so, se= buildah{
      'config';
      '--stop-signal';
      term;
      name;
    }
    panic(r, 'CONFIG(term)', {
      term = term;
      stdout = so;
      stderr = se;
    })
    ok('CONFIG(term)', {
      term = term;
    })
  end
  env.ENTRYPOINT = env.CONFIG
  env.ARCHIVE = function(cname)
    local r, so, se = buildah{
      'commit';
      '--rm';
      '--squash';
      name;
      F('oci-archive:%s', cname);
    }
    panic(r, 'ARCHIVE', {
      name = cname;
      stdout = so;
      stderr = se;
    })
    ok('ARCHIVE', {
      name = cname;
    })
  end
  env.PURGE = function(a)
    if a == 'directories' then
      buildah{
        'run';
        '--volume';
        F('%s:/ub', util_buildah);
        name;
        '--';
        '/ub';
        'purge-directories';
      }
      ok('PURGE(directories)', {})
    end
    if a == 'debian' or a == 'dpkg' then
      buildah{
        'run';
        '--volume';
        F('%s:/ub', util_buildah);
        name;
        '--';
        '/ub';
        'purge-dpkg';
      }
      ok('PURGE(apt/dpkg and dependencies)', {})
    end
    if a == 'perl' then
      buildah{
        'run';
        '--volume';
        F('%s:/ub', util_buildah);
        name;
        '--';
        '/ub';
        'purge-perl';
      }
      ok('PURGE(perl)', {})
    end
    if a == 'userland' then
      buildah{
        'run';
        '--volume';
        F('%s:/ub', util_buildah);
        name;
        '--';
        '/ub';
        'purge-userland';
      }
      ok('PURGE(perl)', {})
    end
    if a == 'docs' or a == 'documentation' then
      buildah{
        'run';
        '--volume';
        F('%s:/ub', util_buildah);
        name;
        '--';
        '/ub';
        'purge-docs';
      }
      ok('PURGE(docs)', {})
    end
    if a == 'shell' or a == 'sh' then
      buildah{
        'run';
        '--volume';
        F('%s:/ub', util_buildah);
        name;
        '--';
        '/ub';
        'purge-sh';
      }
      ok('PURGE(sh)', {})
    end
  end
  setfenv(2, env)
end

return {
  from = from
}
