--// Foxxy's Leaks — Admin/Debug UI (para TU experiencia)
--// Login con efecto (blur + scale) -> 5 menús: Movimiento, Aimbot, Visual, Créditos, Otros
--// Fondo de estrellas, tecla L para ocultar/mostrar
--// Pie: "programador: by pedri.exe" + Usuario actual

-------------------------
--    CONFIGURACIÓN    --
-------------------------
local ACCESS_KEY = "HJGL-FKSS"

-- Restringe a tus lugares/usuarios (opcional). Déjalo vacío para no restringir.
local ALLOWED_PLACE_IDS = { }
local ALLOWED_USER_IDS = { }

-- Velocidad (WalkSpeed)
local SPEED_MIN, SPEED_MAX, SPEED_DEFAULT = 8, 100, 16

-- Salto (multiplicador via slider)
local JUMP_MULT_MIN, JUMP_MULT_MAX, JUMP_MULT_DEFAULT = 0.9, 1.6, 1.25
local JUMP_MAX_ABS_ADD = 28 -- tope de aumento absoluto

-- Noclip anti-rebote
local NOCLIP_CORRECTION_FACTOR = 0.85

-- Fly (slider propio)
local FLY_SPEED_MIN, FLY_SPEED_MAX, FLY_SPEED_DEFAULT = 16, 200, 64
local FLY_TILT_STIFFNESS = 8  -- suavidad para orientar hacia la cámara

-- Freecam (modo foto)
local FC_SPEED_DEFAULT = 40     -- velocidad base
local FC_SENS = Vector2.new(0.003, 0.003) -- sensibilidad mouse (x, y)

-- Aimbot
local AIM_FOV_MIN, AIM_FOV_MAX, AIM_FOV_DEFAULT = 30, 500, 200
local AIM_SMOOTH = 0.22 -- suavizado de giro (0=instantáneo, 1=muy lento)

-- Discord y logo
local DISCORD_LINK = "https://discord.gg/xQbpCEgz9E"
local LOGO_URL = "https://cdn.discordapp.com/attachments/1392752518148395119/1413517337851592805/c851ab41-8a9e-4458-8235-cf4479d3a0ce.png?ex=68be325b&is=68bce0db&hm=2b8ce5b8398729a2f08ecf597497755d416755ae837ba8e4ee2da72e915f9edc&"
local LOGO_ASSET_ID = "rbxassetid://0000000000" -- <- REEMPLAZA por tu assetId cuando subas el decal

-------------------------
--      SERVICIOS      --
-------------------------
local Players   = game:GetService("Players")
local UIS       = game:GetService("UserInputService")
local TS        = game:GetService("TweenService")
local RS        = game:GetService("RunService")
local SG        = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local Lighting  = game:GetService("Lighting")

local lp = Players.LocalPlayer

-------------------------
--      GUARDAS        --
-------------------------
local function isAllowedPlace()
    if #ALLOWED_PLACE_IDS == 0 then return true end
    for _,id in ipairs(ALLOWED_PLACE_IDS) do if id == game.PlaceId then return true end end
    return false
end
local function isAllowedUser()
    if #ALLOWED_USER_IDS == 0 then return true end
    for _,id in ipairs(ALLOWED_USER_IDS) do if id == lp.UserId then return true end end
    return false
end
if not isAllowedPlace() or not isAllowedUser() then
    warn("[FoxxysLeaks] No autorizado en este lugar/usuario. Configura ALLOWED_* en el script.")
    return
end

-------------------------
--       GUI BASE      --
-------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "FoxyLeaksUI"
gui.ResetOnSpawn = false
pcall(function() gui.Parent = game.CoreGui end)
if not gui.Parent then gui.Parent = lp:WaitForChild("PlayerGui") end

-------------------------
--     LOGIN (KEY)     --
-------------------------
-- Overlay + blur + estilo nuevo
local loginOverlay = Instance.new("Frame")
loginOverlay.Size = UDim2.fromScale(1,1)
loginOverlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
loginOverlay.BackgroundTransparency = 0.25
loginOverlay.ZIndex = 10
loginOverlay.Parent = gui

local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = Lighting
TS:Create(blur, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = 12}):Play()

local loginFrame = Instance.new("Frame")
loginFrame.Size = UDim2.fromOffset(380, 190)
loginFrame.Position = UDim2.new(0.5, -190, 0.35, 0)
loginFrame.BackgroundColor3 = Color3.fromRGB(18,18,26)
loginFrame.BorderSizePixel = 0
loginFrame.ZIndex = 11
loginFrame.Parent = gui
Instance.new("UICorner", loginFrame).CornerRadius = UDim.new(0, 16)

-- Degradado + borde brillante
local lfGrad = Instance.new("UIGradient", loginFrame)
lfGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(28,28,42)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(12,12,20))
}
lfGrad.Rotation = 90
local lfStroke = Instance.new("UIStroke", loginFrame)
lfStroke.Thickness = 1.4
lfStroke.Transparency = 0.35
local lfSGrad = Instance.new("UIGradient", lfStroke)
lfSGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(120,70,220)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(70,150,255))
}

-- Animación de escala
local lfScale = Instance.new("UIScale", loginFrame)
lfScale.Scale = 0.85
TS:Create(lfScale, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1}):Play()

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(235,235,255)
title.Text = "Foxxy's Leaks — Login"
title.Size = UDim2.new(1, -20, 0, 32)
title.Position = UDim2.new(0, 10, 0, 10)
title.ZIndex = 12
title.Parent = loginFrame

local keyBox = Instance.new("TextBox")
keyBox.Size = UDim2.new(1, -20, 0, 38)
keyBox.Position = UDim2.new(0, 10, 0, 58)
keyBox.BackgroundColor3 = Color3.fromRGB(28,28,38)
keyBox.TextColor3 = Color3.fromRGB(255,255,255)
keyBox.PlaceholderText = "Ingresa la key"
keyBox.Text = ""
keyBox.ClearTextOnFocus = false
keyBox.Font = Enum.Font.Gotham
keyBox.TextSize = 14
keyBox.ZIndex = 12
keyBox.Parent = loginFrame
Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 10)
local kbStroke = Instance.new("UIStroke", keyBox)
kbStroke.Thickness = 1
kbStroke.Color = Color3.fromRGB(70,120,220)
kbStroke.Transparency = 0.35

local loginBtn = Instance.new("TextButton")
loginBtn.Size = UDim2.new(1, -20, 0, 38)
loginBtn.Position = UDim2.new(0, 10, 0, 108)
loginBtn.BackgroundColor3 = Color3.fromRGB(45,130,90)
loginBtn.TextColor3 = Color3.fromRGB(255,255,255)
loginBtn.Font = Enum.Font.GothamBold
loginBtn.TextSize = 14
loginBtn.Text = "Entrar"
loginBtn.ZIndex = 12
loginBtn.Parent = loginFrame
Instance.new("UICorner", loginBtn).CornerRadius = UDim.new(0, 10)

local info = Instance.new("TextLabel")
info.BackgroundTransparency = 1
info.TextColor3 = Color3.fromRGB(180,180,200)
info.Font = Enum.Font.Gotham
info.TextSize = 12
info.Text = "Key requerida para continuar"
info.Size = UDim2.new(1, -20, 0, 16)
info.Position = UDim2.new(0, 10, 1, -22)
info.ZIndex = 12
info.Parent = loginFrame

local function toast(txt, dur)
    pcall(function()
        SG:SetCore("SendNotification", {
            Title = "Foxxy's Leaks";
            Text = txt;
            Duration = dur or 5;
        })
    end)
end

-- Banner clicable (copia al hacer clic) — duración 9s
local function clickableBanner(message, link, duration)
    duration = duration or 9
    local banner = Instance.new("TextButton")
    banner.AutoButtonColor = true
    banner.Text = message .. "  (clic para copiar)"
    banner.Font = Enum.Font.GothamSemibold
    banner.TextSize = 14
    banner.TextXAlignment = Enum.TextXAlignment.Left
    banner.TextColor3 = Color3.fromRGB(235,235,255)
    banner.Size = UDim2.new(1, -20, 0, 36)
    banner.Position = UDim2.new(0, 10, 0, -40)
    banner.BackgroundColor3 = Color3.fromRGB(28,28,40)
    banner.BorderSizePixel = 0
    banner.ZIndex = 100
    banner.Parent = gui
    Instance.new("UICorner", banner).CornerRadius = UDim.new(0, 8)

    TS:Create(banner, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Position = UDim2.new(0, 10, 0, 10)}):Play()

    banner.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(link)
            banner.Text = "¡Copiado! " .. link
        end
    end)

    task.delay(duration, function()
        if banner and banner.Parent then
            TS:Create(banner, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                {Position = UDim2.new(0, 10, 0, -40)}):Play()
            task.delay(0.25, function() if banner then banner:Destroy() end end)
        end
    end)
end

-------------------------
--  VENTANA PRINCIPAL  --
-------------------------
local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(560, 0)
main.Position = UDim2.new(0.5, -280, 0.2, 0)
main.BackgroundColor3 = Color3.fromRGB(12,12,18)
main.BorderSizePixel = 0
main.Visible = false
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 16)

-- Degradado + trazo como el login
local mainGrad = Instance.new("UIGradient", main)
mainGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(22,22,34)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10,10,16))
}
mainGrad.Rotation = 90
local mainStroke = Instance.new("UIStroke", main)
mainStroke.Thickness = 1.25
mainStroke.Transparency = 0.35
local strokeGrad = Instance.new("UIGradient", mainStroke)
strokeGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(120,70,180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(70,120,220))
}

-- Capa de estrellas (fondo)
local starLayer = Instance.new("Frame")
starLayer.BackgroundTransparency = 1
starLayer.Size = UDim2.fromScale(1,1)
starLayer.ClipsDescendants = true
starLayer.ZIndex = 0
starLayer.Parent = main

-- Contenido
local content = Instance.new("Frame")
content.BackgroundTransparency = 1
content.Size = UDim2.fromScale(1,1)
content.ZIndex = 2
content.Parent = main

-- TopBar con logo + título + glow
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 52)
topBar.BackgroundColor3 = Color3.fromRGB(16,16,24)
topBar.BorderSizePixel = 0
topBar.ZIndex = 3
topBar.Parent = content
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 16)

local logo = Instance.new("ImageLabel")
logo.BackgroundTransparency = 1
logo.Size = UDim2.fromOffset(40, 40)
logo.Position = UDim2.new(0, 10, 0.5, -20)
logo.ZIndex = 4
logo.Parent = topBar
local okLogo = pcall(function() logo.Image = LOGO_URL end)
if not okLogo then logo.Image = LOGO_ASSET_ID end

local titleMain = Instance.new("TextLabel")
titleMain.BackgroundTransparency = 1
titleMain.Size = UDim2.new(1, -70, 1, 0)
titleMain.Position = UDim2.new(0, 60, 0, 0)
titleMain.Font = Enum.Font.GothamBold
titleMain.TextSize = 16
titleMain.TextXAlignment = Enum.TextXAlignment.Left
titleMain.TextColor3 = Color3.fromRGB(220,220,255)
titleMain.Text = "Foxxy's Leaks  —  [L para ocultar/mostrar]"
titleMain.ZIndex = 4
titleMain.Parent = topBar

-- Pie con crédito + usuario
local footer = Instance.new("TextLabel")
footer.BackgroundTransparency = 1
footer.Size = UDim2.new(1, -16, 0, 32)
footer.Position = UDim2.new(0, 8, 1, -34)
footer.Font = Enum.Font.Gotham
footer.TextSize = 12
footer.TextXAlignment = Enum.TextXAlignment.Center
footer.TextColor3 = Color3.fromRGB(160,160,190)
footer.Text = "programador: by pedri.exe  |  Usuario: (cargando...)"
footer.ZIndex = 4
footer.Parent = content

task.defer(function()
    footer.Text = string.format("programador: by pedri.exe  |  Usuario: %s (@%s)", lp.DisplayName, lp.Name)
end)

-- Drag ventana
do
    local dragging, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
    topBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = inp.Position
            startPos = main.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            update(inp)
        end
    end)
end

-- Tabs
local tabs = Instance.new("Frame")
tabs.Size = UDim2.new(1, -20, 0, 36)
tabs.Position = UDim2.new(0, 10, 0, 60)
tabs.BackgroundTransparency = 1
tabs.ZIndex = 3
tabs.Parent = content

local gridTabs = Instance.new("UIListLayout")
gridTabs.FillDirection = Enum.FillDirection.Horizontal
gridTabs.Padding = UDim.new(0, 8)
gridTabs.Parent = tabs

local function makeTabBtn(text)
    local b = Instance.new("TextButton")
    b.AutoButtonColor = true
    b.Size = UDim2.fromOffset(130, 32)
    b.BackgroundColor3 = Color3.fromRGB(28,28,40)
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.Text = text
    b.ZIndex = 4
    b.Parent = tabs
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
    local st = Instance.new("UIStroke", b); st.Thickness = 1; st.Transparency = 0.5
    st.Color = Color3.fromRGB(60,60, ninety or 90)
    st.Color = Color3.fromRGB(60,60,90)
    return b
end

local tabMove   = makeTabBtn("Movimiento")
local tabAimbot = makeTabBtn("Aimbot")
local tabVisual = makeTabBtn("Visual")
local tabCred   = makeTabBtn("Créditos")
local tabOtros  = makeTabBtn("Otros")

local pages = Instance.new("Frame")
pages.Size = UDim2.new(1, -20, 1, -60-36-18)
pages.Position = UDim2.new(0, 10, 0, 60+36+8)
pages.BackgroundTransparency = 1
pages.ZIndex = 3
pages.Parent = content

local pageMove  = Instance.new("Frame"); pageMove.BackgroundTransparency=1; pageMove.Size=UDim2.new(1,0,1,0); pageMove.ZIndex=3; pageMove.Parent=pages
local pageAimb  = Instance.new("Frame"); pageAimb.BackgroundTransparency=1; pageAimb.Size=UDim2.new(1,0,1,0); pageAimb.Visible=false; pageAimb.ZIndex=3; pageAimb.Parent=pages
local pageVisual= Instance.new("Frame"); pageVisual.BackgroundTransparency=1; pageVisual.Size=UDim2.new(1,0,1,0); pageVisual.Visible=false; pageVisual.ZIndex=3; pageVisual.Parent=pages
local pageCred  = Instance.new("Frame"); pageCred.BackgroundTransparency=1; pageCred.Size=UDim2.new(1,0,1,0); pageCred.Visible=false; pageCred.ZIndex=3; pageCred.Parent=pages
local pageOtros = Instance.new("Frame"); pageOtros.BackgroundTransparency=1; pageOtros.Size=UDim2.new(1,0,1,0); pageOtros.Visible=false; pageOtros.ZIndex=3; pageOtros.Parent=pages

local function switchTo(which)
    pageMove.Visible   = (which == "move")
    pageAimb.Visible   = (which == "aimb")
    pageVisual.Visible = (which == "visual")
    pageCred.Visible   = (which == "cred")
    pageOtros.Visible  = (which == "otros")
end
tabMove.MouseButton1Click:Connect(function() switchTo("move") end)
tabAimbot.MouseButton1Click:Connect(function() switchTo("aimb") end)
tabVisual.MouseButton1Click:Connect(function() switchTo("visual") end)
tabCred.MouseButton1Click:Connect(function() switchTo("cred") end)
tabOtros.MouseButton1Click:Connect(function() switchTo("otros") end)

-------------------------
--  ESTRELLAS (fondo)  --
-------------------------
local function spawnStars(container, count)
    if container.AbsoluteSize.X < 1 then task.wait() end
    local w, h = container.AbsoluteSize.X, container.AbsoluteSize.Y
    for _=1, count do
        local s = Instance.new("Frame")
        s.Size = UDim2.fromOffset(math.random(2,4), math.random(2,4))
        s.Position = UDim2.fromOffset(math.random(0, w), math.random(-h, h))
        s.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        s.BackgroundTransparency = math.random() * 0.3
        s.BorderSizePixel = 0
        s.ZIndex = 1
        Instance.new("UICorner", s).CornerRadius = UDim.new(1,0)
        s.Parent = container

        task.spawn(function()
            while s.Parent do
                local endY = h + 10
                local dur = math.random(4,9) + math.random()
                TS:Create(s, TweenInfo.new(dur, Enum.EasingStyle.Linear),
                    {Position = UDim2.fromOffset(s.Position.X.Offset, endY)}):Play()
                task.wait(dur)
                s.Position = UDim2.fromOffset(math.random(0, w), -10)
            end
        end)
    end
end
spawnStars(starLayer, 90)

-------------------------
--   UTILIDADES UI     --
-------------------------
local function makeBtn(parent, text, y)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -20, 0, 36)
    b.Position = UDim2.new(0, 10, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(28,28,40)
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.Text = text
    b.ZIndex = 4
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    return b
end
local function setBtnState(b, label, on)
    b.Text = label .. (on and "ON" or "OFF")
    b.BackgroundColor3 = on and Color3.fromRGB(45,130,90) or Color3.fromRGB(120,50,50)
end
local function makeSlider(parent, y, color3)
    local back = Instance.new("Frame")
    back.Size = UDim2.new(1, -20, 0, 10)
    back.Position = UDim2.new(0, 10, 0, y)
    back.BackgroundColor3 = Color3.fromRGB(42,42,60)
    back.BorderSizePixel = 0
    back.ZIndex = 3
    back.Parent = parent
    Instance.new("UICorner", back).CornerRadius = UDim.new(0, 6)
    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(14, 18)
    knob.BackgroundColor3 = color3 or Color3.fromRGB(120,120,120)
    knob.BorderSizePixel = 0
    knob.ZIndex = 4
    knob.Parent = back
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    return back, knob
end
local function relFromVal(val, minv, maxv) return (val - minv) / (maxv - minv) end
local function valFromRel(rel, minv, maxv) return (minv + rel*(maxv - minv)) end

-------------------------
--   MOVIMIENTO (UI)   --
-------------------------
-- Slider caminar
local sliderBack = makeSlider(pageMove, 10, Color3.fromRGB(45,130,90))
local sliderKnob = sliderBack:FindFirstChildWhichIsA("Frame")
sliderKnob.Position = UDim2.new((SPEED_DEFAULT-SPEED_MIN)/(SPEED_MAX-SPEED_MIN), -7, 0.5, -9)

local speedLabel = Instance.new("TextLabel")
speedLabel.BackgroundTransparency = 1
speedLabel.Position = UDim2.new(0, 10, 0, 32)
speedLabel.Size = UDim2.new(1, -20, 0, 20)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 14
speedLabel.TextColor3 = Color3.fromRGB(235,235,255)
speedLabel.Text = ("Velocidad: %d"):format(SPEED_DEFAULT)
speedLabel.ZIndex = 4
speedLabel.Parent = pageMove

local currentSpeed = SPEED_DEFAULT
local function setSpeed(v)
    v = math.clamp(math.floor(v + 0.5), SPEED_MIN, SPEED_MAX)
    currentSpeed = v
    speedLabel.Text = ("Velocidad: %d"):format(v)
    local char = lp.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = v end
end
setSpeed(SPEED_DEFAULT)

do -- drag/click caminar
    local dragging = false
    local function update(x)
        local rel = math.clamp((x - sliderBack.AbsolutePosition.X)/sliderBack.AbsoluteSize.X, 0, 1)
        sliderKnob.Position = UDim2.new(rel, -7, 0.5, -9)
        setSpeed(SPEED_MIN + rel*(SPEED_MAX - SPEED_MIN))
    end
    sliderKnob.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            inp.Changed:Connect(function() if inp.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    UIS.InputChanged:Connect(function(inp) if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then update(inp.Position.X) end end)
    sliderBack.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then update(inp.Position.X) end end)
end

-- Slider salto
local jumpBack = makeSlider(pageMove, 70, Color3.fromRGB(90,120,200))
local jumpKnob = jumpBack:FindFirstChildWhichIsA("Frame")
jumpKnob.Position = UDim2.new((JUMP_MULT_DEFAULT-JUMP_MULT_MIN)/(JUMP_MULT_MAX-JUMP_MULT_MIN), -7, 0.5, -9)

local jumpLabel = Instance.new("TextLabel")
jumpLabel.BackgroundTransparency = 1
jumpLabel.Position = UDim2.new(0, 10, 0, 92)
jumpLabel.Size = UDim2.new(1, -20, 0, 20)
jumpLabel.Font = Enum.Font.Gotham
jumpLabel.TextSize = 14
jumpLabel.TextColor3 = Color3.fromRGB(235,235,255)
jumpLabel.ZIndex = 4
jumpLabel.Parent = pageMove

local baseRecorded = false
local baseUseJumpPower, baseJumpPower, baseJumpHeight
local jumpMult = JUMP_MULT_DEFAULT
local function recordBaseJump(hum)
    if baseRecorded then return end
    baseUseJumpPower = hum.UseJumpPower
    if baseUseJumpPower then baseJumpPower = hum.JumpPower else baseJumpHeight = hum.JumpHeight end
    baseRecorded = true
end
local function applyJump(hum)
    if not hum then return end
    recordBaseJump(hum)
    if baseUseJumpPower then
        local target = math.min(baseJumpPower + JUMP_MAX_ABS_ADD, baseJumpPower * jumpMult)
        hum.JumpPower = target
        jumpLabel.Text = string.format("Salto: x%.2f  (%d)", jumpMult, math.floor(target + 0.5))
    else
        local target = math.min(baseJumpHeight + (JUMP_MAX_ABS_ADD/8), baseJumpHeight * jumpMult)
        hum.JumpHeight = target
        jumpLabel.Text = string.format("Salto: x%.2f", jumpMult)
    end
end
local function setJumpByRel(rel)
    jumpMult = JUMP_MULT_MIN + rel * (JUMP_MULT_MAX - JUMP_MULT_MIN)
    local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
    if hum then applyJump(hum) end
    jumpKnob.Position = UDim2.new(rel, -7, 0.5, -9)
end
setJumpByRel((JUMP_MULT_DEFAULT-JUMP_MULT_MIN)/(JUMP_MULT_MAX-JUMP_MULT_MIN))
do
    local dragging=false
    local function update(x)
        local rel = math.clamp((x - jumpBack.AbsolutePosition.X)/jumpBack.AbsoluteSize.X, 0, 1)
        setJumpByRel(rel)
    end
    jumpKnob.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            dragging=true
            inp.Changed:Connect(function() if inp.UserInputState==Enum.UserInputState.End then dragging=false end end)
        end
    end)
    UIS.InputChanged:Connect(function(inp) if dragging and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then update(inp.Position.X) end end)
    jumpBack.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then update(inp.Position.X) end end)
end

-- Slider velocidad de vuelo
local flyBack = makeSlider(pageMove, 130, Color3.fromRGB(200,140,90))
local flyKnob = flyBack:FindFirstChildWhichIsA("Frame")
local flyLabel = Instance.new("TextLabel")
flyLabel.BackgroundTransparency = 1
flyLabel.Position = UDim2.new(0, 10, 0, 152)
flyLabel.Size = UDim2.new(1, -20, 0, 20)
flyLabel.Font = Enum.Font.Gotham
flyLabel.TextSize = 14
flyLabel.TextColor3 = Color3.fromRGB(235,235,255)
flyLabel.ZIndex = 4
flyLabel.Parent = pageMove

local flySpeed = FLY_SPEED_DEFAULT
local function setFlySpeed(v)
    v = math.clamp(math.floor(v + 0.5), FLY_SPEED_MIN, FLY_SPEED_MAX)
    flySpeed = v
    flyLabel.Text = ("Velocidad de vuelo: %d"):format(v)
end
do
    local rel = relFromVal(FLY_SPEED_DEFAULT, FLY_SPEED_MIN, FLY_SPEED_MAX)
    flyKnob.Position = UDim2.new(rel, -7, 0.5, -9)
    setFlySpeed(FLY_SPEED_DEFAULT)
end
do
    local dragging=false
    local function update(x)
        local rel = math.clamp((x - flyBack.AbsolutePosition.X)/flyBack.AbsoluteSize.X, 0, 1)
        flyKnob.Position = UDim2.new(rel, -7, 0.5, -9)
        setFlySpeed(math.floor(valFromRel(rel, FLY_SPEED_MIN, FLY_SPEED_MAX)+0.5))
    end
    flyKnob.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            dragging=true
            inp.Changed:Connect(function() if inp.UserInputState==Enum.UserInputState.End then dragging=false end end)
        end
    end)
    UIS.InputChanged:Connect(function(inp) if dragging and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then update(inp.Position.X) end end)
    flyBack.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then update(inp.Position.X) end end)
end

-- Noclip
local noclipOn=false
local hbConn, steppedConn
local originalCollide = {}
local function getHum()
    local c = lp.Character
    return c and c:FindFirstChildOfClass("Humanoid"), c and c:FindFirstChild("HumanoidRootPart")
end
local function cacheDefaults(char)
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") and originalCollide[p] == nil then originalCollide[p] = p.CanCollide end
    end
end
local function setCharCollision(char, can)
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = can; p.CanTouch = not can end
    end
end
local function enableNoclip()
    noclipOn = true
    local char = lp.Character
    if char then cacheDefaults(char); setCharCollision(char, false) end
    if steppedConn then steppedConn:Disconnect() end
    steppedConn = RS.Stepped:Connect(function()
        if not noclipOn then return end
        local c = lp.Character; if not c then return end
        for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
    end)
    if hbConn then hbConn:Disconnect() end
    hbConn = RS.Heartbeat:Connect(function(dt)
        if not noclipOn then return end
        local hum, hrp = getHum(); if not (hum and hrp) then return end
        local dir = hum.MoveDirection
        if dir.Magnitude > 0 then
            local corr = dir.Unit * (hum.WalkSpeed * dt * NOCLIP_CORRECTION_FACTOR)
            hrp.CFrame = hrp.CFrame + Vector3.new(corr.X, 0, corr.Z)
        end
        hrp.AssemblyAngularVelocity = Vector3.new()
    end)
end
local function disableNoclip()
    noclipOn = false
    if hbConn then hbConn:Disconnect(); hbConn=nil end
    if steppedConn then steppedConn:Disconnect(); steppedConn=nil end
    local char = lp.Character
    if char then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") and originalCollide[p] ~= nil then p.CanCollide = originalCollide[p]; p.CanTouch = true end
        end
    end
end
local btnNoclip = makeBtn(pageMove, "Atravesar paredes: OFF", 186)
btnNoclip.MouseButton1Click:Connect(function()
    if noclipOn then disableNoclip() else enableNoclip() end
    setBtnState(btnNoclip, "Atravesar paredes: ", noclipOn)
end)
setBtnState(btnNoclip, "Atravesar paredes: ", noclipOn)

-- Fly (WASD + Space/Ctrl)
local flyOn=false
local flyBV, flyBGyro
local flyConn
local btnFly = makeBtn(pageMove, "Fly: OFF", 232)
btnFly.MouseButton1Click:Connect(function()
    local function enableFly()
        if flyOn then return end
        flyOn = true
        local hum, hrp = getHum(); if not (hum and hrp) then return end
        hum.PlatformStand = true
        flyBV = Instance.new("BodyVelocity"); flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5); flyBV.Parent = hrp
        flyBGyro = Instance.new("BodyGyro"); flyBGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5); flyBGyro.P = 1e4; flyBGyro.Parent = hrp
        local cam = Workspace.CurrentCamera
        flyConn = RS.RenderStepped:Connect(function(dt)
            if not flyOn then return end
            local look = cam.CFrame.LookVector
            local right = cam.CFrame.RightVector
            local flatLook, flatRight = Vector3.new(look.X,0,look.Z), Vector3.new(right.X,0,right.Z)
            local dir = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then dir += flatLook end
            if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= flatLook end
            if UIS:IsKeyDown(Enum.KeyCode.D) then dir += flatRight end
            if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= flatRight end
            if dir.Magnitude > 0 then dir = dir.Unit else dir = Vector3.zero end
            local up = 0
            if UIS:IsKeyDown(Enum.KeyCode.Space) then up = 1 end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.RightControl) then up = -1 end
            flyBV.Velocity = Vector3.new(dir.X * flySpeed, up * flySpeed, dir.Z * flySpeed)
            local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local hrpPos = hrp.Position
                local targetCF = CFrame.lookAt(hrpPos, hrpPos + flatLook)
                hrp.CFrame = hrp.CFrame:Lerp(targetCF, math.clamp(FLY_TILT_STIFFNESS*dt, 0, 1))
                flyBGyro.CFrame = cam.CFrame
            end
        end)
    end
    local function disableFly()
        if not flyOn then return end
        flyOn = false
        local hum = (lp.Character and lp.Character:FindFirstChildOfClass("Humanoid"))
        if hum then hum.PlatformStand = false end
        if flyConn then flyConn:Disconnect(); flyConn=nil end
        if flyBV then flyBV:Destroy(); flyBV=nil end
        if flyBGyro then flyBGyro:Destroy(); flyBGyro=nil end
    end
    if flyOn then disableFly() else enableFly() end
    setBtnState(btnFly, "Fly: ", flyOn)
end)
setBtnState(btnFly, "Fly: ", flyOn)

-- Respawn: restaurar estados
lp.CharacterAdded:Connect(function(char)
    originalCollide = {}
    local hum = char:WaitForChild("Humanoid", 10); char:WaitForChild("HumanoidRootPart", 10)
    if hum then
        hum.WalkSpeed = currentSpeed
        baseRecorded = false; recordBaseJump(hum); applyJump(hum)
        if flyOn then task.wait(0.2); btnFly:Activate() end
    end
    if noclipOn then task.wait(0.1); setCharCollision(char, false) end
end)

-------------------------
--      AIMBOT UI      --
-------------------------
local aimbotOn = false
local rmbDown = false
local aimFOV = AIM_FOV_DEFAULT
local aimColor = Color3.fromRGB(255, 70, 70)

-- Círculo FOV
local fovCircle = Instance.new("Frame")
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Size = UDim2.fromOffset(aimFOV*2, aimFOV*2)
fovCircle.Position = UDim2.fromScale(0.5, 0.5)
fovCircle.BackgroundTransparency = 1
fovCircle.Visible = false
fovCircle.ZIndex = 999
fovCircle.Parent = gui
local fovCorner = Instance.new("UICorner", fovCircle); fovCorner.CornerRadius = UDim.new(1,0)
local fovStroke = Instance.new("UIStroke", fovCircle); fovStroke.Thickness = 2; fovStroke.Color = aimColor; fovStroke.Transparency = 0.15

-- Controles
local btnAimb = makeBtn(pageAimb, "Aimbot: OFF (mantén clic derecho)", 10)
setBtnState(btnAimb, "Aimbot: ", aimbotOn)
btnAimb.MouseButton1Click:Connect(function()
    aimbotOn = not aimbotOn
    fovCircle.Visible = aimbotOn
    setBtnState(btnAimb, "Aimbot: ", aimbotOn)
end)

-- Slider FOV
local fovBack = makeSlider(pageAimb, 56, Color3.fromRGB(200,120,120))
local fovKnob = fovBack:FindFirstChildWhichIsA("Frame")
local fovLabel = Instance.new("TextLabel")
fovLabel.BackgroundTransparency = 1
fovLabel.Position = UDim2.new(0, 10, 0, 78)
fovLabel.Size = UDim2.new(1, -20, 0, 20)
fovLabel.Font = Enum.Font.Gotham
fovLabel.TextSize = 14
fovLabel.TextColor3 = Color3.fromRGB(235,235,255)
fovLabel.ZIndex = 4
fovLabel.Parent = pageAimb

local function setFOV(val)
    aimFOV = math.clamp(math.floor(val+0.5), AIM_FOV_MIN, AIM_FOV_MAX)
    fovLabel.Text = ("FOV: %d"):format(aimFOV)
    fovCircle.Size = UDim2.fromOffset(aimFOV*2, aimFOV*2)
end
do
    local rel = relFromVal(AIM_FOV_DEFAULT, AIM_FOV_MIN, AIM_FOV_MAX)
    fovKnob.Position = UDim2.new(rel, -7, 0.5, -9)
    setFOV(AIM_FOV_DEFAULT)
end
do
    local dragging=false
    local function update(x)
        local rel = math.clamp((x - fovBack.AbsolutePosition.X)/fovBack.AbsoluteSize.X, 0, 1)
        fovKnob.Position = UDim2.new(rel, -7, 0.5, -9)
        setFOV(valFromRel(rel, AIM_FOV_MIN, AIM_FOV_MAX))
    end
    fovBack.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then update(inp.Position.X) end end)
    fovKnob.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            dragging=true
            inp.Changed:Connect(function() if inp.UserInputState==Enum.UserInputState.End then dragging=false end end)
        end
    end)
    UIS.InputChanged:Connect(function(inp) if dragging and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then update(inp.Position.X) end end)
end

-- Sliders RGB
local rgbY = 110
local rBack = makeSlider(pageAimb, rgbY, Color3.fromRGB(255,0,0))
local rKnob = rBack:FindFirstChildWhichIsA("Frame")
local gBack = makeSlider(pageAimb, rgbY+36, Color3.fromRGB(0,255,0))
local gKnob = gBack:FindFirstChildWhichIsA("Frame")
local bBack = makeSlider(pageAimb, rgbY+72, Color3.fromRGB(0,0,255))
local bKnob = bBack:FindFirstChildWhichIsA("Frame")

local rLabel = Instance.new("TextLabel"); rLabel.BackgroundTransparency=1; rLabel.Position=UDim2.new(0,10,0,rgbY-18); rLabel.Size=UDim2.new(1,-20,0,16); rLabel.Font=Enum.Font.Gotham; rLabel.TextSize=12; rLabel.TextColor3=Color3.fromRGB(255,200,200); rLabel.Text="Color FOV (R/G/B)"; rLabel.Parent=pageAimb

local preview = Instance.new("Frame"); preview.Size=UDim2.fromOffset(26,26); preview.Position=UDim2.new(1,-36,0,rgbY-4); preview.BackgroundColor3=aimColor; preview.Parent=pageAimb; Instance.new("UICorner", preview).CornerRadius=UDim.new(0,6); local pStroke=Instance.new("UIStroke",preview); pStroke.Thickness=1; pStroke.Transparency=0.5

local R,G,B = 255,70,70
local function updateAimColor()
    aimColor = Color3.fromRGB(R,G,B)
    fovStroke.Color = aimColor
    preview.BackgroundColor3 = aimColor
end
local function setRGB(knob, back, val) knob.Position = UDim2.new(math.clamp(val/255,0,1), -7, 0.5, -9) end
setRGB(rKnob, rBack, R); setRGB(gKnob, gBack, G); setRGB(bKnob, bBack, B)
do
    local function hookup(back, knob, which)
        local dragging=false
        local function update(x)
            local rel = math.clamp((x - back.AbsolutePosition.X)/back.AbsoluteSize.X, 0, 1)
            knob.Position = UDim2.new(rel, -7, 0.5, -9)
            local v = math.floor(rel*255 + 0.5)
            if which=="R" then R=v elseif which=="G" then G=v else B=v end
            updateAimColor()
        end
        back.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then update(inp.Position.X) end end)
        knob.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                dragging=true
                inp.Changed:Connect(function() if inp.UserInputState==Enum.UserInputState.End then dragging=false end end)
            end
        end)
        UIS.InputChanged:Connect(function(inp) if dragging and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then update(inp.Position.X) end end)
    end
    hookup(rBack, rKnob, "R")
    hookup(gBack, gKnob, "G")
    hookup(bBack, bKnob, "B")
end
updateAimColor()

-- Lógica Aimbot
local function getTargetHeadInFOV()
    local cam = Workspace.CurrentCamera
    local center = cam.ViewportSize/2
    local bestPlr, bestDist, bestHead = nil, math.huge, nil
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= lp then
            local char = p.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local head = char and char:FindFirstChild("Head")
            if hum and head and hum.Health > 0 then
                local v2, on = cam:WorldToViewportPoint(head.Position)
                if on and v2.Z > 0 then
                    local dist = (Vector2.new(v2.X, v2.Y) - center).Magnitude
                    if dist <= aimFOV and dist < bestDist then
                        bestDist = dist; bestPlr = p; bestHead = head
                    end
                end
            end
        end
    end
    return bestPlr, bestHead
end

UIS.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.UserInputType == Enum.UserInputType.MouseButton2 then rmbDown = true end
end)
UIS.InputEnded:Connect(function(inp, gpe)
    if gpe then return end
    if inp.UserInputType == Enum.UserInputType.MouseButton2 then rmbDown = false end
end)

local aimConn
aimConn = RS.RenderStepped:Connect(function(dt)
    if not aimbotOn or not rmbDown then return end
    -- no aimbot si Freecam activo
    if Workspace.CurrentCamera.CameraType == Enum.CameraType.Scriptable then return end
    local cam = Workspace.CurrentCamera
    local _, head = getTargetHeadInFOV()
    if head then
        local from = cam.CFrame.Position
        local targetCF = CFrame.new(from, head.Position)
        -- suavizado
        cam.CFrame = cam.CFrame:Lerp(targetCF, math.clamp(1 - (1 - AIM_SMOOTH)^(math.max(dt*60,1)), 0, 1))
    end
end)

-------------------------
--      CRÉDITOS       --
-------------------------
local cred1 = Instance.new("TextLabel")
cred1.BackgroundTransparency = 1
cred1.Size = UDim2.new(1, -20, 0, 24)
cred1.Position = UDim2.new(0, 10, 0, 10)
cred1.Font = Enum.Font.GothamBold
cred1.TextSize = 16
cred1.TextColor3 = Color3.fromRGB(235,235,255)
cred1.TextXAlignment = Enum.TextXAlignment.Left
cred1.Text = "creador: pedri.exe / Nakamy"
cred1.Parent = pageCred

local cred2 = Instance.new("TextLabel")
cred2.BackgroundTransparency = 1
cred2.Size = UDim2.new(1, -20, 0, 22)
cred2.Position = UDim2.new(0, 10, 0, 40)
cred2.Font = Enum.Font.Gotham
cred2.TextSize = 14
cred2.TextColor3 = Color3.fromRGB(220,220,240)
cred2.TextXAlignment = Enum.TextXAlignment.Left
cred2.Text = "versión: V6"
cred2.Parent = pageCred

local credBtn = Instance.new("TextButton")
credBtn.Size = UDim2.new(1, -20, 0, 36)
credBtn.Position = UDim2.new(0, 10, 0, 72)
credBtn.BackgroundColor3 = Color3.fromRGB(28,28,40)
credBtn.TextColor3 = Color3.fromRGB(255,255,255)
credBtn.Font = Enum.Font.GothamBold
credBtn.TextSize = 14
credBtn.Text = "Discord: "..DISCORD_LINK.."  (clic para copiar)"
credBtn.Parent = pageCred
Instance.new("UICorner", credBtn).CornerRadius = UDim.new(0, 8)
credBtn.MouseButton1Click:Connect(function()
    if setclipboard then setclipboard(DISCORD_LINK) end
    credBtn.Text = "¡Copiado! "..DISCORD_LINK
end)

-------------------------
--        OTROS        --
-------------------------
-- Invisible (local)
local invisOn = false
local btnInvis = makeBtn(pageOtros, "Invisible: OFF", 10)
local function setCharacterLocalTransparency(char, val)
    for _,d in ipairs(char:GetDescendants()) do
        if d:IsA("BasePart") then
            d.LocalTransparencyModifier = val
        elseif d:IsA("Decal") then
            d.Transparency = val -- comenta si no quieres replicación visual de decals
        end
    end
end
local function enableInvisible()
    local char = lp.Character; if not char then return end
    setCharacterLocalTransparency(char, 1)
    local hum = char:FindFirstChildOfClass("Humanoid"); if hum then hum.NameDisplayDistance = 0 end
end
local function disableInvisible()
    local char = lp.Character; if not char then return end
    setCharacterLocalTransparency(char, 0)
    local hum = char:FindFirstChildOfClass("Humanoid"); if hum then hum.NameDisplayDistance = 100 end
end
btnInvis.MouseButton1Click:Connect(function()
    invisOn = not invisOn
    if invisOn then enableInvisible() else disableInvisible() end
    setBtnState(btnInvis, "Invisible: ", invisOn)
end)
setBtnState(btnInvis, "Invisible: ", invisOn)

-- Freecam / Foto
local freecamOn = false
local btnFree = makeBtn(pageOtros, "Foto (Freecam): OFF", 56)

local prevCamType, prevCamSubj, prevCamCF
local savedAnchor = nil
local fcConn, mouseConn
local yaw, pitch = 0, 0
local fcSpeed = FC_SPEED_DEFAULT
local function setMouseLock(lock)
    if lock then
        UIS.MouseIconEnabled = false
        UIS.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
    else
        UIS.MouseBehavior = Enum.MouseBehavior.Default
        UIS.MouseIconEnabled = true
    end
end
local function fcStart()
    if freecamOn then return end
    local cam = Workspace.CurrentCamera
    local hum, hrp = getHum(); if not cam or not (hum and hrp) then return end
    freecamOn = true
    prevCamType, prevCamSubj, prevCamCF = cam.CameraType, cam.CameraSubject, cam.CFrame
    savedAnchor = hrp.Anchored; hrp.Anchored = true; hum.AutoRotate = false; hum.PlatformStand = true
    cam.CameraType = Enum.CameraType.Scriptable
    setMouseLock(true)
    yaw, pitch = 0, 0
    mouseConn = UIS.InputChanged:Connect(function(inp, gpe)
        if gpe then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement and freecamOn then
            yaw   = yaw   - inp.Delta.X * FC_SENS.X
            pitch = math.clamp(pitch - inp.Delta.Y * FC_SENS.Y, -1.3, 1.3)
        end
    end)
    fcConn = RS.RenderStepped:Connect(function(dt)
        if not freecamOn then return end
        local cam = Workspace.CurrentCamera
        local rot = CFrame.Angles(0, yaw, 0) * CFrame.Angles(pitch, 0, 0)
        local forward, right, up = rot.LookVector, rot.RightVector, rot.UpVector
        local move = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then move += forward end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move -= forward end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move += right end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move -= right end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move += up end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.RightControl) then move -= up end
        if move.Magnitude > 0 then move = move.Unit * (fcSpeed * dt) end
        cam.CFrame = CFrame.new(cam.CFrame.Position + move) * rot
    end)
end
local function fcStop()
    if not freecamOn then return end
    freecamOn = false
    local cam = Workspace.CurrentCamera
    if fcConn then fcConn:Disconnect(); fcConn=nil end
    if mouseConn then mouseConn:Disconnect(); mouseConn=nil end
    setMouseLock(false)
    local hum, hrp = getHum()
    if hrp and savedAnchor ~= nil then hrp.Anchored = savedAnchor end
    if hum then hum.AutoRotate = true; hum.PlatformStand = false end
    if cam then
        cam.CameraType = prevCamType or Enum.CameraType.Custom
        cam.CameraSubject = prevCamSubj or (hum or hrp)
        cam.CFrame = prevCamCF or (hrp and hrp.CFrame or cam.CFrame)
    end
end
btnFree.MouseButton1Click:Connect(function()
    if freecamOn then fcStop() else fcStart() end
    setBtnState(btnFree, "Foto (Freecam): ", freecamOn)
end)
setBtnState(btnFree, "Foto (Freecam): ", freecamOn)

lp.CharacterAdded:Connect(function()
    if freecamOn then fcStop() end
    if invisOn then task.wait(0.2); enableInvisible() end
end)

-------------------------
--   TECLA L (toggle)  --
-------------------------
local function openMain()
    if main.Visible then return end
    main.Visible = true
    main.Size = UDim2.fromOffset(560, 0)
    TS:Create(main, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = UDim2.fromOffset(560, 460)}):Play()
end
local function closeMain()
    if not main.Visible then return end
    TS:Create(main, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = UDim2.fromOffset(560, 0)}):Play()
    task.delay(0.25, function() main.Visible = false end)
end
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.L and main.Visible then closeMain()
    elseif input.KeyCode == Enum.KeyCode.L and not main.Visible then openMain() end
end)

-------------------------
--   ACCIÓN DEL LOGIN  --
-------------------------
loginBtn.MouseButton1Click:Connect(function()
    if keyBox.Text == ACCESS_KEY then
        clickableBanner("bienvenido si nesesitas ayuda ven al discord "..DISCORD_LINK, DISCORD_LINK, 9)

        -- salida animada del login + quitar blur
        TS:Create(lfScale, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0.95}):Play()
        TS:Create(loginFrame, TweenInfo.new(0.18), {BackgroundTransparency = 1}):Play()
        TS:Create(loginOverlay, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        TS:Create(blur, TweenInfo.new(0.25), {Size = 0}):Play()
        task.delay(0.22, function()
            loginOverlay:Destroy()
            loginFrame:Destroy()
            blur:Destroy()
            openMain()
        end)
    else
        toast("Key incorrecta.", 5)
        loginBtn.BackgroundColor3 = Color3.fromRGB(150,50,50)
        task.delay(0.4, function() loginBtn.BackgroundColor3 = Color3.fromRGB(45,130,90) end)
    end
end)
