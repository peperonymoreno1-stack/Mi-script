local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MenuGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 320)
frame.Position = UDim2.new(0, 20, 0.5, -160)
frame.BackgroundColor3 = Color3.fromRGB(80, 0, 120)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(180, 0, 255)
stroke.Thickness = 3
stroke.Parent = frame

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(60, 0, 100)
title.BorderSizePixel = 0
title.Text = "⚡ Menu"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 6)

local function crearBoton(nombre, posY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 180, 0, 38)
    btn.Position = UDim2.new(0.5, -90, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(110, 0, 160)
    btn.BorderSizePixel = 0
    btn.Text = nombre
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.Gotham
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(180, 0, 255)
    s.Thickness = 1.5
    s.Parent = btn
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(150, 0, 210) end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(110, 0, 160) end)
    return btn
end

local btnVelocidad = crearBoton("🚀 Speed x2",   55)
local btnSalto     = crearBoton("⬆️ Super Salto", 105)
local btnVolar     = crearBoton("🦅 Volar",       155)
local btnInvisible = crearBoton("👻 Invisible",   205)
local btnReset     = crearBoton("🔄 Reset Todo",  260)

local volando = false
local invisible = false
local flyConnection = nil

local function getChar() return player.Character end

local function activarVuelo()
    local char = getChar()
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end
    hum.PlatformStand = true
    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bg.P = 1e4
    bg.Parent = root
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = root
    flyConnection = RunService.RenderStepped:Connect(function()
        if not volando then return end
        local cam = workspace.CurrentCamera
        local dir = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
        bv.Velocity = dir.Magnitude > 0 and dir.Unit * 40 or Vector3.new(0, 0, 0)
        bg.CFrame = cam.CFrame
    end)
end

local function desactivarVuelo()
    local char = getChar()
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if root then
            local bg = root:FindFirstChildOfClass("BodyGyro")
            local bv = root:FindFirstChildOfClass("BodyVelocity")
            if bg then bg:Destroy() end
            if bv then bv:Destroy() end
        end
        if hum then hum.PlatformStand = false end
    end
    if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
end

local function setInvisible(state)
    local char = getChar()
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.LocalTransparencyModifier = state and 1 or 0
        end
    end
    for _, acc in pairs(char:GetChildren()) do
        if acc:IsA("Accessory") then
            local handle = acc:FindFirstChild("Handle")
            if handle then handle.LocalTransparencyModifier = state and 1 or 0 end
        end
    end
end

btnVolar.MouseButton1Click:Connect(function()
    volando = not volando
    btnVolar.Text = volando and "🦅 Volar ✅" or "🦅 Volar"
    if volando then activarVuelo() else desactivarVuelo() end
end)

btnInvisible.MouseButton1Click:Connect(function()
    invisible = not invisible
    btnInvisible.Text = invisible and "👻 Invisible ✅" or "👻 Invisible"
    setInvisible(invisible)
end)

btnVelocidad.MouseButton1Click:Connect(function()
    local hum = getChar() and getChar():FindFirstChildOfClass("Humanoid")
    if not hum then return end
    hum.WalkSpeed = hum.WalkSpeed == 16 and 32 or 16
    btnVelocidad.Text = hum.WalkSpeed == 32 and "🚀 Speed x2 ✅" or "🚀 Speed x2"
end)

btnSalto.MouseButton1Click:Connect(function()
    local hum = getChar() and getChar():FindFirstChildOfClass("Humanoid")
    if not hum then return end
    hum.JumpPower = hum.JumpPower == 50 and 120 or 50
    btnSalto.Text = hum.JumpPower == 120 and "⬆️ Super Salto ✅" or "⬆️ Super Salto"
end)

btnReset.MouseButton1Click:Connect(function()
    volando = false
    invisible = false
    desactivarVuelo()
    setInvisible(false)
    local hum = getChar() and getChar():FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = 16; hum.JumpPower = 50 end
    btnVelocidad.Text = "🚀 Speed x2"
    btnSalto.Text = "⬆️ Super Salto"
    btnVolar.Text = "🦅 Volar"
    btnInvisible.Text = "👻 Invisible"
end)

player.CharacterAdded:Connect(function()
    volando = false
    invisible = false
    if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
    btnVolar.Text = "🦅 Volar"
    btnInvisible.Text = "👻 Invisible"
end)
