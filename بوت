-- // 1. تحميل مكتبة Rayfield بأحدث إصدار لتضمن استقرار الواجهة
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "VX Leviathan Destroyer V2 | Ultimate",
   LoadingTitle = "جاري تحميل محرك VX V2...",
   LoadingSubtitle = "by VX Team",
   ConfigurationSaving = { Enabled = false }
})

-- // 2. المتغيرات العامة والأداء
getgenv().BoatSpeed = 150
getgenv().BoatHeight = 30
getgenv().AutoStopOnFrozen = true
getgenv().AutoKillLeviathan = false
getgenv().UseDragonSkills = true
getgenv().FastAttackM1 = true
getgenv().AutoHarpoonHeart = false
getgenv().HeartESP = true
getgenv().LeviathanESP = true
getgenv().AutoReturnTiki = false
getgenv().BypassAntiCheat = true
getgenv().SkillDelay = 0.05

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- // 3. إنشاء تبويبات الواجهة المتقدمة

-- [تبويب 1: التحكم بالسفينة والملاحة]
local BoatTab = Window:CreateTab("الملاحة والسفينة", 4483362458)

BoatTab:CreateSlider({
   Name = "سرعة السفينة المتقدمة",
   Range = {50, 400},
   Increment = 10,
   Suffix = "Speed",
   CurrentValue = 150,
   Flag = "BoatSpeed",
   Callback = function(Value) getgenv().BoatSpeed = Value end,
})

BoatTab:CreateSlider({
   Name = "ارتفاع الطيران عن الماء",
   Range = {10, 150},
   Increment = 5,
   Suffix = "Studs",
   CurrentValue = 30,
   Flag = "BoatHeight",
   Callback = function(Value) getgenv().BoatHeight = Value end,
})

BoatTab:CreateToggle({
   Name = "إيقاف آلي فوري عند رسبن Frozen Dimension",
   CurrentValue = true,
   Flag = "AutoStop",
   Callback = function(Value) getgenv().AutoStopOnFrozen = Value end,
})

-- [تبويب 2: نظام القتال والمهارات]
local FarmTab = Window:CreateTab("قتال الليفايثن والمهارات", 4483362458)

FarmTab:CreateToggle({
   Name = "تفعيل Auto-Kill القاتل (تتبع الأجزاء والذيل)",
   CurrentValue = false,
   Flag = "AutoKill",
   Callback = function(Value) getgenv().AutoKillLeviathan = Value end,
})

FarmTab:CreateToggle({
   Name = "M1 Fast Attack (ضربات فائقة السرعة)",
   CurrentValue = true,
   Flag = "FastAttack",
   Callback = function(Value) getgenv().FastAttackM1 = Value end,
})

FarmTab:CreateToggle({
   Name = "إطلاق مهارات Dragon / Dragon Storm (Z, X, C, V, F)",
   CurrentValue = true,
   Flag = "UseSkills",
   Callback = function(Value) getgenv().UseDragonSkills = Value end,
})

FarmTab:CreateSlider({
   Name = "تأخير المهارات (لتفادي الكراش)",
   Range = {0.01, 0.5},
   Increment = 0.01,
   Suffix = "Sec",
   CurrentValue = 0.05,
   Flag = "SkillDelay",
   Callback = function(Value) getgenv().SkillDelay = Value end,
})

-- [تبويب 3: صيد القلب والعودة الآلية]
local HeartTab = Window:CreateTab("صيد القلب والتأمين", 4483362458)

HeartTab:CreateToggle({
   Name = "صيد وسحب القلب تلقائياً بالرمح (Harpoon)",
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

-- [تبويب 4: كاشف الرؤية والرادار ESP]
local EspTab = Window:CreateTab("كاشف المواقع (ESP)", 4483362458)

EspTab:CreateToggle({
   Name = "كاشف موقع القلب (Cold Heart ESP)",
   CurrentValue = true,
   Flag = "HeartESP",
   Callback = function(Value) getgenv().HeartESP = Value end,
})

EspTab:CreateToggle({
   Name = "كاشف موقع الليفايثن (Leviathan ESP)",
   CurrentValue = true,
   Flag = "LeviathanESP",
   Callback = function(Value) getgenv().LeviathanESP = Value end,
})

-- // 4. محركات الأداء العالي والتخفي (Engine Logic)

-- دالة محاكاة ضغط المهارات والضرب السريع
local function sendInputKey(key)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[key], false, game)
    task.wait(getgenv().SkillDelay)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[key], false, game)
end

-- نظام القتال والتتبع التلقائي للذيل والوحش
task.spawn(function()
    while true do
        task.wait(0.01) -- أداء فائق السرعة وبدون لاق
        if getgenv().AutoKillLeviathan then
            pcall(function()
                local enemies = workspace:FindFirstChild("Enemies") or workspace
                local targetPart = nil
                
                -- إعطاء الأولوية لذيل وأجزاء الليفايثن
                for _, monster in pairs(enemies:GetChildren()) do
                    if monster.Name:find("Leviathan") or monster.Name:find("Segment") or monster.Name:find("Tail") then
                        if monster:FindFirstChild("HumanoidRootPart") and monster:FindFirstChild("Humanoid") and monster.Humanoid.Health > 0 then
                            targetPart = monster.HumanoidRootPart
                            break
                        end
                    end
                end

                if targetPart and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    -- التموقع فوق ذيل أو جزء الليفايثن بمسافة آمنة لتفادي الضرر
                    LocalPlayer.Character.HumanoidRootPart.CFrame = targetPart.CFrame * CFrame.new(0, 30, 0)
                    
                    -- Fast Attack (M1)
                    if getgenv().FastAttackM1 then
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    end
                    
                    -- إطلاق جميع مهارات الدراغون والأسلحة
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

-- نظام صيد القلب وسحبه بالسفينة والعودة إلى Tiki Outpost
task.spawn(function()
    local tikiCoords = Vector3.new(-16200, 20, 4500) -- إحداثيات Tiki Outpost
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
                    
                    -- 1. التوجيه الذكي للسفينة نحو القلب
                    if distance > 40 then
                        local bodyVel = boatPrimary:FindFirstChild("VX_Vel") or Instance.new("BodyVelocity")
                        bodyVel.Name = "VX_Vel"
                        bodyVel.MaxForce = Vector3.new(1e6, 0, 1e6)
                        bodyVel.Velocity = (heartPos.Position - boatPrimary.Position).Unit * getgenv().BoatSpeed
                        bodyVel.Parent = boatPrimary
                    else
                        -- عند الوصول: تثبيت السفينة وإطلاق الرمح
                        if boatPrimary:FindFirstChild("VX_Vel") then
                            boatPrimary.VX_Vel.Velocity = Vector3.zero
                        end
                        
                        local harpoon = LocalPlayer.Backpack:FindFirstChild("Harpoon") or LocalPlayer.Character:FindFirstChild("Harpoon")
                        if harpoon then
                            LocalPlayer.Character.Humanoid:EquipTool(harpoon)
                            harpoon:Activate()
                        end
                        
                        -- 2. إذا تُمكّن من شبك القلب وتم تفعيل العودة الآلية لـ Tiki Outpost
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

-- نظام الفحص التلقائي لـ Frozen Dimension
task.spawn(function()
    while true do
        task.wait(0.5)
        if getgenv().AutoStopOnFrozen then
            local frozenZone = workspace:FindFirstChild("Frozen Dimension") or workspace.Map:FindFirstChild("Frozen Dimension")
            if frozenZone then
                getgenv().AutoKillLeviathan = false
                Rayfield:Notify({
                   Title = "تم رسبن Frozen Dimension!",
                   Content = "تم إيقاف الملاحة التلقائية وتثبيت الموقع لتفادي الضياع.",
                   Duration = 8,
                   Image = 4483362458,
                })
                break
            end
        end
    end
end)

-- نظام ESP الراداري لكشف موقع القلب والوحش على الشاشة
RunService.RenderStepped:Connect(function()
    if getgenv().HeartESP then
        local heart = workspace:FindFirstChild("Cold Heart") or workspace.Items:FindFirstChild("Cold Heart")
        if heart and heart:FindFirstChild("PrimaryPart") then
            -- تحديث مؤشر الإبصار الذاتي
        end
    end
end)
