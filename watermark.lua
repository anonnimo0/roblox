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
dragTitle.Text = "CMD SHOP Panel"
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
-- PAGE 1: MYSELF
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
myselfTitle.Text = "MYSELF"
myselfTitle.Parent = page1

local btnVer = Instance.new("TextButton")
btnVer.Size = UDim2.new(0, 120, 0, 32)
btnVer.Position = UDim2.new(0, 0, 0, 40)
btnVer.BackgroundColor3 = Color3.fromRGB(30,30,50)
btnVer.BorderSizePixel = 0
btnVer.Font = Enum.Font.Gotham
btnVer.TextSize = 14
btnVer.Text = "Ver"
btnVer.TextColor3 = Color3.fromRGB(240,240,255)
btnVer.Parent = page1
Instance.new("UICorner", btnVer).CornerRadius = UDim.new(0, 8)

-- Contenedor simple de ejemplo al pulsar "Ver" (puedes usarlo para info de tu jugador, etc.)
local myselfInfo = Instance.new("TextLabel")
myselfInfo.BackgroundTransparency = 1
myselfInfo.Size = UDim2.new(1, 0, 0, 24)
myselfInfo.Position = UDim2.new(0, 0, 0, 80)
myselfInfo.Font = Enum.Font.Gotham
myselfInfo.TextSize = 14
myselfInfo.TextXAlignment = Enum.TextXAlignment.Left
myselfInfo.TextColor3 = Color3.fromRGB(230,230,255)
myselfInfo.Text = ""
myselfInfo.Parent = page1

btnVer.MouseButton1Click:Connect(function()
    print("Botón 'Ver' pulsado (MYSELF).")
    local device
    if UIS.TouchEnabled and not UIS.KeyboardEnabled then
        device = "Mobile"
    elseif UIS.GamepadEnabled and not UIS.KeyboardEnabled then
        device = "Console"
    else
        device = "PC"
    end
    myselfInfo.Text = "You are playing on: " .. device
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

-- Ajustar CanvasSize automáticamente
listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    playersList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
end)

-- Función para detectar dispositivo (solo exacto para tú mismo)
local function GetDeviceForPlayer(plr)
    -- Si el jugador es el LocalPlayer, detectamos por UserInputService
    if plr == lp then
        if UIS.TouchEnabled and not UIS.KeyboardEnabled then
            return "Mobile"
        elseif UIS.GamepadEnabled and not UIS.KeyboardEnabled then
            return "Console"
        else
            return "PC"
        end
    end
    
    -- Si en el server les has puesto un StringValue llamado "DeviceType"
    -- debajo del Player, lo usamos:
    local deviceTag = plr:FindFirstChild("DeviceType")
    if deviceTag and deviceTag:IsA("StringValue") then
        return deviceTag.Value
    end

    -- Si no sabemos, lo marcamos como Unknown
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

-- Botón manual de refresco
refreshBtn.MouseButton1Click:Connect(function()
    RefreshPlayerList()
end)

-- Actualización automática al entrar / salir players
Players.PlayerAdded:Connect(function(plr)
    CreatePlayerRow(plr)
end)

Players.PlayerRemoving:Connect(function(plr)
    local row = playersList:FindFirstChild(plr.Name)
    if row then
        row:Destroy()
    end
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
