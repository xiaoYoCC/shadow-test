local lighting = game:GetService("Lighting")

local function applyEnhancedLighting()
    -- 核心設定：調整時間與基礎光影
    lighting.Brightness = 2.5 -- 增加整體亮度
    lighting.GlobalShadows = true -- 開啟全球陰影
    lighting.ClockTime = 14.5 -- 設定下午時段，光線角度佳
    lighting.OutdoorAmbient = Color3.fromRGB(150, 150, 160) -- 戶外環境光，略帶藍調
    lighting.Ambient = Color3.fromRGB(100, 100, 105) -- 室內環境光

    -- Bloom Effect (光暈效果：讓光源和高亮區域更具發光感)
    local bloom = Instance.new("BloomEffect")
    bloom.Parent = lighting
    bloom.Intensity = 0.8 -- 光暈強度
    bloom.Size = 28 -- 光暈範圍
    bloom.Threshold = 1.5 -- 觸發光暈的亮度閾值

    -- ColorCorrection Effect (色彩校正：調整整體色彩風格)
    local colorCorrection = Instance.new("ColorCorrectionEffect")
    colorCorrection.Parent = lighting
    colorCorrection.Brightness = 0.05 -- 微調整體亮度
    colorCorrection.Contrast = 0.18 -- 增加對比度，讓畫面更立體
    colorCorrection.Saturation = 0.2 -- 增加飽和度，顏色更鮮豔
    colorCorrection.Tint = Color3.fromRGB(255, 255, 240) -- 輕微暖色調濾鏡

    -- SunRays Effect (太陽光束效果：模擬陽光穿透雲層或物體的散射光)
    local sunRays = Instance.new("SunRaysEffect")
    sunRays.Parent = lighting
    sunRays.Intensity = 0.15 -- 太陽光束強度
    sunRays.Spread = 0.8 -- 光束擴散程度

    -- DepthOfField Effect (景深效果：模擬相機焦點，讓遠處模糊，近處清晰)
    -- 注意：景深效果在某些低端設備上可能會導致性能下降
    local dof = Instance.new("DepthOfFieldEffect")
    dof.Parent = lighting
    dof.FarBlur = 0.1 -- 遠景模糊程度
    dof.FocusDistance = 30 -- 焦點距離，根據場景調整
    dof.InFocusRadius = 10 -- 焦點清晰半徑

    -- 在遊戲右下角顯示通知
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "光影加載成功！",
        Text = "美化版光影效果已啟用",
        Duration = 5,
        Button1 = "OK"
    })

    print("--- 增強版光影腳本已成功載入並應用 ---")
end

-- 使用 pcall 確保即使有部分錯誤也不會導致整個腳本崩潰
pcall(applyEnhancedLighting)
