# Yugen UI Library

Dark card UI for Roblox executor scripts. **v1.1.0**

Fluent-class API (flags, live themes, dialogs, configs) with Yugen look — not a Windows 11 clone.

## Load

```lua
local YugenUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Moonoffss/uilib/main/yugen_ui.lua?v=1.1.0"))()
```

Local: `loadstring(readfile("yugen_ui.lua"))()`

## Quick start

```lua
local Window = YugenUI:CreateWindow({
    Name = "Yugen",
    Subtitle = "v1.1",
    Theme = "Teal", -- Teal | Violet | Crimson | Ocean | Amber | Midnight
    ToggleKey = Enum.KeyCode.RightShift,
    Resizable = true,
    ShowProfile = true,
    Transparency = false,
    Acrylic = false, -- optional blur; may be detectable
})

local Tab = Window:CreateTab({ Name = "Main", Icon = "combat" })
Tab:Section("Demo")
Tab:Paragraph({ Title = "Info", Content = "Yugen UI 1.1" })
Tab:Toggle({
    Name = "Aimbot",
    Description = "Locks onto closest enemy",
    Flag = "Aimbot",
    Default = false,
    Callback = print,
})
Tab:Slider({ Name = "FOV", Flag = "FOV", Min = 20, Max = 400, Default = 120, Callback = print })
Tab:Dropdown({ Name = "Mode", Flag = "Mode", Options = { "Legit", "Rage" }, Default = "Legit", Callback = print })
Tab:Dropdown({ Name = "Parts", Multi = true, Options = { "Head", "Torso" }, Callback = print })
Tab:Input({ Name = "Name", Flag = "Name", Placeholder = "player", Callback = print })
Tab:Keybind({ Name = "Toggle", Mode = "Hold", Default = Enum.KeyCode.Q, Callback = print })
Tab:Button({ Name = "Ping", Callback = function()
    YugenUI:Notify({ Title = "Yugen", Content = "Hello", SubContent = "v1.1", Duration = 3 })
end })

Window:Dialog({
    Title = "Load config?",
    Content = "This overwrites current flags.",
    Buttons = {
        { Title = "Yes", Callback = function() Window:LoadConfig("default") end },
        { Title = "No" },
    },
})

local Settings = Window:CreateTab({ Name = "Settings", Icon = "settings" })
Window:BuildSettingsTab(Settings)

-- Options registry
YugenUI.Options.Aimbot:Set(true)
Window:SelectTab("Main")
```

## Themes

`YugenUI:GetThemes()` · `Window:SetTheme("Violet")` restyles every painted control.

## Configs

`Window:SaveConfig(name)` / `LoadConfig` / `ListConfigs` → `yugen/configs/*.json` (Flags only).
