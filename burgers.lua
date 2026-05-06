local Burgers = {}

local PattyShelf, PattyShelfY, PattyShelfOpened, PattyShelfSpeed
local BurgerStack = {}
local BurgerRecipes = {}
local Sauces = {}

-- Load burger-related assets and initialize variables
function Burgers.load()
    -- Load burger spritesheet and define ingredient quads
    BurgerSpritesheet = love.graphics.newImage("assets/textures/BurgerSpritesheet.png")

    Bun_Top    = love.graphics.newQuad(0,0,   112,96, BurgerSpritesheet)
    Bun_Bottom = love.graphics.newQuad(112,0, 112,96, BurgerSpritesheet)
    Cheese     = love.graphics.newQuad(224,0, 112,96, BurgerSpritesheet)
    Lettuce    = love.graphics.newQuad(336,0, 112,96, BurgerSpritesheet)
    Patty      = love.graphics.newQuad(448,0, 112,96, BurgerSpritesheet)
    Ketchup    = love.graphics.newQuad(560,0, 112,96, BurgerSpritesheet)
    Mustard    = love.graphics.newQuad(672,0, 112,96, BurgerSpritesheet)

    -- Load sauce sounds
    SoundMusta = love.audio.newSource("assets/sounds/sauce.ogg", "static")
    SoundKetch = love.audio.newSource("assets/sounds/sauce.ogg", "static")
    SoundKetch:setVolume(0.25)
    SoundMusta:setVolume(0.25)

    -- Load patty shelf image
    PattyShelf = love.graphics.newImage("assets/textures/PattyShelf.png")

    -- Initialize patty shelf animation
    PattyShelfY = -197
    PattyShelfYPosition = -197
    PattyShelfOpened = false
    PattyShelfSpeed = 12

    -- Initialize burger stack
    BurgerStack = {}
    BurgerStackCount = 0

    -- Define sauces (for special handling in recipes)
    Sauces = { [Ketchup] = true, [Mustard] = true }

    -- Define burger recipes
    BurgerRecipes = {
        Ham     = { Bun_Bottom, Patty, Ketchup, Mustard, Bun_Top },
        Cheese  = { Bun_Bottom, Patty, Cheese, Ketchup, Mustard, Bun_Top },
        Classic = { Bun_Bottom, Lettuce, Patty, Ketchup, Mustard, Cheese, Bun_Top },
        Keto    = { Lettuce, Cheese, Patty, Cheese, Lettuce },
        Lettuc  = { Bun_Bottom, Lettuce, Cheese, Ketchup, Mustard, Lettuce, Bun_Top },
        BigBun  = { Bun_Bottom, Cheese, Patty, Ketchup, Mustard, Bun_Bottom, Cheese, Ketchup, Mustard, Patty, Lettuce, Patty, Cheese, Bun_Top },
    }
end

-- Handle button inputs for burger building
function Burgers.buttons(button, BottomUI, TopUI)
    -- Check if burger station is active
    if targetX == -320 then
        -- Toggle patty shelf
        if button == "dpup" then
            if PattyShelfOpened == true then
                PattyShelfY = -197
                PattyShelfOpened = false
            elseif PattyShelfOpened == false then
                PattyShelfY = -50
                PattyShelfOpened = true
            end
        end

        -- Add bun bottom
        if button == "b" then
            BurgerStackCount = BurgerStackCount + 1
            local newY = 111 - (BurgerStackCount * 10)
            table.insert(BurgerStack, { thing = Bun_Bottom, y = newY })

        -- Add bun top
        elseif button == "x" then
            BurgerStackCount = BurgerStackCount + 1
            local newY = 111 - (BurgerStackCount * 10)
            table.insert(BurgerStack, { thing = Bun_Top, y = newY })

        -- Add cheese (when shelf closed)
        elseif button == "a" and PattyShelfOpened == false then
            local newY = 111 - (BurgerStackCount * 10)
            table.insert(BurgerStack, { thing = Cheese, y = newY })

        -- Add lettuce
        elseif button == "y" then
            local newY = 111 - (BurgerStackCount * 10)
            table.insert(BurgerStack, { thing = Lettuce, y = newY })

        -- Add ketchup
        elseif button == "leftshoulder" then
            local newY = 111 - ((BurgerStackCount - 1) * 10)
            table.insert(BurgerStack, { thing = Ketchup, y = newY })

            SoundKetch:play()

        -- Add mustard
        elseif button == "rightshoulder" then
            local newY = 111 - ((BurgerStackCount - 1) * 10)
            table.insert(BurgerStack, { thing = Mustard, y = newY })

            SoundMusta:play()

        -- Add patty (when shelf open)
        elseif button == "a" and PattyShelfOpened == true then
            BurgerStackCount = BurgerStackCount + 1
            local newY = 111 - (BurgerStackCount * 10)
            table.insert(BurgerStack, { thing = Patty, y = newY })
        end

        -- Submit burger
        if button == "dpdown" then
            if Burgers.Check() == true then
                OrderBurger = "None"
                TopUI.CheckOrder()
            end
            BurgerStack = {}
            BurgerStackCount = 0
        end
    end
end

-- Check if burger stack matches a recipe (handles sauces separately)
function Burgers.StackMatchesRecipe(recipe)
    local stackOrdered = {}
    local stackSauces = {}
    for _, item in ipairs(BurgerStack) do
        if Sauces[item.thing] == true then
            stackSauces[item.thing] = (stackSauces[item.thing] or 0) + 1
        else
            table.insert(stackOrdered, item.thing)
        end
    end

    local recipeOrdered = {}
    local recipeSauces = {}
    for _, ingredient in ipairs(recipe) do
        if Sauces[ingredient] == true then
            recipeSauces[ingredient] = (recipeSauces[ingredient] or 0) + 1
        else
            table.insert(recipeOrdered, ingredient)
        end
    end

    -- Check ordered ingredients
    if #stackOrdered ~= #recipeOrdered then return false end
    for i = 1, #recipeOrdered do
        if stackOrdered[i] ~= recipeOrdered[i] then return false end
    end

    -- Check sauces (can be in any order)
    for sauce, count in pairs(recipeSauces) do
        if (stackSauces[sauce] or 0) < count == true then return false end
    end

    return true
end

-- Check if current burger stack matches the ordered burger
function Burgers.Check()
    if OrderBurger == "None" then return false end

    local recipe = BurgerRecipes[OrderBurger]
    if recipe and Burgers.StackMatchesRecipe(recipe) == true then
        return true
    end
    return false
end

-- Update patty shelf animation
function Burgers.update(dt)
    PattyShelfYPosition = PattyShelfYPosition + (PattyShelfY - PattyShelfYPosition) * math.min(PattyShelfSpeed * dt, 1)
end

-- Draw burger stack and patty shelf
function Burgers.draw(Animation, BottomUI)
    -- Draw burger ingredients
    for _, item in ipairs(BurgerStack) do
        love.graphics.draw(BurgerSpritesheet, item.thing, BottomUI.x + 500, item.y)
    end

    -- Draw patty shelf
    love.graphics.draw(PattyShelf, BottomUI.x + 452, PattyShelfYPosition)
end

-- Reset burger station
function Burgers.reset()
    BurgerStack = {}
    BurgerStackCount = 0
    PattyShelfY = -197
    PattyShelfOpened = false
end

return Burgers