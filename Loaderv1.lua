local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DesyncGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

-- Main frame with rounded corners
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 100)
mainFrame.Position = UDim2.new(0.5, -110, 0.5, -50)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Add rounded corners
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)  -- adjust the radius
corner.Parent = mainFrame

-- Optionally add a border or stroke
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(200, 200, 200)
stroke.Thickness = 1
stroke.Parent = mainFrame

-- Title Label
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 24)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Text = "Onyx Desync"
titleLabel.Parent = mainFrame

-- Desync Button
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(1, -20, 0, 40)
toggleButton.Position = UDim2.new(0, 10, 0, 30)
toggleButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
toggleButton.BorderSizePixel = 0
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 20
toggleButton.Font = Enum.Font.SourceSans
toggleButton.Text = "Desync ON"
toggleButton.Parent = mainFrame

-- Rounded corners on button
local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = toggleButton

-- "PREMIUM" Label Below Button
local premiumLabel = Instance.new("TextLabel")
premiumLabel.Size = UDim2.new(1, 0, 0, 18)
premiumLabel.Position = UDim2.new(0, 0, 1, -18)  -- inside bottom of mainFrame
premiumLabel.BackgroundTransparency = 1
premiumLabel.Text = "PREMIUM"
premiumLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
premiumLabel.TextSize = 14
premiumLabel.Font = Enum.Font.SourceSansSemibold
premiumLabel.Parent = mainFrame

-- Desync Function (same as before)
local function enableMobileDesync()
    local success, error = pcall(function()
        local backpack = LocalPlayer:WaitForChild("Backpack")
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")

        local packages = ReplicatedStorage:WaitForChild("Packages", 5)
        if not packages then
            warn("Packages not found")
            return false
        end

        local netFolder = packages:WaitForChild("Net", 5)
        if not netFolder then
            warn("Net folder not found")
            return false
        end

        local useItemRemote = netFolder:WaitForChild("RE/UseItem", 5)
        local teleportRemote = netFolder:WaitForChild("RE/QuantumCloner/OnTeleport", 5)
        if not useItemRemote or not teleportRemote then
            warn("Remotes not found")
            return false
        end

        local toolNames = {"Quantum Cloner", "Brainrot", "brainrot"}
        local tool
        for _, toolName in ipairs(toolNames) do
            tool = backpack:FindFirstChild(toolName) or character:FindFirstChild(toolName)
            if tool then break end
        end

        if not tool then
            for _, item in ipairs(backpack:GetChildren()) do
                if item:IsA("Tool") then
                    tool = item
                    break
                end
            end
        end

        if tool and tool.Parent == backpack then
            humanoid:EquipTool(tool)
            task.wait(0.5)
        end

        if setfflag then setfflag("WorldStepMax", "-9999999999") end
        task.wait(0.2)
        useItemRemote:FireServer()
        task.wait(1)
        teleportRemote:FireServer()
        task.wait(2)
        if setfflag then setfflag("WorldStepMax", "-1") end

        return true
    end)

    if not success then
        warn("Error activating desync: " .. tostring(error))
        return false
    end
    return true
end

-- Button Click Logic
toggleButton.MouseButton1Click:Connect(function()
    toggleButton.AutoButtonColor = false
    toggleButton.Active = false
    local success = enableMobileDesync()
    if not success then
        toggleButton.Text = "Failed"
    end
end)

-- Reset on respawn
LocalPlayer.CharacterAdded:Connect(function()
    toggleButton.Text = "Desync ON"
    toggleButton.Active = true
    toggleButton.AutoButtonColor = true
