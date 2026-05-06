 -- Nest Library initialization for 3DS
nest_ok, nest = pcall(function()
    return require("nest").init({ console = "3ds" })
end)

-- Require other Lua modules
local Title		 = require "title"
local BottomUI   = require "bottom_ui"
local TopUI      = require "top_ui"
local Fries      = require "fries"
local Sodas      = require "sodas"
local Burgers    = require "burgers"
	  TimeTimer  = require "timetimer"
      Animation  = require "animation"


-- Game state variables
Mode      = "Title"
Pause     = false
WasPaused = false

-- Transition system for screen fading
local Transition = {
    active = false,
    alpha  = 0,
    speed  = 1.5,      -- Higher value means faster transition
    going  = "in",     -- "in" = fade to black, "out" = fade from black
    next   = nil,      -- Next mode after transition
}

-- Joystick X axis handling
local axisX          = 0	-- Current Joystick's X Axis
local axisXCooldown  = 0.2	-- Joystick's Cooldown to prevent multiple inputs
local axisXTimer     = 0	-- Cooldown timer

-- Joystick Y axis handling
local axisY          = 0	-- Current Joystick's Y Axis
local axisYCooldown  = 0.2	-- Joystick's Cooldown
local axisYTimer     = 0	-- Cooldown timer
local axisYPrev = 0			-- Previous Y value to detect changes

-- Love.load: Initialize all modules
function love.load()
	Animation.load()
	Title.load()
	BottomUI.load()
	Fries.load(BottomUI)
	Sodas.load(BottomUI)
	TopUI.load()
	Burgers.load()

	-- Start initial transition to title screen
	Transition.active = true
    Transition.alpha  = 1
    Transition.going  = "out"
    Transition.next   = "Title"
end


function love.update(dt)
	-- Handle screen transitions
	if Transition.active == true then
    	if Transition.going == "in" then
    	    Transition.alpha = math.min(1, Transition.alpha + Transition.speed * dt)
    	    if Transition.alpha >= 1 then
    	        Mode = Transition.next
    	        Transition.going = "out"
    	    end
    	else
    	    Transition.alpha = math.max(0, Transition.alpha - Transition.speed * dt)
    	    if Transition.alpha <= 0 then
    	        Transition.active = false
    	    end
    	end
	end

	-- Get 3DS 3D slider depth
	sysDepth = -love.graphics.getDepth()

	-- Update joystick cooldown timers
	if axisYTimer > 0 then
		axisYTimer = axisYTimer - dt
	end

	if axisXTimer > 0 then
		axisXTimer = axisXTimer - dt
	end
	
	-- Handle horizontal joystick input (d-pad left/right)
	if axisXTimer <= 0 then
		if axisX < -0.5 then
			if Mode == "Game" and Pause == false then
				BottomUI.press("dpleft")
			end
			axisXTimer = axisXCooldown
		elseif axisX > 0.5 then
			if Mode == "Game" and Pause == false then
				BottomUI.press("dpright")
			end
			axisXTimer = axisXCooldown
		end
	end

	-- Handle vertical joystick input (d-pad up/down)
	if axisYTimer <= 0 then
    	if axisY > 0.5 and axisYPrev <= 0.5 then
    	    -- Up pressed
    	    if Mode == "Game"  and Pause == false then
    	        Burgers.buttons("dpup", BottomUI, TopUI)
    	    elseif Mode == "Title" then
    	        Title.buttons("dpup")
    	    end
    	    axisYTimer = axisYCooldown

    	elseif axisY < -0.5 and axisYPrev >= -0.5 then
    	    -- Down pressed
    	    if Mode == "Game"  and Pause == false then
    	        Fries.press("dpdown", BottomUI, TopUI)
    	        Sodas.buttons("dpdown", BottomUI, TopUI)
    	        Burgers.buttons("dpdown", BottomUI, TopUI)
    	    elseif Mode == "Title" then
    	        Title.buttons("dpdown")
    	    end
    	    axisYTimer = axisYCooldown
    	end
	end

	-- Update previous Y axis value
	axisYPrev = axisY

	-- Update modules if not paused
	if Pause == false then
		Animation.update(dt)

		if Mode == "Game" then
			TimeTimer.update(dt)
			BottomUI.update(dt)
			Burgers.update(dt)
			Fries.update(BottomUI, dt)
			Sodas.update(dt, BottomUI)
			TopUI.update(dt)
		elseif Mode == "Title" then
			Title.update(dt)
			ResetGame()
		end
	end
end


-- Handle joystick axis input
function love.gamepadaxis(joystick, axis, value)
	if axis == "leftx" then
		axisX = tonumber(value) or 0
	elseif axis == "lefty" then
		axisY = tonumber(value) or 0
	end
end

-- Handle gamepad button presses
function love.gamepadpressed(joystick, button)
	if Mode == "Game" then
		if Pause == false then
			-- Pass button presses to game modules
			BottomUI.press(button)
			TopUI.buttons(button)
			Fries.press(button, BottomUI, TopUI)
			Sodas.buttons(button, BottomUI, TopUI)
			Burgers.buttons(button, BottomUI, TopUI)
		end

		-- Handle pause functionality
		if button == "back" and quicktimerSTOP == false then
			if Pause == false then
				Pause = true
				love.audio.pause()
			else
				Pause = false
				SoundFrying:play()

				if SodaState == "Pouring" then
					SoundMashine:play()
					SoundSoda:play()
				end
			end
		end
		
		-- Handle unpause and return to title
		if button == "a" and Pause == true then
			Pause = false
			TimeTimer.Reset()
			Title.CalculateBest()
			StartTransition("Title")
		end

	elseif Mode == "Title" then
		Title.buttons(button)
	end
end


-- Main draw function
function love.draw(screen)
	Animation.updateOffsets(screen)

	if screen == "bottom" then
		-- Draw bottom screen content
		if Mode == "Game" then
			BottomUI.draw(Animation)
			Fries.draw(Animation, BottomUI)
			Sodas.draw(Animation, BottomUI)
			Burgers.draw(Animation, BottomUI)
		elseif Mode == "Title" then
			Title.BottomDraw(Animation)
		end

	else
		-- Draw top screen content
		if Mode == "Game" then
			TopUI.draw(Animation, screen)
		elseif Mode == "Title" then
			Title.TopDraw(Animation)
		end
	end
	
	-- Draw transition overlay
	if Transition.active == true then
    	love.graphics.setColor(1, 1, 1, Transition.alpha)
    	love.graphics.rectangle("fill", 0, 0, 400, 240)
    	love.graphics.setColor(1, 1, 1)
	end

	-- Draw pause/game over screens
	if Pause == true and quicktimerSTOP == true then
		-- Game over screen
		if screen == "bottom" then
			-- Bottom screen
			love.graphics.setColor(50/255, 0, 0, 138/255)
    		love.graphics.rectangle("fill", 0, 0, 320, 240)
    		love.graphics.setColor(1, 1, 1)

			love.graphics.draw(TitleSpritesheet,RanOutText, 94,16)
			love.graphics.draw(TitleSpritesheet,TimeAText, 80,144)
			
		else
			-- Top screen
			love.graphics.setColor(50/255, 0, 0, 138/255)
    		love.graphics.rectangle("fill", 0, 0, 400, 240)
    		love.graphics.setColor(1, 1, 1)

			love.graphics.draw(TitleSpritesheet,GameOverText,  Five_Offset+165,19)

			love.graphics.draw(TopUISpritesheet,PointsVis,      Two_Offset+135,100)

    		love.graphics.setColor(0, 0, 0)
    		love.graphics.print(Points.QuickTime[HardnessSelected],SharpFont,         Three_Offset+192,118)
    		love.graphics.setColor(1, 1, 1)

			if Points.QuickTime[HardnessSelected] > Best.QuickTime[HardnessSelected] then
				love.graphics.draw(TitleSpritesheet,NewBestText,      Four_Offset+157,84)
			end
		end
	elseif Pause == true then
		-- Regular pause screen
		if screen == "bottom" then
			love.graphics.setColor(0, 0, 0, 138/255)
    		love.graphics.rectangle("fill", 0, 0, 320, 240)
    		love.graphics.setColor(1, 1, 1)

			love.graphics.draw(TitleSpritesheet,PausedAText, 80,144)
			
		else
			love.graphics.setColor(0, 0, 0, 138/255)
    		love.graphics.rectangle("fill", 0, 0, 400, 240)
    		love.graphics.setColor(1, 1, 1)

			love.graphics.draw(TitleSpritesheet,PausedText,  Five_Offset+165,19)
		end
	end
end

-- Start a screen transition to a new mode
function StartTransition(nextMode)
    Transition.active = true
    Transition.alpha  = 0
    Transition.going  = "in"
    Transition.next   = nextMode
	Transition.from   = Mode
end

-- Reset game state for new game
function ResetGame()
	-- Stop all sounds
	SoundFrying:stop()
    SoundMashine:stop()
    SoundSoda:stop()
	
	-- Reset all game modules
	Sodareset()
	resetPotato()
	Burgers.reset()
	TopUI.NewOrder()

	-- Reset UI positions
	CookBookXPosition = 393
    CookBookXTarget = 393
    CookBookOpened = false

	BottomUI.x = -320
	targetX = BottomUI.x

	-- Reset points
	Points = { QuickTime = { Easy = 0, Medium = 0, Hard = 0 } }
end