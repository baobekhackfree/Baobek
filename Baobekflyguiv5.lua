
-- baobek Fly GUI V5 | Mobile
-- Roblox Studio - game you control
-- Camera-relative flight with mobile controls

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local flying = false
local speed = 50
local vertical = 0
local attachment, velocity, orientation
local flightConnection

local gui = Instance.new("ScreenGui")
gui.Name = "baobekFlyV5"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(280, 330)
panel.Position = UDim2.new(0, 16, 0.25, 0)
panel.BackgroundColor3 = Color3.fromRGB(24, 27, 38)
panel.BorderSizePixel = 0
panel.Parent = gui

Instance.new("UICorner", panel).CornerRadius =
    UDim.new(0, 14)

local function makeButton(text, position, size)
    local b = Instance.new("TextButton")
    b.Size = size or UDim2.new(1, -20, 0, 48)
    b.Position = position
    b.BackgroundColor3 = Color3.fromRGB(55, 65, 85)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextSize = 17
    b.Font = Enum.Font.GothamBold
    b.Text = text
    b.AutoButtonColor = true
    b.Parent = panel
    Instance.new("UICorner", b).CornerRadius =
        UDim.new(0, 10)
    return b
end

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -48, 0, 44)
title.Position = UDim2.fromOffset(12, 0)
title.BackgroundTransparency = 1
title.Text = "BAOBEK FLY V5"
title.TextColor3 = Color3.fromRGB(100, 220, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 19
title.Parent = panel

local minimize = makeButton(
    "−", UDim2.new(1, -42, 0, 5),
    UDim2.fromOffset(32, 32)
)

local toggle = makeButton(
    "FLY: OFF", UDim2.fromOffset(10, 52)
)

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, -20, 0, 28)
speedLabel.Position = UDim2.fromOffset(10, 105)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Tốc độ: 50"
speedLabel.TextColor3 = Color3.new(1, 1, 1)
speedLabel.TextSize = 16
speedLabel.Parent = panel

local slower = makeButton(
    "− Tốc độ", UDim2.fromOffset(10, 137),
    UDim2.new(0.48, -5, 0, 42)
)

local faster = makeButton(
    "+ Tốc độ", UDim2.new(0.52, 0, 0, 137),
    UDim2.new(0.48, -10, 0, 42)
)

local up = makeButton(
    "⬆ BAY LÊN", UDim2.fromOffset(10, 186)
)

local down = makeButton(
    "⬇ BAY XUỐNG", UDim2.fromOffset(10, 239)
)

local function stopFlight()
    flying = false
    vertical = 0

    if flightConnection then
        flightConnection:Disconnect()
        flightConnection = nil
    end

    if velocity then velocity:Destroy() end
    if orientation then orientation:Destroy() end
    if attachment then attachment:Destroy() end

    velocity, orientation, attachment = nil, nil, nil
    toggle.Text = "FLY: OFF"
    toggle.BackgroundColor3 = Color3.fromRGB(55, 65, 85)
end

local function startFlight()
    local character = player.Character
    local humanoid = character and
        character:FindFirstChildOfClass("Humanoid")
    local root = character and
        character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not root or humanoid.Health <= 0 then
        return
    end

    stopFlight()
    flying = true
    humanoid.AutoRotate = false

    attachment = Instance.new("Attachment")
    attachment.Parent = root

    velocity = Instance.new("LinearVelocity")
    velocity.Attachment0 = attachment
    velocity.RelativeTo = Enum.ActuatorRelativeTo.World
    velocity.VelocityConstraintMode =
        Enum.VelocityConstraintMode.Vector
    velocity.VectorVelocity = Vector3.zero
    velocity.MaxForce = 1000000
    velocity.Parent = root

    orientation = Instance.new("AlignOrientation")
    orientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
    orientation.Attachment0 = attachment
    orientation.Responsiveness = 15
    orientation.MaxTorque = 1000000
    orientation.Parent = root

    toggle.Text = "FLY: ON"
    toggle.BackgroundColor3 = Color3.fromRGB(25, 145, 95)

    flightConnection = RunService.RenderStepped:Connect(function()
        if not flying or not root.Parent then
            stopFlight()
            return
        end

        local camera = workspace.CurrentCamera
        if not camera then return end

        local move = humanoid.MoveDirection
        velocity.VectorVelocity =
            move * speed + Vector3.new(0, vertical * speed, 0)

        local look = camera.CFrame.LookVector
        local flatLook = Vector3.new(look.X, 0, look.Z)

        if flatLook.Magnitude > 0.001 then
            orientation.CFrame = CFrame.lookAt(
                root.Position,
                root.Position + flatLook.Unit
            )
        end
    end)
end

toggle.Activated:Connect(function()
    if flying then
        stopFlight()
    else
        startFlight()
    end
end)

slower.Activated:Connect(function()
    speed = math.max(10, speed - 10)
    speedLabel.Text = "Tốc độ: " .. speed
end)

faster.Activated:Connect(function()
    speed = math.min(150, speed + 10)
    speedLabel.Text = "Tốc độ: " .. speed
end)

local function bindVertical(button, value)
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
            vertical = value
        end
    end)

    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
            if vertical == value then
                vertical = 0
            end
        end
    end)
end

bindVertical(up, 1)
bindVertical(down, -1)

local minimized = false

minimize.Activated:Connect(function()
    minimized = not minimized

    for _, child in ipairs(panel:GetChildren()) do
        if child ~= title and child ~= minimize
            and not child:IsA("UICorner") then
            child.Visible = not minimized
        end
    end

    panel.Size = minimized
        and UDim2.fromOffset(280, 44)
        or UDim2.fromOffset(280, 330)

    minimize.Text = minimized and "+" or "−"
end)

player.CharacterAdded:Connect(function()
    stopFlight()
end)

local camera = workspace.CurrentCamera
if not camera then return end

local move = humanoid.MoveDirection
local direction

if controlMode == "Camera" then
    -- Hướng di chuyển theo camera, gồm cả lên/xuống
    local look = camera.CFrame.LookVector
    local right = camera.CFrame.RightVector

    direction =
        right * move:Dot(Vector3.new(right.X, 0, right.Z).Unit)
        + look * move:Dot(Vector3.new(look.X, 0, look.Z).Unit)
else
    -- Theo hướng di chuyển của nhân vật trên mặt phẳng
    direction = move
end

velocity.VectorVelocity =
    direction * speed + Vector3.new(0, vertical * speed, 0)
