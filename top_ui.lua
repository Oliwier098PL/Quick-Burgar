local TopUI = {}

math.randomseed(os.time())

-- Load ALL The Variables, Textures and Fonts
-- And Set ALL Of Them to something
function TopUI.load()
    -- Load fonts
    SharpFont        = love.graphics.newFont("assets/fonts/SharpFont.ttf", 32)
    
    -- Load background image
    Background       = love.graphics.newImage("assets/textures/Background.png")

    -- Load cookbook image
    CookBook         = love.graphics.newImage("assets/textures/CookBook.png")

    -- Load top UI spritesheet and define quads for various UI elements
    TopUISpritesheet = love.graphics.newImage("assets/textures/TopUISpritesheet.png")
    OrderVis         = love.graphics.newQuad(0,0,       160,240,    TopUISpritesheet)
    PointsVis        = love.graphics.newQuad(537,149,   128,64,     TopUISpritesheet)

    FriesVis         = love.graphics.newQuad(537,73,   126,76,     TopUISpritesheet)

    -- Burger order visuals
    HamBurgarVis     = love.graphics.newQuad(160,0,     126,81,     TopUISpritesheet)
    CheeseBurgarVis  = love.graphics.newQuad(160,81,    126,81,     TopUISpritesheet)
    ClassicBurgarVis = love.graphics.newQuad(160,162,   126,81,     TopUISpritesheet)
    KetoBurgarVis    = love.graphics.newQuad(286,0,     126,81,     TopUISpritesheet)
    LettucBurgarVis  = love.graphics.newQuad(286,81,    126,81,     TopUISpritesheet)
    BigBunBurgarVis  = love.graphics.newQuad(286,162,   126,81,     TopUISpritesheet)

    -- Soda order visuals
    CokendVis        = love.graphics.newQuad(412,0,     125,73,     TopUISpritesheet)
    FuntumVis        = love.graphics.newQuad(412,73,    125,73,     TopUISpritesheet)
    SpiatrusVis      = love.graphics.newQuad(412,146,   125,73,     TopUISpritesheet)
    IceTeaVis        = love.graphics.newQuad(537,0,     125,73,     TopUISpritesheet)

    QuickTimerVis    = love.graphics.newQuad(569,185,   10,1,       TopUISpritesheet)

    -- Load sound effects
    SoundNewOrder    = love.audio.newSource("assets/sounds/neworder.ogg", "static")
    SoundCookBook    = love.audio.newSource("assets/sounds/PotatoPickup.ogg", "static")

    -- Initialize background position
    BackgroundPosition = {X=0, Y=0}

    -- Initialize order states
    OrderFries       = false
    OrderBurger      = "None"
    OrderSoda        = "None"

    -- Cookbook animation variables
    CookBookXPosition = 393
    CookBookXTarget = 393
    CookBookOpened = false

    TopUI.NewOrder()
end


function TopUI.update(dt)
    local speed = 25
    local CookBookSpeed = 25

    -- Update background position for scrolling effect
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

    -- Animate cookbook sliding in/out
    CookBookXPosition = CookBookXPosition + (CookBookXTarget - CookBookXPosition) * math.min(CookBookSpeed * dt, 1)
end

function TopUI.buttons(button)
    -- Handle button presses for UI interactions
    if button == "start" then
        -- Toggle cookbook open/close
        if CookBookOpened == false then
            CookBookOpened = true
            CookBookXTarget = 0

            SoundCookBook:play()
        else
            CookBookOpened = false
            CookBookXTarget = 393

            SoundCookBook:play()
        end
    end
end

function TopUI.draw(Animation, screen, TimeTimer)
    -- Draw scrolling background
    love.graphics.draw(Background, BackgroundPosition.X, BackgroundPosition.Y)
    love.graphics.draw(Background, BackgroundPosition.X - 384, BackgroundPosition.Y)
    love.graphics.draw(Background, BackgroundPosition.X, BackgroundPosition.Y + 224)
    love.graphics.draw(Background, BackgroundPosition.X - 384, BackgroundPosition.Y + 224)


    -- Draw quick timer bar
    love.graphics.setColor(0,0.25,0)
    love.graphics.rectangle("fill", Two_Offset+3,13, 13,205)
    love.graphics.setColor(1,1,1)
    love.graphics.draw(TopUISpritesheet,QuickTimerVis,  Two_Offset+6,13+(205 - scaleVis), 0, 1,scaleVis)

    -- Draw order and points UI elements
    love.graphics.draw(TopUISpritesheet,OrderVis,       Two_Offset+0,0)
    love.graphics.draw(TopUISpritesheet,PointsVis,      Two_Offset+272,0)

    -- Draw points text
    love.graphics.setColor(0, 0, 0)

    if Timeless == false then
        love.graphics.print(Points.QuickTime[HardnessSelected],SharpFont,         Three_Offset+329,18)
    else
        love.graphics.print(Points.TimelessTime,               SharpFont,         Three_Offset+329,18)
    end

    love.graphics.setColor(1, 1, 1)


    -- Draw ordered fries if applicable
    if OrderFries == true then
        love.graphics.draw(TopUISpritesheet,FriesVis,         Three_Offset+26,10)
    end
    
    -- Draw ordered burger based on type
    if OrderBurger == "Ham" then
        love.graphics.draw(TopUISpritesheet,HamBurgarVis,     Three_Offset+26,84)
    elseif OrderBurger == "Cheese" then
        love.graphics.draw(TopUISpritesheet,CheeseBurgarVis,  Three_Offset+26,84)
    elseif OrderBurger == "Classic" then
        love.graphics.draw(TopUISpritesheet,ClassicBurgarVis,  Three_Offset+26,84)
    elseif OrderBurger == "Keto" then
        love.graphics.draw(TopUISpritesheet,KetoBurgarVis,  Three_Offset+26,84)
    elseif OrderBurger == "Lettuc" then
        love.graphics.draw(TopUISpritesheet,LettucBurgarVis,  Three_Offset+26,84)
    elseif OrderBurger == "BigBun" then
        love.graphics.draw(TopUISpritesheet,BigBunBurgarVis,  Three_Offset+26,84)
    end
    
    -- Draw ordered soda based on type
    if OrderSoda == "Cokend" then
        love.graphics.draw(TopUISpritesheet,CokendVis,  Three_Offset+27,152)
    elseif OrderSoda == "Funtum" then
        love.graphics.draw(TopUISpritesheet,FuntumVis,  Three_Offset+27,152)
    elseif OrderSoda == "Spiatrus" then
        love.graphics.draw(TopUISpritesheet,SpiatrusVis,  Three_Offset+27,152)
    elseif OrderSoda == "IceTea" then
        love.graphics.draw(TopUISpritesheet,IceTeaVis,  Three_Offset+27,152)
    end


    -- Draw cookbook
    love.graphics.draw(CookBook,    CookBookXPosition,0)
end

function TopUI.NewOrder()
    -- Decrease duration if above minimum
    if duration > MinDuration then
        duration = duration - MinusDuration
    end
    -- Reset the timer
    TimeTimer.Reset()

    -- Randomize order items
    local RandomFriesIf = math.random(0,1)

    local RandomBurgerIf = math.random(0,1)
    local RandomBurger = math.random(1,6)

    local RandomSodaIf = math.random(0,1)
    local RandomSoda = math.random(1,4)


    -- Determine fries order
    if RandomFriesIf == 1 then
        OrderFries = true
    else
        OrderFries = false
    end
    
    -- Determine burger order
    if RandomBurgerIf == 1 then
        if RandomBurger == 1 then
            OrderBurger = "Ham"
        elseif RandomBurger == 2 then
            OrderBurger = "Cheese"
        elseif RandomBurger == 3 then
            OrderBurger = "Classic"
        elseif RandomBurger == 4 then
            OrderBurger = "Keto"
        elseif RandomBurger == 5 then
            OrderBurger = "Lettuc"
        elseif RandomBurger == 6 then
            OrderBurger = "BigBun"
        end
    else
        OrderBurger = "None"
    end
    
    -- Determine soda order
    if RandomSodaIf == 1 then
        if RandomSoda == 1 then
            OrderSoda = "Cokend"
        elseif RandomSoda == 2 then
            OrderSoda = "Funtum"
        elseif RandomSoda == 3 then
            OrderSoda = "Spiatrus"
        elseif RandomSoda == 4 then
            OrderSoda = "IceTea"
        end
    else
        OrderSoda = "None"
    end


    -- If the order is blank roll again
    if RandomFriesIf == 0 and RandomBurgerIf == 0 and RandomSodaIf == 0 then
        print("0 Order! Again!")
        TopUI.NewOrder()
        return
    end

    -- Print order details
    print("============ New Order! ================")
    print( "Fries: "..tostring(OrderFries))
    print("Burger: "..OrderBurger)
    print(  "Soda: "..OrderSoda)
end

function TopUI.CheckOrder()
    -- Debug print current order
    print(tostring(OrderFries), OrderBurger, OrderSoda)
    -- If order is complete (all items none/false), award points and generate new order
    if OrderFries == false and OrderBurger == "None" and OrderSoda == "None" then

        if Timeless == false then
            Points.QuickTime[HardnessSelected] = Points.QuickTime[HardnessSelected] + 1
        else
            Points.TimelessTime = Points.TimelessTime + 1
        end
        SoundNewOrder:play()
        TopUI.NewOrder()
    end
end

return TopUI