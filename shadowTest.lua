local l = game:GetService("Lighting")
local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))

local f = Instance.new("Frame", sg)
local mBtn = Instance.new("TextButton", f)
local nBtn = Instance.new("TextButton", f)

-- 1. 液態玻璃 UI 設置 (極致質感)
f.Size = UDim2.new(0, 220, 0, 140)
f.Position = UDim2.new(1, -240, 1, -160)
f.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
f.BackgroundTransparency = 0.8 
f.BorderSizePixel = 0
Instance.new("UICorner", f).CornerRadius = UDim.new(0, 20)
local stroke = Instance.new("UIStroke", f)
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Thickness = 2.5
stroke.Transparency = 0.4

local title = Instance.new("TextLabel", f)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "💎 極致渲染選擇"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.Font = Enum.Font.GothamBold

local function styleBtn(btn, text, color, pos)
    btn.Size = UDim2.new(0.85, 0, 0, 35)
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.BackgroundTransparency = 0.2
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamMedium
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
end

styleBtn(mBtn, "☀ 極致清晨", Color3.fromRGB(255, 140, 0), UDim2.new(0.075, 0, 0.35, 0))
styleBtn(nBtn, "🌌 幻紫銀河", Color3.fromRGB(130, 0, 255), UDim2.new(0.075, 0, 0.65, 0))

-- 2. 極致光影參數函式
local function applyUltraRTX(mode)
    sg:Destroy() -- 按下瞬間立即銷毀選單

    l:ClearAllChildren()
    
    -- 頂級全局參數
    l.GlobalShadows = true
    l.EnvironmentDiffuseScale = 1
    l.EnvironmentSpecularScale = 1
    l.ShadowSoftness = 0 -- 讓陰影邊緣最清晰
    l.GeographicLatitude = 45

    local cc = Instance.new("ColorCorrectionEffect", l)
    local bloom = Instance.new("BloomEffect", l)
    local rays = Instance.new("SunRaysEffect", l)
    local blur = Instance.new("BlurEffect", l)
    local dof = Instance.new("DepthOfFieldEffect", l)

    if mode == "morning" then
        l.ClockTime = 14.5
        l.Brightness = 4 -- 超高亮度
        cc.Contrast = 0.25
        cc.Saturation = 0.35
        rays.Intensity = 0.3
        bloom.Intensity = 0.8
    else
        -- 🌙 極致幻紫星空模式
        l.ClockTime = 0
        l.Brightness = 2.5
        l.OutdoorAmbient = Color3.fromRGB(60, 20, 120) -- 強烈紫色環境光
        
        -- 銀河天空盒
        local sky = Instance.new("Sky", l)
        local gid = "rbxassetid://600830446"
        sky.SkyboxBk = gid sky.SkyboxDn = gid sky.SkyboxFt = gid
        sky.SkyboxLf = gid sky.SkyboxRt = gid sky.SkyboxUp = gid
        sky.StarIntensity = 15 -- 星星閃爍感最大化
        
        cc.TintColor = Color3.fromRGB(190, 170, 255)
        cc.Contrast = 0.45
        cc.Saturation = 0.8 -- 色彩極度濃郁
        
        bloom.Intensity = 2 -- 光暈最強
        bloom.Size = 40
        rays.Intensity = 0.05 -- 微弱月光散射
    end

    -- 景深與模糊 (增加電影感)
    dof.FarBlur = 0.8
    dof.FocusDistance = 50
    dof.InFocusRadius = 30
    blur.Size = 1

    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🚀 極致光影已加載",
        Text = "當前參數已調至最高層級",
        Duration = 5
    })
end

mBtn.MouseButton1Click:Connect(function() applyUltraRTX("morning") end)
nBtn.MouseButton1Click:Connect(function() applyUltraRTX("night") end)
