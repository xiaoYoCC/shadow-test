local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

-- [[ 自定義配置 ]]
local cfg = {
    type = "Emoji", -- "Emoji" 或 "Image"
    id   = "rbxassetid://13511162985",
    emo  = "👾",
    name = "✨ xiaoYo 閃避渲染"
}

if CoreGui:FindFirstChild("xiaoYo_ShaderUI") then CoreGui.xiaoYo_ShaderUI:Destroy() end

local running, curMode, rem = true, player:GetAttribute("ShaderMode") or "day", player:GetAttribute("ShaderRemember") or false
local sg = Instance.new("ScreenGui", CoreGui)
sg.Name = "xiaoYo_ShaderUI"

--==================================================
-- UI 核心組件
--==================================================
local frame = Instance.new("Frame", sg)
frame.Size, frame.Position = UDim2.new(0, 250, 0, 210), UDim2.new(1, -270, 0.5, -105)
frame.BackgroundColor3, frame.BackgroundTransparency = Color3.fromRGB(22,22,22), 0.35
frame.Active, frame.Draggable = true, true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,22)
Instance.new("UIStroke", frame).Transparency = 0.6

local title = Instance.new("TextLabel", frame)
title.Size, title.Position, title.BackgroundTransparency = UDim2.new(0,160,0,40), UDim2.new(0,15,0,0), 1
title.Text, title.Font, title.TextSize, title.TextColor3 = cfg.name, "GothamBold", 16, Color3.new(1,1,1)
title.TextXAlignment = 0

-- 縮小鈕 (restore)
local res = Instance.new("ImageButton", sg)
res.Size, res.Visible, res.Active, res.Draggable = UDim2.new(0,55,0,55), false, true, true
res.BackgroundColor3, res.BackgroundTransparency = Color3.fromRGB(30,30,30), 0.2
Instance.new("UICorner", res).CornerRadius = UDim.new(1,0)
Instance.new("UIStroke", res).Color = Color3.new(1,1,1)

if cfg.type == "Image" then res.Image = cfg.id else
    local l = Instance.new("TextLabel", res)
    l.Size, l.BackgroundTransparency, l.Text, l.TextScaled = UDim2.new(1,0,1,0), 1, cfg.emo, true
end

-- 頂部功能鍵
local function headBtn(txt, pos, col, cb)
    local b = Instance.new("TextButton", frame)
    b.Size, b.Position, b.Text, b.BackgroundColor3 = UDim2.new(0,22,0,22), pos, txt, col
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b).CornerRadius = UDim.new(1,0)
    b.MouseButton1Click:Connect(cb)
end

headBtn("-", UDim2.new(1,-60,0, headBtn and 9 or 9), Color3.fromRGB(60,60,60), function()
    res.Position = frame.Position
    frame.Visible, res.Visible = false, true
end)

headBtn("×", UDim2.new(1,-30,0,9), Color3.fromRGB(150,50,50), function()
    running = false
    sg:Destroy()
end)

-- restore 邏輯 (支援手機 Touch)
local dStart
res.InputBegan:Connect(function(input)
    if input.UserInputType.Value == 0 or input.UserInputType.Value == 7 then dStart = res.AbsolutePosition end
end)
res.MouseButton1Up:Connect(function()
    if dStart and (dStart - res.AbsolutePosition).Magnitude < 10 then
        frame.Position = res.Position
        frame.Visible, res.Visible = true, false
    end
    dStart = nil
end)

--==================================================
-- 渲染邏輯 (修復框框版)
--==================================================
local function getEff(cl, nm)
    local e = Lighting:FindFirstChild(nm) or Instance.new(cl)
    e.Name, e.Parent = nm, Lighting
    return e
end

local nS = {CT=23.5, B=1.4, C=0.22, S=0.35, T=Color3.fromRGB(215,205,255), AD=0.35}
local dS = {CT=14, B=2.0, C=0.08, S=0.14, T=Color3.fromRGB(255,245,235), AD=0.28}

local function apply()
    local CC, Atm, Sky = getEff("ColorCorrectionEffect","x_CC"), getEff("Atmosphere","x_Atm"), getEff("Sky","x_Sky")
    local s = (curMode=="day") and dS or nS
    if math.abs(Lighting.ClockTime - s.CT) > 0.05 then Lighting.ClockTime = s.CT end
    
    Lighting.Brightness = s.B
    Lighting.GlobalShadows = (curMode == "night")
    Lighting.Technology = (curMode == "day") and 3 or 2 -- Future(3) 或 Compatibility(2)
    
    CC.Contrast, CC.Saturation, CC.TintColor = s.C, s.S, s.T
    Atm.Density, Sky.Enabled = s.AD, (curMode=="night")
    if curMode=="night" then
        local g = "rbxassetid://600830446"
        Sky.SkyboxBk, Sky.SkyboxDn, Sky.SkyboxFt, Sky.SkyboxLf, Sky.SkyboxRt, Sky.SkyboxUp, Sky.StarIntensity = g,g,g,g,g,g,6
    end
end

--==================================================
-- 選單按鈕
--==================================================
local function mainBtn(txt, col, pos, cb)
    local b = Instance.new("TextButton", frame)
    b.Size, b.Position, b.Text, b.BackgroundColor3 = UDim2.new(0.86,0,0,36), pos, txt, col
    b.Font, b.TextColor3, b.BackgroundTransparency = "GothamMedium", Color3.new(1,1,1), 0.25
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
    b.MouseButton1Click:Connect(cb)
    return b
end

mainBtn("☀ 早晨模式", Color3.fromRGB(120,190,255), UDim2.new(0.07,0,0.22,0), function()
    curMode = "day"
    player:SetAttribute("ShaderMode", "day")
    apply()
end)

mainBtn("🌌 黑夜模式", Color3.fromRGB(160,110,255), UDim2.new(0.07,0,0.42,0), function()
    curMode = "night"
    player:SetAttribute("ShaderMode", "night")
    apply()
end)

local mBtn
mBtn = mainBtn(rem and "💾 記憶模式: ON" or "💾 記憶模式: OFF", rem and Color3.fromRGB(90,180,120) or Color3.fromRGB(120,120,120), UDim2.new(0.07,0,0.68,0), function()
    rem = not rem
    player:SetAttribute("ShaderRemember", rem)
    mBtn.Text = rem and "💾 記憶模式: ON" or "💾 記憶模式: OFF"
    mBtn.BackgroundColor3 = rem and Color3.fromRGB(90,180,120) or Color3.fromRGB(120,120,120)
end)

--==================================================
-- 循環與初始化
--==================================================
task.spawn(function()
    while running do
        apply()
        task.wait(1.5)
    end
end)

if rem then task.wait(0.5) apply() end
