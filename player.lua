baton   = require "lib/baton"
vec     = require "lib/brinevector"
physics = require "physics"

function Player(idx)
	local p = {
	  id = idx,
	  active = false,
	  state = physics.State(),
	  input = baton.new {
		  controls = {
		    left = {'key:left', 'key:a', 'axis:leftx-', 'button:dpleft'},
		    right = {'key:right', 'key:d', 'axis:leftx+', 'button:dpright'},
		    up = {'key:up', 'key:w', 'axis:lefty-', 'button:dpup'},
		    down = {'key:down', 'key:s', 'axis:lefty+', 'button:dpdown'},
		    aleft = {'key:left', 'key:a', 'axis:rightx-', 'button:dpleft'},
		    aright = {'key:right', 'key:d', 'axis:rightx+', 'button:dpright'},
		    aup = {'key:up', 'key:w', 'axis:righty-', 'button:dpup'},
		    adown = {'key:down', 'key:s', 'axis:righty+', 'button:dpdown'},
		    action = {'key:space', 'axis:triggerright+'},
		    reload = {'key:r', 'button:y'},
		  },
		  pairs = {
		    move = {'left', 'right', 'up', 'down'},
		    aim  =  {'aleft', 'aright', 'aup', 'adown'}
		  },
		  joystick = love.joystick.getJoysticks()[idx],
		}
	}
	return p
end

return Player