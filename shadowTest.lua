local lighting = game:GetService("Lighting")

-- 1. 預先顯示加載通知
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "極致光影啟動中",
    Text = "正在套用最高渲染參數...",
    Duration = 5
})

local function applyUltraRTX()
    -- 清除舊效果
    lighting:ClearAllChildren()

    -- 基礎環境：強制開啟最強渲染模式
    lighting.Brightness = 3
    lighting.GlobalShadows = true
    lighting.ClockTime = 14.5
    lighting.EnvironmentDiffuseScale = 1 -- 增強環境擴散
    lighting.EnvironmentSpecularScale = 1 -- 增強物體反光
    lighting.OutdoorAmbient = Color3.fromRGB(130, 130, 140)
    
    -- Bloom：真實光暈（讓光源更有穿透感）
    local bloom = Instance.new("BloomEffect", lighting)
    bloom.Intensity = 0.5
    bloom.Size = 25
    bloom.Threshold = 1.8

    -- ColorCorrection：電影質感校正
    local cc = Instance.new("ColorCorrectionEffect", lighting)
    cc.Brightness = 0.05
    cc.Contrast = 0.2
    cc.Saturation = 0.3 -- 色彩更濃郁
    cc.TintColor = Color3.fromRGB(255, 253, 245) -- 極輕微的黃金暖色調

    -- SunRays：極致光線追蹤感
    local sun = Instance.new("SunRaysEffect", lighting)
    sun.Intensity = 0.25
    sun.Spread = 1

    -- DepthOfField：景深效果（背景虛化，讓畫面看起來更像大片）
    local dof = Instance.new("DepthOfFieldEffect", lighting)
    dof.FarBlur = 0.75
    dof.FocusDistance = 50
    dof.InFocusRadius = 25

    -- Blur：微量環境模糊（增加柔和度）
    local blur = Instance.new("BlurEffect", lighting)
    blur.Size = 2
end

local success, err = pcall(applyUltraRTX)

if success then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "極致光影加載成功！",
        Text = "當前已處於最高畫質模式",
        Duration = 5
    })
else
    warn("極致光影執行失敗: " .. err)
end
