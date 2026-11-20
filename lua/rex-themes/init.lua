local palettes = require("rex-themes.palettes")

local M = {}

M.active = nil

-- Rex keeps one theme for light appearance and one for dark. Neovim's
-- 'background' follows the terminal's reported appearance, so it picks which.
function M.current_id()
  if not vim.env.REX_SESSION or vim.fn.executable("defaults") == 0 then
    return nil
  end
  assert(vim.system, "rex-themes needs Neovim 0.10 or newer")
  local key = vim.o.background == "light" and "Workspace.lightThemeID" or "Workspace.darkThemeID"
  local result = vim.system({ "defaults", "read", "com.superlogical.rex", key }, { text = true }):wait(500)
  if result.code ~= 0 then
    return nil
  end
  local id = vim.trim(result.stdout)
  if palettes[id] then
    return id
  end
end

-- The ID refresh() just read, so load() does not run `defaults read` again.
local pending

function M.load()
  local id = pending or M.current_id()
  if not id then
    return false
  end
  local palette = palettes[id]

  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
  end
  vim.g.colors_name = "rex"

  for group, spec in pairs(require("rex-themes.highlights").groups(palette)) do
    vim.api.nvim_set_hl(0, group, spec)
  end
  for i, color in ipairs(palette.ansi) do
    vim.g["terminal_color_" .. (i - 1)] = color
  end

  M.active = id
  return true
end

local fallback

local function refresh(force)
  local id = M.current_id()
  if not force and id == M.active then
    return
  end
  M.active = id
  if id then
    pending = id
    local ok, err = pcall(vim.cmd.colorscheme, "rex")
    pending = nil
    if not ok then
      error(err, 0)
    end
  else
    if fallback then
      fallback()
    end
  end
end

-- `fallback` runs whenever the active Rex theme has no palette here, such as
-- a custom theme or Neovim running outside Rex. Without one, the current
-- colorscheme is left alone.
function M.setup(opts)
  opts = opts or {}
  fallback = opts.fallback

  local group = vim.api.nvim_create_augroup("rex-themes", { clear = true })
  vim.api.nvim_create_autocmd("OptionSet", {
    group = group,
    pattern = "background",
    nested = true,
    callback = function()
      refresh(true)
    end,
  })
  vim.api.nvim_create_autocmd("FocusGained", {
    group = group,
    nested = true,
    callback = function()
      refresh(false)
    end,
  })

  refresh(true)
end

return M
