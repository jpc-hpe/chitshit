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
  -- utils.print_message("Hello cheetah!") -- same as info level
  -- utils.print_message("warning from cheetah plugin command!", "warn")
  -- utils.print_message("error from cheetah plugin command!", "error")
  -- utils.print_message("info from cheetah plugin command!", "info")
  -- print("Just using print")
  M.get_keymaps()
end

function M.get_keymaps()
  local leader = vim.api.nvim_get_var("mapleader")
  local escaped_leader = leader:gsub("([^%w])", "%%%1")



  local keymaps = vim.api.nvim_get_keymap("a") -- Get keymaps for all modes

  for _, map in ipairs(keymaps) do
    -- To remove irrelevant fields, code would be:
    -- map.lhsraw = nil
    map.display_lhs = map.lhs:gsub(escaped_leader, "<Leader>")
    if map.rhs and type(map.rhs) == "string" then
      map.display_rhs = map.rhs:gsub(escaped_leader, "<Leader>")
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
        map.decoded_callback = tostring(map.callback)
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

  -- create reduced keymap list containing only modes, display_lhs and best_descr
  local reduced_keymaps = {}
  for _, map in ipairs(keymaps) do
    local reduced_map = {
      modes = map.modes,
      display_lhs = map.display_lhs,
      best_descr = map.best_descr
    }
    table.insert(reduced_keymaps, reduced_map)
  end
  -- Consolidate entries with same display_lhs and best_descr
  local consolidated_keymaps = {}
  local seen_combinations = {}

  for _, map in ipairs(reduced_keymaps) do
    local key = (map.display_lhs or "") .. "|" .. (map.best_descr or "")

    if seen_combinations[key] then
      -- Combine modes with existing entry
      local existing_entry = seen_combinations[key]
      if map.modes and map.modes ~= "" then
        if existing_entry.modes and existing_entry.modes ~= "" then
          existing_entry.modes = existing_entry.modes .. map.modes
        else
          existing_entry.modes = map.modes
        end
      end
    else
      -- Create new entry
      local new_entry = {
        modes = map.modes,
        display_lhs = map.display_lhs,
        best_descr = map.best_descr
      }
      seen_combinations[key] = new_entry
      table.insert(consolidated_keymaps, new_entry)
    end
  end

  -- Sort consolidated keymaps by display_lhs, then modes
  table.sort(consolidated_keymaps, function(a, b)
    return (a.display_lhs or "") < (b.display_lhs or "") or
        ((a.display_lhs or "") == (b.display_lhs or "") and (a.modes or "") < (b.modes or ""))
  end)



  -- Uncomment to Save keymaps to CSV
  -- M.save_keymaps_to_csv(consolidated_keymaps)
  M.dump_to_buffer(consolidated_keymaps)


  -- Add more commands as needed
end

function M.dump_to_buffer(keymaps)
  -- Create a new buffer to display the keymaps
  local buf = vim.api.nvim_create_buf(false, true) -- Create new buffer (not listed, scratch)
  vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(buf, 'swapfile', false)
  vim.api.nvim_buf_set_name(buf, 'Keymaps')

  -- Calculate maximum column widths
  local max_modes_width = 5  -- Minimum width for "Modes" header
  local max_keymap_width = 6 -- Minimum width for "Keymap" header

  for _, map in ipairs(keymaps) do
    local mode_str = map.modes or ""
    local lhs_str = map.display_lhs or ""

    max_modes_width = math.max(max_modes_width, #mode_str)
    max_keymap_width = math.max(max_keymap_width, #lhs_str)
  end

  -- Add some padding
  max_modes_width = max_modes_width + 1
  max_keymap_width = max_keymap_width + 1

  -- Prepare content for the buffer
  local lines = { "Keymaps:", "" }

  -- Create header with proper alignment
  local header = string.format("%-" .. max_modes_width .. "s | %-" .. max_keymap_width .. "s | %s",
    "Modes", "Keymap", "Description")
  table.insert(lines, header)

  -- Create separator line with proper alignment
  local separator = string.rep("-", max_modes_width) .. "-+-" ..
      string.rep("-", max_keymap_width) .. "-+-" ..
      string.rep("-", 30)               -- Reasonable width for description
  table.insert(lines, separator)

  -- Add data rows with proper alignment
  for _, map in ipairs(keymaps) do
    local mode_str = map.modes or ""
    local lhs_str = map.display_lhs or ""
    local desc_str = map.best_descr or ""

    local formatted_line = string.format("%-" .. max_modes_width .. "s | %-" .. max_keymap_width .. "s | %s",
      mode_str, lhs_str, desc_str)
    table.insert(lines, formatted_line)
  end

  -- Set the buffer content
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  -- Open the buffer in a new window
  vim.api.nvim_command('vsplit')
  vim.api.nvim_win_set_buf(0, buf)

  -- Set buffer as readonly
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(buf, 'readonly', true)
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

  -- Replace semicolons with <semicolon> - required by Excel to prevent CSV parsing issues
  value = value:gsub(";", "<semicolon>")

  return value
end

-- Function to save keymaps to CSV file
function M.save_keymaps_to_csv(keymaps)
  -- Generate temporary filename for CSV export similar to Unix mktemp
  local temp_dir = os.getenv("TMPDIR") or os.getenv("TMP") or os.getenv("TEMP") or "/tmp"
  local timestamp = os.date("%Y%m%d_%H%M%S")
  local random_suffix = tostring(math.random(100000, 999999))
  local filepath = temp_dir .. "/keymaps_" .. timestamp .. "_" .. random_suffix .. ".csv"

  -- Collect all possible field names (keeping this for future use)
  local all_fields = {}
  for _, map in ipairs(keymaps) do
    for field, _ in pairs(map) do
      if not vim.tbl_contains(all_fields, field) then
        table.insert(all_fields, field)
      end
    end
  end

  -- Custom sorting: prioritize specific fields, then sort the rest alphabetically
  local prioritized_fields = { "modes", "display_lhs", "best_descr" }
  local remaining_fields = {}
  for _, field in ipairs(all_fields) do
    if not vim.tbl_contains(prioritized_fields, field) then
      table.insert(remaining_fields, field)
    end
  end
  table.sort(remaining_fields)
  all_fields = vim.list_extend(prioritized_fields, remaining_fields)

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
    utils.print_message("Keymaps saved to " .. filepath)
  else
    utils.print_message("Failed to open file for writing: " .. filepath, "error")
  end
end

-- Return the module
return M
