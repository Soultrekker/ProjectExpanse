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
turn_speed = .002
move_forward = false
gamestate = "menu"

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

base_scale = 1
scale = base_scale


function love.update(dt)

    if turnstate ~= "stopped" then --NOT EQUAL STOPPED
        local right_edge = frontvert[2].x
        local left_edge = frontvert[1].x

        local direction = (turnstate == "right") and 1 or -1

        center_x = center_x + turn_speed*screen_width*direction
        Lratio = Lratio + turn_speed*direction*(-1)
        Rratio = Rratio + turn_speed*direction

        -- Voffsets per side
        if not turn_mirrored then
            if turnstate == "right" then
                Voffset_R = Voffset_R + turn_speed * 2.1
            else
                Voffset_L = Voffset_L + turn_speed * 2.1
            end
        else
            if turnstate == "right" then
                Voffset_L = Voffset_L - turn_speed * 2.1
            else
                Voffset_R = Voffset_R - turn_speed * 2.1
            end
        end

        -- Mirror at halfway point (simulate room face swap)
        if not turn_mirrored and (frontvert[1].x <= - screen_width/10 or frontvert[2].x >= screen_width *1.1)  then
            center_x = math.abs(screen_width - center_x)
            local temp = Lratio
            Lratio = Rratio
            Rratio = temp
            if turnstate == "right" then
                Voffset_L = Voffset_R
                Voffset_R = 1
            else
                Voffset_R = Voffset_L
                Voffset_L = 1
            end

            changeLookState(turnstate == "right" and "left" or "right") -- Change look state after turn completes
            turn_mirrored = true
        end

        if turn_mirrored and (center_x  > screen_width / 2 - scale and center_x < screen_width / 2 + scale) then
            center_x = screen_width / 2
            Lratio = 1
            Rratio = 1
            Voffset_L = 1
            Voffset_R = 1
            turn_mirrored = false
            turnstate = "stopped"
        end

    elseif turnstate == "stopped" then
        if move_forward then
            scale = scale + 3 * dt
            if scale > 2 * base_scale then
                scale = base_scale
                move_forward = false
            end
        end
    end



     local topleft =   {x = center_x - screen_width*.3052* Lratio* scale, y = center_y - screen_height*.29 * Lratio* scale *Voffset_L}  -- top-left
     local bottomleft = {x = center_x - screen_width*.3052* Lratio* scale, y = center_y + screen_height*.232* Lratio* scale*Voffset_L}  -- bottom-left


     local topright = {x = center_x + screen_width*.3052* Rratio* scale, y = center_y - screen_height*.29 * Rratio* scale* Voffset_R}  -- top-right
     local bottomright = {x = center_x + screen_width*.3052* Rratio* scale, y = center_y + screen_height*.232* Rratio* scale *Voffset_R}  -- bottom-right
    

     local outertopleft = {x = 0, y = 0}
     local outertopright = {x = screen_width, y = 0}
     local outerbottomright = {x = screen_width, y = screen_height}
     local outerbottomleft = {x = 0, y = screen_height}

    frontvert = {
        topleft,
        topright,  -- top-right
        bottomright,  -- bottom-right
        bottomleft,  -- bottom-left
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
    bottomvert = {
        bottomleft,  -- top-left
        bottomright,  -- top-right
        outerbottomright,  -- bottom-right of screen
        outerbottomleft,  -- bottom-left
    }
    topvert = {
        outertopleft,  -- top-left
        outertopright,  -- top-right of screen
        topright,  -- bottom-right same as top-right of frontvert
        topleft,  -- bottom-left same as top-left of frontvert
    }

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
    love.graphics.draw(right_mesh)
    love.graphics.draw(left_mesh)
    love.graphics.draw(bottom_mesh)
    love.graphics.draw(top_mesh)
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
    local fpoints, rpoints, lpoints = {}, {}, {}

    for _, v in ipairs(frontvert) do
        table.insert(fpoints, v.x)
        table.insert(fpoints, v.y)
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

    local frontcolor, rightcolor, leftcolor = {}, {}, {}, {}

    local switch = {
        ["N"] = function()  leftcolor, frontcolor, rightcolor = wall[1], wall[2], wall[3] end,
        ["E"] = function()  leftcolor, frontcolor, rightcolor = wall[2], wall[3], wall[4] end,
        ["S"] = function()  leftcolor, frontcolor, rightcolor = wall[3], wall[4], wall[1] end,
        ["W"] = function() leftcolor, frontcolor, rightcolor = wall[4], wall[1], wall[2] end
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

        bottom_mesh:setVertex(1, bottomvert[1].x, bottomvert[1].y, 0,0)    
        bottom_mesh:setVertex(2, bottomvert[2].x, bottomvert[2].y, 1,0)
        bottom_mesh:setVertex(3, bottomvert[3].x, bottomvert[3].y, 1,1)
        bottom_mesh:setVertex(4, bottomvert[4].x, bottomvert[4].y, 0,1)
    
        top_mesh:setVertex(1, topvert[1].x, topvert[1].y, 0,0)
        top_mesh:setVertex(2, topvert[2].x, topvert[2].y, 1,0)
        top_mesh:setVertex(3, topvert[3].x, topvert[3].y, 1,1)
        top_mesh:setVertex(4, topvert[4].x, topvert[4].y, 0,1)

    elseif look_state == "E" then

        left_mesh:setTexture(wall1_image)
        front_mesh:setTexture(wall2_image)
        right_mesh:setTexture(wall3_image)

        bottom_mesh:setVertex(1, bottomvert[1].x, bottomvert[1].y, 1,0)    
        bottom_mesh:setVertex(2, bottomvert[2].x, bottomvert[2].y, 1,1)
        bottom_mesh:setVertex(3, bottomvert[3].x, bottomvert[3].y, 0,1)
        bottom_mesh:setVertex(4, bottomvert[4].x, bottomvert[4].y, 0,0)

        top_mesh:setVertex(1, topvert[1].x, topvert[1].y, 0,1)
        top_mesh:setVertex(2, topvert[2].x, topvert[2].y, 0,0)
        top_mesh:setVertex(3, topvert[3].x, topvert[3].y, 1,0)
        top_mesh:setVertex(4, topvert[4].x, topvert[4].y, 1,1)
    


   
    elseif look_state == "S" then
        left_mesh:setTexture(wall2_image)
        front_mesh:setTexture(wall3_image)
        right_mesh:setTexture(wall4_image)

        bottom_mesh:setVertex(1, bottomvert[1].x, bottomvert[1].y, 1,1)    
        bottom_mesh:setVertex(2, bottomvert[2].x, bottomvert[2].y, 0,1)
        bottom_mesh:setVertex(3, bottomvert[3].x, bottomvert[3].y, 0,0)
        bottom_mesh:setVertex(4, bottomvert[4].x, bottomvert[4].y, 1,0)
    
        top_mesh:setVertex(1, topvert[1].x, topvert[1].y, 1,1)
        top_mesh:setVertex(2, topvert[2].x, topvert[2].y, 0,1)
        top_mesh:setVertex(3, topvert[3].x, topvert[3].y, 0,0)
        top_mesh:setVertex(4, topvert[4].x, topvert[4].y, 1,0)


    elseif look_state == "W" then
        left_mesh:setTexture(wall3_image)
        front_mesh:setTexture(wall4_image)
        right_mesh:setTexture(wall1_image)

        bottom_mesh:setVertex(1, bottomvert[1].x, bottomvert[1].y, 0,1)    
        bottom_mesh:setVertex(2, bottomvert[2].x, bottomvert[2].y, 0,0)
        bottom_mesh:setVertex(3, bottomvert[3].x, bottomvert[3].y, 1,0)
        bottom_mesh:setVertex(4, bottomvert[4].x, bottomvert[4].y, 1,1)
    
        top_mesh:setVertex(1, topvert[1].x, topvert[1].y, 1,0)
        top_mesh:setVertex(2, topvert[2].x, topvert[2].y, 1,1)
        top_mesh:setVertex(3, topvert[3].x, topvert[3].y, 0,1)
        top_mesh:setVertex(4, topvert[4].x, topvert[4].y, 0,0)

    end


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


end