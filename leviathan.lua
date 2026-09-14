-- // VX Absolute Overlord Engine | Blox Fruits
-- // Light, Super Fast & Zero Lag Custom Hub

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer

-- // 1. المتغيرات العامة (Global State)
getgenv().KillAura = false
getgenv().AuraRange = 70
getgenv().AutoSailing = false
getgenv().BoatSpeed = 220
getgenv().BoatHeight = 35
getgenv().SelectedBoat = "Beast Hunter"
getgenv().AutoKillLeviathan = false
getgenv().AutoCatchHeart = false

local OpenSeaTarget = Vector3.new(-28000, 35, -15000)

-- // 2. تنظيف الشاشة من أي واجهات سابقة
pcall(function()
    if CoreGui:FindFirstChild("VX_AbsoluteUI") then CoreGui.VX_AbsoluteUI:Destroy() end
    if CoreGui:FindFirstChild("VX_FloatBtn") then CoreGui.VX_FloatBtn:Destroy() end
end)

-- // 3. بناء الواجهة العصرية الخفيفة (Custom Sleek Dark UI)
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "VX_AbsoluteUI"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 480, 0, 320)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 10)

local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)

local TitleText = Instance.new("TextLabel", TitleBar)
TitleText.Size = UDim2.new(1, -50, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.Text = "VX ABSOLUTE OVERLORD | V10"
TitleText.TextColor3 = Color3.fromRGB(0, 255, 170)
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 16
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0.5, -15)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 60, 60)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.BackgroundTransparency = 1

-- زر التحكم الدائري (Floating Mobile Button)
local FloatGui = Instance.new("ScreenGui", CoreGui)
FloatGui.Name = "VX_FloatBtn"

local FloatBtn = Instance.new("TextButton", FloatGui)
FloatBtn.Size = UDim2.new(0, 48, 0, 48)
FloatBtn.Position = UDim2.new(0.02, 0, 0.25, 0)
FloatBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
FloatBtn.Text = "VX"
FloatBtn.TextColor3 = Color3.fromRGB(0, 255, 170)
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.TextSize = 18
FloatBtn.Active = true
FloatBtn.Draggable = true
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)

FloatBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

CloseBtn.MouseButton1Click:Connect(function()
    getgenv().KillAura = false
    getgenv().AutoSailing = false
    getgenv().AutoKillLeviathan = false
    ScreenGui:Destroy()
    FloatGui:Destroy()
end)

-- // 4. قسم التبويبات والأزرار (Controls Layout)
local Container = Instance.new("ScrollingFrame", MainFrame)
Container.Size = UDim2.new(1, -20, 1, -55)
Container.Position = UDim2.new(0, 10, 0, 45)
Container.BackgroundTransparency = 1
Container.ScrollBarThickness = 4
Container.CanvasSize = UDim2.new(0, 0, 0, 450)

local UIList = Instance.new("UIListLayout", Container)
UIList.Padding = UDim.new(0, 8)

local function CreateToggle(name, default, callback)
    local state = default
    local btn = Instance.new("TextButton", Container)
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.BackgroundColor3 = state and Color3.fromRGB(0, 180, 120) or Color3.fromRGB(30, 30, 40)
    btn.Text = name .. " : " .. (state and "تغعيل [ON]" or "إيقاف [OFF]")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 180, 120) or Color3.fromRGB(30, 30, 40)
        btn.Text = name .. " : " .. (state and "تغعيل [ON]" or "إيقاف [OFF]")
        callback(state)
    end)
end

local function CreateButton(name, callback)
    local btn = Instance.new("TextButton", Container)
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(callback)
end

-- إدخال الخيارات والميزات
CreateToggle("تفعيل Kill Aura (ضرب أوتوماتيكي مع حرية حركة كاملة)", false, function(v) getgenv().KillAura = v end)
CreateToggle("الإبحار التلقائي للبحر المفتوح (Auto Sail)", false, function(v) getgenv().AutoSailing = v end)

CreateButton("شراء وركوب السفينة تلقائياً (Beast Hunter)", function()
    pcall(function()
        local comms = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if comms then
            comms:InvokeServer("BuyBoat", getgenv().SelectedBoat)
            task.wait(0.6)
            local boatFolder = workspace:FindFirstChild("Boats") or workspace
            for _, boat in pairs(boatFolder:GetChildren()) do
                if boat:FindFirstChild("Owner") and tostring(boat.Owner.Value) == LocalPlayer.Name then
                    local seat = boat:FindFirstChildOfClass("VehicleSeat") or boat:FindFirstChild("VehicleSeat")
                    if seat and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = seat.CFrame * CFrame.new(0, 3, 0)
                        task.wait(0.2)
                        LocalPlayer.Character.Humanoid:Sit(seat)
                        break
                    end
                end
            end
        end
    end)
end)

CreateToggle("قتل وتتبع الليفايثن تلقائياً (Auto Leviathan)", false, function(v) getgenv().AutoKillLeviathan = v end)
CreateToggle("صيد وتأمين القلب بالرمح تلقائياً", false, function(v) getgenv().AutoCatchHeart = v end)

-- // 5. المحركات البرمجية عالية الكفاءة (High Performance Engines)

-- 1. محرك Kill Aura (بدون تجميد الماوس أو الشخصية)
RunService.Stepped:Connect(function()
    if getgenv().KillAura then
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then
                    tool:Activate()
                end
            end
        end)
    end
end)

-- 2. محرك قيادة وإبحار السفينة بالسلاسة والارتفاع المباشر
task.spawn(function()
    while true do
        task.wait(0.03)
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") and char.Humanoid.SeatPart then
                local seat = char.Humanoid.SeatPart
                local boat = seat.Parent
                
                if boat and boat.PrimaryPart then
                    local primary = boat.PrimaryPart
                    
                    -- التحكم بالارتفاع والتحليق بالماء
                    local bodyPos = primary:FindFirstChild("VX_Pos") or Instance.new("BodyPosition")
                    bodyPos.Name = "VX_Pos"
                    bodyPos.MaxForce = Vector3.new(0, 1e6, 0)
                    bodyPos.Position = Vector3.new(primary.Position.X, getgenv().BoatHeight, primary.Position.Z)
                    bodyPos.Parent = primary
                    
                    -- القيادة إلى البحر المفتوح
                    if getgenv().AutoSailing then
                        local linVel = primary:FindFirstChild("VX_Vel") or Instance.new("LinearVelocity")
                        local attachment = primary:FindFirstChild("RootAttachment") or Instance.new("Attachment", primary)
                        
                        local dir = (OpenSeaTarget - primary.Position).Unit
                        linVel.Name = "VX_Vel"
                        linVel.MaxForce = 1e6
                        linVel.VectorVelocity = Vector3.new(dir.X, 0, dir.Z).Unit * getgenv().BoatSpeed
                        linVel.Attachment0 = attachment
                        linVel.Parent = primary
                        
                        primary.CFrame = CFrame.new(primary.Position, primary.Position + Vector3.new(dir.X, 0, dir.Z))
                    else
                        if primary:FindFirstChild("VX_Vel") then
                            primary.VX_Vel:Destroy()
                        end
                    end
                end
            end
        end)
    end
end)

-- 3. محرك صيد وقتل الليفايثن
task.spawn(function()
    while true do
        task.wait(0.1)
        if getgenv().AutoKillLeviathan then
            pcall(function()
                local enemies = workspace:FindFirstChild("Enemies") or workspace
                for _, monster in pairs(enemies:GetChildren()) do
                    if monster.Name:find("Leviathan") or monster.Name:find("Segment") or monster.Name:find("Tail") then
                        if monster:FindFirstChild("HumanoidRootPart") and monster:FindFirstChild("Humanoid") and monster.Humanoid.Health > 0 then
                            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                LocalPlayer.Character.HumanoidRootPart.CFrame = monster.HumanoidRootPart.CFrame * CFrame.new(0, 25, 0)
                                local keys = {"Z", "X", "C", "V", "F"}
                                for _, k in ipairs(keys) do
                                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[k], false, game)
                                    task.wait(0.01)
                                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[k], false, game)
                                end
                            end
                            break
                        end
                    end
                end
            end)
        end
    end
end)
