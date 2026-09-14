-- // 1. تحميل مكتبة Kavo UI المستقرة للهواتف
local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Kavo.CreateLib("VX HUB | STEAL AN EGG", "DarkTheme")

-- // 2. المتغيرات العامة (Settings)
getgenv().FastEggGrab = true
getgenv().GodModeEgg = false
getgenv().WalkSpeedValue = 16

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local LocalPlayer = Players.LocalPlayer

-- // 3. إنشاء التبويبات والأزرار (Tabs & Sections)

-- [تبويب 1: الميزات الأساسية]
local MainTab = Window:NewTab("الميزات الأساسية")
local MainSection = MainTab:NewSection("سرقة وتأمين البيض")

MainSection:NewToggle("حمل البيض السريع (Instant E Grab)", "سرعة التفاعل في أجزاء من الثانية", function(state)
    getgenv().FastEggGrab = state
end)

MainSection:NewToggle("حماية البيض والشخصية (Egg Protection)", "مقاومة ضربات اللاعبين والحيوانات", function(state)
    getgenv().GodModeEgg = state
end)

-- [تبويب 2: التحكم بالسرعة]
local SpeedTab = Window:NewTab("السرعة والتنقل")
local SpeedSection = SpeedTab:NewSection("سرعة الشخصية")

SpeedSection:NewSlider("سرعة المشي (WalkSpeed)", "من 0 إلى 1000", 1000, 0, function(v)
    getgenv().WalkSpeedValue = v
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = v
    end
end)

-- // 4. الأنظمة والوظائف الخلفية (Engine Logic)

-- [أولاً: السرعة الفائقة لحمل البيضة عند ضغط E]
ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
    if getgenv().FastEggGrab then
        fireproximityprompt(prompt)
    end
end)

-- [ثانياً: تثبيت السرعة وحماية الشخصية والبيض]
RunService.RenderStepped:Connect(function()
    pcall(function()
        -- التثبيت التلقائي للسرعة المحددة
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            if LocalPlayer.Character.Humanoid.WalkSpeed ~= getgenv().WalkSpeedValue then
                LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().WalkSpeedValue
            end
        end
        
        -- إلغاء التصادم وتلقي الضرر لمنع إسقاط البيضة
        if getgenv().GodModeEgg and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanTouch = not getgenv().GodModeEgg -- يمنع تأثير ضربات الحيوانات واللاعبين
                end
            end
        end
    end)
end)

-- // 5. إنشاء الزر العائم للتصغير والتكبير (Floating Toggle Button)

local ScreenGui = Instance.new("ScreenGui")
local ToggleButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

ScreenGui.Name = "VX_FloatingGui"
ScreenGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleButton.Position = UDim2.new(0.05, 0, 0.2, 0)
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Text = "VX"
ToggleButton.TextColor3 = Color3.fromRGB(0, 255, 150)
ToggleButton.TextSize = 18.0
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Active = true
ToggleButton.Draggable = true -- إمكانية سحب الزر لأي مكان في الشاشة

UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = ToggleButton

-- وظيفة إخفاء وإظهار الواجهة عند الضغط
ToggleButton.MouseButton1Click:Connect(function()
    Kavo:ToggleUI()
end)
