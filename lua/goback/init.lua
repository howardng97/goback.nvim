-- lua/goback/init.lua
local M = {}
local config = {
	save_tab = true,
	save_win = true,
}

-- State to save last position
local S = {}

-- Save the current position
local function on_leave()
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
	commands.setup_user_commands()

	print("GoBackLast plugin loaded!")
end

return M
