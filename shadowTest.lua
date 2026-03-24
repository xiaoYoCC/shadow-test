local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Debris = game:GetService("Debris")
local player = Players.LocalPlayer

-- [[ 腳本配置區 ]]
local cfg = {
    emo  = "👾",
    size = 24,
    name = "✨ xiaoYo 閃避終極版",
    trollSound = "rbxassetid://117487354926114", 
    milkyWay = {
        SkyboxBk = "rbxassetid://159454299", SkyboxDn = "rbxassetid://159454286",
        SkyboxFt = "rbxassetid://159454293", SkyboxLf = "rbxassetid://159454296",
        SkyboxRt = "rbxassetid://159454282", SkyboxUp = "rbxassetid://159454300"
    }
}

-- 清理舊 UI
local pGui = player:WaitForChild("PlayerGui")
if pGui:FindFirstChild("xiaoYo_FinalUI") then pGui.xiaoYo_FinalUI:Destroy() end

local running = true
local curMode = player:GetAttribute("ShaderMode") or "day"
local rem = player:GetAttribute("ShaderRemember") or false

local sg = Instance.new("ScreenGui", pGui)
sg.Name, sg.ResetOnSpawn, sg.DisplayOrder = "xiaoYo_FinalUI", false, 99999

-- [[ 1. 渲染系統核心 ]]
local function getEff(cl, nm)
    local e = Lighting:FindFirstChild(nm) or Instance.new(cl)
    e.Name, e.Parent = nm, Lighting
    return e
end

local CC, Atm, Bloom = getEff("ColorCorrectionEffect", "x_CC"), getEff("Atmosphere", "x_Atm"), getEff("BloomEffect", "x_Bloom")

local function apply()
    if not running then return end
    local isDay = (curMode == "day")
    
    -- 天空盒處理
    local sky = getEff("Sky", "x_Sky")
    if not isDay then
        sky.SkyboxBk, sky.SkyboxDn, sky.SkyboxFt = cfg.milkyWay.SkyboxBk, cfg.milkyWay.SkyboxDn, cfg.milkyWay.SkyboxFt
        sky.SkyboxLf, sky.SkyboxRt, sky.SkyboxUp = cfg.milkyWay.SkyboxLf, cfg.milkyWay.SkyboxRt, cfg.milkyWay.SkyboxUp
    else
        sky.SkyboxBk, sky.SkyboxDn, sky.SkyboxFt, sky.SkyboxLf, sky.SkyboxRt, sky.SkyboxUp = "","","","","",""
    end

    local t = isDay and {
        CT = 14.5, B = 2.8, E = 0, C = 0.15, S = 0.15, Tint = Color3.fromRGB(255, 252, 240),
        Dens = 0.2, Amb = Color3.fromRGB(110, 110, 115)
    } or {
        CT = 0, B = 2.5, E = 0.25, C = 0.2, S = 0.3, Tint = Color3.fromRGB(200, 210, 255),
        Dens = 0.01, Amb = Color3.fromRGB(40, 40, 55)
    }

    local ti = TweenInfo.new(1.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    Lighting.Ambient, Lighting.OutdoorAmbient = t.Amb, t.Amb
    TweenService:Create(Lighting, ti, {ClockTime=t.CT, Brightness=t.B, ExposureCompensation=t.E}):Play()
    TweenService:Create(CC, ti, {Contrast=t.C, Saturation=t.S, TintColor=t.Tint}):Play()
    TweenService:Create(Atm, ti, {Density=t.Dens}):Play()
    TweenService:Create(Bloom, ti, {Intensity=0.5, Threshold=0.8}):Play()
end

-- [[ 2. 通知系統 ]]
local function notify(msg)
    local nF = Instance.new("Frame", sg)
    nF.Size, nF.Position = UDim2.new(0, 220, 0, 50), UDim2.new(1, 50, 0.8, 0)
    nF.BackgroundColor3, nF.BackgroundTransparency = Color3.fromRGB(30,30,35), 0.2
    Instance.new("UICorner", nF).CornerRadius = UDim.new(0,10)
    Instance.new("UIStroke", nF).Color = Color3.fromRGB(200,160,255)

    local nL = Instance.new("TextLabel", nF)
    nL.Size, nL.BackgroundTransparency, nL.Text, nL.TextColor3 = UDim2.new(1,0,1,0), 1, msg, Color3.new(1,1,1)
    nL.TextSize, nL.Font = 14, Enum.Font.GothamBold

    nF:TweenPosition(UDim2.new(1, -240, 0.8, 0), "Out", "Quart", 0.4, true)
    task.delay(2.5, function()
        nF:TweenPosition(UDim2.new(1, 50, 0.8, 0), "In", "Quart", 0.4, true)
        task.wait(0.4) nF:Destroy()
    end)
end

-- [[ 3. 日本服極限跳轉邏輯 ]]
local req = (syn and syn.request) or (http and http.request) or http_request or request
local function jumpToJapan()
    if not req then notify("❌ 執行器不支援跳轉功能") return end
    notify("🌸 正在過濾日本低延遲節點...")
    
    task.spawn(function()
        local url = "https://games.roblox.com/v1/games/"..tostring(game.PlaceId).."/servers/Public?sortOrder=Asc&limit=100"
        local success, response = pcall(function() return req({Url = url, Method = "GET"}) end)

        if success and response.Success then
            local data = HttpService:JSONDecode(response.Body)
            local bestServers = {}

            if data and data.data then
                for _, srv in ipairs(data.data) do
                    -- 嚴格篩選：Ping 在 35ms ~ 85ms 之間 (台灣連日本/香港的真實數值)
                    -- 且人數大於 2 人 (避免死服) 小於滿員
                    local p = srv.ping or 999
                    if p >= 35 and p <= 85 and srv.playing < srv.maxPlayers and srv.playing > 2 then
                        table.insert(bestServers, srv.id)
                    end
                end
            end

            if #bestServers > 0 then
                local target = bestServers[math.random(1, #bestServers)]
                notify("🚀 找到最佳節點，正在傳送...")
                task.wait(0.5)
                TeleportService:TeleportToPlaceInstance(game.PlaceId, target, player)
            else
                -- 備用方案：如果找不到標註準確的，找人數最少的後段伺服器
                notify("⚠️ 查無精準標籤，嘗試新開伺服器...")
                local fallback = data.data[math.random(#data.data-5, #data.data)]
                if fallback then TeleportService:TeleportToPlaceInstance(game.PlaceId, fallback.id, player) end
            end
        else
            notify("❌ 無法獲取伺服器列表")
        end
    end)
end

-- [[ 4. 關閉腳本處理 ]]
local function finalExit()
    running = false
    sg.Enabled = false
    
    -- 播放 Moai 音效與特效
    local sound = Instance.new("Sound", SoundService)
    sound.SoundId, sound.Volume = cfg.trollSound, 0.5
    sound:Play()
    
    local tGui = Instance.new("ScreenGui", pGui)
    local moai = Instance.new("TextLabel", tGui)
    moai.Size, moai.Position, moai.BackgroundTransparency = UDim2.new(0,400,0,400), UDim2.new(0.5,-200,0.5,-200), 1
    moai.Text, moai.TextSize, moai.Font = "🗿", 200, Enum.Font.GothamBold
    moai.TextColor3 = Color3.new(1,1,1)
    
    TweenService:Create(moai, TweenInfo.new(1.5, Enum.EasingStyle.Quart), {TextTransparency = 1, Position = UDim2.new(0.5,-200,0.2,-200)}):Play()
    
    task.delay(2, function() tGui:Destroy() sg:Destroy() end)
end

-- [[ 5. UI 介面構建 ]]
local frame = Instance.new("Frame", sg)
frame.Size, frame.Position = UDim2.new(0, 250, 0, 260), UDim2.new(0.5, -125, 0.5, -130)
frame.BackgroundColor3, frame.BackgroundTransparency = Color3.fromRGB(15,15,15), 0.25
frame.Active, frame.Draggable = true, true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,20)
Instance.new("UIStroke", frame).Color = Color3.fromRGB(200,160,255)

local title = Instance.new("TextLabel", frame)
title.Size, title.Position, title.Text = UDim2.new(0,160,0,40), UDim2.new(0,15,0,0), cfg.name
title.TextColor3, title.Font, title.TextSize, title.BackgroundTransparency = Color3.new(1,1,1), Enum.Font.GothamBold, 16, 1
title.TextXAlignment = Enum.TextXAlignment.Left

local res = Instance.new("TextButton", sg)
res.Size, res.Visible, res.Text = UDim2.new(0,50,0,50), false, cfg.emo
res.BackgroundColor3, res.BackgroundTransparency, res.TextColor3, res.TextSize = Color3.fromRGB(20,20,20), 0.2, Color3.new(1,1,1), cfg.size
res.Draggable = true
Instance.new("UICorner", res).CornerRadius = UDim.new(1,0)
Instance.new("UIStroke", res).Color = Color3.fromRGB(200,160,255)

-- 頂部按鈕
local function hBtn(txt, pos, col, cb)
    local b = Instance.new("TextButton", frame)
    b.Size, b.Position, b.Text, b.BackgroundColor3 = UDim2.new(0,24,0,24), pos, txt, col
    b.TextColor3, b.Font = Color3.new(1,1,1), Enum.Font.GothamBold
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
    b.MouseButton1Click:Connect(cb)
end
hBtn("-", UDim2.new(1,-65,0,8), Color3.fromRGB(60,60,60), function() frame.Visible, res.Visible = false, true end)
hBtn("×", UDim2.new(1,-32,0,8), Color3.fromRGB(150,50,50), finalExit)

-- 主功能按鈕
local function mainBtn(txt,col,pos,cb)
    local b = Instance.new("TextButton", frame)
    b.Size, b.Position, b.Text, b.BackgroundColor3 = UDim2.new(0.88,0,0,38), pos, txt, col
    b.TextColor3, b.Font, b.BackgroundTransparency = Color3.new(1,1,1), Enum.Font.GothamMedium, 0.2
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
    b.MouseButton1Click:Connect(cb)
    return b
end

mainBtn("☀ 早晨渲染模式", Color3.fromRGB(100,170,255), UDim2.new(0.06,0,0.20,0), function() curMode="day"; apply(); notify("已切換至早晨") end)
mainBtn("🌌 夜晚渲染模式", Color3.fromRGB(140,90,255), UDim2.new(0.06,0,0.38,0), function() curMode="night"; apply(); notify("已切換至夜晚") end)

local mBtn; mBtn = mainBtn(rem and "💾 記憶模式: ON" or "💾 記憶模式: OFF", rem and Color3.fromRGB(80,160,100) or Color3.fromRGB(100,100,100), UDim2.new(0.06,0,0.56,0), function()
    rem = not rem; player:SetAttribute("ShaderRemember", rem)
    mBtn.Text = rem and "💾 記憶模式: ON" or "💾 記憶模式: OFF"
    mBtn.BackgroundColor3 = rem and Color3.fromRGB(80,160,100) or Color3.fromRGB(100,100,100)
end)

mainBtn("🌸 強制重導日本服", Color3.fromRGB(255,140,180), UDim2.new(0.06,0,0.74,0), jumpToJapan)

-- 縮小點點回歸
res.MouseButton1Click:Connect(function() frame.Visible, res.Visible = true, false end)

-- [[ 6. 核心循環：自動倒地滑行 + 渲染維持 ]]
apply()
task.spawn(function()
    while running do
        pcall(function()
            local char = player.Character
            if char then
                -- 倒地自動蹲下實現滑行 (Evade 核心邏輯)
                if char:GetAttribute("Downed") and char:GetAttribute("Emoting") then
                    char:SetAttribute("Crouching", true)
                end
            end
        end)
        task.wait(0.1)
    end
end)

-- 快捷鍵 K 切換模式
UserInputService.InputBegan:Connect(function(i, p)
    if not p and i.KeyCode == Enum.KeyCode.K then
        curMode = (curMode == "day") and "night" or "day"
        apply()
    end
end)

notify("腳本加載成功！祝你遊戲愉快")
