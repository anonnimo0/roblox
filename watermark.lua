-- Marca de agua con link
local ScreenGui = Instance.new("ScreenGui")
local TextButton = Instance.new("TextButton")

ScreenGui.Parent = game.CoreGui
TextButton.Parent = ScreenGui

TextButton.Text = "pedri.exe ジ"
TextButton.Size = UDim2.new(0, 150, 0, 40)
TextButton.Position = UDim2.new(0.5, -75, 0, 10)
TextButton.BackgroundColor3 = Color3.fromRGB(30,30,30)
TextButton.TextColor3 = Color3.fromRGB(255,255,255)
TextButton.BorderSizePixel = 0

TextButton.MouseButton1Click:Connect(function()
    setclipboard("https://miwa.lol/pedri")
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Marca de Agua";
        Text = "Link copiado: https://miwa.lol/pedri";
        Duration = 5;
    })
end)
