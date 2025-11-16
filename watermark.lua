---------------------------------------------------------
-- FUNCIONES LEGÍTÍMAS DE ADMIN
---------------------------------------------------------

local character = User.Character or User.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

---------------------------------------------------------
-- NAME (TEXTO ARRIBA DEL JUGADOR)
---------------------------------------------------------

local NameTagEnabled = false

local function ToggleName()
    NameTagEnabled = not NameTagEnabled

    if NameTagEnabled then
        -- Crear BillboardGui
        local bill = Instance.new("BillboardGui")
        bill.Name = "AdminNameTag"
        bill.Size = UDim2.new(5,0,1,0)
        bill.StudsOffset = Vector3.new(0,2,0)
        bill.AlwaysOnTop = true
        bill.Parent = character:WaitForChild("Head")

        local text = Instance.new("TextLabel", bill)
        text.Size = UDim2.new(1,0,1,0)
        text.BackgroundTransparency = 1
        text.TextColor3 = Color3.fromRGB(0,200,255)
        text.Font = Enum.Font.GothamBold
        text.TextScaled = true
        text.Text = "ADMIN"
    else
        if character:FindFirstChild("Head"):FindFirstChild("AdminNameTag") then
            character.Head.AdminNameTag:Destroy()
        end
    end
end

BtnName.MouseButton1Click:Connect(ToggleName)


---------------------------------------------------------
-- BOX / HIGHLIGHT (ILUMINACIÓN)
---------------------------------------------------------

local BoxEnabled = false
local highlights = {}

local function ToggleBox()
    BoxEnabled = not BoxEnabled

    if BoxEnabled then
        -- Crear highlight para cada jugador
        for _,plr in pairs(Players:GetPlayers()) do
            if plr.Character then
                local h = Instance.new("Highlight")
                h.FillTransparency = 1
                h.OutlineColor = Color3.fromRGB(0,200,255)
                h.Parent = plr.Character
                highlights[plr.Name] = h
            end
        end
    else
        -- Borrar todos
        for _,h in pairs(highlights) do
            if h then h:Destroy() end
        end
        highlights = {}
    end
end

-- Auto actualizar si entran jugadores
Players.PlayerAdded:Connect(function(plr)
    if BoxEnabled then
        plr.CharacterAdded:Connect(function(char)
            local h = Instance.new("Highlight")
            h.FillTransparency = 1
            h.OutlineColor = Color3.fromRGB(0,200,255)
            h.Parent = char
            highlights[plr.Name] = h
        end)
    end
end)

BtnBox.MouseButton1Click:Connect(ToggleBox)


---------------------------------------------------------
-- NOCLIP LEGAL (ATRAVESAR PAREDES)
---------------------------------------------------------

local Noclip = false

local function ToggleNoclip()
    Noclip = not Noclip

    if Noclip then
        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    else
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end

RunService.Stepped:Connect(function()
    if Noclip and character then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

BtnWall.MouseButton1Click:Connect(ToggleNoclip)


---------------------------------------------------------
-- FLY LEGAL ADMIN
---------------------------------------------------------

local Flying = false
local speed = 60

local bodyGyro
local bodyVel

local function ToggleFly()
    Flying = not Flying

    if Flying then
        local root = character:WaitForChild("HumanoidRootPart")

        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
        bodyGyro.P = 10000
        bodyGyro.Parent = root

        bodyVel = Instance.new("BodyVelocity")
        bodyVel.Velocity = Vector3.new(0,0,0)
        bodyVel.MaxForce = Vector3.new(9e9,9e9,9e9)
        bodyVel.Parent = root

        humanoid.PlatformStand = true

        -- Control de vuelo
        RunService.RenderStepped:Connect(function()
            if Flying then
                local cam = workspace.CurrentCamera
                bodyGyro.CFrame = cam.CFrame

                local move = Vector3.new(0,0,0)

                if UIS:IsKeyDown(Enum.KeyCode.W) then
                    move = move + cam.CFrame.LookVector
                end
                if UIS:IsKeyDown(Enum.KeyCode.S) then
                    move = move - cam.CFrame.LookVector
                end
                if UIS:IsKeyDown(Enum.KeyCode.A) then
                    move = move - cam.CFrame.RightVector
                end
                if UIS:IsKeyDown(Enum.KeyCode.D) then
                    move = move + cam.CFrame.RightVector
                end

                bodyVel.Velocity = move * speed
            end
        end)
    else
        humanoid.PlatformStand = false
        if bodyGyro then bodyGyro:Destroy() end
        if bodyVel then bodyVel:Destroy() end
    end
end

BtnFly.MouseButton1Click:Connect(ToggleFly)
