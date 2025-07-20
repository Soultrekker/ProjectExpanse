require "source/tools"
function love.load()
    love.window.setTitle("Bingus Dingus")
    background = love.graphics.newImage("assets/building1716.png")
    testimage= love.graphics.newImage("assets/referenceroom.png")
    love.window.setMode( testimage:getWidth(), testimage:getHeight())
    titleImage = love.graphics.newImage("assets/menu_assets/pixelatedtitle.png")
    screen_width, screen_height = love.graphics.getDimensions()
    center_x, center_y = screen_width / 2, screen_height / 2
    frontvert = {
        {x = 0, y = 0},                       -- top-left
        {x = screen_width, y = 0},            -- top-right
        {x = screen_width, y = screen_height},-- bottom-right
        {x = 0, y = screen_height}            -- bottom-left
    }

    backvert = {
        {x = 0, y = 0},                       -- top-left
        {x = screen_width, y = 0},            -- top-right
        {x = screen_width, y = screen_height},-- bottom-right
        {x = 0, y = screen_height}            -- bottom-left
    }

    rightvert = {
        {x = 0, y = 0},                       -- top-left
        {x = screen_width, y = 0},            -- top-right
        {x = screen_width, y = screen_height},-- bottom-right
        {x = 0, y = screen_height}            -- bottom-left
    }
    leftvert = {
        {x = 0, y = 0},                       -- top-left
        {x = screen_width, y = 0},            -- top-right
        {x = screen_width, y = screen_height},-- bottom-right
        {x = 0, y = screen_height}            -- bottom-left
    }
    bottomvert = {
        {x = 0, y = 0},                       -- top-left
        {x = screen_width, y = 0},            -- top-right
        {x = screen_width, y = screen_height},-- bottom-right
        {x = 0, y = screen_height}            -- bottom-left
    }
    topvert = {
        {x = 0, y = 0},                       -- top-left
        {x = screen_width, y = 0},            -- top-right
        {x = screen_width, y = screen_height},-- bottom-right
        {x = 0, y = screen_height}            -- bottom-left
    }
    
    Rratio = 1
    Lratio = 1
    lower_limit = 0.3
    Voffset_L = 1
    Voffset_R = 1

    wall1_image = love.graphics.newImage("assets/wall1.png")
    wall2_image = love.graphics.newImage("assets/wall2.png")
    wall3_image = love.graphics.newImage("assets/wall3.png")
    wall4_image = love.graphics.newImage("assets/wall4.png")
    floor_image = love.graphics.newImage("assets/floor.png")
    ceiling_image = love.graphics.newImage("assets/ceiling.png")

    -- Create a mesh with 4 points and texture coords (from top-left to bottom-right)
    front_mesh = love.graphics.newMesh({
        {0, 0, 0, 0},  -- top-left
        {1, 0, 1, 0},  -- top-right
        {1, 1, 1, 1},  -- bottom-right
        {0, 1, 0, 1}   -- bottom-left
    }, "fan")

    front_mesh:setTexture(wall1_image)

    back_mesh = love.graphics.newMesh({
        {0, 0, 0, 0},  -- top-left
        {1, 0, 1, 0},  -- top-right
        {1, 1, 1, 1},  -- bottom-right
        {0, 1, 0, 1}   -- bottom-left
    }, "fan")
    back_mesh:setTexture(wall3_image)

    right_mesh = love.graphics.newMesh({
        {0, 0, 0, 0},  -- top-left
        {1, 0, 1, 0},  -- top-right
        {1, 1, 1, 1},  -- bottom-right
        {0, 1, 0, 1}   -- bottom-left
    }, "fan")
    right_mesh:setTexture(wall2_image)


    left_mesh = love.graphics.newMesh({
        {0, 0, 0, 0},  -- top-left
        {1, 0, 1, 0},  -- top-right
        {1, 1, 1, 1},  -- bottom-right
        {0, 1, 0, 1}   -- bottom-left
    }, "fan")
    left_mesh:setTexture(wall4_image)

    bottom_mesh = love.graphics.newMesh({
        {0, 0, 0, 0},  -- top-left
        {1, 0, 1, 0},  -- top-right
        {1, 1, 1, 1},  -- bottom-right
        {0, 1, 0, 1}   -- bottom-left
    }, "fan")
    bottom_mesh:setTexture(floor_image)

    top_mesh = love.graphics.newMesh({
        {0, 0, 0, 0},  -- top-left
        {1, 0, 1, 0},  -- top-right
        {1, 1, 1, 1},  -- bottom-right
        {0, 1, 0, 1}   -- bottom-left
    }, "fan")
    top_mesh:setTexture(ceiling_image)

end

turnstate = "stopped"
turn_progress = 0
look_state = "N" -- can be 1 North, 2 East, 3 South, 4 West
turn_duration = 1.0  -- how long the turn lasts (seconds)
turn_speed = .005
move_forward = false
gamestate = "menu"
base_scale = 1
scale = base_scale
back_opacity = 0

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
    if key == "return" then
        if state == "menu" then
            state = "game"
        else
            state = "menu"
        end
    end

    if key == "up" then
        move_forward = true
    end

    if key == "right" and turnstate == "stopped" and move_forward == false then
        turnstate = "left"
    end
    if key == "left" and turnstate == "stopped" and move_forward == false then
        turnstate = "right" 
    end
end



function love.update(dt)
    local angle = 0;
    local direction = (turnstate == "right") and 1 or -1 
    local top_center_of_spin = {x = center_x, y = center_y - screen_height *.42}
    local bottom_center_of_spin = {x = center_x, y = center_y + screen_height *.42}

    if turnstate ~= "stopped" then --NOT EQUAL STOPPED
        turn_progress = turn_progress + turn_speed
        back_opacity = turn_progress


        if turn_progress >= 1 then
            turn_progress = 0
            back_opacity = 0
            turnstate = "stopped"
            changeLookState((direction == 1) and "right" or "left")
        end

        local offset = math.sin(turn_progress * math.pi / 2) * 100

        angle = angle + direction * turn_progress * math.pi/2 

    elseif turnstate == "stopped" then
        if move_forward then
            scale = scale + 3 * dt
            if scale > 2 * base_scale then
                scale = base_scale
                move_forward = false
            end
        end
    end

    local istop = -1
    local isbot = 1
    
    local topleft = rotate_about(top_center_of_spin.x, top_center_of_spin.y, istop, .75*math.pi + angle)
    local topright = rotate_about(top_center_of_spin.x, top_center_of_spin.y, istop, .25*math.pi + angle)
    local outertopleft = rotate_about(top_center_of_spin.x, top_center_of_spin.y, istop,  1.25*math.pi + angle)
    local outertopright = rotate_about(top_center_of_spin.x, top_center_of_spin.y, istop, 1.75* math.pi + angle)
    local bottomleft = rotate_about(bottom_center_of_spin.x, bottom_center_of_spin.y, isbot, 1.25*math.pi - angle)
    local bottomright = rotate_about(bottom_center_of_spin.x, bottom_center_of_spin.y, isbot, 1.75*math.pi - angle)
    local outerbottomleft = rotate_about(bottom_center_of_spin.x, bottom_center_of_spin.y, isbot, .75*math.pi - angle)
    local outerbottomright = rotate_about(bottom_center_of_spin.x, bottom_center_of_spin.y, isbot, .25*math.pi - angle)


    frontvert = {
        topleft,
        topright,  -- top-right
        bottomright,  -- bottom-right
        bottomleft,  -- bottom-left
    }

    backvert = {
        outertopleft,  -- top-left
        outertopright,  -- top-right of screen
        outerbottomright,  -- bottom-right of screen
        outerbottomleft,  -- bottom-left
    }

    rightvert = {
        topright,  -- top-left saame as top-right of frontvert
        outertopright,  -- top-right of screen
        outerbottomright,  -- bottom-right of screen
        bottomright,  -- bottom-left same as bottom-right of frontvert
    }
    leftvert = {
        outertopleft,  -- top-left
        topleft,  -- top-right same as top-left of frontvert
        bottomleft,  -- bottom-right same as bottom-left of frontvert
        outerbottomleft,  -- bottom-left
    }


    local bottomlookScene = { 
        ["N"] = {bottomleft, bottomright, outerbottomright, outerbottomleft},
        ["E"] = {outerbottomleft, bottomleft, bottomright, outerbottomright},
        ["S"] = {outerbottomright, outerbottomleft, bottomleft, bottomright},
        ["W"] = {bottomright, outerbottomright, outerbottomleft, bottomleft}
    }

    local toplookScene = { 
        ["N"] = {outertopleft, outertopright, topright, topleft},
        ["E"] = {outertopright, topright, topleft, outertopleft},
        ["S"] = {topright, topleft, outertopleft, outertopright},
        ["W"] = {topleft, outertopleft, outertopright, topright}
    }

    bottomvert = bottomlookScene[look_state]
    topvert = toplookScene[look_state]

    updateTextureDirection()

end



function love.draw()
    love.graphics.setColor(1, 1, 1, 1) -- NORAMAL

    local vertical_space = 110*scale

    for i = 0, love.graphics.getWidth() / screen_width do
        for j = 0, love.graphics.getHeight() / screen_height do
            love.graphics.draw(testimage, i * screen_width, j * screen_height)
        end
    end
    
    plotPolygons()
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

function changeLookState(direction)
    if direction == "right"  then
        if look_state == "N" then
            look_state = "E"
        elseif look_state == "E" then
            look_state = "S"
        elseif look_state == "S" then
            look_state = "W"
        elseif look_state == "W" then
            look_state = "N"
        end

    elseif direction == "left" then
        if look_state == "N" then
            look_state = "W"
        elseif look_state == "W" then
            look_state = "S"
        elseif look_state == "S" then
            look_state = "E"
        elseif look_state == "E" then
            look_state = "N"
        end
    end
end

function updateTextureDirection()


    if look_state == "N" then
        left_mesh:setTexture(wall4_image)
        front_mesh:setTexture(wall1_image)
        right_mesh:setTexture(wall2_image)
        back_mesh:setTexture(wall3_image)


    elseif look_state == "E" then

        left_mesh:setTexture(wall1_image)
        front_mesh:setTexture(wall2_image)
        right_mesh:setTexture(wall3_image)
        back_mesh:setTexture(wall4_image)
   
    elseif look_state == "S" then
        left_mesh:setTexture(wall2_image)
        front_mesh:setTexture(wall3_image)
        right_mesh:setTexture(wall4_image)
        back_mesh:setTexture(wall1_image)



    elseif look_state == "W" then
        left_mesh:setTexture(wall3_image)
        front_mesh:setTexture(wall4_image)
        right_mesh:setTexture(wall1_image)
        back_mesh:setTexture(wall2_image)

    end

    bottom_mesh:setVertex(1, bottomvert[1].x, bottomvert[1].y, 0,0)    
    bottom_mesh:setVertex(2, bottomvert[2].x, bottomvert[2].y, 1,0)
    bottom_mesh:setVertex(3, bottomvert[3].x, bottomvert[3].y, 1,1)
    bottom_mesh:setVertex(4, bottomvert[4].x, bottomvert[4].y, 0,1)

    top_mesh:setVertex(1, topvert[1].x, topvert[1].y, 0,0)
    top_mesh:setVertex(2, topvert[2].x, topvert[2].y, 1,0)
    top_mesh:setVertex(3, topvert[3].x, topvert[3].y, 1,1)
    top_mesh:setVertex(4, topvert[4].x, topvert[4].y, 0,1)

    front_mesh:setVertex(1, frontvert[1].x, frontvert[1].y, 0, 0)
    front_mesh:setVertex(2, frontvert[2].x, frontvert[2].y, 1, 0)
    front_mesh:setVertex(3, frontvert[3].x, frontvert[3].y, 1, 1)
    front_mesh:setVertex(4, frontvert[4].x, frontvert[4].y, 0, 1)

    right_mesh:setVertex(1, rightvert[1].x, rightvert[1].y, 0, 0)
    right_mesh:setVertex(2, rightvert[2].x, rightvert[2].y, 1, 0)
    right_mesh:setVertex(3, rightvert[3].x, rightvert[3].y, 1, 1)
    right_mesh:setVertex(4, rightvert[4].x, rightvert[4].y, 0, 1)

    left_mesh:setVertex(1, leftvert[1].x, leftvert[1].y, 0, 0)
    left_mesh:setVertex(2, leftvert[2].x, leftvert[2].y, 1, 0)
    left_mesh:setVertex(3, leftvert[3].x, leftvert[3].y, 1, 1)
    left_mesh:setVertex(4, leftvert[4].x, leftvert[4].y, 0, 1)

    back_mesh:setVertex(1, backvert[1].x, backvert[1].y, 1, 0)
    back_mesh:setVertex(2, backvert[2].x, backvert[2].y, 0,0)
    back_mesh:setVertex(3, backvert[3].x, backvert[3].y, 0,1)
    back_mesh:setVertex(4, backvert[4].x, backvert[4].y, 1, 1)
end

function move_forward()
end