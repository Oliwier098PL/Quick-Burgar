local Animation = {}

-- Load animation settings
function Animation.load()
    -- Settings for 2-frame animations
     TwoAnFrame = 1
     TwoAnTimer = 0
     TwoAnSpeed = 0.3
     
     -- Settings for 3-frame animations
     ThreeAnFrame = 1
     ThreeAnTimer = 0
     ThreeAnSpeed = 0.3

     -- Settings for non-looping 3-frame animations
     ThreeAnFrameOnce = 1
     ThreeAnTimerOnce = 0
     ThreeAnSpeedOnce = 0.3
     ThreeAnOnOnce = false
end

-- Update animation frames
function Animation.update(dt)
    -- Animate 2-frame textures
    TwoAnTimer = TwoAnTimer + dt
    if TwoAnTimer >= TwoAnSpeed then
        TwoAnTimer = 0
        TwoAnFrame = TwoAnFrame % 2 + 1
    end

    -- Animate 3-frame textures
    ThreeAnTimer = ThreeAnTimer + dt
    if ThreeAnTimer >= ThreeAnSpeed then
        ThreeAnTimer = 0
        ThreeAnFrame = ThreeAnFrame % 3 + 1
    end

    -- Animate non-looping 3-frame textures
    -- To reset: ThreeAnFrameOnce = 1; ThreeAnTimerOnce = 0; ThreeAnOnOnce = false
    -- Or call Animation.ResetNotLoopingAnim()
    if ThreeAnOnOnce == true then
        ThreeAnTimerOnce = ThreeAnTimerOnce + dt

        if ThreeAnFrameOnce < 3 then
            if ThreeAnTimerOnce >= ThreeAnSpeedOnce then
                ThreeAnTimerOnce = 0
                ThreeAnFrameOnce = ThreeAnFrameOnce + 1
            end
        end
    end
end

-- Update 3D offsets for stereoscopic rendering
function Animation.updateOffsets(screen)
    Two_Offset = 0
    Three_Offset = 0
    Four_Offset = 0
    Five_Offset = 0

    -- 3D offsets for left eye
    if screen == "left" then
        Two_Offset = -sysDepth * 2
        Three_Offset = -sysDepth * 3
        Four_Offset = -sysDepth * 4
        Five_Offset = -sysDepth * 5
    
    -- 3D offsets for right eye
    elseif screen == "right" then
        Two_Offset = sysDepth * 2
        Three_Offset = sysDepth * 3
        Four_Offset = sysDepth * 4
        Five_Offset = sysDepth * 5
    end
end

-- Reset non-looping animation
function Animation.ResetNotLoopingAnim()
    ThreeAnFrameOnce = 1
    ThreeAnTimerOnce = 0
    ThreeAnOnOnce = false
end

return Animation