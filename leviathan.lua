-- // 1. تحميل مكتبة Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "VX Universal Hub V8 | Open Sea Navigator",
   LoadingTitle = "جاري تحميل محرك الملاحة البحرية...",
   LoadingSubtitle = "by VX Team",
   ConfigurationSaving = { Enabled = false }
})

-- // 2. المتغيرات العامة
getgenv().BoatSpeed = 200
getgenv().BoatHeight = 35
getgenv().AutoSailing = false
getgenv().SelectedBoat = "Beast Hunter"
getgenv().KillAuraM1 = false
getgenv().KillAuraRange = 50
getgenv().AutoKillLeviathan = false
getgenv().UseDragonSkills = true
getgenv().AutoHarpoonHeart = false
getgenv().AutoReturnTiki = false

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- إحداثيات الاتجاه إلى البحر المفتوح العميق (Zone 6 / Leviathan Spawn Zone)
local OpenSeaTarget = Vector3.new(-28000, 35, -15000)

-- // 3. الزر الدائري لتخفيض وإظهار الواجهة
pcall(function()
    if CoreGui:FindFirstChild("VX_ToggleButton") then
        CoreGui.VX_ToggleButton:Destroy()
    end
end)

local ScreenGui = Instance.new("ScreenGui")
local ToggleBtn = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

ScreenGui.Name = "VX_ToggleButton"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Parent = ScreenGui
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleBtn.Position = UDim2.new(0.02, 0, 0.2, 0)
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.Text = "VX"
ToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 170)
ToggleBtn.TextSize = 20.0
ToggleBtn.Active = true
ToggleBtn.Draggable = true

UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = ToggleBtn

local guiVisible = true
ToggleBtn.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    if Rayfield and Rayfield.Main then
        Rayfield.Main.Visible = guiVisible
    end
end)

-- // 4. إنشـاء التبويبات المُنظمة

-- [تبويب الرئيسية]
local MainTab = Window:CreateTab("الرئيسية والإغلاق", 4483362458)

MainTab:CreateButton({
   Name = "إغلاق السكربت نهائياً (Destroy GUI)",
   Callback = function()
       getgenv().KillAuraM1 = false
       getgenv().AutoKillLeviathan = false
       getgenv().AutoSailing = false
       getgenv().AutoHarpoonHeart = false
       pcall(function() ScreenGui:Destroy() end)
       Rayfield:Destroy()
   end,
})

-- [تبويب قيادة وإبحار السفينة]
local BoatTab = Window:CreateTab("الملاحة والبحر المفتوح", 4483362458)

BoatTab:CreateDropdown({
   Name = "اختر نوع السفينة",
   Options = {"Beast Hunter", "Grand Brig", "Swamp Pirate", "Sloop"},
   CurrentOption = {"Beast Hunter"},
   Flag = "BoatType",
   Callback = function(Option)
       getgenv().SelectedBoat = typeof(Option) == "table" and Option[1] or Option
   end,
})

BoatTab:CreateButton({
   Name = "شراء وركوب السفينة تلقائياً",
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
   end,
})

BoatTab:CreateToggle({
   Name = "الإبحار التلقائي إلى البحر المفتوح (Auto Sail Outer Sea)",
   CurrentValue = false,
   Flag = "AutoSailing",
   Callback = function(Value) getgenv().AutoSailing = Value end,
})

BoatTab:CreateSlider({
   Name = "سرعة إبحار السفينة",
   Range = {50, 500},
   Increment = 10,
   Suffix = "Speed",
   CurrentValue = 200,
   Flag = "BoatSpeed",
   Callback = function(Value) getgenv().BoatSpeed = Value end,
})

BoatTab:CreateSlider({
   Name = "ارتفاع الطيران عن الماء",
   Range = {0, 150},
   Increment = 5,
   Suffix = "Studs",
   CurrentValue = 35,
   Flag = "BoatHeight",
   Callback = function(Value) getgenv().BoatHeight = Value end,
})

-- [تبويب القتال الحر Kill Aura]
local AttackTab = Window:CreateTab("القتال الحر (Kill Aura)", 4483362458)

AttackTab:CreateToggle({
   Name = "تفعيل Kill Aura M1 (حرية حركة مطلقة)",
   CurrentValue = false,
   Flag = "KillAura",
   Callback = function(Value) getgenv().KillAuraM1 = Value end,
})

AttackTab:CreateSlider({
   Name = "مدى الهجوم الخارجي (Aura Range)",
   Range = {20, 150},
   Increment = 5,
   Suffix = "Studs",
   CurrentValue = 50,
   Flag = "AuraRange",
   Callback = function(Value) getgenv().KillAuraRange = Value end,
})

AttackTab:CreateToggle({
   Name = "تفعيل تتبع وقتل الليفايثن (Auto Kill)",
   CurrentValue = false,
   Flag = "AutoKill",
   Callback = function(Value) getgenv().AutoKillLeviathan = Value end,
})

AttackTab:CreateToggle({
   Name = "إطلاق مهارات Dragon / Dragon Storm تلقائياً",
   CurrentValue = true,
   Flag = "UseSkills",
   Callback = function(Value) getgenv().UseDragonSkills = Value end,
})

-- [تبويب صيد وتأمين القلب]
local HeartTab = Window:CreateTab("صيد القلب والتأمين", 4483362458)

HeartTab:CreateToggle({
   Name = "صيد وسحب القلب تلقائياً (Auto Catch)",
   CurrentValue = false,
   Flag = "AutoCatchHeart",
   Callback = function(Value) getgenv().AutoHarpoonHeart = Value end,
})

HeartTab:CreateToggle({
   Name = "العودة بالقلب تلقائياً لـ Tiki Outpost",
   CurrentValue = false,
   Flag = "AutoReturnTiki",
   Callback = function(Value) getgenv().AutoReturnTiki = Value end,
})

-- // 5. المحركات والوظائف الخلفية

-- محرك الإبحار التلقائي باتجاه البحر المفتوح (Deep Ocean Direction)
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
                    
                    -- تثبيت الارتفاع
                    local bodyPos = primary:FindFirstChild("VX_Pos") or Instance.new("BodyPosition")
                    bodyPos.Name = "VX_Pos"
                    bodyPos.MaxForce = Vector3.new(0, 1e6, 0)
                    bodyPos.Position = Vector3.new(primary.Position.X, getgenv().BoatHeight, primary.Position.Z)
                    bodyPos.Parent = primary
                    
                    -- الإبحار التلقائي الموجه للبحر المفتوح
                    if getgenv().AutoSailing then
                        local linVel = primary:FindFirstChild("VX_Vel") or Instance.new("LinearVelocity")
                        local attachment = primary:FindFirstChild("RootAttachment") or Instance.new("Attachment", primary)
                        
                        -- حساب اتجاه البحر المفتوح
                        local direction = (OpenSeaTarget - primary.Position).Unit
                        
                        linVel.Name = "VX_Vel"
                        linVel.MaxForce = 1e6
                        linVel.VectorVelocity = Vector3.new(direction.X, 0, direction.Z).Unit * getgenv().BoatSpeed
                        linVel.Attachment0 = attachment
                        linVel.Parent = primary
                        
                        -- توجيه المقدمة نحو البحر المفتوح
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

-- محرك Kill Aura M1
task.spawn(function()
    while true do
        task.wait(0.03)
        if getgenv().KillAuraM1 then
            pcall(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local myPos = char.HumanoidRootPart.Position
                    local enemies = workspace:FindFirstChild("Enemies") or workspace
                    
                    for _, enemy in pairs(enemies:GetChildren()) do
                        if enemy:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                            local dist = (enemy.HumanoidRootPart.Position - myPos).Magnitude
                            if dist <= getgenv().KillAuraRange then
                                local tool = char:FindFirstChildOfClass("Tool")
                                if tool then
                                    tool:Activate()
                                end
                                break
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- محرك تتبع وقتل الليفايثن والمهارات
task.spawn(function()
    while true do
        task.wait(0.05)
        if getgenv().AutoKillLeviathan then
            pcall(function()
                local enemies = workspace:FindFirstChild("Enemies") or workspace
                local targetPart = nil
                
                for _, monster in pairs(enemies:GetChildren()) do
                    if monster.Name:find("Leviathan") or monster.Name:find("Segment") or monster.Name:find("Tail") then
                        if monster:FindFirstChild("HumanoidRootPart") and monster:FindFirstChild("Humanoid") and monster.Humanoid.Health > 0 then
                            targetPart = monster.HumanoidRootPart
                            break
                        end
                    end
                end

                if targetPart and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = targetPart.CFrame * CFrame.new(0, 28, 0)
                    
                    if getgenv().UseDragonSkills then
                        local keys = {"Z", "X", "C", "V", "F"}
                        for _, key in ipairs(keys) do
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[key], false, game)
                            task.wait(0.01)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[key], false, game)
                        end
                    end
                end
            end)
        end
    end
end)

-- محرك صيد القلب والعودة لـ Tiki Outpost
task.spawn(function()
    local tikiCoords = Vector3.new(-16200, 20, 4500)
    while true do
        task.wait(0.1)
        if getgenv().AutoHarpoonHeart then
            pcall(function()
                local heartModel = workspace:FindFirstChild("Cold Heart") or workspace.Items:FindFirstChild("Cold Heart")
                local myBoat = LocalPlayer.Character and LocalPlayer.Character.Humanoid.SeatPart and LocalPlayer.Character.Humanoid.SeatPart.Parent
                
                if heartModel and myBoat then
                    local heartPos = heartModel.PrimaryPart and heartModel.PrimaryPart.CFrame or heartModel:GetPivot()
                    local boatPrimary = myBoat.PrimaryPart
                    local distance = (boatPrimary.Position - heartPos.Position).Magnitude
                    
                    if distance > 40 then
                        local linVel = boatPrimary:FindFirstChild("VX_Vel") or Instance.new("LinearVelocity")
                        local attachment = boatPrimary:FindFirstChild("RootAttachment") or Instance.new("Attachment", boatPrimary)
                        
                        linVel.Name = "VX_Vel"
                        linVel.MaxForce = 1e6
                        linVel.VectorVelocity = (heartPos.Position - boatPrimary.Position).Unit * getgenv().BoatSpeed
                        linVel.Attachment0 = attachment
                        linVel.Parent = boatPrimary
                    else
                        if boatPrimary:FindFirstChild("VX_Vel") then
                            boatPrimary.VX_Vel.VectorVelocity = Vector3.zero
                        end
                        
                        local harpoon = LocalPlayer.Backpack:FindFirstChild("Harpoon") or LocalPlayer.Character:FindFirstChild("Harpoon")
                        if harpoon then
                            LocalPlayer.Character.Humanoid:EquipTool(harpoon)
                            harpoon:Activate()
                        end
                        
                        if getgenv().AutoReturnTiki then
                            task.wait(1)
                            local linVel = boatPrimary:FindFirstChild("VX_Vel")
                            if linVel then
                                linVel.VectorVelocity = (tikiCoords - boatPrimary.Position).Unit * getgenv().BoatSpeed
                            end
                        end
                    end
                end
            end)
        end
    end
end)
