TimeTimer = {}

-- Quick Timer Variables
duration = 1111111111  -- Initial duration (very large for initial setup)
MinusDuration = 11111  -- Amount to decrease duration each order
MinDuration = 1111111   -- Minimum duration

local actualtimer  = duration     -- Actual timer value (counts down)
quicktimer         = 90           -- Timer display value (integer part)
quicktimerSTOP     = false        -- Flag when timer reaches 0
quicktimerVisScale = 0
progress = actualtimer / duration
targetHeightVis = 205 * (1 - progress)
scaleVis = 205 * progress

-- Update timer each frame
function TimeTimer.update(dt)
    if Pause == false then
        progress = actualtimer / duration

        targetHeightVis = 205 * (1 - progress)
        scaleVis = 205 * progress
    
        actualtimer = actualtimer - dt          -- Decrease timer by delta time
        quicktimer = math.floor(actualtimer)    -- Get integer part for display

        -- When timer hits 0, stop game
        if actualtimer <= 0 then
            quicktimerSTOP = true
            Pause = true
            love.audio.pause()
        end
    end
end

-- Reset timer based on difficulty
function TimeTimer.Reset()
    if HardnessSelected == "Easy" then
        duration = 120
        MinusDuration = 3
        MinDuration = 50
    elseif HardnessSelected == "Medium" then
        duration = 75
        MinusDuration = 5
        MinDuration = 30
    elseif HardnessSelected == "Hard" then
        duration = 55
        MinusDuration = 8
        MinDuration = 18
    end

    actualtimer = duration
    quicktimerSTOP = false
end

return TimeTimer