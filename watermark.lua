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
local t2 = createTab("Sección 2")
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

btnVer.MouseButton1Click:Connect(function()
    -- Aquí tú añades la lógica que quieras hacer al pulsar "Ver"
    -- (por ejemplo, algo para VIP, debug, etc.)
    print("Botón 'Ver' pulsado (MYSELF).")
end)

--------------------------------------------------
-- PAGE 2: Sección 2
--------------------------------------------------
local page2 = Instance.new("Frame")
page2.Size = UDim2.new(1, -20, 1, -20)
page2.Position = UDim2.new(0, 10, 0, 10)
page2.BackgroundTransparency = 1
page2.Visible = false
page2.Parent = pages

local page2Label = Instance.new("TextLabel")
page2Label.BackgroundTransparency = 1
page2Label.Size = UDim2.new(1, 0, 1, 0)
page2Label.Font = Enum.Font.Gotham
page2Label.TextSize = 16
page2Label.TextColor3 = Color3.fromRGB(220,220,240)
page2Label.TextWrapped = true
page2Label.TextXAlignment = Enum.TextXAlignment.Left
page2Label.TextYAlignment = Enum.TextYAlignment.Top
page2Label.Text = "Contenido de Sección 2."
page2Label.Parent = page2

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
t2.MouseButton1Click:Connect(function() showPage(2) end)
t3.MouseButton1Click:Connect(function() showPage(3) end)

-- Por defecto: MYSELF
showPage(1)
