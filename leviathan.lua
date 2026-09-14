-- // 1. تحميل مكتبة Rayfield الشاملة
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "VX Universal Hub V4 | Blox Fruits",
   LoadingTitle = "جاري تحميل محرك VX الخارق...",
   LoadingSubtitle = "by VX Team",
   ConfigurationSaving = { Enabled = false }
})

-- // 2. المتغيرات العامة (Global Settings)
getgenv().AutoFarmLevel = false
getgenv().BringMobs = true
getgenv().FastAttackM1 = true
getgenv().AutoStoreFruit = true
getgenv().AutoRandomFruit = false

getgenv().BoatSpeed = 200
getgenv().SelectedBoat = "Beast Hunter"
getgenv().AutoKillLeviathan = false
getgenv().UseDragonSkills = true
getgenv().AutoHarpoonHeart = false
getgenv().AutoReturnTiki = false

getgenv().FruitESP = false
getgenv().PlayerESP = false

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

-- // 3. إنشاء تبويبات الواجهة الشاملة

-- [تبويب 1: التجميع التلقائي واللفل]
local FarmTab = Window:CreateTab("التجميع واللفل", 4483362458)

FarmTab:CreateToggle({
   Name = "تفعيل التجميع التلقائي للـ Level (Auto Farm)",
   CurrentValue = false,
   Flag = "AutoFarmLevel",
   Callback = function(Value) getgenv().AutoFarmLevel = Value end,
})

FarmTab:CreateToggle({
   Name = "تجميع الوحوش في نقطة واحدة (Bring Mobs)",
   CurrentValue = true,
   Flag = "BringMobs",
   Callback = function(Value) getgenv().BringMobs = Value end,
})

FarmTab:CreateToggle({
   Name = "Fast Attack خارق بدون أنيميشن (M1)",
   CurrentValue = true,
   Flag = "FastAttack",
   Callback = function(Value) getgenv().FastAttackM1 = Value end,
})

-- [تبويب 2: حدث الليفايثن والصيد]
local LeviTab = Window:CreateTab("قتال الليفايثن والصيد", 4483362458)

LeviTab:CreateDropdown({
   Name = "اختر السفينة",
   Options = {"Beast Hunter", "Grand Brig", "Swamp Pirate"},
   CurrentOption = {"Beast Hunter"},
   Flag = "BoatType",
   Callback = function(Option) getgenv().SelectedBoat = typeof(Option) == "table" and Option[1] or Option end,
})

LeviTab:CreateButton({
   Name = "شراء وقيادة السفينة فوراً",
   Callback = function()
       pcall(function()
           local comms = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
           if comms then
               comms:InvokeServer("BuyBoat", getgenv().SelectedBoat)
               task.wait(0.5)
               for _, boat in pairs(workspace.Boats:GetChildren()) do
                   if boat:FindFirstChild("Owner") and boat.Owner.Value == LocalPlayer then
                       if boat:FindFirstChild("VehicleSeat") and LocalPlayer.Character then
                           LocalPlayer.Character.HumanoidRootPart.CFrame = boat.VehicleSeat.CFrame
                       end
                   end
               end
           end
       end)
   end,
})

LeviTab:CreateToggle({
   Name = "تفعيل قتال وتتبع ذيل الليفايثن (Auto Kill)",
   CurrentValue = false,
   Flag = "AutoKillLevi",
   Callback = function(Value) getgenv().AutoKillLeviathan = Value end,
})

LeviTab:CreateToggle({
   Name = "إطلاق مهارات Dragon / Dragon Storm تلقائياً",
   CurrentValue = true,
   Flag = "UseDragonSkills",
   Callback = function(Value) getgenv().UseDragonSkills = Value end,
})

LeviTab:CreateToggle({
   Name = "صيد وسحب القلب تلقائياً بالرمح",
   CurrentValue = false,
   Flag = "AutoCatchHeart",
   Callback = function(Value) getgenv().AutoHarpoonHeart = Value end,
})

LeviTab:CreateToggle({
   Name = "العودة بالقلب تلقائياً لـ Tiki Outpost",
   CurrentValue = false,
   Flag = "AutoReturnTiki",
   Callback = function(Value) getgenv().AutoReturnTiki = Value end,
})

-- [تبويب 3: الفواكه والأسلحة]
local FruitTab = Window:CreateTab("الفواكه والأسلحة", 4483362458)

FruitTab:CreateToggle({
   Name = "تخزين الفواكه آلياً في الشنطة (Auto Store)",
   CurrentValue = true,
   Flag = "AutoStore",
   Callback = function(Value) getgenv().AutoStoreFruit = Value end,
})

FruitTab:CreateToggle({
   Name = "شراء فاكهة عشوائية آلياً (Random Fruit)",
   CurrentValue = false,
   Flag = "RandomFruit",
   Callback = function(Value) getgenv().AutoRandomFruit = Value end,
})

-- [تبويب 4: الرادار والتنقل بين السيرفرات]
local MiscTab = Window:CreateTab("الرادار والسيرفرات", 4483362458)

MiscTab:CreateToggle({
   Name = "كاشف موقع الفواكه الساقطة (Fruit ESP)",
   CurrentValue = false,
   Flag = "FruitESP",
   Callback = function(Value) getgenv().FruitESP = Value end,
})

MiscTab:CreateButton({
   Name = "تغيير السيرفر فوراً (Server Hop)",
   Callback = function()
       TeleportService:Teleport(game.PlaceId, LocalPlayer)
   end,
})

-- // 4. المحركات والوظائف الشاملة (Universal Logic Engines)

-- محرك Fast Attack الخفيف السريع
task.spawn(function()
    while true do
        task.wait(0.02)
        if getgenv().FastAttackM1 then
            pcall(function()
                local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool then
                    tool:Activate()
                end
            end)
        end
    end
end)

-- محرك قتال الليفايثن وإطلاق المهارات
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

-- محرك إدارة وتخزين الفواكه
task.spawn(function()
    while true do
        task.wait(2)
        if getgenv().AutoStoreFruit then
            pcall(function()
                for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if tool.Name:find("Fruit") then
                        local comms = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
                        if comms then
                            comms:InvokeServer("StoreFruit", tool.Name, tool)
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
