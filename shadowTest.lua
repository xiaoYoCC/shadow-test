local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

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

-- 清理 UI
local pGui = player:WaitForChild("PlayerGui")
if pGui:FindFirstChild("xiaoYo_ShaderUI") then
    pGui.xiaoYo_ShaderUI:Destroy()
end

local running = true
local curMode = player:GetAttribute("ShaderMode") or "day"
local rem = player:GetAttribute("ShaderRemember") or false

local sg = Instance.new("ScreenGui", pGui)
sg.Name = "xiaoYo_ShaderUI"
sg.ResetOnSpawn = false
sg.DisplayOrder = 99999

-- 渲染組件
local function getEff(cl, nm)
    local e = Lighting:FindFirstChild(nm) or Instance.new(cl)
    e.Name = nm
    e.Parent = Lighting
    return e
end

local CC = getEff("ColorCorrectionEffect", "x_CC")
local Atm = getEff("Atmosphere", "x_Atm")
local Bloom = getEff("BloomEffect", "x_Bloom")
local DOF = getEff("DepthOfFieldEffect", "x_DOF")
local Sun = getEff("SunRaysEffect", "x_Sun")

--------------------------------------------------
-- ⭐ RTX / 星空系統
--------------------------------------------------

local sky = getEff("Sky", "x_Sky")
local starFolder = Instance.new("Folder", workspace)
starFolder.Name = "x_Stars"

local stars = {}
local galaxyRotation = 0
local nebulaHue = 0

-- 建立星星
for i = 1, 120 do
    local p = Instance.new("Part")
    p.Size = Vector3.new(0.2,0.2,0.2)
    p.Anchored = true
    p.CanCollide = false
    p.Material = Enum.Material.Neon
    p.Color = Color3.new(1,1,1)
    p.Transparency = math.random()*0.5
    p.Parent = starFolder
    
    table.insert(stars, p)
end

-- 流星
local function spawnMeteor()
    local m = Instance.new("Part")
    m.Size = Vector3.new(0.3,0.3,3)
    m.Anchored = true
    m.CanCollide = false
    m.Material = Enum.Material.Neon
    m.Color = Color3.fromRGB(255,255,255)
    
    local start = Vector3.new(math.random(-200,200), math.random(80,120), math.random(-200,200))
    local finish = start + Vector3.new(math.random(-60,60), -120, math.random(-60,60))
    
    m.CFrame = CFrame.new(start)
    m.Parent = workspace
    
    local t = TweenService:Create(m, TweenInfo.new(1.2), {
        Position = finish,
        Transparency = 1
    })
    t:Play()
    
    Debris:AddItem(m, 1.3)
end

--------------------------------------------------
-- 🌌 套用天空
--------------------------------------------------

local function applySky(isNight)
    if isNight then
        for k,v in pairs(cfg.milkyWay) do
            sky[k] = v
        end
    else
        for k,_ in pairs(cfg.milkyWay) do
            sky[k] = ""
        end
    end
end

--------------------------------------------------
-- 🎨 主渲染
--------------------------------------------------

local function apply()
    if not running then return end
    
    local isDay = (curMode == "day")
    applySky(not isDay)

    if isDay then
        Lighting.ClockTime = 14
        Lighting.Brightness = 3
        Lighting.ExposureCompensation = 0
        CC.Contrast = 0.15
        CC.Saturation = 0.15
        CC.TintColor = Color3.fromRGB(255,252,240)
        Atm.Density = 0.25
        
        DOF.Enabled = false
        Sun.Intensity = 0.2
    else
        Lighting.ClockTime = 0
        Lighting.Brightness = 2.5
        Lighting.ExposureCompensation = 0.4
        
        CC.Contrast = 0.3
        CC.Saturation = 0.4
        CC.TintColor = Color3.fromRGB(180,200,255)
        
        Atm.Density = 0.05
        
        DOF.Enabled = true
        DOF.FarIntensity = 0.4
        
        Sun.Intensity = 0
        
        Bloom.Intensity = 1.2
    end
end

--------------------------------------------------
-- ✨ 動態更新
--------------------------------------------------

RunService.RenderStepped:Connect(function(dt)
    if not running or curMode ~= "night" then return end
    
    galaxyRotation += dt * 2
    nebulaHue += dt * 0.05
    
    local hueColor = Color3.fromHSV(nebulaHue%1, 0.4, 1)
    
    for i, star in ipairs(stars) do
        local angle = i * 0.3 + galaxyRotation
        local radius = 100 + (i%20)*5
        
        star.Position = Vector3.new(
            math.cos(angle)*radius,
            80 + math.sin(angle*2)*10,
            math.sin(angle)*radius
        )
        
        -- 閃爍
        star.Transparency = 0.2 + math.sin(tick()*3 + i)*0.2
        star.Color = hueColor
    end
    
    -- 隨機流星
    if math.random() < 0.01 then
        spawnMeteor()
    end
end)

--------------------------------------------------
-- 🚀 UI（完全保留你原本）
--------------------------------------------------

-- 這裡 UI 我不動你原本的（你上面那段全部 그대로用）
-- 👉 你直接把你 UI 那段貼回來（因為你這段是完整正確的）

--------------------------------------------------
-- 🔁 主循環
--------------------------------------------------

apply()

task.spawn(function()
    while running do
        apply()
        
        pcall(function()
            local char = player.Character
            if char and char:GetAttribute("Downed") and char:GetAttribute("Emoting") then
                char:SetAttribute("Crouching", true)
            end
        end)
        
        task.wait(1)
    end
end)

--------------------------------------------------
-- ⌨ 快捷鍵
--------------------------------------------------

UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.K then
        curMode = (curMode == "day") and "night" or "day"
        apply()
    end
end)