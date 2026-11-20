local M = {}

local function rgb(hex)
  return tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16)
end

-- Mixes `amount` of `top` into `base`.
local function blend(top, base, amount)
  local r1, g1, b1 = rgb(top)
  local r2, g2, b2 = rgb(base)
  local function mix(a, b)
    return math.floor(a * amount + b * (1 - amount) + 0.5)
  end
  return string.format("#%02x%02x%02x", mix(r1, r2), mix(g1, g2), mix(b1, b2))
end

-- Rough brightness, only good for telling which of two colors is darker.
local function luma(hex)
  local r, g, b = rgb(hex)
  return 0.2126 * r + 0.7152 * g + 0.0722 * b
end

function M.groups(p)
  local a = p.ansi
  local c = {
    bg = p.bg,
    fg = p.fg,
    red = a[2],
    green = a[3],
    yellow = a[4],
    blue = a[5],
    magenta = a[6],
    cyan = a[7],
    bright_red = a[10],
    bright_yellow = a[12],
    bright_cyan = a[15],
    muted = a[9],
  }
  c.subtle = blend(c.fg, c.bg, 0.65)
  c.surface = blend(c.fg, c.bg, 0.06)
  c.overlay = blend(c.fg, c.bg, 0.10)
  c.highlight = blend(c.fg, c.bg, 0.18)
  c.border = blend(c.fg, c.bg, 0.25)
  -- On a light background the bright variant is usually the lighter one, so it reads worse.
  c.special = p.appearance == "light" and luma(c.cyan) < luma(c.bright_cyan) and c.cyan or c.bright_cyan

  local function tint(color, amount)
    return blend(color, c.bg, amount or 0.15)
  end

  return {
    Normal = { fg = c.fg, bg = c.bg },
    NormalNC = { link = "Normal" },
    NormalFloat = { fg = c.fg, bg = c.overlay },
    FloatBorder = { fg = c.muted, bg = c.overlay },
    FloatTitle = { fg = c.muted, bg = c.overlay, bold = true },
    Cursor = { fg = p.cursor_text, bg = p.cursor },
    lCursor = { link = "Cursor" },
    TermCursor = { link = "Cursor" },
    CursorLine = { bg = c.surface },
    CursorColumn = { link = "CursorLine" },
    ColorColumn = { bg = c.surface },
    CursorLineNr = { fg = c.fg, bold = true },
    LineNr = { fg = c.border },
    SignColumn = { bg = c.bg },
    FoldColumn = { fg = c.border, bg = c.bg },
    Folded = { fg = c.subtle, bg = c.surface },
    Visual = { bg = p.selection_bg },
    VisualNOS = { link = "Visual" },
    Search = { bg = tint(c.yellow, 0.3) },
    CurSearch = { fg = c.bg, bg = c.yellow },
    IncSearch = { link = "CurSearch" },
    Substitute = { fg = c.bg, bg = c.red },
    MatchParen = { bg = c.highlight, bold = true },
    NonText = { fg = c.border },
    Whitespace = { fg = c.highlight },
    SpecialKey = { fg = c.border },
    EndOfBuffer = { fg = c.bg },
    Conceal = { fg = c.muted },
    WinSeparator = { fg = c.highlight },
    VertSplit = { link = "WinSeparator" },
    StatusLine = { fg = c.fg, bg = c.overlay },
    StatusLineNC = { fg = c.muted, bg = c.surface },
    WinBar = { fg = c.subtle, bg = c.bg },
    WinBarNC = { fg = c.muted, bg = c.bg },
    TabLine = { fg = c.muted, bg = c.surface },
    TabLineSel = { fg = c.fg, bg = c.bg, bold = true },
    TabLineFill = { bg = c.surface },
    Pmenu = { fg = c.fg, bg = c.overlay },
    PmenuSel = { bg = c.highlight, bold = true },
    PmenuSbar = { bg = c.overlay },
    PmenuThumb = { bg = c.border },
    PmenuKind = { fg = c.blue, bg = c.overlay },
    PmenuExtra = { fg = c.muted, bg = c.overlay },
    WildMenu = { link = "PmenuSel" },
    QuickFixLine = { bg = c.highlight },
    Title = { fg = c.blue, bold = true },
    Directory = { fg = c.blue },
    ErrorMsg = { fg = c.red },
    WarningMsg = { fg = c.yellow },
    MoreMsg = { fg = c.green },
    OkMsg = { fg = c.green },
    ModeMsg = { fg = c.fg, bold = true },
    Question = { fg = c.blue },

    Comment = { fg = c.muted, italic = true },
    Constant = { fg = c.yellow },
    String = { fg = c.green },
    Character = { link = "String" },
    Number = { fg = c.yellow },
    Boolean = { fg = c.yellow },
    Float = { link = "Number" },
    Identifier = { fg = c.fg },
    Function = { fg = c.blue },
    Statement = { fg = c.magenta },
    Keyword = { fg = c.magenta },
    Conditional = { link = "Keyword" },
    Repeat = { link = "Keyword" },
    Label = { link = "Keyword" },
    Exception = { link = "Keyword" },
    Operator = { fg = c.subtle },
    PreProc = { fg = c.magenta },
    Include = { link = "PreProc" },
    Define = { link = "PreProc" },
    Macro = { fg = c.cyan },
    Type = { fg = c.cyan },
    StorageClass = { link = "Keyword" },
    Structure = { link = "Type" },
    Typedef = { link = "Type" },
    Special = { fg = c.special },
    SpecialChar = { link = "Special" },
    Tag = { fg = c.red },
    Delimiter = { fg = c.subtle },
    SpecialComment = { fg = c.muted, bold = true },
    Debug = { fg = c.red },
    Underlined = { underline = true },
    Error = { fg = c.red },
    Todo = { fg = c.bg, bg = c.yellow, bold = true },

    ["@variable"] = { fg = c.fg },
    ["@variable.builtin"] = { fg = c.red },
    ["@variable.parameter"] = { fg = c.fg, italic = true },
    ["@variable.member"] = { fg = c.red },
    ["@property"] = { link = "@variable.member" },
    ["@constant.builtin"] = { fg = c.yellow },
    ["@module"] = { fg = c.yellow },
    ["@string.escape"] = { fg = c.cyan },
    ["@string.regexp"] = { fg = c.cyan },
    ["@string.special.url"] = { fg = c.blue, underline = true },
    ["@function.builtin"] = { fg = c.cyan },
    ["@function.method"] = { link = "Function" },
    ["@constructor"] = { fg = c.yellow },
    ["@type.builtin"] = { fg = c.cyan },
    ["@attribute"] = { fg = c.yellow },
    ["@tag"] = { fg = c.red },
    ["@tag.attribute"] = { fg = c.yellow },
    ["@tag.delimiter"] = { fg = c.subtle },
    ["@punctuation.delimiter"] = { fg = c.subtle },
    ["@punctuation.bracket"] = { fg = c.subtle },
    ["@punctuation.special"] = { fg = c.cyan },
    ["@markup.heading"] = { fg = c.blue, bold = true },
    ["@markup.strong"] = { bold = true },
    ["@markup.italic"] = { italic = true },
    ["@markup.strikethrough"] = { strikethrough = true },
    ["@markup.link"] = { fg = c.blue },
    ["@markup.link.url"] = { fg = c.blue, underline = true },
    ["@markup.raw"] = { fg = c.green },
    ["@markup.list"] = { fg = c.magenta },
    ["@markup.quote"] = { fg = c.subtle, italic = true },
    ["@lsp.type.namespace"] = { link = "@module" },
    ["@lsp.type.parameter"] = { link = "@variable.parameter" },
    ["@lsp.type.property"] = { link = "@property" },

    DiagnosticError = { fg = c.red },
    DiagnosticWarn = { fg = c.yellow },
    DiagnosticInfo = { fg = c.blue },
    DiagnosticHint = { fg = c.cyan },
    DiagnosticOk = { fg = c.green },
    DiagnosticVirtualTextError = { fg = c.red, bg = tint(c.red, 0.1) },
    DiagnosticVirtualTextWarn = { fg = c.yellow, bg = tint(c.yellow, 0.1) },
    DiagnosticVirtualTextInfo = { fg = c.blue, bg = tint(c.blue, 0.1) },
    DiagnosticVirtualTextHint = { fg = c.cyan, bg = tint(c.cyan, 0.1) },
    DiagnosticUnderlineError = { undercurl = true, sp = c.red },
    DiagnosticUnderlineWarn = { undercurl = true, sp = c.yellow },
    DiagnosticUnderlineInfo = { undercurl = true, sp = c.blue },
    DiagnosticUnderlineHint = { undercurl = true, sp = c.cyan },
    DiagnosticUnderlineOk = { undercurl = true, sp = c.green },
    DiagnosticUnnecessary = { fg = c.muted },
    LspReferenceText = { bg = c.highlight },
    LspReferenceRead = { link = "LspReferenceText" },
    LspReferenceWrite = { link = "LspReferenceText" },
    LspInlayHint = { fg = c.muted, bg = c.surface },
    LspSignatureActiveParameter = { bg = c.highlight, bold = true },

    SpellBad = { undercurl = true, sp = c.red },
    SpellCap = { undercurl = true, sp = c.yellow },
    SpellLocal = { undercurl = true, sp = c.cyan },
    SpellRare = { undercurl = true, sp = c.magenta },

    Added = { fg = c.green },
    Changed = { fg = c.blue },
    Removed = { fg = c.red },
    DiffAdd = { bg = tint(c.green) },
    DiffChange = { bg = tint(c.blue, 0.1) },
    DiffDelete = { bg = tint(c.red) },
    DiffText = { bg = tint(c.blue, 0.3) },
    diffAdded = { link = "Added" },
    diffChanged = { link = "Changed" },
    diffRemoved = { link = "Removed" },
  }
end

return M
