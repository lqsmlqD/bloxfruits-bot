-- // ==========================================
-- // VX STEAL AN EGG | ULTIMATE GLASS HUB
-- // Developed for Ali & VX Community
-- // ==========================================

-- Cleanup old elements
if game:GetService("CoreGui"):FindFirstChild("VX_MainGui") then
    game:GetService("CoreGui").VX_MainGui:Destroy()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local LocalPlayer = Players.LocalPlayer

-- Global Configuration
getgenv().VX_Settings = {
    SpeedToggle = false,
    SpeedValue = 100,
    GodMode = true,
    AntiCage = true,
    InstantPick = true,
    ESP_Players = false,
    ESP_Eggs = false
}

-- ScreenGui Parent
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VX_MainGui"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

-- Floating Circle Button (VX)
local CircleBtn = Instance.new("TextButton")
CircleBtn.Name = "VX_CircleToggle"
CircleBtn.Parent = ScreenGui
CircleBtn.Size = UDim2.new(0, 50, 0, 50)
CircleBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
CircleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
CircleBtn.BorderColor3 = Color3.fromRGB(0, 255, 120)
CircleBtn.BorderSizePixel = 2
CircleBtn.Text = "VX"
CircleBtn.TextColor3 = Color3.fromRGB(0, 255, 120)
CircleBtn.TextSize = 20
CircleBtn.Font = Enum.Font.SourceSansBold
CircleBtn.Active = true
CircleBtn.Draggable = true

local CircleCorner = Instance.new("UICorner")
CircleCorner.CornerRadius = UDim2.new(1, 0)
CircleCorner.Parent = CircleBtn

-- Main Frame (Window)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 380, 0, 420)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 120)
MainFrame.BorderSizePixel = 1
MainFrame.Active = true
MainFrame.Draggable = true

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim2.new(0, 10)
FrameCorner.Parent = MainFrame

-- Title Header
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
Title.Text = "  VX HUB - STEAL AN EGG"
Title.TextColor3 = Color3.fromRGB(0, 255, 120)
Title.TextSize = 18
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim2.new(0, 10)
TitleCorner.Parent = Title

-- Container
local Container = Instance.new("ScrollingFrame")
Container.Parent = MainFrame
Container.Position = UDim2.new(0, 10, 0, 50)
Container.Size = UDim2.new(1, -20, 1, -60)
Container.BackgroundTransparency = 1
Container.ScrollBarThickness = 4
Container.CanvasSize = UDim2.new(0, 0, 0, 450)

local UIList = Instance.new("UIListLayout")
UIList.Parent = Container
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim2.new(0, 8)

-- Helper: Create Toggle Component
local function CreateToggle(text, default, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -5, 0, 40)
    btn.BackgroundColor3 = default and Color3.fromRGB(0, 100, 50) or Color3.fromRGB(30, 30, 35)
    btn.Text = "  " .. text .. ": " .. (default and "[ ON ]" or "[ OFF ]")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = Container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim2.new(0, 6)
    corner.Parent = btn

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 100, 50) or Color3.fromRGB(30, 30, 35)
        btn.Text = "  " .. text .. ": " .. (state and "[ ON ]" or "[ OFF ]")
        callback(state)
    end)
end

-- Helper: Create Speed Input
local function CreateSpeedInput()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -5, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    frame.Parent = Container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim2.new(0, 6)
    corner.Parent = frame

    local lbl = Instance.new("TextLabel")
    lbl.Parent = frame
    lbl.Size = UDim2.new(0.6, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "  حدد السرعة (0 - 1000):"
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 16
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local box = Instance.new("TextBox")
    box.Parent = frame
    box.Position = UDim2.new(0.65, 0, 0.15, 0)
    box.Size = UDim2.new(0.3, 0, 0.7, 0)
    box.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    box.Text = tostring(getgenv().VX_Settings.SpeedValue)
    box.TextColor3 = Color3.fromRGB(0, 255, 120)
    box.Font = Enum.Font.SourceSansBold
    box.TextSize = 16

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim2.new(0, 4)
    boxCorner.Parent = box

    box.FocusLost:Connect(function()
        local num = tonumber(box.Text)
        if num then
            getgenv().VX_Settings.SpeedValue = math.clamp(num, 0, 1000)
        else
            box.Text = tostring(getgenv().VX_Settings.SpeedValue)
        end
    end)
end

-- UI Controls Generation
CreateToggle("تفعيل السرعة المحددة", false, function(v) getgenv().VX_Settings.SpeedToggle = v end)
CreateSpeedInput()
CreateToggle("حماية البيض والشخصية (Godmode)", true, function(v) getgenv().VX_Settings.GodMode = v end)
CreateToggle("إلغاء أقفاص التجميد (Anti Cage)", true, function(v) getgenv().VX_Settings.AntiCage = v end)
CreateToggle("التقاط البيض الفوري (Instant E)", true, function(v) getgenv().VX_Settings.InstantPick = v end)
CreateToggle("كشف اللاعبين (ESP Players)", false, function(v) getgenv().VX_Settings.ESP_Players = v end)
CreateToggle("كشف البيض (ESP Eggs)", false, function(v) getgenv().VX_Settings.ESP_Eggs = v end)

-- Toggle Menu Visibility Event
CircleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- // ==========================================
-- // CORE ENGINES
-- // ==========================================

-- 1. Movement Physics & Anti-Drop Engine
RunService.Heartbeat:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end

        local hrp = char.HumanoidRootPart
        local hum = char:FindFirstChildOfClass("Humanoid")

        -- Speed Engine Override
        if getgenv().VX_Settings.SpeedToggle and hum and hum.MoveDirection.Magnitude > 0 then
            hrp.AssemblyLinearVelocity = Vector3.new(
                hum.MoveDirection.X * getgenv().VX_Settings.SpeedValue,
                hrp.AssemblyLinearVelocity.Y,
                hum.MoveDirection.Z * getgenv().VX_Settings.SpeedValue
            )
        end

        -- Protection & Godmode
        if getgenv().VX_Settings.GodMode then
            if hum then hum.Health = hum.MaxHealth end
            for _, item in pairs(char:GetChildren()) do
                if item:IsA("Tool") or item.Name:lower():find("egg") then
                    if item:FindFirstChild("Handle") then
                        item.Handle.CanCollide = false
                    end
                end
            end
        end

        -- Destroy Traps & Cages
        if getgenv().VX_Settings.AntiCage then
            hrp.Anchored = false
            for _, v in pairs(char:GetChildren()) do
                local name = v.Name:lower()
                if name:find("cage") or name:find("trap") or name:find("stun") then
                    v:Destroy()
                end
            end
        end
    end)
end)

-- 2. Instant Proximity Pick (E Button Fast Hatch/Steal)
ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
    if getgenv().VX_Settings.InstantPick then
        prompt.HoldDuration = 0
        pcall(function()
            fireproximityprompt(prompt)
        end)
    end
end)

workspace.DescendantAdded:Connect(function(v)
    if v:IsA("ProximityPrompt") and getgenv().VX_Settings.InstantPick then
        v.HoldDuration = 0
    end
end)

-- 3. ESP Engine (Radar System)
local function addESP(obj, color, labelText)
    if not obj:FindFirstChild("VX_Highlight") then
        local hl = Instance.new("Highlight")
        hl.Name = "VX_Highlight"
        hl.FillColor = color
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = 0.4
        hl.Parent = obj

        local bb = Instance.new("BillboardGui")
        bb.Name = "VX_Tag"
        bb.Adornee = obj
        bb.Size = UDim2.new(0, 120, 0, 30)
        bb.StudsOffset = Vector3.new(0, 3, 0)
        bb.AlwaysOnTop = true

        local txt = Instance.new("TextLabel")
        txt.Parent = bb
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.Text = labelText
        txt.TextColor3 = color
        txt.Font = Enum.Font.SourceSansBold
        txt.TextSize = 15

        bb.Parent = obj
    end
end

local function removeESP(obj)
    if obj:FindFirstChild("VX_Highlight") then obj.VX_Highlight:Destroy() end
    if obj:FindFirstChild("VX_Tag") then obj.VX_Tag:Destroy() end
end

task.spawn(function()
    while true do
        task.wait(1)
        pcall(function()
            -- ESP Players
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    if getgenv().VX_Settings.ESP_Players then
                        addESP(plr.Character, Color3.fromRGB(255, 60, 60), plr.Name)
                    else
                        removeESP(plr.Character)
                    end
                end
            end

            -- ESP Eggs
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name:lower():find("egg") and (v:IsA("Model") or v:IsA("BasePart")) then
                    if getgenv().VX_Settings.ESP_Eggs then
                        addESP(v, Color3.fromRGB(255, 215, 0), "Egg")
                    else
                        removeESP(v)
                    end
                end
            end
        end)
    end
end)
