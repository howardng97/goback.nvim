-- lua/goback/commands.lua
local M = {}

-- Safely set the buffer if it is valid
local function safe_set_buf(bufnr)
	if vim.api.nvim_buf_is_valid(bufnr) then
		vim.api.nvim_set_current_buf(bufnr)
	else
		print("Buffer does not exist!")
	end
end

-- Safely set the tab if it is valid
local function safe_set_tab(tabnr)
	if vim.api.nvim_tabpage_is_valid(tabnr) then
		vim.api.nvim_set_current_tabpage(tabnr)
	else
		print("Tab does not exist!")
	end
end

-- Return to the last saved position
function M.return_last_leave(S, config)
	if not S["last"] then
		print("No previous position to return to!")
		return
	end

	-- Switch to the saved tab if configured
	if config.save_tab and S["last"].tab then
		safe_set_tab(S["last"].tab)
	end

	-- Switch to the saved buffer
	safe_set_buf(S["last"].buf)

	-- Switch to the saved window if configured
	local win_id = vim.api.nvim_get_current_win()
	if config.save_win and S["last"].win then
		win_id = S["last"].win
	end

	-- Restore cursor position
	if S["last"].buf_cursor then
		vim.api.nvim_win_set_cursor(win_id, S["last"].buf_cursor)
	else
		print("Unable to set the cursor!")
	end
end

-- Register the GoBackLast user command
function M.setup_user_commands()
	vim.api.nvim_create_user_command("GoBackLast", function()
		M.return_last_leave(S, M.config)
	end, {})
end

return M
