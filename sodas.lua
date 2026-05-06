local Sodas = {}

local SodaClosed, SodaOpened
local SodaCokend, SodaFuntum, SodaSpiatrus, SodaIceTea
local StreamCokend = {}
local StreamFuntum = {}
local StreamSpiatrus = {}
local StreamIceTea = {}

local StreamCokendLong = {}
local StreamFuntumLong = {}
local StreamSpiatrusLong = {}
local StreamIceTeaLong = {}

-- Load soda-related assets and initialize variables
function Sodas.load(BottomUI)
    SodaSpritesheet = love.graphics.newImage("assets/textures/SodasSpritesheet.png")

    -- Define soda machine quads
    SodaClosed   = love.graphics.newQuad(0,0,       52,108, SodaSpritesheet)
    SodaOpened   = love.graphics.newQuad(52,0,      52,108, SodaSpritesheet)
    SodaCokend   = love.graphics.newQuad(52,108,    52,108, SodaSpritesheet)
    SodaFuntum   = love.graphics.newQuad(52,216,    52,108, SodaSpritesheet)
    SodaSpiatrus = love.graphics.newQuad(52,324,    52,108, SodaSpritesheet)
    SodaIceTea   = love.graphics.newQuad(52,432,    52,108, SodaSpritesheet)

    -- Overflow states
    SodaCokendOver   = love.graphics.newQuad(104,108,       52,108, SodaSpritesheet)
    SodaFuntumOver   = love.graphics.newQuad(104,216,       52,108, SodaSpritesheet)
    SodaSpiatrusOver = love.graphics.newQuad(104,324,       52,108, SodaSpritesheet)
    SodaIceTeaOver   = love.graphics.newQuad(104,432,       52,108, SodaSpritesheet)

    -- Partial fill states
    SodaCokendLil   = love.graphics.newQuad(0,108,       52,108, SodaSpritesheet)
    SodaFuntumLil   = love.graphics.newQuad(0,216,       52,108, SodaSpritesheet)
    SodaSpiatrusLil = love.graphics.newQuad(0,324,       52,108, SodaSpritesheet)
    SodaIceTeaLil   = love.graphics.newQuad(0,432,       52,108, SodaSpritesheet)

    -- Pouring streams
    StreamCokend[1]   = love.graphics.newQuad(104,0,       4,34, SodaSpritesheet)
    StreamCokend[2]   = love.graphics.newQuad(108,0,       4,34, SodaSpritesheet)

    StreamFuntum[1]   = love.graphics.newQuad(113,0,       4,34, SodaSpritesheet)
    StreamFuntum[2]   = love.graphics.newQuad(117,0,       4,34, SodaSpritesheet)

    StreamSpiatrus[1] = love.graphics.newQuad(122,0,       4,34, SodaSpritesheet)
    StreamSpiatrus[2] = love.graphics.newQuad(126,0,       4,34, SodaSpritesheet)

    StreamIceTea[1]   = love.graphics.newQuad(131,0,       4,34, SodaSpritesheet)
    StreamIceTea[2]   = love.graphics.newQuad(135,0,       4,34, SodaSpritesheet)

    -- Long streams for pouring
    StreamCokendLong[1]   = love.graphics.newQuad(104,0,       4,48, SodaSpritesheet)
    StreamCokendLong[2]   = love.graphics.newQuad(108,0,       4,48, SodaSpritesheet)

    StreamFuntumLong[1]   = love.graphics.newQuad(113,0,       4,48, SodaSpritesheet)
    StreamFuntumLong[2]   = love.graphics.newQuad(117,0,       4,48, SodaSpritesheet)

    StreamSpiatrusLong[1] = love.graphics.newQuad(122,0,       4,48, SodaSpritesheet)
    StreamSpiatrusLong[2] = love.graphics.newQuad(126,0,       4,48, SodaSpritesheet)

    StreamIceTeaLong[1]   = love.graphics.newQuad(131,0,       4,48, SodaSpritesheet)
    StreamIceTeaLong[2]   = love.graphics.newQuad(135,0,       4,48, SodaSpritesheet)

    -- Load sounds
    SoundDone       = love.audio.newSource("assets/sounds/done.ogg", "static")
    SoundCup        = love.audio.newSource("assets/sounds/lid.ogg", "static")
    SoundMashine    = love.audio.newSource("assets/sounds/mashine.ogg", "stream")
    SoundSoda       = love.audio.newSource("assets/sounds/soda.ogg", "stream")
    SoundMashine:setLooping(true)
    SoundSoda:setLooping(true)

    -- Volume calculation
    InBetweenMusicZones = math.max(-640, math.min(0, BottomUI.x))
    MashineVol = (InBetweenMusicZones - -640) / (0 - -640)

    minVol = 0
    maxVol = 0.25

    -- Initialize state
    SodaState    = "None"
    SodaPoured   = "None"

    PourTimer    = 6
    PourTimerDone= false
    PourTimerOn  = false

    math.randomseed(os.time())

    RandX        = math.random(652, 686)
    RandY        = math.random(52, 103)
end

function Sodas.buttons(button, BottomUI, TopUI)
    if targetX == -640 then

       -- Open soda machine
       if SodaState == "None" and (button == "a" or button == "leftshoulder") then
            SodaState = "NormalOpened"
            SoundCup:play()

        -- Pour Cokend
        elseif SodaState == "NormalOpened" and button == "x" then
            SodaState = "Pouring"
            SodaPoured   = "Cokend"
            PourTimerOn  = true

            SoundMashine:play()
            SoundSoda:play()

        -- Pour Funtum
        elseif SodaState == "NormalOpened" and button == "y" then
            SodaState = "Pouring"
            SodaPoured   = "Funtum"
            PourTimerOn  = true

            SoundMashine:play()
            SoundSoda:play()

        -- Pour Spiatrus
        elseif SodaState == "NormalOpened" and button == "b" then
            SodaState = "Pouring"
            SodaPoured   = "Spiatrus"
            PourTimerOn  = true

            SoundMashine:play()
            SoundSoda:play()

        -- Pour IceTea
        elseif SodaState == "NormalOpened" and button == "a" then
            SodaState = "Pouring"
            SodaPoured   = "IceTea"
            PourTimerOn  = true

            SoundMashine:play()
            SoundSoda:play()
    
       -- Take poured soda
       elseif SodaState == "Pouring" and math.floor(PourTimer) == 0 and (button == "x" or button == "leftshoulder") then
            SodaState = "Taken"
            PourTimerOn  = false

            SoundMashine:stop()
            SoundSoda:stop()

        -- Pack soda
        elseif SodaState == "Taken" and (button == "rightshoulder" or button == "y") then
            SodaState = "Packed"

            SoundCup:play()

        -- Send order
        elseif SodaState == "Packed" and button == "dpdown" then

            print("Soda Comparison: "..SodaPoured.." and "..OrderSoda)

            if SodaPoured == OrderSoda then
                OrderSoda = "None"
                TopUI.CheckOrder()
            end

            SoundDone:play()
            Sodareset()

        -- Throw away/reset
        elseif SodaState ~= "NormalOpened" and button == "b" then
            SoundMashine:stop()
            SoundSoda:stop()
            Sodareset()
        end
    end
end

-- Update soda pouring timer and volume
function Sodas.update(dt, BottomUI)
    local t = (BottomUI.x + 640) / 640
	t = math.max(0, math.min(1, t))
    t = 1 - t

	MashineVol = minVol + t * (maxVol - minVol)

	SoundMashine:setVolume(MashineVol)
    SoundSoda:setVolume(MashineVol)
    --print(MashineVol)

	if PourTimerOn == true then
		PourTimer = PourTimer - dt
        --print("PourTimer: "..PourTimer.."")
    end
end

-- Draw soda machine and pouring animation
function Sodas.draw(Animation, BottomUI)
    if SodaState == "NormalOpened" then
        love.graphics.draw(SodaSpritesheet,SodaOpened, BottomUI.x + RandX,RandY)

    elseif SodaState == "Pouring" then
        if math.floor(PourTimer) == 0 then
            if SodaPoured == "Cokend" then
                love.graphics.draw(SodaSpritesheet,SodaCokend,   BottomUI.x + 749,95)
                love.graphics.draw(SodaSpritesheet,StreamCokend[TwoAnFrame], BottomUI.x + 773,88)

            elseif SodaPoured == "Funtum" then
                love.graphics.draw(SodaSpritesheet,SodaFuntum, BottomUI.x + 800,95)
                love.graphics.draw(SodaSpritesheet,StreamFuntum[TwoAnFrame], BottomUI.x + 824,88)

            elseif SodaPoured == "Spiatrus" then
                love.graphics.draw(SodaSpritesheet,SodaSpiatrus, BottomUI.x + 851,95)
                love.graphics.draw(SodaSpritesheet,StreamSpiatrus[TwoAnFrame], BottomUI.x + 875,88)

            elseif SodaPoured == "IceTea" then
                love.graphics.draw(SodaSpritesheet,SodaIceTea, BottomUI.x + 902,95)
                love.graphics.draw(SodaSpritesheet,StreamIceTea[TwoAnFrame], BottomUI.x + 926,88)

            end
            
        elseif math.floor(PourTimer) == 1 then
            if SodaPoured == "Cokend" then
                love.graphics.draw(SodaSpritesheet,SodaCokendLil, BottomUI.x + 749,95)
                love.graphics.draw(SodaSpritesheet,StreamCokend[TwoAnFrame], BottomUI.x + 773,88)

            elseif SodaPoured == "Funtum" then
                love.graphics.draw(SodaSpritesheet,SodaFuntumLil, BottomUI.x + 800,95)
                love.graphics.draw(SodaSpritesheet,StreamFuntum[TwoAnFrame], BottomUI.x + 824,88)

            elseif SodaPoured == "Spiatrus" then
                love.graphics.draw(SodaSpritesheet,SodaSpiatrusLil, BottomUI.x + 851,95)
                love.graphics.draw(SodaSpritesheet,StreamSpiatrus[TwoAnFrame], BottomUI.x + 875,88)

            elseif SodaPoured == "IceTea" then
                love.graphics.draw(SodaSpritesheet,SodaIceTeaLil, BottomUI.x + 902,95)
                love.graphics.draw(SodaSpritesheet,StreamIceTea[TwoAnFrame], BottomUI.x + 926,88)

            end
        elseif PourTimer <= 0 then
            if SodaPoured == "Cokend" then
                love.graphics.draw(SodaSpritesheet,SodaCokendOver, BottomUI.x + 749,95)
                love.graphics.draw(SodaSpritesheet,StreamCokend[TwoAnFrame], BottomUI.x + 773,88)

            elseif SodaPoured == "Funtum" then
                love.graphics.draw(SodaSpritesheet,SodaFuntumOver, BottomUI.x + 800,95)
                love.graphics.draw(SodaSpritesheet,StreamFuntum[TwoAnFrame], BottomUI.x + 824,88)

            elseif SodaPoured == "Spiatrus" then
                love.graphics.draw(SodaSpritesheet,SodaSpiatrusOver, BottomUI.x + 851,95)
                love.graphics.draw(SodaSpritesheet,StreamSpiatrus[TwoAnFrame], BottomUI.x + 875,88)

            elseif SodaPoured == "IceTea" then
                love.graphics.draw(SodaSpritesheet,SodaIceTeaOver, BottomUI.x + 902,95)
                love.graphics.draw(SodaSpritesheet,StreamIceTea[TwoAnFrame], BottomUI.x + 926,88)

            end
        else
            if SodaPoured == "Cokend" then
                love.graphics.draw(SodaSpritesheet,SodaOpened, BottomUI.x + 749,95)
                love.graphics.draw(SodaSpritesheet,StreamCokendLong[TwoAnFrame], BottomUI.x + 773,88)

            elseif SodaPoured == "Funtum" then
                love.graphics.draw(SodaSpritesheet,SodaOpened, BottomUI.x + 800,95)
                love.graphics.draw(SodaSpritesheet,StreamFuntumLong[TwoAnFrame], BottomUI.x + 824,88)

            elseif SodaPoured == "Spiatrus" then
                love.graphics.draw(SodaSpritesheet,SodaOpened, BottomUI.x + 851,95)
                love.graphics.draw(SodaSpritesheet,StreamSpiatrusLong[TwoAnFrame], BottomUI.x + 875,88)

            elseif SodaPoured == "IceTea" then
                love.graphics.draw(SodaSpritesheet,SodaOpened, BottomUI.x + 902,95)
                love.graphics.draw(SodaSpritesheet,StreamIceTeaLong[TwoAnFrame], BottomUI.x + 926,88)
                
            end
        end

    elseif SodaState == "Taken" then
        if SodaPoured == "Cokend" then
            love.graphics.draw(SodaSpritesheet,SodaCokend, BottomUI.x + RandX,RandY)
        elseif SodaPoured == "Funtum" then
            love.graphics.draw(SodaSpritesheet,SodaFuntum, BottomUI.x + RandX,RandY)
        elseif SodaPoured == "Spiatrus" then
            love.graphics.draw(SodaSpritesheet,SodaSpiatrus, BottomUI.x + RandX,RandY)
        elseif SodaPoured == "IceTea" then
            love.graphics.draw(SodaSpritesheet,SodaIceTea, BottomUI.x + RandX,RandY)
        end
    elseif SodaState == "Packed" then
        love.graphics.draw(SodaSpritesheet,SodaClosed, BottomUI.x + RandX,RandY)
    end


    love.graphics.setColor(0,0.125,0)
    love.graphics.rectangle("fill", 824+BottomUI.x,15, 55,5)
    love.graphics.setColor(1,1,1)

    if PourTimerOn == true and PourTimer > 0 then
        love.graphics.setColor(0,1,0)
        love.graphics.rectangle("fill", 824+BottomUI.x,15, (PourTimer / 6)*55,5)
        love.graphics.setColor(1,1,1)
    end
end

-- Reset soda machine to initial state
function Sodareset()
    SodaState    = "None"
    SodaPoured   = "None"

    PourTimer    = 6
    PourTimerDone= false
    PourTimerOn  = false

    math.randomseed(os.time())
    RandX        = math.random(652, 686)
    RandY        = math.random(52, 103)
end

return Sodas