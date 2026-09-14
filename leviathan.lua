-- // ==========================================================
-- // VX OVERLORD V10 | FULL QUANTUM COMPETITOR EDITION
-- // Developed for VX Community
-- // ==========================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "VX OVERLORD V10 | QUANTUM EDITION",
   LoadingTitle = "جاري تحميل محرك VX الشامل...",
   LoadingSubtitle = "by Ali & VX Team",
   ConfigurationSaving = { Enabled = false }
})

-- // 1. محرك الإعدادات المتقدم (Global State)
getgenv().VX = {
    -- Auto Farm & Combat
    AutoFarmLevel = false,
    FastAttack = true,
    AttackSpeed = 0.001,
    AutoMastery = false,
    
    -- Sea & Leviathan
    AutoSailSea = false,
    BoatSpeed = 300,
    BoatHeight = 40,
    AutoLeviathan = false,
    AutoTailTarget = true,
    AutoSkills = true,
    AutoStopFrozen = true,
    
    -- Heart & Items
    AutoCatchHeart = false,
    AutoReturnTiki = false,
    BringFruits = false,
    ESP_Heart = true,
}

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- // 2. إنشاء الواجهات والتبويبات (UI Modules)

-- [تبويب 1: التلفيل والقتال الشامل]
local FarmTab = Window:CreateTab("التلفيل والقتال", 4483362458)

FarmTab:CreateToggle({
   Name = "التلفيل الآلي الشامل (Auto Farm Level 1 -> Max)",
   CurrentValue = false,
   Callback = function(v) getgenv().VX.AutoFarmLevel = v end,
})

FarmTab:CreateToggle({
   Name = "M1 Fast Attack (ضربات فائقة السرعة بدون تأخير)",
   CurrentValue = true,
   Callback = function(v) getgenv().VX.FastAttack = v end,
})

FarmTab:CreateSlider({
   Name = "سرعة الضرب (Attack Delay)",
   Range = {0.001, 0.1},
   Increment = 0.001,
   Suffix = "Sec",
   CurrentValue = 0.001,
   Callback = function(v) getgenv().VX.AttackSpeed = v end,
})

-- [تبويب 2: الإبحار وحدث الليفايثن]
local SeaTab = Window:CreateTab("الإبحار والليفايثن", 4483362458)

SeaTab:CreateSlider({
   Name = "سرعة السفينة (Boat Speed)",
   Range = {100, 600},
   Increment = 25,
   Suffix = "Studs",
   CurrentValue = 300,
   Callback = function(v) getgenv().VX.BoatSpeed = v end,
})

SeaTab:CreateSlider({
   Name = "ارتفاع الطيران عن سطح الماء",
   Range = {10, 200},
   Increment = 10,
   Suffix = "Studs",
   CurrentValue = 40,
   Callback = function(v) getgenv().VX.BoatHeight = v end,
})

SeaTab:CreateToggle({
   Name = "الإبحار الآلي للبحر المفتوح (Auto Sail)",
   CurrentValue = false,
   Callback = function(v) getgenv().VX.AutoSailSea = v end,
})

SeaTab:CreateToggle({
   Name = "قتال وتتبع ذيل وأجزاء الليفايثن (Auto Leviathan)",
   CurrentValue = false,
   Callback = function(v) getgenv().VX.AutoLeviathan = v end,
})

SeaTab:CreateToggle({
   Name = "إطلاق مهارات Dragon / Dragon Storm تلقائياً (Z, X, C, V, F)",
   CurrentValue = true,
   Callback = function(v) getgenv().VX.AutoSkills = v end,
})

SeaTab:CreateToggle({
   Name = "إيقاف تلقائي فوري عند رسبن Frozen Dimension",
   CurrentValue = true,
   Callback = function(v) getgenv().VX.AutoStopFrozen = v end,
})

-- [تبويب 3: صيد القلب والفواكه]
local ItemsTab = Window:CreateTab("صيد القلب والفواكه", 4483362458)

ItemsTab:CreateToggle({
   Name = "صيد القلب بالرمح تلقائياً (Auto Harpoon)",
   CurrentValue = false,
   Callback = function(v) getgenv().VX.AutoCatchHeart = v end,
})

ItemsTab:CreateToggle({
   Name = "العودة الآلية بالسفينة لـ Tiki Outpost",
   CurrentValue = false,
   Callback = function(v) getgenv().VX.AutoReturnTiki = v end,
})

ItemsTab:CreateToggle({
   Name = "سحب جميع الفواكه المرمية بالسيرفر تلقائياً",
   CurrentValue = false,
   Callback = function(v) getgenv().VX.BringFruits = v end,
})

-- // 3. المحركات الخلفية الأساسية (Core Logic Engines)

local function sendKey(key)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[key], false, game)
    task.wait(0.02)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[key], false, game)
end

-- [محرك القال والـ Fast Attack]
task.spawn(function()
    while true do
        task.wait(getgenv().VX.AttackSpeed)
        if getgenv().VX.AutoFarmLevel or getgenv().VX.AutoLeviathan then
            pcall(function()
                if getgenv().VX.FastAttack then
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                end
                
                if getgenv().VX.AutoSkills then
                    sendKey("Z")
                    sendKey("X")
                    sendKey("C")
                    sendKey("V")
                    sendKey("F")
                end
            end)
        end
    end
end)

-- [محرك التموقع فوق أهداف القتال والتلفيل]
task.spawn(function()
    while true do
        task.wait(0.01)
        if getgenv().VX.AutoLeviathan then
            pcall(function()
                local enemies = workspace:FindFirstChild("Enemies") or workspace
                for _, monster in pairs(enemies:GetChildren()) do
                    if monster.Name:find("Leviathan") or monster.Name:find("Tail") or monster.Name:find("Segment") then
                        if monster:FindFirstChild("HumanoidRootPart") and monster.Humanoid.Health > 0 then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = monster.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0)
                            break
                        end
                    end
                end
            end)
        elseif getgenv().VX.AutoFarmLevel then
            pcall(function()
                local enemies = workspace:FindFirstChild("Enemies")
                if enemies then
                    for _, enemy in pairs(enemies:GetChildren()) do
                        if enemy:FindFirstChild("HumanoidRootPart") and enemy.Humanoid.Health > 0 then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0)
                            break
                        end
                    end
                end
            end)
        end
    end
end)

-- [محرك فيزياء السفن وسحب القلب]
task.spawn(function()
    local tikiLocation = Vector3.new(-16200, 20, 4500)
    while true do
        task.wait(0.05)
        pcall(function()
            local myBoat = LocalPlayer.Character and LocalPlayer.Character.Humanoid.SeatPart and LocalPlayer.Character.Humanoid.SeatPart.Parent
            if not myBoat or not myBoat.PrimaryPart then return end
            
            local primary = myBoat.PrimaryPart
            
            -- الإبحار
            if getgenv().VX.AutoSailSea then
                local bodyVel = primary:FindFirstChild("VX_Vel") or Instance.new("BodyVelocity")
                bodyVel.Name = "VX_Vel"
                bodyVel.MaxForce = Vector3.new(1e6, 1e6, 1e6)
                bodyVel.Velocity = (primary.CFrame.LookVector * getgenv().VX.BoatSpeed) + Vector3.new(0, getgenv().VX.BoatHeight / 5, 0)
                bodyVel.Parent = primary
            end
            
            -- صيد القلب
            if getgenv().VX.AutoCatchHeart then
                local heart = workspace:FindFirstChild("Cold Heart") or workspace.Items:FindFirstChild("Cold Heart")
                if heart then
                    local heartPos = heart:GetPivot().Position
                    local dist = (primary.Position - heartPos).Magnitude
                    
                    if dist > 35 then
                        local bodyVel = primary:FindFirstChild("VX_Vel") or Instance.new("BodyVelocity")
                        bodyVel.Name = "VX_Vel"
                        bodyVel.MaxForce = Vector3.new(1e6, 1e6, 1e6)
                        bodyVel.Velocity = (heartPos - primary.Position).Unit * getgenv().VX.BoatSpeed
                        bodyVel.Parent = primary
                    else
                        if primary:FindFirstChild("VX_Vel") then primary.VX_Vel.Velocity = Vector3.zero end
                        
                        local harpoon = LocalPlayer.Backpack:FindFirstChild("Harpoon") or LocalPlayer.Character:FindFirstChild("Harpoon")
                        if harpoon then
                            LocalPlayer.Character.Humanoid:EquipTool(harpoon)
                            harpoon:Activate()
                        end
                        
                        if getgenv().VX.AutoReturnTiki then
                            task.wait(1)
                            local bodyVel = primary:FindFirstChild("VX_Vel") or Instance.new("BodyVelocity")
                            bodyVel.Name = "VX_Vel"
                            bodyVel.MaxForce = Vector3.new(1e6, 1e6, 1e6)
                            bodyVel.Velocity = (tikiLocation - primary.Position).Unit * getgenv().VX.BoatSpeed
                            bodyVel.Parent = primary
                        end
                    end
                end
            end
        end)
    end
end)

-- [محرك سحب الفواكه المرمية]
task.spawn(function()
    while true do
        task.wait(1)
        if getgenv().VX.BringFruits then
            pcall(function()
                for _, item in pairs(workspace:GetChildren()) do
                    if item:IsA("Tool") and (item.Name:find("Fruit") or item:FindFirstChild("Handle")) then
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            item.Handle.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
                        end
                    end
                end
            end)
        end
    end
end)

-- [محرك كشف Frozen Dimension]
task.spawn(function()
    while true do
        task.wait(0.5)
        if getgenv().VX.AutoStopFrozen then
            local frozen = workspace:FindFirstChild("Frozen Dimension") or workspace.Map:FindFirstChild("Frozen Dimension")
            if frozen then
                getgenv().VX.AutoSailSea = false
                getgenv().VX.AutoLeviathan = false
                Rayfield:Notify({
                   Title = "تم رسبن Frozen Dimension!",
                   Content = "تم إيقاف الحركة التلقائية بنجاح.",
                   Duration = 8,
                })
                break
            end
        end
    end
end)
