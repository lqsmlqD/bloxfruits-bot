-- // ==========================================
-- // VX STEAL AN EGG | FULL FIXED VERSION
-- // Developed for VX Community
-- // ==========================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "VX HUB | STEAL AN EGG (FIXED)",
   LoadingTitle = "جاري تهيئة الحماية المتقدمة والسرعة...",
   LoadingSubtitle = "by Ali & VX Team",
   ConfigurationSaving = { Enabled = false }
})

-- // 1. المتغيرات العامة (State)
getgenv().VX_Config = {
    EnableSpeed = false,
    TargetSpeed = 100,
    EggGodMode = true,
    AntiCage = true,
    InstantPick = true,
    ESP_Players = false,
    ESP_Eggs = false
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local LocalPlayer = Players.LocalPlayer

-- // 2. إنشاء الزر الدائري العائم (Floating VX Button)
local function createFloatingButton()
    local parentGui = game:GetService("CoreGui")
    if parentGui:FindFirstChild("VX_FloatingUI") then
        parentGui.VX_FloatingUI:Destroy()
    end

    local sg = Instance.new("ScreenGui")
    sg.Name = "VX_FloatingUI"
    sg.Parent = parentGui
    sg.ResetOnSpawn = false

    local btn = Instance.new("TextButton")
    btn.Name = "VX_Btn"
    btn.Parent = sg
    btn.Size = UDim2.new(0, 55, 0, 55)
    btn.Position = UDim2.new(0.05, 0, 0.2, 0)
    btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    btn.BorderColor3 = Color3.fromRGB(0, 255, 150)
    btn.BorderSizePixel = 2
    btn.Text = "VX"
    btn.TextColor3 = Color3.fromRGB(0, 255, 150)
    btn.TextSize = 22
    btn.Font = Enum.Font.SourceSansBold
    btn.Active = true
    btn.Draggable = true

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim2.new(1, 0)
    corner.Parent = btn

    local visible = true
    btn.MouseButton1Click:Connect(function()
        visible = not visible
        Rayfield:SelectTab() -- Refresh
        for _, gui in pairs(parentGui:GetChildren()) do
            if gui.Name == "Rayfield" then
                gui.Enabled = visible
            end
        end
    end)
end

createFloatingButton()

-- // 3. تبويبات الواجهة (Tabs)
local MainTab = Window:CreateTab("التحكم والسرعة", 4483362458)
local ESPTab = Window:CreateTab("كشف الأماكن (ESP)", 4483362458)

MainTab:CreateToggle({
   Name = "تفعيل السرعة المحددة (Speed Toggle)",
   CurrentValue = false,
   Callback = function(v) getgenv().VX_Config.EnableSpeed = v end,
})

MainTab:CreateSlider({
   Name = "مستوى السرعة (Speed Value)",
   Range = {16, 1000},
   Increment = 10,
   Suffix = "Speed",
   CurrentValue = 100,
   Callback = function(v) getgenv().VX_Config.TargetSpeed = v end,
})

MainTab:CreateToggle({
   Name = "حماية كاملة للبيض والشخصية (Godmode & Anti-Drop)",
   CurrentValue = true,
   Callback = function(v) getgenv().VX_Config.EggGodMode = v end,
})

MainTab:CreateToggle({
   Name = "إلغاء وتدمير أقفاص التجميد (Anti Cage)",
   CurrentValue = true,
   Callback = function(v) getgenv().VX_Config.AntiCage = v end,
})

MainTab:CreateToggle({
   Name = "سحب وحمل البيض التلقائي الفوري (Instant Pick E)",
   CurrentValue = true,
   Callback = function(v) getgenv().VX_Config.InstantPick = v end,
})

ESPTab:CreateToggle({
   Name = "كشف أماكن اللاعبين (ESP Players)",
   CurrentValue = false,
   Callback = function(v) getgenv().VX_Config.ESP_Players = v end,
})

ESPTab:CreateToggle({
   Name = "كشف أماكن البيض (ESP Eggs)",
   CurrentValue = false,
   Callback = function(v) getgenv().VX_Config.ESP_Eggs = v end,
})

-- // 4. المحركات البرمجية (Core Physics Engine)

-- [محرك كسر حماية السرعة والمناعة]
RunService.Heartbeat:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        
        local hrp = char.HumanoidRootPart
        local hum = char:FindFirstChildOfClass("Humanoid")
        
        -- تطبيق السرعة المباشرة عبر الفيزيا
        if getgenv().VX_Config.EnableSpeed and hum and hum.MoveDirection.Magnitude > 0 then
            hrp.AssemblyLinearVelocity = Vector3.new(
                hum.MoveDirection.X * getgenv().VX_Config.TargetSpeed,
                hrp.AssemblyLinearVelocity.Y,
                hum.MoveDirection.Z * getgenv().VX_Config.TargetSpeed
            )
        end
        
        -- حماية البيض والشخصية من الضرب والحيوانات
        if getgenv().VX_Config.EggGodMode then
            if hum then hum.Health = hum.MaxHealth end
            
            for _, item in pairs(char:GetChildren()) do
                if item:IsA("Tool") or item.Name:lower():find("egg") then
                    if item:FindFirstChild("Handle") then
                        item.Handle.CanCollide = false
                    end
                end
            end
        end
        
        -- تدمير الأقفاص والـ Stun
        if getgenv().VX_Config.AntiCage then
            hrp.Anchored = false
            for _, child in pairs(char:GetChildren()) do
                local name = child.Name:lower()
                if name:find("cage") or name:find("trap") or name:find("stun") or name:find("freeze") then
                    child:Destroy()
                end
            end
        end
    end)
end)

-- [محرك تخطي الانتظار وحمل البيض فوراً عند الضغط]
ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
    if getgenv().VX_Config.InstantPick then
        prompt.HoldDuration = 0
        pcall(function()
            fireproximityprompt(prompt)
        end)
    end
end)

workspace.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("ProximityPrompt") and getgenv().VX_Config.InstantPick then
        descendant.HoldDuration = 0
    end
end)

-- [محرك الـ ESP ورادار الكشف]
local function addESP(obj, color, labelText)
    if not obj:FindFirstChild("VX_Highlight") then
        local hl = Instance.new("Highlight")
        hl.Name = "VX_Highlight"
        hl.FillColor = color
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = 0.4
        hl.Parent = obj
        
        local bb = Instance.new("BillboardGui")
        bb.Name = "VX_Tag"
        bb.Adornee = obj
        bb.Size = UDim2.new(0, 120, 0, 30)
        bb.StudsOffset = Vector3.new(0, 3, 0)
        bb.AlwaysOnTop = true
        
        local txt = Instance.new("TextLabel")
        txt.Parent = bb
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.Text = labelText
        txt.TextColor3 = color
        txt.Font = Enum.Font.SourceSansBold
        txt.TextSize = 15
        
        bb.Parent = obj
    end
end

local function removeESP(obj)
    if obj:FindFirstChild("VX_Highlight") then obj.VX_Highlight:Destroy() end
    if obj:FindFirstChild("VX_Tag") then obj.VX_Tag:Destroy() end
end

task.spawn(function()
    while true do
        task.wait(1)
        pcall(function()
            -- ESP Players
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    if getgenv().VX_Config.ESP_Players then
                        addESP(plr.Character, Color3.fromRGB(255, 60, 60), plr.Name)
                    else
                        removeESP(plr.Character)
                    end
                end
            end
            
            -- ESP Eggs
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name:lower():find("egg") and (v:IsA("Model") or v:IsA("BasePart")) then
                    if getgenv().VX_Config.ESP_Eggs then
                        addESP(v, Color3.fromRGB(255, 215, 0), "Egg")
                    else
                        removeESP(v)
                    end
                end
            end
        end)
    end
end)
