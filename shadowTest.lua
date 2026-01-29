local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
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

-- [[ 通知管理系統 ]]
local activeNotifications = {}
local function notify(msg)
    local nF = Instance.new("Frame", sg)
    nF.ZIndex = 1005
    nF.Size = UDim2.new(0, 220, 0, 50)
    nF.Position = UDim2.new(1, 50, 0.8, 0)
    nF.BackgroundColor3, nF.BackgroundTransparency = Color3.new(1,1,1), 0.66
    nF.BorderSizePixel = 0
    Instance.new("UICorner", nF).CornerRadius = UDim.new(0,8)
    
    local stroke = Instance.new("UIStroke", nF)
    stroke.Color, stroke.Thickness = Color3.fromRGB(200, 160, 255), 2

    local nL = Instance.new("TextLabel", nF)
    nL.Size, nL.BackgroundTransparency, nL.Text = UDim2.new(1,0,1,-5), 1, msg
    nL.TextColor3, nL.TextSize, nL.Font = Color3.new(0,0,0), 15, Enum.Font.GothamBold

    local barBG = Instance.new("Frame", nF)
    barBG.Size, barBG.Position = UDim2.new(1,0,0,4), UDim2.new(0,0,1,-4)
    barBG.BackgroundColor3, barBG.BackgroundTransparency = Color3.new(0,0,0), 0.8
    barBG.BorderSizePixel = 0
    
    local bar = Instance.new("Frame", barBG)
    bar.Size, bar.BackgroundColor3, bar.BorderSizePixel = UDim2.new(1,0,1,0), Color3.fromRGB(150,150,150), 0
    Instance.new("UICorner", bar)

    table.insert(activeNotifications, nF)

    local function updatePositions()
        local validNotifs = {}
        for _, v in ipairs(activeNotifications) do
            if v and v.Parent then table.insert(validNotifs, v) end
        end
        for i, v in ipairs(validNotifs) do
            local yOffset = ( #validNotifs - i ) * 65
            v:TweenPosition(UDim2.new(1, -240, 0.8, -yOffset), "Out", "Quart", 0.3, true)
        end
    end
    updatePositions()

    local t = TweenService:Create(bar, TweenInfo.new(2.5, Enum.EasingStyle.Linear), {Size = UDim2.new(0,0,1,0)})
    t:Play()
    t.Completed:Connect(function()
        for i, v in ipairs(activeNotifications) do
            if v == nF then table.remove(activeNotifications, i) break end
        end
        nF:TweenPosition(UDim2.new(1, 50, nF.Position.Y.Scale, nF.Position.Y.Offset), "In", "Quart", 0.3, true)
        task.wait(0.3)
        nF:Destroy()
        updatePositions()
    end)
end

-- [[ 主 UI ]]
local frame = Instance.new("Frame", sg)
frame.Size, frame.Position = UDim2.new(0, 250, 0, 210), UDim2.new(0.5, -125, 0.5, -105)
frame.BackgroundColor3, frame.BackgroundTransparency = Color3.fromRGB(15,15,15), 0.3
frame.Active, frame.Draggable = true, true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,22)
local fStroke = Instance.new("UIStroke", frame)
fStroke.Color, fStroke.Thickness, fStroke.Transparency = Color3.fromRGB(200, 160, 255), 1.5, 0.4

local title = Instance.new("TextLabel", frame)
title.Size, title.Position, title.BackgroundTransparency = UDim2.new(0,160,0,40), UDim2.new(0,15,0,0), 1
title.Text, title.Font, title.TextSize, title.TextColor3 = cfg.name, Enum.Font.GothamBold, 16, Color3.new(1,1,1)
title.TextXAlignment = Enum.TextXAlignment.Left

-- 縮小點 (Res)
local res = Instance.new("TextButton", sg)
res.Size, res.Visible, res.Text = UDim2.new(0,55,0,55), false, cfg.emo
res.BackgroundColor3, res.BackgroundTransparency = Color3.fromRGB(20,20,20), 0.2
res.TextColor3, res.TextSize = Color3.new(1,1,1), cfg.size
res.Draggable = true
Instance.new("UICorner", res).CornerRadius = UDim.new(1,0)
local rStroke = Instance.new("UIStroke", res)
rStroke.Color, rStroke.Thickness = Color3.fromRGB(200, 160, 255), 2

-- [[ 功能：左上角原位對齊邏輯 ]]
local function showMain()
    -- 恢復時，主視窗左上角對準小點中心
    local targetX = res.AbsolutePosition.X - (res.Size.X.Offset / 2) + 27
    local targetY = res.AbsolutePosition.Y - (res.Size.Y.Offset / 2) + 27
    frame.Position = UDim2.new(0, targetX, 0, targetY)
    frame.Visible, res.Visible = true, false
    notify("選單已恢復")
end

local function hideMain()
    -- 縮小時，小點中心對準主視窗左上角
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

-- 最小化按鈕
headBtn("-", UDim2.new(1,-60,0,9), Color3.fromRGB(60,60,60), function()
    hideMain()
end)

headBtn("×", UDim2.new(1,-30,0,9), Color3.fromRGB(150,50,50), function()
    notify("選單已關閉")
    running = false
    task.wait(0.1)
    sg:Destroy()
end)

local dragStartPos
res.MouseButton1Down:Connect(function() dragStartPos = res.AbsolutePosition end)
res.MouseButton1Up:Connect(function()
    if dragStartPos and (res.AbsolutePosition - dragStartPos).Magnitude <= 8 then
        showMain()
    end
end)

-- [[ 渲染控制 ]]
local function getEff(cl,nm)
    local e = Lighting:FindFirstChild(nm) or Instance.new(cl)
    e.Name, e.Parent = nm, Lighting
    return e
end

local function apply()
    if not running then return end
    local CC, Atm, Sky = getEff("ColorCorrectionEffect","x_CC"), getEff("Atmosphere","x_Atm"), getEff("Sky","x_Sky")
    local t = (curMode=="day") and {CT=14,B=2.0,C=0.08,S=0.14,T=Color3.fromRGB(255,245,235),AD=0.28,Sdw=false,Sky=false} or
                                   {CT=23.5,B=1.4,C=0.22,S=0.35,T=Color3.fromRGB(215,205,255),AD=0.35,Sdw=true,Sky=true}

    TweenService:Create(Lighting, TweenInfo.new(1), {ClockTime = t.CT, Brightness = t.B}):Play()
    Lighting.GlobalShadows = t.Sdw
    CC.Contrast, CC.Saturation, CC.TintColor = t.C, t.S, t.T
    Atm.Density, Sky.Enabled = t.AD, t.Sky
end

local function mainBtn(txt,col,pos,cb)
    local b = Instance.new("TextButton", frame)
    b.Size, b.Position, b.Text, b.BackgroundColor3 = UDim2.new(0.86,0,0,36), pos, txt, col
    b.TextColor3, b.Font, b.BackgroundTransparency = Color3.new(1,1,1), Enum.Font.GothamMedium, 0.25
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
    b.MouseButton1Click:Connect(cb)
    return b
end

mainBtn("☀ 早晨模式", Color3.fromRGB(120,190,255), UDim2.new(0.07,0,0.22,0), function()
    notify("成功套用：早晨模式")
    curMode = "day"
    player:SetAttribute("ShaderMode", "day")
    apply()
end)

mainBtn("🌌 黑夜模式", Color3.fromRGB(160,110,255), UDim2.new(0.07,0,0.42,0), function()
    notify("成功套用：黑夜模式")
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
    notify(rem and "記憶模式：已開啟" or "記憶模式：已關閉")
end)

task.spawn(function() while running and sg.Parent do apply() task.wait(2) end end)
if rem then task.wait(0.5) apply() end
