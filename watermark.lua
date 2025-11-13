--// Panel genérico estilo “dashboard”
--// Solo interfaz, sin funciones

local Players = game:GetService("Players")
local lp = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "CustomPanel"
gui.ResetOnSpawn = false
pcall(function() gui.Parent = game.CoreGui end)
if not gui.Parent then gui.Parent = lp:WaitForChild("PlayerGui") end

-- Fondo oscuro total
local backdrop = Instance.new("Frame")
backdrop.Size = UDim2.fromScale(1, 1)
backdrop.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
backdrop.BorderSizePixel = 0
backdrop.Parent = gui

-- Contenedor principal (centrado)
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 800, 0, 460)
main.Position = UDim2.new(0.5, -400, 0.5, -230)
main.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
main.BorderSizePixel = 0
main.Parent = backdrop

local mainCorner = Instance.new("UICorner", main)
mainCorner.CornerRadius = UDim.new(0, 16)

-- Barra lateral izquierda
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 180, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
sidebar.BorderSizePixel = 0
sidebar.Parent = main

local sideCorner = Instance.new("UICorner", sidebar)
sideCorner.CornerRadius = UDim.new(0, 16)

-- Título del panel (arriba en la barra lateral)
local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -20, 0, 40)
title.Position = UDim2.new(0, 10, 0, 10)
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.fromRGB(240, 240, 255)
title.Text = "Tu Panel"
title.Parent = sidebar

-- Lista de pestañas debajo del título
local tabsHolder = Instance.new("Frame")
tabsHolder.BackgroundTransparency = 1
tabsHolder.Size = UDim2.new(1, -20, 1, -60)
tabsHolder.Position = UDim2.new(0, 10, 0, 56)
tabsHolder.Parent = sidebar

local tabsLayout = Instance.new("UIListLayout")
tabsLayout.Parent = tabsHolder
tabsLayout.FillDirection = Enum.FillDirection.Vertical
tabsLayout.Padding = UDim.new(0, 6)
tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function createTabButton(text)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 32)
    b.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
    b.TextColor3 = Color3.fromRGB(220, 220, 240)
    b.Font = Enum.Font.Gotham
    b.TextSize = 14
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.Text = "   " .. text
    b.AutoButtonColor = true
    b.Parent = tabsHolder

    local corner = Instance.new("UICorner", b)
    corner.CornerRadius = UDim.new(0, 8)

    return b
end

-- Crea aquí tus pestañas (nombres genéricos)
local tab1 = createTabButton("Sección 1")
local tab2 = createTabButton("Sección 2")
local tab3 = createTabButton("Sección 3")
local tab4 = createTabButton("Sección 4")
local tab5 = createTabButton("Sección 5")

-- Zona derecha (contenido)
local right = Instance.new("Frame")
right.Size = UDim2.new(1, -190, 1, 0)
right.Position = UDim2.new(0, 190, 0, 0)
right.BackgroundColor3 = Color3.fromRGB(14, 14, 24)
right.BorderSizePixel = 0
right.Parent = main

local rightCorner = Instance.new("UICorner", right)
rightCorner.CornerRadius = UDim.new(0, 16)

-- Barra superior derecha (buscador + avatar placeholder)
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, -20, 0, 40)
topBar.Position = UDim2.new(0, 10, 0, 8)
topBar.BackgroundColor3 = Color3.fromRGB(16, 16, 28)
topBar.BorderSizePixel = 0
topBar.Parent = right

local topCorner = Instance.new("UICorner", topBar)
topCorner.CornerRadius = UDim.new(0, 12)

-- Caja de búsqueda
local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(0.75, -16, 1, -12)
searchBox.Position = UDim2.new(0, 8, 0, 6)
searchBox.BackgroundColor3 = Color3.fromRGB(22, 22, 36)
searchBox.BorderSizePixel = 0
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 14
searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.TextColor3 = Color3.fromRGB(235, 235, 255)
searchBox.PlaceholderText = "Buscar..."
searchBox.Text = ""
searchBox.Parent = topBar

Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 10)

-- Avatar / icono a la derecha
local profile = Instance.new("ImageLabel")
profile.Size = UDim2.new(0, 28, 0, 28)
profile.Position = UDim2.new(1, -36, 0.5, -14)
profile.BackgroundTransparency = 1
profile.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
profile.Parent = topBar

-- Área de contenido (ahí luego pones sliders, toggles, etc.)
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -40, 1, -70)
content.Position = UDim2.new(0, 20, 0, 60)
content.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
content.BorderSizePixel = 0
content.Parent = right

Instance.new("UICorner", content).CornerRadius = UDim.new(0, 14)

-- Texto de ejemplo en el área de contenido
local placeholder = Instance.new("TextLabel")
placeholder.BackgroundTransparency = 1
placeholder.Size = UDim2.new(1, -20, 1, -20)
placeholder.Position = UDim2.new(0, 10, 0, 10)
placeholder.Font = Enum.Font.Gotham
placeholder.TextSize = 16
placeholder.TextColor3 = Color3.fromRGB(200, 200, 220)
placeholder.TextXAlignment = Enum.TextXAlignment.Left
placeholder.TextYAlignment = Enum.TextYAlignment.Top
placeholder.TextWrapped = true
placeholder.Text = "Aquí va el contenido de la pestaña seleccionada."
placeholder.Parent = content
