-- Astra Panel RX (LocalScript, StarterGui)
-- Panel + todo funcional (visual/legal)
-- Autor: ChatGPT (adaptado a tus peticiones)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- CONFIG (puedes ajustar valores)
local NEON_BLUE = Color3.fromRGB(0,170,255)
local RED_HIGHLIGHT = Color3.fromRGB(255,100,100)
local DEFAULT_HIGHLIGHT = Color3.fromRGB(0,200,255)
local DEFAULT_FOV_SIZE = 200 -- tamaño inicial del círculo FOV en px
local MAX_FOV = 700
local MIN_FOV = 50

-- UI root (si existe, lo limpia)
local existing = PlayerGui:FindFirstChild("AstraPanelRX")
if existing then existing:Destroy() end

local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "AstraPanelRX"
ScreenGui.ResetOnSpawn = false

-- ======================================================
-- Banner WELCOME
-- ======================================================
local Banner = Instance.new("Frame", ScreenGui)
Banner.Size = UDim2.new(0, 420, 0, 60)
Banner.Position = UDim2.new(0.5, -210, 0, 10)
Banner.AnchorPoint = Vector2.new(0.5,0)
Banner.BackgroundColor3 = NEON_BLUE
Banner.BorderSizePixel = 0
Instance.new("UICorner", Banner).CornerRadius = UDim.new(0,12)

local BannerText = Instance.new("TextLabel", Banner)
BannerText.Size = UDim2.new(1, -20, 1, 0)
BannerText.Position = UDim2.new(0,10,0,0)
BannerText.BackgroundTransparency = 1
BannerText.Font = Enum.Font.GothamBold
BannerText.TextScaled = true
BannerText.TextColor3 = Color3.new(1,1,1)
BannerText.Text = "WELCOME TO ASTRA PANEL RX"

-- ======================================================
-- Panel principal (oculto / toggle con L)
-- ======================================================
local Panel = Instance.new("Frame", ScreenGui)
Panel.Name = "MainPanel"
Panel.Size = UDim2.new(0, 620, 0, 420)
Panel.Position = UDim2.new(0.5, -310, 0.5, -210)
Panel.AnchorPoint = Vector2.new(0.5,0.5)
Panel.BackgroundColor3 = Color3.fromRGB(12, 62, 98)
Panel.BorderSizePixel = 0
Panel.Visible = false
Panel.ZIndex = 2
Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 14)

-- Top tabs bar
local TabsBar = Instance.new("Frame", Panel)
TabsBar.Size = UDim2.new(1,0,0,48)
TabsBar.Position = UDim2.new(0,0,0,0)
TabsBar.BackgroundColor3 = NEON_BLUE
Instance.new("UICorner", TabsBar).CornerRadius = UDim.new(0,10)

local function makeTab(text, x)
    local b = Instance.new("TextButton", TabsBar)
    b.Size = UDim2.new(0, 200, 1, -8)
    b.Position = UDim2.new(0, x, 0, 4)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 18
    b.BackgroundTransparency = 1
    b.TextColor3 = Color3.new(1,1,1)
    return b
end

local TabVisual = makeTab("VISUAL", 12)
local TabUser = makeTab("USER", 216)
-- (puedes añadir más tabs si quieres)

-- Content areas
local Content = Instance.new("Frame", Panel)
Content.Size = UDim2.new(1, -20, 1, -68)
Content.Position = UDim2.new(0, 10, 0, 58)
Content.BackgroundTransparency = 1

local VisualFrame = Instance.new("Frame", Content)
VisualFrame.Size = UDim2.new(1,0,1,0)
VisualFrame.BackgroundTransparency = 1

local UserFrame = VisualFrame:Clone()
UserFrame.Parent = Content
UserFrame.Visible = false

-- ======================================================
-- Helpers (NameTag, Highlight management)
-- ======================================================
local highlights = {}      -- highlights[plr] = Highlight instance
local nametags = {}        -- nametags[plr] = BillboardGui
local function createHighlightForCharacter(char, color)
    if not char then return end
    if char:FindFirstChildOfClass("Highlight") then return char:FindFirstChildOfClass("Highlight") end
    local h = Instance.new("Highlight")
    h.Adornee = char
    h.FillTransparency = 1
    h.OutlineTransparency = 0
    h.OutlineColor = color or DEFAULT_HIGHLIGHT
    h.Parent = char
    return h
end

local function removeHighlightForCharacter(char)
    if not char then return end
    for _,child in pairs(char:GetChildren()) do
        if child:IsA("Highlight") then child:Destroy() end
    end
end

local function createNameTagForCharacter(char, text)
    if not char or not char:FindFirstChild("Head") then return end
    if char.Head:FindFirstChild("AdminNameTag") then return end

    local bill = Instance.new("BillboardGui")
    bill.Name = "AdminNameTag"
    bill.Adornee = char.Head
    bill.Size = UDim2.new(0,120,0,40)
    bill.StudsOffset = Vector3.new(0,2.4,0)
    bill.AlwaysOnTop = true
    bill.Parent = char.Head

    local label = Instance.new("TextLabel", bill)
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.TextColor3 = NEON_BLUE
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Text = text or char.Name
end

local function removeNameTagForCharacter(char)
    if not char or not char:FindFirstChild("Head") then return end
    local g = char.Head:FindFirstChild("AdminNameTag")
    if g then g:Destroy() end
end

-- ======================================================
-- VISUAL TAB: controls (Name, Boxes, Boxes en ROJO, FOV decorative)
-- ======================================================

-- Layout helper
local function makeLabel(parent, text, posY)
    local l = Instance.new("TextLabel", parent)
    l.Size = UDim2.new(0, 260, 0, 28)
    l.Position = UDim2.new(0, 6, 0, posY)
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.Gotham
    l.TextSize = 18
    l.TextColor3 = Color3.fromRGB(230,230,230)
    l.Text = text
    l.TextXAlignment = Enum.TextXAlignment.Left
    return l
end

local function makeToggle(parent, text, posY)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0, 140, 0, 36)
    btn.Position = UDim2.new(0, 320, 0, posY)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.BackgroundColor3 = NEON_BLUE
    btn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
    return btn
end

-- Visual options
local y = 6
makeLabel(VisualFrame, "Nombres sobre la cabeza", y)
local BtnName = makeToggle(VisualFrame, "TOGGLE NAME", y)

y = y + 44
makeLabel(VisualFrame, "Boxes / Highlight (outline)", y)
local BtnBox = makeToggle(VisualFrame, "TOGGLE BOXES", y)

y = y + 44
makeLabel(VisualFrame, "Resaltar enemigos en rojo", y)
local BtnEnemyRed = makeToggle(VisualFrame, "TOGGLE RED", y)

y = y + 44
makeLabel(VisualFrame, "Mostrar Círculo FOV (decorativo)", y)
local BtnFOV = makeToggle(VisualFrame, "TOGGLE FOV", y)

y = y + 44
makeLabel(VisualFrame, "AIM SELF (visual assist, mantén botón derecho)", y)
local BtnAimSelf = makeToggle(VisualFrame, "AIM SELF", y)

-- ======================================================
-- FOV circle (GUI) - aparece en el centro y es escalable
-- ======================================================
local FOVContainer = Instance.new("Frame", ScreenGui)
FOVContainer.Size = UDim2.new(0, DEFAULT_FOV_SIZE, 0, DEFAULT_FOV_SIZE)
FOVContainer.Position = UDim2.new(0.5, -DEFAULT_FOV_SIZE/2, 0.5, -DEFAULT_FOV_SIZE/2)
FOVContainer.AnchorPoint = Vector2.new(0.5,0.5)
FOVContainer.BackgroundTransparency = 1
FOVContainer.Visible = false
FOVContainer.ZIndex = 5

local FOVCircle = Instance.new("Frame", FOVContainer)
FOVCircle.Size = UDim2.new(1,0,1,0)
FOVCircle.Position = UDim2.new(0,0,0,0)
FOVCircle.BackgroundTransparency = 0.85
FOVCircle.BorderSizePixel = 0
FOVCircle.BackgroundColor3 = Color3.fromRGB(20,20,20)
local uic = Instance.new("UICorner", FOVCircle)
uic.CornerRadius = UDim.new(1,0) -- fully round

local FOVOutline = Instance.new("Frame", FOVContainer)
FOVOutline.Size = UDim2.new(1,0,1,0)
FOVOutline.Position = UDim2.new(0,0,0,0)
FOVOutline.BackgroundTransparency = 1
local outlineStroke = Instance.new("UIStroke", FOVContainer)
outlineStroke.Thickness = 2
outlineStroke.Color = NEON_BLUE
outlineStroke.Transparency = 0.2

-- Slider for FOV size
local SliderBar = Instance.new("Frame", VisualFrame)
SliderBar.Size = UDim2.new(0, 300, 0, 18)
SliderBar.Position = UDim2.new(0, 12, 0, 320)
SliderBar.BackgroundColor3 = Color3.fromRGB(40,40,40)
Instance.new("UICorner", SliderBar).CornerRadius = UDim.new(0,8)

local SliderKnob = Instance.new("TextButton", SliderBar)
SliderKnob.Size = UDim2.new(0, 18, 1, 0)
SliderKnob.Position = UDim2.new((DEFAULT_FOV_SIZE - MIN_FOV)/(MAX_FOV - MIN_FOV), 0, 0, 0)
SliderKnob.Text = ""
SliderKnob.BackgroundColor3 = NEON_BLUE
Instance.new("UICorner", SliderKnob).CornerRadius = UDim.new(0,9)

local dragging = false
SliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
    end
end)
SliderKnob.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- ======================================================
-- State variables
-- ======================================================
local state = {
    names = false,
    boxes = false,
    enemyRed = false,
    fov = false,
    aimSelf = false,
    fovSize = DEFAULT_FOV_SIZE
}

-- ======================================================
-- Functions to toggle features
-- ======================================================
local function updateAllHighlightsColor()
    for plr,h in pairs(highlights) do
        if h and h.Parent then
            if state.enemyRed and plr ~= LocalPlayer then
                h.OutlineColor = RED_HIGHLIGHT
            else
                h.OutlineColor = DEFAULT_HIGHLIGHT
            end
        end
    end
end

-- NAME toggle
BtnName.MouseButton1Click:Connect(function()
    state.names = not state.names
    BtnName.Text = state.names and "NAME: ON" or "NAME: OFF"
    if state.names then
        for _,plr in pairs(Players:GetPlayers()) do
            if plr.Character then
                createNameTagForCharacter(plr.Character, plr.Name)
            end
            plr.CharacterAdded:Connect(function(c)
                if state.names then
                    createNameTagForCharacter(c, plr.Name)
                end
            end)
        end
    else
        -- remove nametags
        for _,plr in pairs(Players:GetPlayers()) do
            if plr.Character then removeNameTagForCharacter(plr.Character) end
        end
    end
end)

-- BOXES toggle
BtnBox.MouseButton1Click:Connect(function()
    state.boxes = not state.boxes
    BtnBox.Text = state.boxes and "BOXES: ON" or "BOXES: OFF"
    if state.boxes then
        for _,plr in pairs(Players:GetPlayers()) do
            if plr.Character and not highlights[plr] then
                local h = createHighlightForCharacter(plr.Character, DEFAULT_HIGHLIGHT)
                highlights[plr] = h
            end
            plr.CharacterAdded:Connect(function(c)
                if state.boxes then
                    local h = createHighlightForCharacter(c, DEFAULT_HIGHLIGHT)
                    highlights[plr] = h
                end
            end)
        end
    else
        for k,v in pairs(highlights) do
            if v and v.Parent then v:Destroy() end
        end
        highlights = {}
    end
end)

-- ENEMY RED toggle
BtnEnemyRed.MouseButton1Click:Connect(function()
    state.enemyRed = not state.enemyRed
    BtnEnemyRed.Text = state.enemyRed and "ENEMY RED: ON" or "ENEMY RED: OFF"
    updateAllHighlightsColor()
end)

-- FOV toggle
BtnFOV.MouseButton1Click:Connect(function()
    state.fov = not state.fov
    BtnFOV.Text = state.fov and "FOV: ON" or "FOV: OFF"
    FOVContainer.Visible = state.fov
end)

-- AIM SELF toggle (visual assist)
BtnAimSelf.MouseButton1Click:Connect(function()
    state.aimSelf = not state.aimSelf
    BtnAimSelf.Text = state.aimSelf and "AIM SELF: ON" or "AIM SELF: OFF"
    -- when enabling aimSelf, usually enable FOV and boxes for clarity
    if state.aimSelf then
        state.fov = true
        FOVContainer.Visible = true
        BtnFOV.Text = "FOV: ON"
        if not state.boxes then
            -- enable boxes for visual
            BtnBox:Activate = true
            BtnBox:GetPropertyChangedSignal("Text"):Wait() -- no-op to keep consistent
        end
    end
end)

-- Slider dragging update
RunService.RenderStepped:Connect(function()
    if dragging then
        local mouse = PlayerGui:GetMouse()
        local x = mouse.X
        local left = SliderBar.AbsolutePosition.X
        local width = SliderBar.AbsoluteSize.X
        local rel = math.clamp((x - left) / width, 0, 1)
        SliderKnob.Position = UDim2.new(rel, 0, 0, 0)
        local newSize = math.floor(MIN_FOV + rel * (MAX_FOV - MIN_FOV))
        state.fovSize = newSize
        FOVContainer.Size = UDim2.new(0, newSize, 0, newSize)
        FOVContainer.Position = UDim2.new(0.5, -newSize/2, 0.5, -newSize/2)
    end
end)

-- ======================================================
-- Aim detection (visual only): busca objetivo más cercano dentro del FOV
-- ======================================================
local function getHead(plr)
    if not plr or not plr.Character then return nil end
    return plr.Character:FindFirstChild("Head")
end

local function getClosestTargetInFOV()
    local camCFrame = Camera.CFrame
    local camPos = camCFrame.Position
    local look = camCFrame.LookVector

    local fovPixels = state.fovSize
    if not state.fov then return nil end

    local best = nil
    local bestDist = math.huge

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            local head = plr.Character.Head
            local dir = (head.Position - camPos)
            local distance = dir.Magnitude
            local dirUnit = dir.Unit
            local dot = look:Dot(dirUnit)
            local angle = math.deg(math.acos(math.clamp(dot, -1, 1)))
            -- compute an approximate angle threshold from fovPixels and camera FOV
            local camFov = Camera.FieldOfView
            local screenRadius = (fovPixels / (workspace.CurrentCamera.ViewportSize.Y)) * camFov -- approx relation
            -- we'll just use a conservative angle threshold: smaller fovPixels -> smaller angle
            local angleThreshold = math.clamp( (fovPixels / workspace.CurrentCamera.ViewportSize.Y) * 120, 5, 90)
            if angle <= angleThreshold and distance < bestDist then
                best = plr
                bestDist = distance
            end
        end
    end
    return best
end

-- Visual highlight for current aim target
local currentAimTarget = nil
local aimHighlight = nil

local function setAimHighlightTarget(plr)
    if aimHighlight and aimHighlight.Parent then aimHighlight:Destroy() end
    currentAimTarget = plr
    if plr and plr.Character then
        aimHighlight = Instance.new("Highlight")
        aimHighlight.Adornee = plr.Character
        aimHighlight.FillTransparency = 1
        aimHighlight.OutlineTransparency = 0
        aimHighlight.OutlineColor = RED_HIGHLIGHT
        aimHighlight.Parent = plr.Character
    end
end

-- Clear aim highlight
local function clearAimHighlight()
    if aimHighlight and aimHighlight.Parent then aimHighlight:Destroy() end
    aimHighlight = nil
    currentAimTarget = nil
end

-- Update loop: si AIM SELF activado y botón derecho presionado -> resalta objetivo más cercano dentro del FOV
local rightDown = false
local mouse = PlayerGui:GetMouse()

mouse.Button2Down:Connect(function()
    rightDown = true
end)
mouse.Button2Up:Connect(function()
    rightDown = false
    clearAimHighlight()
end)

RunService.RenderStepped:Connect(function()
    -- keep colors of highlights updated if boxes or enemyRed changed
    updateAllHighlightsColor()

    -- handle aim self logic
    if state.aimSelf and rightDown then
        local target = getClosestTargetInFOV()
        if target then
            setAimHighlightTarget(target)
        else
            clearAimHighlight()
        end
    else
        -- if not holding right or not enabled, remove aim highlight only (not other highlights)
        if aimHighlight then clearAimHighlight() end
    end
end)

-- When players spawn/despawn, keep boxes and names in sync
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(c)
        if state.names then createNameTagForCharacter(c, plr.Name) end
        if state.boxes then
            local h = createHighlightForCharacter(c, DEFAULT_HIGHLIGHT)
            highlights[plr] = h
        end
    end)
end)

Players.PlayerRemoving:Connect(function(plr)
    if highlights[plr] then
        if highlights[plr].Parent then highlights[plr]:Destroy() end
        highlights[plr] = nil
    end
end)

-- ======================================================
-- Tabs switching
-- ======================================================
TabVisual.MouseButton1Click:Connect(function()
    VisualFrame.Visible = true
    UserFrame.Visible = false
end)
TabUser.MouseButton1Click:Connect(function()
    VisualFrame.Visible = false
    UserFrame.Visible = true
end)

-- ======================================================
-- USER tab (puedes personalizar)
-- - aquí pondremos controles que no son trampas: por ejemplo HUD toggle, personal cosmetic
-- ======================================================
local y2 = 12
local userLabel = makeLabel(UserFrame, "Opciones de usuario (legales):", y2)
y2 = y2 + 44
local BtnHud = makeToggle(UserFrame, "TOGGLE HUD", y2)
local BtnSpeed = makeToggle(UserFrame, "TOGGLE SPEED", y2 + 56)

-- Implementación sencilla: HUD toggle (muestra/oculta banner) y speed modd (solo local)
local hudOn = true
BtnHud.MouseButton1Click:Connect(function()
    hudOn = not hudOn
    BtnHud.Text = hudOn and "HUD: ON" or "HUD: OFF"
    Banner.Visible = hudOn
end)

local speedOn = false
local originalWalkSpeed = nil
BtnSpeed.MouseButton1Click:Connect(function()
    speedOn = not speedOn
    BtnSpeed.Text = speedOn and "SPEED: ON" or "SPEED: OFF"
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        local hum = char.Humanoid
        if speedOn then
            originalWalkSpeed = hum.WalkSpeed
            hum.WalkSpeed = math.clamp(hum.WalkSpeed * 1.6, 16, 200)
        else
            if originalWalkSpeed then hum.WalkSpeed = originalWalkSpeed end
        end
    end
end)

-- ======================================================
-- Toggle Panel with L (mostrar/ocultar)
-- ======================================================
local panelOpen = false
UIS.InputBegan:Connect(function(input, typing)
    if typing then return end
    if input.KeyCode == Enum.KeyCode.L then
        panelOpen = not panelOpen
        Panel.Visible = panelOpen
    end
end)

-- ======================================================
-- Final: initialize defaults
-- ======================================================
-- Start with banner visible, panel hidden
Banner.Visible = true
Panel.Visible = false
FOVContainer.Visible = false

-- Ensure characters that already exist get nametags/highlights if toggled later
for _,plr in pairs(Players:GetPlayers()) do
    if plr.Character then
        -- nothing enabled yet; will create when toggles pressed
    end
end

-- Mensaje de lista rápida en consola
warn("Astra Panel RX cargado (local). Usa L para abrir/ocultar.")
