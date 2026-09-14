-- // 1. تحميل مكتبة Kavo UI
local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Kavo.CreateLib("VX HUB | STEAL AN EGG (FIXED)", "DarkTheme")

-- // 2. المتغيرات العامة
getgenv().FastEggGrab = true
getgenv().GodModeEgg = false
getgenv().WalkSpeedValue = 16

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- // 3. التبويبات والأزرار

-- [تبويب 1: الميزات الأساسية]
local MainTab = Window:NewTab("الميزات الأساسية")
local MainSection = MainTab:NewSection("سرقة وتأمين البيض")

MainSection:NewToggle("حمل البيض السريع (Instant E Grab)", "تجاوز وقت الانتظار", function(state)
    getgenv().FastEggGrab = state
end)

MainSection:NewToggle("حماية البيض والشخصية (Egg Protection)", "إلغاء الضرر لمنع إسقاط البيض", function(state)
    getgenv().GodModeEgg = state
end)

-- [تبويب 2: التحكم بالسرعة]
local SpeedTab = Window:NewTab("السرعة والتنقل")
local SpeedSection = SpeedTab:NewSection("سرعة الشخصية")

SpeedSection:NewSlider("سرعة المشي (WalkSpeed)", "من 0 إلى 1000", 1000, 0, function(v)
    getgenv().WalkSpeedValue = v
end)

-- // 4. المحركات والوظائف الخلفية (Engine Logic)

-- سحب البيض الفوري
ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
    if getgenv().FastEggGrab then
        pcall(function()
            fireproximityprompt(prompt)
        end)
    end
end)

-- حلقة تفعيل السرعة وحماية الشخصية
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

-- // 5. تفعيل سحب الواجهة + الزر العائم (Draggable UI & Floating Button)

-- دالة جعل أي نافذة قابلة للتحريك والسحب باللمس أو الماوس
local function makeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- تطبيق خيار السحب على شاشة الواجهة الرئيسية
task.spawn(function()
    local coreGui = game:GetService("CoreGui")
    local uiFrame = coreGui:FindFirstChild("KavoUI") or coreGui:FindFirstChild("DarkTheme")
    if uiFrame then
        for _, child in pairs(uiFrame:GetChildren()) do
            if child:IsA("Frame") then
                makeDraggable(child)
            end
        end
    end
end)

-- الزر العائم للتصغير والتكبير
local ScreenGui = Instance.new("ScreenGui")
local ToggleButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

ScreenGui.Name = "VX_Toggle_Gui"
ScreenGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
ToggleButton.Position = UDim2.new(0.05, 0, 0.2, 0)
ToggleButton.Size = UDim2.new(0, 45, 0, 45)
ToggleButton.Text = "VX"
ToggleButton.TextColor3 = Color3.fromRGB(0, 0, 0)
ToggleButton.TextSize = 16.0
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Active = true

UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = ToggleButton

makeDraggable(ToggleButton)

ToggleButton.MouseButton1Click:Connect(function()
    Kavo:ToggleUI()
end)
