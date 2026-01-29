local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

local cfg = {
    emo  = "👾",
    size = 24,
    name = "✨ xiaoYo 閃避渲染"
}

local pGui = player:WaitForChild("PlayerGui")
if pGui:FindFirstChild("xiaoYo_ShaderUI") then pGui.xiaoYo_ShaderUI:Destroy() end

local running, curMode, rem = true, player:GetAttribute("ShaderMode") or "day", player:GetAttribute("ShaderRemember") or false
local sg = Instance.new("ScreenGui", pGui)
sg.Name, sg.ResetOnSpawn, sg.DisplayOrder = "xiaoYo_ShaderUI", false, 99999
sg.ZIndexBehavior = Enum.ZIndexBehavior.Global

-- [[ 渲染引擎優化 - 解決綠霧問題 ]]
local function getEff(cl, nm)
    local e = Lighting:FindFirstChild(nm) or Instance.new(cl)
    e.Name, e.Parent = nm, Lighting
    return e
end

local CC = getEff("ColorCorrectionEffect", "x_CC")
local Atm = getEff("Atmosphere", "x_Atm")
local Sky = getEff("Sky", "x_Sky")
local Bloom = getEff("BloomEffect", "x_Bloom")
local SunRays = getEff("SunRaysEffect", "x_SunRays")
local DoF = getEff("DepthOfFieldEffect", "x_DoF")

local function apply()
    if not running then return end
    local isDay = (curMode == "day")
    local t = isDay and {
        CT = 14.5, B = 3, E = 0.1, C = 0.2, S = 0.15, Tint = Color3.fromRGB(255, 252, 240),
        Dens = 0.2, Bloom = 0.5, Sun = 0.2, DoF = 5, Sdw = true, Dif = 1, Spec = 1
    } or {
        CT = 0, B = 2.2, E = 0.15, C = 0.3, S = 0.3, Tint = Color3.fromRGB(210, 220, 255),
        Dens = 0.25, Bloom = 1.0, Sun = 0, DoF = 8, Sdw = true, Dif = 0.7, Spec = 1.5
    }

    local ti = TweenInfo.new(1.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    
    -- 修正大氣效果：降低 Haze 解決綠霧
    Atm.Color = t.Tint
    Atm.Decay = t.Tint
    
    TweenService:Create(Lighting, ti, {ClockTime=t.CT, Brightness=t.B, ExposureCompensation=t.E, EnvironmentDiffuseScale=t.Dif, EnvironmentSpecularScale=t.Spec}):Play()
    TweenService:Create(CC, ti, {Contrast=t.C, Saturation=t.S, TintColor=t.Tint}):Play()
    TweenService:Create(Atm, ti, {Density=t.Dens, Haze=0.1}):Play() -- 鎖定低 Haze 防止綠色迷霧
    TweenService:Create(Bloom, ti, {Intensity=t.Bloom, Threshold=0.8}):Play()
    TweenService:Create(SunRays, ti, {Intensity=t.Sun}):Play()
    TweenService:Create(DoF, ti, {FarIntensity=0.1, FocusDistance=25, InFocusRadius=t.DoF}):Play()
    Sky.Enabled = not isDay
end

-- [[ UI 構建 ]]
local frame = Instance.new("Frame", sg)
frame.Size, frame.Position = UDim2.new(0, 250, 0, 210), UDim2.new(0.5, -125, 0.5, -105)
frame.BackgroundColor3, frame.BackgroundTransparency = Color3.fromRGB(15,15,15), 0.3
frame.Active, frame.Draggable = true, true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,22)
Instance.new("UIStroke", frame).Color = Color3.fromRGB(200,160,255)

-- 小點：位置固定在主視窗左側平行位子
local res = Instance.new("TextButton", sg)
res.Size, res.Visible, res.Text = UDim2.new(0,55,0,55), false, cfg.emo
res.BackgroundColor3, res.BackgroundTransparency = Color3.fromRGB(20,20,20), 0.2
res.TextColor3, res.TextSize = Color3.new(1,1,1), cfg.size
res.Draggable = true
Instance.new("UICorner", res).CornerRadius = UDim.new(1,0)
Instance.new("UIStroke", res).Color = Color3.fromRGB(200,160,255)

-- [[ 修正後的平行切換邏輯 ]]
local function showMain()
    frame.Visible = true
    res.Visible = false
end

local function hideMain()
    -- 同步小點位子到主視窗左側，不再越開越偏
    local fPos = frame.Position
    res.Position = UDim2.new(fPos.X.Scale, fPos.X.Offset - 70, fPos.Y.Scale, fPos.Y.Offset + 75)
    frame.Visible = false
    res.Visible = true
end

-- [其餘按鈕與功能維持不變...]
local function headBtn(txt, pos, col, cb)
    local b = Instance.new("TextButton", frame)
    b.Size, b.Position, b.Text, b.BackgroundColor3 = UDim2.new(0,22,0,22), pos, txt, col
    b.TextColor3, b.Font = Color3.new(1,1,1), Enum.Font.GothamBold
    Instance.new("UICorner", b).CornerRadius = UDim.new(1,0)
    b.MouseButton1Click:Connect(cb)
    return b
end

headBtn("-", UDim2.new(1,-60,0,9), Color3.fromRGB(60,60,60), hideMain)
headBtn("×", UDim2.new(1,-30,0,9), Color3.fromRGB(150,50,50), function() running = false sg:Destroy() end)

local dragStartPos
res.MouseButton1Down:Connect(function() dragStartPos = res.AbsolutePosition end)
res.MouseButton1Up:Connect(function()
    if dragStartPos and (res.AbsolutePosition - dragStartPos).Magnitude <= 8 then showMain() end
end)

local function mainBtn(txt,col,pos,cb)
    local b = Instance.new("TextButton", frame)
    b.Size, b.Position, b.Text, b.BackgroundColor3 = UDim2.new(0.86,0,0,36), pos, txt, col
    b.TextColor3, b.Font, b.BackgroundTransparency = Color3.new(1,1,1), Enum.Font.GothamMedium, 0.25
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
    b.MouseButton1Click:Connect(cb)
    return b
end

mainBtn("☀ 早晨模式", Color3.fromRGB(120,190,255), UDim2.new(0.07,0,0.22,0), function()
    curMode = "day"
    apply()
end)

mainBtn("🌌 黑夜模式", Color3.fromRGB(160,110,255), UDim2.new(0.07,0,0.42,0), function()
    curMode = "night"
    apply()
end)

local mBtn
mBtn = mainBtn(rem and "💾 記憶模式: ON" or "💾 記憶模式: OFF", rem and Color3.fromRGB(90,180,120) or Color3.fromRGB(120,120,120), UDim2.new(0.07,0,0.68,0), function()
    rem = not rem
    player:SetAttribute("ShaderRemember", rem)
    mBtn.Text = rem and "💾 記憶模式: ON" or "💾 記憶模式: OFF"
    mBtn.BackgroundColor3 = rem and Color3.fromRGB(90,180,120) or Color3.fromRGB(120,120,120)
end)

task.spawn(function() while running and sg.Parent do apply() task.wait(3) end end)
if rem then apply() end
