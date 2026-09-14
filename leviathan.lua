-- // ==========================================
-- // VX STEAL AN EGG | GODMODE & INSTANT HUB
-- // Created for VX Community
-- // ==========================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "VX HUB | STEAL AN EGG OVERLORD",
   LoadingTitle = "جاري تهيئة ميزات الحماية والتجميد...",
   LoadingSubtitle = "by Ali & VX Team",
   ConfigurationSaving = { Enabled = false }
})

-- // 1. المتغيرات العامة (State)
getgenv().EggGodMode = true
getgenv().AntiCage = true
getgenv().InstantE = true
getgenv().WalkSpeed = 16

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local LocalPlayer = Players.LocalPlayer

-- // 2. واجهة التحكم (Tabs)
local MainTab = Window:CreateTab("الحماية والسرعة", 4483362458)

MainTab:CreateToggle({
   Name = "حماية كاملة للبيض من الضرب والإسقاط (Egg Godmode)",
   CurrentValue = true,
   Callback = function(v) getgenv().EggGodMode = v end,
})

MainTab:CreateToggle({
   Name = "إلغاء تأثير القفص نهائياً (Anti Cage)",
   CurrentValue = true,
   Callback = function(v) getgenv().AntiCage = v end,
})

MainTab:CreateToggle({
   Name = "تحميل وتحديد البيض فوراً عند الضغط (Instant E Steal)",
   CurrentValue = true,
   Callback = function(v) getgenv().InstantE = v end,
})

MainTab:CreateSlider({
   Name = "تغيير السرعة (WalkSpeed)",
   Range = {0, 1000},
   Increment = 10,
   Suffix = "Speed",
   CurrentValue = 16,
   Callback = function(v) getgenv().WalkSpeed = v end,
})

-- // 3. المحركات البرمجية (Core Physics & Interceptions)

-- [محرك الحماية ومنع الإسقاط وتجاوز القفص]
RunService.Stepped:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        
        -- تعديل السرعة
        if char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = getgenv().WalkSpeed
        end
        
        -- منع التأثر بالقفص وإزالة الـ Anchored
        if getgenv().AntiCage and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.Anchored = false
            for _, v in pairs(char:GetChildren()) do
                if v.Name:find("Cage") or v.Name:find("Stun") or v.Name:find("Trap") then
                    v:Destroy()
                end
            end
        end
        
        -- حماية البيض واللاعب (Godmode & Anti-Drop)
        if getgenv().EggGodMode then
            for _, v in pairs(char:GetChildren()) do
                if v:IsA("Tool") or v.Name:find("Egg") then
                    -- تجميد خاصية السقوط للبيضة
                    if v:FindFirstChild("Handle") then
                        v.Handle.CanCollide = false
                    end
                end
            end
            
            -- منع تنفيذ الـ Remotes التي تسقط البيض
            if char:FindFirstChild("ForceField") == nil then
                local ff = Instance.new("ForceField")
                ff.Name = "VX_EggShield"
                ff.Visible = false
                ff.Parent = char
            end
        end
    end)
end)

-- [محرك الإلغاء الفوري للانتظار عند الضغط على E]
ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
    if getgenv().InstantE then
        pcall(function()
            fireproximityprompt(prompt)
        end)
    end
end)

-- تسريع القيمة الزمنية لأي ProximityPrompt ينشأ في الماب
workspace.DescendantAdded:Connect(function(des)
    if des:IsA("ProximityPrompt") then
        if getgenv().InstantE then
            des.HoldDuration = 0
        end
    end
end)

for _, prompt in pairs(workspace:GetDescendants()) do
    if prompt:IsA("ProximityPrompt") and getgenv().InstantE then
        prompt.HoldDuration = 0
    end
end
