-- room.lua

-- Vertexes are groups of four points that make up the corners of each wall/floor/ceiling
-- Instead of creating four vertexes for each wall or element, I actually create 8 points and reuse them,
-- I only initialize like this to make it a less abstracted initialization (better to see everything laid out)
function initVerts()
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
end

-- Meshes are love objects for drawing textured polygons
-- Here we initialize our meshes and load textures
-- Meshes will be updated each frame to change vertex positions and textures
function initMeshes()
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

-- gets called in love.update, updates vertex positions based on turn_state and move progress
function updateVerts()
    local angle = 0; --Dont question it its magic \(0-0)/
    local direction = (turnstate == "right") and 1 or -1 
    local top_center_of_spin = {x = center_x, y = center_y - screen_height *.4*move_progress}
    local bottom_center_of_spin = {x = center_x, y = center_y + screen_height *.4*move_progress}

    -- If we are NOT stopped then keep turning
    if turnstate ~= "stopped" then --NOT EQUAL STOPPED LUA LOOKS LIKE THIS I KNOW
        turn_progress = turn_progress + turn_speed
        back_opacity = turn_progress

        if turn_progress >= 1 then -- 1 means we finished a 90 degree turn
            turn_progress = 0
            back_opacity = 0
            turnstate = "stopped"
            changeLookState((direction == 1) and "right" or "left")
        end

        --Ok so its just an angle calc no magic here, converting it to radians bc love2d uses radians
        angle = angle + direction * turn_progress * math.pi/2 

    elseif turnstate == "stopped" then
        local lower_bound = .3
        local upper_bound = 1.8
        local default_move_progress = 1
        local move_reset_threshold = .01

        -- moving forward and backward is very rudimentary right now, doesn't look pretty
        if move_forward then
            move_progress = move_progress + move_speed
            if move_progress >= upper_bound then
                move_progress = lower_bound
                move_forward = false
            end
        elseif move_backward then
            move_progress = move_progress - move_speed
            if move_progress <= lower_bound then
                move_progress = upper_bound
                move_backward = false
            end
        elseif move_progress > default_move_progress - move_reset_threshold 
           and move_progress < default_move_progress + move_reset_threshold then
            move_progress = default_move_progress
        elseif move_progress < default_move_progress then
            move_progress = move_progress + move_speed
        elseif move_progress > default_move_progress then
            move_progress = move_progress - move_speed
        end
    end

    local istop = -1 --negative inverts rotation calc for top, wanted a simple way not to repeat code
    local isbot = 1
    
    -- Ok so I know there are some magic numbers here but they just create an angled offset for each vertex, manually tweaked
    -- to make the inital shape better resemble a room, could probably be done cleaner with more math but idc
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
        topright,
        bottomright, 
        bottomleft,  
    }

    backvert = {
        outertopleft,
        outertopright,  
        outerbottomright,  
        outerbottomleft, 
    }

    rightvert = {
        topright,  
        outertopright,  
        outerbottomright,  
        bottomright,
    }
    leftvert = {
        outertopleft,  
        topleft, 
        bottomleft, 
        outerbottomleft,  
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

end

-- gets called in love.update, changes textures based on look_state
-- as well as updates mesh vertex positions
function updateMeshes()
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

    back_mesh:setVertex(1, backvert[2].x, backvert[2].y, 0, 0)
    back_mesh:setVertex(2, backvert[1].x, backvert[1].y, 1,0)
    back_mesh:setVertex(3, backvert[4].x, backvert[4].y, 1,1)
    back_mesh:setVertex(4, backvert[3].x, backvert[3].y, 0, 1)
end

-- Changes lookstate based on direction (I know it can be done cleaner idc)
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

-- Method calculates top or bottom vertexx position rotating around an ellipse
-- to create illusion of a 3D rotation
--a horizontal radius and b vertical radius
function rotate_about(originx, originy, isbot, angle)
  local a_max = screen_width *.72  -- widest at top
  local a_min = screen_width * 0.3  -- narrowest at bottom
  local b = screen_height * 0.125 -- vertical radius for inner

  local vertical_factor = isbot*math.sin(angle)  -- top=1, bottom=-1
  local a = a_min + (a_max - a_min) * (vertical_factor + 1) / 2

  
  a = a * move_progress
  b = b * move_progress
  
  -- MATH IS MATH
  local s = math.sin(angle)
  local c = math.cos(angle)

    return {
        x = originx + a*c,
        y = originy + b*s}
end

