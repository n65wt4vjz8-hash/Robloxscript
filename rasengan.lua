--[[ rasengan.lua - 螺旋丸（最終完全版） ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")

local plr = Players.LocalPlayer
local cam = workspace.CurrentCamera
local PlayerGui = plr:WaitForChild("PlayerGui")

local CHAKRA_COLOR = Color3.fromRGB(80, 180, 255)

-- ★ 音声ID
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
-- 爆発演出（超派手・衝撃波付き）
------------------------------------------------------------
local function explodeAt(pos, size)
    size = size or 2
    local scale = math.clamp(size / 2, 0.5, 10)

    -- ① 白い核
    local core = Instance.new("Part")
    core.Shape = Enum.PartType.Ball
    core.Size = Vector3.new(size * 0.5, size * 0.5, size * 0.5)
    core.Color = Color3.fromRGB(255, 255, 255)
    core.Material = Enum.Material.Neon
    core.Anchored = true
    core.CanCollide = false
    core.CastShadow = false
    core.CFrame = CFrame.new(pos)
    core.Parent = workspace

    local coreLight = Instance.new("PointLight")
    coreLight.Color = Color3.fromRGB(255, 255, 255)
    coreLight.Range = 60 * scale
    coreLight.Brightness = 15 * scale
    coreLight.Parent = core

    TweenService:Create(core, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(size * 3, size * 3, size * 3),
    }):Play()

    task.delay(0.15, function()
        TweenService:Create(core, TweenInfo.new(0.4), {
            Size = Vector3.new(0, 0, 0),
            Transparency = 1,
        }):Play()
        TweenService:Create(coreLight, TweenInfo.new(0.4), {Brightness = 0}):Play()
    end)

    task.delay(0.7, function()
        if core and core.Parent then core:Destroy() end
    end)

    -- ② 青い光球
    local boom = Instance.new("Part")
    boom.Shape = Enum.PartType.Ball
    boom.Size = Vector3.new(size, size, size)
    boom.Color = CHAKRA_COLOR
    boom.Material = Enum.Material.Neon
    boom.Anchored = true
    boom.CanCollide = false
    boom.CastShadow = false
    boom.CFrame = CFrame.new(pos)
    boom.Parent = workspace

    local bl = Instance.new("PointLight")
    bl.Color = CHAKRA_COLOR
    bl.Range = 45 * scale
    bl.Brightness = 8 * scale
    bl.Parent = boom

    TweenService:Create(boom, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(size * 10, size * 10, size * 10),
        Transparency = 1,
    }):Play()

    task.delay(0.7, function()
        if boom and boom.Parent then boom:Destroy() end
    end)

    -- ③ 多色パーティクル
    local COLORS = {
        Color3.fromRGB(80, 180, 255),
        Color3.fromRGB(150, 220, 255),
        Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(180, 130, 255),
    }

    local sparkCount = math.min(math.floor(40 * scale), 200)
    for i = 1, sparkCount do
        local spark = Instance.new("Part")
        spark.Shape = Enum.PartType.Ball
        spark.Size = Vector3.new(0.3, 0.3, 0.3) * (1 + scale * 0.2)
        spark.Color = COLORS[math.random(1, #COLORS)]
        spark.Material = Enum.Material.Neon
        spark.Anchored = true
        spark.CanCollide = false
        spark.CastShadow = false
        spark.CFrame = CFrame.new(pos)
        spark.Parent = workspace

        local dir = Vector3.new(
            math.random(-100, 100),
            math.random(-60, 100),
            math.random(-100, 100)
        ).Unit

        local dist = math.random(10, 25) * scale
        local target = pos + dir * dist

        TweenService:Create(spark, TweenInfo.new(
            math.random(60, 100) / 100,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ), {
            CFrame = CFrame.new(target),
            Size = Vector3.new(0, 0, 0),
            Transparency = 1,
        }):Play()

        task.delay(1, function()
            if spark and spark.Parent then spark:Destroy() end
        end)
    end

    -- ④ 3段リング
    for i = 1, 3 do
        local ring = Instance.new("Part")
        ring.Shape = Enum.PartType.Cylinder
        ring.Size = Vector3.new(0.2, 2, 2)
        ring.CFrame = CFrame.new(pos - Vector3.new(0, 0.5 * i, 0)) * CFrame.Angles(0, 0, math.rad(90))
        ring.Color = (i == 1 and Color3.fromRGB(255, 255, 255))
            or (i == 2 and CHAKRA_COLOR)
            or Color3.fromRGB(150, 220, 255)
        ring.Material = Enum.Material.Neon
        ring.Anchored = true
        ring.CanCollide = false
        ring.CastShadow = false
        ring.Transparency = 0.2
        ring.Parent = workspace

        task.delay(i * 0.08, function()
            TweenService:Create(ring, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = Vector3.new(0.2, 25 * scale, 25 * scale),
                Transparency = 1,
            }):Play()
        end)

        task.delay(1, function()
            if ring and ring.Parent then ring:Destroy() end
        end)
    end

    -- ⑤ 光の柱
    local pillar = Instance.new("Part")
    pillar.Size = Vector3.new(size * 1.5, 1, size * 1.5)
    pillar.Color = Color3.fromRGB(200, 230, 255)
    pillar.Material = Enum.Material.Neon
    pillar.Anchored = true
    pillar.CanCollide = false
    pillar.CastShadow = false
    pillar.Transparency = 0.3
    pillar.CFrame = CFrame.new(pos)
    pillar.Parent = workspace

    local pillarLight = Instance.new("PointLight")
    pillarLight.Color = Color3.fromRGB(200, 230, 255)
    pillarLight.Range = 50 * scale
    pillarLight.Brightness = 10 * scale
    pillarLight.Parent = pillar

    TweenService:Create(pillar, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(size * 1.5, 40 * scale, size * 1.5),
        Transparency = 1,
    }):Play()

    task.delay(0.6, function()
        if pillar and pillar.Parent then pillar:Destroy() end
    end)

    -- ⑥ 落雷
    if scale > 1.5 then
        for i = 1, math.floor(3 * scale) do
            task.delay(i * 0.05, function()
                local length = math.random(15, 30) * scale
                local angle = math.random() * math.pi * 2
                local dir = Vector3.new(math.cos(angle), 0.3, math.sin(angle)).Unit

                local bolt = Instance.new("Part")
                bolt.Size = Vector3.new(0.3, 0.3, length)
                bolt.Color = Color3.fromRGB(255, 255, 255)
                bolt.Material = Enum.Material.Neon
                bolt.Anchored = true
                bolt.CanCollide = false
                bolt.CastShadow = false
                bolt.Transparency = 0.2
                bolt.CFrame = CFrame.new(pos + dir * length / 2, pos + dir * length) * CFrame.Angles(math.pi/2, 0, 0)
                bolt.Parent = workspace

                local boltLight = Instance.new("PointLight")
                boltLight.Color = Color3.fromRGB(150, 220, 255)
                boltLight.Range = 30
                boltLight.Brightness = 5
                boltLight.Parent = bolt

                TweenService:Create(bolt, TweenInfo.new(0.3), {Transparency = 1}):Play()
                TweenService:Create(boltLight, TweenInfo.new(0.3), {Brightness = 0}):Play()

                task.delay(0.4, function()
                    if bolt and bolt.Parent then bolt:Destroy() end
                end)
            end)
        end
    end

    -- ⑦ エネルギードーム
    if scale > 2 then
        local dome = Instance.new("Part")
        dome.Shape = Enum.PartType.Ball
        dome.Size = Vector3.new(1, 1, 1)
        dome.Color = Color3.fromRGB(180, 230, 255)
        dome.Material = Enum.Material.ForceField
        dome.Anchored = true
        dome.CanCollide = false
        dome.CastShadow = false
        dome.Transparency = 0.2
        dome.CFrame = CFrame.new(pos)
        dome.Parent = workspace

        TweenService:Create(dome, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = Vector3.new(35 * scale, 35 * scale, 35 * scale),
            Transparency = 1,
        }):Play()

        task.delay(0.9, function()
            if dome and dome.Parent then dome:Destroy() end
        end)
    end

    -- ⑧ 焦げ跡
    local scorch = Instance.new("Part")
    scorch.Shape = Enum.PartType.Cylinder
    scorch.Size = Vector3.new(0.1, 7 * scale, 7 * scale)
    scorch.CFrame = CFrame.new(pos - Vector3.new(0, 1, 0)) * CFrame.Angles(0, 0, math.rad(90))
    scorch.Color = Color3.fromRGB(20, 20, 30)
    scorch.Material = Enum.Material.SmoothPlastic
    scorch.Anchored = true
    scorch.CanCollide = false
    scorch.CastShadow = false
    scorch.Transparency = 0.3
    scorch.Parent = workspace

    task.delay(4, function()
        if scorch and scorch.Parent then
            TweenService:Create(scorch, TweenInfo.new(1.5), {Transparency = 1}):Play()
            task.wait(1.6)
            scorch:Destroy()
        end
    end)

    -- ⑨ 画面色収差
    local cc = Instance.new("ColorCorrectionEffect")
    cc.Brightness = 0.5 * scale
    cc.Contrast = 0.3
    cc.Saturation = 1
    cc.TintColor = Color3.fromRGB(200, 230, 255)
    cc.Parent = Lighting

    task.delay(0.15, function()
        TweenService:Create(cc, TweenInfo.new(0.5), {
            Brightness = 0,
            Saturation = 0,
            TintColor = Color3.fromRGB(255, 255, 255),
        }):Play()
        task.wait(0.6)
        if cc and cc.Parent then cc:Destroy() end
    end)

    -- ⑩ カメラ揺れ
    task.spawn(function()
        local intensity = math.min(scale, 5)
        for i = 1, 20 do
            cam.CFrame = cam.CFrame * CFrame.Angles(
                math.rad(math.random(-30, 30) / 10 * intensity),
                math.rad(math.random(-30, 30) / 10 * intensity),
                math.rad(math.random(-30, 30) / 10 * intensity)
            )
            task.wait(0.02)
        end
    end)

    -- ⑪ 大衝撃波（地面を這って広がる）
    for i = 1, 2 do
        local wave = Instance.new("Part")
        wave.Shape = Enum.PartType.Cylinder
        wave.Size = Vector3.new(0.3, 4, 4)
        wave.CFrame = CFrame.new(pos - Vector3.new(0, 0.3 * i, 0)) * CFrame.Angles(0, 0, math.rad(90))
        wave.Color = (i == 1 and Color3.fromRGB(255, 255, 255)) or CHAKRA_COLOR
        wave.Material = Enum.Material.Neon
        wave.Anchored = true
        wave.CanCollide = false
        wave.CastShadow = false
        wave.Transparency = 0.1
        wave.Parent = workspace

        task.delay(i * 0.1, function()
            TweenService:Create(wave, TweenInfo.new(
                0.9 + i * 0.15,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            ), {
                Size = Vector3.new(0.3, 60 * scale, 60 * scale),
                Transparency = 1,
            }):Play()
        end)

        task.delay(1.5, function()
            if wave and wave.Parent then wave:Destroy() end
        end)
    end

    -- ⑫ 空気の歪み（ForceField球体が高速拡大）
    local distort = Instance.new("Part")
    distort.Shape = Enum.PartType.Ball
    distort.Size = Vector3.new(1, 1, 1)
    distort.Color = Color3.fromRGB(255, 255, 255)
    distort.Material = Enum.Material.ForceField
    distort.Anchored = true
    distort.CanCollide = false
    distort.CastShadow = false
    distort.Transparency = 0.4
    distort.CFrame = CFrame.new(pos)
    distort.Parent = workspace

    TweenService:Create(distort, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(50 * scale, 50 * scale, 50 * scale),
        Transparency = 1,
    }):Play()

    task.delay(0.6, function()
        if distort and distort.Parent then distort:Destroy() end
    end)

    -- ⑬ 周囲のオブジェクトを揺らす
    task.spawn(function()
        local radius = 30 * scale
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj.Anchored then
                local dist = (obj.Position - pos).Magnitude
                if dist < radius and dist > 0 then
                    local dir = (obj.Position - pos).Unit
                    local force = (1 - dist / radius) * 15 * scale
                    pcall(function()
                        local bv = Instance.new("BodyVelocity")
                        bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                        bv.Velocity = dir * force + Vector3.new(0, force * 0.5, 0)
                        bv.Parent = obj
                        task.delay(0.2, function()
                            if bv and bv.Parent then bv:Destroy() end
                        end)
                    end)
                end
            end
        end
    end)

    -- ⑭ 物理爆発
    local exp = Instance.new("Explosion")
    exp.BlastPressure = 0
    exp.BlastRadius = 0
    exp.Position = pos
    exp.ExplosionType = Enum.ExplosionType.NoCraters
    exp.Parent = workspace
end

------------------------------------------------------------
-- チャクラ玉を発射（無限に飛ぶ）
------------------------------------------------------------
local function fireBall(ball, fromCF)
    for _, c in ipairs(ball:GetChildren()) do
        if c:IsA("Weld") then c:Destroy() end
    end
    ball.Anchored = true

    local dir = cam.CFrame.LookVector
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
        local travel = elapsed * speed
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
                local finalSize = ball.Size.X
                ball:Destroy()
                explodeAt(hitPos, finalSize)

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

        local newSize = math.min(1.6 + (travel / 300) * 6.4, 8)
        ball.Size = Vector3.new(newSize, newSize, newSize)
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
-- チャージ開始
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
