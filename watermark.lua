--// Panel cuadrado con botones + toggle con L + noclip sin volar (anti-rebote)
--// creador: pedri.exe ジ

-- Servicios
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")

local lp = Players.LocalPlayer

-- ===== GUI base =====
local gui = Instance.new("ScreenGui")
gui.Name = "PedriPanelV2"
gui.ResetOnSpawn = false
pcall(function() gui.Parent = game.CoreGui end)
if not gui.Parent then gui.Parent = lp:WaitForChild("PlayerGui") end

-- Panel cuadrado
local PANEL_W, PANEL_H = 270, 270
local OPEN_TIME = 0.28

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.fromOffset(PANEL_W, 0)
panel.Position = UDim2.new(0.5, -math.floor(PANEL_W/2), 0.22, 0)
panel.BackgroundColor3 = Color3.fromRGB(26,26,26)
panel.BorderSizePixel = 0
panel.Visible = true
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)

local shadow = Instance.new("ImageLabel")
shadow.Image = "rbxassetid://5028857084"
shadow.ImageTransparency = 0.18
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(24,24,276,276)
shadow.AnchorPoint = Vector2.new(0.5, 0.5)
shadow.Position = UDim2.fromScale(0.5, 0.5)
shadow.Size = UDim2.new(1, 24, 1, 24)
shadow.BackgroundTransparency = 1
shadow.ZIndex = 0
shadow.Parent = panel

local top = Instance.new("Frame")
top.Name = "TopBar"
top.Size = UDim2.new(1, 0, 0, 36)
top.BackgroundColor3 = Color3.fromRGB(36,36,36)
top.BorderSizePixel = 0
top.Parent = panel
Instance.new("UICorner", top).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -12, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.fromRGB(235,235,235)
title.Text = "Panel pedri.exe ジ  —  [L] mostrar/ocultar"
title.Parent = top

local body = Instance.new("Frame")
body.BackgroundTransparency = 1
body.Position = UDim2.new(0, 12, 0, 46)
body.Size = UDim2.new(1, -24, 1, -46-40)
body.Parent = panel

local grid = Instance.new("UIGridLayout")
grid.CellPadding = UDim2.fromOffset(10, 10)
grid.CellSize = UDim2.fromOffset(120, 40)
grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
grid.VerticalAlignment = Enum.VerticalAlignment.Top
grid.Parent = body

local footer = Instance.new("TextLabel")
footer.BackgroundTransparency = 1
footer.Size = UDim2.new(1, -16, 0, 24)
footer.Position = UDim2.new(0, 8, 1, -28)
footer.Font = Enum.Font.GothamSemibold
footer.TextSize = 13
footer.TextColor3 = Color3.fromRGB(180,180,180)
footer.Text = "creador: pedri.exe"
footer.Parent = panel

-- ========== Animación panel ==========
local isOpen, animBusy = true, false

local function setDescAlpha(p, a)
	for _, d in ipairs(p:GetDescendants()) do
		if d:IsA("TextLabel") or d:IsA("TextButton") then
			d.TextTransparency = a
		elseif d:IsA("ImageLabel") or d:IsA("ImageButton") then
			d.ImageTransparency = a
		elseif d:IsA("Frame") and d ~= panel then
			d.BackgroundTransparency = math.clamp(a, 0, 0.9)
		end
	end
end

local function openPanel()
	if animBusy or isOpen then return end
	animBusy = true
	panel.Visible = true
	TS:Create(panel, TweenInfo.new(OPEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Size = UDim2.fromOffset(PANEL_W, PANEL_H)}):Play()
	local nv = Instance.new("NumberValue")
	nv.Value = 1
	local tw = TS:Create(nv, TweenInfo.new(OPEN_TIME), {Value = 0})
	nv:GetPropertyChangedSignal("Value"):Connect(function() setDescAlpha(panel, nv.Value) end)
	tw:Play()
	task.wait(OPEN_TIME)
	isOpen, animBusy = true, false
end

local function closePanel()
	if animBusy or not isOpen then return end
	animBusy = true
	local nv = Instance.new("NumberValue")
	nv.Value = 0
	local tw = TS:Create(nv, TweenInfo.new(OPEN_TIME), {Value = 1})
	nv:GetPropertyChangedSignal("Value"):Connect(function() setDescAlpha(panel, nv.Value) end)
	tw:Play()
	TS:Create(panel, TweenInfo.new(OPEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Size = UDim2.fromOffset(PANEL_W, 0)}):Play()
	task.wait(OPEN_TIME)
	panel.Visible = false
	isOpen, animBusy = false, false
end

UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.L then
		if isOpen then closePanel() else openPanel() end
	end
end)

-- Drag
do
	local dragging, dragStart, startPos
	local function update(input)
		local delta = input.Position - dragStart
		panel.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end
	top.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = inp.Position
			startPos = panel.Position
			inp.Changed:Connect(function()
				if inp.UserInputState == Enum.UserInputState.End then
					dragging = false
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

-- ======= Noclip SIN volar (anti-rebote) =======
-- Clave: además de CanCollide=false en TODAS las partes, añadimos un micro-traslado
-- en la dirección de movimiento (WASD) por frame para evitar la corrección hacia atrás.
local noclipOn = false
local originalCollide = {}
local steppedConn, hbConn

local function cacheDefaults(char)
	for _, p in ipairs(char:GetDescendants()) do
		if p:IsA("BasePart") and originalCollide[p] == nil then
			originalCollide[p] = p.CanCollide
		end
	end
end

local function setCharCollision(char, canCollide)
	for _, p in ipairs(char:GetDescendants()) do
		if p:IsA("BasePart") then
			p.CanCollide = canCollide
			p.CanTouch = false -- evita triggers raros que empujan
		end
	end
end

local function enableNoclip()
	noclipOn = true
	local char = lp.Character
	if char then
		cacheDefaults(char)
		setCharCollision(char, false)
	end

	-- 1) Refuerza no-colisión constantemente
	if steppedConn then steppedConn:Disconnect() end
	steppedConn = RS.Stepped:Connect(function()
		if not noclipOn then return end
		local c = lp.Character
		if c then
			for _, p in ipairs(c:GetDescendants()) do
				if p:IsA("BasePart") then
					p.CanCollide = false
				end
			end
		end
	end)

	-- 2) Anti-rebote: empuje correctivo mínimo en dirección WASD
	--    Mantiene el control normal (no vuela).
	if hbConn then hbConn:Disconnect() end
	hbConn = RS.Heartbeat:Connect(function(dt)
		if not noclipOn then return end
		local c = lp.Character
		if not c then return end
		local hum = c:FindFirstChildOfClass("Humanoid")
		local hrp = c:FindFirstChild("HumanoidRootPart")
		if not (hum and hrp) then return end

		-- Dirección de entrada del jugador (WASD)
		local dir = hum.MoveDirection
		if dir.Magnitude > 0 then
			-- Empuje muy pequeño, proporcional a WalkSpeed (no cambia la sensación)
			local correction = dir.Unit * (hum.WalkSpeed * dt * 0.85)
			-- Conservar Y para no "volar"
			hrp.CFrame = hrp.CFrame + Vector3.new(correction.X, 0, correction.Z)
		end

		-- Evita que la física te "agarre"
		hrp.AssemblyAngularVelocity = Vector3.new()
	end)
end

local function disableNoclip()
	noclipOn = false
	if steppedConn then steppedConn:Disconnect() steppedConn = nil end
	if hbConn then hbConn:Disconnect() hbConn = nil end
	local char = lp.Character
	if char then
		for _, p in ipairs(char:GetDescendants()) do
			if p:IsA("BasePart") and originalCollide[p] ~= nil then
				p.CanCollide = originalCollide[p]
				p.CanTouch = true
			end
		end
	end
end

lp.CharacterAdded:Connect(function(char)
	char:WaitForChild("Humanoid", 10)
	char:WaitForChild("HumanoidRootPart", 10)
	originalCollide = {}
	cacheDefaults(char)
	if noclipOn then
		task.wait(0.1)
		setCharCollision(char, false)
	end
end)

-- ===== Botones =====
local function makeBtn(text)
	local b = Instance.new("TextButton")
	b.AutoButtonColor = true
	b.BorderSizePixel = 0
	b.BackgroundColor3 = Color3.fromRGB(45,45,45)
	b.TextColor3 = Color3.fromRGB(255,255,255)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 14
	b.Text = text
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
	return b
end

local btnNoclip = makeBtn("no lisicion: OFF")
btnNoclip.Parent = body

local function setNoclipUI(on)
	btnNoclip.Text = "no lisicion: " .. (on and "ON" or "OFF")
	btnNoclip.BackgroundColor3 = on and Color3.fromRGB(45,130,90) or Color3.fromRGB(120,50,50)
end

btnNoclip.MouseButton1Click:Connect(function()
	if noclipOn then disableNoclip() else enableNoclip() end
	setNoclipUI(noclipOn)
end)

local btnLink = makeBtn("copiar link")
btnLink.Parent = body
btnLink.MouseButton1Click:Connect(function()
	if setclipboard then setclipboard("https://miwa.lol/pedri") end
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "pedri.exe";
			Text = "Link copiado: https://miwa.lol/pedri";
			Duration = 4;
		})
	end)
end)

local btnToggle = makeBtn("ocultar [L]")
btnToggle.Parent = body
btnToggle.MouseButton1Click:Connect(function()
	if isOpen then closePanel() else openPanel() end
end)

-- Arranque visual
task.delay(0.05, function()
	TS:Create(panel, TweenInfo.new(OPEN_TIME), {Size = UDim2.fromOffset(PANEL_W, PANEL_H)}):Play()
end)

-- Estado inicial del noclip
setNoclipUI(false)
