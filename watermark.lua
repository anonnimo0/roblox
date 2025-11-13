local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local UIS = game:GetService("UserInputService")

local gui = Instance.new("ScreenGui")
gui.Name = "CustomPanel"
gui.ResetOnSpawn = false
pcall(function() gui.Parent = game.CoreGui end)
if not gui.Parent then gui.Parent = lp:WaitForChild("PlayerGui") end

--=============================
-- PANEL PRINCIPAL + DRAG
--=============================

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 800, 0, 460)
main.Position = UDim2.new(0.5, -400, 0.5, -230)
main.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 16)

-- Barra superior (zona para arrastrar)
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
dragTitle.Text = "Menu Admin"
dragTitle.Parent = topDrag

-- Drag logic
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

--=============================
-- BARRA LATERAL (TABS)
--=============================

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
tabLayout.FillDirection = Enum.FillDirection.Vertical

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
    b.AutoButtonColor = true
    b.Parent = tabsHolder
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    return b
end

local t1 = createTab("MYSELF")
local t2 = createTab("PLAYER LIST")
local t3 = createTab("Sección 3")

--=============================
-- ZONA DERECHA + PÁGINAS
--=============================

local right = Instance.new("Frame")
right.Size = UDim2.new(1, -200, 1, -50)
right.Position = UDim2.new(0, 190, 0, 50)
right.BackgroundColor3 = Color3.fromRGB(18,18,30)
right.BorderSizePixel = 0
right.Parent = main
Instance.new("UICorner", right).CornerRadius = UDim.new(0, 12)

local pages = Instance.new("Folder")
pages.Name = "Pages"
pages.Parent = right

--------------------------------------------------
-- PAGE 1: MYSELF (MENU ADMIN)
--------------------------------------------------
local page1 = Instance.new("Frame")
page1.Size = UDim2.new(1, -20, 1, -20)
page1.Position = UDim2.new(0, 10, 0, 10)
page1.BackgroundTransparency = 1
page1.Parent = pages

local myselfTitle = Instance.new("TextLabel")
myselfTitle.BackgroundTransparency = 1
myselfTitle.Size = UDim2.new(1, 0, 0, 28)
myselfTitle.Position = UDim2.new(0, 0, 0, 0)
myselfTitle.Font = Enum.Font.GothamBold
myselfTitle.TextSize = 20
myselfTitle.TextXAlignment = Enum.TextXAlignment.Left
myselfTitle.TextColor3 = Color3.fromRGB(230,230,250)
myselfTitle.Text = "MENU ADMIN"
myselfTitle.Parent = page1

-- Contenedor de opciones (switches)
local optionsHolder = Instance.new("Frame")
optionsHolder.BackgroundTransparency = 1
optionsHolder.Size = UDim2.new(1, 0, 1, -40)
optionsHolder.Position = UDim2.new(0, 0, 0, 40)
optionsHolder.Parent = page1

local optionsLayout = Instance.new("UIListLayout")
optionsLayout.Parent = optionsHolder
optionsLayout.FillDirection = Enum.FillDirection.Vertical
optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
optionsLayout.Padding = UDim.new(0, 8)

-- Función para crear un toggle
local function createToggleRow(text)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -10, 0, 32)
    row.BackgroundColor3 = Color3.fromRGB(20,20,32)
    row.BorderSizePixel = 0
    row.Parent = optionsHolder
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0.7, -10, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextColor3 = Color3.fromRGB(230,230,255)
    label.Text = text
    label.Parent = row

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 80, 0, 24)
    toggle.Position = UDim2.new(1, -90, 0.5, -12)
    toggle.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
    toggle.BorderSizePixel = 0
    toggle.Font = Enum.Font.GothamBold
    toggle.TextSize = 14
    toggle.TextColor3 = Color3.fromRGB(240,240,255)
    toggle.Text = "OFF"
    toggle.AutoButtonColor = true
    toggle.Parent = row
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 12)

    return toggle
end

--------------------------------------------------
-- LÓGICA REAL: NOMBRES + MARCAR EN ROJO
--------------------------------------------------

-- Estados de las opciones
local option1Enabled = false -- ver nombre de users
local option2Enabled = false -- marcar a jugadores en rojo
local allEnabled     = false -- activar todo/apagar

-- Tablas para guardar instancias
local nameTags = {}       -- [player] = BillboardGui
local redHighlights = {}  -- [player] = Highlight

-- Actualizar visual del botón
local function setToggleVisual(btn, state)
    if state then
        btn.Text = "ON"
        btn.BackgroundColor3 = Color3.fromRGB(30,120,40)
    else
        btn.Text = "OFF"
        btn.BackgroundColor3 = Color3.fromRGB(80,20,20)
    end
end

-- Crear / borrar nombre encima de la cabeza
local function RemoveNameTag(plr)
    local gui = nameTags[plr]
    if gui then
        gui:Destroy()
        nameTags[plr] = nil
    end
end

local function ApplyNameTag(plr)
    local char = plr.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end

    -- Si ya existe, solo re-adornear
    local gui = nameTags[plr]
    if gui and gui.Parent then
        gui.Adornee = head
        gui.Parent = head
        return
    end

    gui = Instance.new("BillboardGui")
    gui.Name = "NameESP"
    gui.Size = UDim2.new(0, 200, 0, 50)
    gui.StudsOffset = Vector3.new(0, 3, 0)
    gui.AlwaysOnTop = true
    gui.Adornee = head
    gui.Parent = head

    local textLabel = Instance.new("TextLabel")
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 16
    textLabel.TextStrokeTransparency = 0.3
    textLabel.TextColor3 = Color3.fromRGB(255,255,255)
    textLabel.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    textLabel.Text = plr.Name
    textLabel.Parent = gui

    nameTags[plr] = gui
end

-- Crear / borrar highlight rojo en el player
local function RemoveRedHighlight(plr)
    local h = redHighlights[plr]
    if h then
        h:Destroy()
        redHighlights[plr] = nil
    end
end

local function ApplyRedHighlight(plr)
    local char = plr.Character
    if not char then return end

    local h = redHighlights[plr]
    if not h or not h.Parent then
        h = Instance.new("Highlight")
        redHighlights[plr] = h
    end

    h.FillColor = Color3.fromRGB(255,0,0)
    h.FillTransparency = 0.5
    h.OutlineColor = Color3.fromRGB(255,255,255)
    h.OutlineTransparency = 0
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Adornee = char
    h.Parent = char
end

-- Al respawnear un player, reaplicar cosas si están ON
local function SetupESPForPlayer(plr)
    plr.CharacterAdded:Connect(function()
        if option1Enabled then
            ApplyNameTag(plr)
        end
        if option2Enabled then
            ApplyRedHighlight(plr)
        end
    end)

    if plr.Character then
        if option1Enabled then
            ApplyNameTag(plr)
        end
        if option2Enabled then
            ApplyRedHighlight(plr)
        end
    end
end

-- Callbacks de cambio de opción
local function OnOption1Changed(state)
    option1Enabled = state
    print("Opción 1 (Ver nombre de users) =", state)

    -- Aplicar o quitar a todos
    for _,plr in ipairs(Players:GetPlayers()) do
        if state then
            ApplyNameTag(plr)
        else
            RemoveNameTag(plr)
        end
    end
end

local function OnOption2Changed(state)
    option2Enabled = state
    print("Opción 2 (Marcar a jugadores en rojo) =", state)

    for _,plr in ipairs(Players:GetPlayers()) do
        if state then
            ApplyRedHighlight(plr)
        else
            RemoveRedHighlight(plr)
        end
    end
end

local function OnAllChanged(state)
    allEnabled = state
    print("Opción 3 (Activar todo/Apagar) =", state)

    option1Enabled = state
    option2Enabled = state

    setToggleVisual(toggle1, state)
    setToggleVisual(toggle2, state)

    OnOption1Changed(state)
    OnOption2Changed(state)
end

-- Crear filas de toggles
local toggle1 = createToggleRow("1) Ver nombre de users")
local toggle2 = createToggleRow("2) Marcar a jugadores en rojo")
local toggleAll = createToggleRow("3) Activar todo / Apagar")

-- Conexiones de los botones
toggle1.MouseButton1Click:Connect(function()
    option1Enabled = not option1Enabled
    setToggleVisual(toggle1, option1Enabled)
    OnOption1Changed(option1Enabled)
end)

toggle2.MouseButton1Click:Connect(function()
    option2Enabled = not option2Enabled
    setToggleVisual(toggle2, option2Enabled)
    OnOption2Changed(option2Enabled)
end)

toggleAll.MouseButton1Click:Connect(function()
    allEnabled = not allEnabled
    setToggleVisual(toggleAll, allEnabled)
    OnAllChanged(allEnabled)
end)

--------------------------------------------------
-- PAGE 2: PLAYER LIST (Admin)
--------------------------------------------------
local page2 = Instance.new("Frame")
page2.Size = UDim2.new(1, -20, 1, -20)
page2.Position = UDim2.new(0, 10, 0, 10)
page2.BackgroundTransparency = 1
page2.Visible = false
page2.Parent = pages

local page2Title = Instance.new("TextLabel")
page2Title.BackgroundTransparency = 1
page2Title.Size = UDim2.new(1, 0, 0, 28)
page2Title.Position = UDim2.new(0, 0, 0, 0)
page2Title.Font = Enum.Font.GothamBold
page2Title.TextSize = 20
page2Title.TextXAlignment = Enum.TextXAlignment.Left
page2Title.TextColor3 = Color3.fromRGB(230,230,250)
page2Title.Text = "PLAYER LIST"
page2Title.Parent = page2

local refreshBtn = Instance.new("TextButton")
refreshBtn.Size = UDim2.new(0, 120, 0, 28)
refreshBtn.Position = UDim2.new(1, -130, 0, 2)
refreshBtn.BackgroundColor3 = Color3.fromRGB(30,30,50)
refreshBtn.BorderSizePixel = 0
refreshBtn.Font = Enum.Font.Gotham
refreshBtn.TextSize = 13
refreshBtn.Text = "Refresh"
refreshBtn.TextColor3 = Color3.fromRGB(240,240,255)
refreshBtn.Parent = page2
Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0, 8)

-- ScrollingFrame para la lista de jugadores
local playersList = Instance.new("ScrollingFrame")
playersList.Size = UDim2.new(1, 0, 1, -40)
playersList.Position = UDim2.new(0, 0, 0, 36)
playersList.CanvasSize = UDim2.new(0, 0, 0, 0)
playersList.ScrollBarThickness = 4
playersList.BackgroundColor3 = Color3.fromRGB(15,15,24)
playersList.BorderSizePixel = 0
playersList.Parent = page2
Instance.new("UICorner", playersList).CornerRadius = UDim.new(0, 8)

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = playersList
listLayout.Padding = UDim.new(0, 4)
listLayout.FillDirection = Enum.FillDirection.Vertical
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    playersList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
end)

-- Función para detectar dispositivo
local function GetDeviceForPlayer(plr)
    if plr == lp then
        if UIS.TouchEnabled and not UIS.KeyboardEnabled then
            return "Mobile"
        elseif UIS.GamepadEnabled and not UIS.KeyboardEnabled then
            return "Console"
        else
            return "PC"
        end
    end

    local deviceTag = plr:FindFirstChild("DeviceType")
    if deviceTag and deviceTag:IsA("StringValue") then
        return deviceTag.Value
    end

    return "Unknown"
end

local function CreatePlayerRow(plr)
    local row = Instance.new("Frame")
    row.Name = plr.Name
    row.Size = UDim2.new(1, -10, 0, 26)
    row.BackgroundColor3 = Color3.fromRGB(20,20,32)
    row.BorderSizePixel = 0
    row.Parent = playersList
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

    local nameLabel = Instance.new("TextLabel")
    nameLabel.BackgroundTransparency = 1
    nameLabel.Size = UDim2.new(0.6, -10, 1, 0)
    nameLabel.Position = UDim2.new(0, 8, 0, 0)
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.TextSize = 14
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextColor3 = Color3.fromRGB(230,230,255)
    nameLabel.Text = plr.Name
    nameLabel.Parent = row

    local deviceLabel = Instance.new("TextLabel")
    deviceLabel.BackgroundTransparency = 1
    deviceLabel.Size = UDim2.new(0.4, -8, 1, 0)
    deviceLabel.Position = UDim2.new(0.6, 0, 0, 0)
    deviceLabel.Font = Enum.Font.Gotham
    deviceLabel.TextSize = 14
    deviceLabel.TextXAlignment = Enum.TextXAlignment.Right
    deviceLabel.TextColor3 = Color3.fromRGB(200,200,255)
    deviceLabel.Text = GetDeviceForPlayer(plr)
    deviceLabel.Parent = row
end

local function ClearPlayerRows()
    for _,child in ipairs(playersList:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
end

local function RefreshPlayerList()
    ClearPlayerRows()
    for _,plr in ipairs(Players:GetPlayers()) do
        CreatePlayerRow(plr)
    end
end

refreshBtn.MouseButton1Click:Connect(function()
    RefreshPlayerList()
end)

-- Inicializar lista + ESP para los players actuales
for _,plr in ipairs(Players:GetPlayers()) do
    CreatePlayerRow(plr)
    SetupESPForPlayer(plr)
end

Players.PlayerAdded:Connect(function(plr)
    CreatePlayerRow(plr)
    SetupESPForPlayer(plr)
end)

Players.PlayerRemoving:Connect(function(plr)
    local row = playersList:FindFirstChild(plr.Name)
    if row then
        row:Destroy()
    end
    RemoveNameTag(plr)
    RemoveRedHighlight(plr)
end)

--------------------------------------------------
-- PAGE 3: Sección 3
--------------------------------------------------
local page3 = Instance.new("Frame")
page3.Size = UDim2.new(1, -20, 1, -20)
page3.Position = UDim2.new(0, 10, 0, 10)
page3.BackgroundTransparency = 1
page3.Visible = false
page3.Parent = pages

local page3Label = Instance.new("TextLabel")
page3Label.BackgroundTransparency = 1
page3Label.Size = UDim2.new(1, 0, 1, 0)
page3Label.Font = Enum.Font.Gotham
page3Label.TextSize = 16
page3Label.TextColor3 = Color3.fromRGB(220,220,240)
page3Label.TextWrapped = true
page3Label.TextXAlignment = Enum.TextXAlignment.Left
page3Label.TextYAlignment = Enum.TextYAlignment.Top
page3Label.Text = "Contenido de Sección 3."
page3Label.Parent = page3

--=============================
-- SISTEMA DE CAMBIO DE PÁGINA
--=============================

local function showPage(which)
    page1.Visible = (which == 1)
    page2.Visible = (which == 2)
    page3.Visible = (which == 3)
end

t1.MouseButton1Click:Connect(function() showPage(1) end)
t2.MouseButton1Click:Connect(function()
    showPage(2)
    RefreshPlayerList()
end)
t3.MouseButton1Click:Connect(function() showPage(3) end)

-- Por defecto: MYSELF
showPage(1)
