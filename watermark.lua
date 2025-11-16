-- ASTRA.GG ADMIN (Luau)
-- Instrucciones: crea 3 scripts con estos contenidos en tu juego de Roblox.
-- 1) ServerScript: ServerScriptService -> AstraAdmin_Server
-- 2) Client GUI: StarterGui -> ScreenGui con LocalScript llamado AstraAdmin_Client
-- 3) Client reporter: StarterPlayerScripts -> AstraAdmin_ReportPlatform (LocalScript)

----------------------------------------------------------------
-- 1) Server: AstraAdmin_Server (ServerScriptService)
----------------------------------------------------------------
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Remotes
local remotes = ReplicatedStorage:FindFirstChild("AstraAdmin_Remotes")
if not remotes then
    remotes = Instance.new("Folder")
    remotes.Name = "AstraAdmin_Remotes"
    remotes.Parent = ReplicatedStorage
end

local applyNeonRemote = remotes:FindFirstChild("ApplyNeon") or Instance.new("RemoteEvent", remotes)
applyNeonRemote.Name = "ApplyNeon"

local reportPlatformRemote = remotes:FindFirstChild("ReportPlatform") or Instance.new("RemoteEvent", remotes)
reportPlatformRemote.Name = "ReportPlatform"

-- Server-side handler to change a player's character parts to Neon material
local function applyNeonToPlayer(targetPlayer, color3)
    if not targetPlayer or not targetPlayer.Character then return end
    local char = targetPlayer.Character
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Material = Enum.Material.Neon
            -- keep transparency/size; set color
            pcall(function() part.Color = color3 end)
        elseif part:IsA("Accessory") then
            -- accessory handle
            local handle = part:FindFirstChild("Handle")
            if handle and handle:IsA("BasePart") then
                handle.Material = Enum.Material.Neon
                pcall(function() handle.Color = color3 end)
            end
        end
    end
end

applyNeonRemote.OnServerEvent:Connect(function(player, targetsUserIds, mode)
    -- Security: only allow if player has a special attribute or is in a list of admins
    -- You can customize this list. For demo, the creator (game owner) and player with DeveloperConsole enabled are allowed.
    local allowed = false
    -- Example admin list (IDs) - replace with real admin IDs
    local ADMINS = {
        [12345678] = true, -- <-- reemplaza por tu UserId si quieres control
    }
    if ADMINS[player.UserId] or player.UserId == game.CreatorId then
        allowed = true
    end
    if not allowed then
        warn("AstraAdmin: "..player.Name.." intentó usar el panel sin permisos")
        return
    end

    -- Apply neon to each target id
    local color = Color3.fromRGB(0, 255, 255) -- default cyan
    if type(mode) == "table" and mode.color then
        color = mode.color
    end

    for _, id in ipairs(targetsUserIds) do
        local p = Players:GetPlayerByUserId(id)
        if p then
            applyNeonToPlayer(p, color)
        end
    end
end)

-- store reported platform attribute
reportPlatformRemote.OnServerEvent:Connect(function(player, platformString)
    if typeof(platformString) == "string" then
        player:SetAttribute("AstraPlatform", platformString)
    end
end)

-- Optional: cleanup attributes on leaving
Players.PlayerRemoving:Connect(function(player)
    -- nothing special for now
end)

print("AstraAdmin Server running")

----------------------------------------------------------------
-- 2) Client GUI: AstraAdmin_Client (LocalScript inside a ScreenGui in StarterGui)
----------------------------------------------------------------
-- Create a ScreenGui programmatically (if you prefer, you can insert a ScreenGui and paste the LocalScript inside)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- Remotes
local remotes = ReplicatedStorage:WaitForChild("AstraAdmin_Remotes")
local applyNeonRemote = remotes:WaitForChild("ApplyNeon")

-- GUI root
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AstraAdminGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main frame (neon square)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 420, 0, 300)
frame.Position = UDim2.new(0.5, -210, 0.5, -150)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundTransparency = 0.15
frame.BackgroundColor3 = Color3.fromRGB(10,10,12)
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- Animated neon border using UIStroke
local stroke = Instance.new("UIStroke")
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.LineJoinMode = Enum.LineJoinMode.Round
stroke.Thickness = 3
stroke.Parent = frame

-- Tween neon hue
local hue = 0
spawn(function()
    while frame.Parent do
        hue = (hue + 5) % 360
        local rgb = Color3.fromHSV(hue/360, 0.9, 1)
        local tween = TweenService:Create(stroke, TweenInfo.new(1.2), {Color = rgb})
        tween:Play()
        wait(0.066)
    end
end)

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -16, 0, 34)
title.Position = UDim2.new(0, 8, 0, 8)
title.BackgroundTransparency = 1
title.Text = "ASTRA.GG ADMIN"
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.fromRGB(230,230,255)
title.Parent = frame

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -36, 0, 8)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.Gotham
closeBtn.TextSize = 18
closeBtn.BackgroundTransparency = 0.4
closeBtn.Parent = frame
closeBtn.MouseButton1Click:Connect(function()
    screenGui.Enabled = not screenGui.Enabled
end)

-- Tabs: USER and ONLINE
local tabHolder = Instance.new("Frame")
tabHolder.Size = UDim2.new(1, -16, 0, 36)
tabHolder.Position = UDim2.new(0, 8, 0, 48)
tabHolder.BackgroundTransparency = 1
tabHolder.Parent = frame

local userTabBtn = Instance.new("TextButton")
userTabBtn.Size = UDim2.new(0.5, -6, 1, 0)
userTabBtn.Position = UDim2.new(0, 0, 0, 0)
userTabBtn.Text = "USER"
userTabBtn.Font = Enum.Font.Gotham
userTabBtn.TextSize = 18
userTabBtn.Parent = tabHolder

local onlineTabBtn = Instance.new("TextButton")
onlineTabBtn.Size = UDim2.new(0.5, -6, 1, 0)
onlineTabBtn.Position = UDim2.new(0.5, 6, 0, 0)
onlineTabBtn.Text = "ONLINE"
onlineTabBtn.Font = Enum.Font.Gotham
onlineTabBtn.TextSize = 18
onlineTabBtn.Parent = tabHolder

-- Pages container
local pages = Instance.new("Frame")
pages.Size = UDim2.new(1, -16, 1, -96)
pages.Position = UDim2.new(0,8,0,92)
pages.BackgroundTransparency = 1
pages.Parent = frame

local userPage = Instance.new("Frame")
userPage.Size = UDim2.new(1,0,1,0)
userPage.BackgroundTransparency = 1
userPage.Parent = pages

local onlinePage = Instance.new("Frame")
onlinePage.Size = UDim2.new(1,0,1,0)
onlinePage.BackgroundTransparency = 1
onlinePage.Visible = false
onlinePage.Parent = pages

userTabBtn.MouseButton1Click:Connect(function()
    userPage.Visible = true
    onlinePage.Visible = false
end)
onlineTabBtn.MouseButton1Click:Connect(function()
    userPage.Visible = false
    onlinePage.Visible = true
end)

-- USER page contents: selection and NEON options
local targetLabel = Instance.new("TextLabel")
targetLabel.Size = UDim2.new(1,0,0,24)
targetLabel.Position = UDim2.new(0,0,0,0)
targetLabel.BackgroundTransparency = 1
targetLabel.Text = "Selecciona usuario (click en la lista de ONLINE)"
targetLabel.TextXAlignment = Enum.TextXAlignment.Left
targetLabel.TextColor3 = Color3.fromRGB(220,220,255)
targetLabel.Parent = userPage

local neonBtn = Instance.new("TextButton")
neonBtn.Size = UDim2.new(0,0,0,36)
neonBtn.Position = UDim2.new(0,0,0,36)
neonBtn.Text = "Aplicar Modo NEON (Cyan)"
neonBtn.TextSize = 16
neonBtn.AutomaticSize = Enum.AutomaticSize.X
neonBtn.Parent = userPage

local viewNameBtn = Instance.new("TextButton")
viewNameBtn.Size = UDim2.new(0,160,0,36)
viewNameBtn.Position = UDim2.new(0,0,0,80)
viewNameBtn.Text = "Ver Nombre"
viewNameBtn.Parent = userPage

local selectedTarget = nil

viewNameBtn.MouseButton1Click:Connect(function()
    if selectedTarget then
        local p = Players:GetPlayerByUserId(selectedTarget)
        if p then
            local name = p.Name
            local display = "Name: "..name.." (UserId: "..tostring(p.UserId)..")"
            -- show a temporary notice
            local notice = Instance.new("TextLabel")
            notice.Size = UDim2.new(1,0,0,28)
            notice.Position = UDim2.new(0,0,0,124)
            notice.BackgroundTransparency = 0.4
            notice.Text = display
            notice.TextColor3 = Color3.fromRGB(230,230,255)
            notice.Parent = userPage
            delay(3, function() notice:Destroy() end)
        end
    else
        local notice = Instance.new("TextLabel")
        notice.Size = UDim2.new(1,0,0,28)
        notice.Position = UDim2.new(0,0,0,124)
        notice.BackgroundTransparency = 0.4
        notice.Text = "No hay usuario seleccionado"
        notice.TextColor3 = Color3.fromRGB(230,230,255)
        notice.Parent = userPage
        delay(2, function() notice:Destroy() end)
    end
end)

neonBtn.MouseButton1Click:Connect(function()
    if not selectedTarget then
        -- feedback
        local n = Instance.new("TextLabel")
        n.Size = UDim2.new(1,0,0,24)
        n.Position = UDim2.new(0,0,0,124)
        n.Text = "Selecciona primero un usuario desde ONLINE"
        n.BackgroundTransparency = 0.6
        n.TextColor3 = Color3.fromRGB(240,240,255)
        n.Parent = userPage
        delay(2, function() n:Destroy() end)
        return
    end

    -- Ask server to apply neon. send as list of ids
    applyNeonRemote:FireServer({selectedTarget}, {color = Color3.fromRGB(0,255,255)})
end)

-- ONLINE page contents: scrolling list
local onlineList = Instance.new("ScrollingFrame")
onlineList.Size = UDim2.new(1,0,1,0)
onlineList.CanvasSize = UDim2.new(0,0)
onlineList.ScrollBarThickness = 8
onlineList.BackgroundTransparency = 1
onlineList.Parent = onlinePage

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Padding = UDim.new(0,6)
uiListLayout.Parent = onlineList

local function createOnlineEntry(pl)
    local entry = Instance.new("Frame")
    entry.Size = UDim2.new(1, -12, 0, 36)
    entry.BackgroundTransparency = 0.4
    entry.BorderSizePixel = 0
    entry.Parent = onlineList

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(0.6,0,1,0)
    nameLbl.Position = UDim2.new(0,8,0,0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.Text = pl.Name
    nameLbl.TextColor3 = Color3.fromRGB(230,230,255)
    nameLbl.Parent = entry

    local platformLbl = Instance.new("TextLabel")
    platformLbl.Size = UDim2.new(0.3,0,1,0)
    platformLbl.Position = UDim2.new(0.62,0,0,0)
    platformLbl.BackgroundTransparency = 1
    platformLbl.Text = pl:GetAttribute("AstraPlatform") or "Desconocido"
    platformLbl.TextColor3 = Color3.fromRGB(190,190,255)
    platformLbl.Parent = entry

    local selectBtn = Instance.new("TextButton")
    selectBtn.Size = UDim2.new(0,60,0,28)
    selectBtn.Position = UDim2.new(1, -72, 0, 4)
    selectBtn.Text = "Seleccionar"
    selectBtn.Parent = entry
    selectBtn.MouseButton1Click:Connect(function()
        selectedTarget = pl.UserId
        -- visual feedback
        for _, c in ipairs(onlineList:GetChildren()) do
            if c:IsA("Frame") then
                c.BackgroundTransparency = 0.6
            end
        end
        entry.BackgroundTransparency = 0.2
        userPage.Visible = true
        onlinePage.Visible = false
    end)

    return entry
end

-- Update online list
local function refreshOnline()
    for _, child in ipairs(onlineList:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    for _, pl in ipairs(Players:GetPlayers()) do
        local e = createOnlineEntry(pl)
    end
    onlineList.CanvasSize = UDim2.new(0,0,0, uiListLayout.AbsoluteContentSize.Y + 12)
end

Players.PlayerAdded:Connect(function(pl)
    -- small delay to wait attributes
    pl:GetAttributeChangedSignal("AstraPlatform"):Connect(function()
        refreshOnline()
    end)
    refreshOnline()
end)
Players.PlayerRemoving:Connect(function()
    refreshOnline()
end)

-- initial
refreshOnline()

print("AstraAdmin GUI loaded")

----------------------------------------------------------------
-- 3) Client Reporter: AstraAdmin_ReportPlatform (LocalScript in StarterPlayerScripts)
----------------------------------------------------------------
-- This script informs the server of the client's platform so the ONLINE list can display it.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local remotes = ReplicatedStorage:WaitForChild("AstraAdmin_Remotes")
local reportPlatform = remotes:WaitForChild("ReportPlatform")

local function detectPlatform()
    -- Try to detect platform in a readable form
    local plat = "PC"
    local platformEnum
    pcall(function()
        platformEnum = UserInputService:GetPlatform()
    end)
    if platformEnum then
        plat = tostring(platformEnum)
    else
        if UserInputService.TouchEnabled then
            plat = "Mobile"
        else
            plat = "PC"
        end
    end
    return plat
end

-- report once at join and when certain signals change
local function report()
    local p = detectPlatform()
    reportPlatform:FireServer(p)
end

report()
-- If the platform can change (rare), re-report occasionally
spawn(function()
    while true do
        wait(10)
        report()
    end
end)

-- END OF SCRIPTS

-- Nota: para uso real, ajusta la lista ADMINS en el servidor y añade checks de seguridad/logs.
-- Puedes mejorar: selector de color, toggle para deshacer neon (revertir materiales), permisos por rango, etc.
