local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

local SPEED = 50
local TOGGLE_KEY = Enum.KeyCode.F

local flying = false
local bv, bg

local stickX, stickY = 0, 0
local touchId = nil
local stickOrigin = nil

UserInputService.TouchStarted:Connect(function(input, gpe)
    if not flying then return end
    if input.Position.X < workspace.CurrentCamera.ViewportSize.X / 2 then
        touchId = input
        stickOrigin = input.Position
    end
end)

UserInputService.TouchMoved:Connect(function(input, gpe)
    if not flying or touchId ~= input then return end
    local delta = input.Position - stickOrigin
    local radius = 80
    stickX = math.clamp(delta.X / radius, -1, 1)
    stickY = math.clamp(delta.Y / radius, -1, 1)
end)

UserInputService.TouchEnded:Connect(function(input)
    if touchId == input then
        touchId = nil
        stickOrigin = nil
        stickX, stickY = 0, 0
    end
end)

local function startFly()
    flying = true
    humanoid.PlatformStand = true

    bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Velocity = Vector3.zero
    bv.Parent = hrp

    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bg.P = 1000
    bg.D = 50
    bg.CFrame = hrp.CFrame
    bg.Parent = hrp
end

local function stopFly()
    flying = false
    humanoid.PlatformStand = false
    if bv then bv:Destroy() bv = nil end
    if bg then bg:Destroy() bg = nil end
    stickX, stickY = 0, 0
    touchId = nil
    stickOrigin = nil
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == TOGGLE_KEY then
        if flying then stopFly() else startFly() end
    end
end)

RunService.RenderStepped:Connect(function()
    if not flying or not bv or not bg then return end

    local cam = workspace.CurrentCamera
    local move = Vector3.zero

    if math.abs(stickY) > 0.05 then
        move += cam.CFrame.UpVector * (-stickY)
    end

    if math.abs(stickX) > 0.05 then
        move += cam.CFrame.RightVector * stickX
    end

    if Vector2.new(stickX, stickY).Magnitude > 0.05 then
        move += cam.CFrame.LookVector * 0.5
    end

    if UserInputService.KeyboardEnabled then
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            move += cam.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            move -= cam.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            move -= cam.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            move += cam.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            move += Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            move -= Vector3.new(0, 1, 0)
        end
    end

    if move.Magnitude > 0 then
        bv.Velocity = move.Unit * SPEED
    else
        bv.Velocity = Vector3.zero
    end

    bg.CFrame = cam.CFrame
end)

plr.CharacterRemoving:Connect(function()
    if flying then stopFly() end
end)
