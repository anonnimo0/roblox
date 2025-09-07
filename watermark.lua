--// 𝙁𝙤𝙭𝙭𝙮's 𝙇𝙚𝙖𝙠𝙨 — Admin/Debug UI (para TU experiencia)
--// Login con key -> 2 menús: Movimiento (velocidad, noclip, salto regulable) y Visual (nombres + highlight)
--// Fondo de estrellas animadas, tecla L para ocultar/mostrar
--// Pie: "programador: by pedri.exe"
--// Opcional: limita por PlaceId/UserId para uso solo en tu juego

-------------------------
--    CONFIGURACIÓN    --
-------------------------
local ACCESS_KEY = "HJGL-FKSS"

-- Limita a tus lugares (opcional). Si lo dejas vacío, funciona en cualquier place.
local ALLOWED_PLACE_IDS = {
    -- 1234567890,
}

-- Limita a ciertos UserId (opcional). Si lo dejas vacío, funciona para cualquiera.
local ALLOWED_USER_IDS = {
    -- 987654321,
}

-- Velocidad (WalkSpeed)
local SPEED_MIN, SPEED_MAX, SPEED_DEFAULT = 8, 100, 16

-- Salto (slider como multiplicador del salto base)
local JUMP_MULT_MIN, JUMP_MULT_MAX, JUMP_MULT_DEFAULT = 0.9, 1.6, 1.25
-- Límite de aumento máximo absoluto para evitar saltos exagerados
local JUMP_MAX_ABS_ADD = 28

-- Noclip anti-rebote: fuerza correctiva (0.85 recomendado; sube a 1.2 si hay muros muy gruesos)
local NOCLIP_CORRECTION_FACTOR = 0.85

-------------------------
--      SERVICIOS      --
-------------------------
local Players = game:GetService("Players")
local UIS     = game:GetService("UserInputService")
local TS      = game:GetService("TweenService")
local RS      = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local lp = Players.LocalPlayer

-------------------------
--      GUARDAS        --
-------------------------
local function isAllowedPlace()
    if #ALLOWED_PLACE_IDS == 0 then return true end
    for _,id in ipairs(ALLOWED_PLACE_IDS) do
        if id == game.PlaceId then return true end
    end
    return false
end

local function isAllowedUser()
    if #ALLOWED_USER_IDS == 0 then return true end
    for _,id in ipairs(ALLOWED_USER_IDS) do
        if id == lp.UserId then return true end
    end
    return false
end

if not isAllowedPlace() or not isAllowedUser() then
    warn("[Foxxy's Leaks] No autorizado en este lugar/usuario. Configura ALLOWED_* en el script.")
    return
end

-------------------------
--       GUI BASE      --
-------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "FoxxysLeaksUI"
gui.ResetOnSpawn = false
pcall(function() gui.Parent = game.CoreGui end)
if not gui.Parent then gui.Parent = lp:WaitForChild("PlayerGui") end

-------------------------
--     LOGIN (KEY)     --
-------------------------
local loginFrame = Instance.new("Frame")
loginFrame.Size = UDim2.fromOffset(360, 160)
loginFrame.Position = UDim2.new(0.5, -180, 0.35, 0)
loginFrame.BackgroundColor3 = Color3.fromRGB(12,12,16)
loginFrame.BorderSizePixel = 0
loginFrame.Parent = gui
Instance.new("UICorner", loginFrame).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(235,235,255)
title.Text = "Foxxy's Leaks — Login"
title.Size = UDim2.new(1, -20, 0, 32)
title.Position = UDim2.new(0, 10, 0, 10)
title.Parent = loginFrame

local keyBox = Instance.new("TextBox")
keyBox.Size = UDim2.new(1, -20, 0, 36)
keyBox.Position = UDim2.new(0, 10, 0, 56)
keyBox.BackgroundColor3 = Color3.fromRGB(24,24,32)
keyBox.TextColor3 = Color3.fromRGB(255,255,255)
keyBox.PlaceholderText = "Ingresa la key"
keyBox.Text = ""
keyBox.ClearTextOnFocus = false
keyBox.Font = Enum.Font.Gotham
keyBox.TextSize = 14
keyBox.Parent = loginFrame
Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 8)

local loginBtn = Instance.new("TextButton")
loginBtn.Size = UDim2.new(1, -20, 0, 36)
loginBtn.Position = UDim2.new(0, 10, 0, 100)
loginBtn.BackgroundColor3 = Color3.fromRGB(45,130,90)
loginBtn.TextColor3 = Color3.fromRGB(255,255,255)
loginBtn.Font = Enum.Font.GothamBold
loginBtn.TextSize = 14
loginBtn.Text = "Entrar"
loginBtn.Parent = loginFrame
Instance.new("UICorner", loginBtn).CornerRadius = UDim.new(0, 8)

local info = Instance.new("TextLabel")
info.BackgroundTransparency = 1
info.TextColor3 = Color3.fromRGB(180,180,200)
info.Font = Enum.Font.Gotham
info.TextSize = 12
info.Text = "Key requerida para continuar"
info.Size = UDim2.new(1, -20, 0, 16)
info.Position = UDim2.new(0, 10, 1, -22)
info.Parent = loginFrame

local function toast(txt)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Foxxy's Leaks";
            Text = txt;
            Duration = 5;
        })
    end)
end

-- Banner de anuncio animado (entra por arriba y sale)
local function bannerAnnounce(message)
    local banner = Instance.new("Frame")
    banner.Size = UDim2.new(1, -20, 0, 36)
    banner.Position = UDim2.new(0, 10, 0, -40)
    banner.BackgroundColor3 = Color3.fromRGB(28,28,40)
    banner.BorderSizePixel = 0
    banner.ZIndex = 100
    banner.Parent = gui
    Instance.new("UICorner", banner).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, -20, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 14
    lbl.TextColor3 = Color3.fromRGB(235,235,255)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = message
    lbl.Parent = banner

    TS:Create(banner, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Position = UDim2.new(0, 10, 0, 10)}):Play()
    task.delay(4.5, function()
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
main.Size = UDim2.fromOffset(460, 0) -- aparecerá con animación
main.Position = UDim2.new(0.5, -230, 0.2, 0)
main.BackgroundColor3 = Color3.fromRGB(8,8,12) -- fondo oscuro (cielo)
main.BorderSizePixel = 0
main.Visible = false
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)

-- CAPA DE ESTRELLAS (detrás)
local starLayer = Instance.new("Frame")
starLayer.BackgroundTransparency = 1
starLayer.Size = UDim2.fromScale(1,1)
starLayer.ClipsDescendants = true
starLayer.ZIndex = 0
starLayer.Parent = main

-- CONTENIDO (encima)
local content = Instance.new("Frame")
content.BackgroundTransparency = 1
content.Size = UDim2.fromScale(1,1)
content.ZIndex = 2
content.Parent = main

-- Barra superior (drag) + título
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 38)
topBar.BackgroundColor3 = Color3.fromRGB(16,16,24)
topBar.BorderSizePixel = 0
topBar.ZIndex = 3
topBar.Parent = content
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 14)

local titleMain = Instance.new("TextLabel")
titleMain.BackgroundTransparency = 1
titleMain.Size = UDim2.new(1, -12, 1, 0)
titleMain.Position = UDim2.new(0, 12, 0, 0)
titleMain.Font = Enum.Font.GothamBold
titleMain.TextSize = 14
titleMain.TextXAlignment = Enum.TextXAlignment.Left
titleMain.TextColor3 = Color3.fromRGB(220,220,255)
titleMain.Text = "𝙁𝙤𝙭𝙭𝙮's 𝙇𝙚𝙖𝙠𝙨  —  [L para ocultar/mostrar]"
titleMain.ZIndex = 4
titleMain.Parent = topBar

-- Pie con crédito del programador
local footer = Instance.new("TextLabel")
footer.BackgroundTransparency = 1
footer.Size = UDim2.new(1, -16, 0, 18)
footer.Position = UDim2.new(0, 8, 1, -20)
footer.Font = Enum.Font.Gotham
footer.TextSize = 12
footer.TextXAlignment = Enum.TextXAlignment.Center
footer.TextColor3 = Color3.fromRGB(150,150,170)
footer.Text = "programador: by pedri.exe ceo Nakamy"
footer.ZIndex = 4
footer.Parent = content

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
tabs.Position = UDim2.new(0, 10, 0, 46)
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
    b.Size = UDim2.fromOffset(200, 32)
    b.BackgroundColor3 = Color3.fromRGB(28,28,40)
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.Text = text
    b.ZIndex = 4
    b.Parent = tabs
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    return b
end

local tabMove = makeTabBtn("Movimiento")
local tabVisual = makeTabBtn("Visual (debug)")

local pages = Instance.new("Frame")
pages.Size = UDim2.new(1, -20, 1, -46-36-18)
pages.Position = UDim2.new(0, 10, 0, 46+36+8)
pages.BackgroundTransparency = 1
pages.ZIndex = 3
pages.Parent = content

local pageMove = Instance.new("Frame")
pageMove.BackgroundTransparency = 1
pageMove.Size = UDim2.new(1, 0, 1, 0)
pageMove.ZIndex = 3
pageMove.Parent = pages

local pageVisual = Instance.new("Frame")
pageVisual.BackgroundTransparency = 1
pageVisual.Size = UDim2.new(1, 0, 1, 0)
pageVisual.Visible = false
pageVisual.ZIndex = 3
pageVisual.Parent = pages

local function switchTo(which)
    pageMove.Visible = (which == "move")
    pageVisual.Visible = (which == "visual")
end

tabMove.MouseButton1Click:Connect(function() switchTo("move") end)
tabVisual.MouseButton1Click:Connect(function() switchTo("visual") end)

-------------------------
--  ESTRELLAS (fondo)  --
-------------------------
local function spawnStars(container, count)
    if container.AbsoluteSize.X < 1 then task.wait() end
    local w, h = container.AbsoluteSize.X, container.AbsoluteSize.Y
    for i=1, count do
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
spawnStars(starLayer, 70)

-------------------------
--   MOVIMIENTO (UI)   --
-------------------------
-- Slider de velocidad
local sliderBack = Instance.new("Frame")
sliderBack.Size = UDim2.new(1, -20, 0, 10)
sliderBack.Position = UDim2.new(0, 10, 0, 10)
sliderBack.BackgroundColor3 = Color3.fromRGB(42,42,60)
sliderBack.BorderSizePixel = 0
sliderBack.ZIndex = 3
sliderBack.Parent = pageMove
Instance.new("UICorner", sliderBack).CornerRadius = UDim.new(0, 6)

local sliderKnob = Instance.new("Frame")
sliderKnob.Size = UDim2.fromOffset(14, 18)
sliderKnob.Position = UDim2.new((SPEED_DEFAULT-SPEED_MIN)/(SPEED_MAX-SPEED_MIN), -7, 0.5, -9)
sliderKnob.BackgroundColor3 = Color3.fromRGB(45,130,90)
sliderKnob.BorderSizePixel = 0
sliderKnob.ZIndex = 4
sliderKnob.Parent = sliderBack
Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)

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

-- Drag del knob + click en barra
do
    local dragging = false
    local function update(inputPosX)
        local rel = math.clamp((inputPosX - sliderBack.AbsolutePosition.X)/sliderBack.AbsoluteSize.X, 0, 1)
        sliderKnob.Position = UDim2.new(rel, -7, 0.5, -9)
        setSpeed(SPEED_MIN + rel*(SPEED_MAX - SPEED_MIN))
    end
    sliderKnob.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            update(inp.Position.X)
        end
    end)
    sliderBack.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            update(inp.Position.X)
        end
    end)
end

-- Slider de salto (multiplicador)
local jumpBack = Instance.new("Frame")
jumpBack.Size = UDim2.new(1, -20, 0, 10)
jumpBack.Position = UDim2.new(0, 10, 0, 70)
jumpBack.BackgroundColor3 = Color3.fromRGB(42,42,60)
jumpBack.BorderSizePixel = 0
jumpBack.ZIndex = 3
jumpBack.Parent = pageMove
Instance.new("UICorner", jumpBack).CornerRadius = UDim.new(0, 6)

local jumpKnob = Instance.new("Frame")
jumpKnob.Size = UDim2.fromOffset(14, 18)
jumpKnob.Position = UDim2.new((JUMP_MULT_DEFAULT-JUMP_MULT_MIN)/(JUMP_MULT_MAX-JUMP_MULT_MIN), -7, 0.5, -9)
jumpKnob.BackgroundColor3 = Color3.fromRGB(90,120,200)
jumpKnob.BorderSizePixel = 0
jumpKnob.ZIndex = 4
jumpKnob.Parent = jumpBack
Instance.new("UICorner", jumpKnob).CornerRadius = UDim.new(1, 0)

local jumpLabel = Instance.new("TextLabel")
jumpLabel.BackgroundTransparency = 1
jumpLabel.Position = UDim2.new(0, 10, 0, 92)
jumpLabel.Size = UDim2.new(1, -20, 0, 20)
jumpLabel.Font = Enum.Font.Gotham
jumpLabel.TextSize = 14
jumpLabel.TextColor3 = Color3.fromRGB(235,235,255)
jumpLabel.ZIndex = 4
jumpLabel.Parent = pageMove

-- Estado del salto
local baseRecorded = false
local baseUseJumpPower, baseJumpPower, baseJumpHeight
local jumpMult = JUMP_MULT_DEFAULT

local function recordBaseJump(hum)
    if baseRecorded then return end
    baseUseJumpPower = hum.UseJumpPower
    if baseUseJumpPower then
        baseJumpPower = hum.JumpPower
    else
        baseJumpHeight = hum.JumpHeight
    end
    baseRecorded = true
end

local function applyJump(hum)
    if not hum then return end
    recordBaseJump(hum)
    if baseUseJumpPower then
        local target = baseJumpPower * jumpMult
        target = math.min(baseJumpPower + JUMP_MAX_ABS_ADD, target)
        hum.JumpPower = target
        jumpLabel.Text = string.format("Salto: x%.2f  (%d)", jumpMult, math.floor(target + 0.5))
    else
        local target = baseJumpHeight * jumpMult
        target = math.min(baseJumpHeight + (JUMP_MAX_ABS_ADD/8), target)
        hum.JumpHeight = target
        jumpLabel.Text = string.format("Salto: x%.2f", jumpMult)
    end
end

local function setJumpByRel(rel)
    jumpMult = JUMP_MULT_MIN + rel * (JUMP_MULT_MAX - JUMP_MULT_MIN)
    local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
    if hum then applyJump(hum) end
    -- Reposicionar knob
    jumpKnob.Position = UDim2.new(rel, -7, 0.5, -9)
end

-- Drag + click del slider de salto
do
    local dragging = false
    local function update(inputPosX)
        local rel = math.clamp((inputPosX - jumpBack.AbsolutePosition.X)/jumpBack.AbsoluteSize.X, 0, 1)
        setJumpByRel(rel)
    end
    jumpKnob.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            update(inp.Position.X)
        end
    end)
    jumpBack.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            update(inp.Position.X)
        end
    end)
end

-- Botones en Movimiento
local function makeBtnMove(text, y)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -20, 0, 36)
    b.Position = UDim2.new(0, 10, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(28,28,40)
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.Text = text
    b.ZIndex = 4
    b.Parent = pageMove
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    return b
end

-- Estados
local noclipOn = false
local hbConn, steppedConn
local originalCollide = {}

local function getHum()
    local c = lp.Character
    return c and c:FindFirstChildOfClass("Humanoid"), c and c:FindFirstChild("HumanoidRootPart")
end

-- NOCLIP (anti-rebote)
local function cacheDefaults(char)
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") and originalCollide[p] == nil then
            originalCollide[p] = p.CanCollide
        end
    end
end
local function setCharCollision(char, can)
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            p.CanCollide = can
            p.CanTouch = not can
        end
    end
end
local function enableNoclip()
    noclipOn = true
    local hum, hrp = getHum()
    local char = lp.Character
    if char then cacheDefaults(char); setCharCollision(char, false) end

    if steppedConn then steppedConn:Disconnect() end
    steppedConn = RS.Stepped:Connect(function()
        if not noclipOn then return end
        local c = lp.Character; if not c then return end
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end)

    if hbConn then hbConn:Disconnect() end
    hbConn = RS.Heartbeat:Connect(function(dt)
        if not noclipOn then return end
        local hum2, hrp2 = getHum()
        if not (hum2 and hrp2) then return end
        local dir = hum2.MoveDirection
        if dir.Magnitude > 0 then
            local corr = dir.Unit * (hum2.WalkSpeed * dt * NOCLIP_CORRECTION_FACTOR)
            hrp2.CFrame = hrp2.CFrame + Vector3.new(corr.X, 0, corr.Z)
        end
        hrp2.AssemblyAngularVelocity = Vector3.new()
    end)
end
local function disableNoclip()
    noclipOn = false
    if hbConn then hbConn:Disconnect(); hbConn=nil end
    if steppedConn then steppedConn:Disconnect(); steppedConn=nil end
    local char = lp.Character
    if char then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") and originalCollide[p] ~= nil then
                p.CanCollide = originalCollide[p]
                p.CanTouch  = true
            end
        end
    end
end

local btnNoclip = makeBtnMove("Atravesar paredes: OFF", 124)
local function setBtnState(b, label, on)
    b.Text = label .. (on and "ON" or "OFF")
    b.BackgroundColor3 = on and Color3.fromRGB(45,130,90) or Color3.fromRGB(120,50,50)
end
btnNoclip.MouseButton1Click:Connect(function()
    if noclipOn then disableNoclip() else enableNoclip() end
    setBtnState(btnNoclip, "Atravesar paredes: ", noclipOn)
end)
setBtnState(btnNoclip, "Atravesar paredes: ", noclipOn)

-- Mantener estados al respawn
lp.CharacterAdded:Connect(function(char)
    originalCollide = {}
    local hum = char:WaitForChild("Humanoid", 10)
    char:WaitForChild("HumanoidRootPart", 10)
    if hum then
        hum.WalkSpeed = currentSpeed
        baseRecorded = false
        recordBaseJump(hum)
        applyJump(hum)
    end
    if noclipOn then
        task.wait(0.1)
        setCharCollision(char, false)
    end
end)

--------------------------------
--  VISUAL: NOMBRES + HIGHLIGHT
--------------------------------
local showNames = false
local showHighlight = false
local nameTags = {}   -- [player] = BillboardGui
local highlights = {} -- [player] = Highlight

local function attachNameTag(plr)
    if plr == lp then return end
    local function onChar(char)
        local head = char:WaitForChild("Head", 8)
        if not head then return end
        if nameTags[plr] and nameTags[plr].Parent then nameTags[plr]:Destroy() end
        local bb = Instance.new("BillboardGui")
        bb.Name = "NameTag_DBG"
        bb.Size = UDim2.fromOffset(200, 50)
        bb.StudsOffset = Vector3.new(0, 2.5, 0)
        bb.AlwaysOnTop = true
        bb.Parent = head
        local tl = Instance.new("TextLabel")
        tl.BackgroundTransparency = 1
        tl.Size = UDim2.new(1, 0, 1, 0)
        tl.Font = Enum.Font.GothamBold
        tl.TextSize = 16
        tl.TextColor3 = Color3.fromRGB(255, 255, 255)
        tl.TextStrokeTransparency = 0.5
        tl.Text = plr.DisplayName .. " (@" .. plr.Name .. ")"
        tl.Parent = bb
        nameTags[plr] = bb
        bb.Enabled = showNames
    end
    plr.CharacterAdded:Connect(onChar)
    if plr.Character then onChar(plr.Character) end
end

local function attachHighlight(plr)
    if plr == lp then return end
    local function onChar(char)
        if highlights[plr] and highlights[plr].Parent then highlights[plr]:Destroy() end
        local h = Instance.new("Highlight")
        h.Name = "DebugHighlight"
        h.FillColor = Color3.fromRGB(220, 40, 40)
        h.OutlineColor = Color3.fromRGB(255, 255, 255)
        h.FillTransparency = 0.25
        h.OutlineTransparency = 0
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent = char
        highlights[plr] = h
        h.Enabled = showHighlight
    end
    plr.CharacterAdded:Connect(onChar)
    if plr.Character then onChar(plr.Character) end
end

for _,p in ipairs(Players:GetPlayers()) do
    if p ~= lp then
        attachNameTag(p)
        attachHighlight(p)
    end
end
Players.PlayerAdded:Connect(function(p)
    attachNameTag(p)
    attachHighlight(p)
end)
Players.PlayerRemoving:Connect(function(p)
    if nameTags[p] then nameTags[p]:Destroy(); nameTags[p]=nil end
    if highlights[p] then highlights[p]:Destroy(); highlights[p]=nil end
end)

-- Botones Visual
local function makeBtnVisual(parent, text, y)
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

local btnNames = makeBtnVisual(pageVisual, "Nombres: OFF", 10)
local btnESP   = makeBtnVisual(pageVisual, "Resaltar (rojo): OFF", 56)

local function setBtnState2(b, label, on)
    b.Text = label .. (on and "ON" or "OFF")
    b.BackgroundColor3 = on and Color3.fromRGB(45,130,90) or Color3.fromRGB(120,50,50)
end

btnNames.MouseButton1Click:Connect(function()
    showNames = not showNames
    for _,bb in pairs(nameTags) do
        if bb and bb.Parent then bb.Enabled = showNames end
    end
    setBtnState2(btnNames, "Nombres: ", showNames)
end)

btnESP.MouseButton1Click:Connect(function()
    showHighlight = not showHighlight
    for _,h in pairs(highlights) do
        if h and h.Parent then h.Enabled = showHighlight end
    end
    setBtnState2(btnESP, "Resaltar (rojo): ", showHighlight)
end)

setBtnState2(btnNames, "Nombres: ", showNames)
setBtnState2(btnESP,   "Resaltar (rojo): ", showHighlight)

-------------------------
--   TECLA L (toggle)  --
-------------------------
local function openMain()
    if main.Visible then return end
    main.Visible = true
    main.Size = UDim2.fromOffset(460, 0)
    TS:Create(main, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = UDim2.fromOffset(460, 350)}):Play()
end

local function closeMain()
    if not main.Visible then return end
    TS:Create(main, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = UDim2.fromOffset(460, 0)}):Play()
    task.delay(0.25, function() main.Visible = false end)
end

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.L and main.Visible then
        closeMain()
    elseif input.KeyCode == Enum.KeyCode.L and not main.Visible then
        openMain()
    end
end)

-------------------------
--   ACCIÓN DEL LOGIN  --
-------------------------
loginBtn.MouseButton1Click:Connect(function()
    if keyBox.Text == ACCESS_KEY then
        -- Anuncios al activar key
        toast("gracias por confiar en Foxxy's Leaks. Si tienes alguna duda, abre ticket en el Discord.")
        bannerAnnounce("gracias por confiar en Foxxy's Leaks — si tienes alguna duda, abre ticket en el Discord")

        TS:Create(loginFrame, TweenInfo.new(0.2), {Size = UDim2.fromOffset(360, 0)}):Play()
        task.delay(0.2, function()
            loginFrame.Visible = false
            openMain()
        end)
    else
        toast("Key incorrecta.")
        loginBtn.BackgroundColor3 = Color3.fromRGB(150,50,50)
        task.delay(0.4, function()
            loginBtn.BackgroundColor3 = Color3.fromRGB(45,130,90)
        end)
    end
end)
