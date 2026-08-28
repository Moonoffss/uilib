# Yugen UI Library

Dark card UI for Roblox executor scripts.

## Load

```lua
local YugenUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Moonoffss/uilib/main/yugen_ui.lua"))()
```

## Quick start

```lua
local Window = YugenUI:CreateWindow({
    Name = "My Hub",
    Subtitle = "v1.0",
    Theme = "Teal",
    ToggleKey = Enum.KeyCode.RightShift,
})

local Tab = Window:CreateTab({ Name = "Main", Icon = "◆" })
Tab:Section("Demo")
Tab:Toggle({ Name = "Enable", Default = false, Callback = print })
Tab:Slider({ Name = "Speed", Min = 1, Max = 100, Default = 16, Callback = print })
Tab:Button({ Name = "Notify", Callback = function()
    YugenUI:Notify("Yugen", "It works", 3)
end })
```

## Themes

`Teal` `Violet` `Crimson` `Ocean` `Amber` `Midnight`
