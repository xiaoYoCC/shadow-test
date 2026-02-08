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
    trollSound = "rbxassetid://5567523620", -- 爆音 ID
    milkyWay = {
        SkyboxBk = "rbxassetid://159454299",
        SkyboxDn = "rbxassetid://159454286",
        SkyboxFt = "rbxassetid://159454293",
        SkyboxLf = "rbxassetid://159454296",
        SkyboxRt = "rbxassetid://159454282",
        SkyboxUp = "rbxassetid://159454300"
    }
}

-- [[ 1. 清理舊 UI ]]
local pGui = player:WaitForChild("PlayerGui")
if pGui:FindFirstChild("xiaoYo_ShaderUI") then pGui.xiaoYo_ShaderUI:Destroy() end

local running = true
local curMode = player:GetAttribute("ShaderMode") or "day"
local rem = player:GetAttribute("ShaderRemember") or false

local sg = Instance.new("ScreenGui", pGui)
sg.Name, sg.ResetOnSpawn, sg.DisplayOrder = "xiaoYo_ShaderUI", false, 99999

-- [[ 2. 渲染核心功能 ]]
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

-- [[ 3. 修復版通知系統 (向上推疊動畫) ]]
local activeNotifications = {} -- 存儲所有通知的 Table

local function updateNotificationPositions()
    -- 倒序遍歷，讓最新的在最下面，舊的往上推
    for i, frame in ipairs(activeNotifications) do
        -- 計算目標位置：底部基準線 - (索引 * 間距)
        -- i=1 是最新的，位置在最下面
        local targetYOffset = -50 - ((i - 1) * 60)
        frame:TweenPosition(UDim2.new(1, -240, 0.9, targetYOffset), "Out", "Quart", 0.3, true)
    end
end

local function notify(msg)
    local isDay = (curMode == "day")
    local nF = Instance.new("Frame", sg)
    -- 初始位置在螢幕外右側
    nF.Size, nF.Position = UDim2.new(0, 220, 0, 50), UDim2.new(1, 50, 0.9, -50)
    nF.BackgroundColor3 = isDay and Color3.new(1,1,1) or Color3.fromRGB(35,35,40)
    nF.BackgroundTransparency = 0.2
    nF.ZIndex = 10
    Instance.new("UICorner", nF).CornerRadius = UDim.new(0,10)
    Instance.new("UIStroke", nF).Color = Color3.fromRGB(200,160,255)

    local nL = Instance.new("TextLabel", nF)
    nL.Size, nL.BackgroundTransparency, nL.Text = UDim2.new(1,0,1,-5), 1, msg
    nL.TextColor3 = isDay and Color3.new(0,0,0) or Color3.new(1,1,1)
    nL.TextSize, nL.Font = 15, Enum.Font.GothamBold
    nL.ZIndex = 11

    -- 進度條
    local barBG = Instance.new("Frame", nF)
    barBG.Size, barBG.Position = UDim2.new(1,-16,0,4), UDim2.new(0,8,1,-8)
    barBG.BackgroundColor3, barBG.ClipsDescendants = Color3.new(0,0,0), true
    barBG.ZIndex = 11
    Instance.new("UICorner", barBG)
    local bar = Instance.new("Frame", barBG)
    bar.Size, bar.BackgroundColor3 = UDim2.new(1,0,1,0), Color3.fromRGB(180,180,180)
    bar.ZIndex = 12
    Instance.new("UICorner", bar)

    -- 插入到 Table 的第一個位置（最新的）
    table.insert(activeNotifications, 1, nF)
    updateNotificationPositions()

    -- 動畫與銷毀邏輯
    TweenService:Create(bar, TweenInfo.new(2.5, Enum.EasingStyle.Linear), {Size=UDim2.new(0,0,1,0)}):Play()
    
    task.delay(2.5, function()
        -- 移除邏輯
        for i, v in ipairs(activeNotifications) do
            if v == nF then
                table.remove(activeNotifications, i)
                break
            end
        end
        -- 往右滑出消失
        nF:TweenPosition(UDim2.new(1, 50, nF.Position.Y.Scale, nF.Position.Y.Offset), "In", "Quart", 0.3, true)
        task.wait(0.3)
        nF:Destroy()
        updateNotificationPositions() -- 重新排列剩下的
    end)
end

-- [[ 4. 主 UI 構建 ]]
local frame = Instance.new("Frame", sg)
frame.Name = "MainFrame"
frame.Size, frame.Position = UDim2.new(0, 250, 0, 210), UDim2.new(0.5, -125, 0.5, -105)
frame.BackgroundColor3, frame.BackgroundTransparency = Color3.fromRGB(15,15,15), 0.25
frame.Active, frame.Draggable = true, true
frame.ZIndex = 1
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,20)
Instance.new("UIStroke", frame).Color = Color3.fromRGB(200,160,255)

local title = Instance.new("TextLabel", frame)
title.Size, title.Position, title.BackgroundTransparency = UDim2.new(0,160,0,40), UDim2.new(0,15,0,0), 1
title.Text, title.Font, title.TextSize, title.TextColor3 = cfg.name, Enum.Font.GothamBold, 16, Color3.new(1,1,1)
title.TextXAlignment = Enum.TextXAlignment.Left

local res = Instance.new("TextButton", sg)
res.Name = "ResButton"
res.Size, res.Visible, res.Text = UDim2.new(0,50,0,50), false, cfg.emo
res.BackgroundColor3, res.BackgroundTransparency = Color3.fromRGB(20,20,20), 0.2
res.TextColor3, res.TextSize = Color3.new(1,1,1), cfg.size
res.Draggable = true
res.ZIndex = 2
Instance.new("UICorner", res).CornerRadius = UDim.new(1,0)
Instance.new("UIStroke", res).Color = Color3.fromRGB(200,160,255)

-- [[ 5. 關閉流程與🗿邏輯 (核心修復) ]]
local function finalCloseSequence()
    running = false
    
    -- 1. 隱藏所有 UI 元素 (讓畫面變乾淨)
    sg.Enabled = false 
    -- 創建一個新的臨時 GUI 來放🗿，確保不會被舊的干擾
    local trollGui = Instance.new("ScreenGui", pGui)
    trollGui.Name = "TrollUI"
    trollGui.DisplayOrder = 100000

    -- 2. 播放音效 (掛載到 SoundService 以防腳本刪除後聲音中斷)
    local s = Instance.new("Sound")
    s.SoundId = cfg.trollSound
    s.Volume = 10
    s.Parent = SoundService
    s:Play()
    Debris:AddItem(s, 5) -- 5秒後自動清理音效物件

    -- 3. 顯示🗿
    local moai = Instance.new("TextLabel", trollGui)
    moai.Size = UDim2.new(1, 0, 1, 0)
    moai.Position = UDim2.new(0, 0, 0, 0)
    moai.BackgroundTransparency = 1
    moai.Text = "🗿"
    moai.TextSize = 200
    moai.TextColor3 = Color3.new(1,1,1)
    moai.TextTransparency = 0 -- 初始可見
    
    -- 4. 漸隱效果
    local tween = TweenService:Create(moai, TweenInfo.new(2, Enum.EasingStyle.Linear), {TextTransparency = 1, TextSize = 250})
    tween:Play()
    
    -- 5. 等待動畫結束後徹底刪除
    task.wait(2)
    trollGui:Destroy()
    sg:Destroy()
    script:Destroy() -- 自我銷毀
end

local function openConfirmUI()
    if sg:FindFirstChild("ConfirmFrame") then return end -- 防止重複開啟

    local confirmF = Instance.new("Frame", sg)
    confirmF.Name = "ConfirmFrame"
    confirmF.Size = UDim2.new(0, 240, 0, 180) -- 4:3 比例
    confirmF.Position = UDim2.new(0.5, -120, 0.5, -90)
    confirmF.BackgroundColor3, confirmF.BackgroundTransparency = Color3.fromRGB(15,15,15), 0.1
    confirmF.ZIndex = 100 -- 確保在最上層
    Instance.new("UICorner", confirmF).CornerRadius = UDim.new(0,15)
    Instance.new("UIStroke", confirmF).Color = Color3.fromRGB(200,160,255)

    local msg = Instance.new("TextLabel", confirmF)
    msg.Size, msg.Position, msg.BackgroundTransparency = UDim2.new(1,0,0,80), UDim2.new(0,0,0,10), 1
    msg.Text, msg.TextColor3, msg.Font, msg.TextSize = "確定要關閉渲染嗎？", Color3.new(1,1,1), Enum.Font.GothamBold, 16
    msg.ZIndex = 101

    local function createBtn(txt, col, pos, cb)
        local b = Instance.new("TextButton", confirmF)
        b.Size, b.Position, b.Text, b.BackgroundColor3 = UDim2.new(0,80,0,35), pos, txt, col
        b.TextColor3, b.Font, b.TextSize = Color3.new(1,1,1), Enum.Font.GothamMedium, 14
        b.ZIndex = 102
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
        b.MouseButton1Click:Connect(cb)
    end

    createBtn("取消", Color3.fromRGB(60,60,60), UDim2.new(0.1,0,0.65,0), function() 
        confirmF:Destroy() 
    end)
    
    createBtn("關閉", Color3.fromRGB(150,50,50), UDim2.new(0.55,0,0.65,0), function()
        finalCloseSequence() -- 觸發最終流程
    end)
end

-- [[ 6. 位移與互動邏輯 ]]
local dragStartPos = nil
res.MouseButton1Down:Connect(function()
    dragStartPos = res.AbsolutePosition
end)
res.MouseButton1Up:Connect(function()
    if dragStartPos then
        local dist = (res.AbsolutePosition - dragStartPos).Magnitude
        if dist < 8 then
            frame.Position = UDim2.new(0, res.AbsolutePosition.X + 50, 0, res.AbsolutePosition.Y)
            frame.Visible, res.Visible = true, false
            notify("選單已恢復")
        end
    end
end)

local function headBtn(txt, pos, col, cb)
    local b = Instance.new("TextButton", frame)
    b.Size, b.Position, b.Text, b.BackgroundColor3 = UDim2.new(0,24,0,24), pos, txt, col
    b.TextColor3, b.Font = Color3.new(1,1,1), Enum.Font.GothamBold
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
    b.MouseButton1Click:Connect(cb)
    return b
end

-- 縮小按鈕
headBtn("-", UDim2.new(1,-65,0,8), Color3.fromRGB(60,60,60), function()
    local fPos = frame.AbsolutePosition
    res.Position = UDim2.new(0, fPos.X - 50, 0, fPos.Y)
    frame.Visible, res.Visible = false, true
    notify("選單已縮小")
end)

-- 關閉按鈕 (呼叫確認視窗)
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
    curMode = "day"
    player:SetAttribute("ShaderMode", "day")
    notify("成功套用：早晨模式")
    apply()
end)

mainBtn("🌌 夜晚模式", Color3.fromRGB(140,90,255), UDim2.new(0.06,0,0.45,0), function()
    curMode = "night"
    player:SetAttribute("ShaderMode", "night")
    notify("成功套用：夜晚模式")
    apply()
end)

local mBtn
mBtn = mainBtn(rem and "💾 儲存模式: ON" or "💾 儲存模式: OFF", rem and Color3.fromRGB(80,160,100) or Color3.fromRGB(100,100,100), UDim2.new(0.06,0,0.72,0), function()
    rem = not rem
    player:SetAttribute("ShaderRemember", rem)
    mBtn.Text = rem and "💾 儲存模式: ON" or "💾 儲存模式: OFF"
    mBtn.BackgroundColor3 = rem and Color3.fromRGB(80,160,100) or Color3.fromRGB(100,100,100)
    notify(rem and "儲存模式：已開啟" or "儲存模式：已關閉")
end)

-- K鍵切換
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.K then
        curMode = (curMode == "day") and "night" or "day"
        player:SetAttribute("ShaderMode", curMode)
        notify(curMode == "day" and "快捷切換：早晨" or "快捷切換：夜晚")
        apply()
    end
end)

if rem and player:GetAttribute("ShaderMode") then
    curMode = player:GetAttribute("ShaderMode")
    apply()
end

task.spawn(function() while running do apply() task.wait(3) end end)
apply()
