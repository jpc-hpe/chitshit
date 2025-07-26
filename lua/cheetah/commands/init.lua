-- Commands implementation for cheetah plugin
local utils = require('cheetah.utils')
local M = {}

-- Function to convert mode_bits to a string representation
function M.decode_mode_bits(mode_bits)
  if not mode_bits or type(mode_bits) ~= "number" then
    return ""
  end
  
  local modes = ""
  local mode_map = {
    [0x01] = "n", -- Normal
    [0x02] = "x", -- Visual
    [0x04] = "o", -- Operator-pending
    [0x08] = "c", -- Command-line
    [0x10] = "i", -- Insert
    [0x20] = "l", -- Language
    [0x40] = "s", -- Select
    [0x80] = "t"  -- Terminal
  }
  
  -- Use Neovim's bit library for Lua 5.1 compatibility
  local bit = require("bit")
  
  for bit_value, char in pairs(mode_map) do
    -- Bitwise AND operation using Lua 5.1 bit library
    if bit.band(mode_bits, bit_value) ~= 0 then
      modes = modes .. char
    end
  end
  
  return modes
end

-- Example command implementation
function M.hello_command()
  utils.print_message("Hello cheetah!") -- same as info level
  -- utils.print_message("warning from cheetah plugin command!", "warn")
  -- utils.print_message("error from cheetah plugin command!", "error")
  -- utils.print_message("info from cheetah plugin command!", "info")
  --print("Just using print")
  M.get_keymaps()

  
end

function M.get_keymaps()
  local leader = vim.api.nvim_get_var("mapleader")
  local escaped_leader = leader:gsub("([^%w])", "%%%1")


  
  local keymaps = vim.api.nvim_get_keymap("a") -- Get keymaps for all modes

  for _, map in ipairs(keymaps) do
    -- To remove irrelevant fields, code would be:
    -- map.lhsraw = nil
    map.display_lhs=map.lhs:gsub(escaped_leader, "<Leader>")
    if map.rhs and type(map.rhs) == "string" then
      map.display_rhs=map.rhs:gsub(escaped_leader, "<Leader>")
    else
      map.display_rhs = map.rhs
    end
    -- Add modes field based on mode_bits
    if map.mode_bits then
      map.modes = M.decode_mode_bits(map.mode_bits)
    else
      map.modes = map.mode
    end
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
    
    -- Create best_descr field with cascading logic
    if map.desc and map.desc ~= "" then
      map.best_descr = map.desc
    elseif map.display_rhs and map.display_rhs ~= "" then
      map.best_descr = map.display_rhs
    elseif map.decoded_callback and map.decoded_callback ~= "" then
      map.best_descr = map.decoded_callback
    end
  end
  -- Save keymaps to CSV
  M.save_keymaps_to_csv(keymaps, "/mnt/c/_a/insta/keymaps.csv")
  
  for _, map in ipairs(keymaps) do
    --print("Keymap:")
    for key, value in pairs(map) do
      -- Skip printing lhsraw and lhsrawalt
      if key == "lhsraw" or key == "lhsrawalt" then
        -- Skip these fields
      else
        -- print(string.format("  %s: %s", key, tostring(value)))
      end
    end
    --print("-------------------")
  end

-- Add more commands as needed
end

-- Function to escape CSV values
function M.escape_csv_value(value)
  if value == nil then
    return "NONE"
  end
  
  value = tostring(value)
  -- Check if value starts with = or + (formula protection)
  if value:match('^[=+]') then
    -- Prefix with single quote to prevent formula execution
    value = "'" .. value
  end
  -- Check if value contains quotes, commas, semicolons, or newlines
  if value:match('[",%c;]') then
    -- Replace double quotes with double double quotes and wrap in quotes
    value = '"' .. value:gsub('"', '""') .. '"'
  end
  
  return value
end

-- Function to save keymaps to CSV file
function M.save_keymaps_to_csv(keymaps, filepath)
  -- Collect all possible field names (keeping this for future use)
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
  
  -- Override with only the allowed fields for now
  all_fields = {"modes", "display_lhs", "best_descr", "display_rhs", "desc", "decoded_callback"}
  
  -- Create CSV content
  local csv_lines = {}
  
  -- Add header
  table.insert(csv_lines, table.concat(all_fields, ","))
  
  -- Add data rows
  for _, map in ipairs(keymaps) do
    local row = {}
    for _, field in ipairs(all_fields) do
      table.insert(row, M.escape_csv_value(map[field]))
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
