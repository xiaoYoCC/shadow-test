-- 徹底簡化版，只測試通知功能
local StarterGui = game:GetService("StarterGui")

local function test()
    StarterGui:SetCore("SendNotification", {
        Title = "連線成功！",
        Text = "你能看到這行字，代表 GitHub 網址沒問題",
        Duration = 10
    })
    print("腳本已成功執行")
end

-- 執行測試
pcall(test)
