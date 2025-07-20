function multiply_table(tbl, factor)
  local result = {}
  for k, v in pairs(tbl) do
    if type(v) == "number" then
      result[k] = v * factor
    else
      result[k] = v
    end
  end
  return result
end

--a horizontal radius and b vertical radius
function rotate_about(originx, originy, isbot, angle)
  local a_max = screen_width *.72  -- widest at top
  local a_min = screen_width * 0.3  -- narrowest at bottom
  local b = screen_height * 0.125 -- vertical radius for inner

  local vertical_factor = isbot*math.sin(angle)  -- top=1, bottom=-1
  local a = a_min + (a_max - a_min) * (vertical_factor + 1) / 2

  local s = math.sin(angle)
  local c = math.cos(angle)

    return {
        x = originx + a*c,
        y = originy + b*s}
end