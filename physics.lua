local vec = require "lib/brinevector"

function State()
	local s = {
		position = vec(0,0),
		velocity = vec(0,0)
	}
	return s
end

function Derivative() 
	local d = {
		velocity = vec(0,0),
		acceleration = vec(0,0)
	}
	return d
end

function evaluate(initial, t, dt, d, accel)
	s = State()
	s.position = initial.position + d.velocity * dt
	s.velocity = initial.velocity + d.acceleration * dt
	s.velocity = s.velocity * 0.95
	
	d = Derivative()
	d.velocity = s.velocity
	d.acceleration = accel(s, t + dt)
	return s, d
end

return {
	evaluate = evaluate,
	State = State,
	Derivative = Derivative
}