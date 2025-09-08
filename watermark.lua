--[[
UI Safe Aim-Trainer (SANTOWARE-like UI)
Autor: pedri.exe (versión segura, sin cheats PvP)
Lenguaje: Lua (Roblox LocalScript)

Qué hace (100% safe):
- UI estilo SANTOWARE (oscuro + acento rojo, sidebar con iconos, cards con bordes)
- Tecla global L: mostrar/ocultar menú
- Tecla "C": Toggle de Asistencia de Mira (SOLO a dianas de práctica)
- Dianas: Partes marcadas con CollectionService tag "AimTarget" (o hijos de workspace.AimTargets)
- Sliders: Intensidad (lerp), FOV con círculo y color RGB, WalkSpeed, Freecam de foto
- Nada interactúa con otros jugadores ni modifica server state

Instalación
- Pega este script en StarterPlayer -> StarterPlayerScripts
- Coloca dianas (Part/Attachment) y márcalas con el tag "AimTarget"; o crea carpeta workspace.AimTargets con tus Parts

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

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

---------------------------------------------------------------------
-- Utilidades
---------------------------------------------------------------------
local function clamp(x,a,b) return math.max(a, math.min(b,x)) end
local function worldToScreen(pos)
	local v, on = Camera:WorldToViewportPoint(pos)
	return Vector2.new(v.X, v.Y), on
end

---------------------------------------------------------------------
-- Tema (SANTOWARE-like)
---------------------------------------------------------------------
local Colors = {
	bg = Color3.fromRGB(12,12,14),
	panel = Color3.fromRGB(20,20,24),
	stroke = Color3.fromRGB(48,48,54),
	text = Color3.fromRGB(235,235,235),
	muted = Color3.fromRGB(150,150,160),
	accent = Color3.fromRGB(255,70,70) -- rojo acento
}

---------------------------------------------------------------------
-- Raíz GUI
---------------------------------------------------------------------
local Gui = Instance.new("ScreenGui")
Gui.Name = "SafeAimTrainerUI"
Gui.IgnoreGuiInset = true
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = LP:WaitForChild("PlayerGui")

local Root = Instance.new("Frame")
Root.Size = UDim2.new(0, 820, 0, 440)
Root.Position = UDim2.new(0.5, -410, 0.5, -220)
Root.BackgroundColor3 = Colors.panel
Root.BorderSizePixel = 0
Root.Parent = Gui

local RootStroke = Instance.new("UIStroke")
RootStroke.Thickness = 2
RootStroke.Color = Colors.accent
RootStroke.Parent = Root

-- Header
local Header = Instance.new("TextLabel")
Header.BackgroundTransparency = 1
Header.Size = UDim2.new(1,-20,0,36)
Header.Position = UDim2.new(0,10,0,8)
Header.Font = Enum.Font.GothamBlack
Header.TextSize = 22
Header.TextColor3 = Colors.text
Header.TextXAlignment = Enum.TextXAlignment.Left
Header.Text = "SANTOWARE.wtf — Safe UI"
Header.Parent = Root

-- Footer
local Footer = Instance.new("TextLabel")
Footer.BackgroundTransparency = 1
Footer.Size = UDim2.new(1,-20,0,22)
Footer.Position = UDim2.new(0,10,1,-26)
Footer.Font = Enum.Font.Gotham
Footer.TextSize = 14
Footer.TextColor3 = Colors.muted
Footer.TextXAlignment = Enum.TextXAlignment.Left
Footer.Text = string.format("%s (@%s)  ·  L: mostrar/ocultar  ·  C: Asistencia (toggle)", LP.DisplayName or LP.Name, LP.Name)
Footer.Parent = Root

-- Drag
local dragging=false; local dragStart; local startPos
Root.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging=true; dragStart=i.Position; startPos=Root.Position end
end)
Root.InputChanged:Connect(function(i)
	if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
		local d=i.Position-dragStart
		Root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
	end
end)
UserInputService.InputEnded:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
end)

-- Sidebar con iconos
local Sidebar = Instance.new("Frame")
Sidebar.BackgroundColor3 = Colors.bg
Sidebar.BorderSizePixel = 0
Sidebar.Size = UDim2.new(0, 64, 1, -70)
Sidebar.Position = UDim2.new(0, 10, 0, 50)
Sidebar.Parent = Root
local sbStroke = Instance.new("UIStroke") sbStroke.Color=Colors.stroke sbStroke.Thickness=2 sbStroke.Parent=Sidebar

local Content = Instance.new("Frame")
Content.BackgroundColor3 = Colors.bg
Content.BorderSizePixel = 0
Content.Size = UDim2.new(1, -94, 1, -70)
Content.Position = UDim2.new(0, 84, 0, 50)
Content.Parent = Root
local ctStroke = Instance.new("UIStroke") ctStroke.Color=Colors.stroke ctStroke.Thickness=2 ctStroke.Parent=Content

local function iconButton(emoji)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1,-12,0,48)
	b.Position = UDim2.new(0,6,0,0)
	b.Text = emoji
	b.BackgroundColor3 = Colors.panel
	b.TextColor3 = Colors.text
	b.Font = Enum.Font.GothamBlack
	b.TextSize = 22
	b.AutoButtonColor = false
	local s=Instance.new("UIStroke") s.Color=Colors.accent s.Thickness=2 s.Parent=b
	b.MouseEnter:Connect(function() TweenService:Create(b,TweenInfo.new(0.1),{BackgroundColor3=Colors.accent,TextColor3=Colors.bg}):Play() end)
	b.MouseLeave:Connect(function() TweenService:Create(b,TweenInfo.new(0.1),{BackgroundColor3=Colors.panel,TextColor3=Colors.text}):Play() end)
	return b
end

local pages = {}
local function addPage(emoji)
	local btn = iconButton(emoji); btn.Parent = Sidebar
	local pg = Instance.new("Frame")
	pg.BackgroundTransparency = 1
	pg.Size = UDim2.new(1,-20,1,-20)
	pg.Position = UDim2.new(0,10,0,10)
	pg.Visible=false
	pg.Parent = Content
	btn.MouseButton1Click:Connect(function()
		for _,x in pairs(pages) do x.Visible=false end
		pg.Visible=true
	end)
	table.insert(pages, pg)
	return pg
end

local sbLayout = Instance.new("UIListLayout") sbLayout.Parent=Sidebar sbLayout.Padding=UDim.new(0,8)

-- Páginas: General (⚙), Accuracy (🎯), Assist (🤖), Visual (👁), Créditos (⭐)
local PG_General = addPage("⚙")
local PG_Accuracy = addPage("🎯")
local PG_Assist  = addPage("🤖")
local PG_Visual  = addPage("👁")
local PG_Credits = addPage("⭐")

local function vlist(parent)
	local l=Instance.new("UIListLayout")
	l.Padding=UDim.new(0,10)
	l.SortOrder=Enum.SortOrder.LayoutOrder
	l.Parent=parent
end
vlist(PG_General); vlist(PG_Accuracy); vlist(PG_Assist); vlist(PG_Visual); vlist(PG_Credits)

-- Card helper
local function card(title)
	local c = Instance.new("Frame")
	c.BackgroundColor3 = Colors.panel
	c.BorderSizePixel = 0
	c.Size = UDim2.new(1,-20,0,150)
	local st = Instance.new("UIStroke") st.Color=Colors.accent st.Thickness=2 st.Parent=c
	local tl = Instance.new("TextLabel")
	tl.BackgroundTransparency=1; tl.Size=UDim2.new(1,-16,0,24); tl.Position=UDim2.new(0,8,0,6)
	tl.Font=Enum.Font.GothamBold; tl.TextSize=16; tl.TextColor3=Colors.text; tl.TextXAlignment=Enum.TextXAlignment.Left; tl.Text=title
	tl.Parent=c
	local body = Instance.new("Frame")
	body.BackgroundTransparency=1; body.Size=UDim2.new(1,-16,1,-34); body.Position=UDim2.new(0,8,0,30)
	local l=Instance.new("UIListLayout") l.Padding=UDim.new(0,8); l.Parent=body
	body.Parent=c
	return c, body
end

-- Controles básicos reutilizables -------------------------------------------------
local function toggleRow(txt, default)
	local r = Instance.new("Frame") r.BackgroundTransparency=1 r.Size=UDim2.new(1,0,0,30)
	local l=Instance.new("TextLabel") l.BackgroundTransparency=1 l.Size=UDim2.new(1,-80,1,0) l.Text=txt l.TextXAlignment=Enum.TextXAlignment.Left l.Font=Enum.Font.Gotham l.TextSize=16 l.TextColor3=Colors.text l.Parent=r
	local b=Instance.new("TextButton") b.Size=UDim2.new(0,70,0,26) b.Position=UDim2.new(1,-74,0.5,-13) b.Text= default and "ON" or "OFF" b.Font=Enum.Font.GothamBold b.TextSize=14 b.BackgroundColor3= default and Colors.accent or Colors.panel b.TextColor3= default and Colors.bg or Colors.text b.AutoButtonColor=false
	local s=Instance.new("UIStroke") s.Color=Colors.accent s.Thickness=2 s.Parent=b
	local state = default or false
	b.Parent=r
	b.MouseButton1Click:Connect(function()
		state = not state
		b.Text = state and "ON" or "OFF"
		TweenService:Create(b,TweenInfo.new(0.12),{BackgroundColor3= state and Colors.accent or Colors.panel, TextColor3= state and Colors.bg or Colors.text}):Play()
		r:SetAttribute("Value", state)
	end)
	r:SetAttribute("Value", state)
	return r
end

local function sliderRow(txt, min,max,default,decimals)
	local r = Instance.new("Frame") r.BackgroundTransparency=1 r.Size=UDim2.new(1,0,0,48)
	local l=Instance.new("TextLabel") l.BackgroundTransparency=1 l.Size=UDim2.new(1,0,0,18) l.Text=txt l.TextXAlignment=Enum.TextXAlignment.Left l.Font=Enum.Font.Gotham l.TextSize=16 l.TextColor3=Colors.text l.Parent=r
	local bar=Instance.new("Frame") bar.BackgroundColor3=Colors.panel bar.BorderSizePixel=0 bar.Size=UDim2.new(1,-80,0,10) bar.Position=UDim2.new(0,0,0,22) bar.Parent=r
	local bst=Instance.new("UIStroke") bst.Color=Colors.stroke bst.Thickness=2 bst.Parent=bar
	local fill=Instance.new("Frame") fill.BackgroundColor3=Colors.accent fill.BorderSizePixel=0 fill.Size=UDim2.new(0,0,1,0) fill.Parent=bar
	local knob=Instance.new("Frame") knob.BackgroundColor3=Colors.accent knob.BorderSizePixel=0 knob.Size=UDim2.new(0,14,0,18) knob.Position=UDim2.new(0,-7,0.5,-9) knob.Parent=bar
	local valLbl=Instance.new("TextLabel") valLbl.BackgroundTransparency=1 valLbl.Size=UDim2.new(0,70,0,20) valLbl.Position=UDim2.new(1,-70,0,16) valLbl.Font=Enum.Font.GothamSemibold valLbl.TextSize=14 valLbl.TextColor3=Colors.text valLbl.TextXAlignment=Enum.TextXAlignment.Right valLbl.Parent=r
	local val=default or min
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
	-- init
	local initAlpha = (val-min)/(max-min) setAlpha(initAlpha)
	bar.InputBegan:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 then
			local conn; conn = RunService.RenderStepped:Connect(function()
				local ap = bar.AbsolutePosition.X; local as = bar.AbsoluteSize.X
				local mx = UserInputService:GetMouseLocation().X
				setAlpha((mx-ap)/as)
			end)
			local endConn; endConn = UserInputService.InputEnded:Connect(function(ii)
				if ii.UserInputType==Enum.UserInputType.MouseButton1 then conn:Disconnect() endConn:Disconnect() end
			end)
		end
	end)
	return r
end

---------------------------------------------------------------------
-- General
---------------------------------------------------------------------
local cardGen, gen = card("General") cardGen.Parent = PG_General
local tVisible = toggleRow("UI Enable", true) tVisible.Parent = gen

-- Toggle L para mostrar/ocultar
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.L then
		local on = not Root.Visible
		Root.Visible = on
		tVisible:SetAttribute("Value", on)
	end
end)

-- WalkSpeed local
local wsSlider = sliderRow("WalkSpeed", 8, 120, 16) wsSlider.Parent = gen
wsSlider:GetAttributeChangedSignal("Value"):Connect(function()
	local char = LP.Character or LP.CharacterAdded:Wait()
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then hum.WalkSpeed = wsSlider:GetAttribute("Value") end
end)

---------------------------------------------------------------------
-- Accuracy (FOV + color)
---------------------------------------------------------------------
local cardAcc, acc = card("Accuracy") cardAcc.Parent = PG_Accuracy
local fovToggle = toggleRow("FOV Circle", true) fovToggle.Parent = acc
local fovSize = sliderRow("FOV Size", 30, 500, 180) fovSize.Parent = acc

local colorCard, colorBody = card("FOV Color (RGB)") colorCard.Parent = PG_Accuracy colorCard.Size = UDim2.new(1,-20,0,180)
local rS = sliderRow("R", 0,255, 255) rS.Parent=colorBody
local gS = sliderRow("G", 0,255, 70)  gS.Parent=colorBody
local bS = sliderRow("B", 0,255, 70)  bS.Parent=colorBody

-- FOV circle
local FOVCircle = Instance.new("Frame")
FOVCircle.AnchorPoint = Vector2.new(0.5,0.5)
FOVCircle.Size = UDim2.fromOffset(fovSize:GetAttribute("Value")*2, fovSize:GetAttribute("Value")*2)
FOVCircle.Position = UDim2.fromScale(0.5, 0.5)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Visible = true
FOVCircle.Parent = Gui
local FStroke = Instance.new("UIStroke") FStroke.Thickness=2 FStroke.Parent=FOVCircle
local corner = Instance.new("UICorner") corner.CornerRadius=UDim.new(1,0) corner.Parent=FOVCircle

RunService.RenderStepped:Connect(function()
	FOVCircle.Visible = fovToggle:GetAttribute("Value") and Root.Visible
	FOVCircle.Size = UDim2.fromOffset(fovSize:GetAttribute("Value")*2, fovSize:GetAttribute("Value")*2)
	FStroke.Color = Color3.fromRGB(rS:GetAttribute("Value"), gS:GetAttribute("Value"), bS:GetAttribute("Value"))
end)

---------------------------------------------------------------------
-- Assist (Aim-Trainer local, tecla C toggle)
---------------------------------------------------------------------
local cardAssist, asBody = card("Assist (local)") cardAssist.Parent = PG_Assist
local tAssist = toggleRow("Aim Assist (toggle C)", false) tAssist.Parent = asBody
local intensity = sliderRow("Intensity", 1, 100, 50) intensity.Parent = asBody

-- Keybind C para toggle
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.C then
		local on = not tAssist:GetAttribute("Value")
		tAssist:SetAttribute("Value", on)
		local btn = tAssist:FindFirstChildOfClass("TextButton")
		if btn then
			btn.Text = on and "ON" or "OFF"
			TweenService:Create(btn,TweenInfo.new(0.12),{BackgroundColor3= on and Colors.accent or Colors.panel, TextColor3= on and Color3.new(0,0,0) or Colors.text}):Play()
		end
	end
end)

-- Recolector de dianas (solo entrenamiento)
local function getTargets()
	local arr = {}
	for _,p in ipairs(CollectionService:GetTagged("AimTarget")) do table.insert(arr,p) end
	local folder = workspace:FindFirstChild("AimTargets")
	if folder then for _,p in ipairs(folder:GetDescendants()) do if p:IsA("BasePart") then table.insert(arr,p) end end end
	return arr
end

RunService.RenderStepped:Connect(function()
	if not tAssist:GetAttribute("Value") then return end
	if Camera.CameraType == Enum.CameraType.Scriptable then return end
	local targets = getTargets()
	if #targets == 0 then return end
	local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
	local best, bestDist
	for _,part in ipairs(targets) do
		local pos = part.Position
		local scr, on = worldToScreen(pos)
		if on then
			local d = (scr - center).Magnitude
			if fovToggle:GetAttribute("Value") then
				if d <= fovSize:GetAttribute("Value") and (not bestDist or d < bestDist) then best=part bestDist=d end
			else
				if not bestDist or d < bestDist then best=part bestDist=d end
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
-- Visual / Freecam de foto
---------------------------------------------------------------------
local cardVis, visBody = card("Visual") cardVis.Parent = PG_Visual
local tFree = toggleRow("Photo Freecam", false) tFree.Parent = visBody
local spd = sliderRow("Move speed", 8, 240, 60) spd.Parent = visBody

local freeConn; local dir = Vector3.new()
local function updateDir()
	dir = Vector3.new()
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += Camera.CFrame.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= Camera.CFrame.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= Camera.CFrame.RightVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += Camera.CFrame.RightVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end
end
UserInputService.InputBegan:Connect(function(_,g) if not g then updateDir() end end)
UserInputService.InputEnded:Connect(function(_,g) if not g then updateDir() end end)

local function setFree(on)
	if on then
		local char = LP.Character or LP.CharacterAdded:Wait()
		local root = char:FindFirstChild("HumanoidRootPart")
		if root then root.Anchored = true end
		local hum = char:FindFirstChildOfClass("Humanoid") if hum then hum.AutoRotate=false end
		Camera.CameraType = Enum.CameraType.Scriptable
		freeConn = RunService.RenderStepped:Connect(function()
			updateDir()
			local v = dir.Magnitude>0 and dir.Unit or Vector3.new()
			Camera.CFrame += v * (spd:GetAttribute("Value") * RunService.RenderStepped:Wait())
		end)
	else
		if freeConn then freeConn:Disconnect() freeConn=nil end
		Camera.CameraType = Enum.CameraType.Custom
		local char = LP.Character
		if char then
			local root = char:FindFirstChild("HumanoidRootPart")
			local hum = char:FindFirstChildOfClass("Humanoid")
			if root then root.Anchored=false end
			if hum then hum.AutoRotate=true end
		end
	end
end

tFree:GetAttributeChangedSignal("Value"):Connect(function() setFree(tFree:GetAttribute("Value")) end)

---------------------------------------------------------------------
-- Créditos
---------------------------------------------------------------------
local cardCr, cr = card("Credits") cardCr.Parent = PG_Credits
local label = Instance.new("TextLabel")
label.BackgroundTransparency=1; label.Size=UDim2.new(1,0,0,24)
label.Font=Enum.Font.Gotham; label.TextSize=16; label.TextColor3=Colors.text; label.TextXAlignment=Enum.TextXAlignment.Left
label.Text = "by pedri.exe  ·  versión segura 1.0.0"
label.Parent = cr

---------------------------------------------------------------------
-- Estado inicial
---------------------------------------------------------------------
for i,pg in ipairs(pages) do pg.Visible = (i==1) end
