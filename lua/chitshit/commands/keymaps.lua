-- Commands implementation for chitshit plugin
local utils = require("chitshit.utils")
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
		[0x80] = "t", -- Terminal
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

function M.keymaps_cheatsheet()
	local leader = vim.api.nvim_get_var("mapleader")
	local localleader = vim.api.nvim_get_var("maplocalleader")
	local escaped_leader = leader:gsub("([^%w])", "%%%1")
	local escaped_localleader = localleader:gsub("([^%w])", "%%%1")

	local keymaps = vim.api.nvim_get_keymap("a") -- Get keymaps for all modes

	for _, map in ipairs(keymaps) do
		-- To remove irrelevant fields, code would be:
		-- map.lhsraw = nil
		map.display_lhs = map.lhs:gsub(escaped_leader, "<Leader>")
		map.display_lhs = map.display_lhs:gsub(escaped_localleader, "<LocalLeader>")
		if map.rhs and type(map.rhs) == "string" then
			map.display_rhs = map.rhs:gsub(escaped_leader, "<Leader>")
			map.display_rhs = map.display_rhs:gsub(escaped_localleader, "<LocalLeader>")
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
				map.decoded_callback = string.format(
					"%s:%s",
					info.source or info.short_src or "unknown source",
					info.linedefined or "unknown"
				)
			else
				map.decoded_callback = tostring(map.callback)
			end
		end

		-- Create best_descr by trying descr, rhs and callback in that order
		if map.desc and map.desc ~= "" then
			map.best_descr = map.desc
		elseif map.display_rhs and map.display_rhs ~= "" then
			map.best_descr = map.display_rhs
		elseif map.decoded_callback and map.decoded_callback ~= "" then
			map.best_descr = map.decoded_callback
		end
	end

	-- create reduced keymap list containing only modes, display_lhs and best_descr
	-- exclude <Plug> mappings as they are internal
	local reduced_keymaps = {}
	for _, map in ipairs(keymaps) do
		-- Skip mappings that start with "<Plug>"
		if not (map.display_lhs and map.display_lhs:match("^<Plug>")) then
			local reduced_map = {
				modes = map.modes,
				display_lhs = map.display_lhs,
				best_descr = map.best_descr,
			}
			table.insert(reduced_keymaps, reduced_map)
		end
	end

	-- Consolidate entries with same display_lhs and best_descr by concatenanting modes
	local consolidated_keymaps = {}
	local seen_combinations = {}

	for _, map in ipairs(reduced_keymaps) do
		local key = (map.display_lhs or "") .. "|" .. (map.best_descr or "")

		if seen_combinations[key] then
			local existing_entry = seen_combinations[key]
			if map.modes and map.modes ~= "" then
				if existing_entry.modes and existing_entry.modes ~= "" then
					existing_entry.modes = existing_entry.modes .. map.modes
				else
					existing_entry.modes = map.modes
				end
			end
		else
			local new_entry = {
				modes = map.modes,
				display_lhs = map.display_lhs,
				best_descr = map.best_descr,
			}
			seen_combinations[key] = new_entry
			table.insert(consolidated_keymaps, new_entry)
		end
	end

	-- Sort consolidated keymaps by display_lhs, then modes
	table.sort(consolidated_keymaps, function(a, b)
		return (a.display_lhs or "") < (b.display_lhs or "")
			or ((a.display_lhs or "") == (b.display_lhs or "") and (a.modes or "") < (b.modes or ""))
	end)

	M.dump_to_buffer(consolidated_keymaps)

	-- Uncomment to Save keymaps to CSV
	-- M.save_keymaps_to_csv(consolidated_keymaps)
end

function M.dump_to_buffer(keymaps)
	-- Create a new buffer to display the keymaps
	local buf = vim.api.nvim_create_buf(false, true) -- Create new buffer (not listed, scratch)
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
	vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
	vim.api.nvim_set_option_value("swapfile", false, { buf = buf })
	vim.api.nvim_buf_set_name(buf, "Keymaps")

	-- Calculate maximum column widths
	local max_modes_width = 5 -- Minimum width for "Modes" header
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

	-- Get the current leader keys
	local leader = vim.g.mapleader or "\\"
	local leader_display = leader
	local localleader = vim.g.maplocalleader or "\\"
	local localleader_display = localleader

	-- Make the leader key visible if it's a special character
	if leader == " " then
		leader_display = "<Space>"
	elseif leader == "\\" then
		leader_display = "\\"
	end

	if localleader == " " then
		localleader_display = "<Space>"
	elseif localleader == "\\" then
		localleader_display = "\\"
	end

	-- Prepare content for the buffer
	local lines = {
		"Your current <Leader> key is: " .. leader_display,
		'You can set it with vim.g.mapleader = "whatever"',
		"Your current <LocalLeader> key is: " .. localleader_display,
		'You can set it with vim.g.maplocalleader = "whatever"',
		"",
		"Keymaps:",
	}

	-- Create header with proper alignment
	local header = string.format(
		"%-" .. max_modes_width .. "s | %-" .. max_keymap_width .. "s | %s",
		"Modes",
		"Keymap",
		"Description"
	)
	table.insert(lines, header)

	-- Create separator line with proper alignment
	local separator = string.rep("-", max_modes_width)
		.. "-+-"
		.. string.rep("-", max_keymap_width)
		.. "-+-"
		.. string.rep("-", 30) -- Reasonable width for description
	table.insert(lines, separator)

	-- Add data rows with proper alignment
	for _, map in ipairs(keymaps) do
		local mode_str = map.modes or ""
		local lhs_str = map.display_lhs or ""
		local desc_str = map.best_descr or ""

		local formatted_line = string.format(
			"%-" .. max_modes_width .. "s | %-" .. max_keymap_width .. "s | %s",
			mode_str,
			lhs_str,
			desc_str
		)
		table.insert(lines, formatted_line)
	end

	-- Add unused prefixes information at the end
	local unused_text = M.unused_prefixes(keymaps)
	if unused_text and #unused_text > 0 then
		table.insert(lines, "")
		table.insert(lines, "")
		for _, line in ipairs(unused_text) do
			table.insert(lines, line)
		end
	end

	-- Set the buffer content
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	-- Open the buffer in a new window
	vim.api.nvim_command("vsplit")
	vim.api.nvim_win_set_buf(0, buf)

	-- Set buffer as readonly
	-- vim.api.nvim_set_option_value('modifiable', false, {buf = buf})
	-- vim.api.nvim_set_option_value('readonly', true, {buf = buf})
end

-- Function to escape CSV values for excel
function M.escape_csv_value(value)
	if value == nil then
		return "NONE"
	end
	value = tostring(value)
	-- Check if value starts with = or + (formula protection)
	if value:match("^[=+]") then
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

	-- Collect all possible field names
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

-- Analyze keymaps to identify unused leader key mappings
function M.unused_prefixes(keymaps)
	local lines = {}

	-- Collect all key mappings
	local all_keys = {}
	for _, map in ipairs(keymaps) do
		if map.display_lhs then
			table.insert(all_keys, map.display_lhs)
		end
	end

	-- Check for <Leader><Leader> mapping or any mapping starting with <Leader><Leader>
	local leader_leader_found = false
	for _, mapped in ipairs(all_keys) do
		if mapped:match("^<Leader><Leader>") then
			leader_leader_found = true
			break
		end
	end

	-- Check which letters (both lowercase and uppercase) are not used with <Leader> prefix
	local unused_lowercase = {}
	local unused_uppercase = {}

	-- For checking <Leader><Leader> combinations if <Leader><Leader> itself is already mapped
	local leader_leader_unused_lowercase = {}
	local leader_leader_unused_uppercase = {}

	-- Check lowercase letters (a-z)
	for i = 97, 122 do -- ASCII a-z (lowercase)
		local key = string.char(i)
		local found = false

		for _, mapped in ipairs(all_keys) do
			-- Check if this mapping starts with "<Leader>" followed by the key
			if mapped:match("^<Leader>" .. key) then
				found = true
				break
			end
		end

		if not found then
			table.insert(unused_lowercase, key)
		end
	end

	-- Check uppercase letters (A-Z)
	for i = 65, 90 do -- ASCII A-Z (uppercase)
		local key = string.char(i)
		local found = false

		for _, mapped in ipairs(all_keys) do
			-- Check if this mapping starts with "<Leader>" followed by the key
			if mapped:match("^<Leader>" .. key) then
				found = true
				break
			end
		end

		if not found then
			table.insert(unused_uppercase, key)
		end
	end

	-- If <Leader><Leader> is mapped, check for <Leader><Leader>{key} combinations
	if leader_leader_found then
		-- Check lowercase letters for <Leader><Leader> combinations
		for i = 97, 122 do -- ASCII a-z (lowercase)
			local key = string.char(i)
			local found = false

			for _, mapped in ipairs(all_keys) do
				-- Check if this mapping starts with "<Leader><Leader>" followed by the key
				if mapped:match("^<Leader><Leader>" .. key) then
					found = true
					break
				end
			end

			if not found then
				table.insert(leader_leader_unused_lowercase, key)
			end
		end

		-- Check uppercase letters for <Leader><Leader> combinations
		for i = 65, 90 do -- ASCII A-Z (uppercase)
			local key = string.char(i)
			local found = false

			for _, mapped in ipairs(all_keys) do
				-- Check if this mapping starts with "<Leader><Leader>" followed by the key
				if mapped:match("^<Leader><Leader>" .. key) then
					found = true
					break
				end
			end

			if not found then
				table.insert(leader_leader_unused_uppercase, key)
			end
		end
	end

	-- Format the output
	table.insert(lines, "Unused Leader Keys:")

	-- Report on <Leader><Leader>
	if not leader_leader_found then
		table.insert(lines, "<Leader><Leader> prefix is unused")
	else
		table.insert(lines, "<Leader><Leader> prefix is already in use")

		-- Report on <Leader><Leader> followed by lowercase letter keys
		if #leader_leader_unused_lowercase > 0 then
			table.insert(lines, "Unused <Leader><Leader> + lowercase combinations:")
			local grouped_keys = {}
			for i = 1, #leader_leader_unused_lowercase, 4 do -- Group keys in sets of 4 for better readability
				local group = {}
				for j = i, math.min(i + 3, #leader_leader_unused_lowercase) do
					table.insert(group, leader_leader_unused_lowercase[j])
				end
				table.insert(grouped_keys, "<Leader><Leader>" .. table.concat(group, ", <Leader><Leader>"))
			end
			for _, group in ipairs(grouped_keys) do
				table.insert(lines, "  " .. group)
			end
		else
			table.insert(lines, "All <Leader><Leader> + lowercase combinations are mapped")
		end

		-- Report on <Leader><Leader> followed by uppercase letter keys
		if #leader_leader_unused_uppercase > 0 then
			table.insert(lines, "Unused <Leader><Leader> + uppercase combinations:")
			local grouped_keys = {}
			for i = 1, #leader_leader_unused_uppercase, 4 do -- Group keys in sets of 4 for better readability
				local group = {}
				for j = i, math.min(i + 3, #leader_leader_unused_uppercase) do
					table.insert(group, leader_leader_unused_uppercase[j])
				end
				table.insert(grouped_keys, "<Leader><Leader>" .. table.concat(group, ", <Leader><Leader>"))
			end
			for _, group in ipairs(grouped_keys) do
				table.insert(lines, "  " .. group)
			end
		else
			table.insert(lines, "All <Leader><Leader> + uppercase combinations are mapped")
		end
	end

	-- Report on lowercase letter keys
	if #unused_lowercase > 0 then
		table.insert(lines, "Unused <Leader> + lowercase combinations:")
		local grouped_keys = {}
		for i = 1, #unused_lowercase, 6 do -- Group keys in sets of 6 for better readability
			local group = {}
			for j = i, math.min(i + 5, #unused_lowercase) do
				table.insert(group, unused_lowercase[j])
			end
			table.insert(grouped_keys, "<Leader>" .. table.concat(group, ", <Leader>"))
		end
		for _, group in ipairs(grouped_keys) do
			table.insert(lines, "  " .. group)
		end
	else
		table.insert(lines, "All lowercase letter keys are mapped with <Leader>")
	end

	-- Report on uppercase letter keys
	if #unused_uppercase > 0 then
		table.insert(lines, "Unused <Leader> + uppercase combinations:")
		local grouped_keys = {}
		for i = 1, #unused_uppercase, 6 do -- Group keys in sets of 6 for better readability
			local group = {}
			for j = i, math.min(i + 5, #unused_uppercase) do
				table.insert(group, unused_uppercase[j])
			end
			table.insert(grouped_keys, "<Leader>" .. table.concat(group, ", <Leader>"))
		end
		for _, group in ipairs(grouped_keys) do
			table.insert(lines, "  " .. group)
		end
	else
		table.insert(lines, "All uppercase letter keys are mapped with <Leader>")
	end

	return lines
end

-- Return the module
return M
