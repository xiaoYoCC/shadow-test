local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

local cfg = {
    emo  = "👾",
    size = 24,
    name = "✨ xiaoYo 閃避渲染"
}

-- 清除舊 UI
local pGui = player:WaitForChild("PlayerGui")
if pGui:FindFirstChild("xiaoYo_ShaderUI") then pGui.xiaoYo_ShaderUI:Destroy() end

local running, curMode, rem = true, player:GetAttribute("ShaderMode") or "day", player:GetAttribute("ShaderRemember") or false
local sg = Instance.new("ScreenGui", pGui)
sg.Name, sg.ResetOnSpawn, sg.DisplayOrder = "xiaoYo_ShaderUI", false, 99999
sg.ZIndexBehavior = Enum.ZIndexBehavior.Global

-- [[ 極致渲染引擎 ]]
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
        Dens = 0.3, Bloom = 0.5, Sun = 0.25, DoF = 5, Sdw = true, Dif = 1, Spec = 1
    } or {
        CT = 0, B = 1.5, E = -0.05, C = 0.35, S = 0.4, Tint = Color3.fromRGB(190, 200, 255),
        Dens = 0.45, Bloom = 1.5, Sun = 0, DoF = 10, Sdw = true, Dif = 0.5, Spec = 1.5
    }

    local ti = TweenInfo.new(1.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    Lighting.GlobalShadows = t.Sdw
    TweenService:Create(Lighting, ti, {ClockTime=t.CT, Brightness=t.B, ExposureCompensation=t.E, EnvironmentDiffuseScale=t.Dif, EnvironmentSpecularScale=t.Spec}):Play()
    TweenService:Create(CC, ti, {Contrast=t.C, Saturation=t.S, TintColor=t.Tint}):Play()
    TweenService:Create(Atm, ti, {Density=t.Dens, Haze=t.Dens*1.5}):Play()
    TweenService:Create(Bloom, ti, {Intensity=t.Bloom, Threshold=0.7}):Play()
    TweenService:Create(SunRays, ti, {Intensity=t.Sun}):Play()
    TweenService:Create(DoF, ti, {FarIntensity=0.1, FocusDistance=25, InFocusRadius=t.DoF}):Play()
    Sky.Enabled = not isDay
end

-- [[ 通知系統 ]]
local activeNotifications = {}
local function notify(msg)
    local nF = Instance.new("Frame", sg)
    nF.ZIndex, nF.Size, nF.Position = 1005, UDim2.new(0, 220, 0, 50), UDim2.new(1, 50, 0.8, 0)
    nF.BackgroundColor3, nF.BackgroundTransparency = Color3.new(1,1,1), 0.66
    nF.BorderSizePixel = 0
    Instance.new("UICorner", nF).CornerRadius = UDim.new(0,8)
    Instance.new("UIStroke", nF).Color = Color3.fromRGB(200,160,255)

    local nL = Instance.new("TextLabel", nF)
    nL.Size, nL.BackgroundTransparency, nL.Text = UDim2.new(1,0,1,-5), 1, msg
    nL.TextColor3, nL.TextSize, nL.Font = Color3.new(0,0,0), 15, Enum.Font.GothamBold

    local barBG = Instance.new("Frame", nF)
    barBG.Size, barBG.Position, barBG.BackgroundColor3 = UDim2.new(1,0,0,4), UDim2.new(0,0,1,-4), Color3.new(0,0,0)
    local bar = Instance.new("Frame", barBG)
    bar.Size, bar.BackgroundColor3 = UDim2.new(1,0,1,0), Color3.fromRGB(150,150,150)
    Instance.new("UICorner", bar)

    table.insert(activeNotifications, nF)
    local function updatePositions()
        local valid = {}
        for _, v in ipairs(activeNotifications) do if v and v.Parent then table.insert(valid, v) end end
        for i, v in ipairs(valid) do
            v:TweenPosition(UDim2.new(1, -240, 0.8, -(#valid - i) * 65), "Out", "Quart", 0.3, true)
        end
    end
    updatePositions()

    local t = TweenService:Create(bar, TweenInfo.new(2.5, Enum.EasingStyle.Linear), {Size = UDim2.new(0,0,1,0)})
    t:Play()
    t.Completed:Connect(function()
        for i, v in ipairs(activeNotifications) do if v == nF then table.remove(activeNotifications, i) break end end
        nF:TweenPosition(UDim2.new(1, 50, nF.Position.Y.Scale, nF.Position.Y.Offset), "In", "Quart", 0.3, true)
        task.wait(0.3) nF:Destroy() updatePositions()
    end)
end

-- [[ UI 構建 ]]
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

local res = Instance.new("TextButton", sg)
res.Size, res.Visible, res.Text = UDim2.new(0,55,0,55), false, cfg.emo
res.BackgroundColor3, res.BackgroundTransparency = Color3.fromRGB(20,20,20), 0.2
res.TextColor3, res.TextSize = Color3.new(1,1,1), cfg.size
res.Draggable = true
Instance.new("UICorner", res).CornerRadius = UDim.new(1,0)
Instance.new("UIStroke", res).Color = Color3.fromRGB(200,160,255)

local function showMain()
    local tx, ty = res.AbsolutePosition.X - (res.Size.X.Offset/2) + 27, res.AbsolutePosition.Y - (res.Size.Y.Offset/2) + 27
    frame.Position = UDim2.new(0, tx, 0, ty)
    frame.Visible, res.Visible = true, false
    notify("選單已恢復")
end
local function hideMain()
    local fPos = frame.AbsolutePosition
    res.Position = UDim2.new(0, fPos.X - (res.Size.X.Offset / 2), 0, fPos.Y - (res.Size.Y.Offset / 2))
    frame.Visible, res.Visible = false, true
    notify("選單已縮小")
end

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
    notify("成功套用：早晨模式")
    apply()
end)

mainBtn("🌌 黑夜模式", Color3.fromRGB(160,110,255), UDim2.new(0.07,0,0.42,0), function()
    curMode = "night"
    notify("成功套用：黑夜模式")
    apply()
end)

local mBtn
mBtn = mainBtn(rem and "💾 記憶模式: ON" or "💾 記憶模式: OFF", rem and Color3.fromRGB(90,180,120) or Color3.fromRGB(120,120,120), UDim2.new(0.07,0,0.68,0), function()
    rem = not rem
    player:SetAttribute("ShaderRemember", rem)
    mBtn.Text = rem and "💾 記憶模式: ON" or "💾 記憶模式: OFF"
    mBtn.BackgroundColor3 = rem and Color3.fromRGB(90,180,120) or Color3.fromRGB(120,120,120)
    notify(rem and "記憶模式：已開啟" or "記憶模式：已關閉")
end)

task.spawn(function() while running and sg.Parent do apply() task.wait(3) end end)
if rem then task.wait(0.5) apply() end
