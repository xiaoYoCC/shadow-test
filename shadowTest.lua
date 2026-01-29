local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

local cfg = {
    emo  = "👾",
    size = 24,
    name = "✨ xiaoYo 閃避渲染"
}

-- 清理舊 UI
local pGui = player:WaitForChild("PlayerGui")
if pGui:FindFirstChild("xiaoYo_ShaderUI") then pGui.xiaoYo_ShaderUI:Destroy() end

local running = true
local curMode = player:GetAttribute("ShaderMode") or "day"
local rem = player:GetAttribute("ShaderRemember") or false

local sg = Instance.new("ScreenGui", pGui)
sg.Name, sg.ResetOnSpawn, sg.DisplayOrder = "xiaoYo_ShaderUI", false, 99999

-- [[ 渲染引擎 - 光影部分保持原樣 ]]
local function getEff(cl,nm)
    local e = Lighting:FindFirstChild(nm) or Instance.new(cl)
    e.Name, e.Parent = nm, Lighting
    return e
end

local CC = getEff("ColorCorrectionEffect", "x_CC")
local Atm = getEff("Atmosphere", "x_Atm")
local Bloom = getEff("BloomEffect", "x_Bloom")
local DoF = getEff("DepthOfFieldEffect", "x_DoF")

local function apply()
    if not running then return end
    local isDay = (curMode == "day")
    
    local t = isDay and {
        CT = 14.5, B = 2.8, E = 0.05, C = 0.18, S = 0.15, Tint = Color3.fromRGB(255, 252, 240),
        Dens = 0.2, Haze = 0, Decay = Color3.fromRGB(180, 200, 220),
        Amb = Color3.fromRGB(110, 110, 115), OutAmb = Color3.fromRGB(125, 125, 130)
    } or {
        CT = 0, B = 2.3, E = 0.12, C = 0.28, S = 0.35, Tint = Color3.fromRGB(205, 215, 255),
        Dens = 0.25, Haze = 0.05, Decay = Color3.fromRGB(25, 30, 45),
        Amb = Color3.fromRGB(35, 35, 50), OutAmb = Color3.fromRGB(45, 50, 65)
    }

    local ti = TweenInfo.new(1.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    
    Lighting.OutdoorAmbient = t.OutAmb
    Lighting.Ambient = t.Amb
    Lighting.EnvironmentDiffuseScale = 1 
    Lighting.EnvironmentSpecularScale = 1

    TweenService:Create(Lighting, ti, {ClockTime=t.CT, Brightness=t.B, ExposureCompensation=t.E}):Play()
    TweenService:Create(CC, ti, {Contrast=t.C, Saturation=t.S, TintColor=t.Tint}):Play()
    TweenService:Create(Atm, ti, {Density=t.Dens, Haze=t.Haze, Decay=t.Decay, Color=t.Tint}):Play()
    TweenService:Create(Bloom, ti, {Intensity=0.45, Threshold=0.75}):Play()
    TweenService:Create(DoF, ti, {FocusDistance=35, InFocusRadius=12, FarIntensity=0.1}):Play()
end

-- [[ 通知系統 ]]
local activeNotifications = {}
local function notify(msg)
    local isDay = (curMode == "day")
    local nF = Instance.new("Frame", sg)
    nF.Size, nF.Position = UDim2.new(0, 220, 0, 50), UDim2.new(1, 50, 0.8, 0)
    nF.BackgroundColor3 = isDay and Color3.new(1,1,1) or Color3.fromRGB(35,35,40)
    nF.BackgroundTransparency = 0.2
    Instance.new("UICorner", nF).CornerRadius = UDim.new(0,10)
    Instance.new("UIStroke", nF).Color = Color3.fromRGB(200,160,255)

    local nL = Instance.new("TextLabel", nF)
    nL.Size, nL.BackgroundTransparency, nL.Text = UDim2.new(1,0,1,-5), 1, msg
    nL.TextColor3 = isDay and Color3.new(0,0,0) or Color3.new(1,1,1)
    nL.TextSize, nL.Font = 15, Enum.Font.GothamBold

    local barBG = Instance.new("Frame", nF)
    barBG.Size, barBG.Position = UDim2.new(1,-16,0,4), UDim2.new(0,8,1,-8)
    barBG.BackgroundColor3, barBG.ClipsDescendants = Color3.new(0,0,0), true
    Instance.new("UICorner", barBG)
    local bar = Instance.new("Frame", barBG)
    bar.Size, bar.BackgroundColor3 = UDim2.new(1,0,1,0), Color3.fromRGB(150,150,150)
    Instance.new("UICorner", bar)

    table.insert(activeNotifications, nF)
    local function updatePos()
        for i, v in ipairs(activeNotifications) do
            v:TweenPosition(UDim2.new(1, -240, 0.8, -(#activeNotifications - i) * 65), "Out", "Quart", 0.3, true)
        end
    end
    updatePos()

    TweenService:Create(bar, TweenInfo.new(2.5, Enum.EasingStyle.Linear), {Size=UDim2.new(0,0,1,0)}):Play()
    task.delay(2.5, function()
        for i, v in ipairs(activeNotifications) do if v == nF then table.remove(activeNotifications, i) break end end
        nF:TweenPosition(UDim2.new(1, 50, nF.Position.Y.Scale, nF.Position.Y.Offset), "In", "Quart", 0.3, true)
        task.wait(0.3) nF:Destroy() updatePos()
    end)
end

-- [[ 主 UI 結構 ]]
local frame = Instance.new("Frame", sg)
frame.Size, frame.Position = UDim2.new(0, 250, 0, 210), UDim2.new(0.5, -125, 0.5, -105)
frame.BackgroundColor3, frame.BackgroundTransparency = Color3.fromRGB(15,15,15), 0.3
frame.Active, frame.Draggable = true, true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,22)
Instance.new("UIStroke", frame).Color = Color3.fromRGB(200,160,255)

local title = Instance.new("TextLabel", frame)
title.Size, title.Position, title.BackgroundTransparency = UDim2.new(0,160,0,40), UDim2.new(0,15,0,0), 1
title.Text, title.Font, title.TextSize, title.TextColor3 = cfg.name, Enum.Font.GothamBold, 16, Color3.new(1,1,1)
title.TextXAlignment = Enum.TextXAlignment.Left

-- 縮小按鈕
local res = Instance.new("TextButton", sg)
res.Size, res.Visible, res.Text = UDim2.new(0,55,0,55), false, cfg.emo
res.BackgroundColor3, res.BackgroundTransparency = Color3.fromRGB(20,20,20), 0.2
res.TextColor3, res.TextSize = Color3.new(1,1,1), cfg.size
res.Draggable = true
Instance.new("UICorner", res).CornerRadius = UDim.new(1,0)
Instance.new("UIStroke", res).Color = Color3.fromRGB(200,160,255)

-- [[ 顯示 / 隱藏 主選單 + 吸邊處理 ]]
local function showMain()
    local x = res.AbsolutePosition.X - frame.Size.X.Offset/2 + res.Size.X.Offset/2
    local y = res.AbsolutePosition.Y - frame.Size.Y.Offset/2 + res.Size.Y.Offset/2
    frame.Position = UDim2.new(0, x, 0, y)
    frame.Visible, res.Visible = true, false
    notify("選單已恢復")
end

local function hideMain()
    local fPos = frame.AbsolutePosition
    local x = math.clamp(fPos.X + frame.Size.X.Offset/2 - res.Size.X.Offset/2, 0, workspace.CurrentCamera.ViewportSize.X - res.Size.X.Offset)
    local y = math.clamp(fPos.Y + frame.Size.Y.Offset/2 - res.Size.Y.Offset/2, 0, workspace.CurrentCamera.ViewportSize.Y - res.Size.Y.Offset)
    res.Position = UDim2.new(0, x, 0, y)
    frame.Visible, res.Visible = false, true
    notify("選單已縮小")
end

-- [[ 標題按鈕 ]]
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
res.MouseButton1Click:Connect(showMain)

-- [[ 主選單按鈕 ]]
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
    player:SetAttribute("ShaderMode", "day")
    notify("成功套用：早晨模式")
    apply()
end)

mainBtn("🌌 黑夜模式", Color3.fromRGB(160,110,255), UDim2.new(0.07,0,0.42,0), function()
    curMode = "night"
    player:SetAttribute("ShaderMode", "night")
    notify("成功套用：黑夜模式")
    apply()
end)

-- 記憶模式按鈕
local mBtn
mBtn = mainBtn(rem and "💾 記憶模式: ON" or "💾 記憶模式: OFF", rem and Color3.fromRGB(90,180,120) or Color3.fromRGB(120,120,120), UDim2.new(0.07,0,0.68,0), function()
    rem = not rem
    player:SetAttribute("ShaderRemember", rem)
    mBtn.Text = rem and "💾 記憶模式: ON" or "💾 記憶模式: OFF"
    mBtn.BackgroundColor3 = rem and Color3.fromRGB(90,180,120) or Color3.fromRGB(120,120,120)
    notify(rem and "記憶模式：已開啟" or "記憶模式：已關閉")
end)

-- 初始化 apply + 記憶模式通知同步
apply()
if rem then notify("記憶模式已啟用") end
task.spawn(function() while running do apply() task.wait(5) end end)