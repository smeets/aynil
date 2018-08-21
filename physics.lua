local vec = require "lib/brinevector"

function State()
	local s = {
		position = vec(0,0),
		velocity = vec(0,0),
		momentum = vec(0,0),
	}
	return s
end

function evaluate(state, t, dt, accel, f)
	state.position = state.position + state.velocity * dt
	state.velocity = state.velocity + state.momentum * dt
	state.velocity = state.velocity * f
	state.momentum = accel(state, t + dt)
end

return {
	evaluate = evaluate,
	State = State
}