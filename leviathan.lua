-- // 1. إنشاء الواجهة القديمة المحدثة والمخصصة للجوال
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

if CoreGui:FindFirstChild("VX_Custom_UI") then
    CoreGui.VX_Custom_UI:Destroy()
end

-- المتغيرات العامة
getgenv().FastEggGrab = true
getgenv().GodModeEgg = false
getgenv().SpeedToggle = false
getgenv().WalkSpeedValue = 16

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleBar = Instance.new("TextLabel")
local CloseBtn = Instance.new("TextButton")
local Container = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")

ScreenGui.Name = "VX_Custom_UI"
ScreenGui.Parent = CoreGui or LocalPlayer:WaitForChild("PlayerGui")

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.2, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 420, 0, 300)
MainFrame.Active = true

TitleBar.Name = "TitleBar"
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
TitleBar.Size = UDim2.new(1, -35, 0, 40)
TitleBar.Font = Enum.Font.SourceSansBold
TitleBar.Text = "   VX HUB | STEAL AN EGG (FIXED)"
TitleBar.TextColor3 = Color3.fromRGB(0, 255, 150)
TitleBar.TextSize = 16
TitleBar.TextXAlignment = Enum.TextXAlignment.Left

CloseBtn.Name = "CloseBtn"
CloseBtn.Parent = MainFrame
CloseBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
CloseBtn.Position = UDim2.new(1, -35, 0, 0)
CloseBtn.Size = UDim2.new(0, 35, 0, 40)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 60, 60)
CloseBtn.TextSize = 18

Container.Name = "Container"
Container.Parent = MainFrame
Container.BackgroundTransparency = 1
Container.Position = UDim2.new(0, 10, 0, 50)
Container.Size = UDim2.new(1, -20, 1, -60)
Container.CanvasSize = UDim2.new(0, 0, 1.8, 0)
Container.ScrollBarThickness = 4

UIListLayout.Parent = Container
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)

-- // 2. أزرار التحكم والخيارات

local function createToggle(text, default, callback)
    local button = Instance.new("TextButton")
    button.Parent = Container
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    button.Size = UDim2.new(1, 0, 0, 40)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 14
    
    local enabled = default
    local function updateText()
        if enabled then
            button.Text = text .. " : [مفعل ON]"
            button.TextColor3 = Color3.fromRGB(0, 255, 150)
        else
            button.Text = text .. " : [معطل OFF]"
            button.TextColor3 = Color3.fromRGB(180, 180, 180)
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
    local minusBtn = Instance.new("TextButton")
    local plusBtn = Instance.new("TextButton")
    
    frame.Parent = Container
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    frame.Size = UDim2.new(1, 0, 0, 45)
    
    label.Parent = frame
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.SourceSansBold
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local currentVal = default
    local function updateVal()
        label.Text = text .. " : " .. tostring(currentVal)
        callback(currentVal)
    end
    
    minusBtn.Parent = frame
    minusBtn.Position = UDim2.new(0.65, 0, 0.15, 0)
    minusBtn.Size = UDim2.new(0, 35, 0, 30)
    minusBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    minusBtn.Text = "-50"
    minusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minusBtn.Font = Enum.Font.SourceSansBold
    
    plusBtn.Parent = frame
    plusBtn.Position = UDim2.new(0.82, 0, 0.15, 0)
    plusBtn.Size = UDim2.new(0, 35, 0, 30)
    plusBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    plusBtn.Text = "+50"
    plusBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    plusBtn.Font = Enum.Font.SourceSansBold
    
    updateVal()
    
    minusBtn.MouseButton1Click:Connect(function()
        currentVal = math.clamp(currentVal - 50, min, max)
        updateVal()
    end)
    
    plusBtn.MouseButton1Click:Connect(function()
        currentVal = math.clamp(currentVal + 50, min, max)
        updateVal()
    end)
end

-- إضافة الخيارات
createToggle("حمل البيض السريع (Instant E Grab)", true, function(state)
    getgenv().FastEggGrab = state
end)

createToggle("تفعيل زر السرعة (Enable Speed)", false, function(state)
    getgenv().SpeedToggle = state
end)

createSlider("مستوى السرعة (Speed Value)", 0, 1000, 100, function(value)
    getgenv().WalkSpeedValue = value
end)

createToggle("حماية البيض والشخصية (Egg Protection)", false, function(state)
    getgenv().GodModeEgg = state
end)

-- // 3. المحركات المحدثة (Anti-Rubberband & Full Protection)

-- [أولاً: السرعة بدون ارتداد باستخدام AssemblyLinearVelocity]
RunService.Stepped:Connect(function()
    pcall(function()
        if getgenv().SpeedToggle and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            local moveDir = LocalPlayer.Character.Humanoid.MoveDirection
            
            if moveDir.Magnitude > 0 then
                hrp.AssemblyLinearVelocity = Vector3.new(
                    moveDir.X * getgenv().WalkSpeedValue,
                    hrp.AssemblyLinearVelocity.Y,
                    moveDir.Z * getgenv().WalkSpeedValue
                )
            end
        end
    end)
end)

-- [ثانياً: حماية البيض والشخصية من الضربات والحيوانات]
RunService.RenderStepped:Connect(function()
    pcall(function()
        if getgenv().GodModeEgg and LocalPlayer.Character then
            -- إلغاء تصادم أجزاء الشخصية
            for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanTouch = false
                end
            end
            
            -- تعويل وحذف التفاعل مع محفزات الضرر الخاصة بالحيوانات
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("TouchTransmitter") and v.Parent and v.Parent.Parent ~= LocalPlayer.Character then
                    if v.Parent.Name:find("Animal") or v.Parent.Name:find("Hitbox") or v.Parent.Name:find("Mob") then
                        v:Destroy()
                    end
                end
            end
        end
    end)
end)

-- [ثالثاً: حمل البيض السريع]
ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
    if getgenv().FastEggGrab then
        pcall(function() fireproximityprompt(prompt) end)
    end
end)

-- // 4. جعل الواجهة قابلة للسحب ومناسبة للجوال

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
