local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local UIS = game:GetService("UserInputService")

local gui = Instance.new("ScreenGui")
gui.Name = "CustomPanel"
gui.ResetOnSpawn = false
pcall(function() gui.Parent = game.CoreGui end)
if not gui.Parent then gui.Parent = lp:WaitForChild("PlayerGui") end

-- Panel principal
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 800, 0, 460)
main.Position = UDim2.new(0.5, -400, 0.5, -230)
main.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 16)

-- Barra superior (draggable)
local topDrag = Instance.new("Frame")
topDrag.Size = UDim2.new(1, 0, 0, 40)
topDrag.Position = UDim2.new(0, 0, 0, 0)
topDrag.BackgroundColor3 = Color3.fromRGB(16, 16, 28)
topDrag.BorderSizePixel = 0
topDrag.Parent = main
Instance.new("UICorner", topDrag).CornerRadius = UDim.new(0, 12)

local dragTitle = Instance.new("TextLabel")
dragTitle.BackgroundTransparency = 1
dragTitle.Size = UDim2.new(1, -20, 1, 0)
dragTitle.Position = UDim2.new(0, 10, 0, 0)
dragTitle.Font = Enum.Font.GothamBold
dragTitle.TextSize = 18
dragTitle.TextXAlignment = Enum.TextXAlignment.Left
dragTitle.TextColor3 = Color3.fromRGB(230,230,255)
dragTitle.Text = "Tu Panel"
dragTitle.Parent = topDrag

-- --------------------------
-- SISTEMA DE ARRASTRAR PANEL
-- --------------------------
local dragging = false
local dragStart, startPos

local function update(input)
	local delta = input.Position - dragStart
	main.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)
end

topDrag.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = main.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		update(input)
	end
end)

-- -----------------
-- Barra lateral
-- -----------------
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 180, 1, -40)
sidebar.Position = UDim2.new(0, 0, 0, 40)
sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
sidebar.BorderSizePixel = 0
sidebar.Parent = main
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 14)

local tabsHolder = Instance.new("Frame")
tabsHolder.BackgroundTransparency = 1
tabsHolder.Size = UDim2.new(1, -20, 1, -20)
tabsHolder.Position = UDim2.new(0, 10, 0, 10)
tabsHolder.Parent = sidebar

local tabLayout = Instance.new("UIListLayout")
tabLayout.Parent = tabsHolder
tabLayout.Padding = UDim.new(0, 6)

local function createTab(text)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, 32)
	b.BackgroundColor3 = Color3.fromRGB(20,20,32)
	b.BorderSizePixel = 0
	b.Font = Enum.Font.Gotham
	b.TextSize = 14
	b.TextXAlignment = Enum.TextXAlignment.Left
	b.Text = "   " .. text
	b.TextColor3 = Color3.fromRGB(235,235,255)
	b.Parent = tabsHolder
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
	return b
end

local t1 = createTab("Sección 1")
local t2 = createTab("Sección 2")
local t3 = createTab("Sección 3")

-- -----------------
-- Zona derecha
-- -----------------
local right = Instance.new("Frame")
right.Size = UDim2.new(1, -200, 1, -50)
right.Position = UDim2.new(0, 190, 0, 50)
right.BackgroundColor3 = Color3.fromRGB(18,18,30)
right.BorderSizePixel = 0
right.Parent = main
Instance.new("UICorner", right).CornerRadius = UDim.new(0, 12)

local placeholder = Instance.new("TextLabel")
placeholder.BackgroundTransparency = 1
placeholder.Size = UDim2.new(1, -20, 1, -20)
placeholder.Position = UDim2.new(0, 10, 0, 10)
placeholder.Font = Enum.Font.Gotham
placeholder.TextSize = 16
placeholder.TextColor3 = Color3.fromRGB(200,200,220)
placeholder.TextXAlignment = Enum.TextXAlignment.Left
placeholder.TextYAlignment = Enum.TextYAlignment.Top
placeholder.TextWrapped = true
placeholder.Text = "Panel listo.\nAquí puedes agregar tus opciones."
placeholder.Parent = right
