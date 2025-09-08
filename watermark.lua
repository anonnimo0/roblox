--// Foxxy's Leaks — Admin/Debug UI (HARD THEME)
--// Carga 10s -> Login -> Menú (Movimiento, Aimbot, Visual, Otros, Créditos)
--// Programador: by pedri.exe | Discord: https://discord.gg/FDjHggJF | Versión 1.30.130
--// Úsalo solo como util de admin/debug en tus propios juegos.

-------------------------
--    CONFIGURACIÓN    --
-------------------------
local ACCESS_KEY = "HJGL-FKSS"

-- Opcional: restringir a lugares/usuarios
local ALLOWED_PLACE_IDS = { }
local ALLOWED_USER_IDS  = { }

-- Movimiento
local SPEED_MIN, SPEED_MAX, SPEED_DEFAULT = 8, 120, 16
local FLY_SPEED_MIN, FLY_SPEED_MAX, FLY_SPEED_DEFAULT = 16, 240, 64
local JUMP_MULT_MIN, JUMP_MULT_MAX, JUMP_MULT_DEFAULT = 0.9, 1.8, 1.25
local JUMP_MAX_ABS_ADD = 32
local NOCLIP_CORRECTION_FACTOR = 0.88
local FLY_TILT_STIFFNESS = 8

-- Freecam (Otros)
local FC_SPEED_DEFAULT = 40
local FC_SENS = Vector2.new(0.003, 0.003)

-- Aimbot
local AIM_FOV_MIN, AIM_FOV_MAX, AIM_FOV_DEFAULT = 30, 500, 220
-- Intensidad 1..100 -> factor de seguimiento por frame (más alto = sigue más fuerte)
local AIM_INT_MIN, AIM_INT_MAX, AIM_INT_DEFAULT = 1, 100, 60

-- Visual
local USE_TEAMS_ONLY = true -- si hay Teams, marcar en rojo solo enemigos (otros equipos)

-- Identidad/branding
local TITLE = "Foxxy's Leaks"
local DISCORD_LINK = "https://discord.gg/FDjHggJF"

-------------------------
--      SERVICIOS      --
-------------------------
local Players   = game:GetService("Players")
local UIS       = game:GetService("UserInputService")
local TS        = game:GetService("TweenService")
local RS        = game:GetService("RunService")
local SG        = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local Teams     = game:GetService("Teams")

local lp = Players.LocalPlayer

-------------------------
--   AUTORIZACIÓN      --
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
    warn("[FoxxysLeaks] No autorizado en este lugar/usuario.")
    return
end

-------------------------
--   UTILES / FACTORY  --
-------------------------
local function mk(class, props, parent)
    local o = Instance.new(class)
    if props then for k,v in pairs(props) do o[k]=v end end
    if parent then o.Parent = parent end
    return o
end

-- Botón con animaciones (hover/click) y estado ON/OFF
local function styleButton(btn)
    local base = btn.BackgroundColor3
    local over = Color3.fromRGB(40,40,70)
    btn.MouseEnter:Connect(function()
        TS:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = over}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TS:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = base}):Play()
    end)
    btn.MouseButton1Down:Connect(function()
        local s = Instance.new("UIScale", btn); s.Scale = 1
        TS:Create(s, TweenInfo.new(0.08), {Scale = 0.96}):Play()
        task.delay(0.12, function() if s then s:Destroy() end end)
    end)
end
local function setToggle(btn, label, state)
    btn.Text = label .. (state and "ON" or "OFF")
    btn.BackgroundColor3 = state and Color3.fromRGB(45,130,90) or Color3.fromRGB(120,50,50)
end

-- Slider duro (barra, fill, knob recto)
local function hardSlider(parent, y, minV, maxV, defV, color, onChange)
    local cont = mk("Frame",{Size=UDim2.new(1,-24,0,28), Position=UDim2.new(0,12,0,y), BackgroundTransparency=1, ZIndex=5}, parent)
    local label = mk("TextLabel",{BackgroundTransparency=1, Size=UDim2.new(1,0,0,14), Position=UDim2.new(0,0,0,0),
        Font=Enum.Font.Gotham, TextSize=12, TextColor3=Color3.fromRGB(220,220,240), Text="Slider"}, cont)
    local bar = mk("Frame",{Size=UDim2.new(1,0,0,10), Position=UDim2.new(0,0,0,16), BackgroundColor3=Color3.fromRGB(32,32,46), BorderSizePixel=0}, cont)
    mk("UIStroke",{Thickness=1.5, Transparency=0.4, Color=Color3.fromRGB(70,80,130)}, bar)
    local fill = mk("Frame",{Size=UDim2.new(0,0,1,0), BackgroundColor3=color or Color3.fromRGB(90,160,255), BorderSizePixel=0}, bar)
    local knob = mk("Frame",{Size=UDim2.fromOffset(12,16), Position=UDim2.new(0,-6,0,13), BackgroundColor3=Color3.fromRGB(230,230,255), BorderSizePixel=0}, cont)
    mk("UIStroke",{Thickness=1.2, Transparency=0.25, Color=Color3.fromRGB(120,120,160)}, knob)

    styleButton(knob)

    local value = defV or minV
    local dragging = false
    local function setRel(rel)
        rel = math.clamp(rel,0,1)
        value = minV + rel*(maxV-minV)
        fill.Size = UDim2.new(rel,0,1,0)
        knob.Position = UDim2.new(rel,-6,0,13)
        if onChange then onChange(value, label) end
    end
    local function relFromX(x) return (x - bar.AbsolutePosition.X)/bar.AbsoluteSize.X end

    bar.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then setRel(relFromX(inp.Position.X)) dragging=true end end)
    knob.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end end)
    UIS.InputEnded:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    UIS.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then
            setRel(relFromX(inp.Position.X))
        end
    end)

    task.defer(function()
        setRel((value - minV)/(maxV-minV))
    end)

    return {
        setLabel=function(t) label.Text=t end,
        set=function(v) setRel((v-minV)/(maxV-minV)) end,
        get=function() return value end,
        setColor=function(c) fill.BackgroundColor3=c end
    }
end

-------------------------
--   PANTALLA CARGA    --
-------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "FoxyLeaksUI"
gui.ResetOnSpawn = false
pcall(function() gui.Parent = game.CoreGui end)
if not gui.Parent then gui.Parent = lp:WaitForChild("PlayerGui") end

local loader = mk("Frame",{Size=UDim2.fromScale(1,1), BackgroundColor3=Color3.fromRGB(5,5,10)}, gui)
local barBox = mk("Frame",{Size=UDim2.new(0.5,0,0,12), Position=UDim2.new(0.25,0,0.6,0),
    BackgroundColor3=Color3.fromRGB(18,18,26), BorderSizePixel=0}, loader)
mk("UIStroke",{Thickness=2, Transparency=0.2, Color=Color3.fromRGB(80,140,255)}, barBox)
local barFill = mk("Frame",{Size=UDim2.new(0,0,1,0), BackgroundColor3=Color3.fromRGB(80,140,255), BorderSizePixel=0}, barBox)
local txtLoad = mk("TextLabel",{BackgroundTransparency=1, Size=UDim2.new(1,0,0,24), Position=UDim2.new(0,0,0.6,-36),
    Font=Enum.Font.GothamBlack, TextSize=18, TextColor3=Color3.fromRGB(220,220,255), Text="Ajustando el juego …"}, loader)

-- animación puntos
task.spawn(function()
    local dots = 0
    while loader.Parent do
        dots = (dots+1)%4
        txtLoad.Text = "Ajustando el juego " .. string.rep(".", dots)
        task.wait(0.5)
    end
end)

-- Progreso 10s
task.spawn(function()
    local dur = 10
    local t0 = os.clock()
    while os.clock() - t0 < dur do
        local rel = (os.clock()-t0)/dur
        barFill.Size = UDim2.new(rel,0,1,0)
        task.wait()
    end
    barFill.Size = UDim2.new(1,0,1,0)
end)

-------------------------
--        LOGIN        --
-------------------------
local loginOverlay = mk("Frame",{Size=UDim2.fromScale(1,1), BackgroundTransparency=1, ZIndex=50}, gui)
local login = mk("Frame",{
    Size=UDim2.fromOffset(420, 210), Position=UDim2.new(0.5,-210, 0.35,0),
    BackgroundColor3=Color3.fromRGB(12,12,18), BorderSizePixel=0, ZIndex=60, Visible=false
}, gui)
-- Estilo duro: bordes rectos + marco doble y esquinas-luz
mk("UIStroke",{Thickness=2.5, Transparency=0.2, Color=Color3.fromRGB(100,160,255)}, login)
local frameTop = mk("Frame",{Size=UDim2.new(1,-20,0,4), Position=UDim2.new(0,10,0,44),
    BackgroundColor3=Color3.fromRGB(180,80,240), ZIndex=61}, login)
mk("UIGradient",{Color=ColorSequence.new(Color3.fromRGB(80,160,255), Color3.fromRGB(200,110,255))}, frameTop)

local titleL = mk("TextLabel",{BackgroundTransparency=1, Size=UDim2.new(1,-20,0,32), Position=UDim2.new(0,10,0,10),
    Font=Enum.Font.GothamBlack, TextSize=16, TextColor3=Color3.fromRGB(230,230,255), Text=TITLE.." — Login (hard)"}, login)
local keyBox = mk("TextBox",{Size=UDim2.new(1,-20,0,38), Position=UDim2.new(0,10,0,74),
    BackgroundColor3=Color3.fromRGB(24,24,34), TextColor3=Color3.new(1,1,1), PlaceholderText="Ingresa la key",
    ClearTextOnFocus=false, Font=Enum.Font.Gotham, TextSize=14, ZIndex=61}, login)
mk("UIStroke",{Thickness=1.6, Transparency=0.35, Color=Color3.fromRGB(70,120,220)}, keyBox)
local btnEnter = mk("TextButton",{Size=UDim2.new(1,-20,0,38), Position=UDim2.new(0,10,0,122),
    BackgroundColor3=Color3.fromRGB(45,130,90), TextColor3=Color3.new(1,1,1), Font=Enum.Font.GothamBold, TextSize=14, Text="Entrar", ZIndex=61}, login)
mk("UIStroke",{Thickness=1.8, Transparency=0.25, Color=Color3.fromRGB(60,130,100)}, btnEnter)
styleButton(btnEnter)
local infoL = mk("TextLabel",{BackgroundTransparency=1, Size=UDim2.new(1,-20,0,16), Position=UDim2.new(0,10,1,-22),
    Font=Enum.Font.Gotham, TextSize=12, TextColor3=Color3.fromRGB(180,180,200), Text="Key requerida para continuar", ZIndex=61}, login)

local function clickableBanner(msg, link, dur)
    local banner = mk("TextButton",{
        AutoButtonColor=true, Text = msg.."  (clic para copiar)",
        Font=Enum.Font.GothamSemibold, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left,
        TextColor3=Color3.fromRGB(235,235,255), Size=UDim2.new(1,-20,0,36),
        Position=UDim2.new(0,10,0,10), BackgroundColor3=Color3.fromRGB(28,28,40),
        BorderSizePixel=0, ZIndex=100, Visible=false
    }, gui)
    mk("UIStroke",{Thickness=1.2, Transparency=0.4, Color=Color3.fromRGB(70,120,220)}, banner)
    styleButton(banner)
    banner.MouseButton1Click:Connect(function()
        if setclipboard then setclipboard(link) banner.Text = "¡Copiado! "..link end
    end)
    banner.Visible = true
    TS:Create(banner, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position=UDim2.new(0,10,0,10)}):Play()
    task.delay(dur or 9, function()
        if banner and banner.Parent then
            TS:Create(banner, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position=UDim2.new(0,10,0,-40)}):Play()
            task.delay(0.22, function() if banner then banner:Destroy() end end)
        end
    end)
end

-------------------------
--    MENÚ PRINCIPAL   --
-------------------------
local main = mk("Frame",{Size=UDim2.fromOffset(820, 0), Position=UDim2.new(0.5,-410, 0.16,0),
    BackgroundColor3=Color3.fromRGB(8,8,14), BorderSizePixel=0, Visible=false, ZIndex=5}, gui)
mk("UIStroke",{Thickness=2.4, Transparency=0.25, Color=Color3.fromRGB(90,150,255)}, main)

-- DRAG (mover)
do
    local dragging, startPos, delta
    main.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; startPos = inp.Position; delta = startPos - main.AbsolutePosition
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local p = inp.Position - delta
            main.Position = UDim2.fromOffset(p.X, p.Y)
        end
    end)
    UIS.InputEnded:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
end

-- Sidebar tabs
local sidebar = mk("Frame",{Size=UDim2.fromOffset(180, 520), BackgroundColor3=Color3.fromRGB(14,14,22), BorderSizePixel=0, ZIndex=6}, main)
mk("UIStroke",{Thickness=2, Transparency=0.3, Color=Color3.fromRGB(60,80,130)}, sidebar)
local function makeTab(name, y)
    local b = mk("TextButton",{Size=UDim2.fromOffset(160,36), Position=UDim2.new(0,10,0,y),
        BackgroundColor3=Color3.fromRGB(28,28,40), BorderSizePixel=0, Font=Enum.Font.GothamBold, TextSize=14,
        TextColor3=Color3.new(1,1,1), Text=name, ZIndex=7}, sidebar)
    mk("UIStroke",{Thickness=1.8, Transparency=0.4, Color=Color3.fromRGB(70,70,110)}, b)
    styleButton(b)
    return b
end

local pages = mk("Frame",{Size=UDim2.fromOffset(820-180, 520), Position=UDim2.new(0,180,0,0),
    BackgroundTransparency=1, ZIndex=6}, main)
local pageMove  = mk("Frame",{Size=UDim2.fromScale(1,1), BackgroundTransparency=1, ZIndex=6}, pages)
local pageAimb  = mk("Frame",{Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Visible=false, ZIndex=6}, pages)
local pageVisual= mk("Frame",{Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Visible=false, ZIndex=6}, pages)
local pageOtros = mk("Frame",{Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Visible=false, ZIndex=6}, pages)
local pageCred  = mk("Frame",{Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Visible=false, ZIndex=6}, pages)

local function switchPage(which)
    pageMove.Visible=false; pageAimb.Visible=false; pageVisual.Visible=false; pageOtros.Visible=false; pageCred.Visible=false
    which.Visible=true
end

local tbMove   = makeTab("Movimiento", 16);   tbMove.MouseButton1Click:Connect(function() switchPage(pageMove) end)
local tbAimb   = makeTab("Aimbot",     56);   tbAimb.MouseButton1Click:Connect(function() switchPage(pageAimb) end)
local tbVisual = makeTab("Visual",     96);   tbVisual.MouseButton1Click:Connect(function() switchPage(pageVisual) end)
local tbOtros  = makeTab("Otros",     136);   tbOtros.MouseButton1Click:Connect(function() switchPage(pageOtros) end)
local tbCred   = makeTab("Créditos",  176);   tbCred.MouseButton1Click:Connect(function() switchPage(pageCred) end)

-- Header + footer
local header = mk("TextLabel",{BackgroundTransparency=1, Size=UDim2.new(1,0,0,32), Position=UDim2.new(0,10,0,10),
    Font=Enum.Font.GothamBlack, TextSize=16, TextColor3=Color3.fromRGB(220,220,255), Text = TITLE.."  —  [L para ocultar/mostrar]"}, pages)
local footer = mk("TextLabel",{BackgroundTransparency=1, Size=UDim2.new(1,-16,0,20), Position=UDim2.new(0,8,1,-24),
    Font=Enum.Font.Gotham, TextSize=12, TextColor3=Color3.fromRGB(160,160,190),
    Text="programador: by pedri.exe  |  Usuario: (cargando...)",
    ZIndex=7, TextXAlignment=Enum.TextXAlignment.Center}, pages)
task.defer(function()
    footer.Text = string.format("programador: by pedri.exe  |  Usuario: %s (@%s)", lp.DisplayName, lp.Name)
end)

-------------------------
--   MOVIMIENTO (UI)   --
-------------------------
local currentSpeed, flySpeed = SPEED_DEFAULT, FLY_SPEED_DEFAULT
local jumpMult = JUMP_MULT_DEFAULT

local speedS = hardSlider(pageMove, 36, SPEED_MIN, SPEED_MAX, SPEED_DEFAULT, Color3.fromRGB(80,180,120), function(v, lab)
    currentSpeed = math.floor(v+0.5); lab.Text = "Velocidad: "..currentSpeed
    local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed = currentSpeed end
end); speedS.setLabel("Velocidad: "..SPEED_DEFAULT)

local jumpS = hardSlider(pageMove, 96, JUMP_MULT_MIN, JUMP_MULT_MAX, JUMP_MULT_DEFAULT, Color3.fromRGB(120,150,230), function(v, lab)
    jumpMult = v; lab.Text = ("Salto: x%.2f"):format(jumpMult)
    local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        local useJP, baseJP, baseJH = hum.UseJumpPower, hum.JumpPower, hum.JumpHeight
        if useJP then
            hum.JumpPower = math.min(baseJP + JUMP_MAX_ABS_ADD, baseJP * jumpMult)
        else
            hum.JumpHeight = math.min(baseJH + (JUMP_MAX_ABS_ADD/8), baseJH * jumpMult)
        end
    end
end); jumpS.setLabel(("Salto: x%.2f"):format(JUMP_MULT_DEFAULT))

local flyS = hardSlider(pageMove, 156, FLY_SPEED_MIN, FLY_SPEED_MAX, FLY_SPEED_DEFAULT, Color3.fromRGB(210,150,100), function(v, lab)
    flySpeed = math.floor(v+0.5); lab.Text = "Velocidad de vuelo: "..flySpeed
end); flyS.setLabel("Velocidad de vuelo: "..FLY_SPEED_DEFAULT)

local function getHum()
    local c = lp.Character
    return c and c:FindFirstChildOfClass("Humanoid"), c and c:FindFirstChild("HumanoidRootPart")
end

-- Noclip
local noclipOn=false
local hbConn, steppedConn
local origCollide = {}
local btnNoclip = mk("TextButton",{Size=UDim2.new(1,-24,0,34), Position=UDim2.new(0,12,0,210),
    BackgroundColor3=Color3.fromRGB(120,50,50), BorderSizePixel=0, Font=Enum.Font.GothamBold, TextSize=14, Text="Atravesar paredes: OFF", TextColor3=Color3.new(1,1,1)}, pageMove)
mk("UIStroke",{Thickness=1.8, Transparency=0.4, Color=Color3.fromRGB(70,70,110)}, btnNoclip); styleButton(btnNoclip)
btnNoclip.MouseButton1Click:Connect(function()
    noclipOn = not noclipOn
    setToggle(btnNoclip, "Atravesar paredes: ", noclipOn)
    local function cacheDefaults(char)
        for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") and origCollide[p]==nil then origCollide[p]=p.CanCollide end end
    end
    local function setCharCollision(char, can)
        for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = can; p.CanTouch = not can end end
    end
    if noclipOn then
        local char = lp.Character
        if char then cacheDefaults(char); setCharCollision(char,false) end
        if steppedConn then steppedConn:Disconnect() end
        steppedConn = RS.Stepped:Connect(function()
            if not noclipOn then return end
            local c = lp.Character; if not c then return end
            for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
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
            for _,p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and origCollide[p]~=nil then p.CanCollide = origCollide[p]; p.CanTouch=true end
            end
        end
    end
end)

-- Fly
local flyOn=false
local flyBV, flyBGyro, flyConn
local btnFly = mk("TextButton",{Size=UDim2.new(1,-24,0,34), Position=UDim2.new(0,12,0,250),
    BackgroundColor3=Color3.fromRGB(120,50,50), BorderSizePixel=0, Font=Enum.Font.GothamBold, TextSize=14, Text="Fly: OFF", TextColor3=Color3.new(1,1,1)}, pageMove)
mk("UIStroke",{Thickness=1.8, Transparency=0.4, Color=Color3.fromRGB(70,70,110)}, btnFly); styleButton(btnFly)
btnFly.MouseButton1Click:Connect(function()
    local function enableFly()
        if flyOn then return end
        flyOn = true; setToggle(btnFly, "Fly: ", true)
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
            local hrp2 = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            if hrp2 then
                local hrpPos = hrp2.Position
                local targetCF = CFrame.lookAt(hrpPos, hrpPos + flatLook)
                hrp2.CFrame = hrp2.CFrame:Lerp(targetCF, math.clamp(FLY_TILT_STIFFNESS*dt,0,1))
                flyBGyro.CFrame = cam.CFrame
            end
        end)
    end
    local function disableFly()
        if not flyOn then return end
        flyOn=false; setToggle(btnFly, "Fly: ", false)
        local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand=false end
        if flyConn then flyConn:Disconnect(); flyConn=nil end
        if flyBV then flyBV:Destroy(); flyBV=nil end
        if flyBGyro then flyBGyro:Destroy(); flyBGyro=nil end
    end
    if flyOn then disableFly() else enableFly() end
end)

lp.CharacterAdded:Connect(function(char)
    origCollide = {}
    local hum = char:WaitForChild("Humanoid",10); char:WaitForChild("HumanoidRootPart",10)
    if hum then hum.WalkSpeed = currentSpeed end
    if flyOn then task.wait(0.2); btnFly:Activate() end
    if noclipOn then task.wait(0.1)
        for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
    end
end)

-------------------------
--      AIMBOT (UI)    --
-------------------------
local aimbotOn=false
local aimFOV = AIM_FOV_DEFAULT
local aimCircleOn = true
local aimColor = Color3.fromRGB(255,70,70)
local aimIntensity = AIM_INT_DEFAULT -- 1..100

-- Keybind
local aimKey_IsMouse = true
local aimKey_Mouse   = Enum.UserInputType.MouseButton2
local aimKey_KeyCode = nil
local function aimKeyToText()
    if aimKey_IsMouse then
        if aimKey_Mouse == Enum.UserInputType.MouseButton2 then return "RMB (clic derecho)" end
        if aimKey_Mouse == Enum.UserInputType.MouseButton1 then return "LMB (clic izq.)" end
        if aimKey_Mouse == Enum.UserInputType.MouseButton3 then return "MMB (clic medio)" end
        return aimKey_Mouse.Name
    else
        return aimKey_KeyCode and aimKey_KeyCode.Name or "N/A"
    end
end

-- FOV circle
local fovCircle = mk("Frame",{AnchorPoint=Vector2.new(0.5,0.5), Size=UDim2.fromOffset(aimFOV*2, aimFOV*2),
    Position=UDim2.fromScale(0.5,0.5), BackgroundTransparency=1, Visible=aimCircleOn, ZIndex=999}, gui)
mk("UICorner",{CornerRadius=UDim.new(1,0)}, fovCircle)
local fovStroke = mk("UIStroke",{Thickness=2, Transparency=0.15, Color=aimColor}, fovCircle)
local function setFOV(v) aimFOV = math.clamp(math.floor(v+0.5), AIM_FOV_MIN, AIM_FOV_MAX); fovCircle.Size = UDim2.fromOffset(aimFOV*2, aimFOV*2) end
local function setAimColor(c) aimColor=c; fovStroke.Color=c end

-- Controles
local btnAimb = mk("TextButton",{Size=UDim2.new(1,-24,0,34), Position=UDim2.new(0,12,0,10),
    BackgroundColor3=Color3.fromRGB(120,50,50), BorderSizePixel=0, Font=Enum.Font.GothamBold, TextSize=14, Text="Aimbot: OFF", TextColor3=Color3.new(1,1,1)}, pageAimb)
mk("UIStroke",{Thickness=1.8, Transparency=0.4, Color=Color3.fromRGB(70,70,110)}, btnAimb); styleButton(btnAimb)
btnAimb.MouseButton1Click:Connect(function() aimbotOn = not aimbotOn; setToggle(btnAimb, "Aimbot: ", aimbotOn); fovCircle.Visible = aimbotOn and aimCircleOn end)

local btnBind = mk("TextButton",{Size=UDim2.new(1,-24,0,34), Position=UDim2.new(0,12,0,50),
    BackgroundColor3=Color3.fromRGB(28,28,40), BorderSizePixel=0, Font=Enum.Font.GothamBold, TextSize=14, Text="Cambiar tecla ("..aimKeyToText()..")", TextColor3=Color3.new(1,1,1)}, pageAimb)
mk("UIStroke",{Thickness=1.8, Transparency=0.4, Color=Color3.fromRGB(70,70,110)}, btnBind); styleButton(btnBind)
local waitingBind=false
btnBind.MouseButton1Click:Connect(function()
    waitingBind = true
    btnBind.Text = "Pulsa una tecla o botón…"
    btnBind.BackgroundColor3 = Color3.fromRGB(80,80,140)
end)
UIS.InputBegan:Connect(function(inp, gpe)
    if waitingBind then
        waitingBind=false
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.MouseButton2 or inp.UserInputType == Enum.UserInputType.MouseButton3 then
            aimKey_IsMouse=true; aimKey_Mouse=inp.UserInputType; aimKey_KeyCode=nil
        elseif inp.KeyCode ~= Enum.KeyCode.Unknown then
            aimKey_IsMouse=false; aimKey_KeyCode=inp.KeyCode
        end
        btnBind.Text = "Cambiar tecla ("..aimKeyToText()..")"
        btnBind.BackgroundColor3 = Color3.fromRGB(28,28,40)
    end
end)

-- Intensidad 1..100
local intS = hardSlider(pageAimb, 96, AIM_INT_MIN, AIM_INT_MAX, AIM_INT_DEFAULT, Color3.fromRGB(120,200,160), function(v, lab)
    aimIntensity = math.floor(v+0.5)
    lab.Text = "Intensidad: "..aimIntensity.."/100"
end); intS.setLabel("Intensidad: "..AIM_INT_DEFAULT.."/100")

-- FOV ON/OFF
local btnFOV = mk("TextButton",{Size=UDim2.new(1,-24,0,34), Position=UDim2.new(0,12,0,136),
    BackgroundColor3=Color3.fromRGB(45,130,90), BorderSizePixel=0, Font=Enum.Font.GothamBold, TextSize=14, Text="FOV círculo: ON", TextColor3=Color3.new(1,1,1)}, pageAimb)
mk("UIStroke",{Thickness=1.8, Transparency=0.4, Color=Color3.fromRGB(70,70,110)}, btnFOV); styleButton(btnFOV)
btnFOV.MouseButton1Click:Connect(function()
    aimCircleOn = not aimCircleOn
    btnFOV.Text = "FOV círculo: " .. (aimCircleOn and "ON" or "OFF")
    btnFOV.BackgroundColor3 = aimCircleOn and Color3.fromRGB(45,130,90) or Color3.fromRGB(120,50,50)
    fovCircle.Visible = aimbotOn and aimCircleOn
end)

-- FOV tamaño
local fovS = hardSlider(pageAimb, 176, AIM_FOV_MIN, AIM_FOV_MAX, AIM_FOV_DEFAULT, Color3.fromRGB(200,120,120), function(v, lab)
    setFOV(v); lab.Text = "FOV: "..aimFOV
end); fovS.setLabel("FOV: "..AIM_FOV_DEFAULT)

-- Color FOV (RGB)
local rgbTitle = mk("TextLabel",{BackgroundTransparency=1, Size=UDim2.new(1,-24,0,16), Position=UDim2.new(0,12,0,216),
    Font=Enum.Font.Gotham, TextSize=12, TextColor3=Color3.fromRGB(240,240,255), Text="Color FOV (R/G/B)"}, pageAimb)
local R,G,B = 255,70,70
local rSl = hardSlider(pageAimb, 236, 0,255,R, Color3.fromRGB(255,100,100), function(v) R=math.floor(v+0.5); setAimColor(Color3.fromRGB(R,G,B)) end); rSl.setLabel("Rojo")
local gSl = hardSlider(pageAimb, 264, 0,255,G, Color3.fromRGB(100,255,100), function(v) G=math.floor(v+0.5); setAimColor(Color3.fromRGB(R,G,B)) end); gSl.setLabel("Verde")
local bSl = hardSlider(pageAimb, 292, 0,255,B, Color3.fromRGB(100,100,255), function(v) B=math.floor(v+0.5); setAimColor(Color3.fromRGB(R,G,B)) end); bSl.setLabel("Azul")

-- Lógica aimbot
local aimHeld=false
UIS.InputBegan:Connect(function(inp,gpe)
    if gpe then return end
    if aimKey_IsMouse and inp.UserInputType==aimKey_Mouse then aimHeld=true end
    if (not aimKey_IsMouse) and inp.KeyCode==(aimKey_KeyCode or Enum.KeyCode.Unknown) then aimHeld=true end
end)
UIS.InputEnded:Connect(function(inp,gpe)
    if aimKey_IsMouse and inp.UserInputType==aimKey_Mouse then aimHeld=false end
    if (not aimKey_IsMouse) and inp.KeyCode==(aimKey_KeyCode or Enum.KeyCode.Unknown) then aimHeld=false end
end)

local function getTargetHeadInFOV()
    local cam = Workspace.CurrentCamera
    local center = cam.ViewportSize/2
    local bestHead, bestDist
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= lp then
            if not (USE_TEAMS_ONLY and Teams and Teams:FindFirstChildOfClass("Team") and lp.Team and p.Team and p.Team==lp.Team) then
                local char = p.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local head= char and char:FindFirstChild("Head")
                if hum and head and hum.Health>0 then
                    local v2, on = cam:WorldToViewportPoint(head.Position)
                    if on and v2.Z>0 then
                        local dist = (Vector2.new(v2.X,v2.Y) - center).Magnitude
                        if dist <= aimFOV and (not bestDist or dist<bestDist) then
                            bestDist = dist; bestHead = head
                        end
                    end
                end
            end
        end
    end
    return bestHead
end

RS.RenderStepped:Connect(function(dt)
    if not (aimbotOn and aimHeld) then return end
    if Workspace.CurrentCamera.CameraType == Enum.CameraType.Scriptable then return end
    local cam = Workspace.CurrentCamera
    local head = getTargetHeadInFOV()
    if head then
        local from = cam.CFrame.Position
        local target = CFrame.new(from, head.Position)
        -- map intensidad 1..100 -> factor de lerp por frame
        local k = math.clamp(aimIntensity/100, 0.02, 1) -- 0.02 mínimo
        local t = 1 - (1 - k)^(math.max(dt*60,1))       -- tiempo dependiente del frame
        cam.CFrame = cam.CFrame:Lerp(target, math.clamp(t,0,1))
    end
end)

-------------------------
--       VISUAL (UI)   --
-------------------------
local visualOn=false
local showESP=false
local showNames=false
local showDist=false

local btnVisual = mk("TextButton",{Size=UDim2.new(1,-24,0,34), Position=UDim2.new(0,12,0,10),
    BackgroundColor3=Color3.fromRGB(120,50,50), BorderSizePixel=0, Font=Enum.Font.GothamBold, TextSize=14, Text="Visual: OFF", TextColor3=Color3.new(1,1,1)}, pageVisual)
mk("UIStroke",{Thickness=1.8, Transparency=0.4, Color=Color3.fromRGB(70,70,110)}, btnVisual); styleButton(btnVisual)
btnVisual.MouseButton1Click:Connect(function() visualOn = not visualOn; setToggle(btnVisual, "Visual: ", visualOn) end)

local btnESP = mk("TextButton",{Size=UDim2.new(1,-24,0,34), Position=UDim2.new(0,12,0,50),
    BackgroundColor3=Color3.fromRGB(120,50,50), BorderSizePixel=0, Font=Enum.Font.GothamBold, TextSize=14, Text="Marcar enemigos (rojo): OFF", TextColor3=Color3.new(1,1,1)}, pageVisual)
mk("UIStroke",{Thickness=1.8, Transparency=0.4, Color=Color3.fromRGB(70,70,110)}, btnESP); styleButton(btnESP)
local btnNames = mk("TextButton",{Size=UDim2.new(1,-24,0,34), Position=UDim2.new(0,12,0,90),
    BackgroundColor3=Color3.fromRGB(120,50,50), BorderSizePixel=0, Font=Enum.Font.GothamBold, TextSize=14, Text="Nombres: OFF", TextColor3=Color3.new(1,1,1)}, pageVisual)
mk("UIStroke",{Thickness=1.8, Transparency=0.4, Color=Color3.fromRGB(70,70,110)}, btnNames); styleButton(btnNames)
local btnDist = mk("TextButton",{Size=UDim2.new(1,-24,0,34), Position=UDim2.new(0,12,0,130),
    BackgroundColor3=Color3.fromRGB(120,50,50), BorderSizePixel=0, Font=Enum.Font.GothamBold, TextSize=14, Text="Distancia: OFF", TextColor3=Color3.new(1,1,1)}, pageVisual)
mk("UIStroke",{Thickness=1.8, Transparency=0.4, Color=Color3.fromRGB(70,70,110)}, btnDist); styleButton(btnDist)

btnESP.MouseButton1Click:Connect(function() showESP = not showESP; setToggle(btnESP, "Marcar enemigos (rojo): ", showESP) end)
btnNames.MouseButton1Click:Connect(function() showNames = not showNames; setToggle(btnNames, "Nombres: ", showNames) end)
btnDist.MouseButton1Click:Connect(function() showDist = not showDist; setToggle(btnDist, "Distancia: ", showDist) end)

-- Implementación de etiquetas y highlights
local nameTags, distTags, highlights = {}, {}, {}
local function onCharFor(p)
    if p==lp then return end
    local char = p.Character; if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end

    -- Name tag
    do
        if nameTags[p] then nameTags[p]:Destroy() end
        local bb = Instance.new("BillboardGui"); bb.Size=UDim2.fromOffset(200,50); bb.StudsOffset=Vector3.new(0,2.8,0); bb.AlwaysOnTop=true; bb.Parent=head
        local tl = Instance.new("TextLabel"); tl.BackgroundTransparency=1; tl.Size=UDim2.new(1,0,0,20); tl.Position=UDim2.new(0,0,0,0)
        tl.Font=Enum.Font.GothamBold; tl.TextSize=16; tl.TextColor3=Color3.fromRGB(255,255,255); tl.TextStrokeTransparency=0.5
        tl.Text = p.DisplayName.." (@"..p.Name..")"; tl.Parent=bb
        bb.Enabled = showNames and visualOn
        nameTags[p]=bb
    end

    -- Dist tag
    do
        if distTags[p] then distTags[p]:Destroy() end
        local bb = Instance.new("BillboardGui"); bb.Size=UDim2.fromOffset(120,24); bb.StudsOffset=Vector3.new(0,1.8,0); bb.AlwaysOnTop=true; bb.Parent=head
        local tl = Instance.new("TextLabel"); tl.BackgroundTransparency=1; tl.Size=UDim2.new(1,0,1,0)
        tl.Font=Enum.Font.Gotham; tl.TextSize=12; tl.TextColor3=Color3.fromRGB(200,220,255)
        tl.Text = "dist: --m"; tl.Parent=bb
        bb.Enabled = showDist and visualOn
        distTags[p]=bb
    end

    -- Highlight rojo (enemigos)
    do
        if highlights[p] then highlights[p]:Destroy() end
        local h = Instance.new("Highlight"); h.FillColor=Color3.fromRGB(220,40,40); h.OutlineColor=Color3.fromRGB(255,255,255)
        h.FillTransparency=0.25; h.OutlineTransparency=0; h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; h.Parent=char
        -- visible solo si showESP y (enemigo si Teams)
        local isEnemy = true
        if USE_TEAMS_ONLY and Teams and lp.Team and p.Team then isEnemy = (lp.Team ~= p.Team) end
        h.Enabled = visualOn and showESP and isEnemy
        highlights[p]=h
    end
end

for _,p in ipairs(Players:GetPlayers()) do if p~=lp then
    p.CharacterAdded:Connect(function() task.delay(0.2, function() onCharFor(p) end) end)
    if p.Character then onCharFor(p) end
end end
Players.PlayerAdded:Connect(function(p)
    if p==lp then return end
    p.CharacterAdded:Connect(function() task.delay(0.2, function() onCharFor(p) end) end)
end)
Players.PlayerRemoving:Connect(function(p)
    if nameTags[p] then nameTags[p]:Destroy(); nameTags[p]=nil end
    if distTags[p] then distTags[p]:Destroy(); distTags[p]=nil end
    if highlights[p] then highlights[p]:Destroy(); highlights[p]=nil end
end)

-- Update toggles visuales
RS.RenderStepped:Connect(function()
    for p,bb in pairs(nameTags) do if bb and bb.Parent then bb.Enabled = visualOn and showNames end end
    for p,bb in pairs(distTags) do
        if bb and bb.Parent then
            bb.Enabled = visualOn and showDist
            if bb.Enabled then
                local char = p.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local my = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                if hrp and my then
                    local d = (hrp.Position - my.Position).Magnitude
                    bb:FindFirstChildOfClass("TextLabel").Text = ("dist: %dm"):format(d//1)
                end
            end
        end
    end
    for p,h in pairs(highlights) do
        if h and h.Parent then
            local isEnemy = true
            if USE_TEAMS_ONLY and Teams and lp.Team and p.Team then isEnemy = (lp.Team ~= p.Team) end
            h.Enabled = visualOn and showESP and isEnemy
        end
    end
end)

-------------------------
--         OTROS       --
-------------------------
-- Invisible
local invisOn=false
local btnInvis = mk("TextButton",{Size=UDim2.new(1,-24,0,34), Position=UDim2.new(0,12,0,10),
    BackgroundColor3=Color3.fromRGB(120,50,50), BorderSizePixel=0, Font=Enum.Font.GothamBold, TextSize=14, Text="Invisible: OFF", TextColor3=Color3.new(1,1,1)}, pageOtros)
mk("UIStroke",{Thickness=1.8, Transparency=0.4, Color=Color3.fromRGB(70,70,110)}, btnInvis); styleButton(btnInvis)
local function setLocalTransparency(char, val)
    for _,d in ipairs(char:GetDescendants()) do
        if d:IsA("BasePart") then d.LocalTransparencyModifier = val
        elseif d:IsA("Decal") then d.Transparency = val end
    end
end
btnInvis.MouseButton1Click:Connect(function()
    invisOn = not invisOn
    setToggle(btnInvis, "Invisible: ", invisOn)
    local c = lp.Character; if not c then return end
    if invisOn then setLocalTransparency(c,1) else setLocalTransparency(c,0) end
end)

-- Freecam modo foto
local freecamOn=false
local prevCamType, prevCamSubj, prevCamCF, savedAnchor
local fcConn, mouseConn
local yaw,pitch=0,0
local function setMouseLock(lock)
    if lock then UIS.MouseIconEnabled=false; UIS.MouseBehavior=Enum.MouseBehavior.LockCurrentPosition
    else UIS.MouseBehavior=Enum.MouseBehavior.Default; UIS.MouseIconEnabled=true end
end
local btnFree = mk("TextButton",{Size=UDim2.new(1,-24,0,34), Position=UDim2.new(0,12,0,50),
    BackgroundColor3=Color3.fromRGB(120,50,50), BorderSizePixel=0, Font=Enum.Font.GothamBold, TextSize=14, Text="Foto (Freecam): OFF", TextColor3=Color3.new(1,1,1)}, pageOtros)
mk("UIStroke",{Thickness=1.8, Transparency=0.4, Color=Color3.fromRGB(70,70,110)}, btnFree); styleButton(btnFree)
local function fcStart()
    if freecamOn then return end
    local cam=Workspace.CurrentCamera; local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid"); local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not (cam and hum and hrp) then return end
    freecamOn=true; setToggle(btnFree, "Foto (Freecam): ", true)
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
        local rot=CFrame.Angles(0,yaw,0)*CFrame.Angles(pitch,0,0)
        local f,r,u=rot.LookVector,rot.RightVector,rot.UpVector
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
    freecamOn=false; setToggle(btnFree, "Foto (Freecam): ", false)
    if fcConn then fcConn:Disconnect(); fcConn=nil end
    if mouseConn then mouseConn:Disconnect(); mouseConn=nil end
    setMouseLock(false)
    local cam=Workspace.CurrentCamera; local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid"); local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if hrp and savedAnchor~=nil then hrp.Anchored=savedAnchor end
    if hum then hum.AutoRotate=true; hum.PlatformStand=false end
    if cam then cam.CameraType=prevCamType or Enum.CameraType.Custom; cam.CameraSubject=prevCamSubj or (hum or hrp); cam.CFrame=prevCamCF or cam.CFrame end
end
btnFree.MouseButton1Click:Connect(function() if freecamOn then fcStop() else fcStart() end end)
lp.CharacterAdded:Connect(function() if freecamOn then fcStop() end end)

-------------------------
--       CRÉDITOS      --
-------------------------
mk("TextLabel",{BackgroundTransparency=1, Size=UDim2.new(1,-24,0,24), Position=UDim2.new(0,12,0,10),
    Font=Enum.Font.GothamBlack, TextSize=16, TextColor3=Color3.fromRGB(235,235,255), TextXAlignment=Enum.TextXAlignment.Left,
    Text="creador: by pedri.exe"}, pageCred)
mk("TextLabel",{BackgroundTransparency=1, Size=UDim2.new(1,-24,0,22), Position=UDim2.new(0,12,0,38),
    Font=Enum.Font.Gotham, TextSize=14, TextColor3=Color3.fromRGB(220,220,240), TextXAlignment=Enum.TextXAlignment.Left,
    Text="discord: "..DISCORD_LINK}, pageCred)
mk("TextLabel",{BackgroundTransparency=1, Size=UDim2.new(1,-24,0,22), Position=UDim2.new(0,12,0,62),
    Font=Enum.Font.Gotham, TextSize=14, TextColor3=Color3.fromRGB(220,220,240), TextXAlignment=Enum.TextXAlignment.Left,
    Text="versión: 1.30.130"}, pageCred)

-------------------------
--     TECLA L UI      --
-------------------------
local function openMain()
    if main.Visible then return end
    main.Visible = true
    main.Size = UDim2.fromOffset(820, 0)
    TS:Create(main, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size=UDim2.fromOffset(820,520)}):Play()
end
local function closeMain()
    if not main.Visible then return end
    TS:Create(main, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size=UDim2.fromOffset(820,0)}):Play()
    task.delay(0.22, function() main.Visible=false end)
end
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode==Enum.KeyCode.L and main.Visible then closeMain()
    elseif input.KeyCode==Enum.KeyCode.L and not main.Visible then openMain() end
end)

-------------------------
--   FLUJO CARGA->LOGIN
-------------------------
task.delay(10, function() -- 10 segundos
    if loader then loader:Destroy() end
    login.Visible = true
    -- animación de entrada
    local scale = mk("UIScale",{Scale=0.92}, login)
    TS:Create(scale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale=1}):Play()
end)

local function toast(txt, dur)
    pcall(function() SG:SetCore("SendNotification", {Title=TITLE, Text=txt, Duration=dur or 5}) end)
end

btnEnter.MouseButton1Click:Connect(function()
    if keyBox.Text == ACCESS_KEY then
        clickableBanner("Bienvenido. Si necesitas ayuda ven al discord "..DISCORD_LINK, DISCORD_LINK, 9)
        TS:Create(login, TweenInfo.new(0.18), {BackgroundTransparency=1}):Play()
        task.delay(0.18, function() if login then login:Destroy() end; openMain() end)
    else
        toast("Key incorrecta.", 5)
        btnEnter.BackgroundColor3 = Color3.fromRGB(150,50,50)
        task.delay(0.4, function() btnEnter.BackgroundColor3 = Color3.fromRGB(45,130,90) end)
    end
end)
