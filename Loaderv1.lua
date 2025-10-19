-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- State
local desyncActive = false
local dragging = false
local dragStart, startPos

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Lenon Hub Desync"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- BACK LAYER (compact medium size, shorter height)
local BackLayer = Instance.new("Frame")
BackLayer.Size = UDim2.new(0, 240, 0, 120) -- width 240, height 120
BackLayer.Position = UDim2.new(0.5, -120, 0.2, 0) -- centered horizontally
BackLayer.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- dark gray
BackLayer.BorderSizePixel = 0
BackLayer.Parent = ScreenGui

local BackCorner = Instance.new("UICorner")
BackCorner.CornerRadius = UDim.new(0, 25) -- rounded corners
BackCorner.Parent = BackLayer

-- FRONT BUTTON (small-medium rectangle)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 160, 0, 50) -- small-medium
ToggleButton.Position = UDim2.new(0.5, -80, 0.5, -25) -- centered inside back layer
ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50) -- dark button
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255) -- fully white
ToggleButton.Text = "Desync On"
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 24
ToggleButton.AutoButtonColor = false
ToggleButton.Parent = BackLayer

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 15)
ButtonCorner.Parent = ToggleButton

-- Stroke for button
local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(70, 70, 70)
UIStroke.Transparency = 0.3
UIStroke.Parent = ToggleButton

-- Dragging functionality
BackLayer.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = BackLayer.Position
	end
end)

BackLayer.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		if dragging then
			local delta = input.Position - dragStart
			BackLayer.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

-- Desync Functions
local function enableMobileDesync()
	if desyncActive then return false end
	local success, errorMsg = pcall(function()
		local backpack = LocalPlayer:WaitForChild("Backpack")
		local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local humanoid = character:WaitForChild("Humanoid")

		local packages = ReplicatedStorage:WaitForChild("Packages", 5)
		if not packages then return false end

		local netFolder = packages:WaitForChild("Net", 5)
		if not netFolder then return false end

		local useItemRemote = netFolder:WaitForChild("RE/UseItem", 5)
		local teleportRemote = netFolder:WaitForChild("RE/QuantumCloner/OnTeleport", 5)
		if not useItemRemote or not teleportRemote then return false end

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
	end)

	if not success then
		warn("Error activating desync: "..tostring(errorMsg))
		return false
	end

	desyncActive = true
	return true
end

local function disableMobileDesync()
	if not desyncActive then return end
	pcall(function()
		if setfflag then setfflag("WorldStepMax", "-1") end
	end)
	desyncActive = false
end

-- Toggle button
ToggleButton.MouseButton1Click:Connect(function()
	if not desyncActive then
		enableMobileDesync()
	else
		disableMobileDesync()
	end
end)

-- Reset on respawn
LocalPlayer.CharacterAdded:Connect(function()
	desyncActive = false
	disableMobileDesync()
end)
