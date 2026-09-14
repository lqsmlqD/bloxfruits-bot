-- // 1. تحميل مكتبة الواجهات Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "VX Leviathan Destroyer V2 | Fast Attack Edition",
   LoadingTitle = "جاري تحميل السكربت...",
   LoadingSubtitle = "by VX Team",
   ConfigurationSaving = { Enabled = false }
})

-- // 2. المتغيرات العامة
getgenv().BoatSpeed = 150
getgenv().BoatHeight = 30
getgenv().AutoStopOnFrozen = true
getgenv().AutoKillLeviathan = false
getgenv().UseDragonSkills = true
getgenv().SuperFastAttack = false -- زر ضربات M1 السريعة جداً
getgenv().AttackSpeedMulti = 5    -- عدد الضربات في الضغطة الواحدة
getgenv().AutoHarpoonHeart = false
getgenv().AutoReturnTiki = false

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- // 3. التبويبات والواجهة

local BoatTab = Window:CreateTab("الملاحة والسفينة", 4483362458)

BoatTab:CreateSlider({
   Name = "سرعة السفينة",
   Range = {50, 400},
   Increment = 10,
   Suffix = "Speed",
   CurrentValue = 150,
   Flag = "BoatSpeed",
   Callback = function(Value) getgenv().BoatSpeed = Value end,
})

BoatTab:CreateToggle({
   Name = "إيقاف تلقائي عند ظهور Frozen Dimension",
   CurrentValue = true,
   Flag = "AutoStop",
   Callback = function(Value) getgenv().AutoStopOnFrozen = Value end,
})

local FarmTab = Window:CreateTab("قتال الليفايثن والمهارات", 4483362458)

FarmTab:CreateToggle({
   Name = "تفعيل قتال الليفايثن (Auto Kill)",
   CurrentValue = false,
   Flag = "AutoKill",
   Callback = function(Value) getgenv().AutoKillLeviathan = Value end,
})

-- ZAR M1 FAST ATTACK (زر مخصص للضرب الخارق)
FarmTab:CreateToggle({
   Name = "تفعيل Fast Attack خارق وسريع جداً (M1)",
   CurrentValue = false,
   Flag = "SuperFastAttack",
   Callback = function(Value)
       getgenv().SuperFastAttack = Value
   end,
})

FarmTab:CreateSlider({
   Name = "كثافة الضربات في الكليك (Attack Multiplier)",
   Range = {1, 15},
   Increment = 1,
   Suffix = "Hits",
   CurrentValue = 5,
   Flag = "AttackMulti",
   Callback = function(Value) getgenv().AttackSpeedMulti = Value end,
})

FarmTab:CreateToggle({
   Name = "إطلاق مهارات Dragon / Dragon Storm (Z, X, C, V, F)",
   CurrentValue = true,
   Flag = "UseSkills",
   Callback = function(Value) getgenv().UseDragonSkills = Value end,
})

local HeartTab = Window:CreateTab("صيد القلب والتأمين", 4483362458)

HeartTab:CreateToggle({
   Name = "صيد وسحب القلب تلقائياً (Auto Catch Heart)",
   CurrentValue = false,
   Flag = "AutoCatchHeart",
   Callback = function(Value) getgenv().AutoHarpoonHeart = Value end,
})

HeartTab:CreateToggle({
   Name = "العودة التلقائية بالقلب إلى Tiki Outpost",
   CurrentValue = false,
   Flag = "AutoReturnTiki",
   Callback = function(Value) getgenv().AutoReturnTiki = Value end,
})

-- // 4. المحركات المتقدمة للضرب المباشر (Super Fast Attack Logic)

local function executeFastM1()
    for i = 1, getgenv().AttackSpeedMulti do
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    end
end

local function castSkill(key)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[key], false, game)
    task.wait(0.02)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[key], false, game)
end

-- حلقة ضربات Fast Attack المخصصة الخارقة
task.spawn(function()
    while true do
        task.wait() -- أسرع استجابة فريمات ممكبة
        if getgenv().SuperFastAttack then
            pcall(function()
                executeFastM1()
            end)
        end
    end
end)

-- حلقة القتال وتتبع ذيل الليفايثن
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
                    LocalPlayer.Character.HumanoidRootPart.CFrame = targetPart.CFrame * CFrame.new(0, 25, 0)
                    
                    if getgenv().UseDragonSkills then
                        castSkill("Z")
                        castSkill("X")
                        castSkill("C")
                        castSkill("V")
                        castSkill("F")
                    end
                end
            end)
        end
    end
end)

-- حلقة صيد القلب والتحرك بالسفينة
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
                        local bodyVel = boatPrimary:FindFirstChild("VX_Vel") or Instance.new("BodyVelocity")
                        bodyVel.Name = "VX_Vel"
                        bodyVel.MaxForce = Vector3.new(1e6, 0, 1e6)
                        bodyVel.Velocity = (heartPos.Position - boatPrimary.Position).Unit * getgenv().BoatSpeed
                        bodyVel.Parent = boatPrimary
                    else
                        if boatPrimary:FindFirstChild("VX_Vel") then
                            boatPrimary.VX_Vel.Velocity = Vector3.zero
                        end
                        
                        local harpoon = LocalPlayer.Backpack:FindFirstChild("Harpoon") or LocalPlayer.Character:FindFirstChild("Harpoon")
                        if harpoon then
                            LocalPlayer.Character.Humanoid:EquipTool(harpoon)
                            harpoon:Activate()
                        end
                        
                        if getgenv().AutoReturnTiki then
                            task.wait(1)
                            local bodyVel = boatPrimary:FindFirstChild("VX_Vel") or Instance.new("BodyVelocity")
                            bodyVel.Name = "VX_Vel"
                            bodyVel.MaxForce = Vector3.new(1e6, 0, 1e6)
                            bodyVel.Velocity = (tikiCoords - boatPrimary.Position).Unit * getgenv().BoatSpeed
                            bodyVel.Parent = boatPrimary
                        end
                    end
                end
            end)
        end
    end
end)

-- حلقة إيقاف الحركة عند البعد المتجمد
task.spawn(function()
    while true do
        task.wait(0.5)
        if getgenv().AutoStopOnFrozen then
            local frozenZone = workspace:FindFirstChild("Frozen Dimension") or workspace.Map:FindFirstChild("Frozen Dimension")
            if frozenZone then
                getgenv().AutoKillLeviathan = false
                Rayfield:Notify({
                   Title = "تم رسبن Frozen Dimension!",
                   Content = "تم إيقاف الملاحة والتتبع بنجاح.",
                   Duration = 6,
                   Image = 4483362458,
                })
                break
            end
        end
    end
end)
