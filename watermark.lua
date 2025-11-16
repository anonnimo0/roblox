--=====================================================
-- ADMIN PANEL v2 - Actualizado
--=====================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local User = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui", User.PlayerGui)
ScreenGui.Name = "AdminPanelGUI"
ScreenGui.ResetOnSpawn = false

--=====================================================
-- PANEL SUPERIOR (FPS + USER)
--=====================================================

local TopPanel = Instance.new("Frame", ScreenGui)
TopPanel.Size = UDim2.new(0, 380, 0, 40)
TopPanel.Position = UDim2.new(0.5, -190, 0, 10)
TopPanel.BackgroundColor3 = Color3.fromRGB(0,170,255)
TopPanel.BorderSizePixel = 0
Instance.new("UICorner", TopPanel).CornerRadius = UDim.new(0, 10)

local TopText = Instance.new("TextLabel", TopPanel)
TopText.Size = UDim2.new(1,0,1,0)
TopText.BackgroundTransparency = 1
TopText.TextColor3 = Color3.new(1,1,1)
TopText.Font = Enum.Font.GothamBold
TopText.TextSize = 16
TopText.Text = "ADMIN PANEL ACTIVADO | FPS: 0 | User: "..User.Name


--=====================================================
-- PANEL PRINCIPAL
--=====================================================

local Panel = Instance.new("Frame", ScreenGui)
Panel.Name = "Panel"
Panel.Size = UDim2.new(0, 420, 0, 320)
Panel.Position = UDim2.new(0.5,-210,1,300)
Panel.BackgroundColor3 = Color3.fromRGB(0,130,200)
Panel.BorderSizePixel = 0
Panel.Visible = false
Panel.Active = true
Panel.Draggable = true

Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 12)

-- Título
local Title = Instance.new("TextLabel", Panel)
Title.Size = UDim2.new(1,0,0,40)
Title.Position = UDim2.new(0,0,0,10)
Title.BackgroundTransparency = 1
Title.Text = "ADMIN PANEL"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 28

--=====================================================
-- INPUT USUARIO
--=====================================================
local UserBox = Instance.new("TextBox", Panel)
UserBox.PlaceholderText = "Pon tu usuario aquí"
UserBox.Text = ""
UserBox.Size = UDim2.new(0.8,0,0,40)
UserBox.Position = UDim2.new(0.1,0,0.28,0)
UserBox.BackgroundColor3 = Color3.fromRGB(0,160,240)
UserBox.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", UserBox).CornerRadius = UDim.new(0,10)

--=====================================================
-- INPUT CONTRASEÑA
--=====================================================
local PassBox = Instance.new("TextBox", Panel)
PassBox.PlaceholderText = "Pon tu contraseña aquí"
PassBox.Text = ""
PassBox.Size = UDim2.new(0.8,0,0,40)
PassBox.Position = UDim2.new(0.1,0,0.45,0)
PassBox.BackgroundColor3 = Color3.fromRGB(0,160,240)
PassBox.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", PassBox).CornerRadius = UDim.new(0,10)

--=====================================================
-- BOTÓN ENTRAR
--=====================================================
local EnterButton = Instance.new("TextButton", Panel)
EnterButton.Size = UDim2.new(0.6,0,0,40)
EnterButton.Position = UDim2.new(0.2,0,0.65,0)
EnterButton.BackgroundColor3 = Color3.fromRGB(0,190,255)
EnterButton.Text = "ENTRAR"
EnterButton.TextColor3 = Color3.new(1,1,1)
EnterButton.Font = Enum.Font.GothamBold
EnterButton.TextSize = 20
Instance.new("UICorner", EnterButton).CornerRadius = UDim.new(0,10)

-- Status
local Status = Instance.new("TextLabel", Panel)
Status.Size = UDim2.new(1,0,0,40)
Status.Position = UDim2.new(0,0,0.8,0)
Status.BackgroundTransparency = 1
Status.TextColor3 = Color3.new(1,1,1)
Status.Font = Enum.Font.GothamBold
Status.TextSize = 18
Status.Text = ""

--=====================================================
-- FUNCIÓN LOGIN
--=====================================================
local function CheckLogin()
    if UserBox.Text == "ASTRA" and PassBox.Text == "FREE" then
        Status.Text = "✔ Acceso Correcto"
        Status.TextColor3 = Color3.fromRGB(0,255,0)
    else
        Status.Text = "❌ Usuario o Contraseña Incorrectos"
        Status.TextColor3 = Color3.fromRGB(255,0,0)
    end
end

EnterButton.MouseButton1Click:Connect(CheckLogin)

--=====================================================
-- ANIMACIÓN ABRIR / CERRAR con L
--=====================================================

local open = false

local function TogglePanel()
    open = not open

    if open then
        Panel.Visible = true
        Panel:TweenPosition(UDim2.new(0.5,-210,0.3,0), "Out", "Quad", 0.5, true)
    else
        Panel:TweenPosition(UDim2.new(0.5,-210,1,300), "Out", "Quad", 0.5, true)
        task.wait(0.5)
        Panel.Visible = false
    end
end

UIS.InputBegan:Connect(function(key)
    if key.KeyCode == Enum.KeyCode.L then
        TogglePanel()
    end
end)

--=====================================================
-- FPS EN VIVO
--=====================================================

RunService.RenderStepped:Connect(function(dt)
    local fps = math.floor(1/dt)
    TopText.Text = "ADMIN PANEL ACTIVADO | FPS: "..fps.." | User: "..User.Name
end)
