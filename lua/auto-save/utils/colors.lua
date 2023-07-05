--- This file is deprecated and should be removed in the future.
--- It is still in use but the functionality does not belong in the scope of this plugin

local o = vim.o
local api = vim.api

local BLACK = "#000000"
local WHITE = "#ffffff"
local auto_save_hl_group = "MsgArea"

local M = {}

---@param hex_str string hexadecimal value of a color
local hex_to_rgb = function(hex_str)
  local hex = "[abcdef0-9][abcdef0-9]"
  local pat = "^#(" .. hex .. ")(" .. hex .. ")(" .. hex .. ")$"
  hex_str = string.lower(hex_str)

  assert(string.find(hex_str, pat) ~= nil, "hex_to_rgb: invalid hex_str: " .. tostring(hex_str))

  local red, green, blue = string.match(hex_str, pat)
  return { tonumber(red, 16), tonumber(green, 16), tonumber(blue, 16) }
end

--- @param group string
--- @param color table
--- @param force? boolean
local function highlight(group, color, force)
  if color.link then
    vim.api.nvim_set_hl(0, group, {
      link = color.link,
    })
  else
    if color.style then
      for _, style in ipairs(color.style) do
        color[style] = true
      end
    end
    color.style = nil
    if force then
      vim.cmd("hi " .. group .. " guifg=" .. (color.fg or "NONE") .. " guibg=" .. (color.bg or "NONE"))
      return
    end
    vim.api.nvim_set_hl(0, group, color)
  end
end

local function get_hl(name)
  local ok, hl = pcall(vim.api.nvim_get_hl_by_name, name, true)
  if not ok then
    return
  end
  for _, key in pairs({ "foreground", "background", "special" }) do
    if hl[key] then
      hl[key] = string.format("#%06x", hl[key])
    end
  end
  return hl
end

---@param fg string foreground color
---@param bg string background color
---@param alpha number number between 0 and 1. 0 results in bg, 1 results in fg
local function blend(fg, bg, alpha)
  local bg_hex = hex_to_rgb(bg)
  local fg_hex = hex_to_rgb(fg)

  local blendChannel = function(i)
    local ret = (alpha * fg_hex[i] + ((1 - alpha) * bg_hex[i]))
    return math.floor(math.min(math.max(0, ret), 255) + 0.5)
  end

  return string.format("#%02X%02X%02X", blendChannel(1), blendChannel(2), blendChannel(3))
end

--- This function is still in use, but should be removed in the future.
--- The dimming should be done by the colorscheme or an UI Plugin.
--- @deprecated
--- @param dim_value number
M.apply_colors = function(dim_value)
  if dim_value > 0 then
    MSG_AREA = get_hl("MsgArea")
    if MSG_AREA.foreground ~= nil then
      MSG_AREA.background = (MSG_AREA.background or get_hl("Normal")["background"])
      local foreground = (
        o.background == "dark" and blend(MSG_AREA.background or BLACK, MSG_AREA.foreground or BLACK, dim_value)
        or blend(MSG_AREA.background or WHITE, MSG_AREA.foreground or WHITE, dim_value)
      )

      highlight("AutoSaveText", { fg = foreground })
      auto_save_hl_group = "AutoSaveText"
    end
  end
end

--- @deprecated
--- @see M.apply_colors
--- @param message string
M.echo_with_highlight = function(message)
  api.nvim_echo({ { message, auto_save_hl_group } }, true, {})
end

return M
