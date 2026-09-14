-- // 1. تحميل مكتبة Kavo UI (المضمونة والمستقرة للهواتف)
local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Kavo.CreateLib("VX ABSOLUTE OVERLORD | V10 ULTIMATE", "DarkTheme")

-- // 2. المتغيرات العامة
getgenv().BoatSpeed = 150
getgenv().BoatHeight = 30
getgenv().AutoStopOnFrozen = true
getgenv().AutoKillLeviathan = false
getgenv().FastAttackM1 = true
getgenv().UseDragonSkills = true
getgenv().AutoHarpoonHeart = false
getgenv().AutoReturnTiki = false
getgenv().SkillDelay = 0.05
getgenv().KillAura = false

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- // 3. إنشاء التبويبات (Tabs)

-- [تبويب 1: الملاحة والسفينة]
local MainTab = Window:NewTab("الملاحة والسفينة")
local MainSection = MainTab:NewSection("إعدادات التحكم بالسفينة")

MainSection:NewSlider("سرعة السفينة (Boat Speed)", "ضبط السرعة", 400, 50, function(v)
    getgenv().BoatSpeed = v
end)

MainSection:NewSlider("ارتفاع الطيران عن الماء", "ضبط الارتفاع", 150, 10, function(v)
    getgenv().BoatHeight = v
end)

MainSection:NewToggle("إيقاف تلقائي عند Frozen Dimension", "التوقف الآلي", function(state)
    getgenv().AutoStopOnFrozen = state
end)

-- [تبويب 2: قتال الليفايثن والمهارات]
local FarmTab = Window:NewTab("قتال الليفايثن")
local FarmSection = FarmTab:NewSection("القتال التلقائي والمهارات")

FarmSection:NewToggle("تفعيل Kill Aura (ضرب أوتوماتيكي)", "ضرب مستمر", function(state)
    getgenv().KillAura = state
end)

FarmSection:NewToggle("قتال وتتبع الليفايثن والذيل", "Auto Leviathan", function(state)
    getgenv().AutoKillLeviathan = state
end)

FarmSection:NewToggle("M1 Fast Attack (ضربات فائقة السرعة)", "Fast Attack", function(state)
    getgenv().FastAttackM1 = state
end)

FarmSection:NewToggle("إطلاق مهارات Dragon (Z, X, C, V, F)", "المهارات التلقائية", function(state)
    getgenv().UseDragonSkills = state
end)

-- [تبويب 3: صيد القلب والعودة]
local HeartTab = Window:NewTab("صيد القلب والتأمين")
local HeartSection = HeartTab:NewSection("الرمح والعودة")

HeartSection:NewToggle("صيد وتأمين القلب بالرمح تلقائياً", "Auto Catch", function(state)
    getgenv().AutoHarpoonHeart = state
end)

HeartSection:NewToggle("العودة التلقائية بالقلب إلى Tiki Outpost", "العودة الآلية", function(state)
    getgenv().AutoReturnTiki = state
end)

-- // 4. المحركات والوظائف الخلفية (Engine Logic)

local function sendInputKey(key)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[key], false, game)
    task.wait(getgenv().SkillDelay)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[key], false, game)
end

-- حلقة الهجوم وتتبع الأجزاء
task.spawn(function()
    while true do
        task.wait(0.01)
        if getgenv().AutoKillLeviathan or getgenv().KillAura then
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
                    if getgenv().AutoKillLeviathan then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = targetPart.CFrame * CFrame.new(0, 30, 0)
                    end
                    
                    if getgenv().FastAttackM1 then
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    end
                    
                    if getgenv().UseDragonSkills then
                        sendInputKey("Z")
                        sendInputKey("X")
                        sendInputKey("C")
                        sendInputKey("V")
                        sendInputKey("F")
                    end
                end
            end)
        end
    end
end)

-- حلقة صيد القلب وسحبه بالسفينة
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

-- حلقة التوقف عند البعد المتجمد
task.spawn(function()
    while true do
        task.wait(0.5)
        if getgenv().AutoStopOnFrozen then
            local frozenZone = workspace:FindFirstChild("Frozen Dimension") or workspace.Map:FindFirstChild("Frozen Dimension")
            if frozenZone then
                getgenv().AutoKillLeviathan = false
                break
            end
        end
    end
end)
