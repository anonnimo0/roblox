--[[
Foxxy's Leaks — Admin Menu (v1.30.130)
Autor: pedri.exe
Lenguaje: Lua (Roblox LocalScript)

⚠️ Aviso
Este script está pensado para pruebas / desarrollo en tus propios juegos.
Respeta siempre las normas de cada experiencia y la ToS de Roblox.

Instrucciones rápidas
- Pega este código en un LocalScript dentro de StarterPlayerScripts.
- Al iniciar, aparece el Login (clave por defecto: "HJGL-FKSS").
- Tecla global para mostrar/ocultar: L.
- Menú móvil y arrastrable. Sidebar con pestañas: Movimiento, Aimbot, Visual, Otros, Créditos.
- Pie con DisplayName (@Username).

Estilo/UX
- Tema duro: esquinas rectas, acentos neón, trazos gruesos.
- Sliders duros (barra + relleno + knob recto).
- Botones animados (hover/click: escala y color).

Incluye
- Movimiento: WalkSpeed (8–120), Salto x0.9–x1.8, Noclip ON/OFF, Fly ON/OFF + velocidad (16–240).
- Aimbot: ON/OFF, rebind de tecla (por defecto RMB), Intensidad (1–100), FOV círculo ON/OFF + tamaño (30–500) + color RGB, target = cabeza del enemigo más cercano dentro del FOV (ignora Freecam).
- Visual: ON/OFF maestro, Highlight enemigos (si hay Teams, solo enemigos), nombres y distancia.
- Otros: Invisible (local), Freecam/Foto (cámara libre con WASD y ratón; el cuerpo se queda anclado).
- Créditos: autor, discord (botón copia), versión.

--]]

---------------------------------------------------------------------
-- Servicios
---------------------------------------------------------------------
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Teams = game:GetService("Teams")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

---------------------------------------------------------------------
-- Utilidades
---------------------------------------------------------------------
local function safeSetClipboard(text)
	-- setclipboard existe en algunos entornos de ejecución; protegemos con pcall
	local ok = pcall(function()
		if setclipboard then setclipboard(text) end
	end)
	if not ok then
		StarterGui:SetCore("SendNotification", {
			Title = "Copiado";
			Text = "No se pudo copiar automáticamente. Enlace: "..text;
			Duration = 4;
		})
	end
end

local function getCharacter(player)
	local char = player.Character or player.CharacterAdded:Wait()
	return char
end

local function getRoot(char)
	return char:FindFirstChild("HumanoidRootPart")
end

local function isEnemy(targetPlayer)
	if targetPlayer == LP then return false end
	if Teams and LP.Team and targetPlayer.Team then
		return LP.Team ~= targetPlayer.Team
	end
	return true -- si no hay equipos, tratamos a todos menos a ti como potenciales
end

local function worldToScreen(pos)
	local v, onScreen = Camera:WorldToViewportPoint(pos)
	return Vector2.new(v.X, v.Y), onScreen
end

local function vec2Distance(a, b)
	return (a - b).Magnitude
end

local function clamp(x, a, b)
	return math.max(a, math.min(b, x))
end

local function lerp(a, b, t)
	return a + (b - a) * t
end

local function humanoidOf(char)
	return char and char:FindFirstChildOfClass("Humanoid")
end

---------------------------------------------------------------------
-- Paleta y tema duro
---------------------------------------------------------------------
local Colors = {
	bg = Color3.fromRGB(10, 10, 14),
	panel = Color3.fromRGB(18, 18, 24),
	neon = Color3.fromRGB(0, 255, 170), -- acento neón
	neon2 = Color3.fromRGB(255, 50, 140),
	text = Color3.fromRGB(240, 240, 240),
	muted = Color3.fromRGB(140, 140, 155),
	stroke = Color3.fromRGB(50, 50, 60)
}

---------------------------------------------------------------------
-- GUI raíz
---------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FoxxysLeaksAdmin"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LP:WaitForChild("PlayerGui")

---------------------------------------------------------------------
-- Login “duro”
---------------------------------------------------------------------
local LoginContainer = Instance.new("Frame")
LoginContainer.BackgroundColor3 = Colors.bg
LoginContainer.BorderSizePixel = 0
LoginContainer.Size = UDim2.new(1,0,1,0)
LoginContainer.Parent = ScreenGui

local Center = Instance.new("Frame")
Center.AnchorPoint = Vector2.new(0.5, 0.5)
Center.Position = UDim2.new(0.5, 0, 0.5, 0)
Center.Size = UDim2.new(0, 420, 0, 260)
Center.BackgroundColor3 = Colors.panel
Center.BorderSizePixel = 0
Center.Parent = LoginContainer

local Stroke = Instance.new("UIStroke")
Stroke.Thickness = 3
Stroke.Color = Colors.neon
Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Stroke.Parent = Center

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -20, 0, 40)
Title.Position = UDim2.new(0, 10, 0, 10)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 24
Title.TextColor3 = Colors.text
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Text = "Foxxy's Leaks — Login"
Title.Parent = Center

local KeyBox = Instance.new("TextBox")
KeyBox.BackgroundColor3 = Colors.bg
KeyBox.BorderSizePixel = 0
KeyBox.Size = UDim2.new(1, -20, 0, 44)
KeyBox.Position = UDim2.new(0, 10, 0, 70)
KeyBox.PlaceholderText = "Introduce la key"
KeyBox.Text = ""
KeyBox.Font = Enum.Font.GothamSemibold
KeyBox.TextSize = 18
KeyBox.TextColor3 = Colors.text
KeyBox.ClearTextOnFocus = false
KeyBox.Parent = Center

local KeyStroke = Instance.new("UIStroke")
KeyStroke.Thickness = 3
KeyStroke.Color = Colors.stroke
KeyStroke.Parent = KeyBox

local LoginBtn = Instance.new("TextButton")
LoginBtn.BackgroundColor3 = Colors.neon
LoginBtn.Size = UDim2.new(1, -20, 0, 44)
LoginBtn.Position = UDim2.new(0, 10, 0, 130)
LoginBtn.Text = "ENTRAR"
LoginBtn.Font = Enum.Font.GothamBlack
LoginBtn.TextSize = 20
LoginBtn.TextColor3 = Colors.bg
LoginBtn.AutoButtonColor = false
LoginBtn.Parent = Center

local function pulse(btn)
	local t1 = TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = btn.Size + UDim2.new(0, 6, 0, 6)})
	local t2 = TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = btn.Size})
	t1:Play(); t1.Completed:Wait(); t2:Play()
end

local LoginInfo = Instance.new("TextLabel")
LoginInfo.BackgroundTransparency = 1
LoginInfo.Size = UDim2.new(1,-20,0,24)
LoginInfo.Position = UDim2.new(0, 10, 1, -34)
LoginInfo.Font = Enum.Font.Gotham
LoginInfo.TextSize = 14
LoginInfo.TextColor3 = Colors.muted
LoginInfo.Text = "Tema duro. Entra directo al login."
LoginInfo.TextXAlignment = Enum.TextXAlignment.Left
LoginInfo.Parent = Center

local KEY_REQUIRED = "HJGL-FKSS"

local authed = false

local function tryLogin()
	if KeyBox.Text == KEY_REQUIRED then
		authed = true
		pulse(LoginBtn)
		TweenService:Create(LoginContainer, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
		TweenService:Create(Center, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
		LoginContainer.Visible = false
	else
		LoginInfo.TextColor3 = Colors.neon2
		LoginInfo.Text = "Key incorrecta"
	end
end

LoginBtn.MouseButton1Click:Connect(tryLogin)
KeyBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then tryLogin() end
end)

---------------------------------------------------------------------
-- Contenedor del menú (inicialmente oculto hasta login)
---------------------------------------------------------------------
local Root = Instance.new("Frame")
Root.BackgroundColor3 = Colors.panel
Root.BorderSizePixel = 0
Root.Size = UDim2.new(0, 740, 0, 420)
Root.Position = UDim2.new(0.5, -370, 0.5, -210)
Root.Visible = false
Root.Parent = ScreenGui

local RootStroke = Instance.new("UIStroke")
RootStroke.Thickness = 3
RootStroke.Color = Colors.neon
RootStroke.Parent = Root

-- Drag manual
local dragging = false
local dragStart, startPos
Root.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = Root.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)
Root.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		Root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Header
local Header = Instance.new("TextLabel")
Header.BackgroundTransparency = 1
Header.Size = UDim2.new(1,-20,0,36)
Header.Position = UDim2.new(0,10,0,8)
Header.Font = Enum.Font.GothamBlack
Header.TextSize = 22
Header.TextColor3 = Colors.text
Header.TextXAlignment = Enum.TextXAlignment.Left
Header.Text = "Foxxy's Leaks — Admin Menu"
Header.Parent = Root

-- Footer con DisplayName (@Username)
local Footer = Instance.new("TextLabel")
Footer.BackgroundTransparency = 1
Footer.Size = UDim2.new(1,-20,0,24)
Footer.Position = UDim2.new(0,10,1,-28)
Footer.Font = Enum.Font.GothamSemibold
Footer.TextSize = 14
Footer.TextColor3 = Colors.muted
Footer.TextXAlignment = Enum.TextXAlignment.Left
Footer.Text = string.format("%s (@%s)", LP.DisplayName or LP.Name, LP.Name)
Footer.Parent = Root

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.BackgroundColor3 = Colors.bg
Sidebar.BorderSizePixel = 0
Sidebar.Size = UDim2.new(0, 160, 1, -70)
Sidebar.Position = UDim2.new(0, 10, 0, 50)
Sidebar.Parent = Root

local SidebarStroke = Instance.new("UIStroke")
SidebarStroke.Thickness = 3
SidebarStroke.Color = Colors.stroke
SidebarStroke.Parent = Sidebar

-- Panel de contenido
local Content = Instance.new("Frame")
Content.BackgroundColor3 = Colors.bg
Content.BorderSizePixel = 0
Content.Size = UDim2.new(1, -190, 1, -70)
Content.Position = UDim2.new(0, 180, 0, 50)
Content.Parent = Root

local ContentStroke = Instance.new("UIStroke")
ContentStroke.Thickness = 3
ContentStroke.Color = Colors.stroke
ContentStroke.Parent = Content

---------------------------------------------------------------------
-- Componentes UI reusables
---------------------------------------------------------------------
local function makeButton(text)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -16, 0, 36)
	b.Position = UDim2.new(0, 8, 0, 0)
	b.BackgroundColor3 = Colors.panel
	b.AutoButtonColor = false
	b.Text = text
	b.Font = Enum.Font.GothamBold
	b.TextSize = 16
	b.TextColor3 = Colors.text
	local s = Instance.new("UIStroke") s.Thickness = 2 s.Color = Colors.neon s.Parent = b
	b.MouseEnter:Connect(function() TweenService:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = Colors.neon}):Play() TweenService:Create(b, TweenInfo.new(0.1), {TextColor3 = Colors.bg}):Play() end)
	b.MouseLeave:Connect(function() TweenService:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = Colors.panel}):Play() TweenService:Create(b, TweenInfo.new(0.1), {TextColor3 = Colors.text}):Play() end)
	b.MouseButton1Click:Connect(function() pulse(b) end)
	return b
end

local function makeToggle(label, default)
	local frame = Instance.new("Frame")
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.new(1,-20,0,36)
	local txt = Instance.new("TextLabel")
	txt.BackgroundTransparency = 1
	txt.Size = UDim2.new(1, -60, 1, 0)
	txt.TextXAlignment = Enum.TextXAlignment.Left
	txt.Font = Enum.Font.Gotham
	txt.TextSize = 16
	txt.TextColor3 = Colors.text
	txt.Text = label
	txt.Parent = frame
	local btn = makeButton(default and "ON" or "OFF")
	btn.Size = UDim2.new(0, 60, 0, 30)
	btn.Position = UDim2.new(1, -70, 0.5, -15)
	btn.Parent = frame
	local state = default or false
	local function refresh()
		btn.Text = state and "ON" or "OFF"
		TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = state and Colors.neon or Colors.panel, TextColor3 = state and Colors.bg or Colors.text}):Play()
	end
	refresh()
	btn.MouseButton1Click:Connect(function() state = not state refresh() frame:SetAttribute("Value", state) end)
	frame:SetAttribute("Value", state)
	return frame
end

local function makeSlider(label, min, max, default, decimals)
	local frame = Instance.new("Frame")
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.new(1,-20,0,56)
	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Size = UDim2.new(1, 0, 0, 20)
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 16
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextColor3 = Colors.text
	lbl.Text = label
	lbl.Parent = frame
	local bar = Instance.new("Frame")
	bar.BackgroundColor3 = Colors.panel
	bar.BorderSizePixel = 0
	bar.Position = UDim2.new(0, 0, 0, 26)
	bar.Size = UDim2.new(1, -70, 0, 10)
	bar.Parent = frame
	local barStroke = Instance.new("UIStroke") barStroke.Color = Colors.stroke barStroke.Thickness = 2 barStroke.Parent = bar
	local fill = Instance.new("Frame")
	fill.BackgroundColor3 = Colors.neon
	fill.BorderSizePixel = 0
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.Parent = bar
	local knob = Instance.new("Frame")
	knob.BackgroundColor3 = Colors.neon
	knob.BorderSizePixel = 0
	knob.Size = UDim2.new(0, 14, 0, 18)
	knob.Position = UDim2.new(0, -7, 0.5, -9)
	knob.Parent = bar
	local valueLbl = Instance.new("TextLabel")
	valueLbl.BackgroundTransparency = 1
	valueLbl.Size = UDim2.new(0, 60, 0, 24)
	valueLbl.Position = UDim2.new(1, -60, 0, 18)
	valueLbl.Font = Enum.Font.GothamSemibold
	valueLbl.TextSize = 14
	valueLbl.TextColor3 = Colors.text
	valueLbl.TextXAlignment = Enum.TextXAlignment.Right
	valueLbl.Parent = frame

	local val = default or min
	local draggingS = false

	local function setFromX(x)
		local absPos = bar.AbsolutePosition.X
		local absSize = bar.AbsoluteSize.X
		local alpha = clamp((x - absPos) / absSize, 0, 1)
		val = min + (max - min) * alpha
		if decimals and decimals > 0 then
			local m = 10 ^ decimals
			val = math.floor(val * m + 0.5) / m
		else
			val = math.floor(val + 0.5)
		end
		local px = math.floor(alpha * absSize + 0.5)
		fill.Size = UDim2.new(0, px, 1, 0)
		knob.Position = UDim2.new(0, px - 7, 0.5, -9)
		valueLbl.Text = tostring(val)
		frame:SetAttribute("Value", val)
	end

	frame:SetAttribute("Value", val)
	valueLbl.Text = tostring(val)
	fill.Size = UDim2.new((val-min)/(max-min), 0, 1, 0)
	knob.Position = UDim2.new((val-min)/(max-min), -7, 0.5, -9)

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingS = true
			setFromX(input.Position.X)
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then draggingS = false end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if draggingS and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			setFromX(input.Position.X)
		end
	end)

	return frame
end

local function makeColorSlider(label, default)
	local container = Instance.new("Frame")
	container.BackgroundTransparency = 1
	container.Size = UDim2.new(1,-20,0,170)
	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(1,0,0,20)
	title.Text = label
	title.Font = Enum.Font.Gotham
	title.TextSize = 16
	title.TextColor3 = Colors.text
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = container
	local r = makeSlider("R", 0, 255, default.R*255)
	r.Position = UDim2.new(0,0,0,26)
	r.Parent = container
	local g = makeSlider("G", 0, 255, default.G*255)
	g.Position = UDim2.new(0,0,0,82)
	g.Parent = container
	local b = makeSlider("B", 0, 255, default.B*255)
	b.Position = UDim2.new(0,0,0,138)
	b.Parent = container
	container:SetAttribute("Color", default)
	local function update()
		local col = Color3.fromRGB(r:GetAttribute("Value"), g:GetAttribute("Value"), b:GetAttribute("Value"))
		container:SetAttribute("Color", col)
	end
	r:GetAttributeChangedSignal("Value"):Connect(update)
	g:GetAttributeChangedSignal("Value"):Connect(update)
	b:GetAttributeChangedSignal("Value"):Connect(update)
	return container
end

---------------------------------------------------------------------
-- Sistema de pestañas
---------------------------------------------------------------------
local Tabs = {}
local function addTab(name)
	local btn = makeButton(name)
	btn.Parent = Sidebar
	btn.LayoutOrder = #Sidebar:GetChildren()
	local page = Instance.new("Frame")
	page.BackgroundTransparency = 1
	page.Size = UDim2.new(1,-20,1,-20)
	page.Position = UDim2.new(0,10,0,10)
	page.Visible = false
	page.Parent = Content
	Tabs[name] = {button = btn, page = page}
	btn.MouseButton1Click:Connect(function()
		for n, t in pairs(Tabs) do
			t.page.Visible = false
		end
		page.Visible = true
	end)
	return page
end

-- Layouts
local sLayout = Instance.new("UIListLayout") sLayout.Parent = Sidebar sLayout.Padding = UDim.new(0,8)

local function vlist(parent)
	local l = Instance.new("UIListLayout")
	l.Padding = UDim.new(0,8)
	l.HorizontalAlignment = Enum.HorizontalAlignment.Left
	l.SortOrder = Enum.SortOrder.LayoutOrder
	l.Parent = parent
	return l
end

---------------------------------------------------------------------
-- Notificación/banner superior (copia Discord al click)
---------------------------------------------------------------------
local Banner = Instance.new("TextButton")
Banner.Size = UDim2.new(1, -20, 0, 32)
Banner.Position = UDim2.new(0, 10, 0, 10)
Banner.Text = "Haz clic para copiar Discord: https://discord.gg/FDjHggJF"
Banner.TextColor3 = Colors.bg
Banner.BackgroundColor3 = Colors.neon
Banner.Font = Enum.Font.GothamBold
Banner.TextSize = 14
Banner.AutoButtonColor = false
Banner.Parent = Root
Banner.MouseButton1Click:Connect(function()
	safeSetClipboard("https://discord.gg/FDjHggJF")
end)

---------------------------------------------------------------------
-- Pestañas
---------------------------------------------------------------------
local TabMovimiento = addTab("Movimiento")
local TabAimbot = addTab("Aimbot")
local TabVisual = addTab("Visual")
local TabOtros = addTab("Otros")
local TabCred = addTab("Créditos")

vlist(TabMovimiento); vlist(TabAimbot); vlist(TabVisual); vlist(TabOtros); vlist(TabCred)

---------------------------------------------------------------------
-- Estado global / controles
---------------------------------------------------------------------
local Global = {
	Visible = true,
	AimbotOn = false,
	AimKey = Enum.UserInputType.MouseButton2, -- RMB por defecto
	AimHolding = false,
	AimIntensity = 50, -- 1..100
	FOVOn = true,
	FOVSize = 150,
	FOVColor = Color3.fromRGB(0,255,170),
	VisualOn = false,
	Noclip = false,
	Fly = false,
	FlySpeed = 60,
	InvisibleLocal = false,
	Freecam = false,
}

-- Tecla global L para mostrar/ocultar
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.L then
		Global.Visible = not Global.Visible
		Root.Visible = Global.Visible and authed
	end
end)

---------------------------------------------------------------------
-- Movimiento
---------------------------------------------------------------------
local slideWS = makeSlider("Velocidad de caminar", 8, 120, 16)
slideWS.Parent = TabMovimiento
slideWS:GetAttributeChangedSignal("Value"):Connect(function()
	local char = getCharacter(LP)
	local hum = humanoidOf(char)
	if hum then hum.WalkSpeed = slideWS:GetAttribute("Value") end
end)

local slideJump = makeSlider("Salto (multiplicador)", 0.9, 1.8, 1.0, 2)
slideJump.Parent = TabMovimiento
slideJump:GetAttributeChangedSignal("Value"):Connect(function()
	local char = getCharacter(LP)
	local hum = humanoidOf(char)
	if hum then
		local base = 50 -- base razonable
		hum.JumpPower = base * slideJump:GetAttribute("Value")
	end
end)

local toggleNoclip = makeToggle("Atravesar paredes (Noclip)", false)
toggleNoclip.Parent = TabMovimiento

toggleNoclip:GetAttributeChangedSignal("Value"):Connect(function()
	Global.Noclip = toggleNoclip:GetAttribute("Value")
end)

RunService.Stepped:Connect(function()
	if Global.Noclip then
		local char = LP.Character
		if char then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then part.CanCollide = false end
			end
		end
	end
end)

local toggleFly = makeToggle("Fly (WASD / Espacio / Ctrl)", false)
toggleFly.Parent = TabMovimiento

local slideFly = makeSlider("Velocidad de vuelo", 16, 240, 60)
slideFly.Parent = TabMovimiento

local flyDir = Vector3.new()
local flyConn
local function updateFlyInput()
	local dir = Vector3.new()
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then dir = dir - Vector3.new(0,1,0) end
	flyDir = dir.Magnitude > 0 and dir.Unit or Vector3.new()
end

UserInputService.InputBegan:Connect(function(_, gpe) if not gpe then updateFlyInput() end end)
UserInputService.InputEnded:Connect(function(_, gpe) if not gpe then updateFlyInput() end end)

local function setFly(on)
	Global.Fly = on
	if on then
		local char = getCharacter(LP)
		local root = getRoot(char)
		if not root then return end
		local hum = humanoidOf(char)
		if hum then hum.PlatformStand = true end
		if flyConn then flyConn:Disconnect() end
		flyConn = RunService.RenderStepped:Connect(function(dt)
			local speed = slideFly:GetAttribute("Value")
			updateFlyInput()
			if flyDir.Magnitude > 0 then
				root.Velocity = flyDir * speed
			else
				root.Velocity = Vector3.new(0,0,0)
			end
		end)
	else
		if flyConn then flyConn:Disconnect() flyConn = nil end
		local char = LP.Character
		local hum = humanoidOf(char)
		if hum then hum.PlatformStand = false end
	end
end

toggleFly:GetAttributeChangedSignal("Value"):Connect(function()
	setFly(toggleFly:GetAttribute("Value"))
end)

---------------------------------------------------------------------
-- Aimbot
---------------------------------------------------------------------
local toggleAim = makeToggle("Aimbot", false)
toggleAim.Parent = TabAimbot

toggleAim:GetAttributeChangedSignal("Value"):Connect(function()
	Global.AimbotOn = toggleAim:GetAttribute("Value")
end)

local keyBindBtn = makeButton("Cambiar tecla (actual: RMB)")
keyBindBtn.Parent = TabAimbot

local waitingKey = false
keyBindBtn.MouseButton1Click:Connect(function()
	if waitingKey then return end
	waitingKey = true
	keyBindBtn.Text = "Pulsa una tecla…"
	local conn
	conn = UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		waitingKey = false
		conn:Disconnect()
		Global.AimKey = input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 and input.UserInputType or input.KeyCode
		keyBindBtn.Text = "Tecla cambiada"
		wait(0.6)
		keyBindBtn.Text = "Cambiar tecla (actualizada)"
	end)
end)

-- Estado de pulsación de la tecla de aimbot
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if not Global.AimbotOn then return end
	if input.UserInputType == Global.AimKey or input.KeyCode == Global.AimKey then
		Global.AimHolding = true
	end
end)
UserInputService.InputEnded:Connect(function(input, gpe)
	if gpe then return end
	if input.UserInputType == Global.AimKey or input.KeyCode == Global.AimKey then
		Global.AimHolding = false
	end
end)

local slideIntensity = makeSlider("Intensidad", 1, 100, Global.AimIntensity)
slideIntensity.Parent = TabAimbot
slideIntensity:GetAttributeChangedSignal("Value"):Connect(function()
	Global.AimIntensity = slideIntensity:GetAttribute("Value")
end)

local toggleFOV = makeToggle("FOV Círculo", true)
toggleFOV.Parent = TabAimbot

toggleFOV:GetAttributeChangedSignal("Value"):Connect(function()
	Global.FOVOn = toggleFOV:GetAttribute("Value")
	if Global.FOVOn then FOVCircle.Visible = true else FOVCircle.Visible = false end
end)

local slideFOV = makeSlider("Tamaño FOV", 30, 500, Global.FOVSize)
slideFOV.Parent = TabAimbot
slideFOV:GetAttributeChangedSignal("Value"):Connect(function()
	Global.FOVSize = slideFOV:GetAttribute("Value")
end)

local colorPick = makeColorSlider("Color del círculo (RGB)", Global.FOVColor)
colorPick.Parent = TabAimbot
colorPick:GetAttributeChangedSignal("Color"):Connect(function()
	Global.FOVColor = colorPick:GetAttribute("Color")
end)

-- Círculo FOV
local FOVCircle = Instance.new("Frame")
FOVCircle.AnchorPoint = Vector2.new(0.5,0.5)
FOVCircle.Size = UDim2.fromOffset(Global.FOVSize*2, Global.FOVSize*2)
FOVCircle.Position = UDim2.fromScale(0.5, 0.5)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Visible = true
FOVCircle.Parent = ScreenGui
local FOVStroke = Instance.new("UIStroke")
FOVStroke.Thickness = 3
FOVStroke.LineJoinMode = Enum.LineJoinMode.Round
FOVStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
FOVStroke.Color = Global.FOVColor
FOVStroke.Parent = FOVCircle
local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(1,0) corner.Parent = FOVCircle

-- Actualiza tamaño/color del FOV en tiempo real
RunService.RenderStepped:Connect(function()
	FOVCircle.Size = UDim2.fromOffset(Global.FOVSize*2, Global.FOVSize*2)
	FOVStroke.Color = Global.FOVColor
end)

-- Lógica de aimbot (ignora Freecam / Scriptable)
RunService.RenderStepped:Connect(function(dt)
	if not Global.AimbotOn or not Global.AimHolding then return end
	if Camera.CameraType == Enum.CameraType.Scriptable then return end

	local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
	local bestDist = math.huge
	local bestHead

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LP and isEnemy(plr) then
			local char = plr.Character
			local head = char and char:FindFirstChild("Head")
			local hum = humanoidOf(char)
			if head and hum and hum.Health > 0 then
				local screenPos, onScreen = worldToScreen(head.Position)
				if onScreen then
					local dist = vec2Distance(screenPos, center)
					if dist <= Global.FOVSize and dist < bestDist then
						bestDist = dist
						bestHead = head
					end
				end
			end
		end
	end

	if bestHead then
		local targetPos = bestHead.Position
		local currentCF = Camera.CFrame
		local newCF = CFrame.new(currentCF.Position, targetPos)
		local t = clamp(Global.AimIntensity/100, 0.02, 0.95)
		Camera.CFrame = currentCF:Lerp(newCF, t)
	end
end)

---------------------------------------------------------------------
-- Visual (ESP + nombres + distancia)
---------------------------------------------------------------------
local toggleVisual = makeToggle("Visual (maestro)", false)
toggleVisual.Parent = TabVisual

toggleVisual:GetAttributeChangedSignal("Value"):Connect(function()
	Global.VisualOn = toggleVisual:GetAttribute("Value")
	if not Global.VisualOn then
		-- limpiar highlights y etiquetas
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LP and plr.Character then
				local h = plr.Character:FindFirstChildOfClass("Highlight")
				if h then h:Destroy() end
				local bg = plr.Character:FindFirstChild("FL_NameTag")
				if bg then bg:Destroy() end
			end
		end
	end
end)

local function ensureESP(plr)
	if not plr.Character then return end
	local enemy = isEnemy(plr)
	if not enemy then
		-- si hay equipos y es compañero, no marcamos
		local h = plr.Character:FindFirstChildOfClass("Highlight")
		if h then h:Destroy() end
		local bg = plr.Character:FindFirstChild("FL_NameTag")
		if bg then bg:Destroy() end
		return
	end
	-- Highlight rojo para enemigos
	local h = plr.Character:FindFirstChildOfClass("Highlight") or Instance.new("Highlight")
	h.FillTransparency = 1
	h.OutlineTransparency = 0
	h.OutlineColor = Color3.fromRGB(255, 45, 45)
	h.Parent = plr.Character
	-- Billboard con nombre y distancia
	local bg = plr.Character:FindFirstChild("FL_NameTag")
	if not bg then
		bg = Instance.new("BillboardGui")
		bg.Name = "FL_NameTag"
		bg.Size = UDim2.new(0, 200, 0, 40)
		bg.AlwaysOnTop = true
		bg.StudsOffset = Vector3.new(0, 3, 0)
		bg.Parent = plr.Character:FindFirstChild("Head") or plr.Character
		local tl = Instance.new("TextLabel")
		tl.BackgroundTransparency = 1
		tl.Size = UDim2.new(1,0,1,0)
		tl.Font = Enum.Font.GothamBold
		tl.TextStrokeTransparency = 0.2
		tl.TextSize = 14
		tl.TextColor3 = Color3.fromRGB(255, 80, 80)
		tl.Text = ""
		tl.Name = "NameText"
		tl.Parent = bg
	end
end

local function updateNameTag(plr)
	local bg = plr.Character and plr.Character:FindFirstChild("FL_NameTag")
	if not bg then return end
	local tl = bg:FindFirstChild("NameText")
	if not tl then return end
	local root = plr.Character and getRoot(plr.Character)
	local myRoot = getRoot(LP.Character or getCharacter(LP))
	local dist = (root and myRoot) and (root.Position - myRoot.Position).Magnitude or 0
	tl.Text = string.format("%s (@%s)  |  %dm", plr.DisplayName or plr.Name, plr.Name, math.floor(dist + 0.5))
end

RunService.RenderStepped:Connect(function()
	if not Global.VisualOn then return end
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LP then
			ensureESP(plr)
			updateNameTag(plr)
		end
	end
end)

Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function()
		if Global.VisualOn then ensureESP(plr) end
	end)
end)

---------------------------------------------------------------------
-- Otros: Invisible (local) y Freecam
---------------------------------------------------------------------
local toggleInv = makeToggle("Invisible (local)", false)
toggleInv.Parent = TabOtros

toggleInv:GetAttributeChangedSignal("Value"):Connect(function()
	Global.InvisibleLocal = toggleInv:GetAttribute("Value")
	local char = LP.Character
	if not char then return end
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			part.LocalTransparencyModifier = Global.InvisibleLocal and 1 or 0
		end
	end
end)

local toggleFree = makeToggle("Freecam / Foto", false)
toggleFree.Parent = TabOtros

local freeConn
local mouseDelta = Vector2.new()

UserInputService.InputChanged:Connect(function(input)
	if Global.Freecam and input.UserInputType == Enum.UserInputType.MouseMovement then
		mouseDelta = Vector2.new(input.Delta.X, input.Delta.Y)
	end
end)

local function setFreecam(on)
	Global.Freecam = on
	local char = LP.Character
	local root = char and getRoot(char)
	local hum = humanoidOf(char)
	if on then
		if root then root.Anchored = true end
		if hum then hum.AutoRotate = false end
		Camera.CameraType = Enum.CameraType.Scriptable
		local pos = (root and root.Position) or Camera.CFrame.Position
		local rot = Camera.CFrame - Camera.CFrame.Position
		local yaw, pitch = 0, 0
		mouseDelta = Vector2.new()
		if freeConn then freeConn:Disconnect() end
		freeConn = RunService.RenderStepped:Connect(function(dt)
			local move = Vector3.new()
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Vector3.new(0,0,-1) end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move + Vector3.new(0,0, 1) end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move + Vector3.new(-1,0,0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Vector3.new( 1,0,0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move + Vector3.new(0,-1,0) end
			local spd = 1 * (slideFly:GetAttribute("Value")/60)
			pos += (rot * move) * spd
			yaw -= mouseDelta.X * 0.0025
			pitch = clamp(pitch - mouseDelta.Y * 0.0025, -1.3, 1.3)
			local cf = CFrame.new(pos) * CFrame.Angles(0, yaw, 0) * CFrame.Angles(pitch, 0, 0)
			Camera.CFrame = cf
			mouseDelta = Vector2.new()
		end)
	else
		if freeConn then freeConn:Disconnect() freeConn = nil end
		if root then root.Anchored = false end
		if hum then hum.AutoRotate = true end
		Camera.CameraType = Enum.CameraType.Custom
	end
end

toggleFree:GetAttributeChangedSignal("Value"):Connect(function()
	setFreecam(toggleFree:GetAttribute("Value"))
end)

---------------------------------------------------------------------
-- Créditos
---------------------------------------------------------------------
local cred1 = Instance.new("TextLabel")
cred1.BackgroundTransparency = 1
cred1.Size = UDim2.new(1,-20,0,24)
cred1.TextXAlignment = Enum.TextXAlignment.Left
cred1.Font = Enum.Font.Gotham
cred1.TextSize = 16
cred1.TextColor3 = Colors.text
cred1.Text = "creador: by pedri.exe"
cred1.Parent = TabCred

local copyBtn = makeButton("Copiar Discord")
copyBtn.Parent = TabCred
copyBtn.MouseButton1Click:Connect(function()
	safeSetClipboard("https://discord.gg/FDjHggJF")
end)

local cred3 = Instance.new("TextLabel")
cred3.BackgroundTransparency = 1
cred3.Size = UDim2.new(1,-20,0,24)
cred3.TextXAlignment = Enum.TextXAlignment.Left
cred3.Font = Enum.Font.Gotham
cred3.TextSize = 16
cred3.TextColor3 = Colors.text
cred3.Text = "versión: 1.30.130"
cred3.Parent = TabCred

---------------------------------------------------------------------
-- Activación inicial / pestaña por defecto
---------------------------------------------------------------------
local function openDefaultTab()
	for _, t in pairs(Tabs) do t.page.Visible = false end
	Tabs["Movimiento"].page.Visible = true
end

local function postLogin()
	Root.Visible = true
	openDefaultTab()
end

-- Observa cambio de authed y abre UI
spawn(function()
	while true do
		if authed and not Root.Visible then
			postLogin()
			break
		end
		RunService.Heartbeat:Wait()
	end
end)

---------------------------------------------------------------------
-- Render info en footer de versión y toggle global
---------------------------------------------------------------------
local rightFooter = Instance.new("TextLabel")
rightFooter.BackgroundTransparency = 1
rightFooter.Size = UDim2.new(0, 220, 0, 24)
rightFooter.Position = UDim2.new(1, -230, 1, -28)
rightFooter.Font = Enum.Font.Gotham
rightFooter.TextSize = 14
rightFooter.TextColor3 = Colors.muted
rightFooter.TextXAlignment = Enum.TextXAlignment.Right
rightFooter.Text = "L: mostrar/ocultar  |  v1.30.130"
rightFooter.Parent = Root

---------------------------------------------------------------------
-- Fin
---------------------------------------------------------------------
