local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

if CoreGui:FindFirstChild("xiaoYo_ShaderUI") then CoreGui.xiaoYo_ShaderUI:Destroy() end

local running, currentMode, remember = true, player:GetAttribute("ShaderMode"), player:GetAttribute("ShaderRemember") or false
local sg = Instance.new("ScreenGui", CoreGui)
sg.Name = "xiaoYo_ShaderUI"

local frame = Instance.new("Frame", sg)
frame.Size, frame.Position = UDim2.new(0, 250, 0, 230), UDim2.new(1, -270, 0.5, -115)
frame.BackgroundColor3, frame.BackgroundTransparency = Color3.fromRGB(22,22,22), 0.35
frame.Active, frame.Draggable = true, true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,22)
Instance.new("UIStroke", frame).Transparency = 0.6

local title = Instance.new("TextLabel", frame)
title.Size, title.Position, title.BackgroundTransparency = UDim2.new(0,160,0,40), UDim2.new(0,15,0,0), 1
title.Text, title.Font, title.TextSize, title.TextColor3 = "✨ xiaoYo 閃避渲染", 10, 16, Color3.new(1,1,1)
title.TextXAlignment = 0

local mini = Instance.new("TextButton", frame)
mini.Size, mini.Position, mini.Text = UDim2.new(0,22,0,22), UDim2.new(1,-60,0,9), "-"
mini.BackgroundColor3, mini.TextColor3 = Color3.fromRGB(60,60,60), Color3.new(1,1,1)
Instance.new("UICorner", mini).CornerRadius = UDim.new(1,0)

local close = Instance.new("TextButton", frame)
close.Size, close.Position, close.Text = UDim2.new(0,22,0,22), UDim2.new(1,-30,0,9), "×"
close.BackgroundColor3, close.TextColor3 = Color3.fromRGB(150,50,50), Color3.new(1,1,1)
Instance.new("UICorner", close).CornerRadius = UDim.new(1,0)

local restore = Instance.new("TextButton", sg)
restore.Size, restore.Position, restore.Text, restore.Visible = UDim2.new(0,50,0,50), UDim2.new(1,-60,0.5,-25), "👾", false
restore.Active, restore.Draggable, restore.BackgroundColor3, restore.BackgroundTransparency = true, true, Color3.fromRGB(30,30,30), 0.3
Instance.new("UICorner", restore).CornerRadius = UDim.new(1,0)
Instance.new("UIStroke", restore).Color = Color3.new(1,1,1)

mini.MouseButton1Click:Connect(function() frame.Visible, restore.Visible = false, true end)
restore.MouseButton1Click:Connect(function() frame.Visible, restore.Visible = true, false end)
close.MouseButton1Click:Connect(function() running = false sg:Destroy() end)

local function effect(c, n)
	local e = Lighting:FindFirstChild(n) or Instance.new(c)
	e.Name, e.Parent = n, Lighting
	return e
end

local CC, Bloom, Rays, Atm, Sky
local nS = {CT=23.5, B=1.6, C=0.26, S=0.38, T=Color3.fromRGB(215,205,255), BI=0.75, BS=26, RI=0.06, AD=0.4}
local dS = {CT=14, B=2.4, C=0.1, S=0.16, T=Color3.fromRGB(255,245,235), BI=0.35, BS=14, RI=0.18, AD=0.32}

local function apply()
	if not currentMode then return end
	CC, Bloom, Rays, Atm, Sky = effect("ColorCorrectionEffect","x_CC"), effect("BloomEffect","x_Bloom"), effect("SunRaysEffect","x_Rays"), effect("Atmosphere","x_Atm"), effect("Sky","x_Sky")
	local s = (currentMode=="day") and dS or nS
	if math.abs(Lighting.ClockTime - s.CT)>0.05 then Lighting.ClockTime = s.CT end
	Lighting.Brightness, Lighting.Technology = s.B, 3
	CC.Contrast, CC.Saturation, CC.TintColor = s.C, s.S, s.T
	Bloom.Intensity, Bloom.Size = s.BI, s.BS
	Rays.Intensity, Atm.Density, Sky.Enabled = s.RI, s.AD, (currentMode=="night")
	if currentMode=="night" then
		local g = "rbxassetid://600830446"
		Sky.SkyboxBk, Sky.SkyboxDn, Sky.SkyboxFt, Sky.SkyboxLf, Sky.SkyboxRt, Sky.SkyboxUp, Sky.StarIntensity = g,g,g,g,g,g,6
	end
end

local function makeBtn(txt, col, pos)
	local b = Instance.new("TextButton", frame)
	b.Size, b.Position, b.Text, b.BackgroundColor3 = UDim2.new(0.86,0,0,36), pos, txt, col
	b.Font, b.TextColor3, b.BackgroundTransparency = 5, Color3.new(1,1,1), 0.25
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
	return b
end

local dBtn = makeBtn("☀ 早晨模式", Color3.fromRGB(120,190,255), UDim2.new(0.07,0,0.28,0))
local nBtn = makeBtn("🌌 黑夜模式", Color3.fromRGB(160,110,255), UDim2.new(0.07,0,0.48,0))
local mBtn = makeBtn(remember and "💾 記憶模式: ON" or "💾 記憶模式: OFF", remember and Color3.fromRGB(90,180,120) or Color3.fromRGB(120,120,120), UDim2.new(0.07,0,0.70,0))

dBtn.MouseButton1Click:Connect(function() currentMode="day" player:SetAttribute("ShaderMode","day") apply() end)
nBtn.MouseButton1Click:Connect(function() currentMode="night" player:SetAttribute("ShaderMode","night") apply() end)
mBtn.MouseButton1Click:Connect(function()
	remember = not remember
	player:SetAttribute("ShaderRemember", remember)
	mBtn.Text = remember and "💾 記憶模式: ON" or "💾 記憶模式: OFF"
	mBtn.BackgroundColor3 = remember and Color3.fromRGB(90,180,120) or Color3.fromRGB(120,120,120)
end)

local function makeSlider(txt, pos, min, max, def, cb)
	local l = Instance.new("TextLabel", frame)
	l.Size, l.Position, l.Text, l.BackgroundTransparency = UDim2.new(0.4,0,0,20), pos, txt, 1
	l.Font, l.TextSize, l.TextColor3, l.TextXAlignment = 3, 14, Color3.new(1,1,1), 0
	local s = Instance.new("Frame", frame)
	s.Size, s.Position, s.BackgroundColor3 = UDim2.new(0.5,0,0,20), UDim2.new(pos.X.Scale+0.42,0,pos.Y.Scale,0), Color3.fromRGB(60,60,60)
	Instance.new("UICorner", s).CornerRadius = UDim.new(0,8)
	local k = Instance.new("Frame", s)
	k.Size, k.Position, k.BackgroundColor3 = UDim2.new(0,10,1,0), UDim2.new(def,0,0,0), Color3.fromRGB(180,180,255)
	Instance.new("UICorner", k).CornerRadius = UDim.new(1,0)
	local drag = false
	k.InputBegan:Connect(function(i) if i.UserInputType.Value == 0 then drag = true end end)
	k.InputEnded:Connect(function(i) if i.UserInputType.Value == 0 then drag = false end end)
	game:GetService("UserInputService").InputChanged:Connect(function(i)
		if drag and i.UserInputType.Value == 4 then
			local x = math.clamp(i.Position.X - s.AbsolutePosition.X, 0, s.AbsoluteSize.X)
			k.Position = UDim2.new(x/s.AbsoluteSize.X, 0, 0, 0)
			cb(min + (max-min)*(x/s.AbsoluteSize.X))
		end
	end)
end

makeSlider("Bloom", UDim2.new(0.07,0,0.85,0), 0, 2, 0.5, function(v) if Bloom then Bloom.Intensity=v end end)
makeSlider("Rays", UDim2.new(0.07,0,0.92,0), 0, 1, 0.1, function(v) if Rays then Rays.Intensity=v end end)

task.spawn(function() while running do if currentMode then apply() end task.wait(1.5) end end)
if remember and currentMode then task.wait(1) apply() end
