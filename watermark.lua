--=====================================================
-- ADMIN LOGIN PANEL
--=====================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local User = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui", User.PlayerGui)
ScreenGui.Name = "AdminPanelGUI"
ScreenGui.ResetOnSpawn = false

---------------------------------------------------------
-- PANEL PRINCIPAL (LOGIN)
---------------------------------------------------------

local LoginPanel = Instance.new("Frame", ScreenGui)
LoginPanel.Size = UDim2.new(0, 420, 0, 320)
LoginPanel.Position = UDim2.new(0.5,-210,1,300)
LoginPanel.BackgroundColor3 = Color3.fromRGB(0,130,200)
LoginPanel.BorderSizePixel = 0
LoginPanel.Visible = false
LoginPanel.Active = true
LoginPanel.Draggable = true
Instance.new("UICorner", LoginPanel).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", LoginPanel)
Title.Size = UDim2.new(1,0,0,40)
Title.Position = UDim2.new(0,0,0,10)
Title.BackgroundTransparency = 1
Title.Text = "ADMIN PANEL"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 28

local UserBox = Instance.new("TextBox", LoginPanel)
UserBox.PlaceholderText = "Pon tu usuario aquí"
UserBox.Text = ""
UserBox.Size = UDim2.new(0.8,0,0,40)
UserBox.Position = UDim2.new(0.1,0,0.28,0)
UserBox.BackgroundColor3 = Color3.fromRGB(0,160,240)
UserBox.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", UserBox).CornerRadius = UDim.new(0,10)

local PassBox = Instance.new("TextBox", LoginPanel)
PassBox.PlaceholderText = "Pon tu contraseña aquí"
PassBox.Text = ""
PassBox.Size = UDim2.new(0.8,0,0,40)
PassBox.Position = UDim2.new(0.1,0,0.45,0)
PassBox.BackgroundColor3 = Color3.fromRGB(0,160,240)
PassBox.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", PassBox).CornerRadius = UDim.new(0,10)

local EnterButton = Instance.new("TextButton", LoginPanel)
EnterButton.Size = UDim2.new(0.6,0,0,40)
EnterButton.Position = UDim2.new(0.2,0,0.65,0)
EnterButton.BackgroundColor3 = Color3.fromRGB(0,190,255)
EnterButton.Text = "ENTRAR"
EnterButton.TextColor3 = Color3.new(1,1,1)
EnterButton.Font = Enum.Font.GothamBold
EnterButton.TextSize = 20
Instance.new("UICorner", EnterButton).CornerRadius = UDim.new(0,10)

local Status = Instance.new("TextLabel", LoginPanel)
Status.Size = UDim2.new(1,0,0,40)
Status.Position = UDim2.new(0,0,0.8,0)
Status.BackgroundTransparency = 1
Status.TextColor3 = Color3.new(1,1,1)
Status.Font = Enum.Font.GothamBold
Status.TextSize = 18
Status.Text = ""

---------------------------------------------------------
-- PANEL SECUNDARIO (ADMIN COMPLETO)
---------------------------------------------------------

local MainPanel = Instance.new("Frame", ScreenGui)
MainPanel.Size = UDim2.new(0, 600, 0, 400)
MainPanel.Position = UDim2.new(0.5,-300,0.5,-200)
MainPanel.BackgroundColor3 = Color3.fromRGB(0,140,220)
MainPanel.BorderSizePixel = 0
MainPanel.Visible = false
MainPanel.Active = true
MainPanel.Draggable = true
Instance.new("UICorner", MainPanel).CornerRadius = UDim.new(0, 14)

-- Botones de secciones
local Tabs = Instance.new("Frame", MainPanel)
Tabs.Size = UDim2.new(1,0,0,40)
Tabs.BackgroundColor3 = Color3.fromRGB(0,90,150)
Instance.new("UICorner", Tabs).CornerRadius = UDim.new(0,12)

local function CreateTab(name, pos)
    local b = Instance.new("TextButton", Tabs)
    b.Size = UDim2.new(0,150,1,0)
    b.Position = UDim2.new(0, pos, 0, 0)
    b.Text = name
    b.BackgroundTransparency = 1
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 20
    return b
end

local UserTab = CreateTab("USER", 10)
local OnlineTab = CreateTab("ONLINE", 160)
local RageTab = CreateTab("RAGE", 310)

-- Contenedores
local UserFrame = Instance.new("Frame", MainPanel)
UserFrame.Size = UDim2.new(1,0,1,-40)
UserFrame.Position = UDim2.new(0,0,0,40)
UserFrame.BackgroundTransparency = 1

local OnlineFrame = UserFrame:Clone()
OnlineFrame.Parent = MainPanel
OnlineFrame.Visible = false

local RageFrame = UserFrame:Clone()
RageFrame.Parent = MainPanel
RageFrame.Visible = false

---------------------------------------------------------
-- BOTONES USER
---------------------------------------------------------

local function CreateUserButton(text, pos)
    local b = Instance.new("TextButton", UserFrame)
    b.Size = UDim2.new(0,200,0,50)
    b.Position = UDim2.new(0, 30, 0, pos)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(0,170,255)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 20
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,12)
    return b
end

local BtnName = CreateUserButton("ACTIVAR NAME", 20)
local BtnBox = CreateUserButton("ACTIVAR BOX", 90)
local BtnWall = CreateUserButton("ATRAVESAR PAREDES", 160)
local BtnFly = CreateUserButton("FLY", 230)

---------------------------------------------------------
-- ONLINE LISTA
---------------------------------------------------------

local OnlineList = Instance.new("TextLabel", OnlineFrame)
OnlineList.Size = UDim2.new(1,-20,1,-20)
OnlineList.Position = UDim2.new(0,10,0,10)
OnlineList.BackgroundTransparency = 1
OnlineList.TextColor3 = Color3.new(1,1,1)
OnlineList.Font = Enum.Font.Gotham
OnlineList.TextSize = 20
OnlineList.TextXAlignment = Enum.TextXAlignment.Left
OnlineList.TextYAlignment = Enum.TextYAlignment.Top
OnlineList.Text = "Cargando jugadores..."

local function RefreshPlayers()
    local t = "JUGADORES ONLINE:\n\n"
    for _,plr in pairs(Players:GetPlayers()) do
        t = t .. "• " .. plr.Name .. "\n"
    end
    OnlineList.Text = t
end

Players.PlayerAdded:Connect(RefreshPlayers)
Players.PlayerRemoving:Connect(RefreshPlayers)
RefreshPlayers()

---------------------------------------------------------
-- CAMBIO DE TABS
---------------------------------------------------------

UserTab.MouseButton1Click:Connect(function()
    UserFrame.Visible = true
    OnlineFrame.Visible = false
    RageFrame.Visible = false
end)

OnlineTab.MouseButton1Click:Connect(function()
    UserFrame.Visible = false
    OnlineFrame.Visible = true
    RageFrame.Visible = false
end)

RageTab.MouseButton1Click:Connect(function()
    UserFrame.Visible = false
    OnlineFrame.Visible = false
    RageFrame.Visible = true
end)

---------------------------------------------------------
-- LOGIN VALIDACIÓN
---------------------------------------------------------

local function CheckLogin()
    if UserBox.Text == "ASTRA" and PassBox.Text == "FREE" then
        Status.Text = "✔ Acceso Correcto"
        Status.TextColor3 = Color3.fromRGB(0,255,0)

        task.wait(1)
        LoginPanel.Visible = false
        MainPanel.Visible = true
    else
        Status.Text = "❌ Usuario o Contraseña Incorrectos"
        Status.TextColor3 = Color3.fromRGB(255,0,0)
    end
end

EnterButton.MouseButton1Click:Connect(CheckLogin)

---------------------------------------------------------
-- ANIMACIÓN LOGIN (L)
---------------------------------------------------------

local open = false
UIS.InputBegan:Connect(function(key)
    if key.KeyCode == Enum.KeyCode.L then
        open = not open
        if open then
            LoginPanel.Visible = true
            LoginPanel:TweenPosition(UDim2.new(0.5,-210,0.3,0), "Out", "Quad", 0.5, true)
        else
            LoginPanel:TweenPosition(UDim2.new(0.5,-210,1,300), "Out", "Quad", 0.5, true)
            task.wait(0.5)
            LoginPanel.Visible = false
        end
    end
end)
