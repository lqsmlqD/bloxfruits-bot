-- // 1. تحميل مكتبة Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "VX Leviathan Overlord V3 | Ultimate",
   LoadingTitle = "جاري تحميل محرك القوة...",
   LoadingSubtitle = "by VX Team",
   ConfigurationSaving = { Enabled = false }
})

-- // 2. المتغيرات العامة
getgenv().BoatSpeed = 180
getgenv().BoatHeight = 35
getgenv().AutoBuyBoat = false
getgenv().SelectedBoat = "Beast Hunter"
getgenv().AutoStopOnFrozen = true
getgenv().AutoKillLeviathan = false
getgenv().UseDragonSkills = true
getgenv().UltraFastM1 = false
getgenv().AutoHarpoonHeart = false
getgenv().AutoReturnTiki = false

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- // 3. إنشـاء الواجهة والتصنيفات

-- [تبويب إدارة السفن والملاحة]
local BoatTab = Window:CreateTab("إدارة السفن والملاحة", 4483362458)

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
   Name = "شراء وقيادة السفينة تلقائياً الآن",
   Callback = function()
       pcall(function()
           -- استدعاء ريموت شراء السفينة
           local comms = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
           if comms then
               comms:InvokeServer("BuyBoat", getgenv().SelectedBoat)
               task.wait(0.5)
               -- البحث عن السفينة والجلوس بها
               for _, boat in pairs(workspace.Boats:GetChildren()) do
                   if boat:FindFirstChild("Owner") and boat.Owner.Value == LocalPlayer then
                       if boat:FindFirstChild("VehicleSeat") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                           LocalPlayer.Character.HumanoidRootPart.CFrame = boat.VehicleSeat.CFrame
                       end
                   end
               end
           end
       end)
   end,
})

BoatTab:CreateSlider({
   Name = "سرعة طيران السفينة (سلسة بدون لاق)",
   Range = {50, 450},
   Increment = 10,
   Suffix = "Speed",
   CurrentValue = 180,
   Flag = "BoatSpeed",
   Callback = function(Value) getgenv().BoatSpeed = Value end,
})

BoatTab:CreateToggle({
   Name = "إيقاف الحركة عند رسبن Frozen Dimension",
   CurrentValue = true,
   Flag = "AutoStop",
   Callback = function(Value) getgenv().AutoStopOnFrozen = Value end,
})

-- [تبويب الهجوم الخارق والمهارات]
local AttackTab = Window:CreateTab("نظام القتال والسلاح", 4483362458)

AttackTab:CreateToggle({
   Name = "تفعيل قتل الليفايثن والذيل تلقائياً (Auto Kill)",
   CurrentValue = false,
   Flag = "AutoKill",
   Callback = function(Value) getgenv().AutoKillLeviathan = Value end,
})

AttackTab:CreateToggle({
   Name = "Fast Attack خفيف بدون لاق (ملاحة بحرية وسريعة)",
   CurrentValue = false,
   Flag = "UltraFastM1",
   Callback = function(Value) getgenv().UltraFastM1 = Value end,
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

-- // 4. المحركات المتقدمة (Lightweight Engines)

-- محرك Fast Attack الخفيف بدون تقطيع أو اللاق
task.spawn(function()
    while true do
        task.wait(0.03) -- سرعة متوافقة تجنب طرد الـ Anti-Cheat
        if getgenv().UltraFastM1 then
            pcall(function()
                local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool then
                    tool:Activate()
                end
            end)
        end
    end
end)

-- محرك القتال والتمركز الذكي فوق أجزاء وذيل الليفايثن
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
                    -- الوقوف بمسافة آمنة لتفادي الضرر وتسهيل إصابة المهارات
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

-- محرك صيد وسحب القلب والعودة الآلية لـ Tiki
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
                        local linVel = boatPrimary:FindFirstChild("VX_Velocity") or Instance.new("LinearVelocity")
                        local attachment = boatPrimary:FindFirstChild("RootAttachment") or Instance.new("Attachment", boatPrimary)
                        
                        linVel.Name = "VX_Velocity"
                        linVel.MaxForce = 1e6
                        linVel.VectorVelocity = (heartPos.Position - boatPrimary.Position).Unit * getgenv().BoatSpeed
                        linVel.Attachment0 = attachment
                        linVel.Parent = boatPrimary
                    else
                        if boatPrimary:FindFirstChild("VX_Velocity") then
                            boatPrimary.VX_Velocity.VectorVelocity = Vector3.zero
                        end
                        
                        local harpoon = LocalPlayer.Backpack:FindFirstChild("Harpoon") or LocalPlayer.Character:FindFirstChild("Harpoon")
                        if harpoon then
                            LocalPlayer.Character.Humanoid:EquipTool(harpoon)
                            harpoon:Activate()
                        end
                        
                        if getgenv().AutoReturnTiki then
                            task.wait(1)
                            local linVel = boatPrimary:FindFirstChild("VX_Velocity")
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

-- كاشف وإيقاف Frozen Dimension
task.spawn(function()
    while true do
        task.wait(0.5)
        if getgenv().AutoStopOnFrozen then
            local frozenZone = workspace:FindFirstChild("Frozen Dimension") or workspace.Map:FindFirstChild("Frozen Dimension")
            if frozenZone then
                getgenv().AutoKillLeviathan = false
                Rayfield:Notify({
                   Title = "تم اكتشاف Frozen Dimension!",
                   Content = "تم إيقاف الملاحة التلقائية وتأمين الموقع.",
                   Duration = 6,
                   Image = 4483362458,
                })
                break
            end
        end
    end
end)
