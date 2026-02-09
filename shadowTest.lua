local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local player = Players.LocalPlayer

local cfg = {
    emo  = "👾",
    size = 24,
    name = "✨ xiaoYo 閃避渲染",
    trollSound = "rbxassetid://117487354926114", -- 已更新為指定的音效 ID
    milkyWay = {
        SkyboxBk = "rbxassetid://159454299",
        SkyboxDn = "rbxassetid://159454286",
        SkyboxFt = "rbxassetid://159454293",
        SkyboxLf = "rbxassetid://159454296",
        SkyboxRt = "rbxassetid://159454282",
        SkyboxUp = "rbxassetid://159454300"
    }
}

-- 清理舊 UI
local pGui = player:WaitForChild("PlayerGui")
if pGui:FindFirstChild("xiaoYo_ShaderUI") then pGui.xiaoYo_ShaderUI:Destroy() end

local running = true
local curMode = player:GetAttribute("ShaderMode") or "day"
local rem = player:GetAttribute("ShaderRemember") or false

local sg = Instance.new("ScreenGui", pGui)
sg.Name, sg.ResetOnSpawn, sg.DisplayOrder = "xiaoYo_ShaderUI", false, 99999

-- [[ 渲染組件 ]]
local function getEff(cl, nm)
    local e = Lighting:FindFirstChild(nm) or Instance.new(cl)
    e.Name, e.Parent = nm, Lighting
    return e
end

local CC = getEff("ColorCorrectionEffect", "x_CC")
local Atm = getEff("Atmosphere", "x_Atm")
local Bloom = getEff("BloomEffect", "x_Bloom")

local function applySky(isNight)
    for _, v in ipairs(Lighting:GetChildren()) do
        if (v:IsA("Sky") or v:IsA("Clouds")) and v.Name ~= "x_Sky" then v:Destroy() end
    end
    local s = getEff("Sky", "x_Sky")
    if isNight then
        s.SkyboxBk, s.SkyboxDn, s.SkyboxFt = cfg.milkyWay.SkyboxBk, cfg.milkyWay.SkyboxDn, cfg.milkyWay.SkyboxFt
        s.SkyboxLf, s.SkyboxRt, s.SkyboxUp = cfg.milkyWay.SkyboxLf, cfg.milkyWay.SkyboxRt, cfg.milkyWay.SkyboxUp
        s.SunTextureId, s.MoonTextureId = "", ""
    else
        s.SkyboxBk, s.SkyboxDn, s.SkyboxFt = "", "", ""
        s.SkyboxLf, s.SkyboxRt, s.SkyboxUp = "", "", ""
    end
end

local function apply()
    if not running then return end
    local isDay = (curMode == "day")
    applySky(not isDay)
    
    local t = isDay and {
        CT = 14.5, B = 2.8, E = 0, C = 0.15, S = 0.15, Tint = Color3.fromRGB(255, 252, 240),
        Dens = 0.2, Amb = Color3.fromRGB(110, 110, 115)
    } or {
        CT = 0, B = 2.5, E = 0.25, C = 0.2, S = 0.3, Tint = Color3.fromRGB(200, 210, 255),
        Dens = 0.01, Amb = Color3.fromRGB(40, 40, 55)
    }

    local ti = TweenInfo.new(1.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    
    Lighting.Ambient = t.Amb
    Lighting.OutdoorAmbient = t.Amb
    TweenService:Create(Lighting, ti, {ClockTime=t.CT, Brightness=t.B, ExposureCompensation=t.E}):Play()
    TweenService:Create(CC, ti, {Contrast=t.C, Saturation=t.S, TintColor=t.Tint}):Play()
    TweenService:Create(Atm, ti, {Density=t.Dens}):Play()
    TweenService:Create(Bloom, ti, {Intensity=0.5, Threshold=0.8}):Play()
end

-- [[ 進度條通知系統 ]]
local activeNotifications = {}
local function updatePos()
    for i, v in ipairs(activeNotifications) do
        v:TweenPosition(UDim2.new(1, -240, 0.8, -(#activeNotifications - i) * 65), "Out", "Quart", 0.3, true)
    end
end

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
    bar.Size, bar.BackgroundColor3 = UDim2.new(1,0,1,0), Color3.fromRGB(180,180,180)
    Instance.new("UICorner", bar)

    table.insert(activeNotifications, nF)
    updatePos()

    TweenService:Create(bar, TweenInfo.new(2.5, Enum.EasingStyle.Linear), {Size=UDim2.new(0,0,1,0)}):Play()
    
    task.delay(2.5, function()
        for i, v in ipairs(activeNotifications) do if v == nF then table.remove(activeNotifications, i) break end end
        nF:TweenPosition(UDim2.new(1, 50, nF.Position.Y.Scale, nF.Position.Y.Offset), "In", "Quart", 0.3, true)
        task.wait(0.3) nF:Destroy() updatePos()
    end)
end

-- [[ 主 UI ]]
local frame = Instance.new("Frame", sg)
frame.Size, frame.Position = UDim2.new(0, 250, 0, 210), UDim2.new(0.5, -125, 0.5, -105)
frame.BackgroundColor3, frame.BackgroundTransparency = Color3.fromRGB(15,15,15), 0.25
frame.Active, frame.Draggable = true, true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,20)
Instance.new("UIStroke", frame).Color = Color3.fromRGB(200,160,255)

local title = Instance.new("TextLabel", frame)
title.Size, title.Position, title.BackgroundTransparency = UDim2.new(0,160,0,40), UDim2.new(0,15,0,0), 1
title.Text, title.Font, title.TextSize, title.TextColor3 = cfg.name, Enum.Font.GothamBold, 16, Color3.new(1,1,1)
title.TextXAlignment = Enum.TextXAlignment.Left

local res = Instance.new("TextButton", sg)
res.Size, res.Visible, res.Text = UDim2.new(0,50,0,50), false, cfg.emo
res.BackgroundColor3, res.BackgroundTransparency = Color3.fromRGB(20,20,20), 0.2
res.TextColor3, res.TextSize = Color3.new(1,1,1), cfg.size
res.Draggable = true
Instance.new("UICorner", res).CornerRadius = UDim.new(1,0)
Instance.new("UIStroke", res).Color = Color3.fromRGB(200,160,255)

-- [[ 關閉功能與 🗿 動畫 ]]
local function finalExit()
    running = false
    sg.Enabled = false 
    
    local trollGui = Instance.new("ScreenGui", pGui)
    trollGui.DisplayOrder = 999999
    
    local sound = Instance.new("Sound", SoundService)
    sound.SoundId, sound.Volume = cfg.trollSound, 5
    sound:Play()
    Debris:AddItem(sound, 8) -- 延長清理時間以適應可能的歌曲長度

    local moai = Instance.new("TextLabel", trollGui)
    moai.Size, moai.Position = UDim2.new(0, 400, 0, 400), UDim2.new(0.5, -200, 0.5, -200)
    moai.BackgroundTransparency, moai.Text = 1, "🗿"
    moai.TextSize, moai.TextColor3 = 250, Color3.new(1,1,1)
    moai.Font = Enum.Font.GothamBold
    
    local ti = TweenInfo.new(2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    TweenService:Create(moai, ti, {TextTransparency = 1, Position = UDim2.new(0.5, -200, 0.3, -200)}):Play()
    
    task.wait(2)
    trollGui:Destroy()
    sg:Destroy()
    script:Destroy()
end

local function openConfirmUI()
    if sg:FindFirstChild("ConfirmUI") then return end
    local cF = Instance.new("Frame", sg)
    cF.Name = "ConfirmUI"
    cF.Size, cF.Position = UDim2.new(0, 240, 0, 180), UDim2.new(0.5, -120, 0.5, -90)
    cF.BackgroundColor3, cF.BackgroundTransparency = Color3.fromRGB(15,15,15), 0.1
    cF.ZIndex = 100
    Instance.new("UICorner", cF).CornerRadius = UDim.new(0,15)
    Instance.new("UIStroke", cF).Color = Color3.fromRGB(200,160,255)

    local msg = Instance.new("TextLabel", cF)
    msg.Size, msg.Position, msg.BackgroundTransparency = UDim2.new(1,0,0,80), UDim2.new(0,0,0,10), 1
    msg.Text, msg.TextColor3, msg.Font, msg.TextSize = "確定要關閉渲染嗎？", Color3.new(1,1,1), Enum.Font.GothamBold, 16
    msg.ZIndex = 101

    local function makeBtn(txt, col, pos, cb)
        local b = Instance.new("TextButton", cF)
        b.Size, b.Position, b.Text, b.BackgroundColor3 = UDim2.new(0,80,0,35), pos, txt, col
        b.TextColor3, b.Font, b.TextSize, b.ZIndex = Color3.new(1,1,1), Enum.Font.GothamMedium, 14, 102
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
        b.MouseButton1Click:Connect(cb)
    end
    makeBtn("取消", Color3.fromRGB(60,60,60), UDim2.new(0.1,0,0.65,0), function() cF:Destroy() end)
    makeBtn("關閉", Color3.fromRGB(150,50,50), UDim2.new(0.55,0,0.65,0), finalExit)
end

-- [[ 交互邏輯 ]]
local dragStartPos = nil
res.MouseButton1Down:Connect(function() dragStartPos = res.AbsolutePosition end)
res.MouseButton1Up:Connect(function()
    if dragStartPos and (res.AbsolutePosition - dragStartPos).Magnitude < 8 then
        frame.Position = UDim2.new(0, res.AbsolutePosition.X + 50, 0, res.AbsolutePosition.Y)
        frame.Visible, res.Visible = true, false
        notify("選單已恢復")
    end
end)

local function headBtn(txt, pos, col, cb)
    local b = Instance.new("TextButton", frame)
    b.Size, b.Position, b.Text, b.BackgroundColor3 = UDim2.new(0,24,0,24), pos, txt, col
    b.TextColor3, b.Font = Color3.new(1,1,1), Enum.Font.GothamBold
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
    b.MouseButton1Click:Connect(cb)
end
headBtn("-", UDim2.new(1,-65,0,8), Color3.fromRGB(60,60,60), function()
    res.Position = UDim2.new(0, frame.AbsolutePosition.X - 50, 0, frame.AbsolutePosition.Y)
    frame.Visible, res.Visible = false, true
    notify("選單已縮小")
end)
headBtn("×", UDim2.new(1,-32,0,8), Color3.fromRGB(150,50,50), openConfirmUI)

local function mainBtn(txt,col,pos,cb)
    local b = Instance.new("TextButton", frame)
    b.Size, b.Position, b.Text, b.BackgroundColor3 = UDim2.new(0.88,0,0,38), pos, txt, col
    b.TextColor3, b.Font, b.BackgroundTransparency = Color3.new(1,1,1), Enum.Font.GothamMedium, 0.2
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
    b.MouseButton1Click:Connect(cb)
    return b
end

mainBtn("☀ 早晨模式", Color3.fromRGB(100,170,255), UDim2.new(0.06,0,0.24,0), function()
    curMode = "day"; player:SetAttribute("ShaderMode", "day"); notify("成功套用：早晨模式"); apply()
end)
mainBtn("🌌 夜晚模式", Color3.fromRGB(140,90,255), UDim2.new(0.06,0,0.45,0), function()
    curMode = "night"; player:SetAttribute("ShaderMode", "night"); notify("成功套用：夜晚模式"); apply()
end)

local mBtn
mBtn = mainBtn(rem and "💾 儲存模式: ON" or "💾 儲存模式: OFF", rem and Color3.fromRGB(80,160,100) or Color3.fromRGB(100,100,100), UDim2.new(0.06,0,0.72,0), function()
    rem = not rem; player:SetAttribute("ShaderRemember", rem)
    mBtn.Text = rem and "💾 儲存模式: ON" or "💾 儲存模式: OFF"
    mBtn.BackgroundColor3 = rem and Color3.fromRGB(80,160,100) or Color3.fromRGB(100,100,100)
    notify(rem and "儲存模式：已開啟" or "儲存模式：已關閉")
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.K then
        curMode = (curMode == "day") and "night" or "day"
        player:SetAttribute("ShaderMode", curMode)
        notify(curMode == "day" and "快捷切換：早晨模式" or "快捷切換：夜晚模式")
        apply()
    end
end)

if rem and player:GetAttribute("ShaderMode") then
    curMode = player:GetAttribute("ShaderMode")
end

apply()
task.spawn(function()
    while running do
        task.wait(3)
        if running then apply() end
    end
end)
