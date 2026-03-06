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
    trollSound = "rbxassetid://117487354926114", 
    milkyWay = {
        SkyboxBk = "rbxassetid://159454299",
        SkyboxDn = "rbxassetid://159454286",
        SkyboxFt = "rbxassetid://159454293",
        SkyboxLf = "rbxassetid://159454296",
        SkyboxRt = "rbxassetid://159454282",
        SkyboxUp = "rbxassetid://159454300"
    }
}

-- [[ 1. 初始化 ]]
local pGui = player:WaitForChild("PlayerGui")
if pGui:FindFirstChild("xiaoYo_ShaderUI") then pGui.xiaoYo_ShaderUI:Destroy() end

local running = true
local curMode = player:GetAttribute("ShaderMode") or "day"
local rem = player:GetAttribute("ShaderRemember") or false

local sg = Instance.new("ScreenGui", pGui)
sg.Name, sg.ResetOnSpawn, sg.DisplayOrder = "xiaoYo_ShaderUI", false, 99999

-- [[ 2. 渲染核心 ]]
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

-- [[ 3. 關閉功能 (音量 0.5 + 🗿) ]]
local function finalExit()
    running = false
    sg.Enabled = false 
    local tGui = Instance.new("ScreenGui", pGui)
    tGui.DisplayOrder = 999999
    local s = Instance.new("Sound", SoundService)
    s.SoundId, s.Volume = cfg.trollSound, 0.5
    s:Play() Debris:AddItem(s, 8) 
    local moai = Instance.new("TextLabel", tGui)
    moai.Size, moai.Position = UDim2.new(0, 400, 0, 400), UDim2.new(0.5, -200, 0.5, -200)
    moai.BackgroundTransparency, moai.Text = 1, "🗿"
    moai.TextSize, moai.TextColor3 = 250, Color3.new(1,1,1)
    TweenService:Create(moai, TweenInfo.new(2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = 1, Position = UDim2.new(0.5, -200, 0.3, -200)}):Play()
    task.wait(2) tGui:Destroy() sg:Destroy() script:Destroy()
end

-- [[ 4. UI 構建與按鈕 ]]
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

local function hBtn(txt, pos, col, cb)
    local btn = Instance.new("TextButton", frame)
    btn.Size, btn.Position, btn.Text, btn.BackgroundColor3 = UDim2.new(0,24,0,24), pos, txt, col
    btn.TextColor3, btn.Font = Color3.new(1,1,1), Enum.Font.GothamBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
    btn.MouseButton1Click:Connect(cb)
end
hBtn("-", UDim2.new(1,-65,0,8), Color3.fromRGB(60,60,60), function() frame.Visible, res.Visible = false, true end)
hBtn("×", UDim2.new(1,-32,0,8), Color3.fromRGB(150,50,50), finalExit)

local function mainBtn(txt,col,pos,cb)
    local b = Instance.new("TextButton", frame)
    b.Size, b.Position, b.Text, b.BackgroundColor3 = UDim2.new(0.88,0,0,38), pos, txt, col
    b.TextColor3, b.Font, b.BackgroundTransparency = Color3.new(1,1,1), Enum.Font.GothamMedium, 0.2
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(cb)
    return b
end
mainBtn("☀ 早晨模式", Color3.fromRGB(100,170,255), UDim2.new(0.06,0,0.24,0), function() curMode="day"; apply() end)
mainBtn("🌌 夜晚模式", Color3.fromRGB(140,90,255), UDim2.new(0.06,0,0.45,0), function() curMode="night"; apply() end)
local mBtn; mBtn = mainBtn(rem and "💾 儲存模式: ON" or "💾 儲存模式: OFF", rem and Color3.fromRGB(80,160,100) or Color3.fromRGB(100,100,100), UDim2.new(0.06,0,0.72,0), function()
    rem = not rem; mBtn.Text = rem and "💾 儲存模式: ON" or "💾 儲存模式: OFF"; mBtn.BackgroundColor3 = rem and Color3.fromRGB(80,160,100) or Color3.fromRGB(100,100,100)
end)

-- [[ 5. 倒地滑手機優化版邏輯 ]]
local function slideLogic()
    local char = player.Character
    if char then
        local downed = char:GetAttribute("Downed")
        local emoting = char:GetAttribute("Emoting")
        
        -- 如果偵測到倒地且正在動作，強制注入蹲下屬性
        if downed and emoting then
            char:SetAttribute("Crouching", true)
            -- 強力鎖定：防止遊戲在倒地時強制重置你的物理摩擦力
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = false end 
        end
    end
end

-- [[ 6. 核心循環：渲染維持 + 倒地滑偵測 ]]
apply()
task.spawn(function()
    while running do
        slideLogic() -- 高頻偵測倒地滑（對手機操作更靈敏）
        task.wait(0.1) -- 0.1秒檢查一次，確保不卡頓但夠快
    end
end)

-- 渲染維持循環（較低頻率以節省效能）
task.spawn(function()
    while running do
        task.wait(3)
        if running then apply() end
    end
end)

-- 快捷鍵保持
UserInputService.InputBegan:Connect(function(i, p)
    if not p and i.KeyCode == Enum.KeyCode.K then
        curMode = (curMode == "day") and "night" or "day"; apply()
    end
end)
