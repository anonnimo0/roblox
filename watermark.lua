--// Panel movible + toggle con L + animación + Noclip //--
--// creador: pedri.exe ジ //--

-- Servicios
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local Players = game:GetService("Players")

local lp = Players.LocalPlayer

-- GUI base
local gui = Instance.new("ScreenGui")
gui.Name = "PedriPanelGUI"
gui.ResetOnSpawn = false
pcall(function() gui.Parent = game.CoreGui end)
if not gui.Parent then gui.Parent = lp:WaitForChild("PlayerGui") end

-- Config
local PANEL_SIZE = Vector2.new(320, 200)
local OPEN_TIME = 0.3
local EASING = Enum.EasingStyle.Quad
local EASED = Enum.EasingDirection.Out

-- Frame principal
local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(PANEL_SIZE.X, 0) -- empieza cerrado (alto 0)
frame.Position = UDim2.new(0.5, -PANEL_SIZE.X/2, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
frame.BorderSizePixel = 0
frame.BackgroundTransparency = 0.1
frame.Parent = gui

-- Esquinas redondeadas
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

-- Sombra
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.Image = "rbxassetid://5028857084"
shadow.ImageTransparency = 0.2
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(24, 24, 276, 276)
shadow.AnchorPoint = Vector2.new(0.5, 0.5)
shadow.Position = UDim2.fromScale(0.5, 0.5)
shadow.Size = UDim2.new(1, 28, 1, 28)
shadow.BackgroundTransparency = 1
shadow.ZIndex = 0
shadow.Parent = frame

-- Barra superior (para arrastrar)
local top = Instance.new("Frame")
top.Name = "TopBar"
top.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
top.BorderSizePixel = 0
top.Size = UDim2.new(1, 0, 0, 36)
top.Parent = frame
Instance.new("UICorner", top).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -12, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.Font = Enum.Font.GothamBold
title.Text = "Panel pedri.exe ジ  —  [L] mostrar/ocultar"
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.fromRGB(235,235,235)
title.Parent = top

-- Contenido
local content = Instance.new("Frame")
content.BackgroundTransparency = 1
content.Size = UDim2.new(1, -16, 1, -36-28)
content.Position = UDim2.new(0, 8, 0, 36+4)
content.Parent = frame

-- Toggle noclip
local noclipBtn = Instance.new("TextButton")
noclipBtn.Name = "NoclipBtn"
noclipBtn.Size = UDim2.new(0, 140, 0, 36)
noclipBtn.Position = UDim2.new(0, 0, 0, 0)
noclipBtn.BackgroundColor3 = Color3.fromRGB(45, 130, 90)
noclipBtn.AutoButtonColor = true
noclipBtn.BorderSizePixel = 0
noclipBtn.Font = Enum.Font.GothamBold
noclipBtn.TextSize = 14
noclipBtn.TextColor3 = Color3.fromRGB(255,255,255)
noclipBtn.Text = "Noclip: ON"
noclipBtn.Parent = content
Instance.new("UICorner", noclipBtn).CornerRadius = UDim.new(0, 10)

local info = Instance.new("TextLabel")
info.BackgroundTransparency = 1
info.Size = UDim2.new(1, -150, 0, 36)
info.Position = UDim2.new(0, 150, 0, 0)
info.Font = Enum.Font.Gotham
info.TextSize = 13
info.TextXAlignment = Enum.TextXAlignment.Left
info.TextColor3 = Color3.fromRGB(220,220,220)
info.Text = "Atravesar paredes mientras esté ON."
info.Parent = content

-- Pie con autor
local footer = Instance.new("TextLabel")
footer.BackgroundTransparency = 1
footer.Size = UDim2.new(1, -16, 0, 24)
footer.Position = UDim2.new(0, 8, 1, -24-8)
footer.Font = Enum.Font.GothamSemibold
footer.TextSize = 13
footer.TextXAlignment = Enum.TextXAlignment.Center
footer.TextColor3 = Color3.fromRGB(180,180,180)
footer.Text = "creador: pedri.exe"
footer.Parent = frame

-- Función para animar transparencia de descendientes
local function setDescendantsTransparency(p, alpha)
	for _, d in ipairs(p:GetDescendants()) do
		if d:IsA("TextLabel") or d:IsA("TextButton") then
			d.TextTransparency = alpha
		end
		if d:IsA("ImageLabel") or d:IsA("ImageButton") then
			d.ImageTransparency = alpha
		end
		if d:IsA("Frame") then
			d.BackgroundTransparency = math.clamp(alpha, 0, 0.9)
		end
	end
end

-- Estado panel
local isOpen = true
local animBusy = false

local function openPanel()
	if animBusy or isOpen then return end
	animBusy = true
	frame.Visible = true
	TS:Create(frame, TweenInfo.new(OPEN_TIME, EASING, EASED), {Size = UDim2.fromOffset(PANEL_SIZE.X, PANEL_SIZE.Y)}):Play()
	local tweenAlpha = Instance.new("NumberValue")
	tweenAlpha.Value = 1
	local tw = TS:Create(tweenAlpha, TweenInfo.new(OPEN_TIME, EASING, EASED), {Value = 0})
	tw:GetPropertyChangedSignal("Value"):Connect(function()
		setDescendantsTransparency(frame, tweenAlpha.Value)
	end)
	tw:Play()
	task.wait(OPEN_TIME)
	isOpen = true
	animBusy = false
end

local function closePanel()
	if animBusy or not isOpen then return end
	animBusy = true
	local tweenAlpha = Instance.new("NumberValue")
	tweenAlpha.Value = 0
	local tw = TS:Create(tweenAlpha, TweenInfo.new(OPEN_TIME, EASING, EASED), {Value = 1})
	tw:GetPropertyChangedSignal("Value"):Connect(function()
		setDescendantsTransparency(frame, tweenAlpha.Value)
	end)
	tw:Play()
	TS:Create(frame, TweenInfo.new(OPEN_TIME, EASING, EASED), {Size = UDim2.fromOffset(PANEL_SIZE.X, 0)}):Play()
	task.wait(OPEN_TIME)
	frame.Visible = false
	isOpen = false
	animBusy = false
end

-- Toggle con tecla L
UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.L then
		if isOpen then
			closePanel()
		else
			openPanel()
		end
	end
end)

-- Drag suave de la ventana
do
	local dragging = false
	local dragStart, startPos
	local function update(input)
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end

	top.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = inp.Position
			startPos = frame.Position
			-- “enganche” con una pequeña animación
			TS:Create(frame, TweenInfo.new(0.1, EASING, EASED), {BackgroundTransparency = 0}):Play()
			inp.Changed:Connect(function()
				if inp.UserInputState == Enum.UserInputState.End then
					dragging = false
					TS:Create(frame, TweenInfo.new(0.15, EASING, EASED), {BackgroundTransparency = 0.1}):Play()
				end
			end)
		end
	end)

	UIS.InputChanged:Connect(function(inp)
		if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
			update(inp)
		end
	end)
end

-- Noclip
local noclipEnabled = true
local function applyNoclip(char)
	if not char then return end
	for _,v in ipairs(char:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide = false
		end
	end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		-- Estado 'Physics' ayuda a no quedarse pillado
		pcall(function() hum:ChangeState(Enum.HumanoidStateType.Physics) end)
	end
end

local steppedConn
local function startNoclip()
	if steppedConn then steppedConn:Disconnect() end
	steppedConn = RS.Stepped:Connect(function()
		if not noclipEnabled then return end
		local char = lp.Character
		if char then applyNoclip(char) end
	end)
end
startNoclip()

-- Toggle noclip botón
local function setNoclip(on)
	noclipEnabled = on
	noclipBtn.Text = "Noclip: " .. (on and "ON" or "OFF")
	noclipBtn.BackgroundColor3 = on and Color3.fromRGB(45,130,90) or Color3.fromRGB(120,50,50)
end

noclipBtn.MouseButton1Click:Connect(function()
	setNoclip(not noclipEnabled)
end)

-- Reaplicar al respawnear
lp.CharacterAdded:Connect(function(char)
	char:WaitForChild("HumanoidRootPart", 10)
	task.wait(0.1)
	if noclipEnabled then applyNoclip(char) end
end)

-- Arranque visual (abre con animación)
task.delay(0.05, openPanel)
setNoclip(true)
