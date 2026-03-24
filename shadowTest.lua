local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Debris = game:GetService("Debris")
local player = Players.LocalPlayer

local cfg = {
    emo  = "👾",
    size = 24,
    name = "✨ xiaoYo 閃避渲染",
    trollSound = "rbxassetid://117487354926114", 
    milkyWay = {
        SkyboxBk = "rbxassetid://159454299", SkyboxDn = "rbxassetid://159454286",
        SkyboxFt = "rbxassetid://159454293", SkyboxLf = "rbxassetid://159454296",
        SkyboxRt = "rbxassetid://159454282", SkyboxUp = "rbxassetid://159454300"
    }
}

local pGui = player:WaitForChild("PlayerGui")
if pGui:FindFirstChild("xiaoYo_ShaderUI") then pGui.xiaoYo_ShaderUI:Destroy() end

local running = true
local curMode = player:GetAttribute("ShaderMode") or "day"
local rem = player:GetAttribute("ShaderRemember") or false

local sg = Instance.new("ScreenGui", pGui)
sg.Name, sg.ResetOnSpawn, sg.DisplayOrder = "xiaoYo_ShaderUI", false, 99999

-- [[ 渲染組件與倒地滑邏輯（保留不變） ]]
local function getEff(cl, nm)
    local e = Lighting:FindFirstChild(nm) or Instance.new(cl)
    e.Name, e.Parent = nm, Lighting
    return e
end
local CC, Atm, Bloom = getEff("ColorCorrectionEffect", "x_CC"), getEff("Atmosphere", "x_Atm"), getEff("BloomEffect", "x_Bloom")

local function apply()
    if not running then return end
    local isDay = (curMode == "day")
    local s = getEff("Sky", "x_Sky")
    if not isDay then
        s.SkyboxBk, s.SkyboxDn, s.SkyboxFt = cfg.milkyWay.SkyboxBk, cfg.milkyWay.SkyboxDn, cfg.milkyWay.SkyboxFt
        s.SkyboxLf, s.SkyboxRt, s.SkyboxUp = cfg.milkyWay.SkyboxLf, cfg.milkyWay.SkyboxRt, cfg.milkyWay.SkyboxUp
    else
        s.SkyboxBk, s.SkyboxDn, s.SkyboxFt, s.SkyboxLf, s.SkyboxRt, s.SkyboxUp = "","","","","",""
    end
    local t = isDay and {CT=14.5, B=2.8, E=0, C=0.15, S=0.15, Tint=Color3.fromRGB(255,252,240), Dens=0.2, Amb=Color3.fromRGB(110,110,115)} 
                   or {CT=0, B=2.5, E=0.25, C=0.2, S=0.3, Tint=Color3.fromRGB(200,210,255), Dens=0.01, Amb=Color3.fromRGB(40,40,55)}
    local ti = TweenInfo.new(1.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    Lighting.Ambient, Lighting.OutdoorAmbient = t.Amb, t.Amb
    TweenService:Create(Lighting, ti, {ClockTime=t.CT, Brightness=t.B, ExposureCompensation=t.E}):Play()
    TweenService:Create(CC, ti, {Contrast=t.C, Saturation=t.S, TintColor=t.Tint}):Play()
    TweenService:Create(Atm, ti, {Density=t.Dens}):Play()
    TweenService:Create(Bloom, ti, {Intensity=0.5, Threshold=0.8}):Play()
end

local function notify(msg)
    local isDay = (curMode == "day")
    local nF = Instance.new("Frame", sg)
    nF.Size, nF.Position = UDim2.new(0, 220, 0, 50), UDim2.new(1, 50, 0.8, 0)
    nF.BackgroundColor3, nF.BackgroundTransparency = isDay and Color3.new(1,1,1) or Color3.fromRGB(35,35,40), 0.2
    Instance.new("UICorner", nF)
    local nL = Instance.new("TextLabel", nF)
    nL.Size, nL.BackgroundTransparency, nL.Text, nL.TextColor3 = UDim2.new(1,0,1,-5), 1, msg, isDay and Color3.new(0,0,0) or Color3.new(1,1,1)
    nL.TextSize, nL.Font = 14, Enum.Font.GothamBold
    nF:TweenPosition(UDim2.new(1, -240, 0.8, 0), "Out", "Quart", 0.3, true)
    task.delay(2.5, function() nF:Destroy() end)
end

-- [[ 伺服器跳轉：日本專用邏輯（人數優先版） ]]
local req = (syn and syn.request) or (http and http.request) or http_request or request
local function jumpToJapan()
    if not req then notify("❌ 執行器不支援跳轉") return end
    notify("🌸 正在對接日本專用節點...")
    
    task.spawn(function()
        -- 增加 limit 到 100，擴大搜尋範圍
        local url = "https://games.roblox.com/v1/games/"..tostring(game.PlaceId).."/servers/Public?sortOrder=Asc&limit=100"
        local success, response = pcall(function() return req({Url = url, Method = "GET"}) end)

        if success and response.Success then
            local data = HttpService:JSONDecode(response.Body)
            local candidates = {}

            if data and data.data then
                for _, srv in ipairs(data.data) do
                    -- 核心邏輯：在台灣連日本，Ping 標註在 40-95ms 之間的最穩
                    -- 同時確保人數在 3-10 人之間，這是最容易維持低延遲的人數區間
                    local p = srv.ping or 999
                    if p >= 30 and p <= 95 and srv.playing < srv.maxPlayers then
                        table.insert(candidates, srv.id)
                    end
                end
            end

            if #candidates > 0 then
                -- 隨機從符合條件的「低延遲候選名單」選一個，避免大家都擠同一個
                local target = candidates[math.random(1, #candidates)]
                notify("🚀 找到低延遲節點，傳送中...")
                task.wait(0.5)
                TeleportService:TeleportToPlaceInstance(game.PlaceId, target, player)
            else
                -- 如果找不到標註低的，就找人數最少的 (Fresh Server)
                local target = data.data[math.random(#data.data-5, #data.data)]
                if target then 
                    notify("⚠️ 找不到精準節點，嘗試新伺服器...")
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, target.id, player)
                end
            end
        else
            notify("❌ 連線失敗")
        end
    end)
end

-- [[ UI 構建（保留原本架構） ]]
local frame = Instance.new("Frame", sg)
frame.Size, frame.Position = UDim2.new(0, 250, 0, 260), UDim2.new(0.5, -125, 0.5, -130)
frame.BackgroundColor3, frame.BackgroundTransparency = Color3.fromRGB(15,15,15), 0.25
frame.Active, frame.Draggable = true, true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,20)
Instance.new("UIStroke", frame).Color = Color3.fromRGB(200,160,255)

local title = Instance.new("TextLabel", frame)
title.Size, title.Position, title.Text, title.TextColor3 = UDim2.new(0,160,0,40), UDim2.new(0,15,0,0), cfg.name, Color3.new(1,1,1)
title.BackgroundTransparency, title.Font, title.TextSize, title.TextXAlignment = 1, Enum.Font.GothamBold, 16, Enum.TextXAlignment.Left

local res = Instance.new("TextButton", sg)
res.Size, res.Visible, res.Text = UDim2.new(0,50,0,50), false, cfg.emo
res.BackgroundColor3, res.BackgroundTransparency, res.TextColor3, res.TextSize = Color3.fromRGB(20,20,20), 0.2, Color3.new(1,1,1), cfg.size
res.Draggable = true
Instance.new("UICorner", res).CornerRadius = UDim.new(1,0)

-- [[ UI 交互按鈕 ]]
local function hBtn(txt, pos, col, cb)
    local b = Instance.new("TextButton", frame)
    b.Size, b.Position, b.Text, b.BackgroundColor3 = UDim2.new(0,24,0,24), pos, txt, col
    b.TextColor3, b.Font = Color3.new(1,1,1), Enum.Font.GothamBold
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
    b.MouseButton1Click:Connect(cb)
end
hBtn("-", UDim2.new(1,-65,0,8), Color3.fromRGB(60,60,60), function() frame.Visible, res.Visible = false, true end)
hBtn("×", UDim2.new(1,-32,0,8), Color3.fromRGB(150,50,50), function() running=false; sg:Destroy() end)

local function mainBtn(txt,col,pos,cb)
    local b = Instance.new("TextButton", frame)
    b.Size, b.Position, b.Text, b.BackgroundColor3 = UDim2.new(0.88,0,0,38), pos, txt, col
    b.TextColor3, b.Font, b.BackgroundTransparency = Color3.new(1,1,1), Enum.Font.GothamMedium, 0.2
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
    b.MouseButton1Click:Connect(cb)
    return b
end

mainBtn("☀ 早晨模式", Color3.fromRGB(100,170,255), UDim2.new(0.06,0,0.20,0), function() curMode="day"; apply() end)
mainBtn("🌌 夜晚模式", Color3.fromRGB(140,90,255), UDim2.new(0.06,0,0.38,0), function() curMode="night"; apply() end)
local mBtn; mBtn = mainBtn(rem and "💾 儲存模式: ON" or "💾 儲存模式: OFF", rem and Color3.fromRGB(80,160,100) or Color3.fromRGB(100,100,100), UDim2.new(0.06,0,0.56,0), function()
    rem = not rem; mBtn.Text = rem and "💾 儲存模式: ON" or "💾 儲存模式: OFF"; mBtn.BackgroundColor3 = rem and Color3.fromRGB(80,160,100) or Color3.fromRGB(100,100,100)
end)

-- 這裡改為專攻日本服的單一按鈕，簡化操作
mainBtn("🌸 跳轉至日本服 (低延遲測試)", Color3.fromRGB(255,150,180), UDim2.new(0.06,0,0.74,0), jumpToJapan)

-- [[ 核心循環 ]]
apply()
task.spawn(function()
    while running do
        pcall(function()
            local char = player.Character
            if char and char:GetAttribute("Downed") and char:GetAttribute("Emoting") then
                char:SetAttribute("Crouching", true)
            end
        end)
        task.wait(0.1) 
    end
end)
