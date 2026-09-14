-- // 1. إنشاء الواجهة القديمة المخصصة (Custom Dark Engine)
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- حذف الواجهة القديمة إذا كانت مفتوحة لمنع التكرار
if CoreGui:FindFirstChild("VX_Custom_UI") then
    CoreGui.VX_Custom_UI:Destroy()
end

-- المتغيرات العامة
getgenv().FastEggGrab = true
getgenv().GodModeEgg = false
getgenv().WalkSpeedValue = 16

-- إنشاء الهيكل الأساسي للواجهة القديمة
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleBar = Instance.new("TextLabel")
local CloseBtn = Instance.new("TextButton")
local Container = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")

ScreenGui.Name = "VX_Custom_UI"
ScreenGui.Parent = CoreGui or LocalPlayer:WaitForChild("PlayerGui")

-- النافذة الرئيسية (تطابق تصميم صورتك القديمة)
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 480, 0, 320)
MainFrame.Active = true

-- الشريط العلوي
TitleBar.Name = "TitleBar"
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
TitleBar.Size = UDim2.new(1, -35, 0, 40)
TitleBar.Font = Enum.Font.SourceSansBold
TitleBar.Text = "   VX ABSOLUTE OVERLORD | STEAL AN EGG"
TitleBar.TextColor3 = Color3.fromRGB(0, 255, 150)
TitleBar.TextSize = 16
TitleBar.TextXAlignment = Enum.TextXAlignment.Left

-- زر الإغلاق
CloseBtn.Name = "CloseBtn"
CloseBtn.Parent = MainFrame
CloseBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
CloseBtn.Position = UDim2.new(1, -35, 0, 0)
CloseBtn.Size = UDim2.new(0, 35, 0, 40)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.TextSize = 18

-- قائمة العناصر الداخيلية
Container.Name = "Container"
Container.Parent = MainFrame
Container.BackgroundTransparency = 1
Container.Position = UDim2.new(0, 10, 0, 50)
Container.Size = UDim2.new(1, -20, 1, -60)
Container.CanvasSize = UDim2.new(0, 0, 1.5, 0)
Container.ScrollBarThickness = 5

UIListLayout.Parent = Container
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)

-- // 2. دالة إنشـاء الأزرار والسلايدر بالتصميم القديم

local function createToggle(text, default, callback)
    local button = Instance.new("TextButton")
    button.Parent = Container
    button.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    button.Size = UDim2.new(1, 0, 0, 45)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 15
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    local enabled = default
    local function updateText()
        if enabled then
            button.Text = text .. " : [تفعيل ON]"
            button.TextColor3 = Color3.fromRGB(0, 255, 150)
        else
            button.Text = text .. " : [إيقاف OFF]"
            button.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end
    
    updateText()
    button.MouseButton1Click:Connect(function()
        enabled = not enabled
        updateText()
        callback(enabled)
    end)
end

local function createSlider(text, min, max, default, callback)
    local frame = Instance.new("Frame")
    local label = Instance.new("TextLabel")
    local sliderBtn = Instance.new("TextButton")
    
    frame.Parent = Container
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    frame.Size = UDim2.new(1, 0, 0, 55)
    
    label.Parent = frame
    label.Size = UDim2.new(1, 0, 0, 25)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.SourceSansBold
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.Text = text .. " : " .. tostring(default)
    
    sliderBtn.Parent = frame
    sliderBtn.Position = UDim2.new(0.05, 0, 0.5, 0)
    sliderBtn.Size = UDim2.new(0.9, 0, 0, 20)
    sliderBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    sliderBtn.Text = "اسحب لتعديل السرعة"
    sliderBtn.Font = Enum.Font.SourceSans
    sliderBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    sliderBtn.TextSize = 12
    
    sliderBtn.MouseButton1Down:Connect(function()
        local moveconnection, releaseconnection
        moveconnection = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local relativeX = input.Position.X - sliderBtn.AbsolutePosition.X
                local percentage = math.clamp(relativeX / sliderBtn.AbsoluteSize.X, 0, 1)
                local value = math.floor(min + (max - min) * percentage)
                label.Text = text .. " : " .. tostring(value)
                callback(value)
            end
        end)
        releaseconnection = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                moveconnection:Disconnect()
                releaseconnection:Disconnect()
            end
        end)
    end)
end

-- // 3. إضافـة الخيارات والميزات داخل الواجهة

createToggle("حمل البيض السريع (Instant E Grab)", true, function(state)
    getgenv().FastEggGrab = state
end)

createToggle("حماية البيض والشخصية (Egg Protection)", false, function(state)
    getgenv().GodModeEgg = state
end)

createSlider("سرعة المشي (WalkSpeed)", 0, 1000, 16, function(value)
    getgenv().WalkSpeedValue = value
end)

-- // 4. المحركات والسرعة والحماية

ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
    if getgenv().FastEggGrab then
        pcall(function() fireproximityprompt(prompt) end)
    end
end)

RunService.RenderStepped:Connect(function()
    pcall(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().WalkSpeedValue
        end
        if getgenv().GodModeEgg and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") then part.CanTouch = false end
            end
        end
    end)
end)

-- // 5. جعل الواجهة والزر العائم ينحركان بالسحب (Draggable)

local function makeDraggable(guiObj, handleObj)
    local handle = handleObj or guiObj
    local dragging, dragStart, startPos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObj.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            guiObj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- تفعيل السحب للنافذة الرئيسية عن طريق الشريط العلوي
makeDraggable(MainFrame, TitleBar)

-- الزر العائم للتصغير والتكبير
local ToggleBtn = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

ToggleBtn.Name = "VX_Floating_Btn"
ToggleBtn.Parent = ScreenGui
ToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
ToggleBtn.Size = UDim2.new(0, 45, 0, 45)
ToggleBtn.Text = "VX"
ToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 16

UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = ToggleBtn

makeDraggable(ToggleBtn)

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)
