-- Building block for fixed timestep game loop
-- https://gafferongames.com/post/fix_your_timestep/

local timer = love.timer
local graphics = love.graphics

function run(arg)
	if love.load then love.load(arg) end

	local t  = 0.0
	local dt = 0.016

	local currentTime = 0
	local accumulator = 0

	while true do
		local newTime = 0
		local frameTime = newTime - currentTime
		if frameTime > 0.25 then
			frameTime = 0.25
		end

		currentTime = newTime
		accumulator = accumulator + frameTime

		while accumulator >= dt do
			-- previous = current
			-- current = update(t, dt)
			t = t + dt
			accumulator = accumulator - dt
		end

		local alpha = accumulator / dt
		-- state = currentState * alpha +
		-- previous * (1.0 - alpha)
	end

end