--[[
    Yugen UI Library v1.2.0,
    Fluent-inspired dark UI for Roblox executor scripts. Yugen API.

    Load:
      local YugenUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Moonoffss/uilib/main/yugen_ui.lua?v=1.2.0"))()

    Window:
      local Window = YugenUI:CreateWindow({
          Name = "Yugen", Subtitle = "v1.1", Theme = "Teal",
          ToggleKey = Enum.KeyCode.RightShift, Resizable = true,
          ShowProfile = true, Profile = { Plan = "Free", Subtitle = "Free plan" },
          Transparency = false, Acrylic = false, -- acrylic off: may be detectable
      })
      Window:SetTheme("Violet")
      Window:Minimize()
      Window:Dialog({ Title = "Sure?", Content = "…", Buttons = {
          { Title = "Yes", Callback = function() end },
          { Title = "No" },
      }})
      Window:BuildSettingsTab(settingsTab)
      Window:SaveConfig("default") / LoadConfig / ListConfigs

    Controls (all accept Description, Flag):
      Tab:Section, Label, Paragraph, Toggle, ToggleKeybind, Slider,
      Dropdown ({ Multi = true }), Input, ColorPicker, Keybind ({ Mode = "Toggle"|"Hold"|"Always", GetState }),
      Button
      Returns { Set, Get, OnChanged, Value } and registers YugenUI.Options[Flag] / Window.Flags

    Notify:
      YugenUI:Notify("Title", "Text", 3)
      YugenUI:Notify({ Title = "Yugen", Content = "Hi", SubContent = "extra", Duration = 0 }) -- 0 = sticky
--]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local YugenUI = {
    Version = "1.2.0",
    Windows = {},
    Options = {},
    ThemeName = "Fluent",
    Transparency = false,
    Acrylic = false,
}

local toastGui

local taskLib
pcall(function()
    taskLib = task
end)

local function deferCall(fn)
    if type(fn) ~= "function" then
        return
    end
    if type(taskLib) == "table" and type(taskLib.defer) == "function" then
        taskLib.defer(fn)
        return
    end
    if type(taskLib) == "table" and type(taskLib.spawn) == "function" then
        taskLib.spawn(fn)
        return
    end
    if type(spawn) == "function" then
        spawn(fn)
        return
    end
    pcall(fn)
end

local function delayCall(sec, fn)
    if type(fn) ~= "function" then
        return
    end
    if type(taskLib) == "table" and type(taskLib.delay) == "function" then
        taskLib.delay(sec, fn)
        return
    end
    if type(delay) == "function" then
        delay(sec, fn)
        return
    end
    deferCall(fn)
end

local function enumItem(enumName, itemName)
    local ok, value = pcall(function()
        return Enum[enumName][itemName]
    end)
    if ok then
        return value
    end
    return nil
end

local function clamp(n, a, b)
    if n < a then
        return a
    end
    if n > b then
        return b
    end
    return n
end

--------------------------------------------------------------------
-- Theme
--------------------------------------------------------------------
local Theme = {
    Bg = Color3.fromRGB(19, 19, 22),
    Panel = Color3.fromRGB(24, 24, 28),
    Card = Color3.fromRGB(31, 31, 36),
    CardHover = Color3.fromRGB(39, 39, 45),
    Stroke = Color3.fromRGB(55, 55, 64),
    Text = Color3.fromRGB(245, 245, 247),
    Muted = Color3.fromRGB(164, 164, 178),
    Accent = Color3.fromRGB(139, 124, 246),
    AccentDim = Color3.fromRGB(67, 58, 112),
    Danger = Color3.fromRGB(235, 78, 92),
    Warn = Color3.fromRGB(255, 186, 73),
    Success = Color3.fromRGB(80, 220, 140),
    Track = Color3.fromRGB(50, 50, 58),
}

local ThemePresets = {
    Fluent = {
        Bg = Color3.fromRGB(19, 19, 22),
        Panel = Color3.fromRGB(24, 24, 28),
        Card = Color3.fromRGB(31, 31, 36),
        CardHover = Color3.fromRGB(39, 39, 45),
        Stroke = Color3.fromRGB(55, 55, 64),
        Text = Color3.fromRGB(245, 245, 247),
        Muted = Color3.fromRGB(164, 164, 178),
        Accent = Color3.fromRGB(139, 124, 246),
        AccentDim = Color3.fromRGB(67, 58, 112),
        Danger = Color3.fromRGB(235, 78, 92),
        Warn = Color3.fromRGB(255, 186, 73),
        Success = Color3.fromRGB(80, 220, 140),
        Track = Color3.fromRGB(50, 50, 58),
    },
    Teal = {
        Bg = Color3.fromRGB(10, 12, 16),
        Panel = Color3.fromRGB(16, 19, 26),
        Card = Color3.fromRGB(22, 26, 34),
        CardHover = Color3.fromRGB(28, 33, 44),
        Stroke = Color3.fromRGB(42, 50, 64),
        Text = Color3.fromRGB(236, 240, 245),
        Muted = Color3.fromRGB(130, 140, 158),
        Accent = Color3.fromRGB(56, 214, 186),
        AccentDim = Color3.fromRGB(32, 120, 108),
        Danger = Color3.fromRGB(235, 78, 92),
        Warn = Color3.fromRGB(255, 186, 73),
        Success = Color3.fromRGB(80, 220, 140),
        Track = Color3.fromRGB(35, 42, 55),
    },
    Violet = {
        Bg = Color3.fromRGB(12, 10, 18),
        Panel = Color3.fromRGB(20, 16, 28),
        Card = Color3.fromRGB(28, 22, 40),
        CardHover = Color3.fromRGB(36, 28, 52),
        Stroke = Color3.fromRGB(58, 48, 78),
        Text = Color3.fromRGB(240, 236, 250),
        Muted = Color3.fromRGB(150, 140, 170),
        Accent = Color3.fromRGB(168, 120, 255),
        AccentDim = Color3.fromRGB(90, 60, 150),
        Danger = Color3.fromRGB(235, 78, 92),
        Warn = Color3.fromRGB(255, 186, 73),
        Success = Color3.fromRGB(80, 220, 140),
        Track = Color3.fromRGB(40, 34, 55),
    },
    Crimson = {
        Bg = Color3.fromRGB(14, 10, 10),
        Panel = Color3.fromRGB(22, 14, 14),
        Card = Color3.fromRGB(32, 18, 18),
        CardHover = Color3.fromRGB(42, 24, 24),
        Stroke = Color3.fromRGB(70, 40, 40),
        Text = Color3.fromRGB(245, 236, 236),
        Muted = Color3.fromRGB(160, 130, 130),
        Accent = Color3.fromRGB(255, 80, 100),
        AccentDim = Color3.fromRGB(140, 40, 55),
        Danger = Color3.fromRGB(255, 70, 70),
        Warn = Color3.fromRGB(255, 186, 73),
        Success = Color3.fromRGB(80, 220, 140),
        Track = Color3.fromRGB(50, 30, 32),
    },
    Ocean = {
        Bg = Color3.fromRGB(8, 12, 18),
        Panel = Color3.fromRGB(12, 18, 28),
        Card = Color3.fromRGB(16, 26, 40),
        CardHover = Color3.fromRGB(22, 34, 52),
        Stroke = Color3.fromRGB(40, 60, 90),
        Text = Color3.fromRGB(230, 240, 255),
        Muted = Color3.fromRGB(120, 150, 180),
        Accent = Color3.fromRGB(64, 180, 255),
        AccentDim = Color3.fromRGB(30, 90, 140),
        Danger = Color3.fromRGB(235, 78, 92),
        Warn = Color3.fromRGB(255, 186, 73),
        Success = Color3.fromRGB(80, 220, 140),
        Track = Color3.fromRGB(28, 40, 55),
    },
    Amber = {
        Bg = Color3.fromRGB(14, 12, 8),
        Panel = Color3.fromRGB(22, 18, 12),
        Card = Color3.fromRGB(32, 26, 16),
        CardHover = Color3.fromRGB(42, 34, 22),
        Stroke = Color3.fromRGB(70, 55, 30),
        Text = Color3.fromRGB(255, 245, 230),
        Muted = Color3.fromRGB(170, 150, 120),
        Accent = Color3.fromRGB(255, 186, 73),
        AccentDim = Color3.fromRGB(140, 90, 30),
        Danger = Color3.fromRGB(235, 78, 92),
        Warn = Color3.fromRGB(255, 210, 100),
        Success = Color3.fromRGB(80, 220, 140),
        Track = Color3.fromRGB(45, 38, 25),
    },
    Midnight = {
        Bg = Color3.fromRGB(6, 6, 8),
        Panel = Color3.fromRGB(12, 12, 16),
        Card = Color3.fromRGB(18, 18, 24),
        CardHover = Color3.fromRGB(26, 26, 34),
        Stroke = Color3.fromRGB(48, 48, 58),
        Text = Color3.fromRGB(230, 230, 235),
        Muted = Color3.fromRGB(120, 120, 130),
        Accent = Color3.fromRGB(220, 220, 230),
        AccentDim = Color3.fromRGB(80, 80, 95),
        Danger = Color3.fromRGB(235, 78, 92),
        Warn = Color3.fromRGB(255, 186, 73),
        Success = Color3.fromRGB(80, 220, 140),
        Track = Color3.fromRGB(30, 30, 38),
    },
}

--------------------------------------------------------------------
-- Utils
--------------------------------------------------------------------
local function getUiParent()
    local parent
    pcall(function()
        if typeof(gethui) == "function" then
            parent = gethui()
        end
    end)
    if parent then return parent end
    pcall(function()
        if syn and syn.protect_gui then
            local folder = Instance.new("Folder")
            syn.protect_gui(folder)
            folder.Parent = CoreGui
            parent = folder
        end
    end)
    if parent then return parent end
    local ok = pcall(function()
        parent = CoreGui
    end)
    if ok and parent then return parent end
    return PlayerGui
end

local function uiFont(weight)
    local names = {
        Medium = { "GothamMedium", "Gotham" },
        Bold = { "GothamBold", "Gotham" },
        Regular = { "Gotham", "SourceSans" },
    }
    for _, name in ipairs(names[weight] or names.Regular) do
        local ok, font = pcall(function()
            return Enum.Font[name]
        end)
        if ok and font then
            return font
        end
    end
    return Enum.Font.Gotham
end

local function make(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        local ok = pcall(function()
            obj[k] = v
        end)
        if not ok then
            warn("[YugenUI] skipped property " .. tostring(k) .. " on " .. tostring(class))
        end
    end
    return obj
end

local function bindPageCanvas(scroll, layout)
    local function refresh()
        local h = layout.AbsoluteContentSize.Y
        if h < 1 then
            h = 1
        end
        scroll.CanvasSize = UDim2.fromOffset(0, h + 16)
    end
    pcall(function()
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(refresh)
    end)
    deferCall(refresh)
    return refresh
end

local function corner(parent, radius)
    return make("UICorner", { CornerRadius = UDim.new(0, radius or 8), Parent = parent })
end

local function stroke(parent, color, thickness, transparency)
    local s = make("UIStroke", {
        Color = color or Theme.Stroke,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        Parent = parent,
    })
    pcall(function()
        local mode = enumItem("ApplyStrokeMode", "Border")
        if mode then
            s.ApplyStrokeMode = mode
        end
    end)
    return s
end

local function pad(parent, t, r, b, l)
    return make("UIPadding", {
        PaddingTop = UDim.new(0, t or 0),
        PaddingRight = UDim.new(0, r or t or 0),
        PaddingBottom = UDim.new(0, b or t or 0),
        PaddingLeft = UDim.new(0, l or r or t or 0),
        Parent = parent,
    })
end

local function listLayout(parent, spacing, fill)
    return make("UIListLayout", {
        FillDirection = fill or Enum.FillDirection.Vertical,
        Padding = UDim.new(0, spacing or 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = parent,
    })
end

local function tween(obj, props, duration)
    local t = TweenService:Create(
        obj,
        TweenInfo.new(duration or 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        props
    )
    t:Play()
    return t
end

local painted = {}

local function resolveThemeName(name)
    if type(name) == "table" then
        name = name.id or name.label or name.Name or name[1]
    end
    if type(name) ~= "string" or name == "" then
        return nil
    end
    if ThemePresets[name] then
        return name
    end
    local lower = string.lower(name)
    for k in pairs(ThemePresets) do
        if string.lower(k) == lower then
            return k
        end
    end
    return nil
end

local function applyTheme(name)
    name = resolveThemeName(name)
    local preset = name and ThemePresets[name]
    if not preset then
        return false
    end
    YugenUI.ThemeName = name
    for k, v in pairs(preset) do
        Theme[k] = v
    end
    return true
end

local function paint(obj, prop, token)
    if not obj or not prop or not token then
        return obj
    end
    pcall(function()
        obj:SetAttribute("YugenPaint", token)
        obj:SetAttribute("YugenPaintProp", prop)
    end)
    local found = false
    for i = 1, #painted do
        local e = painted[i]
        if e[1] == obj and e[2] == prop then
            e[3] = token
            found = true
            break
        end
    end
    if not found then
        painted[#painted + 1] = { obj, prop, token }
    end
    local color = Theme[token]
    if color ~= nil then
        pcall(function()
            obj[prop] = color
        end)
    end
    return obj
end

local function restyle()
    local i = 1
    while i <= #painted do
        local e = painted[i]
        local inst, prop, token = e[1], e[2], e[3]
        local alive = false
        pcall(function()
            alive = inst ~= nil and inst.Parent ~= nil
        end)
        if not alive then
            table.remove(painted, i)
        else
            local color = Theme[token]
            if color ~= nil then
                pcall(function()
                    inst[prop] = color
                end)
            end
            i = i + 1
        end
    end
end

local ICONS = {
    player = "+",
    combat = "*",
    eye = "o",
    settings = "=",
    fling = "~",
    misc = "#",
    home = ">",
}

local function resolveIcon(icon)
    if not icon or icon == "" then
        return ">"
    end
    return ICONS[string.lower(tostring(icon))] or tostring(icon)
end

local function colorToHex(c)
    return string.format(
        "#%02X%02X%02X",
        math.clamp(math.floor(c.R * 255 + 0.5), 0, 255),
        math.clamp(math.floor(c.G * 255 + 0.5), 0, 255),
        math.clamp(math.floor(c.B * 255 + 0.5), 0, 255)
    )
end

local function hexToColor(hex)
    if type(hex) ~= "string" then return nil end
    hex = hex:gsub("%s+", ""):gsub("^#", "")
    if #hex == 3 then
        hex = hex:sub(1, 1):rep(2) .. hex:sub(2, 2):rep(2) .. hex:sub(3, 3):rep(2)
    end
    if #hex ~= 6 then return nil end
    local r, g, b = tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
    if not r then return nil end
    return Color3.fromRGB(r, g, b)
end

local COLOR_PRESETS = {
    Color3.fromRGB(56, 214, 186),
    Color3.fromRGB(255, 255, 255),
    Color3.fromRGB(255, 80, 80),
    Color3.fromRGB(80, 150, 255),
    Color3.fromRGB(255, 186, 73),
    Color3.fromRGB(168, 120, 255),
    Color3.fromRGB(80, 220, 140),
    Color3.fromRGB(255, 120, 200),
}

local activeDropdownClose
local activeColorClose
local dropdownIgnoreUntil = 0
local function ensureToastGui()
    if toastGui and toastGui.Parent then return toastGui end
    toastGui = make("ScreenGui", {
        Name = "YugenUI_Toasts",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 9999,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = getUiParent(),
    })
    local folder = make("Frame", {
        Name = "Stack",
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(300, 420),
        Position = UDim2.new(1, -316, 0, 16),
        Parent = toastGui,
    })
    listLayout(folder, 8)
    return toastGui
end

function YugenUI:Notify(title, text, duration)
    local sub
    if type(title) == "table" then
        local cfg = title
        title = cfg.Title or cfg.Name or "Yugen"
        sub = cfg.SubContent
        text = cfg.Content or cfg.Text or text
        duration = cfg.Duration
        if duration == nil then
            duration = 3
        end
    else
        duration = duration or 3
    end
    local gui = ensureToastGui()
    local stack = gui:FindFirstChild("Stack")
    local h = (sub and sub ~= "") and 72 or 56
    local toast = make("Frame", {
        Size = UDim2.new(1, 0, 0, h),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
        Parent = stack,
    })
    paint(toast, "BackgroundColor3", "Card")
    corner(toast, 10)
    local st = stroke(toast, Theme.Accent, 1, 0.35)
    paint(st, "Color", "Accent")
    local bar = make("Frame", {
        Size = UDim2.fromOffset(3, h),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = toast,
    })
    paint(bar, "BackgroundColor3", "Accent")
    make("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 8),
        Size = UDim2.new(1, -24, 0, 18),
        Font = Enum.Font.GothamBold,
        Text = title or "Yugen",
        TextSize = 13,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = toast,
    })
    make("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 28),
        Size = UDim2.new(1, -24, 0, 18),
        Font = Enum.Font.Gotham,
        Text = text or "",
        TextSize = 12,
        TextColor3 = Theme.Muted,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = toast,
    })
    if sub and sub ~= "" then
        make("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(14, 46),
            Size = UDim2.new(1, -24, 0, 18),
            Font = Enum.Font.Gotham,
            Text = sub,
            TextSize = 11,
            TextColor3 = Theme.Muted,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = toast,
        })
    end
    if duration and duration > 0 then
        delayCall(duration, function()
            if toast.Parent then
                tween(toast, { BackgroundTransparency = 1 }, 0.18)
                delayCall(0.2, function()
                    if toast.Parent then toast:Destroy() end
                end)
            end
        end)
    end
    return toast
end

--------------------------------------------------------------------
-- Controls (attached to a page ScrollingFrame)
--------------------------------------------------------------------
local function makeCard(parent, height)
    local c = make("Frame", {
        Size = UDim2.new(1, 0, 0, height or 44),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
        Parent = parent,
    })
    paint(c, "BackgroundColor3", "Card")
    corner(c, 10)
    local st = stroke(c, Theme.Stroke, 1, 0.45)
    paint(st, "Color", "Stroke")
    c.MouseEnter:Connect(function()
        tween(c, { BackgroundColor3 = Theme.CardHover }, 0.12)
    end)
    c.MouseLeave:Connect(function()
        tween(c, { BackgroundColor3 = Theme.Card }, 0.12)
    end)
    return c
end

local function cardHeight(opts, base)
    if opts and opts.Description and opts.Description ~= "" then
        return (base or 44) + 14
    end
    return base or 44
end

local function addNameBlock(frame, opts, rightPad)
    local hasDesc = opts.Description and opts.Description ~= ""
    local title = make("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, hasDesc and 6 or 0),
        Size = UDim2.new(1, -(rightPad or 80), hasDesc and 0 or 1, hasDesc and 16 or 0),
        Font = uiFont("Medium"),
        Text = opts.Name or opts.Title or "",
        TextSize = 13,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
    })
    paint(title, "TextColor3", "Text")
    if hasDesc then
        local desc = make("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(14, 22),
            Size = UDim2.new(1, -(rightPad or 80), 0, 16),
            Font = uiFont("Regular"),
            Text = opts.Description,
            TextSize = 11,
            TextColor3 = Theme.Muted,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame,
        })
        paint(desc, "TextColor3", "Muted")
    end
    return title
end

local function bindSearch(frame, opts)
    local label = string.lower(tostring(opts.Name or opts.Title or ""))
    pcall(function()
        frame:SetAttribute("YugenSearch", label)
    end)
end

local function makeFlag(opts, get, set, extra)
    extra = extra or {}
    extra.Get = get
    extra.Set = function(v, fire)
        return set(v, fire ~= false)
    end
    extra.OnChanged = function(fn)
        extra._onChanged = fn
    end
    extra.Value = extra.Value
    extra.Flag = opts.Flag or opts.Idx
    extra.Title = opts.Name or opts.Title
    local origSet = extra.Set
    extra.Set = function(v, fire)
        origSet(v, fire)
        extra.Value = extra.Get()
        if extra._onChanged then
            pcall(extra._onChanged, extra.Value)
        end
    end
    extra.SetValue = extra.Set
    extra.GetValue = extra.Get
    local flag = extra.Flag
    if type(flag) == "string" and flag ~= "" then
        YugenUI.Options[flag] = extra
    end
    return extra
end

local function addSection(page, title)
    local lab = make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = string.upper(title or "Section"),
        TextSize = 11,
        TextColor3 = Theme.Accent,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = page,
    })
    paint(lab, "TextColor3", "Accent")
    bindSearch(lab, { Name = title })
    return lab
end

local function addLabel(page, text)
    local lab = make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = text or "",
        TextSize = 12,
        TextColor3 = Theme.Muted,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = page,
    })
    paint(lab, "TextColor3", "Muted")
    bindSearch(lab, { Name = text })
    return lab
end

local function addParagraph(page, opts)
    opts = opts or {}
    local frame = makeCard(page, 72)
    bindSearch(frame, opts)
    local titleL = make("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 8),
        Size = UDim2.new(1, -28, 0, 16),
        Font = uiFont("Bold"),
        Text = opts.Title or opts.Name or "Info",
        TextSize = 13,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
    })
    paint(titleL, "TextColor3", "Text")
    local bodyL = make("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 28),
        Size = UDim2.new(1, -28, 0, 36),
        Font = uiFont("Regular"),
        Text = opts.Content or opts.Description or "",
        TextSize = 12,
        TextColor3 = Theme.Muted,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        Parent = frame,
    })
    paint(bodyL, "TextColor3", "Muted")
    return frame
end

local function addInput(page, opts)
    opts = opts or {}
    local frame = makeCard(page, cardHeight(opts, 44))
    bindSearch(frame, opts)
    addNameBlock(frame, opts, 170)
    local value = tostring(opts.Default or "")
    local box = make("TextBox", {
        Size = UDim2.fromOffset(148, 28),
        Position = UDim2.new(1, -162, 0.5, -14),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        Font = uiFont("Bold"),
        Text = value,
        PlaceholderText = opts.Placeholder or "",
        TextColor3 = Theme.Accent,
        TextSize = 12,
        ClearTextOnFocus = false,
        Parent = frame,
    })
    paint(box, "BackgroundColor3", "Panel")
    paint(box, "TextColor3", "Accent")
    corner(box, 8)
    stroke(box, Theme.AccentDim, 1, 0.35)
    local function emit()
        local t = box.Text
        if opts.Numeric then
            t = tonumber(t) or 0
        end
        value = t
        if opts.Callback then
            pcall(opts.Callback, t)
        end
    end
    box.FocusLost:Connect(function()
        emit()
    end)
    if not opts.Finished then
        box:GetPropertyChangedSignal("Text"):Connect(function()
            if opts.Numeric and box.Text ~= "" and not tonumber(box.Text) then
                return
            end
        end)
    end
    local api
    api = makeFlag(opts, function()
        return value
    end, function(v)
        box.Text = tostring(v)
        value = opts.Numeric and (tonumber(v) or 0) or tostring(v)
        if opts.Callback then
            pcall(opts.Callback, value)
        end
    end)
    api.Value = value
    return api
end

local function addToggle(page, opts)
    opts = opts or {}
    local frame = makeCard(page, cardHeight(opts, 44))
    bindSearch(frame, opts)
    addNameBlock(frame, opts, 80)
    local track = make("TextButton", {
        Size = UDim2.fromOffset(42, 24),
        Position = UDim2.new(1, -56, 0.5, -12),
        BackgroundColor3 = opts.Default and Theme.Accent or Theme.Track,
        Text = "",
        AutoButtonColor = false,
        Parent = frame,
    })
    corner(track, 12)
    local knob = make("Frame", {
        Size = UDim2.fromOffset(18, 18),
        Position = opts.Default and UDim2.fromOffset(21, 3) or UDim2.fromOffset(3, 3),
        BackgroundColor3 = Theme.Text,
        BorderSizePixel = 0,
        Parent = track,
    })
    paint(knob, "BackgroundColor3", "Text")
    corner(knob, 9)
    local state = not not opts.Default
    local function set(v, fire)
        state = not not v
        track.BackgroundColor3 = state and Theme.Accent or Theme.Track
        paint(track, "BackgroundColor3", state and "Accent" or "Track")
        tween(knob, { Position = state and UDim2.fromOffset(21, 3) or UDim2.fromOffset(3, 3) }, 0.15)
        if fire ~= false and opts.Callback then
            pcall(opts.Callback, state)
        end
    end
    paint(track, "BackgroundColor3", state and "Accent" or "Track")
    track.MouseButton1Click:Connect(function()
        set(not state, true)
    end)
    local api = makeFlag(opts, function()
        return state
    end, set)
    api.Value = state
    return api
end

local function addToggleKeybind(page, opts)
    opts = opts or {}
    local frame = makeCard(page, cardHeight(opts, 44))
    bindSearch(frame, opts)
    addNameBlock(frame, opts, 160)
    local currentKey = opts.DefaultKey or Enum.KeyCode.Unknown
    local keyBtn = make("TextButton", {
        Size = UDim2.fromOffset(72, 26),
        Position = UDim2.new(1, -130, 0.5, -13),
        BackgroundColor3 = Theme.Panel,
        Text = currentKey.Name,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = Theme.Accent,
        AutoButtonColor = false,
        Parent = frame,
    })
    paint(keyBtn, "BackgroundColor3", "Panel")
    paint(keyBtn, "TextColor3", "Accent")
    corner(keyBtn, 8)
    stroke(keyBtn, Theme.AccentDim, 1, 0.35)
    local track = make("TextButton", {
        Size = UDim2.fromOffset(42, 24),
        Position = UDim2.new(1, -52, 0.5, -12),
        BackgroundColor3 = opts.Default and Theme.Accent or Theme.Track,
        Text = "",
        AutoButtonColor = false,
        Parent = frame,
    })
    corner(track, 12)
    local knob = make("Frame", {
        Size = UDim2.fromOffset(18, 18),
        Position = opts.Default and UDim2.fromOffset(21, 3) or UDim2.fromOffset(3, 3),
        BackgroundColor3 = Theme.Text,
        BorderSizePixel = 0,
        Parent = track,
    })
    paint(knob, "BackgroundColor3", "Text")
    corner(knob, 9)
    local state = not not opts.Default
    local function set(v, fire)
        state = not not v
        paint(track, "BackgroundColor3", state and "Accent" or "Track")
        tween(knob, { Position = state and UDim2.fromOffset(21, 3) or UDim2.fromOffset(3, 3) }, 0.15)
        if fire ~= false and opts.Callback then
            pcall(opts.Callback, state)
        end
    end
    paint(track, "BackgroundColor3", state and "Accent" or "Track")
    local listening, conn
    keyBtn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        keyBtn.Text = "…"
        conn = UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.KeyCode == Enum.KeyCode.Escape then
                keyBtn.Text = currentKey.Name
                listening = false
                if conn then conn:Disconnect() end
                return
            end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                currentKey = input.KeyCode
                keyBtn.Text = currentKey.Name
                listening = false
                if conn then conn:Disconnect() end
                if opts.OnKey then pcall(opts.OnKey, currentKey) end
            end
        end)
    end)
    track.MouseButton1Click:Connect(function()
        set(not state, true)
    end)
    local api = makeFlag(opts, function()
        return state
    end, set, {
        GetKey = function()
            return currentKey
        end,
        SetKey = function(k)
            if k then
                currentKey = k
                keyBtn.Text = k.Name
            end
        end,
    })
    api.Value = state
    return api
end

local function addSlider(page, opts)
    opts = opts or {}
    local min, max = opts.Min or 0, opts.Max or 100
    local decimals = opts.Decimals or 0
    local value = clamp(opts.Default or min, min, max)
    local frame = makeCard(page, cardHeight(opts, 62))
    bindSearch(frame, opts)
    addNameBlock(frame, opts, 90)
    local valueLabel = make("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -78, 0, 6),
        Size = UDim2.fromOffset(64, 18),
        Font = Enum.Font.GothamBold,
        Text = decimals > 0 and string.format("%." .. decimals .. "f", value) or tostring(math.floor(value + 0.5)),
        TextSize = 12,
        TextColor3 = Theme.Accent,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = frame,
    })
    paint(valueLabel, "TextColor3", "Accent")
    local bar = make("Frame", {
        Size = UDim2.new(1, -28, 0, 8),
        Position = UDim2.fromOffset(14, 36),
        BackgroundColor3 = Theme.Track,
        BorderSizePixel = 0,
        Parent = frame,
    })
    paint(bar, "BackgroundColor3", "Track")
    corner(bar, 4)
    local fill = make("Frame", {
        Size = UDim2.new((value - min) / math.max(max - min, 1e-6), 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = bar,
    })
    paint(fill, "BackgroundColor3", "Accent")
    corner(fill, 4)
    local handle = make("Frame", {
        Size = UDim2.fromOffset(14, 14),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new((value - min) / math.max(max - min, 1e-6), 0, 0.5, 0),
        BackgroundColor3 = Theme.Text,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = bar,
    })
    paint(handle, "BackgroundColor3", "Text")
    corner(handle, 7)
    local hit = make("TextButton", {
        Size = UDim2.new(1, 0, 0, 22),
        Position = UDim2.fromOffset(0, -7),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 3,
        Parent = bar,
    })
    local dragging = false
    local function set(v, fire)
        value = clamp(v, min, max)
        if decimals > 0 then
            local m = 10 ^ decimals
            value = math.floor(value * m + 0.5) / m
            valueLabel.Text = string.format("%." .. decimals .. "f", value)
        else
            value = math.floor(value + 0.5)
            valueLabel.Text = tostring(value)
        end
        local t = (value - min) / math.max(max - min, 1e-6)
        fill.Size = UDim2.new(t, 0, 1, 0)
        handle.Position = UDim2.new(t, 0, 0.5, 0)
        if fire ~= false and opts.Callback then
            pcall(opts.Callback, value)
        end
    end
    local function fromX(x)
        local a, w = bar.AbsolutePosition.X, math.max(bar.AbsoluteSize.X, 1)
        set(min + clamp((x - a) / w, 0, 1) * (max - min), true)
    end
    hit.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            fromX(input.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            fromX(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    local api = makeFlag(opts, function()
        return value
    end, set)
    api.Value = value
    return api
end

local function addDropdown(page, screenGui, opts)
    opts = opts or {}
    local multi = opts.Multi == true
    local options = {}
    for _, opt in ipairs(opts.Options or {}) do
        if typeof(opt) == "table" then
            table.insert(options, { id = opt.id or opt.value or opt.label, label = opt.label or tostring(opt.id) })
        else
            table.insert(options, { id = opt, label = tostring(opt) })
        end
    end
    local selected = options[1]
    local selectedSet = {}
    local function defaultIsOn(it)
        local d = opts.Default
        if type(d) == "table" then
            for _, x in ipairs(d) do
                if x == it.id or x == it.label then
                    return true
                end
            end
            return false
        end
        return it.id == d or it.label == d
    end
    for _, it in ipairs(options) do
        if defaultIsOn(it) then
            selected = it
            selectedSet[it.id] = true
        end
    end
    if multi and next(selectedSet) == nil and options[1] then
        -- leave empty until user picks
    end

    local frame = makeCard(page, cardHeight(opts, 44))
    bindSearch(frame, opts)
    addNameBlock(frame, opts, 150)
    local openBtn = make("TextButton", {
        Size = UDim2.fromOffset(128, 28),
        Position = UDim2.new(1, -142, 0.5, -14),
        BackgroundColor3 = Theme.Panel,
        Text = "",
        AutoButtonColor = false,
        Parent = frame,
    })
    paint(openBtn, "BackgroundColor3", "Panel")
    corner(openBtn, 8)
    stroke(openBtn, Theme.AccentDim, 1, 0.35)
    local function multiLabel()
        local labels = {}
        for _, it in ipairs(options) do
            if selectedSet[it.id] then
                table.insert(labels, it.label)
            end
        end
        if #labels == 0 then
            return "—"
        end
        if #labels > 2 then
            return tostring(#labels) .. " selected"
        end
        return table.concat(labels, ", ")
    end
    local openLabel = make("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(10, 0),
        Size = UDim2.new(1, -28, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = multi and multiLabel() or (selected and selected.label or "—"),
        TextSize = 11,
        TextColor3 = Theme.Accent,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = openBtn,
    })
    paint(openLabel, "TextColor3", "Accent")
    make("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -18, 0, 0),
        Size = UDim2.fromOffset(14, 28),
        Font = Enum.Font.GothamBold,
        Text = "▾",
        TextSize = 11,
        TextColor3 = Theme.Muted,
        Parent = openBtn,
    })

    local drop = make("Frame", {
        Size = UDim2.fromOffset(128, 0),
        BackgroundColor3 = Theme.Bg,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 80,
        ClipsDescendants = true,
        Parent = screenGui,
    })
    paint(drop, "BackgroundColor3", "Bg")
    corner(drop, 10)
    stroke(drop, Theme.Stroke, 1, 0.2)
    local dropList = make("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(),
        ZIndex = 81,
        Parent = drop,
    })
    paint(dropList, "ScrollBarImageColor3", "Accent")
    pcall(function()
        local autoY = enumItem("AutomaticSize", "Y")
        if autoY then
            dropList.AutomaticCanvasSize = autoY
        end
    end)
    pad(dropList, 4, 4, 4, 4)
    listLayout(dropList, 3)

    local function close()
        drop.Visible = false
        if activeDropdownClose == close then
            activeDropdownClose = nil
        end
    end
    local function open()
        if activeDropdownClose and activeDropdownClose ~= close then
            activeDropdownClose()
        end
        local abs, size = openBtn.AbsolutePosition, openBtn.AbsoluteSize
        -- ScreenGui has no AbsolutePosition. Its children use viewport
        -- coordinates, so the button's absolute position is already correct.
        drop.Position = UDim2.fromOffset(abs.X, abs.Y + size.Y + 4)
        drop.Size = UDim2.fromOffset(math.max(size.X, 128), math.min(28 + #options * 30, 160))
        drop.Visible = true
        activeDropdownClose = close
        dropdownIgnoreUntil = tick() + 0.2
    end

    local function emit()
        if multi then
            local ids = {}
            for _, it in ipairs(options) do
                if selectedSet[it.id] then
                    table.insert(ids, it.id)
                end
            end
            if opts.Callback then
                pcall(opts.Callback, ids)
            end
        else
            if opts.Callback and selected then
                pcall(opts.Callback, selected.id, selected)
            end
        end
    end

    local function refreshRows()
        for _, child in ipairs(dropList:GetChildren()) do
            if child:IsA("TextButton") then
                local mark = child:FindFirstChild("Mark")
                local id = child:GetAttribute("YugenOptId")
                if mark then
                    local on = (not multi and selected and selected.id == id) or (multi and selectedSet[id])
                    mark.Text = on and "●" or "○"
                end
            end
        end
    end

    for _, it in ipairs(options) do
        local row = make("TextButton", {
            Size = UDim2.new(1, 0, 0, 26),
            BackgroundColor3 = Theme.Card,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 82,
            Parent = dropList,
        })
        paint(row, "BackgroundColor3", "Card")
        pcall(function()
            row:SetAttribute("YugenOptId", it.id)
        end)
        corner(row, 6)
        local mark = make("TextLabel", {
            Name = "Mark",
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(6, 0),
            Size = UDim2.fromOffset(16, 26),
            Font = Enum.Font.GothamBold,
            Text = ((multi and selectedSet[it.id]) or (not multi and selected and selected.id == it.id)) and "●" or "○",
            TextSize = 11,
            TextColor3 = Theme.Accent,
            ZIndex = 83,
            Parent = row,
        })
        paint(mark, "TextColor3", "Accent")
        make("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(24, 0),
            Size = UDim2.new(1, -28, 1, 0),
            Font = uiFont("Medium"),
            Text = it.label,
            TextSize = 12,
            TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 83,
            Parent = row,
        })
        row.MouseButton1Click:Connect(function()
            if multi then
                selectedSet[it.id] = not selectedSet[it.id]
                openLabel.Text = multiLabel()
                refreshRows()
                emit()
            else
                selected = it
                openLabel.Text = it.label
                refreshRows()
                close()
                emit()
            end
        end)
        row.MouseEnter:Connect(function()
            tween(row, { BackgroundColor3 = Theme.AccentDim }, 0.1)
        end)
        row.MouseLeave:Connect(function()
            tween(row, { BackgroundColor3 = Theme.Card }, 0.1)
        end)
    end

    openBtn.MouseButton1Click:Connect(function()
        if drop.Visible then close() else open() end
    end)

    local function getValue()
        if multi then
            local ids = {}
            for _, it in ipairs(options) do
                if selectedSet[it.id] then
                    table.insert(ids, it.id)
                end
            end
            return ids
        end
        return selected and selected.id
    end
    local function setValue(id, fire)
        if multi then
            selectedSet = {}
            local list = type(id) == "table" and id or { id }
            for _, x in ipairs(list) do
                selectedSet[x] = true
            end
            openLabel.Text = multiLabel()
            refreshRows()
            if fire ~= false then
                emit()
            end
            return
        end
        for _, it in ipairs(options) do
            if it.id == id or it.label == id then
                selected = it
                openLabel.Text = it.label
                refreshRows()
                if fire ~= false then
                    emit()
                end
                break
            end
        end
    end
    local api = makeFlag(opts, getValue, setValue)
    api.Value = getValue()
    return api
end

local function addThemeGallery(page, apply)
    local card = makeCard(page, 176)
    bindSearch(card, { Name = "Theme appearance" })
    local title = make("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 8),
        Size = UDim2.new(1, -28, 0, 18),
        Font = uiFont("Medium"),
        Text = "Theme",
        TextSize = 13,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card,
    })
    paint(title, "TextColor3", "Text")
    local subtitle = make("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 26),
        Size = UDim2.new(1, -28, 0, 16),
        Font = uiFont("Regular"),
        Text = "Choose a palette. Changes apply immediately.",
        TextSize = 11,
        TextColor3 = Theme.Muted,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card,
    })
    paint(subtitle, "TextColor3", "Muted")

    local grid = make("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(12, 50),
        Size = UDim2.new(1, -24, 1, -62),
        Parent = card,
    })
    local layout = make("UIGridLayout", {
        CellSize = UDim2.new(1 / 3, -5, 0, 35),
        CellPadding = UDim2.fromOffset(7, 7),
        FillDirectionMaxCells = 3,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = grid,
    })
    local buttons = {}
    local function refresh()
        for name, item in pairs(buttons) do
            local preset = ThemePresets[name]
            local active = name == YugenUI.ThemeName
            item.Button.BackgroundColor3 = active and preset.AccentDim or preset.Card
            item.Stroke.Color = active and preset.Accent or preset.Stroke
            item.Mark.Visible = active
        end
    end
    for order, name in ipairs(YugenUI:GetThemes()) do
        local preset = ThemePresets[name]
        local button = make("TextButton", {
            LayoutOrder = order,
            BackgroundColor3 = preset.Card,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            Parent = grid,
        })
        corner(button, 7)
        local buttonStroke = stroke(button, preset.Stroke, 1, 0.2)
        local swatch = make("Frame", {
            Size = UDim2.fromOffset(8, 8),
            Position = UDim2.fromOffset(9, 13),
            BackgroundColor3 = preset.Accent,
            BorderSizePixel = 0,
            Parent = button,
        })
        corner(swatch, 4)
        local label = make("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(24, 0),
            Size = UDim2.new(1, -42, 1, 0),
            Font = uiFont("Medium"),
            Text = name,
            TextSize = 11,
            TextColor3 = preset.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = button,
        })
        local mark = make("TextLabel", {
            Size = UDim2.fromOffset(14, 14),
            Position = UDim2.new(1, -20, 0.5, -7),
            BackgroundTransparency = 1,
            Font = uiFont("Bold"),
            Text = "✓",
            TextSize = 12,
            TextColor3 = preset.Text,
            Visible = false,
            Parent = button,
        })
        buttons[name] = { Button = button, Stroke = buttonStroke, Mark = mark }
        button.MouseButton1Click:Connect(function()
            if apply(name) then
                refresh()
            end
        end)
    end
    refresh()
    return makeFlag({ Flag = "UI_Theme", Name = "Theme" }, function()
        return YugenUI.ThemeName
    end, function(value)
        local name = resolveThemeName(value)
        if name and apply(name) then
            refresh()
        end
    end)
end

local function addColorPicker(page, screenGui, opts)
    opts = opts or {}
    local current = opts.Default or Theme.Accent
    local h, s, v = Color3.toHSV(current)
    local frame = makeCard(page, cardHeight(opts, 44))
    bindSearch(frame, opts)
    addNameBlock(frame, opts, 170)
    local swatch = make("TextButton", {
        Size = UDim2.fromOffset(28, 28),
        Position = UDim2.new(1, -154, 0.5, -14),
        BackgroundColor3 = current,
        Text = "",
        AutoButtonColor = false,
        Parent = frame,
    })
    corner(swatch, 8)
    stroke(swatch, Theme.Stroke, 1, 0.25)
    local hexBox = make("TextBox", {
        Size = UDim2.fromOffset(88, 28),
        Position = UDim2.new(1, -118, 0.5, -14),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        Font = Enum.Font.Code,
        Text = colorToHex(current),
        TextColor3 = Theme.Accent,
        TextSize = 12,
        ClearTextOnFocus = false,
        Parent = frame,
    })
    corner(hexBox, 8)
    stroke(hexBox, Theme.AccentDim, 1, 0.35)

    local picker = make("Frame", {
        Size = UDim2.fromOffset(196, 236),
        BackgroundColor3 = Theme.Bg,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 90,
        ClipsDescendants = true,
        Parent = screenGui,
    })
    corner(picker, 12)
    stroke(picker, Theme.Stroke, 1, 0.15)

    make("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(12, 8),
        Size = UDim2.new(1, -24, 0, 16),
        Font = Enum.Font.GothamBold,
        Text = "Pick color",
        TextSize = 11,
        TextColor3 = Theme.Muted,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 91,
        Parent = picker,
    })

    local svBox = make("Frame", {
        Size = UDim2.fromOffset(168, 120),
        Position = UDim2.fromOffset(14, 30),
        BackgroundColor3 = Color3.fromHSV(h, 1, 1),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 91,
        Parent = picker,
    })
    corner(svBox, 8)
    local white = make("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 92,
        Parent = svBox,
    })
    make("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1),
        }),
        Parent = white,
    })
    local black = make("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BorderSizePixel = 0,
        ZIndex = 93,
        Parent = svBox,
    })
    make("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0),
        }),
        Rotation = 90,
        Parent = black,
    })
    local svCursor = make("Frame", {
        Size = UDim2.fromOffset(12, 12),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(s, 0, 1 - v, 0),
        BackgroundTransparency = 1,
        ZIndex = 94,
        Parent = svBox,
    })
    stroke(svCursor, Color3.new(1, 1, 1), 2, 0)
    corner(svCursor, 6)
    local svHit = make("TextButton", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 95,
        Parent = svBox,
    })

    local hueBar = make("Frame", {
        Size = UDim2.fromOffset(168, 14),
        Position = UDim2.fromOffset(14, 160),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 91,
        Parent = picker,
    })
    corner(hueBar, 7)
    make("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0)),
        }),
        Parent = hueBar,
    })
    local hueCursor = make("Frame", {
        Size = UDim2.fromOffset(6, 18),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(h, 0, 0.5, 0),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 92,
        Parent = hueBar,
    })
    corner(hueCursor, 3)
    local hueHit = make("TextButton", {
        Size = UDim2.new(1, 0, 1, 8),
        Position = UDim2.fromOffset(0, -4),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 93,
        Parent = hueBar,
    })

    local presetRow = make("Frame", {
        Size = UDim2.fromOffset(168, 22),
        Position = UDim2.fromOffset(14, 186),
        BackgroundTransparency = 1,
        ZIndex = 91,
        Parent = picker,
    })
    listLayout(presetRow, 4, Enum.FillDirection.Horizontal)
    local preview = make("Frame", {
        Size = UDim2.fromOffset(168, 16),
        Position = UDim2.fromOffset(14, 214),
        BackgroundColor3 = current,
        BorderSizePixel = 0,
        ZIndex = 91,
        Parent = picker,
    })
    corner(preview, 6)

    local function sync(fire, skipHex)
        current = Color3.fromHSV(h, s, v)
        swatch.BackgroundColor3 = current
        preview.BackgroundColor3 = current
        svBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        svCursor.Position = UDim2.new(s, 0, 1 - v, 0)
        hueCursor.Position = UDim2.new(h, 0, 0.5, 0)
        if not skipHex then hexBox.Text = colorToHex(current) end
        if fire ~= false and opts.Callback then pcall(opts.Callback, current) end
    end

    local function setColor(c, fire, skipHex)
        if typeof(c) ~= "Color3" then return end
        current = c
        h, s, v = Color3.toHSV(c)
        sync(fire, skipHex)
    end

    local function close()
        picker.Visible = false
        if activeColorClose == close then activeColorClose = nil end
    end
    local function open()
        if activeColorClose and activeColorClose ~= close then activeColorClose() end
        if activeDropdownClose then activeDropdownClose() end
        h, s, v = Color3.toHSV(current)
        sync(false, true)
        local abs, size = swatch.AbsolutePosition, swatch.AbsoluteSize
        local camera = Workspace.CurrentCamera
        local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
        local x = math.clamp(abs.X - 80, 8, math.max(8, viewport.X - 204))
        local y = math.clamp(abs.Y + size.Y + 6, 8, math.max(8, viewport.Y - 244))
        picker.Position = UDim2.fromOffset(x, y)
        picker.Visible = true
        activeColorClose = close
        dropdownIgnoreUntil = tick() + 0.2
    end

    local dragSV, dragHue = false, false
    svHit.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragSV = true
            local a, sz = svBox.AbsolutePosition, svBox.AbsoluteSize
            s = math.clamp((input.Position.X - a.X) / math.max(sz.X, 1), 0, 1)
            v = 1 - math.clamp((input.Position.Y - a.Y) / math.max(sz.Y, 1), 0, 1)
            sync(true)
        end
    end)
    hueHit.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragHue = true
            local a, w = hueBar.AbsolutePosition.X, math.max(hueBar.AbsoluteSize.X, 1)
            h = math.clamp((input.Position.X - a) / w, 0, 1)
            sync(true)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not picker.Visible then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
        if dragSV then
            local a, sz = svBox.AbsolutePosition, svBox.AbsoluteSize
            s = math.clamp((input.Position.X - a.X) / math.max(sz.X, 1), 0, 1)
            v = 1 - math.clamp((input.Position.Y - a.Y) / math.max(sz.Y, 1), 0, 1)
            sync(true)
        elseif dragHue then
            local a, w = hueBar.AbsolutePosition.X, math.max(hueBar.AbsoluteSize.X, 1)
            h = math.clamp((input.Position.X - a) / w, 0, 1)
            sync(true)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragSV, dragHue = false, false
        end
    end)

    for _, preset in ipairs(COLOR_PRESETS) do
        local chip = make("TextButton", {
            Size = UDim2.fromOffset(18, 18),
            BackgroundColor3 = preset,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 92,
            Parent = presetRow,
        })
        corner(chip, 5)
        chip.MouseButton1Click:Connect(function()
            setColor(preset, true)
        end)
    end

    swatch.MouseButton1Click:Connect(function()
        if picker.Visible then close() else open() end
    end)
    hexBox.FocusLost:Connect(function()
        local parsed = hexToColor(hexBox.Text)
        if parsed then setColor(parsed, true) else hexBox.Text = colorToHex(current) end
    end)

    UserInputService.InputBegan:Connect(function(input)
        if not picker.Visible then return end
        if tick() < dropdownIgnoreUntil then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local p = Vector2.new(input.Position.X, input.Position.Y)
        local function inside(gui)
            if not gui or not gui.Parent then return false end
            local a, sz = gui.AbsolutePosition, gui.AbsoluteSize
            return p.X >= a.X and p.X <= a.X + sz.X and p.Y >= a.Y and p.Y <= a.Y + sz.Y
        end
        if inside(picker) or inside(swatch) or inside(hexBox) then return end
        close()
    end)

    local api = makeFlag(opts, function()
        return current
    end, function(c, fire)
        setColor(c, fire)
    end)
    api.Value = current
    return api
end

local function addKeybind(page, opts)
    opts = opts or {}
    local current = opts.Default or Enum.KeyCode.E
    local mode = opts.Mode or "Toggle"
    if mode ~= "Always" and mode ~= "Hold" and mode ~= "Toggle" then
        mode = "Toggle"
    end
    local held = false
    local toggled = false
    local frame = makeCard(page, cardHeight(opts, 44))
    bindSearch(frame, opts)
    addNameBlock(frame, opts, 170)
    local modeBtn = make("TextButton", {
        Size = UDim2.fromOffset(52, 28),
        Position = UDim2.new(1, -162, 0.5, -14),
        BackgroundColor3 = Theme.Panel,
        Text = mode,
        Font = Enum.Font.GothamBold,
        TextSize = 9,
        TextColor3 = Theme.Muted,
        AutoButtonColor = false,
        Parent = frame,
    })
    paint(modeBtn, "BackgroundColor3", "Panel")
    paint(modeBtn, "TextColor3", "Muted")
    corner(modeBtn, 8)
    local button = make("TextButton", {
        Size = UDim2.fromOffset(72, 28),
        Position = UDim2.new(1, -104, 0.5, -14),
        BackgroundColor3 = Theme.Panel,
        Text = current.Name,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = Theme.Accent,
        AutoButtonColor = false,
        Parent = frame,
    })
    paint(button, "BackgroundColor3", "Panel")
    paint(button, "TextColor3", "Accent")
    corner(button, 8)
    stroke(button, Theme.AccentDim, 1, 0.35)
    local function getState()
        if mode == "Always" then
            return true
        end
        if mode == "Hold" then
            return held
        end
        return toggled
    end
    local function cycleMode()
        if mode == "Toggle" then
            mode = "Hold"
        elseif mode == "Hold" then
            mode = "Always"
        else
            mode = "Toggle"
        end
        modeBtn.Text = mode
        toggled = false
        held = false
    end
    modeBtn.MouseButton1Click:Connect(cycleMode)
    local listening, conn
    button.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        button.Text = "…"
        conn = UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.KeyCode == Enum.KeyCode.Escape then
                button.Text = current.Name
                listening = false
                if conn then conn:Disconnect() end
                return
            end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                current = input.KeyCode
                button.Text = current.Name
                listening = false
                if conn then conn:Disconnect() end
                if opts.Callback then pcall(opts.Callback, current) end
            end
        end)
    end)
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or listening then return end
        if input.KeyCode ~= current then return end
        if mode == "Hold" then
            held = true
        elseif mode == "Toggle" then
            toggled = not toggled
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == current then
            held = false
        end
    end)
    local api = makeFlag(opts, function()
        return current
    end, function(k, fire)
        if k then
            current = k
            button.Text = k.Name
            if fire ~= false and opts.Callback then
                pcall(opts.Callback, current)
            end
        end
    end, {
        GetState = getState,
        SetMode = function(m)
            if m == "Always" or m == "Hold" or m == "Toggle" then
                mode = m
                modeBtn.Text = mode
            end
        end,
        GetMode = function()
            return mode
        end,
    })
    api.Value = current
    return api
end

local function addButton(page, opts)
    opts = opts or {}
    local btn = make("TextButton", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = opts.Danger and Theme.Danger or Theme.Card,
        Text = opts.Name or "Button",
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = Theme.Text,
        AutoButtonColor = false,
        Parent = page,
    })
    bindSearch(btn, opts)
    paint(btn, "BackgroundColor3", opts.Danger and "Danger" or "Card")
    paint(btn, "TextColor3", "Text")
    corner(btn, 10)
    stroke(btn, opts.Danger and Theme.Danger or Theme.Stroke, 1, opts.Danger and 0.2 or 0.4)
    btn.MouseEnter:Connect(function()
        tween(btn, {
            BackgroundColor3 = opts.Danger and Color3.fromRGB(255, 100, 110) or Theme.CardHover,
        }, 0.12)
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, {
            BackgroundColor3 = opts.Danger and Theme.Danger or Theme.Card,
        }, 0.12)
    end)
    btn.MouseButton1Click:Connect(function()
        if opts.Callback then pcall(opts.Callback) end
    end)
    local api = makeFlag(opts, function()
        return true
    end, function()
        if opts.Callback then pcall(opts.Callback) end
    end)
    api.Instance = btn
    return api
end

--------------------------------------------------------------------
-- Outside click for dropdowns
--------------------------------------------------------------------
UserInputService.InputBegan:Connect(function(input)
    if not activeDropdownClose then return end
    if tick() < dropdownIgnoreUntil then return end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end
    activeDropdownClose()
end)

--------------------------------------------------------------------
-- Window
--------------------------------------------------------------------
function YugenUI:CreateWindow(config)
    config = config or {}
    -- Fluent-style aliases make the window easier to configure without changing
    -- the existing Yugen call sites.
    config.Name = config.Name or config.Title
    config.Subtitle = config.Subtitle or config.SubTitle
    config.ToggleKey = config.ToggleKey or config.MinimizeKey
    if config.Theme then
        applyTheme(config.Theme)
    end

    local screenGui = make("ScreenGui", {
        Name = "YugenUI_" .. tostring(config.Name or "Window"):gsub("%s+", ""),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = config.DisplayOrder or 1200,
        IgnoreGuiInset = true,
        Parent = getUiParent(),
    })

    local requestedSize = config.Size
    local width = config.Width or (requestedSize and requestedSize.X.Offset) or 560
    local height = config.Height or (requestedSize and requestedSize.Y.Offset) or 400

    local main = make("Frame", {
        Size = UDim2.fromOffset(width, height),
        Position = UDim2.new(0.5, -width / 2, 0.5, -height / 2),
        BackgroundColor3 = Theme.Bg,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = screenGui,
    })
    paint(main, "BackgroundColor3", "Bg")
    corner(main, 9)
    local mainStroke = stroke(main, Theme.Stroke, 1, 0.35)
    paint(mainStroke, "Color", "Stroke")

    local titleBar = make("Frame", {
        Size = UDim2.new(1, 0, 0, 52),
        BackgroundTransparency = 1,
        Parent = main,
    })

    local brandDot = make("Frame", {
        Size = UDim2.fromOffset(24, 24),
        Position = UDim2.fromOffset(16, 14),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = titleBar,
    })
    paint(brandDot, "BackgroundColor3", "Accent")
    corner(brandDot, 7)

    local brandMark = make("TextLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Font = uiFont("Bold"),
        Text = "Y",
        TextSize = 13,
        TextColor3 = Theme.Text,
        Parent = brandDot,
    })
    paint(brandMark, "TextColor3", "Text")

    local titleLabel = make("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(50, 7),
        Size = UDim2.new(0, 210, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = config.Name or "Yugen",
        TextSize = 14,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleBar,
    })
    paint(titleLabel, "TextColor3", "Text")

    if config.Subtitle then
        local subLabel = make("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(50, 25),
            Size = UDim2.new(0, 210, 0, 16),
            Font = Enum.Font.Gotham,
            Text = config.Subtitle,
            TextSize = 12,
            TextColor3 = Theme.Muted,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = titleBar,
        })
        paint(subLabel, "TextColor3", "Muted")
    end

    local closeBtn = make("TextButton", {
        Size = UDim2.fromOffset(28, 28),
        Position = UDim2.new(1, -38, 0.5, -14),
        BackgroundTransparency = 1,
        Text = "×",
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = Theme.Muted,
        AutoButtonColor = false,
        Parent = titleBar,
    })
    corner(closeBtn, 6)
    paint(closeBtn, "TextColor3", "Muted")

    local minBtn = make("TextButton", {
        Size = UDim2.fromOffset(28, 28),
        Position = UDim2.new(1, -70, 0.5, -14),
        BackgroundTransparency = 1,
        Text = "–",
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = Theme.Muted,
        AutoButtonColor = false,
        Parent = titleBar,
    })
    corner(minBtn, 6)
    paint(minBtn, "TextColor3", "Muted")

    local searchBox = make("TextBox", {
        Size = UDim2.fromOffset(132, 28),
        Position = UDim2.new(1, -216, 0.5, -14),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
        Font = uiFont("Regular"),
        PlaceholderText = "Search…",
        Text = "",
        TextSize = 11,
        TextColor3 = Theme.Text,
        ClearTextOnFocus = false,
        Parent = titleBar,
    })
    corner(searchBox, 6)
    paint(searchBox, "BackgroundColor3", "Card")
    stroke(searchBox, Theme.Stroke, 1, 0.5)
    paint(searchBox, "TextColor3", "Text")
    searchBox.Visible = config.Search ~= false

    local sidebar = make("Frame", {
        Size = UDim2.new(0, config.TabWidth or 160, 1, -52),
        Position = UDim2.fromOffset(0, 52),
        BackgroundColor3 = Theme.Bg,
        BorderSizePixel = 0,
        Parent = main,
    })
    paint(sidebar, "BackgroundColor3", "Bg")
    local sbStroke = stroke(sidebar, Theme.Stroke, 1, 0.65)
    paint(sbStroke, "Color", "Stroke")

    local PROFILE_H = 82
    local showProfile = config.ShowProfile ~= false
    local navHeightPad = showProfile and (PROFILE_H + 16) or 12

    local nav = make("ScrollingFrame", {
        Size = UDim2.new(1, -12, 1, -navHeightPad),
        Position = UDim2.fromOffset(6, 6),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(),
        Parent = sidebar,
    })
    paint(nav, "ScrollBarImageColor3", "Accent")
    pcall(function()
        local autoY = enumItem("AutomaticSize", "Y")
        if autoY then
            nav.AutomaticCanvasSize = autoY
        end
    end)
    listLayout(nav, 6)
    pad(nav, 2, 2, 2, 2)

    local content = make("Frame", {
        Size = UDim2.new(1, -(config.TabWidth or 160), 1, -52),
        Position = UDim2.fromOffset(config.TabWidth or 160, 52),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        Parent = main,
    })
    corner(content, 0)
    paint(content, "BackgroundColor3", "Panel")
    local ctStroke = stroke(content, Theme.Stroke, 1, 0.7)
    paint(ctStroke, "Color", "Stroke")

    local pageTitle = make("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 8),
        Size = UDim2.new(1, -28, 0, 22),
        Font = Enum.Font.GothamBold,
        Text = "Tab",
        TextSize = 16,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = content,
    })
    paint(pageTitle, "TextColor3", "Text")
    local pageSub = make("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 28),
        Size = UDim2.new(1, -28, 0, 16),
        Font = Enum.Font.Gotham,
        Text = "",
        TextSize = 11,
        TextColor3 = Theme.Muted,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = content,
    })
    paint(pageSub, "TextColor3", "Muted")

    local pagesFolder = make("Frame", {
        Size = UDim2.new(1, -16, 1, -52),
        Position = UDim2.fromOffset(8, 48),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = content,
    })

    local profileState = {
        Plan = "Free",
        PlanLabel = "FREE",
        Subtitle = "Free plan",
        KeyText = "No active premium key",
        UpgradeUrl = config.UpgradeUrl or "",
        UpgradeText = "Get Premium",
        Premium = false,
    }
    if type(config.Profile) == "table" then
        for k, v in pairs(config.Profile) do
            profileState[k] = v
        end
    end

    local profileBtn, planChip, planChipLabel, planSubLabel
    local accountModal, accountPlanTitle, accountPlanDesc, accountKeyLabel, upgradeBtn, accountAvatar
    local openProfileFn, closeProfileFn, refreshProfileFn

    local function loadAvatar(imageLabel)
        if not imageLabel then
            return
        end
        deferCall(function()
            local ok, thumb = pcall(function()
                return Players:GetUserThumbnailAsync(
                    LocalPlayer.UserId,
                    Enum.ThumbnailType.HeadShot,
                    Enum.ThumbnailSize.Size100x100
                )
            end)
            if ok and type(thumb) == "string" and thumb ~= "" then
                imageLabel.Image = thumb
            else
                imageLabel.Image = string.format(
                    "rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150",
                    LocalPlayer.UserId
                )
            end
        end)
    end

    if showProfile then
        profileBtn = make("TextButton", {
            Name = "Profile",
            Size = UDim2.new(1, -12, 0, PROFILE_H),
            Position = UDim2.new(0, 6, 1, -(PROFILE_H + 6)),
            BackgroundColor3 = Theme.Card,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            Parent = sidebar,
        })
        corner(profileBtn, 10)
        stroke(profileBtn, Theme.AccentDim, 1, 0.55)

        local avatarRing = make("Frame", {
            Size = UDim2.fromOffset(36, 36),
            Position = UDim2.fromOffset(8, 10),
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0,
            Parent = profileBtn,
        })
        corner(avatarRing, 18)

        local avatar = make("ImageLabel", {
            Size = UDim2.fromOffset(30, 30),
            Position = UDim2.fromOffset(3, 3),
            BackgroundColor3 = Theme.Panel,
            BorderSizePixel = 0,
            Image = "",
            Parent = avatarRing,
        })
        corner(avatar, 15)

        local statusDot = make("Frame", {
            Size = UDim2.fromOffset(8, 8),
            Position = UDim2.fromOffset(26, 26),
            BackgroundColor3 = Theme.Success,
            BorderSizePixel = 0,
            ZIndex = 2,
            Parent = avatarRing,
        })
        corner(statusDot, 4)

        make("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(50, 8),
            Size = UDim2.new(1, -58, 0, 14),
            Font = uiFont("Bold"),
            Text = LocalPlayer.DisplayName,
            TextSize = 11,
            TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = profileBtn,
        })
        make("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(50, 22),
            Size = UDim2.new(1, -58, 0, 12),
            Font = uiFont("Regular"),
            Text = "@" .. LocalPlayer.Name,
            TextSize = 9,
            TextColor3 = Theme.Muted,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = profileBtn,
        })

        planChip = make("Frame", {
            Size = UDim2.fromOffset(52, 16),
            Position = UDim2.fromOffset(8, 54),
            BackgroundColor3 = Theme.Track,
            BorderSizePixel = 0,
            Parent = profileBtn,
        })
        corner(planChip, 5)
        planChipLabel = make("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Font = uiFont("Bold"),
            Text = "FREE",
            TextSize = 8,
            TextColor3 = Theme.Muted,
            Parent = planChip,
        })
        planSubLabel = make("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(64, 54),
            Size = UDim2.new(1, -72, 0, 16),
            Font = uiFont("Regular"),
            Text = "Free plan",
            TextSize = 9,
            TextColor3 = Theme.Muted,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = profileBtn,
        })

        accountModal = make("Frame", {
            Name = "AccountModal",
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Visible = false,
            ZIndex = 50,
            Parent = main,
        })
        local dimBtn = make("TextButton", {
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0.45,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 50,
            Parent = accountModal,
        })
        local accountPanel = make("Frame", {
            Size = UDim2.fromOffset(320, 300),
            Position = UDim2.new(0.5, -160, 0.5, -150),
            BackgroundColor3 = Theme.Bg,
            BorderSizePixel = 0,
            ZIndex = 51,
            Parent = accountModal,
        })
        corner(accountPanel, 16)
        stroke(accountPanel, Theme.Stroke, 1, 0.15)

        make("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(20, 16),
            Size = UDim2.new(1, -60, 0, 22),
            Font = uiFont("Bold"),
            Text = "Account",
            TextSize = 16,
            TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 52,
            Parent = accountPanel,
        })
        local accountClose = make("TextButton", {
            Size = UDim2.fromOffset(28, 28),
            Position = UDim2.new(1, -40, 0, 12),
            BackgroundColor3 = Theme.Card,
            Text = "×",
            Font = uiFont("Bold"),
            TextSize = 16,
            TextColor3 = Theme.Muted,
            AutoButtonColor = false,
            ZIndex = 52,
            Parent = accountPanel,
        })
        corner(accountClose, 8)

        accountAvatar = make("ImageLabel", {
            Size = UDim2.fromOffset(56, 56),
            Position = UDim2.fromOffset(20, 52),
            BackgroundColor3 = Theme.Panel,
            BorderSizePixel = 0,
            Image = "",
            ZIndex = 52,
            Parent = accountPanel,
        })
        corner(accountAvatar, 28)

        make("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(88, 56),
            Size = UDim2.new(1, -108, 0, 20),
            Font = uiFont("Bold"),
            Text = LocalPlayer.DisplayName,
            TextSize = 15,
            TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 52,
            Parent = accountPanel,
        })
        make("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(88, 78),
            Size = UDim2.new(1, -108, 0, 16),
            Font = uiFont("Regular"),
            Text = "@" .. LocalPlayer.Name,
            TextSize = 12,
            TextColor3 = Theme.Muted,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 52,
            Parent = accountPanel,
        })

        local accountPlanCard = make("Frame", {
            Size = UDim2.new(1, -40, 0, 72),
            Position = UDim2.fromOffset(20, 124),
            BackgroundColor3 = Theme.Card,
            BorderSizePixel = 0,
            ZIndex = 52,
            Parent = accountPanel,
        })
        corner(accountPlanCard, 12)
        stroke(accountPlanCard, Theme.Stroke, 1, 0.35)
        accountPlanTitle = make("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(14, 12),
            Size = UDim2.new(1, -28, 0, 18),
            Font = uiFont("Bold"),
            Text = "Free plan",
            TextSize = 14,
            TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 53,
            Parent = accountPlanCard,
        })
        accountPlanDesc = make("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(14, 34),
            Size = UDim2.new(1, -28, 0, 28),
            Font = uiFont("Regular"),
            Text = "Hub access with free features.",
            TextSize = 11,
            TextColor3 = Theme.Muted,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            ZIndex = 53,
            Parent = accountPlanCard,
        })
        accountKeyLabel = make("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(20, 206),
            Size = UDim2.new(1, -40, 0, 18),
            Font = uiFont("Medium"),
            Text = "",
            TextSize = 12,
            TextColor3 = Theme.Accent,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 52,
            Parent = accountPanel,
        })
        upgradeBtn = make("TextButton", {
            Size = UDim2.new(1, -40, 0, 36),
            Position = UDim2.fromOffset(20, 240),
            BackgroundColor3 = Theme.AccentDim,
            Text = "Get Premium",
            Font = uiFont("Bold"),
            TextSize = 13,
            TextColor3 = Theme.Text,
            AutoButtonColor = false,
            ZIndex = 52,
            Parent = accountPanel,
        })
        corner(upgradeBtn, 10)

        local function refreshProfileUi()
            local premium = profileState.Premium or string.lower(tostring(profileState.Plan or "")) == "premium"
            planChipLabel.Text = profileState.PlanLabel or (premium and "PREMIUM" or "FREE")
            planSubLabel.Text = profileState.Subtitle or (premium and "Premium" or "Free plan")
            if premium then
                planChip.BackgroundColor3 = Theme.AccentDim
                planChipLabel.TextColor3 = Theme.Text
                accountPlanTitle.Text = "Premium plan"
                accountPlanDesc.Text = profileState.Subtitle or "Premium access. All features unlocked."
            else
                planChip.BackgroundColor3 = Theme.Track
                planChipLabel.TextColor3 = Theme.Muted
                accountPlanTitle.Text = "Free plan"
                accountPlanDesc.Text = "Basic access. Upgrade for Premium."
            end
            accountKeyLabel.Text = profileState.KeyText or ""
            upgradeBtn.Text = profileState.UpgradeText or (premium and "Discord" or "Get Premium")
            accountAvatar.Image = avatar.Image
        end

        local function openAccountModal()
            refreshProfileUi()
            accountModal.Visible = true
        end
        local function closeAccountModal()
            accountModal.Visible = false
        end

        profileBtn.MouseButton1Click:Connect(openAccountModal)
        profileBtn.MouseEnter:Connect(function()
            tween(profileBtn, { BackgroundColor3 = Theme.CardHover }, 0.12)
        end)
        profileBtn.MouseLeave:Connect(function()
            tween(profileBtn, { BackgroundColor3 = Theme.Card }, 0.12)
        end)
        accountClose.MouseButton1Click:Connect(closeAccountModal)
        dimBtn.MouseButton1Click:Connect(closeAccountModal)
        upgradeBtn.MouseButton1Click:Connect(function()
            local url = profileState.UpgradeUrl or ""
            if type(profileState.OnUpgrade) == "function" then
                pcall(profileState.OnUpgrade, url)
                return
            end
            if url == "" then
                YugenUI:Notify("Account", "No upgrade link set", 3)
                return
            end
            local copied = false
            pcall(function()
                if typeof(setclipboard) == "function" then
                    setclipboard(url)
                    copied = true
                end
            end)
            if copied then
                YugenUI:Notify("Account", "Link copied", 3)
            else
                YugenUI:Notify("Account", url, 4)
            end
        end)

        loadAvatar(avatar)
        loadAvatar(accountAvatar)
        refreshProfileUi()
        openProfileFn = openAccountModal
        closeProfileFn = closeAccountModal
        refreshProfileFn = refreshProfileUi
    end

    -- drag + resize
    local dragging, resizing = false, false
    local dragStart, startPos, startSize
    local minW = (config.MinSize and config.MinSize.X) or 440
    local minH = (config.MinSize and config.MinSize.Y) or 320
    local maxW = (config.MaxSize and config.MaxSize.X) or 920
    local maxH = (config.MaxSize and config.MaxSize.Y) or 720
    local resizable = config.Resizable ~= false

    titleBar.InputBegan:Connect(function(input)
        if resizing then
            return
        end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)

    if resizable then
        local resizeHandle = make("TextButton", {
            Name = "Resize",
            Size = UDim2.fromOffset(18, 18),
            Position = UDim2.new(1, -18, 1, -18),
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 30,
            Parent = main,
        })
        for i = 1, 3 do
            make("Frame", {
                Size = UDim2.fromOffset(2 + i * 3, 2),
                Position = UDim2.fromOffset(14 - i * 3, 14 - (3 - i)),
                BackgroundColor3 = Theme.Muted,
                BackgroundTransparency = 0.25,
                BorderSizePixel = 0,
                Parent = resizeHandle,
            })
        end
        resizeHandle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                resizing = true
                dragging = false
                dragStart = input.Position
                startSize = Vector2.new(main.AbsoluteSize.X, main.AbsoluteSize.Y)
            end
        end)
    end

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        if resizing and dragStart and startSize then
            local delta = input.Position - dragStart
            local w = clamp(startSize.X + delta.X, minW, maxW)
            local h = clamp(startSize.Y + delta.Y, minH, maxH)
            main.Size = UDim2.fromOffset(w, h)
        elseif dragging and dragStart and startPos then
            local d = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            resizing = false
        end
    end)

    local Window = {
        ScreenGui = screenGui,
        Main = main,
        Tabs = {},
        Current = nil,
        Flags = YugenUI.Options,
    }
    local toggleKey = config.ToggleKey or Enum.KeyCode.RightShift

    local function switchTab(name)
        local tab = Window.Tabs[name]
        if not tab then return end

        Window.Current = name
        pageTitle.Text = name
        pageSub.Text = tab.Subtitle or ""

        for n, t in pairs(Window.Tabs) do
            local active = (n == name)
            local vis = t.Shell or t.Page
            if vis then
                vis.Visible = active
            end
            if t.NavButton then
                t.NavButton.BackgroundColor3 = active and Theme.AccentDim or Theme.Card
                t.NavButton.BackgroundTransparency = active and 0 or 1
            end
            if t.NavLabel then
                t.NavLabel.TextColor3 = active and Theme.Text or Theme.Muted
            end
            if active and t.Refresh then
                pcall(t.Refresh)
            end
        end
    end

    function Window:SelectTab(name)
        switchTab(name)
    end

    function Window:RefreshTab(name)
        local tab = Window.Tabs[name or Window.Current]
        if tab and tab.Refresh then
            tab.Refresh()
        end
    end

    function Window:CreateTab(tabConfig)
        tabConfig = tabConfig or {}
        local name = tabConfig.Name or ("Tab" .. tostring((function()
            local c = 0
            for _ in pairs(Window.Tabs) do
                c = c + 1
            end
            return c
        end)() + 1))
        local icon = resolveIcon(tabConfig.Icon)

        local btn = make("TextButton", {
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = Theme.AccentDim,
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            Parent = nav,
        })
        corner(btn, 6)
        paint(btn, "BackgroundColor3", "AccentDim")
        local label = make("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(12, 0),
            Size = UDim2.new(1, -16, 1, 0),
            Font = uiFont("Medium"),
            Text = tostring(icon) .. "  " .. tostring(name),
            TextSize = 12,
            TextColor3 = Theme.Muted,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = btn,
        })
        paint(label, "TextColor3", "Muted")

        local shell = make("Frame", {
            Name = name,
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Visible = false,
            ZIndex = 1,
            Parent = pagesFolder,
        })

        local page = make("ScrollingFrame", {
            Name = "Scroll",
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Parent = shell,
        })
        paint(page, "ScrollBarImageColor3", "Accent")
        pcall(function()
            local dir = enumItem("ScrollingDirection", "Y")
            if dir then
                page.ScrollingDirection = dir
            end
        end)
        local pageList = listLayout(page, 8)
        pad(page, 4, 4, 12, 4)
        local refresh = bindPageCanvas(page, pageList)

        btn.MouseButton1Click:Connect(function()
            switchTab(name)
        end)

        local Tab = {
            Name = name,
            Subtitle = tabConfig.Subtitle or "",
            Shell = shell,
            Page = page,
            NavButton = btn,
            NavLabel = label,
            Refresh = refresh,
        }

        function Tab:Section(title)
            return addSection(page, title)
        end
        function Tab:Label(text)
            return addLabel(page, text)
        end
        function Tab:Toggle(o)
            return addToggle(page, o)
        end
        function Tab:ToggleKeybind(o)
            return addToggleKeybind(page, o)
        end
        function Tab:Slider(o)
            return addSlider(page, o)
        end
        function Tab:Dropdown(o)
            return addDropdown(page, screenGui, o)
        end
        function Tab:ColorPicker(o)
            return addColorPicker(page, screenGui, o)
        end
        function Tab:Keybind(o)
            return addKeybind(page, o)
        end
        function Tab:Button(o)
            return addButton(page, o)
        end
        function Tab:Paragraph(o)
            return addParagraph(page, o)
        end
        function Tab:Input(o)
            return addInput(page, o)
        end
        Tab.AddToggle = Tab.Toggle
        Tab.AddSlider = Tab.Slider
        Tab.AddDropdown = Tab.Dropdown
        Tab.AddButton = Tab.Button
        Tab.AddParagraph = Tab.Paragraph
        Tab.AddInput = Tab.Input
        Tab.AddKeybind = Tab.Keybind
        Tab.AddColorpicker = Tab.ColorPicker
        Tab.AddToggleKeybind = Tab.ToggleKeybind
        Tab.AddLabel = Tab.Label
        Tab.Colorpicker = Tab.ColorPicker

        Window.Tabs[name] = Tab
        if Window.Current == nil then
            switchTab(name)
        end
        return Tab
    end

    function Window:SetProfile(info)
        if type(info) ~= "table" then
            return
        end
        for k, v in pairs(info) do
            profileState[k] = v
        end
        if refreshProfileFn then
            refreshProfileFn()
        end
    end

    function Window:OpenProfile()
        if openProfileFn then
            openProfileFn()
        end
    end

    function Window:CloseProfile()
        if closeProfileFn then
            closeProfileFn()
        end
    end

    local minimized = false
    local savedSize = Vector2.new(width, height)
    local function applySearch(q)
        q = string.lower(tostring(q or ""))
        for _, tab in pairs(Window.Tabs) do
            local pg = tab.Page
            if pg then
                for _, child in ipairs(pg:GetChildren()) do
                    if child:IsA("GuiObject") and not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
                        local label = ""
                        pcall(function()
                            label = child:GetAttribute("YugenSearch") or ""
                        end)
                        child.Visible = (q == "" or string.find(label, q, 1, true) ~= nil)
                    end
                end
            end
        end
    end
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        applySearch(searchBox.Text)
    end)

    function Window:Minimize()
        minimized = not minimized
        sidebar.Visible = not minimized
        content.Visible = not minimized
        searchBox.Visible = not minimized and config.Search ~= false
        if minimized then
            savedSize = Vector2.new(main.AbsoluteSize.X, main.AbsoluteSize.Y)
            tween(main, { Size = UDim2.fromOffset(280, 48) }, 0.2)
        else
            tween(main, { Size = UDim2.fromOffset(savedSize.X, savedSize.Y) }, 0.2)
        end
    end
    minBtn.MouseButton1Click:Connect(function()
        Window:Minimize()
    end)

    function Window:Dialog(cfg)
        cfg = cfg or {}
        local overlay = make("Frame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 0.45,
            ZIndex = 80,
            Parent = main,
        })
        local panel = make("Frame", {
            Size = UDim2.fromOffset(300, 170),
            Position = UDim2.new(0.5, -150, 0.5, -85),
            BackgroundColor3 = Theme.Bg,
            ZIndex = 81,
            Parent = overlay,
        })
        paint(panel, "BackgroundColor3", "Bg")
        corner(panel, 14)
        stroke(panel, Theme.Stroke, 1, 0.15)
        make("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(16, 12),
            Size = UDim2.new(1, -32, 0, 22),
            Font = uiFont("Bold"),
            Text = cfg.Title or "Dialog",
            TextSize = 15,
            TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 82,
            Parent = panel,
        })
        make("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(16, 40),
            Size = UDim2.new(1, -32, 0, 56),
            Font = uiFont("Regular"),
            Text = cfg.Content or "",
            TextSize = 12,
            TextColor3 = Theme.Muted,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 82,
            Parent = panel,
        })
        local buttons = cfg.Buttons or { { Title = "OK" } }
        for i, b in ipairs(buttons) do
            local btn = make("TextButton", {
                Size = UDim2.new(1 / #buttons, -10, 0, 32),
                Position = UDim2.new((i - 1) / #buttons, 8, 1, -44),
                BackgroundColor3 = i == 1 and Theme.AccentDim or Theme.Card,
                Text = b.Title or "OK",
                Font = uiFont("Bold"),
                TextSize = 12,
                TextColor3 = Theme.Text,
                AutoButtonColor = false,
                ZIndex = 82,
                Parent = panel,
            })
            corner(btn, 8)
            btn.MouseButton1Click:Connect(function()
                overlay:Destroy()
                if b.Callback then
                    pcall(b.Callback)
                end
            end)
        end
        return overlay
    end

    function Window:ToggleTransparency(on)
        if on == nil then
            on = not YugenUI.Transparency
        end
        YugenUI.Transparency = not not on
        local t = YugenUI.Transparency and 0.25 or 0
        main.BackgroundTransparency = t
        sidebar.BackgroundTransparency = t
        content.BackgroundTransparency = t
    end

    function Window:ToggleAcrylic(on)
        YugenUI.Acrylic = not not on
        if YugenUI.Acrylic then
            pcall(function()
                local Lighting = game:GetService("Lighting")
                local dof = Lighting:FindFirstChild("YugenAcrylic")
                if not dof then
                    dof = Instance.new("DepthOfFieldEffect")
                    dof.Name = "YugenAcrylic"
                    dof.FarIntensity = 0.4
                    dof.FocusDistance = 0.05
                    dof.InFocusRadius = 0.1
                    dof.NearIntensity = 0.8
                    dof.Parent = Lighting
                end
                dof.Enabled = true
            end)
        else
            pcall(function()
                local dof = game:GetService("Lighting"):FindFirstChild("YugenAcrylic")
                if dof then
                    dof.Enabled = false
                end
            end)
        end
    end

    if config.Transparency then
        Window:ToggleTransparency(true)
    end
    if config.Acrylic then
        Window:ToggleAcrylic(true)
    end

    local function serializeValue(v)
        if typeof(v) == "Color3" then
            return { __c = true, r = v.R, g = v.G, b = v.B }
        end
        if typeof(v) == "EnumItem" then
            return { __e = true, name = v.Name }
        end
        return v
    end
    local function deserializeValue(v)
        if type(v) == "table" and v.__c then
            return Color3.new(v.r, v.g, v.b)
        end
        if type(v) == "table" and v.__e and Enum.KeyCode[v.name] then
            return Enum.KeyCode[v.name]
        end
        return v
    end

    function Window:SaveConfig(name)
        name = tostring(name or "default"):gsub("[^%w%-%_]", "")
        if name == "" then
            name = "default"
        end
        if typeof(makefolder) == "function" then
            pcall(makefolder, "yugen")
            pcall(makefolder, "yugen/configs")
        end
        if typeof(writefile) ~= "function" then
            YugenUI:Notify("Config", "writefile unavailable", 3)
            return false
        end
        local data = { theme = YugenUI.ThemeName, flags = {} }
        for k, api in pairs(YugenUI.Options) do
            if api and api.Get then
                data.flags[k] = serializeValue(api.Get())
            end
        end
        local HttpService = game:GetService("HttpService")
        local ok, json = pcall(function()
            return HttpService:JSONEncode(data)
        end)
        if not ok then
            return false
        end
        pcall(writefile, "yugen/configs/" .. name .. ".json", json)
        YugenUI:Notify("Config", "Saved " .. name, 2)
        return true
    end

    function Window:LoadConfig(name)
        name = tostring(name or "default"):gsub("[^%w%-%_]", "")
        local path = "yugen/configs/" .. name .. ".json"
        if typeof(readfile) ~= "function" or typeof(isfile) ~= "function" or not isfile(path) then
            YugenUI:Notify("Config", "Not found", 3)
            return false
        end
        local HttpService = game:GetService("HttpService")
        local ok, data = pcall(function()
            return HttpService:JSONDecode(readfile(path))
        end)
        if not ok or type(data) ~= "table" then
            return false
        end
        if type(data.theme) == "string" then
            Window:SetTheme(data.theme)
        end
        if type(data.flags) == "table" then
            for k, v in pairs(data.flags) do
                local api = YugenUI.Options[k]
                if api and api.Set then
                    pcall(api.Set, deserializeValue(v), true)
                end
            end
        end
        YugenUI:Notify("Config", "Loaded " .. name, 2)
        return true
    end

    function Window:ListConfigs()
        local names = {}
        if typeof(listfiles) == "function" then
            local ok, files = pcall(listfiles, "yugen/configs")
            if ok and type(files) == "table" then
                for _, f in ipairs(files) do
                    local n = tostring(f):match("([^/\\]+)%.json$")
                    if n then
                        table.insert(names, n)
                    end
                end
            end
        end
        return names
    end

    function Window:BuildSettingsTab(tab)
        if not tab then
            return
        end
        tab:Section("Appearance")
        addThemeGallery(tab.Page, function(name)
            return Window:SetTheme(name)
        end)
        tab:Toggle({
            Name = "Transparency",
            Flag = "UI_Transparency",
            Default = YugenUI.Transparency,
            Callback = function(v)
                Window:ToggleTransparency(v)
            end,
        })
        tab:Toggle({
            Name = "Acrylic blur",
            Description = "May be detectable. Needs graphics 8+",
            Flag = "UI_Acrylic",
            Default = YugenUI.Acrylic,
            Callback = function(v)
                Window:ToggleAcrylic(v)
            end,
        })
        tab:Keybind({
            Name = "Minimize bind",
            Default = config.ToggleKey or Enum.KeyCode.RightShift,
            Callback = function(key)
                toggleKey = key
            end,
        })
        tab:Section("Configs")
        tab:Input({
            Name = "Config name",
            Flag = "UI_ConfigName",
            Default = "default",
            Placeholder = "default",
        })
        tab:Button({
            Name = "Save config",
            Callback = function()
                local n = YugenUI.Options.UI_ConfigName and YugenUI.Options.UI_ConfigName.Get() or "default"
                Window:SaveConfig(n)
            end,
        })
        tab:Button({
            Name = "Load config",
            Callback = function()
                local n = YugenUI.Options.UI_ConfigName and YugenUI.Options.UI_ConfigName.Get() or "default"
                Window:LoadConfig(n)
            end,
        })
    end

    function Window:SetTheme(name)
        if applyTheme(name) then
            pcall(restyle)
            pcall(function()
                main.BackgroundColor3 = Theme.Bg
                sidebar.BackgroundColor3 = Theme.Bg
                content.BackgroundColor3 = Theme.Panel
                brandDot.BackgroundColor3 = Theme.Accent
            end)
            if Window.Current then
                pcall(switchTab, Window.Current)
            end
            YugenUI:Notify("Theme", tostring(YugenUI.ThemeName) .. " applied", 2)
            return true
        end
        return false
    end

    function Window:Destroy()
        if screenGui then screenGui:Destroy() end
        for i, w in ipairs(YugenUI.Windows) do
            if w == Window then
                table.remove(YugenUI.Windows, i)
                break
            end
        end
    end

    closeBtn.MouseButton1Click:Connect(function()
        Window:Destroy()
    end)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == toggleKey then
            main.Visible = not main.Visible
        end
    end)

    table.insert(YugenUI.Windows, Window)
    return Window
end

function YugenUI:SetTheme(name)
    if applyTheme(name) then
        pcall(restyle)
        return true
    end
    return false
end

function YugenUI:GetThemes()
    return { "Fluent", "Teal", "Violet", "Crimson", "Ocean", "Amber", "Midnight" }
end

function YugenUI:GetTheme()
    return Theme
end

return YugenUI

