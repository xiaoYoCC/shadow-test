local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

if CoreGui:FindFirstChild("xiaoYo_ShaderUI") then
    CoreGui.xiaoYo_ShaderUI:Destroy()
end

local running = true
local currentMode = player:GetAttribute("ShaderMode")
local remember = player:GetAttribute("ShaderRemember") or false

local sg = Instance.new("ScreenGui", CoreGui)
sg.Name = "xiaoYo_ShaderUI"

local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 230, 0, 195)
frame.Position = UDim2.new(1, -250, 0.5, -97)
frame.BackgroundColor3 = Color3.fromRGB(22,22,22)
frame.BackgroundTransparency = 0.35
frame.Active, frame.Draggable = true, true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,22)
Instance.new("UIStroke", frame).Transparency = 0.6

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,40)
title.BackgroundTransparency = 1
title.Text = "✨ xiaoYo 閃避渲染"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.new(1,1,1)

local miniBtn = Instance.new("TextButton", frame)
miniBtn.Size = UDim2.new(0,25,0,25)
miniBtn.Position = UDim2.new(1,-65,0,8)
miniBtn.Text = "-"
miniBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
miniBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(1,0)

local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(0,25,0,25)
closeBtn.Position = UDim2.new(1,-35,0,8)
closeBtn.Text = "×"
closeBtn.BackgroundColor3 = Color3.fromRGB(150,50,50)
closeBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1,0)

local restoreBtn = Instance.new("TextButton", sg)
restoreBtn.Size = UDim2.new(0,50,0,50)
restoreBtn.Position = UDim2.new(1,-60,0.5,-25)
restoreBtn.Text = "✨"
restoreBtn.TextSize = 24
restoreBtn.Visible = false
restoreBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
restoreBtn.BackgroundTransparency = 0.3
Instance.new("UICorner", restoreBtn).CornerRadius = UDim.new(1,0)
Instance.new("UIStroke", restoreBtn)

miniBtn.MouseButton1Click:Connect(function() frame.Visible = false restoreBtn.Visible = true end)
restoreBtn.MouseButton1Click:Connect(function() frame.Visible = true restoreBtn.Visible = false end)
closeBtn.MouseButton1Click:Connect(function() running = false sg:Destroy() end)

local function effect(class, name)
    local e = Lighting:FindFirstChild(name) or Instance.new(class)
    e.Name, e.Parent = name, Lighting
    return e
end

local function apply()
    if not currentMode then return end
    local CC = effect("ColorCorrectionEffect","x_CC")
    local Bloom = effect("BloomEffect","x_Bloom")
    local Rays = effect("SunRaysEffect","x_Rays")
    local Atm = effect("Atmosphere","x_Atm")
    local Sky = effect("Sky","x_Sky")

    Lighting.Technology = Enum.Technology.Future
    Lighting.GlobalShadows = true

    if currentMode == "day" then
        if math.abs(Lighting.ClockTime - 14) > 0.05 then Lighting.ClockTime = 14 end
        Lighting.Brightness = 2.4
        CC.Contrast, CC.Saturation, CC.TintColor = 0.1, 0.16, Color3.fromRGB(255,245,235)
        Bloom.Intensity, Bloom.Size = 0.35, 14
        Rays.Intensity, Atm.Density, Sky.Enabled = 0.18, 0.32, false
    else
        if math.abs(Lighting.ClockTime - 23.5) > 0.05 then Lighting.ClockTime = 23.5 end
        Lighting.Brightness = 1.6
        CC.Contrast, CC.Saturation, CC.TintColor = 0.26, 0.38, Color3.fromRGB(215,205,255)
        Bloom.Intensity, Bloom.Size = 0.75, 26
        Rays.Intensity, Atm.Density, Sky.Enabled = 0.06, 0.4, true
        local gid = "rbxassetid://600830446"
        Sky.SkyboxBk, Sky.SkyboxDn, Sky.SkyboxFt, Sky.SkyboxLf, Sky.SkyboxRt, Sky.SkyboxUp, Sky.StarIntensity = gid, gid, gid, gid, gid, gid, 6
    end
end

local function makeBtn(txt, color, pos)
    local b = Instance.new("TextButton", frame)
    b.Size, b.Position, b.Text = UDim2.new(0.86,0,0,36), pos, txt
    b.Font, b.TextColor3, b.BackgroundColor3 = Enum.Font.GothamMedium, Color3.new(1,1,1), color
    b.BackgroundTransparency = 0.25
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
    return b
end

local dBtn = makeBtn("☀ 清晨模式", Color3.fromRGB(120,190,255), UDim2.new(0.07,0,0.28,0))
local nBtn = makeBtn("🌌 黑夜模式", Color3.fromRGB(160,110,255), UDim2.new(0.07,0,0.48,0))
local mBtn = makeBtn(remember and "💾 記憶模式: ON" or "💾 記憶模式: OFF", remember and Color3.fromRGB(90,180,120) or Color3.fromRGB(120,120,120), UDim2.new(0.07,0,0.70,0))

dBtn.MouseButton1Click:Connect(function() currentMode = "day" player:SetAttribute("ShaderMode","day") apply() end)
nBtn.MouseButton1Click:Connect(function() currentMode = "night" player:SetAttribute("ShaderMode","night") apply() end)
mBtn.MouseButton1Click:Connect(function()
    remember = not remember
    player:SetAttribute("ShaderRemember", remember)
    mBtn.Text = remember and "💾 記憶模式: ON" or "💾 記憶模式: OFF"
    mBtn.BackgroundColor3 = remember and Color3.fromRGB(90,180,120) or Color3.fromRGB(120,120,120)
end)

task.spawn(function()
    while running do
        if currentMode then apply() end
        task.wait(2)
    end
end)

if remember and currentMode then task.wait(1) apply() end
