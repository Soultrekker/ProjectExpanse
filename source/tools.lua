function multiply_table(tbl, factor) -- dont think I used this, but might be useful for table manipulations in further development
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

