-- // 1. تحميل مكتبة Fluent GUI (المستعملة في Quantum Onyx و Banana Hub)
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "VX Hub V9 | Quantum & Banana Edition",
    SubTitle = "Blox Fruits Universal Engine",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 400),
    Acrylic = true,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- // 2. المتغيرات العامة (Global Settings)
getgenv().AutoFarmLevel = false
getgenv().BringMobs = true
getgenv().TweenSpeed = 250
getgenv().FastAttackM1 = true

getgenv().BoatSpeed = 200
getgenv().BoatHeight = 35
getgenv().AutoSailing = false
getgenv().SelectedBoat = "Beast Hunter"

getgenv().AutoKillLeviathan = false
getgenv().UseDragonSkills = true
getgenv().AutoHarpoonHeart = false
getgenv().AutoReturnTiki = false

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local OpenSeaTarget = Vector3.new(-28000, 35, -15000)

-- // 3. الزر الدائري لتخفيض وإظهار الواجهة (Floating Toggle)
pcall(function()
    if CoreGui:FindFirstChild("VX_QuantumToggle") then
        CoreGui.VX_QuantumToggle:Destroy()
    end
end)

local ScreenGui = Instance.new("ScreenGui")
local ToggleBtn = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

ScreenGui.Name = "VX_QuantumToggle"
ScreenGui.Parent = CoreGui

ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Parent = ScreenGui
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ToggleBtn.Position = UDim2.new(0.02, 0, 0.25, 0)
ToggleBtn.Size = UDim2.new(0, 52, 0, 52)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Text = "VX"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 205, 0) -- لون موز مميز
ToggleBtn.TextSize = 18
ToggleBtn.Active = true
ToggleBtn.Draggable = true

UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = ToggleBtn

ToggleBtn.MouseButton1Click:Connect(function()
    Window:Minimize()
end)

-- // 4. إنشاء التبويبات والمكونات (Tabs)
local Tabs = {
    Main = Window:AddTab({ Title = "التجميع (Main Farm)", Icon = "home" }),
    Sea = Window:AddTab({ Title = "البحر المفتوح (Sea Event)", Icon = "anchor" }),
    Settings = Window:AddTab({ Title = "الإعدادات والإغلاق", Icon = "settings" })
}

-- [تبويب 1: التجميع واللفل]
Tabs.Main:AddToggle("AutoFarmLevel", {
    Title = "تجميع اللفل تلقائياً (Auto Farm Level)",
    Default = false,
    Callback = function(Value) getgenv().AutoFarmLevel = Value end
})

Tabs.Main:AddToggle("BringMobs", {
    Title = "تجميع الوحوش في نقطة واحدة (Bring Mobs)",
    Default = true,
    Callback = function(Value) getgenv().BringMobs = Value end
})

Tabs.Main:AddToggle("FastAttack", {
    Title = "هجوم سريع خارق (Quantum Fast Attack)",
    Default = true,
    Callback = function(Value) getgenv().FastAttackM1 = Value end
})

Tabs.Main:AddSlider("TweenSpeed", {
    Title = "سرعة التنقل (Tween Speed)",
    Default = 250,
    Min = 100,
    Max = 350,
    Rounding = 0,
    Callback = function(Value) getgenv().TweenSpeed = Value end
})

-- [تبويب 2: أحداث البحر والسفينة]
Tabs.Sea:AddDropdown("BoatType", {
    Title = "اختر السفينة",
    Values = {"Beast Hunter", "Grand Brig", "Swamp Pirate", "Sloop"},
    Default = "Beast Hunter",
    Callback = function(Option) getgenv().SelectedBoat = Option end
})

Tabs.Sea:AddButton({
    Title = "شراء وركوب السفينة تلقائياً",
    Callback = function()
        pcall(function()
            local comms = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
            if comms then
                comms:InvokeServer("BuyBoat", getgenv().SelectedBoat)
                task.wait(0.8)
                local boatFolder = workspace:FindFirstChild("Boats") or workspace
                for _, boat in pairs(boatFolder:GetChildren()) do
                    if boat:FindFirstChild("Owner") and tostring(boat.Owner.Value) == LocalPlayer.Name then
                        local seat = boat:FindFirstChildOfClass("VehicleSeat") or boat:FindFirstChild("VehicleSeat")
                        if seat and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = seat.CFrame * CFrame.new(0, 2, 0)
                            task.wait(0.2)
                            LocalPlayer.Character.Humanoid:Sit(seat)
                            break
                        end
                    end
                end
            end
        end)
    end
})

Tabs.Sea:AddToggle("AutoSailing", {
    Title = "الإبحار التلقائي للبحر المفتوح (Auto Sail Zone 6)",
    Default = false,
    Callback = function(Value) getgenv().AutoSailing = Value end
})

Tabs.Sea:AddSlider("BoatSpeed", {
    Title = "سرعة إبحار السفينة",
    Default = 200,
    Min = 50,
    Max = 500,
    Rounding = 0,
    Callback = function(Value) getgenv().BoatSpeed = Value end
})

Tabs.Sea:AddToggle("AutoKillLevi", {
    Title = "قتل وتتبع الليفايثن والذيل تلقائياً",
    Default = false,
    Callback = function(Value) getgenv().AutoKillLeviathan = Value end
})

Tabs.Sea:AddToggle("AutoCatchHeart", {
    Title = "صيد وسحب القلب بالرمح تلقائياً",
    Default = false,
    Callback = function(Value) getgenv().AutoHarpoonHeart = Value end
})

-- [تبويب 3: الإعدادات والإغلاق]
Tabs.Settings:AddButton({
    Title = "إغلاق السكربت نهائياً (Destroy GUI)",
    Callback = function()
        getgenv().AutoFarmLevel = false
        getgenv().KillAuraM1 = false
        getgenv().AutoKillLeviathan = false
        getgenv().AutoSailing = false
        getgenv().AutoHarpoonHeart = false
        pcall(function() ScreenGui:Destroy() end)
        Fluent:Destroy()
    end
})

-- // 5. المحركات والوظائف الخلفية الخارقة (Quantum Engine Mechanics)

-- محرك التنقل السريع Tween Transport
local function TweenTo(cframe)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        local dist = (hrp.Position - cframe.Position).Magnitude
        local tweenInfo = TweenInfo.new(dist / getgenv().TweenSpeed, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = cframe})
        tween:Play()
        return tween
    end
end

-- محرك التجميع والقتال الخفيف M1 Attack
task.spawn(function()
    while true do
        task.wait(0.02)
        if getgenv().FastAttackM1 then
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then
                        tool:Activate()
                    end
                end
            end)
        end
    end
end)

-- محرك Bring Mobs (تجميع الوحوش حول اللاعب)
task.spawn(function()
    while true do
        task.wait(0.2)
        if getgenv().BringMobs then
            pcall(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local myPos = char.HumanoidRootPart.Position
                    local enemies = workspace:FindFirstChild("Enemies") or workspace
                    for _, mob in pairs(enemies:GetChildren()) do
                        if mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                            if (mob.HumanoidRootPart.Position - myPos).Magnitude <= 350 then
                                mob.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(0, 0, -6)
                                mob.HumanoidRootPart.CanCollide = false
                                mob.Humanoid.Size = Vector3.new(20, 20, 20)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- محرك الإبحار والملاحة إلى البحر المفتوح
task.spawn(function()
    while true do
        task.wait(0.05)
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") and char.Humanoid.SeatPart then
                local seat = char.Humanoid.SeatPart
                local boat = seat.Parent
                
                if boat and boat.PrimaryPart then
                    local primary = boat.PrimaryPart
                    
                    local bodyPos = primary:FindFirstChild("VX_Pos") or Instance.new("BodyPosition")
                    bodyPos.Name = "VX_Pos"
                    bodyPos.MaxForce = Vector3.new(0, 1e6, 0)
                    bodyPos.Position = Vector3.new(primary.Position.X, getgenv().BoatHeight, primary.Position.Z)
                    bodyPos.Parent = primary
                    
                    if getgenv().AutoSailing then
                        local linVel = primary:FindFirstChild("VX_Vel") or Instance.new("LinearVelocity")
                        local attachment = primary:FindFirstChild("RootAttachment") or Instance.new("Attachment", primary)
                        
                        local direction = (OpenSeaTarget - primary.Position).Unit
                        linVel.Name = "VX_Vel"
                        linVel.MaxForce = 1e6
                        linVel.VectorVelocity = Vector3.new(direction.X, 0, direction.Z).Unit * getgenv().BoatSpeed
                        linVel.Attachment0 = attachment
                        linVel.Parent = primary
                        
                        primary.CFrame = CFrame.new(primary.Position, primary.Position + Vector3.new(direction.X, 0, direction.Z))
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
