
clickableobjects = {}
mouseSensor = {}
test_object = {}
hoveredObject = nil --only want one object to hover at a time

function initMouseClickBox()
    world = love.physics.newWorld(0, 0, false)
     -- Set up collision callbacks
    world:setCallbacks(beginContact, endContact)
    test_object.body = love.physics.newBody(world, 700, 700, "static")
    test_object.shape = love.physics.newRectangleShape(50, 50) -- Example rectangle 
    test_object.fixture = love.physics.newFixture(test_object.body, test_object.shape)
    --test_object.fixture:setSensor(true) -- Not a sensor, just a regular object
    test_object.fixture:setUserData("box") -- Store the object in the fixture's user data

    mouseSensor.body = love.physics.newBody(world, 0, 0, "dynamic")
    mouseSensor.shape = love.physics.newCircleShape(5) -- small radius
    mouseSensor.fixture = love.physics.newFixture(mouseSensor.body, mouseSensor.shape)
    --mouseSensor.fixture:setSensor(true)
    mouseSensor.fixture:setUserData("mouse")

end

function beginContact(a, b, coll) 
    local ua, ub = a:getUserData(), b:getUserData()
    print("Contact detected!",ua,ub,coll)
    
    if ua == "mouse" and ub == "box" then -- if the object is a table then it is a clickable object
        textbox_queue.add("COLLIDE", 100, screen_height * 3/4, screen_width - 200, screen_height / 4, "normal")
        hoveredObject = ub
    elseif ub == "mouse" and ua == "box" then
        textbox_queue.add("COLLIDE", 100, screen_height * 3/4, screen_width - 200, screen_height / 4, "normal")
        hoveredObject = ua
    end
end

function endContact(a, b, coll)
    local ua, ub = a:getUserData(), b:getUserData()
    print("Contact un detected!",ua,ub,coll)
    hoveredObject = nil -- Reset hovered object when contact ends

end