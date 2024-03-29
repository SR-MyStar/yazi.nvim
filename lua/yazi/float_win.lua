local float_win = {}

local function getpos(width, height, pos, ui)
  local x, y, anchor = 0, 0, ""
  if type(pos) == "string" then
    if pos:sub(1, 1) == "c" then
      anchor = anchor .. "N"
      x = math.ceil((ui.height - height) / 2 - 1)
    elseif pos:sub(1, 1) == "t" then
      anchor = anchor .. "N"
      x = 1
    elseif pos:sub(1, 1) == "b" then
      anchor = anchor .. "S"
      x = ui.height - 1
    end
    if pos:sub(2, 2) == "c" then
      anchor = anchor .. "W"
      y = math.ceil((ui.width - width) / 2)
    elseif pos:sub(2, 2) == "l" then
      anchor = anchor .. "W"
      y = 0
    elseif pos:sub(2, 2) == "r" then
      anchor = anchor .. "E"
      y = ui.width
    end
  else
    x, y = pos[1], pos[2]
  end
  return x, y, anchor
end

local function update(win, val, ui)
  if 0 < win.width and win.width < 1 then
    win.width = math.ceil(ui.width * win.width)
  end
  if 0 < win.height and win.height < 1 then
    win.height = math.ceil(ui.height * win.height)
  end
  if val.lines then
    for _, v in ipairs(val.lines) do
      win.width = math.max(win.width, vim.fn.strchars(v))
    end
    win.height = math.max(win.height, #val.lines)
  end
  win.height, win.width =
    math.min(win.height, ui.height), math.min(win.width, ui.width)
  return win
end

local function float_win_opt(opt, val)
  local ui = vim.api.nvim_list_uis()[1]
  local win = vim.tbl_extend("force", {
    anchor = "NW",
    relative = "editor",
    width = math.ceil(ui.width / 2),
    height = math.ceil(ui.height / 2),
    style = "minimal",
    border = "rounded",
    title = "",
    title_pos = "center",
  }, opt or {})
  win = update(win, val, ui)
  win.row, win.col, win.anchor = getpos(win.width, win.height, val.pos, ui)
  return win
end

function float_win:GetInfo()
  return {
    width = float_win.win.width,
    height = float_win.win.height,
    col = float_win.win.col,
    row = float_win.win.row,
    bufnr = float_win.bufnr,
    winnr = float_win.winnr,
  }
end

-- @type
-- opt = {
--   anchor = 'NW',
--   relative = 'editor',
--   width = math.ceil(ui.width / 2),
--   height = math.ceil(ui.height / 2),
--   style = 'minimal',
--   border = 'rounded',
--   title = '',
--   title_pos = 'center',
-- }
-- val = {
--   lines = {},
--   buflisted = false,
--   pos = 'cc',
-- }
function float_win:Create(opt, val)
  val = vim.tbl_extend("force", {
    lines = {},
    buflisted = false,
    pos = "cc",
  }, val or {})
  float_win.win = float_win_opt(opt, val)
  float_win.bufnr = vim.api.nvim_create_buf(val.buflisted, true)
  float_win.winnr = vim.api.nvim_open_win(float_win.bufnr, true, float_win.win)
end

return float_win
