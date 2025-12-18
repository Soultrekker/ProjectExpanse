require "source/tools"
require "source/room"
require "source/textbox"
require "source/character"
require "source/clickbox"

-- Initializes once at the start of the program
function love.load()
    initEnvironment()
    
    love.physics.setMeter(64)
    initVerts()
    initMeshes()
    initMouseClickBox()
end

turnstate = "stopped" -- can be "left", "right", "stopped"
turn_progress = 0
move_progress = 1
turn_speed = .013
move_speed = .013
move_forward = false -- event flag for state machine
move_backward = false -- event flag for state machine
look_state = "N" -- can be 1 North, 2 East, 3 South, 4 West

gamestate = "menu"
base_scale = 1
scale = base_scale
back_opacity = 0 -- opacity of back wall changes when turning, looks EXTRA cool

-- Handles key press events
function love.keypressed(key)
    if key == "escape" then
        love.event.quit() --exit the game
    end

    -- Raises event flags for moving forward/backward
    if key == "up" then
        move_forward = true
    end
    if key == "down" then
        move_backward = true
    end

    -- Moving left/right only works if not already turning or moving, initiate turn changes
    if key == "right" and turnstate == "stopped" and move_forward == false and move_backward == false then
        turnstate = "left"
    end
    if key == "left" and turnstate == "stopped" and move_forward == false and move_backward == false then
        turnstate = "right" 
    end

    -- Test textbox queue
    if key == "t" then
        textbox_queue.add("This is a test message.", 100, screen_height * 3/4, screen_width - 200, screen_height / 4, "normal")
    end
    if key == "return" then
       textbox_queue.remove()
    end
end

-- Gets called every dt to update game state
function love.update(dt)
    world:update(dt)
    updateVerts()
    updateMeshes()
    local mx, my = love.mouse.getPosition()
    mouseSensor.body:setPosition(mx, my)
end


-- Draws all visual elements
function love.draw()
    love.graphics.setColor(1, 1, 1, 1) -- NORAMAL

    local vertical_space = 110*scale
    
    plotPolygons()
    textbox_queue.draw()

    -- Draw the test object (highlight if hovered)
    if hoveredObject == test_object.fixture:getUserData() then
        love.graphics.setColor(0, 1, 0, 1) -- Highlighted green
    else
        love.graphics.setColor(1, 0, 0, 1) -- Default red
    end
    love.graphics.polygon("fill", test_object.body:getWorldPoints(test_object.shape:getPoints()))


    love.graphics.setColor(0, 1, 0, 0.5)
    love.graphics.circle("fill", mouseSensor.body:getX(), mouseSensor.body:getY(), mouseSensor.shape:getRadius())
end

function plotPolygons()
    local tpoints, bpoints = {}, {}
    
    for _, v in ipairs(topvert) do
        table.insert(tpoints, v.x)
        table.insert(tpoints, v.y)
    end
    for _, v in ipairs(bottomvert) do
        table.insert(bpoints, v.x)
        table.insert(bpoints, v.y)
    end

    love.graphics.setColor(0.4, 0.8, 0.4, 1.0) 
    love.graphics.polygon("fill", unpack(tpoints))
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("fill", unpack(bpoints))
    
    selectwalls()

    love.graphics.setColor(1, 1, 1, 1) -- NORAMAL
    love.graphics.draw(front_mesh)

    if( turnstate == "left") then
        love.graphics.setColor(1, 1, 1, 1- back_opacity) 
    end
    love.graphics.draw(right_mesh)
    love.graphics.setColor(1, 1, 1, 1) -- NORAMAL


    if( turnstate == "right") then
        love.graphics.setColor(1, 1, 1, 1- back_opacity) 
    end
    love.graphics.draw(left_mesh)
    love.graphics.setColor(1, 1, 1, 1) -- NORAMAL


    love.graphics.draw(bottom_mesh)
    love.graphics.draw(top_mesh)
    love.graphics.setColor(1, 1, 1, back_opacity) 
    love.graphics.draw(back_mesh)
end

function selectwalls()
    local fpoints, bpoints, rpoints, lpoints = {}, {}, {}, {}

    for _, v in ipairs(frontvert) do
        table.insert(fpoints, v.x)
        table.insert(fpoints, v.y)
    end
    for _, v in ipairs(backvert) do
        table.insert(bpoints, v.x)
        table.insert(bpoints, v.y)
    end
    for _, v in ipairs(rightvert) do
        table.insert(rpoints, v.x)
        table.insert(rpoints, v.y)
    end
    for _, v in ipairs(leftvert) do
        table.insert(lpoints, v.x)
        table.insert(lpoints, v.y)
    end

    local wall = {
        {0.4, 0.8, 1.0, 1.0}, --N
        {0.4, 3, 1.0, 1.0}, --E
        {0.8, 0.8, 1.0, 1.0}, --S
        {10, 0.8, 0.4, 1.0} --W
    }

    local frontcolor, rightcolor, leftcolor, backcolor = {}, {}, {}, {}

    local switch = {
        ["N"] = function()  leftcolor, frontcolor, rightcolor, backcolor = wall[1], wall[2], wall[3], wall[4] end,
        ["E"] = function()  leftcolor, frontcolor, rightcolor, backcolor = wall[2], wall[3], wall[4], wall[1] end,
        ["S"] = function()  leftcolor, frontcolor, rightcolor, backcolor = wall[3], wall[4], wall[1], wall[2] end,
        ["W"] = function() leftcolor, frontcolor, rightcolor, backcolor = wall[4], wall[1], wall[2], wall[3] end
    }

    if switch[look_state] then
        switch[look_state]()
    end

    
    love.graphics.setColor(unpack(frontcolor)) 
    love.graphics.polygon("fill", unpack(fpoints))

    love.graphics.setColor(unpack(rightcolor)) 
    love.graphics.polygon("fill", unpack(rpoints))

    love.graphics.setColor(leftcolor)
    love.graphics.polygon("fill", unpack(lpoints))

    love.graphics.setColor(unpack(backcolor))
    love.graphics.polygon("fill", unpack(bpoints))
end

function initEnvironment()
    love.window.setTitle("Bingus Dingus")
    background = love.graphics.newImage("assets/building1716.png")
    testimage= love.graphics.newImage("assets/referenceroom.png")
    love.window.setMode( testimage:getWidth(), testimage:getHeight())
    titleImage = love.graphics.newImage("assets/menu_assets/pixelatedtitle.png")
    screen_width, screen_height = love.graphics.getDimensions()
    center_x, center_y = screen_width / 2, screen_height / 2
end