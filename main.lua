lurker = require "lib/lurker"
vec    = require "lib/brinevector"

lurker.postswap = function (f) 
    init() 
end

theme   = require "graphics"
physics = require "physics"
player  = require "player"
effect  = require "effect"

local players = { player(1), player(2), player(3), player(4) }
local effects = { Effect(1), }
-- idx is the entity ID. an entity may have one or more effects, it may be a plaer or a hound, etc.

local hound = {
  state = physics.State(),
  boost = 0
}

local target = {
  state = physics.State(),
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
  init_ttl = 5
  init_color = vec(1,1)
  targetIsOwned = false
  targetIsFree  = true
  target.owner = 0

  hound.state.position = vec(0, 0)
  hound.state.velocity = vec(0, 0)
  hound.state.momentum = vec(0, 0)
  hound.boost = 0

  for i,player in ipairs(players) do
    player.state.position = vec(20, H/2)
    player.state.velocity = vec(100,0)
    player.color = init_color
  end

  for i,effect in ipairs(effects) do
    effect.state.position = vec(W*.85/1, H/2)
    effect.ttl = init_ttl
    effect.dttl = -1
    effect.owner = 0
  end
  target.state.position = vec(W/2, H/2)
  target.state.velocity = players[1].state.position - target.state.position

  local joysticks = love.joystick.getJoysticks()
  for i, joystick in ipairs(joysticks) do
      players[joystick:getID()].active = true
  end

  players[1].active = true

  gfx = theme.standard()
end

function updatePlayer(player, t, dt)
  player.input:update()

  local mx, my = player.input:get 'move'
  local ax, ay = player.input:get 'aim'

  local dx = player.state.position - target.state.position
  if dx.length < 30 and target.owner == 0 then 
    target.owner = player.id
  end

  player.state.velocity.y = player.state.velocity.y + my * 4000 * dt;
  player.state.velocity.x = player.state.velocity.x + mx * 4000 * dt;
  if player.state.velocity.length > 500 then
    local f = 500 / player.state.velocity.length
    player.state.velocity = player.state.velocity * f
  end

  if player.input:pressed 'action' and target.owner == player.id then
    local dir = vec(mx, my)
    target.state.position = player.state.position + dir * 35;
    target.state.velocity = dir * 1000
    target.owner = 0
  end

  if player.input:pressed 'reload' then
    init()
  end

  player.state.velocity = player.state.velocity * 0.90
  player.state.position = player.state.position + player.state.velocity * dt
end

function updateHound(t, dt)
  local accel = function (s, t)
    return (target.state.position - s.position).normalized * 800
  end

  physics.evaluate(hound.state, t, dt, accel, 0.96)

  if hound.state.velocity.length < 150 and target.owner > 0 then
    hound.boost = math.min(0.5, hound.boost + 0.05 * dt)
  elseif target.owner == 0 then 
    hound.boost = hound.boost * 0.92
    hound.state.velocity = hound.state.velocity * (1 + hound.boost)
  end
end

function updateTarget(t, dt)
  local accel = function (s, t)
    if target.owner > 0 then
      local player = players[target.owner]
      return (player.state.position - target.state.position) * 10 * dt
    else
      return vec(0, 0)
    end
  end

  if target.owner == 0 then
    physics.evaluate(target.state, t, dt, accel, 0.98)
  else
    local player = players[target.owner]
    local ax, ay = player.input:get 'move'
    target.state.position = player.state.position + vec(ax, ay) * 35 - vec((w-5)/2,(h-5)/2);
  end
end

function updateEffect(effect, dt)
  if effect.ttl >= 0 then
    if effect.owner ~= 0 then
      local player = players[effect.owner]
      local dc = 0.3*math.sin((init_ttl-effect.ttl)*20)

      effect.ttl = effect.ttl + effect.dttl*dt
      effect.state.position = player.state.position
      player.color = init_color - vec(dc,dc)
    else
      for i, player in ipairs(players) do
        player.color = init_color
        local dx = player.state.position - effect.state.position
        if dx.length < 30 then
          effect.owner = player.id
        end
      end
    end
  elseif effect.ttl < 0 and effect.owner ~= 0 then
    local player = players[effect.owner]
    player.color = init_color
  end
end


function bounceBounds(state, w, h)
  local x, y = state.position:split()
  if x < 0 then
    state.velocity.x = -state.velocity.x
    state.position.x = 1
  end
  if x+w > W then
    state.velocity.x = -state.velocity.x
    state.position.x = W-w-1
  end
  
  if y < 0 then
    state.velocity.y = -state.velocity.y
    state.position.y = 0
  end
  if y+h > H then
    state.velocity.y = -state.velocity.y
    state.position.y = H-h
  end
end

function love.joystickadded(joystick)
  players[joystick:getID()].active = true
end

function love.joystickremoved(joystick)
  players[joystick:getID()].active = false
end

-- Increase the size of the rectangle every frame.
local t = 0
function love.update(gdt)
  t = t + gdt

  updateHound(t, gdt)
  for i, player in ipairs(players) do
    if player.active then
      updatePlayer(player, t, gdt)
      bounceBounds(player.state, w, h)
    end
  end
  updateTarget(t, gdt)

  bounceBounds(hound.state, w, h)
  bounceBounds(target.state, w-5, h-5)


  -- iterate throuhg all effects. effects on a heap (priority queue, sorted by ttl). an effect has a playerid, its own id, a position.
  
  for i,effect in ipairs(effects) do
    updateEffect(effect, gdt)
  end
  lurker.update()
end

local grassLayout = love.math.newRandomGenerator(100)

function drawGrass()
  grassLayout:setSeed(100)
  local h_sprites = W / 64
  local v_sprites = H / 64

  love.graphics.setColor(1,1,1)
  for x=0,h_sprites do
    for y=0,v_sprites do
      local idx = grassLayout:random(3)
      love.graphics.draw(gfx.sheet, gfx.grass[idx], x * 64, y * 64, 0, 4.25, 4.25)
    end
  end
end

function getPlayerColor(playerIndex)
  for i,effect in ipairs(effects) do
    if effect.owner == playerIndex then
      return 0,0,0.8
    end
  end
  return 1,1,1
end

function love.draw()
  drawGrass()

  local x, y = hound.state.position:split()
  love.graphics.setColor(0.4, 0, 0)
  love.graphics.rectangle("fill", x, y, w, h)

  for i,player in ipairs(players) do
    if player.active then
      x, y = player.state.position:split()
      local vx, vy = player.state.velocity:split()
      local orientation = math.atan2(vy, vx)
      local g,b = player.color:split()
      --getPlayerColor(i)
      love.graphics.setColor(1,g,b)
      love.graphics.draw(gfx.sheet, gfx.player[1], x, y, orientation, 2, 2, 8, 8)
    end
  end
  
  x, y = target.state.position:split()
  love.graphics.setColor(0, 0.0, 0.4)
  love.graphics.rectangle("fill", x, y, w-5, h-5)

  -- draw effects if "free"
  for i,effect in ipairs(effects) do
    if effect.ttl >= 0 and effect.owner == 0 then
      x, y = effect.state.position:split()
      love.graphics.setColor(0.4, 0.4, 0.4)
      love.graphics.circle("fill", x+w/2, y+h/2, w-15, h-15)
    end
    if effect.owner ~= 0 then
      love.graphics.setColor(0, 0.0, 0.8)
      love.graphics.rectangle("fill", 10, 10 + 10 * effect.owner, (w+20)*effect.ttl/init_ttl, 5)
    end
  end
end
