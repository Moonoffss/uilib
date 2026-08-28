--[[
    Yugen UI Library
    Dark teal card UI for Roblox executor scripts.

    Load from GitHub:
      local YugenUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/USER/REPO/main/yugen_ui.lua"))()

    Load locally:
      local YugenUI = loadstring(readfile("yugen_ui.lua"))()

    Quick start:
      local Window = YugenUI:CreateWindow({
          Name = "My Hub",
          Subtitle = "v1.0",
          Theme = "Teal", -- Teal | Violet | Crimson | Ocean | Amber | Midnight
          ToggleKey = Enum.KeyCode.RightShift,
      })

      local Tab = Window:CreateTab({ Name = "Main", Icon = "◆" })
      Tab:Section("Combat")
      Tab:Toggle({ Name = "Aimbot", Default = false, Callback = function(v) print(v) end })
      Tab:Slider({ Name = "FOV", Min = 20, Max = 400, Default = 120, Callback = print })
      Tab:Dropdown({ Name = "Mode", Options = {"Legit","Rage"}, Default = "Legit", Callback = print })
      Tab:ColorPicker({ Name = "Accent", Default = Color3.fromRGB(56,214,186), Callback = print })
      Tab:Keybind({ Name = "Toggle", Default = Enum.KeyCode.Q, Callback = print })
      Tab:Button({ Name = "Notify me", Callback = function()
          YugenUI:Notify("Yugen", "Hello", 3)
      end })
--]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local YugenUI = {
    Version = "1.0.2",
    Windows = {},
}

--------------------------------------------------------------------
-- Theme
--------------------------------------------------------------------
local Theme = {
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
}

local ThemePresets = {
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
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(refresh)
    task.defer(refresh)
    return refresh
end

local function corner(parent, radius)
    return make("UICorner", { CornerRadius = UDim.new(0, radius or 8), Parent = parent })
end

local function stroke(parent, color, thickness, transparency)
    return make("UIStroke", {
        Color = color or Theme.Stroke,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
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

local function applyTheme(name)
    local preset = ThemePresets[name]
    if not preset then return false end
    for k, v in pairs(preset) do
        Theme[k] = v
    end
    return true
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

--------------------------------------------------------------------
-- Notify
--------------------------------------------------------------------
local toastGui
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
    duration = duration or 3
    local gui = ensureToastGui()
    local stack = gui:FindFirstChild("Stack")
    local toast = make("Frame", {
        Size = UDim2.new(1, 0, 0, 56),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
        Parent = stack,
    })
    corner(toast, 10)
    stroke(toast, Theme.Accent, 1, 0.35)
    make("Frame", {
        Size = UDim2.fromOffset(3, 56),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = toast,
    })
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
    task.delay(duration, function()
        if toast.Parent then
            tween(toast, { BackgroundTransparency = 1 }, 0.18)
            task.delay(0.2, function()
                if toast.Parent then toast:Destroy() end
            end)
        end
    end)
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
    corner(c, 10)
    stroke(c, Theme.Stroke, 1, 0.45)
    c.MouseEnter:Connect(function()
        tween(c, { BackgroundColor3 = Theme.CardHover }, 0.12)
    end)
    c.MouseLeave:Connect(function()
        tween(c, { BackgroundColor3 = Theme.Card }, 0.12)
    end)
    return c
end

local function addSection(page, title)
    make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = string.upper(title or "Section"),
        TextSize = 11,
        TextColor3 = Theme.Accent,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = page,
    })
end

local function addLabel(page, text)
    make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = text or "",
        TextSize = 12,
        TextColor3 = Theme.Muted,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = page,
    })
end

local function addToggle(page, opts)
    opts = opts or {}
    local frame = makeCard(page, 44)
    make("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 0),
        Size = UDim2.new(1, -80, 1, 0),
        Font = uiFont("Medium"),
        Text = opts.Name or "Toggle",
        TextSize = 13,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
    })
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
    corner(knob, 9)
    local state = not not opts.Default
    local function set(v, fire)
        state = not not v
        track.BackgroundColor3 = state and Theme.Accent or Theme.Track
        tween(knob, { Position = state and UDim2.fromOffset(21, 3) or UDim2.fromOffset(3, 3) }, 0.15)
        if fire ~= false and opts.Callback then
            pcall(opts.Callback, state)
        end
    end
    track.MouseButton1Click:Connect(function()
        set(not state, true)
    end)
    return { Set = set, Get = function() return state end }
end

local function addToggleKeybind(page, opts)
    opts = opts or {}
    local frame = makeCard(page, 44)
    make("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 0),
        Size = UDim2.new(1, -160, 1, 0),
        Font = uiFont("Medium"),
        Text = opts.Name or "Toggle",
        TextSize = 13,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
    })
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
    corner(knob, 9)
    local state = not not opts.Default
    local function set(v, fire)
        state = not not v
        track.BackgroundColor3 = state and Theme.Accent or Theme.Track
        tween(knob, { Position = state and UDim2.fromOffset(21, 3) or UDim2.fromOffset(3, 3) }, 0.15)
        if fire ~= false and opts.Callback then
            pcall(opts.Callback, state)
        end
    end
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
    return { Set = set, Get = function() return state end, GetKey = function() return currentKey end }
end

local function addSlider(page, opts)
    opts = opts or {}
    local min, max = opts.Min or 0, opts.Max or 100
    local decimals = opts.Decimals or 0
    local value = math.clamp(opts.Default or min, min, max)
    local frame = makeCard(page, 62)
    make("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 6),
        Size = UDim2.new(1, -90, 0, 18),
        Font = uiFont("Medium"),
        Text = opts.Name or "Slider",
        TextSize = 13,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
    })
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
    local bar = make("Frame", {
        Size = UDim2.new(1, -28, 0, 8),
        Position = UDim2.fromOffset(14, 36),
        BackgroundColor3 = Theme.Track,
        BorderSizePixel = 0,
        Parent = frame,
    })
    corner(bar, 4)
    local fill = make("Frame", {
        Size = UDim2.new((value - min) / math.max(max - min, 1e-6), 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = bar,
    })
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
        value = math.clamp(v, min, max)
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
        set(min + math.clamp((x - a) / w, 0, 1) * (max - min), true)
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
    return { Set = set, Get = function() return value end }
end

local function addDropdown(page, screenGui, opts)
    opts = opts or {}
    local options = {}
    for _, opt in ipairs(opts.Options or {}) do
        if typeof(opt) == "table" then
            table.insert(options, { id = opt.id or opt.value or opt.label, label = opt.label or tostring(opt.id) })
        else
            table.insert(options, { id = opt, label = tostring(opt) })
        end
    end
    local selected = options[1]
    for _, it in ipairs(options) do
        if it.id == opts.Default or it.label == opts.Default then
            selected = it
            break
        end
    end

    local frame = makeCard(page, 44)
    make("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 0),
        Size = UDim2.new(0.42, 0, 1, 0),
        Font = uiFont("Medium"),
        Text = opts.Name or "List",
        TextSize = 13,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
    })
    local openBtn = make("TextButton", {
        Size = UDim2.fromOffset(128, 28),
        Position = UDim2.new(1, -142, 0.5, -14),
        BackgroundColor3 = Theme.Panel,
        Text = "",
        AutoButtonColor = false,
        Parent = frame,
    })
    corner(openBtn, 8)
    stroke(openBtn, Theme.AccentDim, 1, 0.35)
    local openLabel = make("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(10, 0),
        Size = UDim2.new(1, -28, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = selected and selected.label or "—",
        TextSize = 11,
        TextColor3 = Theme.Accent,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = openBtn,
    })
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
    corner(drop, 10)
    stroke(drop, Theme.Stroke, 1, 0.2)
    local dropList = make("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
        ZIndex = 81,
        Parent = drop,
    })
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
        local guiAbs = screenGui.AbsolutePosition
        drop.Position = UDim2.fromOffset(abs.X - guiAbs.X, abs.Y - guiAbs.Y + size.Y + 4)
        drop.Size = UDim2.fromOffset(math.max(size.X, 128), math.min(28 + #options * 30, 160))
        drop.Visible = true
        activeDropdownClose = close
        dropdownIgnoreUntil = tick() + 0.2
    end

    for _, it in ipairs(options) do
        local row = make("TextButton", {
            Size = UDim2.new(1, 0, 0, 26),
            BackgroundColor3 = Theme.Card,
            Text = "  " .. it.label,
            Font = uiFont("Medium"),
            TextSize = 12,
            TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false,
            ZIndex = 82,
            Parent = dropList,
        })
        corner(row, 6)
        row.MouseButton1Click:Connect(function()
            selected = it
            openLabel.Text = it.label
            close()
            if opts.Callback then pcall(opts.Callback, it.id, it) end
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

    return {
        Set = function(id)
            for _, it in ipairs(options) do
                if it.id == id or it.label == id then
                    selected = it
                    openLabel.Text = it.label
                    break
                end
            end
        end,
        Get = function()
            return selected and selected.id
        end,
    }
end

local function addColorPicker(page, screenGui, opts)
    opts = opts or {}
    local current = opts.Default or Theme.Accent
    local h, s, v = Color3.toHSV(current)
    local frame = makeCard(page, 44)
    make("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 0),
        Size = UDim2.new(1, -170, 1, 0),
        Font = uiFont("Medium"),
        Text = opts.Name or "Color",
        TextSize = 13,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
    })
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
        local guiAbs = screenGui.AbsolutePosition
        local x = math.clamp(abs.X - guiAbs.X - 80, 8, math.max(8, screenGui.AbsoluteSize.X - 204))
        local y = math.clamp(abs.Y - guiAbs.Y + size.Y + 6, 8, math.max(8, screenGui.AbsoluteSize.Y - 244))
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

    return { Set = setColor, Get = function() return current end }
end

local function addKeybind(page, opts)
    opts = opts or {}
    local current = opts.Default or Enum.KeyCode.E
    local frame = makeCard(page, 44)
    make("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 0),
        Size = UDim2.new(0.55, 0, 1, 0),
        Font = uiFont("Medium"),
        Text = opts.Name or "Keybind",
        TextSize = 13,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
    })
    local button = make("TextButton", {
        Size = UDim2.fromOffset(90, 28),
        Position = UDim2.new(1, -104, 0.5, -14),
        BackgroundColor3 = Theme.Panel,
        Text = current.Name,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = Theme.Accent,
        AutoButtonColor = false,
        Parent = frame,
    })
    corner(button, 8)
    stroke(button, Theme.AccentDim, 1, 0.35)
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
    return { Set = function(k) current = k button.Text = k.Name end, Get = function() return current end }
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
    return btn
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

    local width = config.Width or 560
    local height = config.Height or 400

    local main = make("Frame", {
        Size = UDim2.fromOffset(width, height),
        Position = UDim2.new(0.5, -width / 2, 0.5, -height / 2),
        BackgroundColor3 = Theme.Bg,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = screenGui,
    })
    corner(main, 14)
    stroke(main, Theme.Stroke, 1, 0.15)

    local titleBar = make("Frame", {
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundTransparency = 1,
        Parent = main,
    })

    local brandDot = make("Frame", {
        Size = UDim2.fromOffset(10, 10),
        Position = UDim2.fromOffset(16, 18),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = titleBar,
    })
    corner(brandDot, 5)

    make("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(34, 0),
        Size = UDim2.new(0, 200, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = config.Name or "Yugen",
        TextSize = 15,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleBar,
    })

    if config.Subtitle then
        make("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(34 + (#(config.Name or "Yugen") * 8) + 24, 0),
            Size = UDim2.new(0, 160, 1, 0),
            Font = Enum.Font.Gotham,
            Text = config.Subtitle,
            TextSize = 12,
            TextColor3 = Theme.Muted,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = titleBar,
        })
    end

    local closeBtn = make("TextButton", {
        Size = UDim2.fromOffset(28, 28),
        Position = UDim2.new(1, -40, 0.5, -14),
        BackgroundColor3 = Theme.Card,
        Text = "×",
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = Theme.Muted,
        AutoButtonColor = false,
        Parent = titleBar,
    })
    corner(closeBtn, 8)

    local sidebar = make("Frame", {
        Size = UDim2.new(0, 140, 1, -58),
        Position = UDim2.fromOffset(12, 48),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        Parent = main,
    })
    corner(sidebar, 12)
    stroke(sidebar, Theme.Stroke, 1, 0.4)

    local nav = make("ScrollingFrame", {
        Size = UDim2.new(1, -12, 1, -12),
        Position = UDim2.fromOffset(6, 6),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = sidebar,
    })
    listLayout(nav, 6)
    pad(nav, 2, 2, 2, 2)

    local content = make("Frame", {
        Size = UDim2.new(1, -172, 1, -58),
        Position = UDim2.fromOffset(160, 48),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        Parent = main,
    })
    corner(content, 12)
    stroke(content, Theme.Stroke, 1, 0.4)

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

    local pagesFolder = make("Frame", {
        Size = UDim2.new(1, -16, 1, -52),
        Position = UDim2.fromOffset(8, 48),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = content,
    })

    -- drag
    do
        local dragging, dragStart, startPos
        titleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = main.Position
            end
        end)
        titleBar.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local d = input.Position - dragStart
                main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end)
    end

    local Window = {
        ScreenGui = screenGui,
        Main = main,
        Tabs = {},
        Current = nil,
    }

    local function switchTab(name)
        local tab = Window.Tabs[name]
        if not tab then return end

        for n, t in pairs(Window.Tabs) do
            local active = (n == name)
            t.Shell.Visible = active
            t.Button.BackgroundColor3 = active and Theme.AccentDim or Theme.Card
            if t.Label then
                t.Label.TextColor3 = active and Theme.Text or Theme.Muted
            end
            if active and t.Refresh then
                task.defer(t.Refresh)
            end
        end

        Window.Current = name
        pageTitle.Text = name
        pageSub.Text = tab.Subtitle or ""
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
        local icon = tabConfig.Icon or ">"

        local btn = make("TextButton", {
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = Theme.Card,
            Text = "",
            AutoButtonColor = false,
            Parent = nav,
        })
        corner(btn, 10)
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
            ScrollingDirection = Enum.ScrollingDirection.Y,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Parent = shell,
        })
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
            Button = btn,
            Label = label,
            Refresh = refresh,
        }

        function Tab:Section(title)
            addSection(page, title)
        end
        function Tab:Label(text)
            addLabel(page, text)
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

        Window.Tabs[name] = Tab
        if Window.Current == nil then
            switchTab(name)
        end
        return Tab
    end

    function Window:SetTheme(name)
        if applyTheme(name) then
            brandDot.BackgroundColor3 = Theme.Accent
            main.BackgroundColor3 = Theme.Bg
            sidebar.BackgroundColor3 = Theme.Panel
            content.BackgroundColor3 = Theme.Panel
            YugenUI:Notify("Theme", name .. " applied", 2)
        end
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

    local toggleKey = config.ToggleKey or Enum.KeyCode.RightShift
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
    return applyTheme(name)
end

function YugenUI:GetTheme()
    return Theme
end

return YugenUI
