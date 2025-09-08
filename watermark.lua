--// Foxxy's Leaks — Admin/Debug UI (ESTILO DURO)
--// Login (scanline+glow) -> Sidebar con 5 menús: Movimiento, Aimbot, Visual, Otros, Créditos
--// Sliders "duros", aimbot con FOV+color+smooth y tecla configurable, tecla L para ocultar/mostrar
--// Pie: "programador: by pedri.exe" + Usuario (DisplayName @Username)

-------------------------
--    CONFIGURACIÓN    --
-------------------------
local ACCESS_KEY = "HJGL-FKSS"

-- Restringe a tus lugares/usuarios (opcional). Déjalo vacío para no restringir.
local ALLOWED_PLACE_IDS = { }
local ALLOWED_USER_IDS  = { }

-- Velocidad (WalkSpeed)
local SPEED_MIN, SPEED_MAX, SPEED_DEFAULT = 8, 120, 16

-- Salto (multiplicador via slider)
local JUMP_MULT_MIN, JUMP_MULT_MAX, JUMP_MULT_DEFAULT = 0.9, 1.8, 1.25
local JUMP_MAX_ABS_ADD = 32

-- Noclip anti-rebote
local NOCLIP_CORRECTION_FACTOR = 0.88

-- Fly
local FLY_SPEED_MIN, FLY_SPEED_MAX, FLY_SPEED_DEFAULT = 16, 240, 64
local FLY_TILT_STIFFNESS = 8

-- Freecam (modo foto)
local FC_SPEED_DEFAULT = 40
local FC_SENS = Vector2.new(0.003, 0.003)

-- Aimbot
local AIM_FOV_MIN, AIM_FOV_MAX, AIM_FOV_DEFAULT = 30, 500, 200
local AIM_SMOOTH_MIN, AIM_SMOOTH_MAX, AIM_SMOOTH_DEFAULT = 0.0, 0.6, 0.22 -- ahora ajustable

-- Discord y logo
local DISCORD_LINK = "https://discord.gg/xQbpCEgz9E"
local LOGO_URL = "https://cdn.discordapp.com/attachments/1392752518148395119/1413517337851592805/c851ab41-8a9e-4458-8235-cf4479d3a0ce.png?ex=68be325b&is=68bce0db&hm=2b8ce5b8398729a2f08ecf597497755d416755ae837ba8e4ee2da72e915f9edc&"
local LOGO_ASSET_ID = "rbxassetid://0" -- si subes el decal, cambia por su assetId

-------------------------
--      SERVICIOS      --
-------------------------
local Players   = game:GetService("Players")
local UIS       = game:GetService("UserInputService")
local TS        = game:GetService("TweenService")
local RS        = game:GetService("RunService")
local SG        = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local Lighting  = game:GetService("Lighting")

local lp = Players.LocalPlayer

-------------------------
--     AUTORIZACIÓN    --
-------------------------
local function isAllowedPlace()
    if #ALLOWED_PLACE_IDS == 0 then return true end
    for _,id in ipairs(ALLOWED_PLACE_IDS) do if id == game.PlaceId then return true end end
    return false
end
local function isAllowedUser()
    if #ALLOWED_USER_IDS == 0 then return true end
    for _,id in ipairs(ALLOWED_USER_IDS) do if id == lp.UserId then return true end end
    return false
end
if not isAllowedPlace() or not isAllowedUser() then
    warn("[FoxxysLeaks] No autorizado en este lugar/usuario. Configura ALLOWED_* en el script.")
    return
end

-------------------------
--     UTILIDADES UI   --
-------------------------
local function mk(instance, props, parent)
    local o = Instance.new(instance)
    for k,v in pairs(props or {}) do o[k]=v end
    if parent then o.Parent=parent end
    return o
end

-- Slider “duro”: barra + relleno + knob rectangular
local function makeHardSlider(parent, posY, minV, maxV, defaultV, color, onChange)
    local cont = mk("Frame", {Size=UDim2.new(1,-24,0,24), Position=UDim2.new(0,12,0,posY), BackgroundTransparency=1, ZIndex=5}, parent)
    local bar  = mk("Frame", {Size=UDim2.new(1,0,0,10), Position=UDim2.new(0,0,0,7), BackgroundColor3=Color3.fromRGB(35,35,50), BorderSizePixel=0}, cont)
    local stroke=mk("UIStroke",{Thickness=1.5, Transparency=0.35, Color=Color3.fromRGB(80,80,120)}, bar)
    local fill = mk("Frame", {Size=UDim2.new(0,0,1,0), BackgroundColor3=color or Color3.fromRGB(90,160,255), BorderSizePixel=0}, bar)
    local knob = mk("Frame", {Size=UDim2.fromOffset(12,16), BackgroundColor3=Color3.fromRGB(230,230,255), BorderSizePixel=0}, cont)
    mk("UIStroke",{Thickness=1.2, Transparency=0.2, Color=Color3.fromRGB(120,120,160)}, knob)

    local value = defaultV
    local dragging = false

    local function setByRel(rel)
        rel = math.clamp(rel,0,1)
        local v = minV + rel*(maxV-minV)
        value = v
        fill.Size = UDim2.new(rel,0,1,0)
        knob.Position = UDim2.new(rel,-6,0,4)
        if onChange then onChange(v) end
    end

    local function relFromAbs(x)
        return math.clamp((x - bar.AbsolutePosition.X)/bar.AbsoluteSize.X, 0, 1)
    end

    bar.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then setByRel(relFromAbs(inp.Position.X)); dragging=true end
    end)
    knob.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
    end)
    UIS.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then
            setByRel(relFromAbs(inp.Position.X))
        end
    end)

    -- inicio
    if defaultV then
        local rel = (defaultV - minV)/(maxV-minV)
        setByRel(rel)
    else
        setByRel(0)
    end

    return {
        get=function() return value end,
        set=function(v) setByRel((v-minV)/(maxV-minV)) end,
        setColor=function(c) fill.BackgroundColor3=c end
    }
end

local function makeToggle(parent, text, posY, onClick)
    local btn = mk("TextButton",{
        Size=UDim2.new(1,-24,0,32), Position=UDim2.new(0,12,0,posY),
        BackgroundColor3=Color3.fromRGB(28,28,40), BorderSizePixel=0,
        Font=Enum.Font.GothamBold, TextSize=14, TextColor3=Color3.new(1,1,1), Text=text, ZIndex=5
    }, parent)
    mk("UIStroke",{Thickness=1.5, Transparency=0.45, Color=Color3.fromRGB(70,70,110)}, btn)
    btn.MouseButton1Click:Connect(function() if onClick then onClick(btn) end end)
    return btn
end

local function setBtnState(btn, label, state)
    btn.Text = label .. (state and "ON" or "OFF")
    btn.BackgroundColor3 = state and Color3.fromRGB(45,130,90) or Color3.fromRGB(120,50,50)
end

-------------------------
--        GUI BASE     --
-------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "FoxyLeaksUI"
gui.ResetOnSpawn = false
pcall(function() gui.Parent = game.CoreGui end)
if not gui.Parent then gui.Parent = lp:WaitForChild("PlayerGui") end

-------------------------
--      LOGIN NUEVO    --
-------------------------
-- overlay oscuro + “scanlines” y glow en el panel
local loginOverlay = mk("Frame",{Size=UDim2.fromScale(1,1), BackgroundColor3=Color3.new(0,0,0), BackgroundTransparency=0.3, ZIndex=50}, gui)
local scan = mk("Frame",{Size=UDim2.fromScale(1,1), BackgroundTransparency=1, ZIndex=51}, loginOverlay)
do
    -- scanlines con gradient animado
    local g = mk("UIGradient",{}, scan)
    g.Color = ColorSequence.new(Color3.fromRGB(0,0,0), Color3.fromRGB(20,20,30))
    g.Rotation = 90
    TS:Create(g, TweenInfo.new(2.8, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, math.huge, true), {Offset=Vector2.new(0,0.2)}):Play()
end

local loginFrame = mk("Frame",{
    Size=UDim2.fromOffset(400, 210), Position=UDim2.new(0.5,-200, 0.35,0),
    BackgroundColor3=Color3.fromRGB(16,16,24), BorderSizePixel=0, ZIndex=60
}, gui)
-- estilo duro: esquinas rectas + doble trazo + glow
mk("UIStroke",{Thickness=2.0, Transparency=0.25, Color=Color3.fromRGB(80,140,255)}, loginFrame)
local glow = mk("Frame",{Size=UDim2.new(1,-20,0,4), Position=UDim2.new(0,10,0,44), BackgroundColor3=Color3.fromRGB(120,70,220), ZIndex=61}, loginFrame)
mk("UIGradient",{Color=ColorSequence.new(Color3.fromRGB(80,160,255), Color3.fromRGB(200,110,255))}, glow)

-- aparición con scale/alpha
local scl = mk("UIScale",{Scale=0.9}, loginFrame)
TS:Create(scl, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale=1}):Play()

local title = mk("TextLabel",{
    BackgroundTransparency=1, Font=Enum.Font.GothamBlack, TextSize=16,
    TextColor3=Color3.fromRGB(230,230,255), Text="Foxxy's Leaks — Login (estilo duro)",
    Size=UDim2.new(1,-20,0,32), Position=UDim2.new(0,10,0,10), ZIndex=61, TextXAlignment=Enum.TextXAlignment.Left
}, loginFrame)

local keyBox = mk("TextBox",{
    Size=UDim2.new(1,-20,0,38), Position=UDim2.new(0,10,0,74),
    BackgroundColor3=Color3.fromRGB(26,26,36), TextColor3=Color3.new(1,1,1),
    PlaceholderText="Ingresa la key", ClearTextOnFocus=false,
    Font=Enum.Font.Gotham, TextSize=14, ZIndex=61, TextScaled=false
}, loginFrame)
mk("UIStroke",{Thickness=1.6, Transparency=0.35, Color=Color3.fromRGB(70,120,220)}, keyBox)

local loginBtn = mk("TextButton",{
    Size=UDim2.new(1,-20,0,38), Position=UDim2.new(0,10,0,122),
    BackgroundColor3=Color3.fromRGB(45,130,90), TextColor3=Color3.new(1,1,1),
    Font=Enum.Font.GothamBold, TextSize=14, Text="Entrar", ZIndex=61
}, loginFrame)
mk("UIStroke",{Thickness=1.8, Transparency=0.25, Color=Color3.fromRGB(60,130,100)}, loginBtn)

local info = mk("TextLabel",{
    BackgroundTransparency=1, TextColor3=Color3.fromRGB(180,180,200),
    Font=Enum.Font.Gotham, TextSize=12,
    Text="Key requerida para continuar", Size=UDim2.new(1,-20,0,16),
    Position=UDim2.new(0,10,1,-22), ZIndex=61, TextXAlignment=Enum.TextXAlignment.Left
}, loginFrame)

local function toast(txt, dur)
    pcall(function()
        SG:SetCore("SendNotification", {Title="Foxxy's Leaks", Text=txt, Duration=dur or 5})
    end)
end

-- Banner clicable (9s)
local function clickableBanner(message, link, duration)
    duration = duration or 9
    local banner = mk("TextButton",{
        AutoButtonColor=true, Text = message.."  (clic para copiar)",
        Font=Enum.Font.GothamSemibold, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left,
        TextColor3=Color3.fromRGB(235,235,255), Size=UDim2.new(1,-20,0,36),
        Position=UDim2.new(0,10,0,-40), BackgroundColor3=Color3.fromRGB(28,28,40),
        BorderSizePixel=0, ZIndex=100
    }, gui)
    mk("UIStroke",{Thickness=1.2, Transparency=0.4, Color=Color3.fromRGB(70,120,220)}, banner)
    TS:Create(banner, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position=UDim2.new(0,10,0,10)}):Play()
    banner.MouseButton1Click:Connect(function()
        if setclipboard then setclipboard(link) banner.Text = "¡Copiado! "..link end
    end)
    task.delay(duration, function()
        if banner and banner.Parent then
            TS:Create(banner, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position=UDim2.new(0,10,0,-40)}):Play()
            task.delay(0.22, function() if banner then banner:Destroy() end end)
        end
    end)
end

-------------------------
--  CONTENEDOR PRINC.  --
-------------------------
local main = mk("Frame",{Size=UDim2.fromOffset(780, 0), Position=UDim2.new(0.5,-390, 0.18,0),
    BackgroundColor3=Color3.fromRGB(10,10,16), BorderSizePixel=0, Visible=false, ZIndex=5}, gui)
mk("UIStroke",{Thickness=2.2, Transparency=0.25, Color=Color3.fromRGB(80,140,255)}, main)

-- Sidebar (tabs)
local sidebar = mk("Frame",{Size=UDim2.fromOffset(170, 460), Position=UDim2.new(0,0,0,0), BackgroundColor3=Color3.fromRGB(14,14,22), BorderSizePixel=0, ZIndex=6}, main)
mk("UIStroke",{Thickness=2, Transparency=0.3, Color=Color3.fromRGB(60,80,130)}, sidebar)

-- TopBar
local topBar = mk("Frame",{Size=UDim2.new(1,0,0,54), Position=UDim2.new(0,0,0,0),
    BackgroundColor3=Color3.fromRGB(16,16,26), BorderSizePixel=0, ZIndex=7}, main)
local logo = mk("ImageLabel",{BackgroundTransparency=1, Size=UDim2.fromOffset(36,36), Position=UDim2.new(0,10,0.5,-18), ZIndex=8}, topBar)
pcall(function() logo.Image=LOGO_URL end)
local titleMain = mk("TextLabel",{BackgroundTransparency=1, Size=UDim2.new(1,-60,1,0), Position=UDim2.new(0,56,0,0),
    Font=Enum.Font.GothamBlack, TextSize=16, TextColor3=Color3.fromRGB(220,220,255),
    Text="Foxxy's Leaks — [L para ocultar/mostrar]", ZIndex=8, TextXAlignment=Enum.TextXAlignment.Left}, topBar)

-- Pie con usuario
local footer = mk("TextLabel",{BackgroundTransparency=1, Size=UDim2.new(1,-16,0,20), Position=UDim2.new(0,8,1,-22),
    Font=Enum.Font.Gotham, TextSize=12, TextColor3=Color3.fromRGB(160,160,190),
    Text="programador: by pedri.exe  |  Usuario: (cargando...)", ZIndex=7, TextXAlignment=Enum.TextXAlignment.Center}, main)
task.defer(function()
    footer.Text = string.format("programador: by pedri.exe  |  Usuario: %s (@%s)", lp.DisplayName, lp.Name)
end)

-- Área de páginas (derecha)
local pages = mk("Frame",{Size=UDim2.fromOffset(780-170, 460), Position=UDim2.new(0,170,0,0), BackgroundTransparency=1, ZIndex=6}, main)
local pageMove  = mk("Frame",{Size=UDim2.fromScale(1,1), BackgroundTransparency=1, ZIndex=6}, pages)
local pageAimb  = mk("Frame",{Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Visible=false, ZIndex=6}, pages)
local pageVisual= mk("Frame",{Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Visible=false, ZIndex=6}, pages)
local pageOtros = mk("Frame",{Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Visible=false, ZIndex=6}, pages)
local pageCred  = mk("Frame",{Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Visible=false, ZIndex=6}, pages)

-- Botones de sidebar
local function makeTab(name, y, targetPage)
    local b = mk("TextButton",{
        Size=UDim2.fromOffset(150,34), Position=UDim2.new(0,10,0,y),
        BackgroundColor3=Color3.fromRGB(28,28,40), BorderSizePixel=0,
        Font=Enum.Font.GothamBold, TextSize=14, TextColor3=Color3.new(1,1,1), Text=name, ZIndex=7
    }, sidebar)
    mk("UIStroke",{Thickness=1.8, Transparency=0.4, Color=Color3.fromRGB(70,70,110)}, b)
    b.MouseButton1Click:Connect(function()
        pageMove.Visible=false; pageAimb.Visible=false; pageVisual.Visible=false; pageOtros.Visible=false; pageCred.Visible=false
        targetPage.Visible=true
    end)
    return b
end
makeTab("Movimiento", 16, pageMove)
makeTab("Aimbot",     56, pageAimb)
makeTab("Visual",     96, pageVisual)
makeTab("Otros",     136, pageOtros)
makeTab("Créditos",  176, pageCred)

-- Fondo estrella simple (líneas duras)
local starLayer = mk("Frame",{BackgroundTransparency=1, Size=UDim2.fromScale(1,1), ZIndex=5}, main)
local function spawnStars(container, count)
    task.wait()
    local w,h = container.AbsoluteSize.X, container.AbsoluteSize.Y
    for _=1,count do
        local s = mk("Frame",{Size=UDim2.fromOffset(2,2), Position=UDim2.fromOffset(math.random(0,w), math.random(0,h)),
            BackgroundColor3=Color3.fromRGB(255,255,255), BorderSizePixel=0, ZIndex=4}, container)
        task.spawn(function()
            while s.Parent do
                local dur = 5 + math.random()
                TS:Create(s, TweenInfo.new(dur, Enum.EasingStyle.Linear), {Position=UDim2.fromOffset(s.Position.X.Offset, h+6)}):Play()
                task.wait(dur)
                s.Position = UDim2.fromOffset(math.random(0,w), -6)
            end
        end)
    end
end
spawnStars(starLayer, 70)

-------------------------
--  MOVIMIENTO (DURO)  --
-------------------------
local currentSpeed = SPEED_DEFAULT
local jumpMult = JUMP_MULT_DEFAULT
local flySpeed = FLY_SPEED_DEFAULT

local speedLabel = mk("TextLabel",{BackgroundTransparency=1, Text="Velocidad: "..SPEED_DEFAULT, TextColor3=Color3.fromRGB(235,235,255),
    Font=Enum.Font.Gotham, TextSize=14, Size=UDim2.new(1,-24,0,18), Position=UDim2.new(0,12,0,8)}, pageMove)
local speedSlider = makeHardSlider(pageMove, 30, SPEED_MIN, SPEED_MAX, SPEED_DEFAULT, Color3.fromRGB(80,180,120), function(v)
    currentSpeed = math.floor(v+0.5)
    speedLabel.Text = "Velocidad: "..currentSpeed
    local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed = currentSpeed end
end)

local jumpLabel = mk("TextLabel",{BackgroundTransparency=1, Text=string.format("Salto: x%.2f", JUMP_MULT_DEFAULT), TextColor3=Color3.fromRGB(235,235,255),
    Font=Enum.Font.Gotham, TextSize=14, Size=UDim2.new(1,-24,0,18), Position=UDim2.new(0,12,0,84)}, pageMove)
local baseRecorded, baseUseJumpPower, baseJumpPower, baseJumpHeight = false,false,0,0
local function recordBaseJump(hum)
    if baseRecorded then return end
    baseUseJumpPower = hum.UseJumpPower
    if baseUseJumpPower then baseJumpPower = hum.JumpPower else baseJumpHeight = hum.JumpHeight end
    baseRecorded = true
end
local function applyJump(hum)
    if not hum then return end
    recordBaseJump(hum)
    if baseUseJumpPower then
        local target = math.min(baseJumpPower + JUMP_MAX_ABS_ADD, baseJumpPower * jumpMult)
        hum.JumpPower = target
    else
        local target = math.min(baseJumpHeight + (JUMP_MAX_ABS_ADD/8), baseJumpHeight * jumpMult)
        hum.JumpHeight = target
    end
    jumpLabel.Text = string.format("Salto: x%.2f", jumpMult)
end
local jumpSlider = makeHardSlider(pageMove, 106, JUMP_MULT_MIN, JUMP_MULT_MAX, JUMP_MULT_DEFAULT, Color3.fromRGB(120,150,230), function(v)
    jumpMult = v
    local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid"); if hum then applyJump(hum) end
end)

local flyLabel = mk("TextLabel",{BackgroundTransparency=1, Text="Velocidad de vuelo: "..FLY_SPEED_DEFAULT, TextColor3=Color3.fromRGB(235,235,255),
    Font=Enum.Font.Gotham, TextSize=14, Size=UDim2.new(1,-24,0,18), Position=UDim2.new(0,12,0,162)}, pageMove)
local flySlider = makeHardSlider(pageMove, 184, FLY_SPEED_MIN, FLY_SPEED_MAX, FLY_SPEED_DEFAULT, Color3.fromRGB(210,150,100), function(v)
    flySpeed = math.floor(v+0.5)
    flyLabel.Text = "Velocidad de vuelo: "..flySpeed
end)

-- Toggles Noclip + Fly
local function getHum()
    local c = lp.Character
    return c and c:FindFirstChildOfClass("Humanoid"), c and c:FindFirstChild("HumanoidRootPart")
end

local noclipOn=false
local hbConn, steppedConn
local originalCollide = {}
local btnNoclip = makeToggle(pageMove, "Atravesar paredes: OFF", 230, function(b)
    noclipOn = not noclipOn
    setBtnState(b, "Atravesar paredes: ", noclipOn)
    local function cacheDefaults(char)
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") and originalCollide[p]==nil then originalCollide[p]=p.CanCollide end
        end
    end
    local function setCharCollision(char, can)
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = can; p.CanTouch = not can end
        end
    end
    if noclipOn then
        local char = lp.Character
        if char then cacheDefaults(char); setCharCollision(char,false) end
        if steppedConn then steppedConn:Disconnect() end
        steppedConn = RS.Stepped:Connect(function()
            if not noclipOn then return end
            local c = lp.Character; if not c then return end
            for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
        end)
        if hbConn then hbConn:Disconnect() end
        hbConn = RS.Heartbeat:Connect(function(dt)
            if not noclipOn then return end
            local hum, hrp = getHum(); if not (hum and hrp) then return end
            local dir = hum.MoveDirection
            if dir.Magnitude>0 then
                local corr = dir.Unit * (hum.WalkSpeed * dt * NOCLIP_CORRECTION_FACTOR)
                hrp.CFrame = hrp.CFrame + Vector3.new(corr.X, 0, corr.Z)
            end
        end)
    else
        if hbConn then hbConn:Disconnect(); hbConn=nil end
        if steppedConn then steppedConn:Disconnect(); steppedConn=nil end
        local char = lp.Character
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and originalCollide[p]~=nil then p.CanCollide=originalCollide[p]; p.CanTouch=true end
            end
        end
    end
end)
setBtnState(btnNoclip, "Atravesar paredes: ", noclipOn)

local flyOn=false
local flyBV, flyBGyro, flyConn
local btnFly = makeToggle(pageMove, "Fly: OFF", 270, function(b)
    local function enableFly()
        if flyOn then return end
        flyOn = true; setBtnState(b, "Fly: ", true)
        local hum, hrp = getHum(); if not (hum and hrp) then return end
        hum.PlatformStand = true
        flyBV = mk("BodyVelocity",{MaxForce=Vector3.new(1e5,1e5,1e5), Velocity=Vector3.zero}, hrp)
        flyBGyro = mk("BodyGyro",{MaxTorque=Vector3.new(1e5,1e5,1e5), P=1e4}, hrp)
        local cam = Workspace.CurrentCamera
        flyConn = RS.RenderStepped:Connect(function(dt)
            if not flyOn then return end
            local look, right = cam.CFrame.LookVector, cam.CFrame.RightVector
            local flatLook, flatRight = Vector3.new(look.X,0,look.Z), Vector3.new(right.X,0,right.Z)
            local dir = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then dir += flatLook end
            if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= flatLook end
            if UIS:IsKeyDown(Enum.KeyCode.D) then dir += flatRight end
            if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= flatRight end
            if dir.Magnitude>0 then dir=dir.Unit end
            local up=0
            if UIS:IsKeyDown(Enum.KeyCode.Space) then up=1 end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.RightControl) then up=-1 end
            flyBV.Velocity = Vector3.new(dir.X*flySpeed, up*flySpeed, dir.Z*flySpeed)
            local hrpPos = hrp.Position
            local targetCF = CFrame.lookAt(hrpPos, hrpPos + flatLook)
            hrp.CFrame = hrp.CFrame:Lerp(targetCF, math.clamp(FLY_TILT_STIFFNESS*dt,0,1))
            flyBGyro.CFrame = cam.CFrame
        end)
    end
    local function disableFly()
        if not flyOn then return end
        flyOn=false; setBtnState(b, "Fly: ", false)
        local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand=false end
        if flyConn then flyConn:Disconnect(); flyConn=nil end
        if flyBV then flyBV:Destroy(); flyBV=nil end
        if flyBGyro then flyBGyro:Destroy(); flyBGyro=nil end
    end
    if flyOn then disableFly() else enableFly() end
end)
setBtnState(btnFly, "Fly: ", flyOn)

lp.CharacterAdded:Connect(function(char)
    originalCollide = {}
    local hum = char:WaitForChild("Humanoid",10); char:WaitForChild("HumanoidRootPart",10)
    if hum then
        hum.WalkSpeed = currentSpeed
        baseRecorded=false; recordBaseJump(hum); applyJump(hum)
        if flyOn then task.wait(0.2); btnFly:Activate() end
    end
    if noclipOn then task.wait(0.1)
        for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
    end
end)

-------------------------
--       AIMBOT        --
-------------------------
local aimbotOn=false
local aimFOV = AIM_FOV_DEFAULT
local aimColor = Color3.fromRGB(255,70,70)
local aimSmooth = AIM_SMOOTH_DEFAULT

-- Tecla configurable (por defecto MouseButton2 / clic derecho)
local aimKey_IsMouse = true
local aimKey_Mouse   = Enum.UserInputType.MouseButton2
local aimKey_KeyCode = nil

local function aimKeyToText()
    if aimKey_IsMouse then
        if aimKey_Mouse == Enum.UserInputType.MouseButton2 then return "RMB (clic derecho)" end
        if aimKey_Mouse == Enum.UserInputType.MouseButton1 then return "LMB (clic izq.)" end
        if aimKey_Mouse == Enum.UserInputType.MouseButton3 then return "MMB (clic medio)" end
        return tostring(aimKey_Mouse.Name)
    else
        return aimKey_KeyCode and aimKey_KeyCode.Name or "N/A"
    end
end

-- Círculo de FOV
local fovCircle = mk("Frame",{AnchorPoint=Vector2.new(0.5,0.5), Size=UDim2.fromOffset(aimFOV*2, aimFOV*2),
    Position=UDim2.fromScale(0.5,0.5), BackgroundTransparency=1, Visible=false, ZIndex=999}, gui)
mk("UICorner",{CornerRadius=UDim.new(1,0)}, fovCircle)
local fovStroke = mk("UIStroke",{Thickness=2, Transparency=0.15, Color=aimColor}, fovCircle)

local function setFOV(v)
    aimFOV = math.clamp(math.floor(v+0.5), AIM_FOV_MIN, AIM_FOV_MAX)
    fovCircle.Size = UDim2.fromOffset(aimFOV*2, aimFOV*2)
end
local function setAimColor(c)
    aimColor = c; fovStroke.Color = c
end

-- Controles UI
local btnAimb = makeToggle(pageAimb, "Aimbot: OFF (mantén tecla)", 10, function(b)
    aimbotOn = not aimbotOn
    setBtnState(b, "Aimbot: ", aimbotOn)
    fovCircle.Visible = aimbotOn
end); setBtnState(btnAimb, "Aimbot: ", aimbotOn)

local fovLabel = mk("TextLabel",{BackgroundTransparency=1, Text="FOV: "..AIM_FOV_DEFAULT, TextColor3=Color3.fromRGB(235,235,255),
    Font=Enum.Font.Gotham, TextSize=14, Size=UDim2.new(1,-24,0,18), Position=UDim2.new(0,12,0,52)}, pageAimb)
local fovSlider = makeHardSlider(pageAimb, 74, AIM_FOV_MIN, AIM_FOV_MAX, AIM_FOV_DEFAULT, Color3.fromRGB(200,120,120), function(v)
    setFOV(v); fovLabel.Text = "FOV: "..aimFOV
end)

-- Smooth
local smoothLabel = mk("TextLabel",{BackgroundTransparency=1, Text=("Suavizado: %.2f"):format(AIM_SMOOTH_DEFAULT), TextColor3=Color3.fromRGB(235,235,255),
    Font=Enum.Font.Gotham, TextSize=14, Size=UDim2.new(1,-24,0,18), Position=UDim2.new(0,12,0,118)}, pageAimb)
local smoothSlider = makeHardSlider(pageAimb, 140, AIM_SMOOTH_MIN, AIM_SMOOTH_MAX, AIM_SMOOTH_DEFAULT, Color3.fromRGB(120,200,160), function(v)
    aimSmooth = math.clamp(v, AIM_SMOOTH_MIN, AIM_SMOOTH_MAX)
    smoothLabel.Text = ("Suavizado: %.2f"):format(aimSmooth)
end)

-- Color RGB
local rgbTitle = mk("TextLabel",{BackgroundTransparency=1, Text="Color FOV (R/G/B)", TextColor3=Color3.fromRGB(240,240,255),
    Font=Enum.Font.Gotham, TextSize=12, Size=UDim2.new(1,-24,0,16), Position=UDim2.new(0,12,0,178)}, pageAimb)
local R,G,B = 255,70,70
local rSl = makeHardSlider(pageAimb, 198, 0,255, R, Color3.fromRGB(255,100,100), function(v) R=math.floor(v+0.5); setAimColor(Color3.fromRGB(R,G,B)) end)
local gSl = makeHardSlider(pageAimb, 226, 0,255, G, Color3.fromRGB(100,255,100), function(v) G=math.floor(v+0.5); setAimColor(Color3.fromRGB(R,G,B)) end)
local bSl = makeHardSlider(pageAimb, 254, 0,255, B, Color3.fromRGB(100,100,255), function(v) B=math.floor(v+0.5); setAimColor(Color3.fromRGB(R,G,B)) end)
local preview = mk("Frame",{Size=UDim2.fromOffset(28,28), Position=UDim2.new(1,-40,0,198), BackgroundColor3=aimColor, ZIndex=6}, pageAimb)
mk("UIStroke",{Thickness=1.2, Transparency=0.4, Color=Color3.fromRGB(120,120,160)}, preview)
task.spawn(function()
    while preview.Parent do preview.BackgroundColor3 = aimColor; task.wait(0.1) end
end)

-- Rebind de tecla
local waitingBind = false
local keyLabel = mk("TextLabel",{BackgroundTransparency=1, Text="Tecla actual: "..aimKeyToText(), TextColor3=Color3.fromRGB(235,235,255),
    Font=Enum.Font.Gotham, TextSize=14, Size=UDim2.new(1,-24,0,18), Position=UDim2.new(0,12,0,294)}, pageAimb)
local bindBtn = makeToggle(pageAimb, "Cambiar tecla aimbot", 316, function(b)
    waitingBind = true
    b.Text = "Pulsa una tecla o botón..."
    b.BackgroundColor3 = Color3.fromRGB(80,80,140)
end)

UIS.InputBegan:Connect(function(inp, gpe)
    if waitingBind then
        waitingBind = false
        -- Preferimos teclas o botones del mouse
        if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.MouseButton2
            or inp.UserInputType == Enum.UserInputType.MouseButton3 then
            aimKey_IsMouse = true
            aimKey_Mouse   = inp.UserInputType
            aimKey_KeyCode = nil
        elseif inp.KeyCode ~= Enum.KeyCode.Unknown then
            aimKey_IsMouse = false
            aimKey_KeyCode = inp.KeyCode
        end
        keyLabel.Text = "Tecla actual: "..aimKeyToText()
        bindBtn.Text = "Cambiar tecla aimbot"
        setBtnState(bindBtn, "Cambiar tecla aimbot ", false) -- solo para restablecer color
        bindBtn.BackgroundColor3 = Color3.fromRGB(28,28,40)
    end
end)

-- Targeting
local aimHeld = false
UIS.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if aimKey_IsMouse and inp.UserInputType == aimKey_Mouse then aimHeld = true end
    if (not aimKey_IsMouse) and inp.KeyCode == (aimKey_KeyCode or Enum.KeyCode.Unknown) then aimHeld = true end
end)
UIS.InputEnded:Connect(function(inp, gpe)
    if aimKey_IsMouse and inp.UserInputType == aimKey_Mouse then aimHeld = false end
    if (not aimKey_IsMouse) and inp.KeyCode == (aimKey_KeyCode or Enum.KeyCode.Unknown) then aimHeld = false end
end)

local function getTargetHeadInFOV()
    local cam = Workspace.CurrentCamera
    local center = cam.ViewportSize/2
    local bestPlr, bestDist, bestHead = nil, math.huge, nil
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= lp then
            local char = p.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local head = char and char:FindFirstChild("Head")
            if hum and head and hum.Health>0 then
                local v2, on = cam:WorldToViewportPoint(head.Position)
                if on and v2.Z>0 then
                    local dist = (Vector2.new(v2.X, v2.Y) - center).Magnitude
                    if dist <= aimFOV and dist < bestDist then
                        bestDist = dist; bestPlr = p; bestHead = head
                    end
                end
            end
        end
    end
    return bestPlr, bestHead
end

RS.RenderStepped:Connect(function(dt)
    if not aimbotOn or not aimHeld then return end
    if Workspace.CurrentCamera.CameraType == Enum.CameraType.Scriptable then return end -- no aimbot si Freecam
    local cam = Workspace.CurrentCamera
    local _, head = getTargetHeadInFOV()
    if head then
        local from = cam.CFrame.Position
        local targetCF = CFrame.new(from, head.Position)
        local t = 1 - (1 - math.clamp(aimSmooth, 0, 0.98))^(math.max(dt*60,1))
        cam.CFrame = cam.CFrame:Lerp(targetCF, math.clamp(t, 0, 1))
    end
end)

-------------------------
--        VISUAL       --
-------------------------
local showNames, showHighlight = false, false
local nameTags, highlights = {}, {}
local function attachNameTag(plr)
    if plr == lp then return end
    local function onChar(char)
        local head = char:WaitForChild("Head", 8); if not head then return end
        if nameTags[plr] and nameTags[plr].Parent then nameTags[plr]:Destroy() end
        local bb = mk("BillboardGui",{Name="NameTag_DBG", Size=UDim2.fromOffset(200,50), StudsOffset=Vector3.new(0,2.5,0), AlwaysOnTop=true}, head)
        local tl = mk("TextLabel",{BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Font=Enum.Font.GothamBold, TextSize=16,
            TextColor3=Color3.fromRGB(255,255,255), TextStrokeTransparency=0.5, Text=plr.DisplayName.." (@"..plr.Name..")"}, bb)
        nameTags[plr]=bb; bb.Enabled = showNames
    end
    plr.CharacterAdded:Connect(onChar); if plr.Character then onChar(plr.Character) end
end
local function attachHighlight(plr)
    if plr == lp then return end
    local function onChar(char)
        if highlights[plr] and highlights[plr].Parent then highlights[plr]:Destroy() end
        local h = mk("Highlight",{Name="DebugHighlight", FillColor=Color3.fromRGB(220,40,40), OutlineColor=Color3.fromRGB(255,255,255),
            FillTransparency=0.25, OutlineTransparency=0, DepthMode=Enum.HighlightDepthMode.AlwaysOnTop}, char)
        highlights[plr]=h; h.Enabled = showHighlight
    end
    plr.CharacterAdded:Connect(onChar); if plr.Character then onChar(plr.Character) end
end
for _,p in ipairs(Players:GetPlayers()) do if p~=lp then attachNameTag(p); attachHighlight(p) end end
Players.PlayerAdded:Connect(function(p) attachNameTag(p); attachHighlight(p) end)
Players.PlayerRemoving:Connect(function(p) if nameTags[p] then nameTags[p]:Destroy(); nameTags[p]=nil end; if highlights[p] then highlights[p]:Destroy(); highlights[p]=nil end end)

local btnNames = makeToggle(pageVisual, "Nombres: OFF", 10, function(b)
    showNames = not showNames
    for _,bb in pairs(nameTags) do if bb and bb.Parent then bb.Enabled=showNames end end
    setBtnState(b, "Nombres: ", showNames)
end); setBtnState(btnNames, "Nombres: ", showNames)

local btnESP = makeToggle(pageVisual, "Resaltar (rojo): OFF", 50, function(b)
    showHighlight = not showHighlight
    for _,h in pairs(highlights) do if h and h.Parent then h.Enabled=showHighlight end end
    setBtnState(b, "Resaltar (rojo): ", showHighlight)
end); setBtnState(btnESP, "Resaltar (rojo): ", showHighlight)

-------------------------
--         OTROS       --
-------------------------
-- Invisible
local invisOn=false
local function setCharacterLocalTransparency(char, val)
    for _,d in ipairs(char:GetDescendants()) do
        if d:IsA("BasePart") then d.LocalTransparencyModifier=val
        elseif d:IsA("Decal") then d.Transparency=val end
    end
end
local function enableInvisible()
    local char=lp.Character; if not char then return end
    setCharacterLocalTransparency(char,1)
    local hum=char:FindFirstChildOfClass("Humanoid"); if hum then hum.NameDisplayDistance=0 end
end
local function disableInvisible()
    local char=lp.Character; if not char then return end
    setCharacterLocalTransparency(char,0)
    local hum=char:FindFirstChildOfClass("Humanoid"); if hum then hum.NameDisplayDistance=100 end
end
local btnInvis = makeToggle(pageOtros, "Invisible: OFF", 10, function(b)
    invisOn = not invisOn
    if invisOn then enableInvisible() else disableInvisible() end
    setBtnState(b, "Invisible: ", invisOn)
end); setBtnState(btnInvis, "Invisible: ", invisOn)

-- Freecam
local freecamOn=false
local prevCamType, prevCamSubj, prevCamCF, savedAnchor
local fcConn, mouseConn
local yaw,pitch=0,0
local function setMouseLock(lock)
    if lock then UIS.MouseIconEnabled=false; UIS.MouseBehavior=Enum.MouseBehavior.LockCurrentPosition
    else UIS.MouseBehavior=Enum.MouseBehavior.Default; UIS.MouseIconEnabled=true end
end
local function fcStart()
    if freecamOn then return end
    local cam=Workspace.CurrentCamera
    local hum,hrp=(lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")), (lp.Character and lp.Character:FindFirstChild("HumanoidRootPart"))
    if not (cam and hum and hrp) then return end
    freecamOn=true
    prevCamType, prevCamSubj, prevCamCF = cam.CameraType, cam.CameraSubject, cam.CFrame
    savedAnchor = hrp.Anchored; hrp.Anchored=true; hum.AutoRotate=false; hum.PlatformStand=true
    cam.CameraType=Enum.CameraType.Scriptable; setMouseLock(true); yaw=0; pitch=0
    mouseConn = UIS.InputChanged:Connect(function(inp,gpe)
        if gpe then return end
        if inp.UserInputType==Enum.UserInputType.MouseMovement and freecamOn then
            yaw = yaw - inp.Delta.X*FC_SENS.X
            pitch = math.clamp(pitch - inp.Delta.Y*FC_SENS.Y, -1.3, 1.3)
        end
    end)
    fcConn = RS.RenderStepped:Connect(function(dt)
        if not freecamOn then return end
        local cam=Workspace.CurrentCamera
        local rot = CFrame.Angles(0,yaw,0)*CFrame.Angles(pitch,0,0)
        local f,r,u=rot.LookVector, rot.RightVector, rot.UpVector
        local move=Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then move+=f end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move-=f end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move+=r end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move-=r end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move+=u end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.RightControl) then move-=u end
        if move.Magnitude>0 then move=move.Unit*(FC_SPEED_DEFAULT*dt) end
        cam.CFrame = CFrame.new(cam.CFrame.Position + move)*rot
    end)
end
local function fcStop()
    if not freecamOn then return end
    freecamOn=false
    if fcConn then fcConn:Disconnect(); fcConn=nil end
    if mouseConn then mouseConn:Disconnect(); mouseConn=nil end
    setMouseLock(false)
    local cam=Workspace.CurrentCamera
    local hum,hrp=(lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")), (lp.Character and lp.Character:FindFirstChild("HumanoidRootPart"))
    if hrp and savedAnchor~=nil then hrp.Anchored=savedAnchor end
    if hum then hum.AutoRotate=true; hum.PlatformStand=false end
    if cam then cam.CameraType=prevCamType or Enum.CameraType.Custom; cam.CameraSubject=prevCamSubj or (hum or hrp); cam.CFrame=prevCamCF or cam.CFrame end
end
local btnFree = makeToggle(pageOtros, "Foto (Freecam): OFF", 50, function(b)
    if freecamOn then fcStop() else fcStart() end
    setBtnState(b, "Foto (Freecam): ", freecamOn)
end); setBtnState(btnFree, "Foto (Freecam): ", freecamOn)

lp.CharacterAdded:Connect(function()
    if freecamOn then fcStop() end
    if invisOn then task.wait(0.2); enableInvisible() end
end)

-------------------------
--       CRÉDITOS      --
-------------------------
mk("TextLabel",{BackgroundTransparency=1, Size=UDim2.new(1,-24,0,24), Position=UDim2.new(0,12,0,10),
    Font=Enum.Font.GothamBlack, TextSize=16, TextColor3=Color3.fromRGB(235,235,255), TextXAlignment=Enum.TextXAlignment.Left,
    Text="creador: pedri.exe / Nakamy"}, pageCred)
mk("TextLabel",{BackgroundTransparency=1, Size=UDim2.new(1,-24,0,22), Position=UDim2.new(0,12,0,40),
    Font=Enum.Font.Gotham, TextSize=14, TextColor3=Color3.fromRGB(220,220,240), TextXAlignment=Enum.TextXAlignment.Left,
    Text="versión: V6"}, pageCred)
local credBtn = makeToggle(pageCred, "Discord: "..DISCORD_LINK.."  (clic para copiar)", 72, function(b)
    if setclipboard then setclipboard(DISCORD_LINK) end
    b.Text = "¡Copiado! "..DISCORD_LINK
end)

-------------------------
--   TECLA L (toggle)  --
-------------------------
local function openMain()
    if main.Visible then return end
    main.Visible=true
    main.Size=UDim2.fromOffset(780, 0)
    TS:Create(main, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size=UDim2.fromOffset(780,460)}):Play()
end
local function closeMain()
    if not main.Visible then return end
    TS:Create(main, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size=UDim2.fromOffset(780,0)}):Play()
    task.delay(0.22, function() main.Visible=false end)
end
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode==Enum.KeyCode.L and main.Visible then closeMain()
    elseif input.KeyCode==Enum.KeyCode.L and not main.Visible then openMain() end
end)

-------------------------
--   ACCIÓN DEL LOGIN  --
-------------------------
loginBtn.MouseButton1Click:Connect(function()
    if keyBox.Text == ACCESS_KEY then
        clickableBanner("bienvenido si nesesitas ayuda ven al discord "..DISCORD_LINK, DISCORD_LINK, 9)
        -- cierre del login con efecto
        TS:Create(scl, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale=0.96}):Play()
        TS:Create(loginOverlay, TweenInfo.new(0.16), {BackgroundTransparency=1}):Play()
        TS:Create(loginFrame, TweenInfo.new(0.18), {BackgroundTransparency=1}):Play()
        task.delay(0.2, function()
            if loginOverlay then loginOverlay:Destroy() end
            if loginFrame then loginFrame:Destroy() end
            openMain()
        end)
    else
        toast("Key incorrecta.", 5)
        loginBtn.BackgroundColor3 = Color3.fromRGB(150,50,50)
        task.delay(0.4, function() loginBtn.BackgroundColor3 = Color3.fromRGB(45,130,90) end)
    end
end)
