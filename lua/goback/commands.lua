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

-- Check if the current window is a valid buffer window
local function is_valid_window(win_id)
  local buftype = vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(win_id), "buftype")
  return buftype == "" -- Chỉ lấy các cửa sổ chứa buffer thông thường
end

-- Check if in split mode (more than one window)
local function is_split_mode()
  return vim.fn.winnr("$") > 1
end

-- Find the window that contains the last buffer and is a valid buffer window
local function find_window_with_buf(bufnr, last_win_id)
  for _, win_id in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(win_id) and is_valid_window(win_id) then
      local win_buf = vim.api.nvim_win_get_buf(win_id)
      if win_buf == bufnr and win_id ~= last_win_id then
        return win_id
      end
    end
  end
  return nil
end

-- Main function to return to the last position
function M.return_last_leave(S, config)
  if not S["last"] then
    print("No previous position to return to!")
    return
  end

  -- Set flag to prevent recursive save
  S.is_returning = true

  -- Switch to the saved tab if configured
  if config.save_tab and S["last"].tab then
    safe_set_tab(S["last"].tab)
  end

  -- Check if in split mode and find the window containing the last buffer
  local win_id = nil
  if is_split_mode() then
    win_id = find_window_with_buf(S["last"].buf, S["last"].win)
  end

  -- If window not found or not in split mode, use the saved window ID
  if not win_id and config.save_win and S["last"].win then
    win_id = S["last"].win
  end

  -- Set window if valid
  if win_id and vim.api.nvim_win_is_valid(win_id) then
    vim.api.nvim_set_current_win(win_id)
  else
    print("Window does not exist or is not valid!")
  end

  -- Ensure the buffer is set correctly within the selected window
  if vim.api.nvim_win_get_buf(win_id) ~= S["last"].buf then
    safe_set_buf(S["last"].buf)
  end

  -- Restore cursor position
  if S["last"].buf_cursor then
    vim.api.nvim_win_set_cursor(win_id, S["last"].buf_cursor)
  else
    print("Unable to set the cursor!")
  end

  -- Unset the flag after completion
  S.is_returning = false
end

-- Register the GoBackLast user command
function M.setup_user_commands(S, config)
  vim.api.nvim_create_user_command("GoBackLast", function()
    M.return_last_leave(S, config)
  end, {})
end

return M
