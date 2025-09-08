--[[
Foxxy's Leaks — Admin Menu (SANTOWARE-style)
Autor: pedri.exe
Lenguaje: Lua (Roblox LocalScript)

⚠️ Ética/uso: interfaz pensada para tus propios juegos/zonas de prueba. Nada de afectar a otros jugadores.
- "Aimbot" aquí es una asistencia de mira **solo para dianas de práctica** (tags `AimTarget` o carpeta `workspace.AimTargets`).

Qué incluye (según pedido)
- Login “duro” con key HJGL-FKSS, entra directo al login.
- Menú móvil, arrastrable; tecla global L para mostrar/ocultar.
- Sidebar por pestañas: Movimiento, Aimbot, Visual, Otros y Créditos.
- Animaciones hover/click, estilo oscuro con acento rojo (tipo captura), “sliders duros”.
- Pie con DisplayName (@Username).
- Banner clicable que copia el Discord.

Controles
- Mostrar/Ocultar: tecla L.
- Mover: arrastrar el contenedor.
- Aimbot seguro: tecla C = **toggle** (queda activo hasta volver a pulsar).

Movimiento
- WalkSpeed (8–120). Salto multiplicador (x0.9–x1.8). Noclip ON/OFF. Fly ON/OFF con WASD + Space/Ctrl y slider de velocidad (16–240).

Aimbot (práctica)
- ON/OFF.
- Tecla C toggle (no necesitas mantener).
- Intensidad (1–100) = cuánto “pega” la cámara.
- FOV: círculo ON/OFF, tamaño (30–500) y color RGB.
- Target: diana más cercana dentro del FOV (ignora Freecam).

Visual
- ON/OFF maestro.
- Highlight rojo de objetos con tag `AimTarget` o `EnemyNPC`.
- Nombres + distancia (si el objeto tiene `Name` o `DisplayName`).

Otros
- Invisible (local) y Freecam/Foto (cámara libre; ancla el cuerpo).

Créditos
- creador: by pedri.exe
- discord: https://discord.gg/FDjHggJF (botón copia)
- versión: 1.30.130
--]]

---------------------------------------------------------------------
-- Servicios
---------------------------------------------------------------------
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local CollectionService = game:GetService("CollectionService")
local Teams = game:GetService("Teams")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

---------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------
local function clamp(x,a,b) return math.max(a, math.min(b,x)) end
local function safeSetClipboard(text)
	pcall(function() if setclipboard then setclipboard(text) end end)
end
local function getChar(p) return p.Character or p.CharacterAdded:Wait() end
local function getRoot(c) return c and c:FindFirstChild("HumanoidRootPart") end
local function hum(c) return c and c:FindFirstChildOfClass("Humanoid") end
local function w2s(pos) local v,on = Camera:WorldToViewportPoint(pos); return Vector2.new(v.X,v.Y), on end

---------------------------------------------------------------------
-- Tema (oscuro + acento rojo, estilo captura)
---------------------------------------------------------------------
local Colors = {
	bg = Color3.fromRGB(12,12,14),
	panel = Color3.fromRGB(20,20,24),
	stroke = Color3.fromRGB(48,48,54),
	text = Color3.fromRGB(235,235,235),
	muted = Color3.fromRGB(150,150,160),
	accent = Color3.fromRGB(255,70,70)
}

---------------------------------------------------------------------
-- UI raíz
---------------------------------------------------------------------
local Gui = Instance.new("ScreenGui")
Gui.Name = "FoxxysLeaksAdmin_SANTO"
Gui.IgnoreGuiInset = true
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = LP:WaitForChild("PlayerGui")

---------------------------------------------------------------------
-- Login
---------------------------------------------------------------------
local KEY = "HJGL-FKSS"
local authed = false

local Login = Instance.new("Frame")
Login.Size = UDim2.new(1,0,1,0)
Login.BackgroundColor3 = Colors.bg
Login.BorderSizePixel = 0
Login.Parent = Gui

local Box = Instance.new("Frame")
Box.AnchorPoint = Vector2.new(0.5,0.5)
Box.Position = UDim2.new(0.5,0,0.5,0)
Box.Size = UDim2.new(0, 420, 0, 220)
Box.BackgroundColor3 = Colors.panel
Box.BorderSizePixel = 0
Box.Parent = Login
local BoxStroke = Instance.new("UIStroke") BoxStroke.Color=Colors.accent BoxStroke.Thickness=2 BoxStroke.Parent=Box

local LTitle = Instance.new("TextLabel")
LTitle.BackgroundTransparency=1
LTitle.Position = UDim2.new(0,12,0,12)
LTitle.Size = UDim2.new(1,-24,0,30)
LTitle.Font = Enum.Font.GothamBlack
LTitle.TextSize = 22
LTitle.TextColor3 = Colors.text
LTitle.TextXAlignment = Enum.TextXAlignment.Left
LTitle.Text = "Foxxy's Leaks — Login"
LTitle.Parent = Box

local KeyBox = Instance.new("TextBox")
KeyBox.BackgroundColor3 = Colors.bg
KeyBox.BorderSizePixel = 0
KeyBox.Position = UDim2.new(0,12,0,60)
KeyBox.Size = UDim2.new(1,-24,0,42)
KeyBox.Font = Enum.Font.GothamSemibold
KeyBox.TextSize = 18
KeyBox.TextColor3 = Colors.text
KeyBox.ClearTextOnFocus = false
KeyBox.PlaceholderText = "Introduce la key"
KeyBox.Parent = Box
local KeyStroke = Instance.new("UIStroke") KeyStroke.Color=Colors.stroke KeyStroke.Thickness=2 KeyStroke.Parent=KeyBox

local EnterBtn = Instance.new("TextButton")
EnterBtn.BackgroundColor3 = Colors.accent
EnterBtn.AutoButtonColor = false
EnterBtn.Position = UDim2.new(0,12,0,112)
EnterBtn.Size = UDim2.new(1,-24,0,42)
EnterBtn.Font = Enum.Font.GothamBlack
EnterBtn.TextSize = 18
EnterBtn.TextColor3 = Colors.bg
EnterBtn.Text = "ENTRAR"
EnterBtn.Parent = Box
local EStroke = Instance.new("UIStroke") EStroke.Color=Colors.accent EStroke.Thickness=2 EStroke.Parent=EnterBtn

local Info = Instance.new("TextLabel")
Info.BackgroundTransparency=1
Info.Position = UDim2.new(0,12,1,-30)
Info.Size = UDim2.new(1,-24,0,20)
Info.Font = Enum.Font.Gotham
Info.TextXAlignment = Enum.TextXAlignment.Left
Info.TextSize = 14
Info.TextColor3 = Colors.muted
Info.Text = "Tema oscuro/acento rojo. Entra directo al login."
Info.Parent = Box

local function pulse(btn)
	local s = btn.Size
	local t1 = TweenService:Create(btn,TweenInfo.new(0.08,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=s+UDim2.new(0,6,0,6)})
	local t2 = TweenService:Create(btn,TweenInfo.new(0.08,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Size=s})
	t1:Play(); t1.Completed:Wait(); t2:Play()
end

local function tryLogin()
	if KeyBox.Text == KEY then
		authed = true
		pulse(EnterBtn)
		Login.Visible = false
	else
		Info.TextColor3 = Colors.accent; Info.Text = "Key incorrecta"
	end
end
EnterBtn.MouseButton1Click:Connect(tryLogin)
KeyBox.FocusLost:Connect(function(enter) if enter then tryLogin() end end)

---------------------------------------------------------------------
-- Marco principal
---------------------------------------------------------------------
local Root = Instance.new("Frame")
Root.Size = UDim2.new(0, 860, 0, 470)
Root.Position = UDim2.new(0.5, -430, 0.5, -235)
Root.BackgroundColor3 = Colors.panel
Root.BorderSizePixel = 0
Root.Visible = false
Root.Parent = Gui
local RootStroke = Instance.new("UIStroke") RootStroke.Color=Colors.accent RootStroke.Thickness=2 RootStroke.Parent=Root

-- Drag
local dragging=false; local dragStart; local startPos
Root.InputBegan:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; dragStart=i.Position; startPos=Root.Position end
end)
Root.InputChanged:Connect(function(i)
	if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
		local d=i.Position-dragStart
		Root.Position = UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
	end
end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)

-- Header y Footer
local Header = Instance.new("TextLabel")
Header.BackgroundTransparency=1
Header.Position = UDim2.new(0,10,0,8)
Header.Size = UDim2.new(1,-20,0,34)
Header.Font = Enum.Font.GothamBlack
Header.TextSize = 22
Header.TextColor3 = Colors.text
Header.TextXAlignment = Enum.TextXAlignment.Left
Header.Text = "Foxxy's Leaks — Admin Menu"
Header.Parent = Root

local Footer = Instance.new("TextLabel")
Footer.BackgroundTransparency=1
Footer.Position = UDim2.new(0,10,1,-26)
Footer.Size = UDim2.new(1,-20,0,20)
Footer.Font = Enum.Font.Gotham
Footer.TextSize = 14
Footer.TextColor3 = Colors.muted
Footer.TextXAlignment = Enum.TextXAlignment.Left
Footer.Text = string.format("%s (@%s)", LP.DisplayName or LP.Name, LP.Name)
Footer.Parent = Root

-- Banner (Discord)
local Banner = Instance.new("TextButton")
Banner.BackgroundColor3 = Colors.accent
Banner.AutoButtonColor=false
Banner.Position = UDim2.new(0,10,0,44)
Banner.Size = UDim2.new(1,-20,0,30)
Banner.Text = "Haz clic para copiar Discord: https://discord.gg/FDjHggJF"
Banner.TextColor3 = Colors.bg
Banner.Font = Enum.Font.GothamBold
Banner.TextSize = 14
Banner.Parent = Root
local BStroke = Instance.new("UIStroke") BStroke.Color=Colors.accent BStroke.Thickness=2 BStroke.Parent=Banner
Banner.MouseButton1Click:Connect(function() safeSetClipboard("https://discord.gg/FDjHggJF") end)

-- Sidebar (iconos) y contenido
local Sidebar = Instance.new("Frame")
Sidebar.BackgroundColor3 = Colors.bg
Sidebar.BorderSizePixel=0
Sidebar.Position = UDim2.new(0,10,0,84)
Sidebar.Size = UDim2.new(0, 64, 1, -120)
Sidebar.Parent = Root
local sbStroke = Instance.new("UIStroke") sbStroke.Color=Colors.stroke sbStroke.Thickness=2 sbStroke.Parent=Sidebar

local Content = Instance.new("Frame")
Content.BackgroundColor3 = Colors.bg
Content.BorderSizePixel=0
Content.Position = UDim2.new(0, 84, 0, 84)
Content.Size = UDim2.new(1, -104, 1, -120)
Content.Parent = Root
local ctStroke = Instance.new("UIStroke") ctStroke.Color=Colors.stroke ctStroke.Thickness=2 ctStroke.Parent=Content

local function iconBtn(emoji)
	local b=Instance.new("TextButton")
	b.Size = UDim2.new(1,-12,0,48)
	b.Position = UDim2.new(0,6,0,0)
	b.Text = emoji
	b.BackgroundColor3 = Colors.panel
	b.TextColor3 = Colors.text
	b.Font = Enum.Font.GothamBlack
	b.TextSize = 22
	b.AutoButtonColor=false
	local s=Instance.new("UIStroke") s.Color=Colors.accent s.Thickness=2 s.Parent=b
	b.MouseEnter:Connect(function() TweenService:Create(b,TweenInfo.new(0.1),{BackgroundColor3=Colors.accent,TextColor3=Colors.bg}):Play() end)
	b.MouseLeave:Connect(function() TweenService:Create(b,TweenInfo.new(0.1),{BackgroundColor3=Colors.panel,TextColor3=Colors.text}):Play() end)
	return b
end

local pages = {}
local function addPage(emoji)
	local btn = iconBtn(emoji) btn.Parent=Sidebar
	local pg = Instance.new("Frame")
	pg.BackgroundTransparency=1
	pg.Size = UDim2.new(1,-20,1,-20)
	pg.Position = UDim2.new(0,10,0,10)
	pg.Visible=false
	pg.Parent = Content
	btn.MouseButton1Click:Connect(function()
		for _,p in pairs(pages) do p.Visible=false end
		pg.Visible=true
	end)
	table.insert(pages, pg)
	return pg
end

local layout = Instance.new("UIListLayout") layout.Parent = Sidebar layout.Padding=UDim.new(0,8)

-- Pestañas (⚙ mov, 🎯 aimbot, 👁 visual, 🧰 otros, ⭐ créditos)
local TabMov = addPage("⚙")
local TabAim = addPage("🎯")
local TabVis = addPage("👁")
local TabOtr = addPage("🧰")
local TabCre = addPage("⭐")

local function vlist(parent) local l=Instance.new("UIListLayout") l.Padding=UDim.new(0,10) l.Parent=parent end
vlist(TabMov); vlist(TabAim); vlist(TabVis); vlist(TabOtr); vlist(TabCre)

-- Card helper (estética panel con borde rojo)
local function card(title, h)
	local c = Instance.new("Frame")
	c.BackgroundColor3 = Colors.panel
	c.BorderSizePixel = 0
	c.Size = UDim2.new(1,-20,0,h or 160)
	local st = Instance.new("UIStroke") st.Color=Colors.accent st.Thickness=2 st.Parent=c
	local tl = Instance.new("TextLabel") tl.BackgroundTransparency=1 tl.Size=UDim2.new(1,-16,0,24) tl.Position=UDim2.new(0,8,0,6)
	tl.Font=Enum.Font.GothamBold tl.TextSize=16 tl.TextColor3=Colors.text tl.TextXAlignment=Enum.TextXAlignment.Left tl.Text=title tl.Parent=c
	local body = Instance.new("Frame") body.BackgroundTransparency=1 body.Size=UDim2.new(1,-16,1,-34) body.Position=UDim2.new(0,8,0,30) body.Parent=c
	local l=Instance.new("UIListLayout") l.Padding=UDim.new(0,8) l.Parent=body
	return c, body
end

-- Controles comunes -------------------------------------------------------------
local function toggleRow(txt, default)
	local r = Instance.new("Frame") r.BackgroundTransparency=1 r.Size=UDim2.new(1,0,0,30)
	local l=Instance.new("TextLabel") l.BackgroundTransparency=1 l.Size=UDim2.new(1,-90,1,0) l.Text=txt l.TextXAlignment=Enum.TextXAlignment.Left l.Font=Enum.Font.Gotham l.TextSize=16 l.TextColor3=Colors.text l.Parent=r
	local b=Instance.new("TextButton") b.Size=UDim2.new(0,74,0,26) b.Position=UDim2.new(1,-78,0.5,-13) b.Text= default and "ON" or "OFF" b.Font=Enum.Font.GothamBold b.TextSize=14 b.BackgroundColor3= default and Colors.accent or Colors.panel b.TextColor3= default and Colors.bg or Colors.text b.AutoButtonColor=false b.Parent=r
	local s=Instance.new("UIStroke") s.Color=Colors.accent s.Thickness=2 s.Parent=b
	local state = default or false
	b.MouseButton1Click:Connect(function()
		state = not state
		b.Text = state and "ON" or "OFF"
		TweenService:Create(b,TweenInfo.new(0.12),{BackgroundColor3= state and Colors.accent or Colors.panel, TextColor3= state and Colors.bg or Colors.text}):Play()
		r:SetAttribute("Value", state)
	end)
	r:SetAttribute("Value", state)
	return r
end

local function sliderRow(txt,min,max,default,decimals)
	local r = Instance.new("Frame") r.BackgroundTransparency=1 r.Size=UDim2.new(1,0,0,48)
	local l=Instance.new("TextLabel") l.BackgroundTransparency=1 l.Size=UDim2.new(1,0,0,18) l.Text=txt l.TextXAlignment=Enum.TextXAlignment.Left l.Font=Enum.Font.Gotham l.TextSize=16 l.TextColor3=Colors.text l.Parent=r
	local bar=Instance.new("Frame") bar.BackgroundColor3=Colors.panel bar.BorderSizePixel=0 bar.Size=UDim2.new(1,-90,0,10) bar.Position=UDim2.new(0,0,0,22) bar.Parent=r
	local bst=Instance.new("UIStroke") bst.Color=Colors.stroke bst.Thickness=2 bst.Parent=bar
	local fill=Instance.new("Frame") fill.BackgroundColor3=Colors.accent fill.BorderSizePixel=0 fill.Size=UDim2.new(0,0,1,0) fill.Parent=bar
	local knob=Instance.new("Frame") knob.BackgroundColor3=Colors.accent knob.BorderSizePixel=0 knob.Size=UDim2.new(0,14,0,18) knob.Position=UDim2.new(0,-7,0.5,-9) knob.Parent=bar
	local valLbl=Instance.new("TextLabel") valLbl.BackgroundTransparency=1 valLbl.Size=UDim2.new(0,80,0,20) valLbl.Position=UDim2.new(1,-80,0,16) valLbl.Font=Enum.Font.GothamSemibold valLbl.TextSize=14 valLbl.TextColor3=Colors.text valLbl.TextXAlignment=Enum.TextXAlignment.Right valLbl.Parent=r
	local val = default or min
	local function setAlpha(alpha)
		alpha = clamp(alpha,0,1)
		val = min + (max-min)*alpha
		if decimals and decimals>0 then local m=10^decimals val = math.floor(val*m+0.5)/m else val = math.floor(val+0.5) end
		local px = math.floor(alpha*(bar.AbsoluteSize.X)+0.5)
		fill.Size = UDim2.new(0,px,1,0)
		knob.Position = UDim2.new(0,px-7,0.5,-9)
		valLbl.Text = tostring(val)
		r:SetAttribute("Value", val)
	end
	local init = (val-min)/(max-min) setAlpha(init)
	bar.InputBegan:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 then
			local drag; drag = RunService.RenderStepped:Connect(function()
				local ap=bar.AbsolutePosition.X; local as=bar.AbsoluteSize.X; local mx=UserInputService:GetMouseLocation().X
				setAlpha((mx-ap)/as)
			end)
			local endc; endc = UserInputService.InputEnded:Connect(function(ii)
				if ii.UserInputType==Enum.UserInputType.MouseButton1 then drag:Disconnect() endc:Disconnect() end
			end)
		end
	end)
	return r
end

---------------------------------------------------------------------
-- Movimiento
---------------------------------------------------------------------
local cMov, mov = card("Movimiento", 200) cMov.Parent = TabMov
local ws = sliderRow("Velocidad de caminar", 8, 120, 16) ws.Parent = mov
ws:GetAttributeChangedSignal("Value"):Connect(function()
	local ch=getChar(LP) local h=hum(ch) if h then h.WalkSpeed = ws:GetAttribute("Value") end
end)

local jump = sliderRow("Salto (multiplicador)", 0.9, 1.8, 1.0, 2) jump.Parent = mov
jump:GetAttributeChangedSignal("Value"):Connect(function()
	local ch=getChar(LP) local h=hum(ch) if h then h.JumpPower = 50 * jump:GetAttribute("Value") end
end)

local tNoclip = toggleRow("Atravesar paredes (Noclip)", false) tNoclip.Parent = mov
RunService.Stepped:Connect(function()
	if tNoclip:GetAttribute("Value") then
		local ch = LP.Character
		if ch then for _,p in ipairs(ch:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end
	end
end)

local tFly = toggleRow("Fly (WASD / Espacio / Ctrl)", false) tFly.Parent = mov
local flySpeed = sliderRow("Velocidad de vuelo", 16, 240, 60) flySpeed.Parent = mov
local flyConn; local dir=Vector3.new()
local function updDir()
	dir = Vector3.new()
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir+=Camera.CFrame.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir-=Camera.CFrame.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir-=Camera.CFrame.RightVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir+=Camera.CFrame.RightVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir+=Vector3.new(0,1,0) end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir-=Vector3.new(0,1,0) end
end
UserInputService.InputBegan:Connect(function(_,g) if not g then updDir() end end)
UserInputService.InputEnded:Connect(function(_,g) if not g then updDir() end end)

local function setFly(on)
	if on then
		local ch=getChar(LP) local r=getRoot(ch) local h=hum(ch) if h then h.PlatformStand=true end
		if flyConn then flyConn:Disconnect() end
		flyConn = RunService.RenderStepped:Connect(function(dt)
			updDir()
			local v = dir.Magnitude>0 and dir.Unit or Vector3.new()
			if r then r.Velocity = v * flySpeed:GetAttribute("Value") end
		end)
	else
		if flyConn then flyConn:Disconnect() flyConn=nil end
		local ch=LP.Character local h=hum(ch) if h then h.PlatformStand=false end
	end
end

tFly:GetAttributeChangedSignal("Value"):Connect(function() setFly(tFly:GetAttribute("Value")) end)

---------------------------------------------------------------------
-- Aimbot (seguro a dianas) + FOV y color
---------------------------------------------------------------------
local cAim, aim = card("Aimbot (práctica)", 280) cAim.Parent = TabAim
local tAim = toggleRow("Aimbot ON/OFF", false) tAim.Parent = aim
local intensity = sliderRow("Intensidad", 1, 100, 50) intensity.Parent = aim
local tFOV = toggleRow("FOV Círculo", true) tFOV.Parent = aim
local sFOV = sliderRow("Tamaño FOV", 30, 500, 180) sFOV.Parent = aim

local cColor, col = card("Color FOV (RGB)", 180) cColor.Parent = TabAim
local rS = sliderRow("R", 0,255, 255) rS.Parent = col
local gS = sliderRow("G", 0,255, 70)  gS.Parent = col
local bS = sliderRow("B", 0,255, 70)  bS.Parent = col

-- Estado de la tecla C (toggle, no mantener)
local AimHolding = false
UserInputService.InputBegan:Connect(function(input, g)
	if g then return end
	if input.KeyCode == Enum.KeyCode.C then
		AimHolding = not AimHolding
	end
end)

-- FOV circle
local FOVCircle = Instance.new("Frame")
FOVCircle.AnchorPoint = Vector2.new(0.5,0.5)
FOVCircle.Size = UDim2.fromOffset(sFOV:GetAttribute("Value")*2, sFOV:GetAttribute("Value")*2)
FOVCircle.Position = UDim2.fromScale(0.5, 0.5)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Visible = true
FOVCircle.Parent = Gui
local FS = Instance.new("UIStroke") FS.Thickness=2 FS.Parent=FOVCircle
local corner = Instance.new("UICorner") corner.CornerRadius=UDim.new(1,0) corner.Parent=FOVCircle

RunService.RenderStepped:Connect(function()
	FOVCircle.Visible = tFOV:GetAttribute("Value") and Root.Visible
	FOVCircle.Size = UDim2.fromOffset(sFOV:GetAttribute("Value")*2, sFOV:GetAttribute("Value")*2)
	FS.Color = Color3.fromRGB(rS:GetAttribute("Value"), gS:GetAttribute("Value"), bS:GetAttribute("Value"))
end)

local function getTargets()
	local arr = {}
	for _,p in ipairs(CollectionService:GetTagged("AimTarget")) do table.insert(arr,p) end
	local folder = workspace:FindFirstChild("AimTargets")
	if folder then for _,p in ipairs(folder:GetDescendants()) do if p:IsA("BasePart") then table.insert(arr,p) end end end
	return arr
end

RunService.RenderStepped:Connect(function()
	if not tAim:GetAttribute("Value") or not AimHolding then return end
	if Camera.CameraType == Enum.CameraType.Scriptable then return end
	local targets = getTargets() if #targets==0 then return end
	local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
	local best; local bestDist=math.huge
	for _,part in ipairs(targets) do
		local scr,on = w2s(part.Position)
		if on then
			local d = (scr-center).Magnitude
			if (not tFOV:GetAttribute("Value")) or d <= sFOV:GetAttribute("Value") then
				if d < bestDist then best=part bestDist=d end
			end
		end
	end
	if best then
		local t = clamp(intensity:GetAttribute("Value")/100, 0.02, 0.95)
		local current = Camera.CFrame
		local desired = CFrame.new(current.Position, best.Position)
		Camera.CFrame = current:Lerp(desired, t)
	end
end)

---------------------------------------------------------------------
-- Visual (resalta dianas / NPCs) + nombre y distancia
---------------------------------------------------------------------
local cVis, vbody = card("Visual", 160) cVis.Parent = TabVis
local tVis = toggleRow("Visual ON/OFF (maestro)", false) tVis.Parent = vbody

local function ensureESPFor(part)
	local model = part:IsA("Model") and part or part:FindFirstAncestorOfClass("Model") or part
	if not model then return end
	local h = model:FindFirstChildOfClass("Highlight")
	if not h then h = Instance.new("Highlight") h.Parent = model end
	h.FillTransparency = 1; h.OutlineTransparency = 0; h.OutlineColor = Color3.fromRGB(255,60,60)
	local head = model:FindFirstChild("Head") or model:FindFirstChildWhichIsA("BasePart")
	if head and not head:FindFirstChild("FL_NameTag") then
		local bg = Instance.new("BillboardGui") bg.Name="FL_NameTag" bg.AlwaysOnTop=true bg.Size=UDim2.new(0,200,0,24) bg.StudsOffset=Vector3.new(0,3,0) bg.Parent=head
		local tl = Instance.new("TextLabel") tl.BackgroundTransparency=1 tl.Size=UDim2.new(1,0,1,0) tl.Font=Enum.Font.GothamBold tl.TextSize=14 tl.TextStrokeTransparency=0.2 tl.TextColor3=Color3.fromRGB(255,80,80) tl.Text = model.Name tl.Parent=bg
	end
end

local function updateTag(part)
	local model = part:IsA("Model") and part or part:FindFirstAncestorOfClass("Model") or part
	local head = model and (model:FindFirstChild("Head") or model:FindFirstChildWhichIsA("BasePart"))
	local myRoot = getRoot(getChar(LP))
	if not head or not myRoot then return end
	local bg = head:FindFirstChild("FL_NameTag") if not bg then return end
	local tl = bg:FindFirstChildOfClass("TextLabel") if not tl then return end
	local dist = (head.Position - myRoot.Position).Magnitude
	tl.Text = string.format("%s  |  %dm", model.Name, math.floor(dist+0.5))
end

RunService.RenderStepped:Connect(function()
	if not tVis:GetAttribute("Value") then return end
	local parts = {}
	for _,p in ipairs(CollectionService:GetTagged("AimTarget")) do table.insert(parts,p) end
	for _,p in ipairs(CollectionService:GetTagged("EnemyNPC")) do table.insert(parts,p) end
	local folder = workspace:FindFirstChild("AimTargets") if folder then for _,p in ipairs(folder:GetDescendants()) do if p:IsA("BasePart") then table.insert(parts,p) end end end
	for _,p in ipairs(parts) do ensureESPFor(p); updateTag(p) end
end)

---------------------------------------------------------------------
-- Otros: Invisible (local) + Freecam
---------------------------------------------------------------------
local cOtr, obody = card("Otros", 150) cOtr.Parent = TabOtr
local tInv = toggleRow("Invisible (local)", false) tInv.Parent = obody
local tFree = toggleRow("Freecam / Foto", false) tFree.Parent = obody
local spd = sliderRow("Velocidad Freecam", 8, 240, 60) spd.Parent = obody

local freeConn; local md = Vector2.new()
UserInputService.InputChanged:Connect(function(i)
	if tFree:GetAttribute("Value") and i.UserInputType==Enum.UserInputType.MouseMovement then md = Vector2.new(i.Delta.X, i.Delta.Y) end
end)

tInv:GetAttributeChangedSignal("Value"):Connect(function()
	local ch=LP.Character if not ch then return end
	for _,p in ipairs(ch:GetDescendants()) do if p:IsA("BasePart") then p.LocalTransparencyModifier = tInv:GetAttribute("Value") and 1 or 0 end end
end)

local function setFree(on)
	local ch = LP.Character or LP.CharacterAdded:Wait()
	local root = getRoot(ch)
	local h = hum(ch)
	if on then
		if root then root.Anchored=true end
		if h then h.AutoRotate=false end
		Camera.CameraType = Enum.CameraType.Scriptable
		local pos = (root and root.Position) or Camera.CFrame.Position
		local yaw,pitch = 0,0
		if freeConn then freeConn:Disconnect() end
		freeConn = RunService.RenderStepped:Connect(function(dt)
			local move = Vector3.new()
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then move+=Vector3.new(0,0,-1) end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then move+=Vector3.new(0,0,1) end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then move+=Vector3.new(-1,0,0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then move+=Vector3.new(1,0,0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move+=Vector3.new(0,1,0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move+=Vector3.new(0,-1,0) end
			local sp = spd:GetAttribute("Value") * dt * 6
			pos += (Camera.CFrame:VectorToWorldSpace(move)) * sp
			yaw -= md.X * 0.0025
			pitch = clamp(pitch - md.Y * 0.0025, -1.3, 1.3)
			Camera.CFrame = CFrame.new(pos) * CFrame.Angles(0,yaw,0) * CFrame.Angles(pitch,0,0)
			md = Vector2.new()
		end)
	else
		if freeConn then freeConn:Disconnect() freeConn=nil end
		Camera.CameraType = Enum.CameraType.Custom
		if root then root.Anchored=false end
		if h then h.AutoRotate=true end
	end
end

tFree:GetAttributeChangedSignal("Value"):Connect(function() setFree(tFree:GetAttribute("Value")) end)

---------------------------------------------------------------------
-- Créditos
---------------------------------------------------------------------
local cCre, cr = card("Créditos", 130) cCre.Parent = TabCre
local l1 = Instance.new("TextLabel") l1.BackgroundTransparency=1 l1.Size=UDim2.new(1,0,0,22) l1.Font=Enum.Font.Gotham l1.TextSize=16 l1.TextColor3=Colors.text l1.TextXAlignment=Enum.TextXAlignment.Left l1.Text = "creador: by pedri.exe" l1.Parent = cr
local copy = Instance.new("TextButton") copy.Size=UDim2.new(0,180,0,28) copy.Text="Copiar Discord" copy.Font=Enum.Font.GothamBold copy.TextSize=14 copy.BackgroundColor3=Colors.accent copy.TextColor3=Colors.bg copy.AutoButtonColor=false copy.Parent=cr
local cs = Instance.new("UIStroke") cs.Color=Colors.accent cs.Thickness=2 cs.Parent=copy
copy.MouseButton1Click:Connect(function() safeSetClipboard("https://discord.gg/FDjHggJF") end)
local l3 = Instance.new("TextLabel") l3.BackgroundTransparency=1 l3.Size=UDim2.new(1,0,0,22) l3.Font=Enum.Font.Gotham l3.TextSize=16 l3.TextColor3=Colors.text l3.TextXAlignment=Enum.TextXAlignment.Left l3.Text = "versión: 1.30.130" l3.Parent = cr

---------------------------------------------------------------------
-- Toggle global L y activación tras login
---------------------------------------------------------------------
UserInputService.InputBegan:Connect(function(i,g) if g then return end if i.KeyCode==Enum.KeyCode.L then Root.Visible = not Root.Visible end end)

spawn(function()
	while true do
		if authed and not Root.Visible then Root.Visible=true for i,pg in ipairs(pages) do pg.Visible = (i==1) end break end
		RunService.Heartbeat:Wait()
	end
end)

-- Fin
