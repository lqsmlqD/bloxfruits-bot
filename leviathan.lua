-- // 1. تهيئة النظام والخدمات الأساسية
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- حذف أي واجهة قديمة لتفادي التكرار
if CoreGui:FindFirstChild("VX_Ultimate_Hub") then
    CoreGui.VX_Ultimate_Hub:Destroy()
end

-- // 2. المتغيرات العامة (إدارة الميزات)
getgenv().FastEggGrab = false     -- حمل البيض السريع
getgenv().GodModeProtection = false-- حماية الشخصية من اللاعبين والحيوانات
getgenv().SpeedToggle = false     -- تفعيل/إيقاف السرعة المحددة
getgenv().TargetSpeed = 16        -- قيمة السرعة المطلوبة

-- // 3. بناء الواجهة العصرية (Modern Dark UI)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICornerMain = Instance.new("UICorner")
local UIStrokeMain = Instance.new("UIStroke")
local TitleBar = Instance.new("Frame")
local TitleText = Instance.new("TextLabel")
local CloseBtn = Instance.new("TextButton")
local Container = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")

ScreenGui.Name = "VX_Ultimate_Hub"
ScreenGui.Parent = CoreGui or LocalPlayer:WaitForChild("PlayerGui")

-- النافذة الرئيسية
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 380, 0, 310)
MainFrame.Active = true

UICornerMain.CornerRadius = UDim.new(0, 12)
UICornerMain.Parent = MainFrame

UIStrokeMain.Color = Color3.fromRGB(0, 255, 150)
UIStrokeMain.Thickness = 1.5
UIStrokeMain.Parent = MainFrame

-- الشريط العلوي
TitleBar.Name = "TitleBar"
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
TitleBar.Size = UDim2.new(1, 0, 0, 42)

TitleText.Parent = TitleBar
TitleText.Size = UDim2.new(1, -45, 1, 0)
TitleText.Position = UDim2.new(0, 12, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Font = Enum.Font.GothamBold
TitleText.Text = "VX HUB | STEAL AN EGG"
TitleText.TextColor3 = Color3.fromRGB(0, 255, 150)
TitleText.TextSize = 14
TitleText.TextXAlignment = Enum.TextXAlignment.Left

CloseBtn.Parent = TitleBar
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -38, 0, 3)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 70, 70)
CloseBtn.TextSize = 16

-- الحاوية الداخلية
Container.Parent = MainFrame
Container.BackgroundTransparency = 1
Container.Position = UDim2.new(0, 10, 0, 50)
Container.Size = UDim2.new(1, -20, 1, -60)
Container.CanvasSize = UDim2.new(0, 0, 0, 0)
Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
Container.ScrollBarThickness = 3

UIListLayout.Parent = Container
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)

-- // 4. دالات إنشاء عناصر التحكم العصرية

local function createToggle(text, callback)
    local button = Instance.new("TextButton")
    local corner = Instance.new("UICorner")
    local stroke = Instance.new("UIStroke")
    
    button.Parent = Container
    button.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
    button.Size = UDim2.new(1, 0, 0, 42)
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 13
    button.TextColor3 = Color3.fromRGB(200, 200, 200)
    button.Text = text .. " : [معطل]"
    
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    stroke.Color = Color3.fromRGB(45, 45, 55)
    stroke.Thickness = 1
    stroke.Parent = button
    
    local state = false
    button.MouseButton1Click:Connect(function()
        state = not state
        if state then
            button.Text = text .. " : [مفعل]"
            button.TextColor3 = Color3.fromRGB(0, 255, 150)
            stroke.Color = Color3.fromRGB(0, 255, 150)
        else
            button.Text = text .. " : [معطل]"
            button.TextColor3 = Color3.fromRGB(200, 200, 200)
            stroke.Color = Color3.fromRGB(45, 45, 55)
        end
        callback(state)
    end)
end

local function createSpeedInput(callback)
    local frame = Instance.new("Frame")
    local corner = Instance.new("UICorner")
    local label = Instance.new("TextLabel")
    local textBox = Instance.new("TextBox")
    local boxCorner = Instance.new("UICorner")
    
    frame.Parent = Container
    frame.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
    frame.Size = UDim2.new(1, 0, 0, 42)
    
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    label.Parent = frame
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamSemibold
    label.Text = "اكتب مقدار السرعة:"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    textBox.Parent = frame
    textBox.Size = UDim2.new(0.35, -10, 0.7, 0)
    textBox.Position = UDim2.new(0.65, 0, 0.15, 0)
    textBox.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    textBox.Font = Enum.Font.GothamBold
    textBox.Text = "16"
    textBox.TextColor3 = Color3.fromRGB(0, 255, 150)
    textBox.TextSize = 13
    textBox.ClearTextOnFocus = false
    
    boxCorner.CornerRadius = UDim.new(0, 6)
    boxCorner.Parent = textBox
    
    textBox.FocusLost:Connect(function()
        local val = tonumber(textBox.Text)
        if val then
            callback(val)
        else
            textBox.Text = tostring(getgenv().TargetSpeed)
        end
    end)
end

-- // 5. تجميع أزرار الواجهة حسب الطلب

-- 1. زر حمل البيض السريع
createToggle("حمل البيض الفوري (Instant Grab)", function(state)
    getgenv().FastEggGrab = state
end)

-- 2. زر عدم قدرة الأشخاص والحيوانات على الضرب
createToggle("حماية مطلقة (GodMode & Anti-Hit)", function(state)
    getgenv().GodModeProtection = state
end)

-- 3. مربع كتابة مقدار السرعة
createSpeedInput(function(value)
    getgenv().TargetSpeed = value
end)

-- 4. زر تشغيل/إيقاف السرعة المحددة
createToggle("تفعيل السرعة المحددة", function(state)
    getgenv().SpeedToggle = state
end)

-- // 6. المحركات والوظائف البرمجية (Core Logic)

-- [محرك حمل البيض السريع]
ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
    if getgenv().FastEggGrab then
        pcall(function() fireproximityprompt(prompt) end)
    end
end)

-- [محرك السرعة المستقرة بدون ارتداد]
RunService.Stepped:Connect(function()
    pcall(function()
        if getgenv().SpeedToggle and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            
            if humanoid and humanoid.MoveDirection.Magnitude > 0 then
                hrp.AssemblyLinearVelocity = Vector3.new(
                    humanoid.MoveDirection.X * getgenv().TargetSpeed,
                    hrp.AssemblyLinearVelocity.Y,
                    humanoid.MoveDirection.Z * getgenv().TargetSpeed
                )
            end
        end
    end)
end)

-- [محرك الحماية التامة من اللاعبين والحيوانات]
RunService.RenderStepped:Connect(function()
    pcall(function()
        if getgenv().GodModeProtection and LocalPlayer.Character then
            -- 1. إبطال ملامسة أجزاء الشخصية لإلغاء تلقي الضرر
            for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanTouch = false
                end
            end
            
            -- 2. حظر وتدمير مستشعرات الضرر التابعة للاعبين والحيوانات
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("TouchTransmitter") and v.Parent and v.Parent.Parent ~= LocalPlayer.Character then
                    v:Destroy()
                end
            end
        end
    end)
end)

-- // 7. تفعيل سحب الواجهة والزر العائم للتصغير والتكبير

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

makeDraggable(MainFrame, TitleBar)

-- إنشاء الزر العائم للتصغير/التكبير
local ToggleBtn = Instance.new("TextButton")
local BtnCorner = Instance.new("UICorner")
local BtnStroke = Instance.new("UIStroke")

ToggleBtn.Name = "VX_Floating_Btn"
ToggleBtn.Parent = ScreenGui
ToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
ToggleBtn.Size = UDim2.new(0, 45, 0, 45)
ToggleBtn.Text = "VX"
ToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 15

BtnCorner.CornerRadius = UDim.new(0, 10)
BtnCorner.Parent = ToggleBtn

BtnStroke.Color = Color3.fromRGB(0, 255, 150)
BtnStroke.Thickness = 1.5
BtnStroke.Parent = ToggleBtn

makeDraggable(ToggleBtn)

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)
