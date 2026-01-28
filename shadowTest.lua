--==================================================
-- xiaoYo Evade 永久極致渲染 - 最終守護版
--==================================================
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

-- 確保不重複執行
if CoreGui:FindFirstChild("xiaoYo_ShaderUI") then
    CoreGui.xiaoYo_ShaderUI:Destroy()
end

--==================================================
-- GUI 構建 (手機適配 + 液態玻璃)
--==================================================
local sg = Instance.new("ScreenGui", CoreGui)
sg.Name = "xiaoYo_ShaderUI"

local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 230, 0, 185)
frame.Position = UDim2.new(1, -250, 0.5, -92) -- 靠右居中，手機操作最順手
frame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
frame.BackgroundTransparency = 0.35
frame.Active, frame.Draggable = true, true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 22)

-- 發光外框
local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Thickness = 1.2
stroke.Transparency = 0.6

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "✨ xiaoYo 永久渲染"
title.Font = Enum.Font.GothamBold
title.TextSize = 17
title.TextColor3 = Color3.new(1, 1, 1)

local function makeBtn(txt, color, pos)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(0.86, 0, 0, 36)
    b.Position = pos
    b.Text = txt
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 15
    b.TextColor3 = Color3.new(1, 1, 1)
    b.BackgroundColor3 = color
    b.BackgroundTransparency = 0.25
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
    return b
end

local dayBtn = makeBtn("☀ 白晝模式", Color3.fromRGB(120, 190, 255), UDim2.new(0.07, 0, 0.28, 0))
local nightBtn = makeBtn("🌌 黑夜模式", Color3.fromRGB(160, 110, 255), UDim2.new(0.07, 0, 0.48, 0))
local memoryBtn = makeBtn("💾 記憶模式: OFF", Color3.fromRGB(120, 120, 120), UDim2.new(0.07, 0, 0.70, 0))

--==================================================
-- 效果物件獲取與初始化
--==================================================
local function effect(c, n)
    local e = Lighting:FindFirstChild(n) or Instance.new(c)
    e.Name, e.Parent = n, Lighting
    return e
end

local CC = effect("ColorCorrectionEffect", "x_CC")
local Bloom = effect("BloomEffect", "x_Bloom")
local Rays = effect("SunRaysEffect", "x_Rays")
local Atm = effect("Atmosphere", "x_Atm")
local Sky = effect("Sky", "x_Sky")

--==================================================
-- 核心狀態與套用邏輯
--==================================================
local currentMode = player:GetAttribute("ShaderMode")
local remember = player:GetAttribute("ShaderRemember") or false

local function updateUI()
    memoryBtn.Text = remember and "💾 記憶模式: ON" or "💾 記憶模式: OFF"
    memoryBtn.BackgroundColor3 = remember and Color3.fromRGB(90, 180, 120) or Color3.fromRGB(120, 120, 120)
end

local function apply()
    if not currentMode then return end

    Lighting.Technology = Enum.Technology.Future
    Lighting.GlobalShadows = true

    if currentMode == "day" then
        -- 補正時間與亮度
        if math.abs(Lighting.ClockTime - 14) > 0.05 then Lighting.ClockTime = 14 end
        Lighting.Brightness = 2.4
        Lighting.OutdoorAmbient = Color3.fromRGB(140, 140, 140)
        
        CC.Contrast, CC.Saturation = 0.1, 0.16
        CC.TintColor = Color3.fromRGB(255, 245, 235)
        Bloom.Intensity, Bloom.Size = 0.25, 12
        Rays.Intensity = 0.12
        Atm.Color = Color3.fromRGB(210, 210, 210)
        Sky.Enabled = false -- 白天關閉銀河
    else
        -- 補正黑夜時間與亮度
        if math.abs(Lighting.ClockTime - 23.5) > 0.05 then Lighting.ClockTime = 23.5 end
        Lighting.Brightness = 1.6
        Lighting.OutdoorAmbient = Color3.fromRGB(35, 28, 65)

        CC.Contrast, CC.Saturation = 0.26, 0.38
        CC.TintColor = Color3.fromRGB(220, 210, 255)
        Bloom.Intensity, Bloom.Size = 0.6, 24
        Rays.Intensity = 0.05
        Atm.Color = Color3.fromRGB(100, 80, 150)

        -- 紫色銀河天空盒
        Sky.Enabled = true
        Sky.Parent = Lighting
        Sky.StarIntensity = 6
        local gid = "rbxassetid://600830446"
        Sky.SkyboxBk, Sky.SkyboxDn, Sky.SkyboxFt, Sky.SkyboxLf, Sky.SkyboxRt, Sky.SkyboxUp = gid, gid, gid, gid, gid, gid
    end
end

--==================================================
-- 強力守護守衛 (每秒鎖定)
--==================================================
task.spawn(function()
    while true do
        if currentMode then
            apply()
            -- 確保物件不被地圖腳本強制移除
            for _, obj in pairs({CC, Bloom, Rays, Atm}) do
                if obj.Parent ~= Lighting then obj.Parent = Lighting end
            end
        end
        task.wait(1.2) -- 兼顧性能與防重設
    end
end)

-- 角色重生補正
player.CharacterAdded:Connect(function()
    if remember and currentMode then
        task.wait(1)
        apply()
    end
end)

--==================================================
-- UI 點擊事件
--==================================================
dayBtn.MouseButton1Click:Connect(function()
    currentMode = "day"
    player:SetAttribute("ShaderMode", "day")
    apply()
    sg:Destroy() -- 選單消失，守護繼續
end)

nightBtn.MouseButton1Click:Connect(function()
    currentMode = "night"
    player:SetAttribute("ShaderMode", "night")
    apply()
    sg:Destroy()
end)

memoryBtn.MouseButton1Click:Connect(function()
    remember = not remember
    player:SetAttribute("ShaderRemember", remember)
    updateUI()
end)

-- 初始加載
updateUI()
if remember and currentMode then
    task.wait(0.5)
    apply()
end
