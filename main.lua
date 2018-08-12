lurker = require "lib/lurker"
vec     = require "lib/brinevector"

lurker.postswap = function (f) 
    init() 
end

physics = require "physics"
player  = require "player"

local players = { player(1), player(2), player(3), player(4) }

local hound = {
  state = physics.State(),
  deriv = physics.Derivative()
}

local target = {
  state = physics.State(),
  deriv = physics.Derivative(),
  owner = 0
}

-- Load some default values for our rectangle.
function love.load()
  init()
end

function init()
  W = love.graphics.getWidth()
  H = love.graphics.getHeight()
  w, h = 30, 30
  targetIsOwned = false
  targetIsFree  = true

  hound.state.position = vec(0, 0)
  hound.state.velocity = vec(0,0)

  for i = 1, 4 do
    players[i].state.position = vec(20, H/2)
    players[i].state.velocity = vec(100,0)
  end

  target.state.position = vec(W/2, H/2)
  target.state.velocity = players[1].state.position - target.state.position
end

function updatePlayer(player, t, dt)
  player.input:update()

  local mx, my = player.input:get 'move'
  local ax, ay = player.input:get 'aim'

  local dx = player.state.position - target.state.position
  if dx.length < 30 then 
    target.owner = player.id
  end

  player.state.velocity.y = player.state.velocity.y + my * 1000 * dt;
  player.state.velocity.x = player.state.velocity.x + mx * 1000 * dt;

  if player.input:pressed 'action' and target.owner == player.id then
    target.state.velocity = vec(ax, ay) * 10
    target.owner = 0
  end

  if love.keyboard.isDown("r") then
    init()
  end

  player.state.velocity = player.state.velocity * 0.98
  player.state.position = player.state.position + player.state.velocity * dt
end

function updateHound(t, dt)
  local accel = function (s, t)
    return (target.state.position - s.position).normalized * 800
  end

  state, deriv = physics.evaluate(hound.state, t, dt, hound.deriv, accel)
  hound.state = state
  hound.deriv = deriv
end

function updateTarget(t, dt)
  local accel = function (s, t)
    if target.owner > 0 then
      local player = players[target.owner]
      return (player.state.position - target.state.position) * 10
    else
      return vec(0, 0)
    end
  end

  if target.owner == 0 then
    state, deriv = physics.evaluate(target.state, t, dt, target.deriv, accel)
    target.state = state
    target.deriv = deriv
  else
    local player = players[target.owner]
    target.state.position = player.state.position + player.state.velocity * 10 * dt
  end
end

function bounceBounds(state)
  local x, y = state.position:split()
  if x < 0 or x+w>W then
    state.velocity.x = -state.velocity.x
  end
  if y < 0 or y+h>H then
    state.velocity.y = -state.velocity.y
  end
end

-- Increase the size of the rectangle every frame.
local t = 0
function love.update(gdt)
  t = t + gdt

  updateHound(t, gdt)
  for i=1,4 do
    updatePlayer(players[i], t, gdt)
    bounceBounds(players[i].state)
  end
  updateTarget(t, gdt)

  bounceBounds(hound.state)
  bounceBounds(target.state)
  
  lurker.update()
end

-- Draw a coloured rectangle.
function love.draw()
  local x, y = hound.state.position:split()
  love.graphics.setColor(0.4, 0, 0)
  love.graphics.rectangle("fill", x, y, w, h)

  for i=1,4 do
    local player = players[i]
    x, y = player.state.position:split()
    love.graphics.setColor(0, 0.4, 0.4)
    love.graphics.rectangle("fill", x, y, w, h)
  end
  x, y = target.state.position:split()
  love.graphics.setColor(0, 0.0, 0.4)
  love.graphics.rectangle("fill", x, y, w-5, h-5)
end
