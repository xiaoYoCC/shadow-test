local l = game:GetService("Lighting")
local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
local f = Instance.new("Frame", sg)
local mBtn = Instance.new("TextButton", f)
local nBtn = Instance.new("TextButton", f)

-- 1. 液態玻璃 UI 設置
f.Size = UDim2.new(0, 220, 0, 140)
f.Position = UDim2.new(1, -240, 1, -160)
f.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
f.BackgroundTransparency = 0.8 -- 半透明液態感
f.BorderSizePixel = 0

local corner = Instance.new("UICorner", f)
corner.CornerRadius = UDim.new(0, 15)

-- 玻璃外框高光
local stroke = Instance.new("UIStroke", f)
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Thickness = 2
stroke.Transparency = 0.5

local title = Instance.new("TextLabel", f)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "✨ 唯美光影模式"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.Font = Enum.Font.GothamBold

-- 按鈕樣式函式
local function styleBtn(btn, text, color, pos)
    btn.Size = UDim2.new(0.8, 0, 0, 35)
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.BackgroundTransparency = 0.3
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamMedium
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
end

styleBtn(mBtn, "🌅 琥珀清晨", Color3.fromRGB(255, 150, 50), UDim2.new(0.1, 0, 0.35, 0))
styleBtn(nBtn, "🌌 奇幻星空", Color3.fromRGB(120, 80, 220), UDim2.new(0.1, 0, 0.65, 0))

-- 2. 核心功能：紫色星空與光影
local function apply(mode)
    l:ClearAllChildren()
    local cc = Instance.new("ColorCorrectionEffect", l)
    local bloom = Instance.new("BloomEffect", l)
    
    if mode == "morning" then
        l.ClockTime = 14.5
        l.Brightness = 3
        cc.Saturation = 0.2
        cc.TintColor = Color3.fromRGB(255, 245, 230)
    else
        -- 紫色星空設定
        l.ClockTime = 0
        l.Brightness = 2
        l.OutdoorAmbient = Color3.fromRGB(60, 40, 100) -- 紫色環境光
        
        -- 強化星星
        local sky = l:FindFirstChildOfClass("Sky") or Instance.new("Sky", l)
        sky.StarIntensity = 5 -- 星星亮度加倍
        sky.SunAngularSize = 0
        
        cc.TintColor = Color3.fromRGB(200, 180, 255) -- 畫面偏紫
        cc.Contrast = 0.3
        cc.Saturation = 0.5
        
        bloom.Intensity = 1.2
        bloom.Size = 24
    end
    
    game.StarterGui:SetCore("SendNotification", {
        Title = "加載成功",
        Text = "已進入" .. (mode == "morning" and "清晨" or "紫色星空"),
        Duration = 3
    })
    sg:Destroy()
end

mBtn.MouseButton1Click:Connect(function() apply("morning") end)
nBtn.MouseButton1Click:Connect(function() apply("night") end)
