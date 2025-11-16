-- LocalScript (StarterGui)

local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-------------------------------------------------
-- CREAR GUI SI NO EXISTE
-------------------------------------------------

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AdminPanelGUI"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

-------------------------------------------------
-- PANEL PRINCIPAL (LOGIN)
-------------------------------------------------

local Panel = Instance.new("Frame")
Panel.Name = "LoginPanel"
Panel.Size = UDim2.new(0, 400, 0, 320)
Panel.Position = UDim2.new(0.5, -200, 0.5, -160)
Panel.BackgroundColor3 = Color3.fromRGB(70, 160, 255)
Panel.Visible = false
Panel.Parent = ScreenGui
Panel.BorderSizePixel = 0
Panel.BackgroundTransparency = 0.1
Panel.ClipsDescendants = true
Panel.ZIndex = 3

local UICorner = Instance.new("UICorner", Panel)
UICorner.CornerRadius = UDim.new(0, 20)

-------------------------------------------------
-- TÍTULO
-------------------------------------------------

local Title = Instance.new("TextLabel", Panel)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "ADMIN PANEL"
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true
Title.TextColor3 = Color3.fromRGB(255,255,255)

-------------------------------------------------
-- USER BOX
-------------------------------------------------

local UserBox = Instance.new("TextBox", Panel)
UserBox.Size = UDim2.new(0.8, 0, 0, 45)
UserBox.Position = UDim2.new(0.1, 0, 0.3, 0)
UserBox.PlaceholderText = "Pon tu usuario"
UserBox.Font = Enum.Font.Gotham
UserBox.TextScaled = true
UserBox.BackgroundColor3 = Color3.fromRGB(35, 130, 255)
UserBox.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", UserBox).CornerRadius = UDim.new(0, 12)

local PassBox = Instance.new("TextBox", Panel)
PassBox.Size = UDim2.new(0.8, 0, 0, 45)
PassBox.Position = UDim2.new(0.1, 0, 0.47, 0)
PassBox.PlaceholderText = "Pon tu contraseña"
PassBox.Font = Enum.Font.Gotham
PassBox.TextScaled = true
PassBox.BackgroundColor3 = Color3.fromRGB(35, 130, 255)
PassBox.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", PassBox).CornerRadius = UDim.new(0, 12)

-------------------------------------------------
-- BOTÓN ENTRAR
-------------------------------------------------

local Enter = Instance.new("TextButton", Panel)
Enter.Size = UDim2.new(0.5, 0, 0, 45)
Enter.Position = UDim2.new(0.25, 0, 0.67, 0)
Enter.Text = "ENTRAR"
Enter.BackgroundColor3 = Color3.fromRGB(0, 90, 255)
Enter.TextColor3 = Color3.fromRGB(255,255,255)
Enter.Font = Enum.Font.GothamBold
Enter.TextScaled = true
Instance.new("UICorner", Enter).CornerRadius = UDim.new(0, 12)

-------------------------------------------------
-- ANIMACIÓN DE APERTURA
-------------------------------------------------

local openTween = TweenService:Create(Panel, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
    Size = UDim2.new(0, 400, 0, 320)
})

local closeTween = TweenService:Create(Panel, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
    Size = UDim2.new(0, 0, 0, 0)
})

local panelOpen = false

local function TogglePanel()
    if not panelOpen then
        Panel.Visible = true
        openTween:Play()
        panelOpen = true
    else
        closeTween:Play()
        task.wait(0.35)
        Panel.Visible = false
        panelOpen = false
    end
end

-------------------------------------------------
-- TECLA L PARA ABRIR / CERRAR
-------------------------------------------------

UIS.InputBegan:Connect(function(key, typing)
    if typing then return end
    if key.KeyCode == Enum.KeyCode.L then
        TogglePanel()
    end
end)

-------------------------------------------------
-- VALIDADOR LOGIN
-------------------------------------------------

Enter.MouseButton1Click:Connect(function()
    if UserBox.Text == "ASTRA" and PassBox.Text == "FREE" then
        warn("LOGIN CORRECTO")
        -- AQUÍ CARGAREMOS EL PANEL GRANDE LUEGO
    else
        UserBox.Text = ""
        PassBox.Text = ""
        UserBox.PlaceholderText = "Incorrecto!"
        PassBox.PlaceholderText = "Incorrecto!"
    end
end)
