--=====================================================
-- ADMIN PANEL SCRIPT - By pedri.exe
--=====================================================

-- Crear GUI
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local User = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui", User:WaitForChild("PlayerGui"))
ScreenGui.Name = "AdminPanelGUI"
ScreenGui.ResetOnSpawn = false

-- Panel Principal
local Panel = Instance.new("Frame", ScreenGui)
Panel.Name = "Panel"
Panel.Size = UDim2.new(0, 420, 0, 300)
Panel.Position = UDim2.new(0.5, -210, 1, 300)
Panel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Panel.BorderSizePixel = 0
Panel.Active = true
Panel.Draggable = true

local Corner = Instance.new("UICorner", Panel)
Corner.CornerRadius = UDim.new(0, 12)

-- Barra superior
local Topbar = Instance.new("Frame", Panel)
Topbar.Size = UDim2.new(1, 0, 0, 40)
Topbar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Instance.new("UICorner", Topbar).CornerRadius = UDim.new(0, 12)

local TopLabel = Instance.new("TextLabel", Topbar)
TopLabel.Size = UDim2.new(1, 0, 1, 0)
TopLabel.BackgroundTransparency = 1
TopLabel.Text = "ADMIN PANEL ACTIVADO | FPS: 0 | User: "..User.Name
TopLabel.TextColor3 = Color3.fromRGB(255,255,255)
TopLabel.Font = Enum.Font.GothamBold
TopLabel.TextSize = 16

-- USER INPUT
local UserBox = Instance.new("TextBox", Panel)
UserBox.PlaceholderText = "Pon tu usuario aquí"
UserBox.Text = ""
UserBox.Size = UDim2.new(0.8, 0, 0, 40)
UserBox.Position = UDim2.new(0.1, 0, 0.25, 0)
UserBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
UserBox.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", UserBox).CornerRadius = UDim.new(0, 10)

local PassBox = Instance.new("TextBox", Panel)
PassBox.PlaceholderText = "Pon tu contraseña aquí"
PassBox.Text = ""
PassBox.Size = UDim2.new(0.8, 0, 0, 40)
PassBox.Position = UDim2.new(0.1, 0, 0.45, 0)
PassBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
PassBox.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", PassBox).CornerRadius = UDim.new(0, 10)

local Status = Instance.new("TextLabel", Panel)
Status.Size = UDim2.new(1,0,0,40)
Status.Position = UDim2.new(0,0,0.65,0)
Status.BackgroundTransparency = 1
Status.TextColor3 = Color3.new(1,1,1)
Status.Font = Enum.Font.GothamBold
Status.TextSize = 18
Status.Text = ""

-- Animación de bolas cayendo
local BallsFolder = Instance.new("Folder", ScreenGui)

local function SpawnBall()
    local ball = Instance.new("Frame", BallsFolder)
    ball.Size = UDim2.new(0, math.random(20,50), 0, math.random(20,50))
    ball.Position = UDim2.new(math.random(), 0, -0.1, 0)
    ball.BackgroundColor3 = Color3.fromRGB(255, math.random(50,255), math.random(50,255))
    Instance.new("UICorner", ball).CornerRadius = UDim.new(1,0)

    task.spawn(function()
        for i = -0.1, 1.1, 0.01 do
            if Panel.Visible == false then 
                ball:Destroy()
                return
            end
            ball.Position = UDim2.new(ball.Position.X.Scale,0, i, 0)
            task.wait(0.01)
        end
        ball:Destroy()
    end)
end

-- Mostrar/Ocultar con L
local open = false
local UIS = game:GetService("UserInputService")

local function TogglePanel()
    open = not open

    if open then
        Panel.Visible = true
        for i = 1,30 do
            SpawnBall()
            task.wait(0.05)
        end

        -- Animación de subir
        Panel:TweenPosition(UDim2.new(0.5,-210,0.3,0), "Out", "Quad", 0.5, true)

    else
        -- Animación de bajar
        Panel:TweenPosition(UDim2.new(0.5,-210,1,300), "Out", "Quad", 0.5, true)
        task.wait(0.5)
        Panel.Visible = false
        BallsFolder:ClearAllChildren()
    end
end

UIS.InputBegan:Connect(function(key)
    if key.KeyCode == Enum.KeyCode.L then
        TogglePanel()
    end
end)

-- Login
local function CheckLogin()
    if UserBox.Text == "ASTRA" and PassBox.Text == "FREE" then
        Status.Text = "✔ Acceso concedido"
        Status.TextColor3 = Color3.fromRGB(0,255,0)
    else
        Status.Text = "❌ Usuario o contraseña incorrectos"
        Status.TextColor3 = Color3.fromRGB(255,0,0)
    end
end

UserBox.FocusLost:Connect(CheckLogin)
PassBox.FocusLost:Connect(CheckLogin)

-- FPS LIVE
RunService.RenderStepped:Connect(function()
    local fps = math.floor(1 / RunService.RenderStepped:Wait())
    TopLabel.Text = "ADMIN PANEL ACTIVADO | FPS: "..fps.." | User: "..User.Name
end)
