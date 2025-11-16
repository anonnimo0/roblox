-- Crear la pantalla principal
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

-- Crear el panel principal
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
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
aimSection.Size = UDim2.new(1, 0, 0, 200)
aimSection.Position = UDim2.new(0, 0, 0, 50)
aimSection.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
aimSection.BorderSizePixel = 2
aimSection.BorderColor3 = Color3.fromRGB(50, 50, 50)
aimSection.Parent = mainFrame

-- Botón AIMBOT ON/OFF
local aimbotButton = Instance.new("TextButton")
aimbotButton.Size = UDim2.new(0.5, 0, 0, 50)
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

-- Botón Sona ON/OFF
local sonaButton = Instance.new("TextButton")
sonaButton.Size = UDim2.new(0.5, 0, 0, 50)
sonaButton.Position = UDim2.new(0.5, 0, 0, 0)
sonaButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
sonaButton.Text = "Sona OFF"
sonaButton.TextColor3 = Color3.fromRGB(255, 255, 255)
sonaButton.TextSize = 18
sonaButton.Font = Enum.Font.SourceSans
sonaButton.Parent = aimSection

sonaButton.MouseButton1Click:Connect(function()
    if sonaButton.Text == "Sona OFF" then
        sonaButton.Text = "Sona ON"
    else
        sonaButton.Text = "Sona OFF"
    end
end)

-- Botón Suanona ON/OFF
local suanonaButton = Instance.new("TextButton")
suanonaButton.Size = UDim2.new(0.5, 0, 0, 50)
suanonaButton.Position = UDim2.new(0, 0, 0, 50)
suanonaButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
suanonaButton.Text = "Suanona OFF"
suanonaButton.TextColor3 = Color3.fromRGB(255, 255, 255)
suanonaButton.TextSize = 18
suanonaButton.Font = Enum.Font.SourceSans
suanonaButton.Parent = aimSection

suanonaButton.MouseButton1Click:Connect(function()
    if suanonaButton.Text == "Suanona OFF" then
        suanonaButton.Text = "Suanona ON"
    else
        suanonaButton.Text = "Suanona OFF"
    end
end)

-- Botón Repielanno SIN/OFF
local repielannoButton = Instance.new("TextButton")
repielannoButton.Size = UDim2.new(0.5, 0, 0, 50)
repielannoButton.Position = UDim2.new(0.5, 0, 0, 50)
repielannoButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
repielannoButton.Text = "Repielanno SIN"
repielannoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
repielannoButton.TextSize = 18
repielannoButton.Font = Enum.Font.SourceSans
repielannoButton.Parent = aimSection

repielannoButton.MouseButton1Click:Connect(function()
    if repielannoButton.Text == "Repielanno SIN" then
        repielannoButton.Text = "Repielanno OFF"
    else
        repielannoButton.Text = "Repielanno SIN"
    end
end)

-- Crear el apartado de VISUAL
local visualSection = Instance.new("Frame")
visualSection.Size = UDim2.new(1, 0, 0, 200)
visualSection.Position = UDim2.new(0, 0, 0, 250)
visualSection.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
visualSection.BorderSizePixel = 2
visualSection.BorderColor3 = Color3.fromRGB(50, 50, 50)
visualSection.Parent = mainFrame

-- Botón Name ON/OFF
local nameButton = Instance.new("TextButton")
nameButton.Size = UDim2.new(0.5, 0, 0, 50)
nameButton.Position = UDim2.new(0, 0, 0, 0)
nameButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
nameButton.Text = "Name OFF"
nameButton.TextColor3 = Color3.fromRGB(255, 255, 255)
nameButton.TextSize = 18
nameButton.Font = Enum.Font.SourceSans
nameButton.Parent = visualSection

nameButton.MouseButton1Click:Connect(function()
    if nameButton.Text == "Name OFF" then
        nameButton.Text = "Name ON"
    else
        nameButton.Text = "Name OFF"
    end
end)

-- Botón Box ON/OFF
local boxButton = Instance.new("TextButton")
boxButton.Size = UDim2.new(0.5, 0, 0, 50)
boxButton.Position = UDim2.new(0.5, 0, 0, 0)
boxButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
boxButton.Text = "Box OFF"
boxButton.TextColor3 = Color3.fromRGB(255, 255, 255)
boxButton.TextSize = 18
boxButton.Font = Enum.Font.SourceSans
boxButton.Parent = visualSection

boxButton.MouseButton1Click:Connect(function()
    if boxButton.Text == "Box OFF" then
        boxButton.Text = "Box ON"
    else
        boxButton.Text = "Box OFF"
    end
end)

-- Botón Health Bar ON/OFF
local healthBarButton = Instance.new("TextButton")
healthBarButton.Size = UDim2.new(0.5, 0, 0, 50)
healthBarButton.Position = UDim2.new(0, 0, 0, 50)
healthBarButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
healthBarButton.Text = "Health Bar OFF"
healthBarButton.TextColor3 = Color3.fromRGB(255, 255, 255)
healthBarButton.TextSize = 18
healthBarButton.Font = Enum.Font.SourceSans
healthBarButton.Parent = visualSection

healthBarButton.MouseButton1Click:Connect(function()
    if healthBarButton.Text == "Health Bar OFF" then
        healthBarButton.Text = "Health Bar ON"
    else
        healthBarButton.Text = "Health Bar OFF"
    end
end)

-- Botón Complemoe ON/OFF
local complemoeButton = Instance.new("TextButton")
complemoeButton.Size = UDim2.new(0.5, 0, 0, 50)
complemoeButton.Position = UDim2.new(0.5, 0, 0, 50)
complemoeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
complemoeButton.Text = "Complemoe OFF"
complemoeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
complemoeButton.TextSize = 18
complemoeButton.Font = Enum.Font.SourceSans
complemoeButton.Parent = visualSection

complemoeButton.MouseButton1Click:Connect(function()
    if complemoeButton.Text == "Complemoe OFF" then
        complemoeButton.Text = "Complemoe ON"
    else
        complemoeButton.Text = "Complemoe OFF"
    end
end)
