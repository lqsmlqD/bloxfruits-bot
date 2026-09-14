-- // 1. تحميل مكتبة Fluent UI العصريّة والمطورة
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- // 2. إنشاء النافذة الرئيسية العصرية (قابل للتكبير والتصغير والسحب)
local Window = Fluent:CreateWindow({
    Title = "VX HUB | STEAL AN EGG",
    SubTitle = "Ultimate Edition V2",
    TabWidth = 160,
    Size = UDim2.fromOffset(530, 350),
    Acrylic = true, -- تأثير الزجاج المضبب العصري
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- // 3. المتغيرات العامة (Settings)
getgenv().FastEggGrab = true
getgenv().GodModeEgg = false
getgenv().WalkSpeedValue = 16

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local LocalPlayer = Players.LocalPlayer

-- // 4. إنشاء التبويبات والميزات (Tabs & Options)

local Tabs = {
    Main = Window:AddTab({ Title = "الرئيسية", Icon = "egg" }),
    Speed = Window:AddTab({ Title = "السرعة والتنقل", Icon = "zap" })
}

-- [ميزات سرقة وتأمين البيض]
Tabs.Main:AddToggle("FastGrab", {
    Title = "حمل البيض السريع (Instant E Grab)",
    Default = true,
    Callback = function(Value)
        getgenv().FastEggGrab = Value
    end
})

Tabs.Main:AddToggle("GodEgg", {
    Title = "حماية البيض والشخصية (Egg Protection)",
    Default = false,
    Callback = function(Value)
        getgenv().GodModeEgg = Value
    end
})

-- [ميزات التحكم بالسرعة]
Tabs.Speed:AddSlider("WalkSpeedSlider", {
    Title = "سرعة المشي (WalkSpeed)",
    Description = "تحديد السرعة من 0 إلى 1000",
    Default = 16,
    Min = 0,
    Max = 1000,
    Rounding = 0,
    Callback = function(Value)
        getgenv().WalkSpeedValue = Value
    end
})

-- // 5. المحركات والوظائف الخلفية (Engine Logic)

-- حشو التفاعل السريع للبيض عند ضغط E
ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
    if getgenv().FastEggGrab then
        pcall(function()
            fireproximityprompt(prompt)
        end)
    end
end)

-- حلقة تفعيل السرعة والحماية بدون لاق
RunService.RenderStepped:Connect(function()
    pcall(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().WalkSpeedValue
        end
        
        if getgenv().GodModeEgg and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanTouch = false
                end
            end
        end
    end)
end)

-- // 6. إنشـاء الزر العائم العصري للتصغير والتكبير (Floating Drag Button)

local CoreGui = game:GetService("CoreGui")
local ScreenGui = Instance.new("ScreenGui")
local ToggleBtn = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")
local UIStroke = Instance.new("UIStroke")

ScreenGui.Name = "VX_Modern_Gui"
ScreenGui.Parent = CoreGui or LocalPlayer:WaitForChild("PlayerGui")

ToggleBtn.Name = "VX_Toggle"
ToggleBtn.Parent = ScreenGui
ToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
ToggleBtn.Position = UDim2.new(0.08, 0, 0.15, 0)
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Text = "VX"
ToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
ToggleBtn.TextSize = 18
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Active = true
ToggleBtn.Draggable = true -- زر عائم قابل للسحب في أي مكان على الشاشة

UICorner.CornerRadius = UDim.new(0, 14)
UICorner.Parent = ToggleBtn

UIStroke.Color = Color3.fromRGB(0, 255, 150)
UIStroke.Thickness = 1.5
UIStroke.Parent = ToggleBtn

-- وظيفة زر التخفي والتكبير للواجهة
ToggleBtn.MouseButton1Click:Connect(function()
    Window:Minimize()
end)
