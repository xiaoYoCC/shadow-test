local lighting = game:GetService("Lighting")
lighting.Brightness = 2
lighting.GlobalShadows = true
local bloom = Instance.new("BloomEffect", lighting)
bloom.Intensity = 1
local sunRays = Instance.new("SunRaysEffect", lighting)
sunRays.Intensity = 0.1
print("光影腳本載入成功！")
