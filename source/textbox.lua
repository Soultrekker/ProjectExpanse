--- Textbox Queue Object
-- Manages a queue of textboxes to be displayed on the screen
-- In a normal c scenario, you would like to make this object singleton
-- but since load gets called only once, this is sufficient for now

text_que_pos = 1 -- empty queue
textbox_queue = {
    [1] = { text = "default text",
            x_pos = 0,
            y_pos = 0,
            width = 200,
            height = 200,
            mode = "normal", -- "normal" or "error"
            }
}

function textbox_queue.add(text, x_pos, y_pos, width, height, mode)
    text_que_pos = text_que_pos + 1
    textbox_queue[text_que_pos] = {
        text = text,
        x_pos = x_pos or 0,
        y_pos = y_pos or 0,
        width = width or screen_width - 200,
        height = height or screen_height / 4,
        mode = mode or "normal"
    }
end

function textbox_queue.clear()
    text_que_pos = 1
    textbox_queue[1] = { text = "default text",
                         x_pos = 0,
                         y_pos = 0,
                         width = 200,
                         height = 200,
                         mode = "normal" }
end

function textbox_queue.remove()
    if text_que_pos > 1 then
        textbox_queue[text_que_pos] = nil
        text_que_pos = text_que_pos - 1
    end
end

function textbox_queue.draw()
    if(text_que_pos <= 1) then
        return
    else
        local box = textbox_queue[text_que_pos]
        if box.mode == "normal" then
            love.graphics.setColor(0, 0, 0, 0.5) -- Semi-transparent black background
        elseif box.mode == "error" then
            love.graphics.setColor(1, 0, 0, 0.5) -- Semi-transparent red background
        end
            
        love.graphics.rectangle("fill", box.x_pos, box.y_pos, box.width, box.height)
        love.graphics.setColor(1, 1, 1, 1) -- White text color
        love.graphics.printf(box.text, box.x_pos + 10, box.y_pos + 10, box.width - 20)
        end
    end