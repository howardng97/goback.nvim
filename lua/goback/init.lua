-- lua/goback/init.lua
local M = {}
local config = {
	save_tab = true,
	save_win = true,
}

-- State to save last position
local S = {}

-- Check if the current buffer is a command-line or special window
local function is_valid_buf()
	local buftype = vim.api.nvim_buf_get_option(0, "buftype")
	return buftype == "" -- Chỉ chấp nhận buffer thông thường (không phải command, prompt, quickfix, ...)
end

-- Save the current position
local function on_leave()
	if S.is_returning then
		return
	end
	if not is_valid_buf() then
		return
	end
	local bufnr = vim.api.nvim_get_current_buf()
	local buf_cursor = vim.api.nvim_win_get_cursor(0)
	-- Create a new save point
	S["last"] = { buf = bufnr, buf_cursor = buf_cursor }

	-- Save tab if configured
	if M.config.save_tab then
		local tabnr = vim.api.nvim_get_current_tabpage()
		S["last"].tab = tabnr
	end

	-- Save window if configured
	if M.config.save_win then
		local winnr = vim.api.nvim_get_current_win()
		S["last"].win = winnr
	end
end

-- Setup function and event registration
function M.setup(opts)
	opts = opts or {}
	M.config = vim.tbl_deep_extend("force", config, opts)
	-- Create autocommands for buffer and window events
	vim.api.nvim_create_autocmd({ "BufLeave", "BufWinLeave" }, {
		pattern = "*",
		callback = on_leave,
	})

	if M.config.save_win then
		vim.api.nvim_create_autocmd("WinLeave", {
			pattern = "*",
			callback = on_leave,
		})
	end

	if M.config.save_tab then
		vim.api.nvim_create_autocmd("TabLeave", {
			pattern = "*",
			callback = on_leave,
		})
	end

	-- Import and setup user commands
	local commands = require("goback.commands")
	-- Prevent recursive saving
	S.is_returning = false
	commands.setup_user_commands(S, M.config)

	print("GoBackLast plugin loaded!")
end

return M
