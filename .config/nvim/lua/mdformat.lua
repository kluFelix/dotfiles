-- Markdown table formatter.
-- In markdown buffers: select a table and press `=` (or `=ap` in normal mode,
-- or `gq`) to align its columns. Non-table lines are left untouched.

local M = {}

M.options = {
    -- "aligned": pad columns so the pipes line up
    -- "minimal": compact |a|b|c| form without padding
    style = "aligned",
}

local function trim(s)
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function is_table_line(line)
  return line:match("^%s*|") ~= nil
end

-- "| a | b |" -> { "a", " b " }; nil when the line is not a table row.
-- Splits on unescaped pipes only: `\|` stays inside the cell, and backslashes
-- are consumed in pairs so `\\|` (escaped backslash) still ends the cell.
local function split_row(line)
  local inner = line:match("^%s*|(.*)|%s*$")
  if not inner then
    return nil
  end
  local cells, pos, i = {}, 1, 1
  while i <= #inner do
    local c = inner:sub(i, i)
    if c == "\\" then
      i = i + 2
    elseif c == "|" then
      cells[#cells + 1] = inner:sub(pos, i - 1)
      pos = i + 1
      i = i + 1
    else
      i = i + 1
    end
  end
  cells[#cells + 1] = inner:sub(pos)
  return cells
end

-- cell made of dashes with at most one leading/trailing colon (":---", "---:", ":---:", "---")
local function is_sep_cell(s)
  local t = trim(s)
  if t == "" or t:find("[^:%-]") then
    return false
  end
  if t:sub(1, 1) == ":" then
    t = t:sub(2)
  end
  if t:sub(-1) == ":" then
    t = t:sub(1, -2)
  end
  return #t > 0 and t:find("[^%-]") == nil
end

local function is_separator(cells)
  if #cells == 0 then
    return false
  end
  for _, c in ipairs(cells) do
    if not is_sep_cell(c) then
      return false
    end
  end
  return true
end

local function alignment(s)
  local t = s:gsub("%s", "")
  local left = t:sub(1, 1) == ":"
  local right = t:sub(-1) == ":"
  if left and right then
    return "center"
  elseif right then
    return "right"
  end
  return "left"
end

local function pad_cell(text, width, align)
  local pad = width - vim.fn.strdisplaywidth(text)
  if pad < 0 then
    pad = 0
  end
  if align == "right" then
    return string.rep(" ", pad) .. text
  elseif align == "center" then
    local l = math.floor(pad / 2)
    return string.rep(" ", l) .. text .. string.rep(" ", pad - l)
  end
  return text .. string.rep(" ", pad)
end

-- separator cell spanning the full column (content width + surrounding spaces)
local function sep_cell(width, align)
  local span = width + 2
  if align == "right" then
    return string.rep("-", span - 1) .. ":"
  elseif align == "center" then
    return ":" .. string.rep("-", span - 2) .. ":"
  end
  -- no colons: plain dashes are the default (left) alignment
  return string.rep("-", span)
end

local function sep_cell_minimal(align)
  if align == "right" then
    return "---:"
  elseif align == "center" then
    return ":---:"
  end
  return "---"
end

local function render_row(cells, style)
  if style == "minimal" then
    return "|" .. table.concat(cells, "|") .. "|"
  end
  return "| " .. table.concat(cells, " | ") .. " |"
end

-- separator row: dashes fill the whole column, no surrounding spaces
local function render_sep(cells)
  return "|" .. table.concat(cells, "|") .. "|"
end

-- Reformat one contiguous table block; returns it unchanged when it is not a valid table
local function format_block(block, style)
  local rows, maxcols, sep_idx = {}, 0, nil

  for idx = 1, #block do
    local cells = split_row(block[idx])
    if not cells then
      return block
    end
    rows[idx] = cells
    if #cells > maxcols then
      maxcols = #cells
    end
  end

  -- keep the block's common indent (tables inside list items)
  local indent = nil
  for _, line in ipairs(block) do
    local ind = line:match("^(%s*)")
    if indent == nil or #ind < #indent then
      indent = ind
    end
  end
  indent = indent or ""

  for idx = 1, #block do
    if is_separator(rows[idx]) then
      sep_idx = idx
      break
    end
  end

  local aligns = {}
  for c = 1, maxcols do
    aligns[c] = "left"
  end
  if sep_idx then
    for c = 1, maxcols do
      local s = rows[sep_idx][c]
      if s then
        aligns[c] = alignment(s)
      end
    end
  end

  local widths = {}
  for c = 1, maxcols do
    widths[c] = 1
  end
  if style ~= "minimal" then
    for idx = 1, #block do
      -- dash rows must not drive the column width
      if idx ~= sep_idx then
        for c = 1, #rows[idx] do
          -- display width (multibyte-safe) of the cell content; existing
          -- trailing padding is ignored
          local len = vim.fn.strdisplaywidth(trim(rows[idx][c]))
          if len > widths[c] then
            widths[c] = len
          end
        end
      end
    end
  end

  local out = {}
  for idx = 1, #block do
    local cells = {}
    for c = 1, maxcols do
      local raw = rows[idx][c]
      local text = raw and trim(raw) or ""
      if idx == sep_idx then
        cells[c] = style == "minimal" and sep_cell_minimal(aligns[c]) or sep_cell(widths[c], aligns[c])
      elseif style == "minimal" then
        cells[c] = text
      else
        cells[c] = pad_cell(text, widths[c], aligns[c])
      end
    end
    out[idx] = indent .. (idx == sep_idx and render_sep(cells) or render_row(cells, style))
  end
  return out
end

-- Reformat all table blocks in the given lines, leaving every other line untouched
function M.format(lines)
  local style = M.options.style or "aligned"
  local out, i, n = {}, 1, #lines
  while i <= n do
    if is_table_line(lines[i]) then
      local j = i
      while j <= n and is_table_line(lines[j]) do
        j = j + 1
      end
      local block = vim.list_slice(lines, i, j - 1)
      out = vim.list_extend(out, format_block(block, style))
      i = j
    else
      out[#out + 1] = lines[i]
      i = i + 1
    end
  end
  return out
end

-- Reformat the lines [start, finish] (1-based, inclusive) of the current buffer
local function format_lines(start, finish)
  local lines = vim.api.nvim_buf_get_lines(0, start - 1, finish, false)
  vim.api.nvim_buf_set_lines(0, start - 1, finish, false, M.format(lines))
end

-- True when any line in [start, finish] is a table row.
local function range_has_table(start, finish)
  for i = start, finish do
    local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1] or ""
    if is_table_line(line) and split_row(line) then
      return true
    end
  end
  return false
end

-- Reindent a line range with the built-in `=` operator. `normal!` bypasses the
-- mdformat keymap, so `=` can fall back to real indentation on table-free text.
local function reindent_range(start, finish)
  vim.api.nvim_win_call(0, function()
    local save = vim.fn.winsaveview()
    vim.cmd("silent! keepjumps normal! " .. start .. "GV" .. finish .. "G=")
    vim.fn.winrestview(save)
  end)
end

-- `=` in visual mode: format the selected lines (selection stays active)
-- Note: '< / '> are only materialized when visual mode exits, so the range
-- is derived from the cursor and the `v` mark (other end of the selection).
function M.format_visual()
  local cur = vim.api.nvim_win_get_cursor(0)[1]
  local other = vim.fn.line("v")
  local start, finish = math.min(cur, other), math.max(cur, other)
  if not range_has_table(start, finish) then
    reindent_range(start, finish)
    return
  end
  format_lines(start, finish)
end

-- 'operatorfunc' for `=` + motion in normal mode (invoked by the g@ operator)
function M.opfunc()
  local start, finish = vim.fn.line("'["), vim.fn.line("']")
  if range_has_table(start, finish) then
    format_lines(start, finish)
  else
    reindent_range(start, finish)
  end
  -- operatorfunc is global; it was only set for this one operator
  vim.go.operatorfunc = ""
  return "'[V']"
end

-- 'formatexpr' callback for `gq`: v:lnum = first line, v:count = number of
-- lines. Must set the lines itself and return 0 (a non-zero return falls back
-- to the internal formatter).
function M.expr()
  local first = vim.v.lnum
  local finish = first + vim.v.count - 1
  format_lines(first, finish)
  return 0
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("MarkdownTableFormat", { clear = true }),
  pattern = "markdown",
  callback = function(args)
    local buf = args.buf
    -- `gq` formats tables
    vim.bo[buf].formatexpr = "v:lua.require'mdformat'.expr()"
    -- `=` formats the visual selection (must be a function, not <Cmd>: the
    -- range is read from the cursor + `v` mark while visual mode is active)
    vim.keymap.set("v", "=", M.format_visual, {
      buffer = buf,
      desc = "Format markdown table",
    })
    -- ... or (normal mode) the text of a motion, e.g. =ap
    vim.keymap.set("n", "=", ":set operatorfunc=v:lua.require'mdformat'.opfunc<CR>g@", {
      buffer = buf,
      desc = "Format markdown table",
    })
  end,
})

return M
