
-- Delta Fly Script
local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local flying = false
local speed = 60
local linear, align, attach, conn

local gui = Instance.new("ScreenGui")
gui.Name = "DeltaFly"
gui.ResetOnSpawn = false
pcall(function() gui.Parent = CoreGui end)
if not gui.Parent then gui.Parent = player:WaitForChild("PlayerGui") end

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 160, 0, 90)
frame.Position = UDim2.new(0, 20, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 24)
title.BackgroundTransparency = 1
title.Text = "Fly (Delta)"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = frame

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0.9, 0, 0, 32)
btn.Position = UDim2.new(0.05, 0, 0.32, 0)
btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
btn.Text = "OFF"
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 14
btn.Parent = frame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = btn

local function startFly()
    if flying then return end
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    flying = true
    hum.PlatformStand = true

    attach = Instance.new("Attachment")
    attach.Parent = hrp

    linear = Instance.new("LinearVelocity")
    linear.Attachment0 = attach
    linear.MaxForce = math.huge
    linear.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    linear.RelativeTo = Enum.ActuatorRelativeTo.World
    linear.VectorVelocity = Vector3.zero
    linear.Parent = hrp

    align = Instance.new("AlignOrientation")
    align.Attachment0 = attach
    align.Mode = Enum.OrientationAlignmentMode.OneAttachment
    align.MaxTorque = math.huge
    align.Responsiveness = 50
    align.Parent = hrp

    conn = RunService.RenderStepped:Connect(function()
        if not flying then return end
        local cam = workspace.CurrentCamera
        local dir = Vector3.zero

        if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.yAxis end

        if dir.Magnitude > 0 then
            linear.VectorVelocity = dir.Unit * speed
        else
            linear.VectorVelocity = Vector3.zero
        end

        align.CFrame = cam.CFrame
    end)

    btn.Text = "ON"
    btn.BackgroundColor3 = Color3.fromRGB(0, 170, 90)
end

local function stopFly()
    if not flying then return end
    flying = false

    if conn then conn:Disconnect() conn = nil end
    if linear then linear:Destroy() linear = nil end
    if align then align:Destroy() align = nil end
    if attach then attach:Destroy() attach = nil end

    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = false end

    btn.Text = "OFF"
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
end

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        if flying then stopFly() else startFly() end
    end
end)

btn.MouseButton1Click:Connect(function()
    if flying then stopFly() else startFly() end
end)

player.CharacterAdded:Connect(function()
    if flying then stopFly() end
end)
