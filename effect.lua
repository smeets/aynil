baton   = require "lib/baton"
vec     = require "lib/brinevector"
physics = require "physics"

function Effect(idx)
	local p = {
	  id = idx,
	  active = false,
	  state = physics.State(),
    owner = 0,
    ttl = 0,
    dttl = 0,
	}
	return p
end

return Effect
