-- Crear la pantalla principal
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

-- Crear el panel principal
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 300)
mainFrame.Position = UDim2.new(0.5, -100, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
mainFrame.Parent = screenGui

-- Crear el título del panel
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.Text = "ASTRA ROCK"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 24
title.Font = Enum.Font.SourceSansBold
title.Parent = mainFrame

-- Crear el apartado de AIM
local aimSection = Instance.new("Frame")
aimSection.Size = UDim2.new(1, 0, 0, 100)
aimSection.Position = UDim2.new(0, 0, 0, 50)
aimSection.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
aimSection.BorderSizePixel = 2
aimSection.BorderColor3 = Color3.fromRGB(50, 50, 50)
aimSection.Parent = mainFrame

-- Botón AIMBOT ON/OFF
local aimbotButton = Instance.new("TextButton")
aimbotButton.Size = UDim2.new(0.5, 0, 1, 0)
aimbotButton.Position = UDim2.new(0, 0, 0, 0)
aimbotButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
aimbotButton.Text = "AIMBOT OFF"
aimbotButton.TextColor3 = Color3.fromRGB(255, 255, 255)
aimbotButton.TextSize = 18
aimbotButton.Font = Enum.Font.SourceSans
aimbotButton.Parent = aimSection

aimbotButton.MouseButton1Click:Connect(function()
    if aimbotButton.Text == "AIMBOT OFF" then
        aimbotButton.Text = "AIMBOT ON"
    else
        aimbotButton.Text = "AIMBOT OFF"
    end
end)

-- Botón de FOV
local fovButton = Instance.new("TextButton")
fovButton.Size = UDim2.new(0.5, 0, 1, 0)
fovButton.Position = UDim2.new(0.5, 0, 0, 0)
fovButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
fovButton.Text = "FOV"
fovButton.TextColor3 = Color3.fromRGB(255, 255, 255)
fovButton.TextSize = 18
fovButton.Font = Enum.Font.SourceSans
fovButton.Parent = aimSection

fovButton.MouseButton1Click:Connect(function()
    -- Lógica para ajustar el FOV
end)

-- Crear el apartado de VISUAL
local visualSection = Instance.new("Frame")
visualSection.Size = UDim2.new(1, 0, 0, 100)
visualSection.Position = UDim2.new(0, 0, 0, 150)
visualSection.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
visualSection.BorderSizePixel = 2
visualSection.BorderColor3 = Color3.fromRGB(50, 50, 50)
visualSection.Parent = mainFrame

-- Botón de NAME
local nameButton = Instance.new("TextButton")
nameButton.Size = UDim2.new(0.5, 0, 1, 0)
nameButton.Position = UDim2.new(0, 0, 0, 0)
nameButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
nameButton.Text = "NAME"
nameButton.TextColor3 = Color3.fromRGB(255, 255, 255)
nameButton.TextSize = 18
nameButton.Font = Enum.Font.SourceSans
nameButton.Parent = visualSection

nameButton.MouseButton1Click:Connect(function()
    -- Lógica para mostrar nombres de jugadores
end)

-- Botón de BOX
local boxButton = Instance.new("TextButton")
boxButton.Size = UDim2.new(0.5, 0, 1, 0)
boxButton.Position = UDim2.new(0.5, 0, 0, 0)
boxButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
boxButton.Text = "BOX"
boxButton.TextColor3 = Color3.fromRGB(255, 255, 255)
boxButton.TextSize = 18
boxButton.Font = Enum.Font.SourceSans
boxButton.Parent = visualSection

boxButton.MouseButton1Click:Connect(function()
    -- Lógica para mostrar cajas alrededor de los jugadores
end)

-- Botón de HEALTH BAR
local healthBarButton = Instance.new("TextButton")
healthBarButton.Size = UDim2.new(0.5, 0, 1, 0)
healthBarButton.Position = UDim2.new(0, 0, 0, 100)
healthBarButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
healthBarButton.Text = "HEALTH BAR"
healthBarButton.TextColor3 = Color3.fromRGB(255, 255, 255)
healthBarButton.TextSize = 18
healthBarButton.Font = Enum.Font.SourceSans
healthBarButton.Parent = visualSection

healthBarButton.MouseButton1Click:Connect(function()
    -- Lógica para mostrar barras de salud
end)
