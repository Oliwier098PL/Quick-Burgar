local Fries = {}

local NorX,NorY,		OilX,OilY, PotatoRandom
local minVol,maxVol,FryingVolQuiter
local Potato,PotatoCutHalf,		PotatoCut,PotatoOil,PotatoDoneOil,PotatoPacked,PotatoFUCKED


-- Load fries-related assets and initialize variables
function Fries.load(BottomUI)
	math.randomseed(os.time())
	NorX         = math.random(24, 68)			-- Random position on table
	NorY         = math.random(87, 113)
	OilX         = math.random(184, 207)		-- Random position in oil
	OilY         = math.random(33, 98)
	PotatoRandom = math.random(1, 5)			-- Random potato appearance

	minVol = 0
	maxVol = 0.25
	FryingVolQuiter = 0.50
	FriesTimerTime   = 10
	FriesTimer       = FriesTimerTime
	FriesTimerVisual = 0
	FriesTimerOn     = false
	FriesBurned      = false
	FriesDone        = false
	PotatoState      = "None"

	PotatoSpritesheet = love.graphics.newImage("assets/textures/PotatoSpritesheet.png")

	PotatoRandSSVar = PotatoRandom * 90 - 90

	-- Define potato quads for different states
	Potato           = love.graphics.newQuad(0,PotatoRandSSVar,	   70,90,  PotatoSpritesheet)
	PotatoCutHalf    = love.graphics.newQuad(70,PotatoRandSSVar,   70,90,  PotatoSpritesheet)
	PotatoCut        = love.graphics.newQuad(140,0,	   70,90,  PotatoSpritesheet)
	PotatoOil        = love.graphics.newQuad(140,90,   70,90,  PotatoSpritesheet)
	PotatoDoneOil    = love.graphics.newQuad(140,270,  70,90,  PotatoSpritesheet)
	PotatoPacked     = love.graphics.newQuad(210,0,    78,129, PotatoSpritesheet)
	PotatoFUCKED     = love.graphics.newQuad(140,180,  70,90,  PotatoSpritesheet)

	-- Load sound effects
	SoundCutting1    = love.audio.newSource("assets/sounds/cutting.ogg", "static")
	SoundCutting2    = love.audio.newSource("assets/sounds/cutting.ogg", "static")
	SoundSend        = love.audio.newSource("assets/sounds/done.ogg", "static")
	SoundPacking     = love.audio.newSource("assets/sounds/packing.ogg", "static")
	SoundQuietFrying = love.audio.newSource("assets/sounds/EndFrying.ogg", "static")
	SoundLoudFrying  = love.audio.newSource("assets/sounds/fryingLoud.ogg", "static")
	SoundPotato      = love.audio.newSource("assets/sounds/PotatoPickup.ogg", "static")
	SoundFrying      = love.audio.newSource("assets/sounds/frying.ogg", "stream")
	

	SoundFrying:setLooping(true)
	SoundPacking:setVolume(1.5)
	SoundSend:setVolume(2)
end


-- Reset potato to initial state
function resetPotato()
	PotatoState      = "None"
	FriesTimer       = FriesTimerTime
	FriesTimerOn     = false
	FriesBurned      = false
	FriesDone        = false
	FriesTimerVisual = 0
	NorX         = math.random(24, 68)
	NorY         = math.random(87, 113)
	OilX         = math.random(184, 207)
	OilY         = math.random(33, 98)
	PotatoRandom = math.random(1, 5)
	PotatoRandSSVar = PotatoRandom * 90 - 90
	Potato           = love.graphics.newQuad(0,PotatoRandSSVar,	   70,90,  PotatoSpritesheet)
	PotatoCutHalf    = love.graphics.newQuad(70,PotatoRandSSVar,   70,90,  PotatoSpritesheet)
end

-- Handle button inputs for fries processing
function Fries.press(button, BottomUI, TopUI)
	if targetX == 0 then
		-- Pick up potato
		if (button == "a" or button == "leftshoulder") and PotatoState == "None" then
			PotatoState = "Normal"
			SoundPotato:play()

		-- Cut potato in half
		elseif button == "rightshoulder" and PotatoState == "Normal" then
			PotatoState = "HalfCuted"
			SoundCutting1:play()

		-- Finish cutting
		elseif button == "rightshoulder" and PotatoState == "HalfCuted" then
			PotatoState = "Cuted"
			SoundCutting2:play()

		-- Put in oil to fry
		elseif button == "x" and PotatoState == "Cuted" then
			PotatoState  = "Oil"
			FriesTimerOn = true
			SoundLoudFrying:play()

		-- Take out of oil when done
		elseif button == "x" and PotatoState == "Oil" and FriesDone and not FriesBurned then
			PotatoState  = "DoneOil"
			FriesTimerOn = false
			SoundQuietFrying:play()

		-- Pack fries
		elseif button == "y" and PotatoState == "DoneOil" then
			PotatoState = "Packed"
			SoundPacking:play()

		-- Send order
		elseif button == "dpdown" and PotatoState == "Packed" then
			if OrderFries == true then
				OrderFries = false
				TopUI.CheckOrder()
			end
			SoundSend:play()
			resetPotato()

		-- Throw away potato
		elseif button == "b" then
			resetPotato()
		end
	end
end


function Fries.draw(Animation, BottomUI)
	-- Draw the potato based on current state
	if PotatoState == "Burned" then
		love.graphics.draw(PotatoSpritesheet,PotatoFUCKED,  BottomUI.x + OilX, OilY)
	elseif PotatoState == "Normal" then
		love.graphics.draw(PotatoSpritesheet,Potato,         BottomUI.x + NorX, NorY)
	elseif PotatoState == "HalfCuted" then
		love.graphics.draw(PotatoSpritesheet,PotatoCutHalf,  BottomUI.x + NorX, NorY)
	elseif PotatoState == "Cuted" then
		love.graphics.draw(PotatoSpritesheet,PotatoCut,      BottomUI.x + NorX, NorY)
	elseif PotatoState == "Oil" then
		love.graphics.draw(PotatoSpritesheet,PotatoOil,      BottomUI.x + OilX, OilY)
	elseif PotatoState == "DoneOil" then
		love.graphics.draw(PotatoSpritesheet,PotatoDoneOil,  BottomUI.x + NorX, NorY)
	elseif PotatoState == "Packed" then
		love.graphics.draw(PotatoSpritesheet,PotatoPacked,   BottomUI.x + NorX, NorY)
	end

	-- Draw the timer bar
	love.graphics.setColor(0,1/31,0)
	love.graphics.rectangle("fill", 208+BottomUI.x,5, 55,5)

	if FriesTimerOn == true and FriesTimer > 0 then
		love.graphics.setColor(0,1,0)
		love.graphics.rectangle("fill", 208+BottomUI.x,5, (FriesTimer / FriesTimerTime)*55,5)
	end

	love.graphics.setColor(1,1,1)
end

function Fries.update(BottomUI, dt)
	-- Calculate frying sound volume based on screen position
	local t = (BottomUI.x + 640) / 640
	t = math.max(0, math.min(1, t))

	FryingVol = minVol + t * (maxVol - minVol)

	SoundFrying:setVolume(FryingVol)
	-- Remove to Test if volume works:
	--print("Frying Volume: "..FryingVol)

	-- Oil Timer logic
	if FriesTimerOn then
		FriesTimer = FriesTimer - dt

		if FriesTimer <= -3 then
			FriesBurned      = true
			FriesDone        = false
			FriesTimerOn     = false
			FriesTimerVisual = 11
			PotatoState      = "Burned"
		elseif FriesTimer <= 0 then
			FriesDone        = true
			FriesTimerVisual = 11
		end
	end

	if SoundFrying:isPlaying() == false and quicktimerSTOP == false then
		SoundFrying:play()
	end
end

return Fries