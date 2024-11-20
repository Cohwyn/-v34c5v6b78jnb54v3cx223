-- Target Aim Lock and Camlock Script with GUI Label

-- Settings
getgenv().AimLockSettings = {
    Enabled = false, -- Toggle Aim Lock
    CamlockEnabled = false, -- Toggle Camlock
    Target = nil, -- Target Player (set to a specific player's name or leave nil to auto-detect)
    AimParts = {"Head", "HumanoidRootPart"}, -- Parts to lock onto in priority order
    Smoothness = 1, -- Camera smoothing value
    Prediction = {
        Target = 0.1347, -- Prediction for Aim Lock
        Camlock = 0.149843 -- Prediction for Camlock
    },
    ToggleKey = "C", -- Key to enable/disable Aim Lock and Camlock
    Notifications = true -- Enable toggle notifications
}

-- Dependencies
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

-- Notification Function
local function SendNotification(Title, Text, Duration)
    if not getgenv().AimLockSettings.Notifications then return end
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = Title,
            Text = Text,
            Duration = Duration or 3
        })
    end)
end

-- Simplify Workspace Materials
for _, v in pairs(workspace:GetDescendants()) do
    if v:IsA("Part") or v:IsA("SpawnLocation") or v:IsA("WedgePart") or v:IsA("Terrain") or v:IsA("MeshPart") then
        v.Material = Enum.Material.Plastic
    end
end

-- Create GUI Label
local function CreateGrimLabel()
    local ScreenGui = Instance.new("ScreenGui")
    local Label = Instance.new("TextLabel")

    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.Name = "GrimLabelGui"

    Label.Parent = ScreenGui
    Label.Name = "GrimLabel"
    Label.Text = "Grim made this"
    Label.Size = UDim2.new(0, 200, 0, 50)
    Label.Position = UDim2.new(1, -210, 1, -60) -- Bottom-right corner
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 18
end

CreateGrimLabel()

-- Get Closest Player
local function GetClosestPlayer()
    local ClosestPlayer = nil
    local ShortestDistance = math.huge
    local Mouse = LocalPlayer:GetMouse()

    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character then
            for _, PartName in ipairs(getgenv().AimLockSettings.AimParts) do
                local TargetPart = Player.Character:FindFirstChild(PartName)
                if TargetPart then
                    local ScreenPos, OnScreen = Camera:WorldToViewportPoint(TargetPart.Position)
                    local Distance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(ScreenPos.X, ScreenPos.Y)).Magnitude

                    if OnScreen and Distance < ShortestDistance then
                        ClosestPlayer = Player
                        ShortestDistance = Distance
                        break
                    end
                end
            end
        end
    end

    return ClosestPlayer
end

-- Aim Lock Logic
RunService.RenderStepped:Connect(function()
    if getgenv().AimLockSettings.Enabled then
        local Target = getgenv().AimLockSettings.Target or GetClosestPlayer()
        if Target and Target.Character then
            for _, PartName in ipairs(getgenv().AimLockSettings.AimParts) do
                local TargetPart = Target.Character:FindFirstChild(PartName)
                if TargetPart then
                    local TargetPosition = TargetPart.Position + (TargetPart.Velocity * getgenv().AimLockSettings.Prediction.Target)

                    Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, TargetPosition), getgenv().AimLockSettings.Smoothness)
                    break
                end
            end
        end
    end

    if getgenv().AimLockSettings.CamlockEnabled then
        local Target = getgenv().AimLockSettings.Target or GetClosestPlayer()
        if Target and Target.Character then
            for _, PartName in ipairs(getgenv().AimLockSettings.AimParts) do
                local TargetPart = Target.Character:FindFirstChild(PartName)
                if TargetPart then
                    local TargetPosition = TargetPart.Position + (TargetPart.Velocity * getgenv().AimLockSettings.Prediction.Camlock)

                    Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, TargetPosition), getgenv().AimLockSettings.Smoothness)
                    break
                end
            end
        end
    end
end)

-- Toggle Aim Lock and Camlock
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode[getgenv().AimLockSettings.ToggleKey] then
        getgenv().AimLockSettings.Enabled = not getgenv().AimLockSettings.Enabled
        getgenv().AimLockSettings.CamlockEnabled = not getgenv().AimLockSettings.CamlockEnabled

        if getgenv().AimLockSettings.Enabled then
            SendNotification("Aim Lock", "Enabled", 3)
        else
            SendNotification("Aim Lock", "Disabled", 3)
        end

        if getgenv().AimLockSettings.CamlockEnabled then
            SendNotification("Camlock", "Enabled", 3)
        else
            SendNotification("Camlock", "Disabled", 3)
        end
    end
end)
