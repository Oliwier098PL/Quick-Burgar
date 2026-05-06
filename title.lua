local Title = {}

-- Load title screen assets and initialize variables
function Title.load()
    -- Load fonts and spritesheet
    BoldPixelsFont   = love.graphics.newFont("assets/fonts/BoldPixels.ttf", 16)
    TitleSpritesheet = love.graphics.newImage("assets/textures/TitleSpritesheet.png")

    -- Define quads for menu buttons
    Button1          = love.graphics.newQuad(177,0,   288,80,  TitleSpritesheet)
    Button2          = love.graphics.newQuad(177,80,  288,80,  TitleSpritesheet)
    Button3          = love.graphics.newQuad(177,160, 288,80,  TitleSpritesheet)

    -- Difficulty level quads
    Easy             = love.graphics.newQuad(465,0,   58 ,76,  TitleSpritesheet)
    Medium           = love.graphics.newQuad(465,76,  58 ,76,  TitleSpritesheet)
    Hard             = love.graphics.newQuad(465,152, 58 ,76,  TitleSpritesheet)

    -- Other UI elements
    Credit           = love.graphics.newQuad(0,116,   160,16,  TitleSpritesheet)
    Version          = love.graphics.newQuad(0,132,   64 ,16,  TitleSpritesheet)
    Logo             = love.graphics.newQuad(0,0,     177,116, TitleSpritesheet)
    LineRounded      = love.graphics.newQuad(160,128, 16 ,16,  TitleSpritesheet)
    PausedText       = love.graphics.newQuad(65,133,  69 ,9,   TitleSpritesheet)
    PausedAText      = love.graphics.newQuad(0,149,   160,32,  TitleSpritesheet)
    TimeAText        = love.graphics.newQuad(0,193,   160,32,  TitleSpritesheet)
    GameOverText     = love.graphics.newQuad(0,182,   67 ,9,   TitleSpritesheet)
    NewBestText      = love.graphics.newQuad(68,182,  83 ,10,  TitleSpritesheet)
    RanOutText       = love.graphics.newQuad(0,226,   132,11,  TitleSpritesheet)

    -- Button animation variables
    Button1YScale    = 0
    Button2YScale    = 0
    Button3YScale    = 0
    HardnessSelected = "Medium"
    HardnessQuads = { Easy = Easy, Medium = Medium, Hard = Hard }
    ButtonSelected   = 1
    ButtonScaleSpeed = 10
    
    -- Logo animation variables
    LogoY            = 29
    LogoTimer        = 0.25
    LogoUp           = true

    LogoUpYMax       = 26
    LogoDownYMax     = 32
    LogoTimerSet     = 0.25
    LogoSpeed        = 10

    -- Score tracking
    Best             = { QuickTime = {Easy = 0, Medium = 0, Hard = 0}}
    Points           = { QuickTime = {Easy = 0, Medium = 0, Hard = 0}}

    -- Load best scores from save file
    local data = love.filesystem.read("save.dat")
    if data then
        local chunk = loadstring and loadstring(data) or load(data)
        if chunk then
            local success, err = pcall(chunk)
            if not success then
                print("Failed to load save.dat:", err)
            end
        end
    end

    Best = Best or { QuickTime = {Easy = 0, Medium = 0, Hard = 0}}
    Best.QuickTime = Best.QuickTime or {Easy = 0, Medium = 0, Hard = 0}
end


-- Handle button inputs for menu navigation
function Title.buttons(button)
    if button == "a" and ButtonSelected == 1 then
        StartTransition("Game")
        TimeTimer.Reset()

    elseif button == "dpdown" then
        if ButtonSelected ~= 3 then
            ButtonSelected = ButtonSelected + 1
        end
    elseif button == "dpup" then
        if ButtonSelected ~= 1 then
            ButtonSelected = ButtonSelected - 1
        end
    
    elseif button == "x" then
        HardnessSelected = "Easy"
    elseif button == "y" then
        HardnessSelected = "Medium"
    elseif button == "b" then
        HardnessSelected = "Hard"
    end
end


-- Update title screen animations
function Title.update(dt)
    local speed = 25

    -- Scroll background
    BackgroundPosition.X = BackgroundPosition.X + speed * dt
    BackgroundPosition.Y = BackgroundPosition.Y - speed * dt

    -- Loop background horizontally
    if BackgroundPosition.X >= 384 then
        BackgroundPosition.X = BackgroundPosition.X - 384
    end

    if BackgroundPosition.X <= -384 then
        BackgroundPosition.X = BackgroundPosition.X + 384
    end

    -- Loop background vertically
    if BackgroundPosition.Y >= 224 then
        BackgroundPosition.Y = BackgroundPosition.Y - 224
    end

    if BackgroundPosition.Y <= -224 then
        BackgroundPosition.Y = BackgroundPosition.Y + 224
    end

    -- Animate logo bouncing
    if LogoUp == true then
        if LogoY <= LogoUpYMax then
            LogoTimer = LogoTimer - dt

            if LogoTimer <= 0 then
                LogoTimer = LogoTimerSet
                LogoUp = false
            end
        else
            LogoY = LogoY - LogoSpeed * dt
        end
    else
        if LogoY >= LogoDownYMax then
            LogoTimer = LogoTimer - dt

            if LogoTimer <= 0 then
                LogoTimer = LogoTimerSet
                LogoUp = true
            end
        else
            LogoY = LogoY + LogoSpeed * dt
        end
    end

    -- Animate button scaling for selection
    local target1 = (ButtonSelected == 1) and 1 or 0
    local target2 = (ButtonSelected == 2) and 1 or 0
    local target3 = (ButtonSelected == 3) and 1 or 0

    Button1YScale = Button1YScale + (target1 - Button1YScale) * ButtonScaleSpeed * dt
    Button2YScale = Button2YScale + (target2 - Button2YScale) * ButtonScaleSpeed * dt
    Button3YScale = Button3YScale + (target3 - Button3YScale) * ButtonScaleSpeed * dt
end


function Title.BottomDraw()
    -- Draw scrolling background
    love.graphics.draw(Background, BackgroundPosition.X, BackgroundPosition.Y)
    love.graphics.draw(Background, BackgroundPosition.X - 384, BackgroundPosition.Y)
    love.graphics.draw(Background, BackgroundPosition.X, BackgroundPosition.Y + 224)
    love.graphics.draw(Background, BackgroundPosition.X - 384, BackgroundPosition.Y + 224)

    
    -- Draw UI borders
    love.graphics.draw(TitleSpritesheet,LineRounded, 0  ,0,   0)
    love.graphics.draw(TitleSpritesheet,LineRounded, 0  ,240, -math.pi/2)
    love.graphics.draw(TitleSpritesheet,LineRounded, 320,240, -math.pi)
    love.graphics.draw(TitleSpritesheet,LineRounded, 320,0,   -(math.pi*3)/2)

    love.graphics.setColor(154/255,0,13/255, 191/255)
    love.graphics.rectangle("fill", 16,7,   288,2)
    love.graphics.rectangle("fill", 16,231, 288,2)
    love.graphics.rectangle("fill", 7,16,   2,288)
    love.graphics.rectangle("fill", 311,16, 2,288)
    love.graphics.setColor(1,1,1, 1)


    -- Draw menu buttons
    love.graphics.draw(TitleSpritesheet,Button1, 16,56,  0, 1,Button1YScale, 0,40)
    love.graphics.draw(TitleSpritesheet,Button2, 16,120, 0, 1,Button2YScale, 0,40)
    love.graphics.draw(TitleSpritesheet,Button3, 16,184, 0, 1,Button3YScale, 0,40)

    -- Draw best score
    love.graphics.setColor(1,197/255,0)
    local bestValue = (Best and Best.QuickTime and Best.QuickTime[HardnessSelected]) or 0
    love.graphics.print("Best: "..bestValue, BoldPixelsFont, 123,55+23*Button1YScale, 0, 1,Button1YScale)
    love.graphics.setColor(1,1,1)

    -- Draw selected difficulty
    love.graphics.draw(TitleSpritesheet, HardnessQuads[HardnessSelected], 244,56, 0, 1,Button1YScale, 0,38)
end


-- Draw top screen of title
function Title.TopDraw()
    -- Draw scrolling background
    love.graphics.draw(Background, BackgroundPosition.X, BackgroundPosition.Y)
    love.graphics.draw(Background, BackgroundPosition.X - 384, BackgroundPosition.Y)
    love.graphics.draw(Background, BackgroundPosition.X, BackgroundPosition.Y + 224)
    love.graphics.draw(Background, BackgroundPosition.X - 384, BackgroundPosition.Y + 224)

    -- Draw animated logo
    love.graphics.draw(TitleSpritesheet,Logo,    Five_Offset+ 112,LogoY)

    -- Draw credits and version
    love.graphics.draw(TitleSpritesheet,Credit,  Two_Offset+ 0,  224)
    love.graphics.draw(TitleSpritesheet,Version, Two_Offset+ 336,224)
end


-- Update best scores and save to file
function Title.CalculateBest()
    if Points.QuickTime[HardnessSelected] > Best.QuickTime[HardnessSelected] then
        Best.QuickTime[HardnessSelected] = Points.QuickTime[HardnessSelected]

        -- Save best scores to file
        local save_text = string.format(
            "Best = { QuickTime = {Easy = %d, Medium = %d, Hard = %d}}",
            Best.QuickTime.Easy,
            Best.QuickTime.Medium,
            Best.QuickTime.Hard
        )

        love.filesystem.write("save.dat", save_text)
    end
end


return Title