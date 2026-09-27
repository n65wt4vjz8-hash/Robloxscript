--[[ rasengan.lua - 螺旋丸（ONで音が鳴る版） ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local plr = Players.LocalPlayer
local cam = workspace.CurrentCamera
local PlayerGui = plr:WaitForChild("PlayerGui")

local CHAKRA_COLOR = Color3.fromRGB(80, 180, 255)

-- ★ ここに取得した音声IDを設定
local SHOUT_SOUND_ID = "rbxassetid://138799059412090"

------------------------------------------------------------
-- 状態
------------------------------------------------------------
local ready = false
local charging = false
local ball = nil
local chargeGyro = nil
local chargePos = nil
local chargeYaw = 0

------------------------------------------------------------
-- サウンド再生
------------------------------------------------------------
local function playShout()
    local s = Instance.new("Sound")
    s.SoundId = SHOUT_SOUND_ID
    s.Volume = 5
    s.PlaybackSpeed = 1
    s.Parent = SoundService
    s:Play()

    s.Ended:Connect(function()
        s:Destroy()
    end)

    task.delay(5, function()
        if s and s.Parent then s:Destroy() end
    end)
end

------------------------------------------------------------
-- GUI（ON/OFFボタン）
------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "RasenganGui"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 140, 0, 55)
btn.Position = UDim2.new(0.05, 0, 0.4, 0)
btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.Text = "螺旋丸: OFF"
btn.TextSize = 15
btn.Font = Enum.Font.GothamBold
btn.BorderSizePixel = 0
btn.Active = true
btn.Draggable = true
btn.Parent = gui
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)

------------------------------------------------------------
-- チャクラ玉を作る
------------------------------------------------------------
local function createChakraBall(hand)
    local r = Instance.new("Part")
    r.Name = "Rasengan"
    r.Shape = Enum.PartType.Ball
    r.Size = Vector3.new(1.6, 1.6, 1.6)
    r.Color = CHAKRA_COLOR
    r.Material = Enum.Material.Neon
    r.Transparency = 0.25
    r.Anchored = false
    r.CanCollide = false
    r.Massless = true
    r.Parent = workspace

    local weld = Instance.new("Weld")
    weld.Part0 = hand
    weld.Part1 = r
    weld.C0 = CFrame.new(0, -1.2, 0)
    weld.Parent = r

    local pl = Instance.new("PointLight")
    pl.Color = CHAKRA_COLOR
    pl.Range = 12
    pl.Brightness = 3
    pl.Parent = r

    local att = Instance.new("Attachment")
    att.Parent = r
    local emitter = Instance.new("ParticleEmitter")
    emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    emitter.Rate = 80
    emitter.Lifetime = NumberRange.new(0.3, 0.6)
    emitter.Speed = NumberRange.new(5, 12)
    emitter.SpreadAngle = Vector2.new(180, 180)
    emitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.6),
        NumberSequenceKeypoint.new(1, 0),
    })
    emitter.Color = ColorSequence.new(CHAKRA_COLOR)
    emitter.LightEmission = 1
    emitter.Parent = att

    return r
end

------------------------------------------------------------
-- 爆発演出
------------------------------------------------------------
local function explodeAt(pos)
    local boom = Instance.new("Part")
    boom.Shape = Enum.PartType.Ball
    boom.Size = Vector3.new(2, 2, 2)
    boom.Color = CHAKRA_COLOR
    boom.Material = Enum.Material.Neon
    boom.Anchored = true
    boom.CanCollide = false
    boom.CastShadow = false
    boom.CFrame = CFrame.new(pos)
    boom.Parent = workspace

    local bl = Instance.new("PointLight")
    bl.Color = CHAKRA_COLOR
    bl.Range = 35
    bl.Brightness = 6
    bl.Parent = boom

    TweenService:Create(boom, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(15, 15, 15),
        Transparency = 1,
    }):Play()

    task.delay(0.6, function()
        if boom and boom.Parent then boom:Destroy() end
    end)

    local flash = Instance.new("Part")
    flash.Shape = Enum.PartType.Ball
    flash.Size = Vector3.new(1, 1, 1)
    flash.Color = Color3.fromRGB(255, 255, 255)
    flash.Material = Enum.Material.Neon
    flash.Anchored = true
    flash.CanCollide = false
    flash.CastShadow = false
    flash.CFrame = CFrame.new(pos)
    flash.Parent = workspace

    TweenService:Create(flash, TweenInfo.new(0.3), {
        Size = Vector3.new(6, 6, 6),
        Transparency = 1,
    }):Play()

    task.delay(0.4, function()
        if flash and flash.Parent then flash:Destroy() end
    end)

    for i = 1, 20 do
        local spark = Instance.new("Part")
        spark.Shape = Enum.PartType.Ball
        spark.Size = Vector3.new(0.4, 0.4, 0.4)
        spark.Color = CHAKRA_COLOR
        spark.Material = Enum.Material.Neon
        spark.Anchored = true
        spark.CanCollide = false
        spark.CastShadow = false
        spark.CFrame = CFrame.new(pos)
        spark.Parent = workspace

        local dir = Vector3.new(
            math.random(-100, 100),
            math.random(-50, 100),
            math.random(-100, 100)
        ).Unit

        local target = pos + dir * math.random(8, 18)

        TweenService:Create(spark, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            CFrame = CFrame.new(target),
            Size = Vector3.new(0, 0, 0),
            Transparency = 1,
        }):Play()

        task.delay(0.8, function()
            if spark and spark.Parent then spark:Destroy() end
        end)
    end

    local ring = Instance.new("Part")
    ring.Shape = Enum.PartType.Cylinder
    ring.Size = Vector3.new(0.2, 2, 2)
    ring.CFrame = CFrame.new(pos) * CFrame.Angles(0, 0, math.rad(90))
    ring.Color = CHAKRA_COLOR
    ring.Material = Enum.Material.Neon
    ring.Anchored = true
    ring.CanCollide = false
    ring.CastShadow = false
    ring.Transparency = 0.3
    ring.Parent = workspace

    TweenService:Create(ring, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(0.2, 20, 20),
        Transparency = 1,
    }):Play()

    task.delay(0.6, function()
        if ring and ring.Parent then ring:Destroy() end
    end)

    local scorch = Instance.new("Part")
    scorch.Shape = Enum.PartType.Cylinder
    scorch.Size = Vector3.new(0.1, 6, 6)
    scorch.CFrame = CFrame.new(pos - Vector3.new(0, 1, 0)) * CFrame.Angles(0, 0, math.rad(90))
    scorch.Color = Color3.fromRGB(30, 30, 40)
    scorch.Material = Enum.Material.SmoothPlastic
    scorch.Anchored = true
    scorch.CanCollide = false
    scorch.CastShadow = false
    scorch.Transparency = 0.4
    scorch.Parent = workspace

    task.delay(3, function()
        if scorch and scorch.Parent then
            TweenService:Create(scorch, TweenInfo.new(1), {Transparency = 1}):Play()
            task.wait(1.1)
            scorch:Destroy()
        end
    end)

    local exp = Instance.new("Explosion")
    exp.BlastPressure = 0
    exp.BlastRadius = 0
    exp.Position = pos
    exp.ExplosionType = Enum.ExplosionType.NoCraters
    exp.Parent = workspace
end

------------------------------------------------------------
-- チャクラ玉を発射（※音は鳴らさない）
------------------------------------------------------------
local function fireBall(ball, fromCF)
    for _, c in ipairs(ball:GetChildren()) do
        if c:IsA("Weld") then c:Destroy() end
    end
    ball.Anchored = true

    local dir = cam.CFrame.LookVector
    local distance = 300
    local speed = 180
    local startTime = tick()
    local lastPos = fromCF.Position
    local hit = false

    local conn
    conn = RunService.RenderStepped:Connect(function(dt)
        if hit then
            conn:Disconnect()
            return
        end
        if not ball or not ball.Parent then
            conn:Disconnect()
            return
        end

        local elapsed = tick() - startTime
        local travel = math.min(elapsed * speed, distance)
        local newPos = fromCF.Position + dir * travel

        local rayDir = newPos - lastPos
        local rayLen = rayDir.Magnitude
        if rayLen > 0.01 then
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = {ball, plr.Character}

            local result = workspace:Raycast(lastPos, rayDir.Unit * rayLen, params)
            if result then
                hit = true
                local hitPos = result.Position
                ball:Destroy()
                explodeAt(hitPos)

                local model = result.Instance:FindFirstAncestorOfClass("Model")
                if model then
                    local hum = model:FindFirstChildOfClass("Humanoid")
                    if hum then
                        pcall(function() hum.Health = 0 end)
                    end
                end
                return
            end
        end

        lastPos = newPos
        ball.CFrame = CFrame.new(newPos) * CFrame.Angles(0, elapsed * 30, 0)

        if travel >= distance then
            hit = true
            conn:Disconnect()
            local endPos = ball.Position
            ball:Destroy()
            explodeAt(endPos)
        end
    end)
end

------------------------------------------------------------
-- 解放処理
------------------------------------------------------------
local function releasePlayer()
    local char = plr.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")

    if chargeGyro and chargeGyro.Parent then chargeGyro:Destroy() end
    chargeGyro = nil

    if hrp then
        local bp = hrp:FindFirstChildOfClass("BodyPosition")
        if bp then bp:Destroy() end
    end

    if hum then
        hum.PlatformStand = false
        hum.WalkSpeed = 16
        hum.JumpPower = 50
    end
end

------------------------------------------------------------
-- チャージ開始（ONで音が鳴る）
------------------------------------------------------------
local function startCharge()
    if charging then return end
    local char = plr.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hand = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightHand")
    if not hrp or not hum or not hand then return end

    charging = true

    -- ★ ここで音声を鳴らす
    playShout()

    local camLook = cam.CFrame.LookVector
    local flat = Vector3.new(camLook.X, 0, camLook.Z)
    if flat.Magnitude > 0.01 then
        chargeYaw = math.atan2(flat.X, flat.Z)
    else
        chargeYaw = 0
    end

    chargeGyro = Instance.new("BodyGyro")
    chargeGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    chargeGyro.P = 1e5
    chargeGyro.D = 500
    chargeGyro.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, chargeYaw, 0)
    chargeGyro.Parent = hrp

    chargePos = Instance.new("BodyPosition")
    chargePos.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    chargePos.P = 1e5
    chargePos.D = 1000
    chargePos.Position = hrp.Position
    chargePos.Parent = hrp

    hum.WalkSpeed = 0
    hum.JumpPower = 0
    hum.PlatformStand = true

    ball = createChakraBall(hand)

    local chargeConn
    chargeConn = RunService.Heartbeat:Connect(function(dt)
        if not ball or not ball.Parent then
            chargeConn:Disconnect()
            return
        end

        ball.CFrame = ball.CFrame * CFrame.Angles(0, dt * 30, 0)

        if chargeGyro and chargeGyro.Parent and hrp and hrp.Parent then
            chargeGyro.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, chargeYaw, 0)
        end

        if chargePos and chargePos.Parent then
            chargePos.Position = chargePos.Position
        end
    end)

    task.delay(3, function()
        if chargeConn then chargeConn:Disconnect() end

        local fireFrom = ball and ball.CFrame or hrp.CFrame

        releasePlayer()

        if ball and ball.Parent then
            fireBall(ball, fireFrom)
        end
        ball = nil
        charging = false
    end)
end

------------------------------------------------------------
-- ボタン押下
------------------------------------------------------------
btn.MouseButton1Click:Connect(function()
    ready = not ready

    if ready then
        btn.Text = "螺旋丸: ON"
        btn.BackgroundColor3 = Color3.fromRGB(30, 120, 200)
        startCharge()
    else
        btn.Text = "螺旋丸: OFF"
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)

        if ball and ball.Parent then ball:Destroy() end
        ball = nil
        charging = false
        releasePlayer()
    end
end)

------------------------------------------------------------
-- キャラ変更でリセット
------------------------------------------------------------
plr.CharacterAdded:Connect(function()
    if ball and ball.Parent then ball:Destroy() end
    ball = nil
    charging = false
    ready = false
    btn.Text = "螺旋丸: OFF"
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)

    task.wait(0.5)
    releasePlayer()
end)

print("[Rasengan] ボタンを押すと音が鳴って螺旋丸をチャージします")
