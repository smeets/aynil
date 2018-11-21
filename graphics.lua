
function loadStandardTheme()
	local path = "assets/tilesheet_transparent.png"
	local sheet = love.graphics.newImage(path)

	return {
		sheet = sheet,
		grass = {
			love.graphics.newQuad(0,    0, 15, 15, sheet:getDimensions()),
			love.graphics.newQuad(17.5, 0, 15, 15, sheet:getDimensions()),
			love.graphics.newQuad(34.5, 0, 15, 15, sheet:getDimensions())
		},
		player = {
			love.graphics.newQuad(476, 0, 16, 16, sheet:getDimensions())
		}
	}
end

local Themes = {
	standard = loadStandardTheme
}

return Themes