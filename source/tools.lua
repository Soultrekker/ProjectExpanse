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