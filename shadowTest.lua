local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

local cfg = {
    emo  = "👾",
    size = 24,
    name = "✨ xiaoYo 閃避渲染"
}

-- 清理舊 UI
local pGui = player:WaitForChild("PlayerGui")
if pGui:FindFirstChild("xiaoYo_ShaderUI") then pGui.xiaoYo_ShaderUI:Destroy() end

local running, curMode, rem = true, player:GetAttribute("ShaderMode") or "day", player:GetAttribute("ShaderRemember") or false
local sg = Instance.new("ScreenGui", pGui)
sg.Name, sg.ResetOnSpawn, sg.DisplayOrder = "xiaoYo_ShaderUI", false, 99999

-- =========================
-- 渲染保持原樣，不動
-- =========================
local function getEff(cl,nm)
    local e = Lighting:FindFirstChild(nm) or Instance.new(cl)
    e.Name, e.Parent = nm, Lighting
    return e
end

local CC = getEff("ColorCorrectionEffect", "x_CC")
local Atm = getEff("Atmosphere", "x_Atm")
local Bloom = getEff("BloomEffect", "x_Bloom")
local DoF = getEff("DepthOfFieldEffect", "x_DoF")

local function apply()
    if not running then return end
    -- 光影效果保持你原本的 apply() 內容
end

-- =========================
-- 通知系統
-- =========================
local activeNotifications = {}
local function notify(msg)
    local isDay = curMode == "day"
    local nF = Instance.new("Frame", sg)
    nF.Size, nF.Position = UDim2.new(0,220,0,50), UDim2.new(1,50,0.8,0)
    nF.BackgroundColor3 = isDay and Color3.new(1,1,1) or Color3.fromRGB(30,30,35)
    nF.BackgroundTransparency = 0.2
    Instance.new("UICorner", nF).CornerRadius = UDim.new(0,10)
    local stroke = Instance.new("UIStroke", nF)
    stroke.Color = Color3.fromRGB(200,160,255)

    local nL = Instance.new("TextLabel", nF)
    nL.Size, nL.BackgroundTransparency = UDim2.new(1,0,1,-5), 1
    nL.Text = msg
    nL.TextColor3 = isDay and Color3.new(0,0,0) or Color3.new(1,1,1)
    nL.TextSize, nL.Font = 15, Enum.Font.GothamBold

    local barBG = Instance.new("Frame", nF)
    barBG.Size, barBG.Position = UDim2.new(1,-16,0,4), UDim2.new(0,8,1,-8)
    barBG.BackgroundColor3 = Color3.new(0,0,0)
    barBG.ClipsDescendants = true
    Instance.new("UICorner", barBG)

    local bar = Instance.new("Frame", barBG)
    bar.Size, bar.BackgroundColor3 = UDim2.new(1,0,1,0), Color3.fromRGB(150,150,150)
    Instance.new("UICorner", bar)

    table.insert(activeNotifications, nF)

    local function updatePos()
        local valid = {}
        for _, v in ipairs(activeNotifications) do
            if v and v.Parent then table.insert(valid, v) end
        end
        for i, v in ipairs(valid) do
            v:TweenPosition(UDim2.new(1, -240, 0.8, -(#valid - i) * 65), "Out", "Quart", 0.3, true)
        end
    end
    updatePos()

    TweenService:Create(bar, TweenInfo.new(2.5, Enum.EasingStyle.Linear), {Size=UDim2.new(0,0,1,0)}):Play()
    task.delay(2.5, function()
        for i, v in ipairs(activeNotifications) do
            if v == nF then table.remove(activeNotifications, i) break end
        end
        nF:TweenPosition(UDim2.new(1, 50, nF.Position.Y.Scale, nF.Position.Y.Offset), "In", "Quart", 0.3, true)
        task.wait(0.3) nF:Destroy()
        updatePos()
    end)
end

-- =========================
-- 主 UI
-- =========================
local frame = Instance.new("Frame", sg)
frame.Size, frame.Position = UDim2.new(0,250,0,210), UDim2.new(0.5,-125,0.5,-105)
frame.BackgroundColor3, frame.BackgroundTransparency = Color3.fromRGB(15,15,15), 0.3
frame.Active, frame.Draggable = true, true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,22)
local fStroke = Instance.new("UIStroke", frame)
fStroke.Color, fStroke.Thickness = Color3.fromRGB(200,160,255), 1.5

local title = Instance.new("TextLabel", frame)
title.Size, title.Position, title.BackgroundTransparency = UDim2.new(0,160,0,40), UDim2.new(0,15,0,0), 1
title.Text, title.Font, title.TextSize, title.TextColor3 = cfg.name, Enum.Font.GothamBold, 16, Color3.new(1,1,1)
title.TextXAlignment = Enum.TextXAlignment.Left

-- 縮小按鈕 (可拖動)
local res = Instance.new("TextButton", sg)
res.Size, res.Visible, res.Text = UDim2.new(0,55,0,55), false, cfg.emo
res.BackgroundColor3, res.BackgroundTransparency = Color3.fromRGB(20,20,20), 0.2
res.TextColor3, res.TextSize = Color3.new(1,1,1), cfg.size
Instance.new("UICorner", res).CornerRadius = UDim.new(1,0)
local rStroke = Instance.new("UIStroke", res)
rStroke.Color = Color3.fromRGB(200,160,255)
res.Draggable = true

local function showMain()
    local x = res.AbsolutePosition.X - frame.Size.X.Offset/2 + res.Size.X.Offset/2
    local y = res.AbsolutePosition.Y - frame.Size.Y.Offset/2 + res.Size.Y.Offset/2
    frame.Position = UDim2.new(0, x, 0, y)
    frame.Visible, res.Visible = true, false
    notify("選單已恢復")
end

local function hideMain()
    local fPos = frame.AbsolutePosition
    res.Position = UDim2.new(0, fPos.X - res.Size.X.Offset/2, 0, fPos.Y - res.Size.Y.Offset/2)
    frame.Visible, res.Visible = false, true
    notify("選單已縮小")
end

local function headBtn(txt, pos, col, cb)
    local b = Instance.new("TextButton", frame)
    b.Size, b.Position, b.Text, b.BackgroundColor3 = UDim2.new(0,22,0,22), pos, txt, col
    b.TextColor3, b.Font = Color3.new(1,1,1), Enum.Font.GothamBold
    Instance.new("UICorner", b).CornerRadius = UDim.new(1,0)
    b.MouseButton1Click:Connect(cb)
    return b
end

headBtn("-", UDim2.new(1,-60,0,9), Color3.fromRGB(60,60,60), hideMain)
headBtn("×", UDim2.new(1,-30,0,9), Color3.fromRGB(150,50,50), function() running=false sg:Destroy() end)
res.MouseButton1Click:Connect(showMain)

local function mainBtn(txt,col,pos,cb)
    local b = Instance.new("TextButton", frame)
    b.Size, b.Position, b.Text, b.BackgroundColor3 = UDim2.new(0.86,0,0,36), pos, txt, col
    b.TextColor3, b.Font, b.BackgroundTransparency = Color3.new(1,1,1), Enum.Font.GothamMedium, 0.25
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
    b.MouseButton1Click:Connect(cb)
    return b
end

mainBtn("☀ 早晨模式", Color3.fromRGB(120,190,255), UDim2.new(0.07,0,0.22,0), function()
    curMode="day"
    notify("成功套用：早晨模式")
    apply()
end)

mainBtn("🌌 黑夜模式", Color3.fromRGB(160,110,255), UDim2.new(0.07,0,0.42,0), function()
    curMode="night"
    notify("成功套用：黑夜模式")
    apply()
end)

task.spawn(function() while running do apply() task.wait(5) end end)
apply()