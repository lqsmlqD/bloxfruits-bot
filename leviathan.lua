-- // ==========================================
-- // VX STEAL AN EGG | GODMODE & ESP ULTIMATE V2
-- // Developed for VX Community
-- // ==========================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "VX HUB | STEAL AN EGG V2",
   LoadingTitle = "جاري تهيئة الرادار والمحرك الحركي...",
   LoadingSubtitle = "by Ali & VX Team",
   ConfigurationSaving = { Enabled = false }
})

-- // 1. المتغيرات العامة (Global State)
getgenv().VX_Egg = {
    Speed = 16,
    GodMode = true,
    AntiCage = true,
    InstantPick = true,
    ESP_Players = false,
    ESP_Eggs = false
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- // 2. إنشاء الزر الدائري العائم (Floating Circle Toggle Button)
local ScreenGui = Instance.new("ScreenGui")
local ToggleButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

ScreenGui.Name = "VX_ToggleGui"
ScreenGui.Parent = (CoreGui:FindFirstChild("RobloxGui") or CoreGui)

ToggleButton.Name = "VX_Button"
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleButton.BorderSizePixel = 0
ToggleButton.Position = UDim2.new(0.1, 0, 0.2, 0)
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Text = "VX"
ToggleButton.TextColor3 = Color3.fromRGB(0, 255, 150)
ToggleButton.TextSize = 22.0
ToggleButton.Active = true
ToggleButton.Draggable = true

UICorner.CornerRadius = UDim2.new(1, 0)
UICorner.Parent = ToggleButton

local menuVisible = true
ToggleButton.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    if Rayfield.Flags then
        -- Toggle Rayfield Main Frame Visibility
        for _, gui in pairs(CoreGui:GetChildren()) do
            if gui.Name == "Rayfield" then
                gui.Enabled = menuVisible
            end
        end
    end
end)

-- // 3. تبويبات التحكم (Tabs)
local MainTab = Window:CreateTab("التحكم والحماية", 4483362458)
local ESPTab = Window:CreateTab("كشف الأماكن (ESP)", 4483362458)

MainTab:CreateSlider({
   Name = "تغيير السرعة الفائقة (Speed Bypass)",
   Range = {16, 1000},
   Increment = 10,
   Suffix = "Speed",
   CurrentValue = 16,
   Callback = function(v) getgenv().VX_Egg.Speed = v end,
})

MainTab:CreateToggle({
   Name = "حماية البيض والشخصية (Godmode & Anti-Drop)",
   CurrentValue = true,
   Callback = function(v) getgenv().VX_Egg.GodMode = v end,
})

MainTab:CreateToggle({
   Name = "إلغاء أقفاص التجميد (Anti Cage & Trap)",
   CurrentValue = true,
   Callback = function(v) getgenv().VX_Egg.AntiCage = v end,
})

MainTab:CreateToggle({
   Name = "حمل البيض التلقائي الفوري (Instant Hold E)",
   CurrentValue = true,
   Callback = function(v) getgenv().VX_Egg.InstantPick = v end,
})

ESPTab:CreateToggle({
   Name = "كشف اللاعبين (ESP Players)",
   CurrentValue = false,
   Callback = function(v) getgenv().VX_Egg.ESP_Players = v end,
})

ESPTab:CreateToggle({
   Name = "كشف البيض الخارجي وفي الأقفاص (ESP Eggs)",
   CurrentValue = false,
   Callback = function(v) getgenv().VX_Egg.ESP_Eggs = v end,
})

-- // 4. المحركات البرمجية والفيزياء (Core Engines)

-- [محرك تجاوز السرعة والحماية Anti-Cage & Speed Physics]
RunService.Stepped:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        
        local hrp = char.HumanoidRootPart
        local hum = char:FindFirstChildOfClass("Humanoid")
        
        -- تطبيق السرعة المباشرة لكسر حماية الماب
        if hum and getgenv().VX_Egg.Speed > 16 then
            if hum.MoveDirection.Magnitude > 0 then
                hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (getgenv().VX_Egg.Speed / 50))
            end
        end
        
        -- إلغاء التجميد والأقفاص
        if getgenv().VX_Egg.AntiCage then
            hrp.Anchored = false
            for _, child in pairs(char:GetChildren()) do
                if child.Name:lower():find("cage") or child.Name:lower():find("trap") or child.Name:lower():find("stun") then
                    child:Destroy()
                end
            end
        end
    end)
end)

-- [محرك تسريع واختطاف زر E للحمل الفوري]
ProximityPromptService.PromptShown:Connect(function(prompt)
    if getgenv().VX_Egg.InstantPick then
        prompt.HoldDuration = 0
        pcall(function()
            fireproximityprompt(prompt)
        end)
    end
end)

-- [محرك الـ ESP ورادار الكشف الشامل]
local function createHighlight(instance, color, name)
    if not instance:FindFirstChild("VX_Highlight") then
        local hl = Instance.new("Highlight")
        hl.Name = "VX_Highlight"
        hl.FillColor = color
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = 0.5
        hl.OutlineTransparency = 0
        hl.Adornee = instance
        hl.Parent = instance
        
        local bb = Instance.new("BillboardGui")
        bb.Name = "VX_NameTag"
        bb.Adornee = instance
        bb.Size = UDim2.new(0, 100, 0, 30)
        bb.StudsOffset = Vector3.new(0, 3, 0)
        bb.AlwaysOnTop = true
        
        local txt = Instance.new("TextLabel")
        txt.Parent = bb
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.Text = name
        txt.TextColor3 = color
        txt.Font = Enum.Font.SourceSansBold
        txt.TextSize = 14
        
        bb.Parent = instance
    end
end

local function removeHighlight(instance)
    if instance:FindFirstChild("VX_Highlight") then instance.VX_Highlight:Destroy() end
    if instance:FindFirstChild("VX_NameTag") then instance.VX_NameTag:Destroy() end
end

task.spawn(function()
    while true do
        task.wait(1)
        -- ESP Players
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                if getgenv().VX_Egg.ESP_Players then
                    createHighlight(plr.Character, Color3.fromRGB(255, 50, 50), plr.Name)
                else
                    removeHighlight(plr.Character)
                end
            end
        end
        
        -- ESP Eggs
        for _, item in pairs(workspace:GetDescendants()) do
            if item.Name:lower():find("egg") and (item:IsA("Model") or item:IsA("BasePart")) then
                if getgenv().VX_Egg.ESP_Eggs then
                    createHighlight(item, Color3.fromRGB(255, 215, 0), "Egg")
                else
                    removeHighlight(item)
                end
            end
        end
    end
end)
