--// Admin/Debug UI para TU experiencia
--// 2 menús: Movimiento (slider velocidad) y Visual (nombres + highlight rojo)
--// Login por key antes de entrar: HJGL-FKSS
--// RESTRICCIÓN: Completa ALLOWED_PLACE_IDS/ALLOWED_USER_IDS para que solo funcione en tu juego.

-------------------------
--    CONFIGURACIÓN    --
-------------------------
local ACCESS_KEY = "HJGL-FKSS"

-- Agrega aquí los PlaceId NUMÉRICOS donde permites la herramienta
local ALLOWED_PLACE_IDS = {
    -- 1234567890,
}

-- Opcional: restringe por UserId (admins)
local ALLOWED_USER_IDS = {
    -- 987654321,
}

-- Rango del slider de velocidad
local SPEED_MIN, SPEED_MAX, SPEED_DEFAULT = 8, 100, 16

-------------------------
--      SERVICIOS      --
-------------------------
local Players = game:GetService("Players")
local UIS     = game:GetService("UserInputService")
local TS      = game:GetService("TweenService")

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
    warn("[AdminUI] No autorizado en este lugar/usuario. Configura ALLOWED_* en el script.")
    return
end

-------------------------
--       GUI BASE      --
-------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "AdminDebugUI"
gui.ResetOnSpawn = false
pcall(function() gui.Parent = game.CoreGui end)
if not gui.Parent then gui.Parent = lp:WaitForChild("PlayerGui") end

-------------------------
--     LOGIN (KEY)     --
-------------------------
local loginFrame = Instance.new("Frame")
loginFrame.Size = UDim2.fromOffset(360, 160)
loginFrame.Position = UDim2.new(0.5, -180, 0.35, 0)
loginFrame.BackgroundColor3 = Color3.fromRGB(26,26,26)
loginFrame.BorderSizePixel = 0
loginFrame.Parent = gui
Instance.new("UICorner", loginFrame).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(235,235,235)
title.Text = "Login — pedri.exe"
title.Size = UDim2.new(1, -20, 0, 32)
title.Position = UDim2.new(0, 10, 0, 10)
title.Parent = loginFrame

local keyBox = Instance.new("TextBox")
keyBox.Size = UDim2.new(1, -20, 0, 36)
keyBox.Position = UDim2.new(0, 10, 0, 56)
keyBox.BackgroundColor3 = Color3.fromRGB(36,36,36)
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
info.TextColor3 = Color3.fromRGB(180,180,180)
info.Font = Enum.Font.Gotham
info.TextSize = 12
info.Text = "Key requerida para continuar"
info.Size = UDim2.new(1, -20, 0, 16)
info.Position = UDim2.new(0, 10, 1, -22)
info.Parent = loginFrame

-------------------------
--  VENTANA PRINCIPAL  --
-------------------------
local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(380, 0) -- aparecerá con animación
main.Position = UDim2.new(0.5, -190, 0.2, 0)
main.BackgroundColor3 = Color3.fromRGB(26,26,26)
main.BorderSizePixel = 0
main.Visible = false
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 36)
topBar.BackgroundColor3 = Color3.fromRGB(36,36,36)
topBar.BorderSizePixel = 0
topBar.Parent = main
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 12)

local titleMain = Instance.new("TextLabel")
titleMain.BackgroundTransparency = 1
titleMain.Size = UDim2.new(1, -12, 1, 0)
titleMain.Position = UDim2.new(0, 12, 0, 0)
titleMain.Font = Enum.Font.GothamBold
titleMain.TextSize = 14
titleMain.TextXAlignment = Enum.TextXAlignment.Left
titleMain.TextColor3 = Color3.fromRGB(235,235,235)
titleMain.Text = "Admin — pedri.exe  [L para ocultar/mostrar]"
titleMain.Parent = topBar

-- Drag de ventana
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
tabs.Position = UDim2.new(0, 10, 0, 44)
tabs.BackgroundTransparency = 1
tabs.Parent = main

local gridTabs = Instance.new("UIListLayout")
gridTabs.FillDirection = Enum.FillDirection.Horizontal
gridTabs.Padding = UDim.new(0, 8)
gridTabs.Parent = tabs

local function makeTabBtn(text)
    local b = Instance.new("TextButton")
    b.AutoButtonColor = true
    b.Size = UDim2.fromOffset(160, 32)
    b.BackgroundColor3 = Color3.fromRGB(45,45,45)
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.Text = text
    b.Parent = tabs
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    return b
end

local tabMove = makeTabBtn("Movimiento")
local tabVisual = makeTabBtn("Visual (debug)")

local pages = Instance.new("Frame")
pages.Size = UDim2.new(1, -20, 1, -44-36-16)
pages.Position = UDim2.new(0, 10, 0, 44+36+8)
pages.BackgroundTransparency = 1
pages.Parent = main

local pageMove = Instance.new("Frame")
pageMove.BackgroundTransparency = 1
pageMove.Size = UDim2.new(1, 0, 1, 0)
pageMove.Parent = pages

local pageVisual = Instance.new("Frame")
pageVisual.BackgroundTransparency = 1
pageVisual.Size = UDim2.new(1, 0, 1, 0)
pageVisual.Visible = false
pageVisual.Parent = pages

local function switchTo(which)
    pageMove.Visible = (which == "move")
    pageVisual.Visible = (which == "visual")
end

tabMove.MouseButton1Click:Connect(function() switchTo("move") end)
tabVisual.MouseButton1Click:Connect(function() switchTo("visual") end)

-------------------------
--  MOVIMIENTO: SLIDER --
-------------------------
local sliderBack = Instance.new("Frame")
sliderBack.Size = UDim2.new(1, -20, 0, 10)
sliderBack.Position = UDim2.new(0, 10, 0, 30)
sliderBack.BackgroundColor3 = Color3.fromRGB(50,50,50)
sliderBack.BorderSizePixel = 0
sliderBack.Parent = pageMove
Instance.new("UICorner", sliderBack).CornerRadius = UDim.new(0, 6)

local sliderKnob = Instance.new("Frame")
sliderKnob.Size = UDim2.fromOffset(14, 18)
sliderKnob.Position = UDim2.new((SPEED_DEFAULT-SPEED_MIN)/(SPEED_MAX-SPEED_MIN), -7, 0.5, -9)
sliderKnob.BackgroundColor3 = Color3.fromRGB(45,130,90)
sliderKnob.BorderSizePixel = 0
sliderKnob.Parent = sliderBack
Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)

local speedLabel = Instance.new("TextLabel")
speedLabel.BackgroundTransparency = 1
speedLabel.Position = UDim2.new(0, 10, 0, 52)
speedLabel.Size = UDim2.new(1, -20, 0, 20)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 14
speedLabel.TextColor3 = Color3.fromRGB(235,235,235)
speedLabel.Text = ("Velocidad: %d"):format(SPEED_DEFAULT)
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

-- Mantener velocidad al respawn
lp.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 10)
    if hum then hum.WalkSpeed = currentSpeed end
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

-- Conectar a todos
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
local function makeBtn(parent, text, posY)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -20, 0, 36)
    b.Position = UDim2.new(0, 10, 0, posY)
    b.BackgroundColor3 = Color3.fromRGB(45,45,45)
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.Text = text
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    return b
end

local btnNames = makeBtn(pageVisual, "Nombres: OFF", 10)
local btnESP   = makeBtn(pageVisual, "Resaltar (rojo): OFF", 56)

local function setBtnState(b, label, on)
    b.Text = label .. (on and "ON" or "OFF")
    b.BackgroundColor3 = on and Color3.fromRGB(45,130,90) or Color3.fromRGB(120,50,50)
end

btnNames.MouseButton1Click:Connect(function()
    showNames = not showNames
    for _,bb in pairs(nameTags) do
        if bb and bb.Parent then bb.Enabled = showNames end
    end
    setBtnState(btnNames, "Nombres: ", showNames)
end)

btnESP.MouseButton1Click:Connect(function()
    showHighlight = not showHighlight
    for _,h in pairs(highlights) do
        if h and h.Parent then h.Enabled = showHighlight end
    end
    setBtnState(btnESP, "Resaltar (rojo): ", showHighlight)
end)

setBtnState(btnNames, "Nombres: ", showNames)
setBtnState(btnESP,   "Resaltar (rojo): ", showHighlight)

-------------------------
--   TECLA L (toggle)  --
-------------------------
local function openMain()
    if main.Visible then return end
    main.Visible = true
    main.Size = UDim2.fromOffset(380, 0)
    TS:Create(main, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = UDim2.fromOffset(380, 280)}):Play()
end

local function closeMain()
    if not main.Visible then return end
    TS:Create(main, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = UDim2.fromOffset(380, 0)}):Play()
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
local function toast(txt)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "pedri.exe";
            Text = txt;
            Duration = 4;
        })
    end)
end

loginBtn.MouseButton1Click:Connect(function()
    if keyBox.Text == ACCESS_KEY then
        toast("Key correcta. Bienvenido.")
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
