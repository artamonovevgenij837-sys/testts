-- hamer client (no key)
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local SoundService = game:GetService("SoundService")
local TeleportService = game:GetService("TeleportService")
local Stats = game:GetService("Stats")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local FONT_BLACK = Enum.Font.GothamBlack
local FONT_BOLD = Enum.Font.GothamBold
local FONT_REG = Enum.Font.Gotham

local ACCENTS = {
    Cyan = Color3.fromRGB(0, 229, 255),
    Purple = Color3.fromRGB(186, 120, 255),
    Pink = Color3.fromRGB(255, 120, 200),
    Red = Color3.fromRGB(255, 78, 100),
    Lime = Color3.fromRGB(160, 240, 90),
    Gold = Color3.fromRGB(255, 205, 80),
    Blue = Color3.fromRGB(90, 150, 255),
    Emerald = Color3.fromRGB(70, 235, 155),
    Orange = Color3.fromRGB(255, 150, 70),
    White = Color3.fromRGB(240, 245, 255)
}
local ACCENT_ORDER = {"Cyan", "Purple", "Pink", "Red", "Lime", "Gold", "Blue", "Emerald", "Orange", "White"}

local S = {
    Accent = "Cyan", MenuOpen = false,
    ESP = false, ESPNames = true, ESPDist = true, ESPColor = Color3.fromRGB(0, 229, 255),
    Fullbright = false, Fog = false, FogDensity = 0.35,
    MotionBlur = false, MotionBlurStrength = 16,
    Aspect = false, AspectValue = 0.8,
    World = false, WorldSaturation = 0, WorldContrast = 0,
    Aimbot = false, AimbotFOV = 160, AimbotSmooth = 0.35, AimbotPart = "Head",
    Speed = false, SpeedValue = 32,
    Jump = false, JumpValue = 80,
    Fly = false, FlySpeed = 60,
    Noclip = false,
    Hitbox = false, HitboxSize = 8,
    InfJump = false,
    AntiAfk = false,
    AutoCollect = false,
    Watermark = true,
    Dong = false, DongSize = 1, DongGlow = true, DongColor = Color3.fromRGB(255, 170, 200),
    Wings = false, Halo = false, ChinaHat = false, Kagune = false, Companion = false, NoAnims = false,
    Korblox = false, GhostLegs = false,
    AvatarScale = 1, ConfigName = "default", DroneActive = false, Mobile = false
}

S.Mobile = (UIS.TouchEnabled and not UIS.KeyboardEnabled) or false

local Unloaded = false
local Conns = {}
local function conn(c)
    table.insert(Conns, c)
    return c
end
local function clamp(v, a, b)
    if v < a then return a elseif v > b then return b end
    return v
end
local function FS(n)
    if S.Mobile then return math.floor(n * 1.25 + 0.5) end
    return n
end
local function RH(n)
    if S.Mobile then return math.floor(n * 1.22 + 0.5) end
    return n
end
local function tw(o, t, props, style, dir)
    local t1 = TweenService:Create(o, TweenInfo.new(t or 0.2, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out), props)
    t1:Play()
    return t1
end
local function accent()
    return ACCENTS[S.Accent] or ACCENTS.Cyan
end

local SoundFolder = Instance.new("Folder")
SoundFolder.Name = "HamerSounds"
SoundFolder.Parent = SoundService
local clickSound = Instance.new("Sound")
clickSound.SoundId = "rbxassetid://6895079853"
clickSound.Volume = 0.25
clickSound.PlaybackSpeed = 2
clickSound.Parent = SoundFolder
local function click()
    pcall(function()
        clickSound:Stop()
        clickSound:Play()
    end)
end

local gui = Instance.new("ScreenGui")
gui.Name = "Hamer"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local blur = Instance.new("BlurEffect")
blur.Name = "HamerBlur"
blur.Size = 0
blur.Parent = Lighting

local dim = Instance.new("Frame")
dim.Size = UDim2.new(1, 0, 1, 0)
dim.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
dim.BackgroundTransparency = 1
dim.BorderSizePixel = 0
dim.Visible = false
dim.ZIndex = 5
dim.Parent = gui

local main = Instance.new("Frame")
main.Name = "Main"
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.new(0.5, 0, 0.5, 0)
main.Size = UDim2.new(0, 600, 0, 390)
main.BackgroundColor3 = Color3.fromRGB(14, 18, 28)
main.BackgroundTransparency = 0.04
main.BorderSizePixel = 0
main.Visible = false
main.ZIndex = 10
main.Parent = gui
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 18)
mainCorner.Parent = main
local mainStroke = Instance.new("UIStroke")
mainStroke.Color = accent()
mainStroke.Transparency = 0.55
mainStroke.Thickness = 1.5
mainStroke.Parent = main

local uiScale = Instance.new("UIScale")
uiScale.Parent = main

local function computeScale()
    local vp = Camera.ViewportSize
    local sc
    if S.Mobile then
        sc = math.min((vp.X - 16) / 600, (vp.Y - 16) / 390)
        return clamp(sc, 0.7, 2.4)
    end
    sc = math.min((vp.X - 60) / 600, (vp.Y - 60) / 390, 1.15)
    return clamp(sc, 0.6, 1.15)
end
uiScale.Scale = computeScale()
conn(Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    if S.MenuOpen then
        uiScale.Scale = computeScale()
    end
end))

local themeFns = {}
local function bindAccent(fn)
    table.insert(themeFns, fn)
    fn(accent())
end
local function applyAccent()
    local c = accent()
    for _, fn in ipairs(themeFns) do
        pcall(fn, c)
    end
end

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 52)
header.BackgroundTransparency = 1
header.ZIndex = 11
header.Parent = main

local hline = Instance.new("Frame")
hline.Size = UDim2.new(1, -28, 0, 1)
hline.Position = UDim2.new(0, 14, 0, 51)
hline.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
hline.BackgroundTransparency = 0.88
hline.BorderSizePixel = 0
hline.ZIndex = 11
hline.Parent = header

local logo = Instance.new("TextLabel")
logo.Text = "H"
logo.Font = FONT_BLACK
logo.TextSize = 26
logo.TextColor3 = accent()
logo.Size = UDim2.new(0, 36, 0, 36)
logo.Position = UDim2.new(0, 20, 0, 8)
logo.BackgroundTransparency = 1
logo.ZIndex = 12
logo.Parent = header
bindAccent(function(c) logo.TextColor3 = c end)

local title = Instance.new("TextLabel")
title.Text = "HAMER"
title.Font = FONT_BLACK
title.TextSize = FS(17)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Size = UDim2.new(0, 150, 0, 22)
title.Position = UDim2.new(0, 58, 0, 7)
title.BackgroundTransparency = 1
title.ZIndex = 12
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Text = "VISUAL CLIENT"
subtitle.Font = FONT_BOLD
subtitle.TextSize = FS(10)
subtitle.TextColor3 = Color3.fromRGB(255, 255, 255)
subtitle.TextTransparency = 0.5
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Size = UDim2.new(0, 150, 0, 14)
subtitle.Position = UDim2.new(0, 58, 0, 27)
subtitle.BackgroundTransparency = 1
subtitle.ZIndex = 12
subtitle.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Text = "×"
closeBtn.Font = FONT_REG
closeBtn.TextSize = FS(24)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextTransparency = 0.35
closeBtn.Size = UDim2.new(0, S.Mobile and 44 or 34, 0, S.Mobile and 44 or 34)
closeBtn.Position = UDim2.new(1, S.Mobile and -54 or -46, 0, S.Mobile and 4 or 9)
closeBtn.BackgroundTransparency = 1
closeBtn.AutoButtonColor = false
closeBtn.ZIndex = 13
closeBtn.Parent = header

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -28, 0, 34)
tabBar.Position = UDim2.new(0, 14, 0, 56)
tabBar.BackgroundTransparency = 1
tabBar.ZIndex = 11
tabBar.Parent = main
local tabList = Instance.new("UIListLayout")
tabList.FillDirection = Enum.FillDirection.Horizontal
tabList.Padding = UDim.new(0, 6)
tabList.SortOrder = Enum.SortOrder.LayoutOrder
tabList.Parent = tabBar

local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -20, 1, -100)
content.Position = UDim2.new(0, 10, 0, 94)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 3
content.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.ZIndex = 11
content.Parent = main
local contentPad = Instance.new("UIPadding")
contentPad.PaddingLeft = UDim.new(0, 6)
contentPad.PaddingRight = UDim.new(0, 6)
contentPad.PaddingTop = UDim.new(0, 4)
contentPad.PaddingBottom = UDim.new(0, 16)
contentPad.Parent = content
local contentList = Instance.new("UIListLayout")
contentList.Padding = UDim.new(0, 8)
contentList.SortOrder = Enum.SortOrder.LayoutOrder
contentList.Parent = content
contentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    content.CanvasSize = UDim2.new(0, 0, 0, contentList.AbsoluteContentSize.Y + 20)
end)

local builders = {}
local tabButtons = {}
local currentTab = "combat"
local tabs = {
    {id = "combat", label = "Combat"},
    {id = "visual", label = "Visual"},
    {id = "cosmetics", label = "Cosmetics"},
    {id = "misc", label = "Misc"}
}

local function clearContent()
    for _, ch in ipairs(content:GetChildren()) do
        if ch:IsA("GuiObject") then
            ch:Destroy()
        end
    end
end

local function selectTab(id)
    currentTab = id
    for tid, b in pairs(tabButtons) do
        local on = tid == id
        b.fill.BackgroundColor3 = accent()
        b.fill.BackgroundTransparency = on and 0.12 or 1
        b.stroke.Color = on and accent() or Color3.fromRGB(255, 255, 255)
        b.stroke.Transparency = on and 0.5 or 1
        b.txt.TextTransparency = on and 0 or 0.5
        b.txt.Font = on and FONT_BOLD or FONT_REG
    end
    clearContent()
    if builders[id] then
        local ok, err = pcall(builders[id])
        if not ok then
            warn("hamer ui error: " .. tostring(err))
        end
    end
    content.CanvasPosition = Vector2.new(0, 0)
end

for i, t in ipairs(tabs) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, S.Mobile and 128 or 124, 0, S.Mobile and 36 or 32)
    b.BackgroundTransparency = 1
    b.Text = ""
    b.AutoButtonColor = false
    b.LayoutOrder = i
    b.ZIndex = 12
    b.Parent = tabBar

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(1, 0, 1, 0)
    fill.BackgroundColor3 = accent()
    fill.BackgroundTransparency = 1
    fill.BorderSizePixel = 0
    fill.ZIndex = 12
    fill.Parent = b
    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(0, 8)
    fc.Parent = fill
    local fs = Instance.new("UIStroke")
    fs.Color = Color3.fromRGB(255, 255, 255)
    fs.Transparency = 1
    fs.Thickness = 1.2
    fs.Parent = fill

    local txt = Instance.new("TextLabel")
    txt.Text = t.label
    txt.Font = FONT_REG
    txt.TextSize = FS(13)
    txt.TextColor3 = Color3.fromRGB(255, 255, 255)
    txt.TextTransparency = 0.5
    txt.BackgroundTransparency = 1
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.ZIndex = 13
    txt.Parent = fill

    tabButtons[t.id] = {btn = b, fill = fill, stroke = fs, txt = txt}
    b.MouseButton1Click:Connect(function()
        selectTab(t.id)
        click()
    end)
end

local function baseRow(height)
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, -12, 0, height or 46)
    row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    row.BackgroundTransparency = 0.94
    row.BorderSizePixel = 0
    row.Text = ""
    row.AutoButtonColor = false
    row.ZIndex = 12
    row.Parent = content
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 10)
    c.Parent = row
    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(255, 255, 255)
    s.Transparency = 0.9
    s.Thickness = 1
    s.Parent = row
    return row, s
end

local function makeLabel(row, text, sub)
    local lbl = Instance.new("TextLabel")
    lbl.Text = text
    lbl.Font = FONT_BOLD
    lbl.TextSize = FS(13)
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextTransparency = 0.05
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.BackgroundTransparency = 1
    lbl.ZIndex = 13
    lbl.Parent = row
    if sub then
        lbl.Size = UDim2.new(1, -150, 0, 20)
        lbl.Position = UDim2.new(0, 14, 0, 6)
        local d = Instance.new("TextLabel")
        d.Text = sub
        d.Font = FONT_REG
        d.TextSize = FS(11)
        d.TextColor3 = Color3.fromRGB(255, 255, 255)
        d.TextTransparency = 0.5
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.TextWrapped = true
        d.BackgroundTransparency = 1
        d.Size = UDim2.new(1, -150, 0, 16)
        d.Position = UDim2.new(0, 14, 0, 25)
        d.ZIndex = 13
        d.Parent = row
    else
        lbl.Size = UDim2.new(1, -150, 1, 0)
        lbl.Position = UDim2.new(0, 14, 0, 0)
    end
    return lbl
end

local function sectionRow(text)
    local l = Instance.new("TextLabel")
    l.Text = text
    l.Font = FONT_BOLD
    l.TextSize = FS(10)
    l.TextColor3 = accent()
    l.TextTransparency = 0.1
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Size = UDim2.new(1, -12, 0, 20)
    l.BackgroundTransparency = 1
    l.ZIndex = 12
    l.Parent = content
    bindAccent(function(c) l.TextColor3 = c end)
    return l
end

local function toggleRow(text, key, onChange)
    local row, st = baseRow(RH(46))
    makeLabel(row, text, nil)
    local sw = Instance.new("Frame")
    local swW = S.Mobile and 46 or 38
    local swH = S.Mobile and 24 or 20
    local knobS = S.Mobile and 20 or 16
    sw.Size = UDim2.new(0, swW, 0, swH)
    sw.Position = UDim2.new(1, -14 - swW, 0.5, -swH / 2)
    sw.BackgroundTransparency = 1
    sw.ZIndex = 13
    sw.Parent = row
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(1, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(70, 76, 92)
    fill.BackgroundTransparency = 0.25
    fill.BorderSizePixel = 0
    fill.ZIndex = 13
    fill.Parent = sw
    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(1, 0)
    fc.Parent = fill
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, knobS, 0, knobS)
    knob.Position = UDim2.new(0, 2, 0.5, -knobS / 2)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 14
    knob.Parent = fill
    local kc = Instance.new("UICorner")
    kc.CornerRadius = UDim.new(1, 0)
    kc.Parent = knob

    local function refresh()
        local c = accent()
        if S[key] then
            fill.BackgroundColor3 = c
            fill.BackgroundTransparency = 0.1
            knob.Position = UDim2.new(1, -knobS - 2, 0.5, -knobS / 2)
            st.Color = c
            st.Transparency = 0.55
        else
            fill.BackgroundColor3 = Color3.fromRGB(70, 76, 92)
            fill.BackgroundTransparency = 0.25
            knob.Position = UDim2.new(0, 2, 0.5, -knobS / 2)
            st.Color = Color3.fromRGB(255, 255, 255)
            st.Transparency = 0.9
        end
    end

    row.MouseButton1Click:Connect(function()
        S[key] = not S[key]
        refresh()
        click()
        if onChange then onChange(S[key]) end
    end)
    refresh()
end

local function stepRow(text, key, minv, maxv, step, suffix, onChange)
    local row, st = baseRow(RH(46))
    makeLabel(row, text, nil)
    local val = Instance.new("TextLabel")
    val.Font = FONT_BOLD
    val.TextSize = FS(13)
    val.TextColor3 = accent()
    val.Size = UDim2.new(0, 62, 0, 20)
    val.Position = UDim2.new(1, S.Mobile and -156 or -146, 0.5, -10)
    val.TextXAlignment = Enum.TextXAlignment.Right
    val.BackgroundTransparency = 1
    val.ZIndex = 13
    val.Parent = row
    bindAccent(function(c) val.TextColor3 = c end)

    local function refresh()
        local v = S[key]
        if type(v) == "number" then
            if v == math.floor(v) then
                val.Text = tostring(math.floor(v)) .. (suffix or "")
            else
                val.Text = string.format("%.2f", v) .. (suffix or "")
            end
        end
        st.Color = accent()
        st.Transparency = 0.85
    end

    local function mkBtn(txt, xoff)
        local bsz = S.Mobile and 34 or 28
        local b = Instance.new("TextButton")
        b.Text = txt
        b.Font = FONT_BOLD
        b.TextSize = FS(18)
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.TextTransparency = 0.1
        b.Size = UDim2.new(0, bsz, 0, bsz)
        b.Position = UDim2.new(1, xoff, 0.5, -bsz / 2)
        b.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        b.BackgroundTransparency = 0.9
        b.AutoButtonColor = false
        b.ZIndex = 14
        b.Parent = row
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 8)
        c.Parent = b
        return b
    end

    local minus = mkBtn("−", S.Mobile and -92 or -80)
    local plus = mkBtn("+", S.Mobile and -50 or -46)

    minus.MouseButton1Click:Connect(function()
        S[key] = clamp(S[key] - step, minv, maxv)
        refresh()
        click()
        if onChange then onChange(S[key]) end
    end)
    plus.MouseButton1Click:Connect(function()
        S[key] = clamp(S[key] + step, minv, maxv)
        refresh()
        click()
        if onChange then onChange(S[key]) end
    end)
    refresh()
end

local function actionRow(text, sub, callback)
    local row, st = baseRow(sub and RH(58) or RH(46))
    makeLabel(row, text, sub)
    local arrow = Instance.new("TextLabel")
    arrow.Text = "›"
    arrow.Font = FONT_BOLD
    arrow.TextSize = FS(22)
    arrow.TextColor3 = Color3.fromRGB(255, 255, 255)
    arrow.TextTransparency = 0.4
    arrow.Size = UDim2.new(0, 26, 1, 0)
    arrow.Position = UDim2.new(1, -34, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.ZIndex = 13
    arrow.Parent = row
    row.MouseButton1Click:Connect(function()
        click()
        if callback then callback() end
    end)
    row.MouseEnter:Connect(function()
        st.Color = accent()
        st.Transparency = 0.5
        tw(row, 0.12, {BackgroundTransparency = 0.9})
    end)
    row.MouseLeave:Connect(function()
        st.Color = Color3.fromRGB(255, 255, 255)
        st.Transparency = 0.9
        tw(row, 0.12, {BackgroundTransparency = 0.94})
    end)
end

local function colorRow(text, key, onChange)
    local row = baseRow(RH(46))
    makeLabel(row, text, nil)
    local colors = {
        Color3.fromRGB(0, 229, 255),
        Color3.fromRGB(255, 120, 200),
        Color3.fromRGB(255, 78, 100),
        Color3.fromRGB(160, 240, 90),
        Color3.fromRGB(186, 120, 255),
        Color3.fromRGB(255, 205, 80),
        Color3.fromRGB(255, 255, 255)
    }
    local csz = S.Mobile and 26 or 20
    local gap = S.Mobile and 30 or 26
    for i, col in ipairs(colors) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, csz, 0, csz)
        b.Position = UDim2.new(1, -14 - csz - (#colors - i) * gap, 0.5, -csz / 2)
        b.BackgroundColor3 = col
        b.BorderSizePixel = 0
        b.Text = ""
        b.AutoButtonColor = false
        b.ZIndex = 14
        b.Parent = row
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(1, 0)
        c.Parent = b
        local s = Instance.new("UIStroke")
        s.Color = Color3.fromRGB(255, 255, 255)
        s.Transparency = 0.6
        s.Parent = b
        b.MouseButton1Click:Connect(function()
            S[key] = col
            click()
            if onChange then onChange(col) end
        end)
    end
end

local function textRow(labelText, key, placeholder)
    local row = baseRow(RH(46))
    makeLabel(row, labelText, nil)
    local bw = S.Mobile and 200 or 180
    local bh = S.Mobile and 36 or 30
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0, bw, 0, bh)
    box.Position = UDim2.new(1, -14 - bw, 0.5, -bh / 2)
    box.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    box.BackgroundTransparency = 0.92
    box.BorderSizePixel = 0
    box.Font = FONT_REG
    box.TextSize = FS(12)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.PlaceholderText = placeholder or ""
    box.PlaceholderColor3 = Color3.fromRGB(150, 160, 180)
    box.Text = tostring(S[key] or "")
    box.ClearTextOnFocus = false
    box.ZIndex = 14
    box.Parent = row
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = box
    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(255, 255, 255)
    s.Transparency = 0.8
    s.Parent = box
    box:GetPropertyChangedSignal("Text"):Connect(function()
        S[key] = box.Text
    end)
end

local function themeRow()
    local row = baseRow(RH(50))
    makeLabel(row, "Accent", nil)
    local csz = S.Mobile and 26 or 22
    local gap = S.Mobile and 30 or 27
    for i, name in ipairs(ACCENT_ORDER) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, csz, 0, csz)
        b.Position = UDim2.new(1, -14 - csz - (#ACCENT_ORDER - i) * gap, 0.5, -csz / 2)
        b.BackgroundColor3 = ACCENTS[name]
        b.BorderSizePixel = 0
        b.Text = ""
        b.AutoButtonColor = false
        b.ZIndex = 14
        b.Parent = row
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(1, 0)
        c.Parent = b
        local s = Instance.new("UIStroke")
        s.Color = Color3.fromRGB(255, 255, 255)
        s.Transparency = (S.Accent == name) and 0.1 or 0.7
        s.Thickness = (S.Accent == name) and 2 or 1
        s.Parent = b
        b.MouseButton1Click:Connect(function()
            S.Accent = name
            applyAccent()
            click()
            task.defer(function()
                if not Unloaded and S.MenuOpen then
                    selectTab(currentTab)
                end
            end)
        end)
    end
end

local toggler = Instance.new("TextButton")
toggler.Size = UDim2.new(0, S.Mobile and 58 or 46, 0, S.Mobile and 58 or 46)
toggler.Position = UDim2.new(1, S.Mobile and -74 or -62, 0, S.Mobile and 72 or 60)
toggler.Text = "H"
toggler.Font = FONT_BLACK
toggler.TextSize = FS(20)
toggler.TextColor3 = accent()
toggler.BackgroundColor3 = Color3.fromRGB(14, 18, 28)
toggler.BackgroundTransparency = 0.12
toggler.BorderSizePixel = 0
toggler.AutoButtonColor = false
toggler.ZIndex = 30
toggler.Parent = gui
local tc = Instance.new("UICorner")
tc.CornerRadius = UDim.new(0, 13)
tc.Parent = toggler
local ts = Instance.new("UIStroke")
ts.Color = accent()
ts.Transparency = 0.4
ts.Thickness = 1.2
ts.Parent = toggler
bindAccent(function(c)
    toggler.TextColor3 = c
    ts.Color = c
end)

local function setMenu(open)
    S.MenuOpen = open
    toggler.Visible = not open
    if open then
        main.Visible = true
        uiScale.Scale = computeScale() * 0.9
        tw(uiScale, 0.24, {Scale = computeScale()}, Enum.EasingStyle.Back)
        tw(blur, 0.3, {Size = 16})
        dim.Visible = true
        dim.BackgroundTransparency = 1
        tw(dim, 0.3, {BackgroundTransparency = 0.45})
    else
        tw(blur, 0.24, {Size = 0})
        tw(dim, 0.24, {BackgroundTransparency = 1})
        uiScale.Scale = computeScale()
        tw(uiScale, 0.18, {Scale = computeScale() * 0.9}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        task.delay(0.2, function()
            if not S.MenuOpen then
                main.Visible = false
                dim.Visible = false
                uiScale.Scale = computeScale()
            end
        end)
    end
end

closeBtn.MouseButton1Click:Connect(function()
    setMenu(false)
    click()
end)
toggler.MouseButton1Click:Connect(function()
    setMenu(true)
    click()
end)

conn(UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        setMenu(not S.MenuOpen)
    end
end))

local dragging, dragStart, startPos = false, nil, nil
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)
conn(UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end))
conn(UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end))
local espGui = Instance.new("ScreenGui")
espGui.Name = "HamerESP"
espGui.ResetOnSpawn = false
espGui.IgnoreGuiInset = true
espGui.DisplayOrder = 998
espGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
espGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local ESP_BOXES = {}
local function makeESPBox(plr)
    local frame = Instance.new("Frame")
    frame.Name = "ESP_" .. plr.Name
    frame.BackgroundColor3 = S.ESPColor
    frame.BackgroundTransparency = 0.94
    frame.BorderSizePixel = 0
    frame.Visible = false
    frame.ZIndex = 1
    frame.Parent = espGui
    local st = Instance.new("UIStroke")
    st.Color = S.ESPColor
    st.Thickness = 1.5
    st.Transparency = 0.1
    st.Parent = frame
    local nameLbl = Instance.new("TextLabel")
    nameLbl.Text = plr.Name
    nameLbl.Font = FONT_BOLD
    nameLbl.TextSize = 13
    nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLbl.TextStrokeTransparency = 0.4
    nameLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Size = UDim2.new(0, 160, 0, 16)
    nameLbl.Position = UDim2.new(0.5, -80, 0, -19)
    nameLbl.ZIndex = 2
    nameLbl.Parent = frame
    local distLbl = Instance.new("TextLabel")
    distLbl.Text = ""
    distLbl.Font = FONT_BOLD
    distLbl.TextSize = 11
    distLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    distLbl.TextStrokeTransparency = 0.4
    distLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distLbl.BackgroundTransparency = 1
    distLbl.Size = UDim2.new(0, 100, 0, 14)
    distLbl.Position = UDim2.new(0.5, -50, 1, 3)
    distLbl.ZIndex = 2
    distLbl.Parent = frame
    return {frame = frame, stroke = st, name = nameLbl, dist = distLbl}
end

local function updateESP()
    if not S.ESP then
        for _, b in pairs(ESP_BOXES) do
            if b.frame then b.frame.Visible = false end
        end
        return
    end
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local box = ESP_BOXES[plr]
            if not box then
                box = makeESPBox(plr)
                ESP_BOXES[plr] = box
            end
            local char = plr.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if char and hum and hum.Health > 0 then
                local cf, size = char:GetBoundingBox()
                local headPos = cf.Position + Vector3.new(0, size.Y / 2, 0)
                local feetPos = cf.Position - Vector3.new(0, size.Y / 2, 0)
                local a, onA = Camera:WorldToViewportPoint(headPos)
                local b, onB = Camera:WorldToViewportPoint(feetPos)
                if (onA or onB) and a.Z > 0 and b.Z > 0 then
                    local top = math.min(a.Y, b.Y)
                    local bottom = math.max(a.Y, b.Y)
                    local h = math.max(bottom - top, 12)
                    local w = clamp(h * 0.55, 20, 400)
                    local cx = (a.X + b.X) / 2
                    box.frame.Visible = true
                    box.frame.Position = UDim2.new(0, cx - w / 2, 0, top)
                    box.frame.Size = UDim2.new(0, w, 0, h)
                    box.frame.BackgroundColor3 = S.ESPColor
                    box.stroke.Color = S.ESPColor
                    box.name.Visible = S.ESPNames
                    box.name.Text = plr.Name
                    box.dist.Visible = S.ESPDist
                    if myRoot then
                        box.dist.Text = math.floor((myRoot.Position - cf.Position).Magnitude) .. "m"
                    else
                        box.dist.Text = ""
                    end
                    box.name.Position = UDim2.new(0.5, -80, 0, -19)
                else
                    box.frame.Visible = false
                end
            else
                box.frame.Visible = false
            end
        end
    end
end

conn(Players.PlayerRemoving:Connect(function(plr)
    local box = ESP_BOXES[plr]
    if box then
        if box.frame then box.frame:Destroy() end
        ESP_BOXES[plr] = nil
    end
end))
conn(RunService.RenderStepped:Connect(function()
    if not Unloaded then updateESP() end
end))

local lightBase = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    GlobalShadows = Lighting.GlobalShadows
}

local function applyFullbright()
    if S.Fullbright then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
    else
        Lighting.Ambient = lightBase.Ambient
        Lighting.OutdoorAmbient = lightBase.OutdoorAmbient
        Lighting.Brightness = lightBase.Brightness
        Lighting.ClockTime = lightBase.ClockTime
        Lighting.GlobalShadows = lightBase.GlobalShadows
    end
end

local function applyFog()
    local old = Lighting:FindFirstChild("HamerFog")
    if old then old:Destroy() end
    if not S.Fog then return end
    local a = Instance.new("Atmosphere")
    a.Name = "HamerFog"
    a.Density = clamp(S.FogDensity, 0, 1)
    a.Offset = 0.25
    a.Color = Color3.fromRGB(200, 205, 220)
    a.Decay = Color3.fromRGB(95, 105, 135)
    a.Haze = 1.5
    a.Glare = 0
    a.Parent = Lighting
end

local function applyWorld()
    local old = Lighting:FindFirstChild("HamerWorld")
    if old then old:Destroy() end
    if not S.World then return end
    local cc = Instance.new("ColorCorrectionEffect")
    cc.Name = "HamerWorld"
    cc.Saturation = S.WorldSaturation
    cc.Contrast = S.WorldContrast
    cc.Brightness = 0
    cc.TintColor = Color3.fromRGB(255, 255, 255)
    cc.Parent = Lighting
end

local mbEffect = Instance.new("BlurEffect")
mbEffect.Name = "HamerMotionBlur"
mbEffect.Size = 0
mbEffect.Parent = Lighting
local mbLast = nil
local mbAmount = 0
conn(RunService.RenderStepped:Connect(function(dt)
    if Unloaded then return end
    if not S.MotionBlur then
        mbAmount = 0
        mbEffect.Size = 0
        mbLast = nil
        return
    end
    local look = Camera.CFrame.LookVector
    local speed = 0
    if mbLast then
        local dot = clamp(look:Dot(mbLast), -1, 1)
        speed = math.acos(dot) / math.max(dt, 0.001)
    end
    mbLast = look
    local target = clamp(speed * 2, 0, S.MotionBlurStrength)
    mbAmount = mbAmount + (target - mbAmount) * math.min(dt * 10, 1)
    mbEffect.Size = mbAmount
end))

local aspectBase, aspectLast = nil, nil
conn(RunService.RenderStepped:Connect(function()
    if Unloaded then return end
    if S.Aspect then
        local cur = Camera.CFrame
        if not aspectBase or (aspectLast and (cur.Position - aspectLast.Position).Magnitude > 0.001) then
            aspectBase = cur
        end
        aspectLast = cur
        Camera.CFrame = aspectBase * CFrame.new(0, 0, 0, 1, 0, 0, 0, S.AspectValue, 0, 0, 0, 1)
    else
        aspectBase = nil
        aspectLast = nil
    end
end))

local fovCircle = Instance.new("Frame")
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.BackgroundTransparency = 1
fovCircle.BorderSizePixel = 0
fovCircle.Visible = false
fovCircle.ZIndex = 6
fovCircle.Parent = gui
local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(1, 0)
fovCorner.Parent = fovCircle
local fovStroke = Instance.new("UIStroke")
fovStroke.Color = accent()
fovStroke.Thickness = 1.4
fovStroke.Transparency = 0.35
fovStroke.Parent = fovCircle
bindAccent(function(c) fovStroke.Color = c end)

local flyBV, flyBG = nil, nil
local noclipSaved = {}
local hitboxSaved = {}
local hitboxAcc = 0
local autoAcc = 0
local speedWasOn = false
local jumpWasOn = false

local function updateFly(char, hum, root)
    if S.Fly and char and hum and root then
        if not flyBV then
            flyBV = Instance.new("BodyVelocity")
            flyBV.Name = "HamerFly"
            flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            flyBV.Velocity = Vector3.zero
            flyBV.Parent = root
        end
        if not flyBG then
            flyBG = Instance.new("BodyGyro")
            flyBG.Name = "HamerGyro"
            flyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
            flyBG.P = 1500
            flyBG.D = 60
            flyBG.Parent = root
        end
        hum.PlatformStand = true
        local move = Vector3.zero
        local cf = Camera.CFrame
        if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0, 1, 0) end
        if move.Magnitude > 0 then
            flyBV.Velocity = move.Unit * S.FlySpeed
        else
            flyBV.Velocity = Vector3.zero
        end
        flyBG.CFrame = cf
    else
        if flyBV then flyBV:Destroy(); flyBV = nil end
        if flyBG then flyBG:Destroy(); flyBG = nil end
        if hum then hum.PlatformStand = false end
    end
end

conn(RunService.Heartbeat:Connect(function(dt)
    if Unloaded then return end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")

    if hum then
        if S.Speed then
            hum.WalkSpeed = S.SpeedValue
            speedWasOn = true
        elseif speedWasOn then
            hum.WalkSpeed = 16
            speedWasOn = false
        end
        if S.Jump then
            hum.UseJumpPower = true
            hum.JumpPower = S.JumpValue
            jumpWasOn = true
        elseif jumpWasOn then
            hum.JumpPower = 50
            jumpWasOn = false
        end
    end

    updateFly(char, hum, root)

    if char then
        if S.Noclip then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and noclipSaved[p] == nil then
                    noclipSaved[p] = p.CanCollide
                    p.CanCollide = false
                end
            end
        else
            for p, v in pairs(noclipSaved) do
                if p.Parent then p.CanCollide = v end
            end
            noclipSaved = {}
        end
    end

    hitboxAcc = hitboxAcc + dt
    if hitboxAcc >= 0.3 then
        hitboxAcc = 0
        if S.Hitbox then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    local r = plr.Character:FindFirstChild("HumanoidRootPart")
                    if r then
                        if hitboxSaved[r] == nil then hitboxSaved[r] = r.Size end
                        r.Size = Vector3.new(S.HitboxSize, S.HitboxSize, S.HitboxSize)
                    end
                end
            end
        else
            for p, v in pairs(hitboxSaved) do
                if p.Parent then p.Size = v end
            end
            hitboxSaved = {}
        end
    end

    if S.AutoCollect and char and root then
        autoAcc = autoAcc + dt
        if autoAcc >= 0.6 then
            autoAcc = 0
            local best, bestD = nil, 60
            for _, d in ipairs(Workspace:GetDescendants()) do
                if d:IsA("BasePart") and not d:IsDescendantOf(char) then
                    local n = string.lower(d.Name)
                    if string.find(n, "coin") or string.find(n, "cash") or string.find(n, "gem") or string.find(n, "money") or string.find(n, "diamond") then
                        local dist = (d.Position - root.Position).Magnitude
                        if dist < bestD then
                            bestD = dist
                            best = d
                        end
                    end
                end
            end
            if best then
                root.CFrame = CFrame.new(best.Position + Vector3.new(0, 3, 0))
            end
        end
    end
end))

conn(UIS.JumpRequest:Connect(function()
    if not S.InfJump then return end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end))

local afkConn = nil
local function setAntiAfk(on)
    S.AntiAfk = on
    if on and not afkConn then
        afkConn = LocalPlayer.Idled:Connect(function()
            local vu = game:GetService("VirtualUser")
            pcall(function()
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
            end)
        end)
    elseif not on and afkConn then
        afkConn:Disconnect()
        afkConn = nil
    end
end

conn(RunService.RenderStepped:Connect(function()
    if Unloaded then return end
    fovCircle.Visible = S.Aimbot
    if not S.Aimbot then return end
    fovCircle.Size = UDim2.new(0, S.AimbotFOV * 2, 0, S.AimbotFOV * 2)
    local vp = Camera.ViewportSize
    local center = Vector2.new(vp.X / 2, vp.Y / 2)
    local best, bestD = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local part = char and (char:FindFirstChild(S.AimbotPart) or char:FindFirstChild("HumanoidRootPart"))
            if hum and hum.Health > 0 and part then
                local sp, on = Camera:WorldToViewportPoint(part.Position)
                if on then
                    local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                    if d <= S.AimbotFOV and d < bestD then
                        bestD = d
                        best = part
                    end
                end
            end
        end
    end
    if best then
        local goal = CFrame.new(Camera.CFrame.Position, best.Position)
        Camera.CFrame = Camera.CFrame:Lerp(goal, clamp(1 - S.AimbotSmooth, 0.03, 1))
    end
end))

local Drone = {model = nil, conn = nil, active = false, t = 0}

local function mkDronePart(model, name, shape, size, cf, material, color)
    local p = Instance.new("Part")
    p.Name = name
    p.Shape = shape
    p.Size = size
    p.CFrame = cf
    p.Anchored = true
    p.CanCollide = false
    p.CanQuery = false
    p.CanTouch = false
    p.CastShadow = false
    p.Material = material
    p.Color = color
    p.Parent = model
    return p
end

local function createDroneModel()
    local model = Instance.new("Model")
    model.Name = "HamerDrone"
    local body = mkDronePart(model, "Fuselage", Enum.PartType.Block, Vector3.new(0.9, 0.7, 3.2), CFrame.new(0, 0, 0), Enum.Material.Metal, Color3.fromRGB(205, 210, 220))
    local wingL = mkDronePart(model, "WingL", Enum.PartType.Block, Vector3.new(3.2, 0.1, 1.1), CFrame.new(-1.4, 0, 0.4), Enum.Material.Metal, Color3.fromRGB(190, 195, 205))
    local wingR = mkDronePart(model, "WingR", Enum.PartType.Block, Vector3.new(3.2, 0.1, 1.1), CFrame.new(1.4, 0, 0.4), Enum.Material.Metal, Color3.fromRGB(190, 195, 205))
    local prop = mkDronePart(model, "Propeller", Enum.PartType.Block, Vector3.new(0.12, 1.5, 0.12), CFrame.new(0, 0, 1.9), Enum.Material.Wood, Color3.fromRGB(190, 150, 100))
    local nose = mkDronePart(model, "Nose", Enum.PartType.Ball, Vector3.new(0.6, 0.6, 0.9), CFrame.new(0, 0, -1.7), Enum.Material.Metal, Color3.fromRGB(60, 65, 75))
    model.PrimaryPart = body
    return model, prop
end

local function stopDrone()
    Drone.active = false
    S.DroneActive = false
    if Drone.conn then Drone.conn:Disconnect(); Drone.conn = nil end
    if Drone.model and Drone.model.Parent then Drone.model:Destroy() end
    Drone.model = nil
end

local function startDrone()
    if Drone.active then return end
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local model, prop = createDroneModel()
    model:PivotTo(CFrame.new(root.Position + root.CFrame.LookVector * 4 + Vector3.new(0, 4, 0)))
    model.Parent = Workspace
    Drone.model = model
    Drone.active = true
    S.DroneActive = true
    Drone.t = 0
    local target, bestDist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local r = p.Character:FindFirstChild("HumanoidRootPart")
            if r then
                local d = (r.Position - root.Position).Magnitude
                if d < bestDist then
                    bestDist = d
                    target = p
                end
            end
        end
    end
    Drone.conn = RunService.Heartbeat:Connect(function(dt)
        if not Drone.active or not model.Parent then return end
        Drone.t = Drone.t + dt
        local fus = model:FindFirstChild("Fuselage")
        if not fus then return end
        local targetPos
        if target and target.Character then
            local tr = target.Character:FindFirstChild("HumanoidRootPart")
            if tr then targetPos = tr.Position end
        end
        if not targetPos then
            targetPos = fus.Position + fus.CFrame.LookVector * 10
        end
        local dir = targetPos - fus.Position
        if dir.Magnitude > 0.1 then
            model:PivotTo(CFrame.lookAt(fus.Position + dir.Unit * 45 * dt, targetPos))
        end
        if prop and prop.Parent then
            prop.CFrame = fus.CFrame * CFrame.new(0, 0, 1.9) * CFrame.Angles(0, 0, Drone.t * 35)
        end
        if target and target.Character then
            local tr = target.Character:FindFirstChild("HumanoidRootPart")
            if tr and (tr.Position - fus.Position).Magnitude < 3 then
                local hum = target.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.Health = 0 end
                stopDrone()
            end
        end
        if Drone.t > 30 then stopDrone() end
    end)
end

builders.combat = function()
    sectionRow("MOVEMENT")
    toggleRow("Speed", "Speed")
    stepRow("Walk speed", "SpeedValue", 16, 200, 4, "")
    toggleRow("Jump power", "Jump")
    stepRow("Jump value", "JumpValue", 50, 300, 10, "")
    toggleRow("Infinite jump", "InfJump")
    toggleRow("Fly", "Fly")
    stepRow("Fly speed", "FlySpeed", 10, 200, 5, "")
    toggleRow("Noclip", "Noclip")
    sectionRow("COMBAT")
    toggleRow("Aimbot", "Aimbot")
    stepRow("Aimbot FOV", "AimbotFOV", 40, 400, 10, " px")
    stepRow("Aimbot smooth", "AimbotSmooth", 0, 0.9, 0.05, "")
    toggleRow("Hitbox expander", "Hitbox")
    stepRow("Hitbox size", "HitboxSize", 2, 30, 1, "")
    toggleRow("Auto collect", "AutoCollect")
    toggleRow("Anti AFK", "AntiAfk", setAntiAfk)
    actionRow("Kamikaze Drone", "Fly to nearest player and explode.", function()
        if Drone.active then stopDrone() else startDrone() end
    end)
end

builders.visual = function()
    sectionRow("PLAYERS")
    toggleRow("ESP 2D", "ESP")
    toggleRow("Show names", "ESPNames")
    toggleRow("Show distance", "ESPDist")
    colorRow("ESP color", "ESPColor")
    sectionRow("LIGHTING")
    toggleRow("Fullbright", "Fullbright", applyFullbright)
    toggleRow("Fog", "Fog", applyFog)
    stepRow("Fog density", "FogDensity", 0, 1, 0.05, "", applyFog)
    toggleRow("Watermark", "Watermark")
    sectionRow("EFFECTS")
    toggleRow("Motion blur", "MotionBlur")
    stepRow("Blur strength", "MotionBlurStrength", 0, 56, 2, "")
    toggleRow("Aspect", "Aspect")
    stepRow("Aspect value", "AspectValue", 0.5, 1.5, 0.05, "")
    toggleRow("World color", "World", applyWorld)
    stepRow("Saturation", "WorldSaturation", -1, 1, 0.1, "", applyWorld)
    stepRow("Contrast", "WorldContrast", -1, 1, 0.1, "", applyWorld)
    sectionRow("INTERFACE")
    themeRow()
end
local function neonPart(parent, shape, size, color, glow)
    local p = Instance.new("Part")
    p.Shape = shape
    p.Size = size
    p.Anchored = true
    p.CanCollide = false
    p.CanQuery = false
    p.CanTouch = false
    p.CastShadow = false
    p.Massless = true
    if glow then
        p.Material = Enum.Material.Neon
    else
        p.Material = Enum.Material.SmoothPlastic
    end
    p.Color = color
    p.Parent = parent
    return p
end

local Dong = {model = nil, conn = nil}
local function applyDong()
    if Dong.conn then Dong.conn:Disconnect(); Dong.conn = nil end
    if Dong.model then Dong.model:Destroy(); Dong.model = nil end
    if not S.Dong then return end
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local s = S.DongSize
    local model = Instance.new("Model")
    model.Name = "HamerDong"
    model.Parent = Workspace
    Dong.model = model
    local ballL = neonPart(model, Enum.PartType.Ball, Vector3.new(0.56 * s, 0.56 * s, 0.56 * s), S.DongColor, S.DongGlow)
    local ballR = neonPart(model, Enum.PartType.Ball, Vector3.new(0.56 * s, 0.56 * s, 0.56 * s), S.DongColor, S.DongGlow)
    local len = 1.25 * s
    local shaft = neonPart(model, Enum.PartType.Cylinder, Vector3.new(len, 0.5 * s, 0.5 * s), S.DongColor, S.DongGlow)
    local head = neonPart(model, Enum.PartType.Ball, Vector3.new(0.62 * s, 0.62 * s, 0.62 * s), S.DongColor, S.DongGlow)
    local t = 0
    Dong.conn = RunService.RenderStepped:Connect(function(dt)
        if not S.Dong or not model.Parent then return end
        local c = LocalPlayer.Character
        local r = c and c:FindFirstChild("HumanoidRootPart")
        if not r then return end
        t = t + dt
        local sway = math.sin(t * 2.2) * 0.08
        local bob = math.sin(t * 3.0) * 0.03
        local cf = r.CFrame * CFrame.new(0, bob, 0)
        local off = CFrame.new(0, -0.62 * s, -0.5 * s)
        ballL.CFrame = cf * off * CFrame.new(-0.28 * s, 0, 0)
        ballR.CFrame = cf * off * CFrame.new(0.28 * s, 0, 0)
        shaft.CFrame = cf * off * CFrame.new(0, 0, -len / 2) * CFrame.Angles(0, math.rad(90), 0) * CFrame.Angles(0, 0, sway)
        head.CFrame = cf * off * CFrame.new(0, 0, -len) * CFrame.Angles(0, 0, sway)
    end)
end

local Wings = {model = nil, conn = nil}
local function applyWings()
    if Wings.conn then Wings.conn:Disconnect(); Wings.conn = nil end
    if Wings.model then Wings.model:Destroy(); Wings.model = nil end
    if not S.Wings then return end
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local c = accent()
    local model = Instance.new("Model")
    model.Name = "HamerWings"
    model.Parent = Workspace
    Wings.model = model
    for sign = -1, 1, 2 do
        for i = 1, 9 do
            local p = neonPart(model, Enum.PartType.Block, Vector3.new(0.9, 0.2, 0.12), c, true)
            p:SetAttribute("sign", sign)
            p:SetAttribute("t", (i - 1) / 8)
        end
    end
    local t = 0
    Wings.conn = RunService.RenderStepped:Connect(function(dt)
        if not S.Wings or not model.Parent then return end
        local ch = LocalPlayer.Character
        local r = ch and ch:FindFirstChild("HumanoidRootPart")
        if not r then return end
        t = t + dt
        local flap = math.sin(t * 3.5) * math.rad(14)
        for _, p in ipairs(model:GetChildren()) do
            if p:IsA("BasePart") then
                local sign = p:GetAttribute("sign")
                local ft = p:GetAttribute("t")
                local x = sign * (0.7 + ft * 2.6)
                local y = 1.5 - ft * 0.9 + math.sin(ft * math.pi) * 0.3
                local z = 0.5 - ft * 0.2
                p.CFrame = r.CFrame * CFrame.new(x, y, z) * CFrame.Angles(0, 0, math.rad(sign * (20 + ft * 25)) + flap * sign)
            end
        end
    end)
end

local Halo = {model = nil, conn = nil}
local function applyHalo()
    if Halo.conn then Halo.conn:Disconnect(); Halo.conn = nil end
    if Halo.model then Halo.model:Destroy(); Halo.model = nil end
    if not S.Halo then return end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("Head") then return end
    local c = accent()
    local model = Instance.new("Model")
    model.Name = "HamerHalo"
    model.Parent = Workspace
    Halo.model = model
    local balls = {}
    for i = 1, 16 do
        local p = neonPart(model, Enum.PartType.Ball, Vector3.new(0.16, 0.16, 0.16), c, true)
        table.insert(balls, {p = p, a = (i - 1) / 16 * math.pi * 2})
    end
    local t = 0
    Halo.conn = RunService.RenderStepped:Connect(function(dt)
        if not S.Halo or not model.Parent then return end
        local ch = LocalPlayer.Character
        local h = ch and ch:FindFirstChild("Head")
        if not h then return end
        t = t + dt
        for _, e in ipairs(balls) do
            local a = e.a + t * 1.5
            e.p.CFrame = h.CFrame * CFrame.new(math.cos(a) * 0.95, 1.15, math.sin(a) * 0.95)
        end
    end)
end

local ChinaHat = {model = nil, conn = nil}
local function applyChinaHat()
    if ChinaHat.conn then ChinaHat.conn:Disconnect(); ChinaHat.conn = nil end
    if ChinaHat.model then ChinaHat.model:Destroy(); ChinaHat.model = nil end
    if not S.ChinaHat then return end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("Head") then return end
    local c = accent()
    local model = Instance.new("Model")
    model.Name = "HamerChinaHat"
    model.Parent = Workspace
    ChinaHat.model = model
    local brim = neonPart(model, Enum.PartType.Cylinder, Vector3.new(0.1, 3.0, 3.0), c, true)
    local rings = {}
    for i = 1, 12 do
        local t = i / 12
        local d = 2.6 * (1 - t) + 0.08 * t
        local p = neonPart(model, Enum.PartType.Cylinder, Vector3.new(0.08, d, d), c, true)
        table.insert(rings, {p = p, y = 0.2 + t * 1.2})
    end
    ChinaHat.conn = RunService.RenderStepped:Connect(function()
        if not S.ChinaHat or not model.Parent then return end
        local ch = LocalPlayer.Character
        local h = ch and ch:FindFirstChild("Head")
        if not h then return end
        brim.CFrame = h.CFrame * CFrame.new(0, 0.6, 0) * CFrame.Angles(0, 0, math.rad(90))
        for _, e in ipairs(rings) do
            e.p.CFrame = h.CFrame * CFrame.new(0, e.y, 0) * CFrame.Angles(0, 0, math.rad(90))
        end
    end)
end

local KG = {model = nil, conn = nil, t = 0, blend = 0}
local function applyKagune()
    if KG.conn then KG.conn:Disconnect(); KG.conn = nil end
    if KG.model then KG.model:Destroy(); KG.model = nil end
    if not S.Kagune then return end
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local color = Color3.fromRGB(220, 30, 40)
    local model = Instance.new("Model")
    model.Name = "HamerKagune"
    model.Parent = Workspace
    KG.model = model
    local parts = {}
    for sx = -1, 1, 2 do
        for sy = -1, 1, 2 do
            for i = 1, 14 do
                local t = (i - 1) / 13
                local p = neonPart(model, Enum.PartType.Block, Vector3.new(0.5, 0.5, 0.5), color, true)
                p:SetAttribute("x", (0.5 + t * 2.0) * sx)
                p:SetAttribute("y", (0.3 + t * 1.6) * sy)
                p:SetAttribute("z", 0.5 - math.max(0, (t - 0.5) / 0.5) * 1.5)
                p:SetAttribute("t", t)
                p:SetAttribute("si", i)
                p:SetAttribute("us", sy)
                table.insert(parts, p)
            end
        end
    end
    KG.t = 0
    KG.blend = 0
    KG.conn = RunService.RenderStepped:Connect(function(dt)
        if not S.Kagune or not model.Parent then return end
        local c = LocalPlayer.Character
        local r = c and c:FindFirstChild("HumanoidRootPart")
        if not r then return end
        local hum = c:FindFirstChildOfClass("Humanoid")
        KG.t = KG.t + dt
        local walking = hum and hum.MoveDirection.Magnitude > 0.1
        KG.blend = KG.blend + ((walking and 1 or 0) - KG.blend) * math.min(dt * 4, 1)
        local idle = math.sin(KG.t * 2.0) * 0.15
        local walk = math.sin(KG.t * 5) * 0.2
        for _, p in ipairs(parts) do
            if p.Parent then
                local t = p:GetAttribute("t")
                local us = p:GetAttribute("us")
                local wd = math.sin(KG.t * 5 - p:GetAttribute("si") * 0.3) * 0.15
                local fo = idle * (1 - KG.blend) + (walk + wd) * KG.blend
                local off = Vector3.new(p:GetAttribute("x") + fo * 0.5 * t, p:GetAttribute("y") + fo * us * t, p:GetAttribute("z"))
                p.CFrame = r.CFrame * CFrame.new(off) * CFrame.Angles(0, 0, math.rad(us * 45) + fo * us * 0.25) * CFrame.Angles(t * 1.2, 0, 0)
            end
        end
    end)
end

local CMP = {model = nil, conn = nil, t = 0}
local function applyCompanion()
    if CMP.conn then CMP.conn:Disconnect(); CMP.conn = nil end
    if CMP.model then CMP.model:Destroy(); CMP.model = nil end
    if not S.Companion then return end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local color = accent()
    local model = Instance.new("Model")
    model.Name = "HamerCompanion"
    model.Parent = Workspace
    CMP.model = model
    local box = neonPart(model, Enum.PartType.Block, Vector3.new(0.7, 0.7, 0.7), color, true)
    local core = neonPart(model, Enum.PartType.Ball, Vector3.new(0.28, 0.28, 0.28), Color3.fromRGB(255, 255, 255), true)
    core.Transparency = 0.15
    CMP.t = 0
    CMP.conn = RunService.RenderStepped:Connect(function(dt)
        if not S.Companion or not model.Parent then return end
        local c = LocalPlayer.Character
        local r = c and c:FindFirstChild("HumanoidRootPart")
        if not r then return end
        CMP.t = CMP.t + dt
        local t = CMP.t
        local bob = math.sin(t * 2.5) * 0.15
        local sway = math.sin(t * 1.8) * 0.2
        local target = r.Position + r.CFrame.LookVector * (2.5 + sway) + r.CFrame.RightVector * 2.0 + r.CFrame.UpVector * (1.2 + bob)
        local pos = box.Position:Lerp(target, math.min(dt * 8, 1))
        box.CFrame = CFrame.new(pos) * CFrame.Angles(math.sin(t * 2) * 0.3, t * 3, math.sin(t * 2) * 0.15)
        local cs = 0.28 + math.sin(t * 4) * 0.05
        core.Size = Vector3.new(cs, cs, cs)
        core.CFrame = box.CFrame
        core.Transparency = 0.15 + math.sin(t * 4) * 0.08
    end)
end

local function applyNoAnims(on)
    S.NoAnims = on
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then return end
    if on then
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            pcall(function() track:Stop() end)
        end
    end
end

local function applyKorblox(on)
    S.Korblox = on
    local char = LocalPlayer.Character
    if not char then return end
    for _, n in ipairs({"Right Leg", "RightUpperLeg", "RightLowerLeg"}) do
        local p = char:FindFirstChild(n)
        if p then
            p.Transparency = on and 1 or 0
        end
    end
end

local function applyGhostLegs(on)
    S.GhostLegs = on
    local char = LocalPlayer.Character
    if not char then return end
    for _, n in ipairs({"Left Leg", "Right Leg", "LeftUpperLeg", "RightUpperLeg", "LeftLowerLeg", "RightLowerLeg"}) do
        local p = char:FindFirstChild(n)
        if p then
            p.Transparency = on and 1 or 0
        end
    end
end

local function setAvatarScale(v)
    S.AvatarScale = v
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    for _, n in ipairs({"BodyHeightScale", "BodyWidthScale", "BodyDepthScale", "HeadScale"}) do
        local nv = hum:FindFirstChild(n)
        if nv then nv.Value = v end
    end
end

local wmGui = Instance.new("ScreenGui")
wmGui.Name = "HamerWatermark"
wmGui.ResetOnSpawn = false
wmGui.IgnoreGuiInset = true
wmGui.DisplayOrder = 997
wmGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
wmGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local wm = Instance.new("Frame")
wm.Size = UDim2.new(0, 210, 0, 26)
wm.Position = UDim2.new(0, 12, 0, 60)
wm.BackgroundColor3 = Color3.fromRGB(14, 18, 28)
wm.BackgroundTransparency = 0.12
wm.BorderSizePixel = 0
wm.ZIndex = 1
wm.Parent = wmGui
local wmc = Instance.new("UICorner")
wmc.CornerRadius = UDim.new(0, 8)
wmc.Parent = wm
local wms = Instance.new("UIStroke")
wms.Color = accent()
wms.Transparency = 0.5
wms.Thickness = 1
wms.Parent = wm
bindAccent(function(c) wms.Color = c end)
local wmText = Instance.new("TextLabel")
wmText.Text = "hamer"
wmText.Font = FONT_BOLD
wmText.TextSize = 11
wmText.TextColor3 = Color3.fromRGB(255, 255, 255)
wmText.TextTransparency = 0.15
wmText.TextXAlignment = Enum.TextXAlignment.Left
wmText.BackgroundTransparency = 1
wmText.Size = UDim2.new(1, -16, 1, 0)
wmText.Position = UDim2.new(0, 8, 0, 0)
wmText.ZIndex = 2
wmText.Parent = wm

local fpsCount, fpsAcc, fpsValue = 0, 0, 0
conn(RunService.RenderStepped:Connect(function(dt)
    if Unloaded then return end
    wmGui.Enabled = S.Watermark
    fpsAcc = fpsAcc + dt
    fpsCount = fpsCount + 1
    if fpsAcc >= 0.5 then
        fpsValue = math.floor(fpsCount / fpsAcc + 0.5)
        fpsAcc = 0
        fpsCount = 0
    end
    local ping = 0
    pcall(function()
        ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
    end)
    wmText.Text = string.format("hamer  |  %d fps  |  %d ms", fpsValue, ping)
end))

local EmoteMenu = {gui = nil, track = nil}
local EMOTES = {
    {name = "Dance", id = "507771019"},
    {name = "Cheer", id = "507770677"},
    {name = "Hello", id = "507770239"},
    {name = "Point", id = "507770453"},
    {name = "Laugh", id = "507770818"},
    {name = "Sit", id = "2506281703"}
}

local function playEmote(id, looped)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = hum
    end
    if EmoteMenu.track then pcall(function() EmoteMenu.track:Stop() end) end
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. id
    local ok, track = pcall(function() return animator:LoadAnimation(anim) end)
    if ok and track then
        track.Priority = Enum.AnimationPriority.Action4
        track.Looped = looped == true
        track:Play()
        EmoteMenu.track = track
    end
end

local function toggleEmoteMenu()
    if EmoteMenu.gui and EmoteMenu.gui.Parent then
        EmoteMenu.gui:Destroy()
        EmoteMenu.gui = nil
        return
    end
    local eg = Instance.new("ScreenGui")
    eg.Name = "HamerEmotes"
    eg.ResetOnSpawn = false
    eg.IgnoreGuiInset = true
    eg.DisplayOrder = 998
    eg.ZIndexBehavior = Enum.ZIndexBehavior.Global
    eg.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 170, 0, 258)
    frame.Position = UDim2.new(1, -190, 0.5, -129)
    frame.BackgroundColor3 = Color3.fromRGB(14, 18, 28)
    frame.BackgroundTransparency = 0.06
    frame.BorderSizePixel = 0
    frame.ZIndex = 10
    frame.Parent = eg
    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(0, 16)
    fc.Parent = frame
    local fs = Instance.new("UIStroke")
    fs.Color = accent()
    fs.Transparency = 0.45
    fs.Thickness = 1.2
    fs.Parent = frame

    local tl = Instance.new("TextLabel")
    tl.Text = "EMOTES"
    tl.Font = FONT_BLACK
    tl.TextSize = 13
    tl.TextColor3 = Color3.fromRGB(255, 255, 255)
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.BackgroundTransparency = 1
    tl.Size = UDim2.new(1, -24, 0, 26)
    tl.Position = UDim2.new(0, 12, 0, 10)
    tl.ZIndex = 11
    tl.Parent = frame

    for i, e in ipairs(EMOTES) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, -24, 0, 30)
        b.Position = UDim2.new(0, 12, 0, 40 + (i - 1) * 34)
        b.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        b.BackgroundTransparency = 0.93
        b.BorderSizePixel = 0
        b.Text = e.name
        b.Font = FONT_REG
        b.TextSize = 12
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.AutoButtonColor = false
        b.ZIndex = 11
        b.Parent = frame
        local bc = Instance.new("UICorner")
        bc.CornerRadius = UDim.new(0, 8)
        bc.Parent = b
        local bs = Instance.new("UIStroke")
        bs.Color = Color3.fromRGB(255, 255, 255)
        bs.Transparency = 0.9
        bs.Parent = b
        b.MouseButton1Click:Connect(function()
            playEmote(e.id, e.name == "Sit")
            click()
        end)
    end
    EmoteMenu.gui = eg
end

local function toast(text)
    local t = Instance.new("TextLabel")
    t.Text = text
    t.Font = FONT_BOLD
    t.TextSize = 12
    t.TextColor3 = Color3.fromRGB(255, 255, 255)
    t.BackgroundColor3 = Color3.fromRGB(14, 18, 28)
    t.BackgroundTransparency = 0.08
    t.Size = UDim2.new(0, 280, 0, 32)
    t.Position = UDim2.new(0.5, -140, 1, -104)
    t.ZIndex = 40
    t.Parent = gui
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 9)
    c.Parent = t
    local s = Instance.new("UIStroke")
    s.Color = accent()
    s.Transparency = 0.4
    s.Parent = t
    task.delay(2, function()
        if t and t.Parent then t:Destroy() end
    end)
end

local CONFIG_DIR = "hamer_configs"

local function hasFileAPI()
    return type(writefile) == "function" and type(readfile) == "function"
end

local function safeName(n)
    n = tostring(n or "default")
    n = string.gsub(n, "[^%w_%- ]", "")
    if n == "" then n = "default" end
    return n
end

local function serialize()
    local t = {}
    for k, v in pairs(S) do
        if (type(v) == "boolean" or type(v) == "number" or type(v) == "string") and k ~= "MenuOpen" and k ~= "DroneActive" then
            t[k] = v
        end
    end
    t.ESPColor = {math.floor(S.ESPColor.R * 255), math.floor(S.ESPColor.G * 255), math.floor(S.ESPColor.B * 255)}
    t.DongColor = {math.floor(S.DongColor.R * 255), math.floor(S.DongColor.G * 255), math.floor(S.DongColor.B * 255)}
    return HttpService:JSONEncode(t)
end

local function reapplyAll()
    applyFullbright()
    applyFog()
    applyWorld()
    applyDong()
    applyWings()
    applyHalo()
    applyChinaHat()
    applyKagune()
    applyCompanion()
    applyKorblox(S.Korblox)
    applyGhostLegs(S.GhostLegs)
    applyNoAnims(S.NoAnims)
    setAvatarScale(S.AvatarScale)
    applyAccent()
    uiScale.Scale = computeScale()
    task.defer(function()
        if not Unloaded and S.MenuOpen then selectTab(currentTab) end
    end)
end

local function saveConfig()
    if not hasFileAPI() then toast("file api unavailable"); return end
    local name = safeName(S.ConfigName)
    local ok, err = pcall(function()
        if type(makefolder) == "function" and type(isfolder) == "function" and not isfolder(CONFIG_DIR) then
            makefolder(CONFIG_DIR)
        end
        writefile(CONFIG_DIR .. "/" .. name .. ".json", serialize())
    end)
    toast(ok and ("saved: " .. name) or ("save failed: " .. tostring(err)))
end

local function loadConfig()
    if not hasFileAPI() then toast("file api unavailable"); return end
    local name = safeName(S.ConfigName)
    local path = CONFIG_DIR .. "/" .. name .. ".json"
    local ok, data = pcall(function() return readfile(path) end)
    if not ok or not data then toast("config not found: " .. name); return end
    local decOk, decoded = pcall(function() return HttpService:JSONDecode(data) end)
    if not decOk or type(decoded) ~= "table" then toast("broken config"); return end
    for k, v in pairs(decoded) do
        if k ~= "ESPColor" and k ~= "DongColor" and S[k] ~= nil then
            if type(S[k]) == type(v) then S[k] = v end
        end
    end
    if type(decoded.ESPColor) == "table" then
        S.ESPColor = Color3.fromRGB(decoded.ESPColor[1] or 0, decoded.ESPColor[2] or 229, decoded.ESPColor[3] or 255)
    end
    if type(decoded.DongColor) == "table" then
        S.DongColor = Color3.fromRGB(decoded.DongColor[1] or 255, decoded.DongColor[2] or 170, decoded.DongColor[3] or 200)
    end
    reapplyAll()
    toast("loaded: " .. name)
end

local function deleteConfig()
    if not hasFileAPI() then toast("file api unavailable"); return end
    local name = safeName(S.ConfigName)
    local ok = pcall(function()
        if type(delfile) == "function" then
            delfile(CONFIG_DIR .. "/" .. name .. ".json")
        end
    end)
    toast(ok and ("deleted: " .. name) or "delete failed")
end

local function unload()
    Unloaded = true
    for _, c in ipairs(Conns) do
        pcall(function() c:Disconnect() end)
    end
    Conns = {}
    stopDrone()
    S.Dong, S.Wings, S.Halo, S.ChinaHat = false, false, false, false
    S.Kagune, S.Companion, S.NoAnims = false, false, false
    applyDong()
    applyWings()
    applyHalo()
    applyChinaHat()
    applyKagune()
    applyCompanion()
    for p, v in pairs(noclipSaved) do
        if p.Parent then p.CanCollide = v end
    end
    noclipSaved = {}
    if flyBV then flyBV:Destroy() end
    if flyBG then flyBG:Destroy() end
    S.Fullbright = false
    applyFullbright()
    S.Fog = false
    applyFog()
    S.World = false
    applyWorld()
    S.MotionBlur = false
    if mbEffect then mbEffect:Destroy() end
    if EmoteMenu.gui and EmoteMenu.gui.Parent then EmoteMenu.gui:Destroy() end
    if blur then blur:Destroy() end
    if gui then gui:Destroy() end
    if espGui then espGui:Destroy() end
    if wmGui then wmGui:Destroy() end
end

builders.cosmetics = function()
    sectionRow("BODY")
    toggleRow("3D Dick", "Dong", applyDong)
    stepRow("Size", "DongSize", 0.4, 3, 0.1, "", function()
        if S.Dong then applyDong() end
    end)
    toggleRow("Glow", "DongGlow", function()
        if S.Dong then applyDong() end
    end)
    colorRow("Color", "DongColor", function()
        if S.Dong then applyDong() end
    end)
    toggleRow("Korblox leg", "Korblox", applyKorblox)
    toggleRow("Ghost legs", "GhostLegs", applyGhostLegs)
    toggleRow("No animations", "NoAnims", applyNoAnims)
    sectionRow("ACCESSORIES")
    toggleRow("Wings", "Wings", applyWings)
    toggleRow("Halo", "Halo", applyHalo)
    toggleRow("China hat", "ChinaHat", applyChinaHat)
    toggleRow("Kagune", "Kagune", applyKagune)
    toggleRow("Companion", "Companion", applyCompanion)
end

builders.misc = function()
    sectionRow("AVATAR")
    stepRow("Avatar scale", "AvatarScale", 0.3, 2, 0.1, "", setAvatarScale)
    sectionRow("SERVER")
    actionRow("Rejoin server", "Reconnect to this place.", function()
        pcall(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
    end)
    actionRow("Reset character", "Respawn your avatar.", function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
    end)
    actionRow("Copy Job ID", "Copy the server id.", function()
        if setclipboard then
            pcall(function() setclipboard(tostring(game.JobId)) end)
        end
    end)
    sectionRow("CLIENT")
    actionRow("Emote menu", "Quick dance / cheer / sit.", toggleEmoteMenu)
    actionRow("Destroy GUI", "Unload hamer.", unload)
    sectionRow("INTERFACE")
    toggleRow("Phone mode", "Mobile", function()
        uiScale.Scale = computeScale()
        task.defer(function()
            if not Unloaded and S.MenuOpen then selectTab(currentTab) end
        end)
    end)
    sectionRow("CONFIGS")
    textRow("Config name", "ConfigName", "default")
    actionRow("Save config", "Write current settings to file.", saveConfig)
    actionRow("Load config", "Apply saved settings.", loadConfig)
    actionRow("Delete config", "Remove saved config.", deleteConfig)
end

conn(LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if Unloaded then return end
    if S.Dong then applyDong() end
    if S.Wings then applyWings() end
    if S.Halo then applyHalo() end
    if S.ChinaHat then applyChinaHat() end
    if S.Kagune then applyKagune() end
    if S.Companion then applyCompanion() end
    applyKorblox(S.Korblox)
    applyGhostLegs(S.GhostLegs)
    applyNoAnims(S.NoAnims)
    setAvatarScale(S.AvatarScale)
end))

selectTab("combat")
setMenu(true)

print("hamer loaded (no key)")
