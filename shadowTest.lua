local l = game:GetService("Lighting")
local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))

local f = Instance.new("Frame", sg)
local mBtn = Instance.new("TextButton", f)
local nBtn = Instance.new("TextButton", f)

-- 1. 液態玻璃 UI 設置
f.Size = UDim2.new(0, 220, 0, 140)
f.Position = UDim2.new(1, -240, 1, -160)
f.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
f.BackgroundTransparency = 0.5 -- 調整為磨砂深色質感
f.BorderSizePixel = 0
Instance.new("UICorner", f).CornerRadius = UDim.new(0, 20)
local stroke = Instance.new("UIStroke", f)
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Thickness = 1.5
stroke.Transparency = 0.6

local title = Instance.new("TextLabel", f)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "🌿 MC 風格渲染"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 17
title.Font = Enum.Font.GothamBold

local function styleBtn(btn, text, color, pos)
    btn.Size = UDim2.new(0.85, 0, 0, 35)
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.BackgroundTransparency = 0.3
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamMedium
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
end

styleBtn(mBtn, "☀ 柔和白晝", Color3.fromRGB(100, 180, 255), UDim2.new(0.075, 0, 0.35, 0))
styleBtn(nBtn, "🌌 夢幻星雲", Color3.fromRGB(160, 100, 255), UDim2.new(0.075, 0, 0.65, 0))

-- 2. Minecraft 風格平衡參數
local function applyMCShader(mode)
    sg:Destroy() -- 點擊後立即消失

    l:ClearAllChildren()
    
    -- 核心：開啟未來渲染技術感
    l.GlobalShadows = true
    l.EnvironmentDiffuseScale = 0.5 -- 降低環境光散射，避免過亮
    l.EnvironmentSpecularScale = 0.5
    l.ShadowSoftness = 0.2 -- 陰影帶有一點點柔和感

    local cc = Instance.new("ColorCorrectionEffect", l)
    local bloom = Instance.new("BloomEffect", l)
    local rays = Instance.new("SunRaysEffect", l)
    local atm = Instance.new("Atmosphere", l) -- 增加大氣感（模擬 MC 的體積光）

    -- 大氣平衡設定
    atm.Density = 0.35
    atm.Offset = 0.2
    atm.Color = Color3.fromRGB(190, 190, 190)
    atm.Glare = 0.5
    atm.Haze = 0.5

    if mode == "morning" then
        l.ClockTime = 14
        l.Brightness = 2.5
        cc.Contrast = 0.1
        cc.Saturation = 0.15
        cc.TintColor = Color3.fromRGB(255, 252, 240) -- 溫暖的陽光感
        
        rays.Intensity = 0.15
        bloom.Intensity = 0.4
        bloom.Size = 12
    else
        -- 🌙 夢幻紫色銀河 (平衡版)
        l.ClockTime = 0
        l.Brightness = 1.8
        l.OutdoorAmbient = Color3.fromRGB(40, 30, 70)
        
        local sky = Instance.new("Sky", l)
        local gid = "rbxassetid://600830446"
        sky.SkyboxBk = gid sky.SkyboxDn = gid sky.SkyboxFt = gid
        sky.SkyboxLf = gid sky.SkyboxRt = gid sky.SkyboxUp = gid
        sky.StarIntensity = 6 
        
        cc.TintColor = Color3.fromRGB(220, 210, 255)
        cc.Contrast = 0.25
        cc.Saturation = 0.4
        
        bloom.Intensity = 0.8
        bloom.Size = 24
        atm.Color = Color3.fromRGB(100, 80, 150) -- 紫色的大氣霧氣
    end

    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🎨 渲染完成",
        Text = "已平衡光影與性能",
        Duration = 3
    })
end

mBtn.MouseButton1Click:Connect(function() applyMCShader("morning") end)
nBtn.MouseButton1Click:Connect(function() applyMCShader("night") end)
