local BottomUI = {}

-- Setting variables in advance so they are gonna be local in scrypt not in function
local speed, step, minX, maxX


-- Loading everything
function BottomUI.load()
	BottomImgs = {}
	BottomImgs[1] = love.graphics.newImage("assets/textures/bottom1.png")
	BottomImgs[2] = love.graphics.newImage("assets/textures/bottom2.png")

	BottomUI.x    = -320
	targetX = BottomUI.x

	speed = 12
	step  = 320
	minX  = -640
	maxX  = 0
end


-- Sets a limit to how far we can go with bottom screen with d-pad
function clamp(x, min, max)
	return math.max(min, math.min(max, x))
end


-- When we click with d-pad it checks where to move and if we can move
function BottomUI.press(button)
	if button == "dpleft" then
		targetX = clamp(targetX + step, minX, maxX)
	elseif button == "dpright" then
		targetX = clamp(targetX - step, minX, maxX)
	end
end


-- Calculates the smooth moveing between e.g. Burgers --> Sodas
function BottomUI.update(dt)
	BottomUI.x = BottomUI.x + (targetX - BottomUI.x) * math.min(speed * dt, 1)
end


-- Drawing
function BottomUI.draw(Animation)
	love.graphics.draw(BottomImgs[TwoAnFrame], BottomUI.x, 0)
end

return BottomUI