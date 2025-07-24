-- Commands implementation for cheetah plugin
local utils = require('cheetah.utils')
local M = {}

-- Example command implementation
function M.hello_command()
  print("Just using print")
  utils.print_message("Hello cheetah!") -- same as info level
  -- utils.print_message("warning from cheetah plugin command!", "warn")
  -- utils.print_message("error from cheetah plugin command!", "error")
  -- utils.print_message("info from cheetah plugin command!", "info")
  get_keymaps()

  
end

function get_keymaps()
  local keymaps = vim.api.nvim_get_keymap("a") -- Get keymaps for all modes

  for _, map in ipairs(keymaps) do
    -- Remove lhsraw and lhsrawalt fields if present
    map.lhsraw = nil
    map.lhsrawalt = nil
    
    if map.callback and type(map.callback) == "function" then
      local info = debug.getinfo(map.callback, "S")
      if info then
        map.decoded_callback = string.format("%s:%s", 
          info.source or info.short_src or "unknown source", 
          info.linedefined or "unknown"
        )
      else
        map.decoded_callback = string.format("%s", tostring(value))
      end
    end
  end
  
  -- Save keymaps to CSV
  save_keymaps_to_csv(keymaps, "/mnt/c/_a/insta/keymaps.csv")
  
  for _, map in ipairs(keymaps) do
    print("Keymap:")
    for key, value in pairs(map) do
      -- Skip printing lhsraw and lhsrawalt
      if key == "lhsraw" or key == "lhsrawalt" then
        -- Skip these fields
      else
        -- print(string.format("  %s: %s", key, tostring(value)))
      end
    end
    print("-------------------")
  end

-- Add more commands as needed
end

-- Function to escape CSV values
local function escape_csv_value(value)
  if value == nil then
    return "NONE"
  end
  
  value = tostring(value)
  -- Check if value starts with = (formula protection) or contains quotes, commas, or newlines
  if value:match('^=') or value:match('[",%c]') then
    -- Replace double quotes with double double quotes and wrap in quotes
    value = '"' .. value:gsub('"', '""') .. '"'
  end
  
  return value
end

-- Function to save keymaps to CSV file
function save_keymaps_to_csv(keymaps, filepath)
  -- Collect all possible field names
  local all_fields = {}
  for _, map in ipairs(keymaps) do
    for field, _ in pairs(map) do
      if not vim.tbl_contains(all_fields, field) then
        table.insert(all_fields, field)
      end
    end
  end
  
  -- Sort fields for consistent output
  table.sort(all_fields)
  
  -- Create CSV content
  local csv_lines = {}
  
  -- Add header
  table.insert(csv_lines, table.concat(all_fields, ","))
  
  -- Add data rows
  for _, map in ipairs(keymaps) do
    local row = {}
    for _, field in ipairs(all_fields) do
      table.insert(row, escape_csv_value(map[field]))
    end
    table.insert(csv_lines, table.concat(row, ","))
  end
  
  -- Write to file
  local file = io.open(filepath, "w")
  if file then
    file:write(table.concat(csv_lines, "\n"))
    file:close()
    print("Keymaps saved to " .. filepath)
  else
    print("Failed to open file for writing: " .. filepath)
  end
end

-- Return the module
return M
