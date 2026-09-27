--[[ rasengan.lua - 螺旋丸（体の前にチャクラ玉） ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")

local plr = Players.LocalPlayer
local cam = workspace.CurrentCamera
local PlayerGui = plr:WaitForChild("PlayerGui")

local CHAKRA_COLOR = Color3.fromRGB(80, 180, 255)
local SHOUT_SOUND_ID = "rbxassetid://138799059412090"

------------------------------------------------------------
-- 状態
------------------------------------------------------------
local ready = false
local charging = false
local ballModel = nil
local ballMain = nil
local ballSpinConn = nil
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
    s.Ended:Connect(function() s:Destroy() end)
    task.delay(5, function()
        if s and s.Parent then s:Destroy() end
    end)
end

------------------------------------------------------------
-- GUI
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
-- チャクラ玉を作る（体の前に配置）
------------------------------------------------------------
local function createChakraBall(char)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local model = Instance.new("Model")
    model.Name = "RasenganModel"

    -- ① Main
    local main = Instance.new("Part")
    main.Name = "Main"
    main.Shape = Enum.PartType.Ball
    main.Size = Vector3.new(1.8, 1.8, 1.8)
    main.Color = CHAKRA_COLOR
    main.Material = Enum.Material.Neon
    main.Transparency = 0.3
    main.Anchored = false
    main.CanCollide = false
    main.Massless = true
    main.Parent = model

    -- ★ 体の前に固定（HRP基準）
    local bodyWeld = Instance.new("Weld")
    bodyWeld.Name = "BodyWeld"
    bodyWeld.Part0 = hrp
    bodyWeld.Part1 = main
    bodyWeld.C0 = CFrame.new(0, 0.5, -3)   -- 前に3スタッド
    bodyWeld.Parent = main

    -- ② Core
    local core = Instance.new("Part")
    core.Name = "Core"
    core.Shape = Enum.PartType.Ball
    core.Size = Vector3.new(0.7, 0.7, 0.7)
    core.Color = Color3.fromRGB(255, 255, 255)
    core.Material = Enum.Material.Neon
    core.Anchored = false
    core.CanCollide = false
    core.Massless = true
    core.Parent = model

    local coreWeld = Instance.new("Weld")
    coreWeld.Part0 = main
    coreWeld.Part1 = core
    coreWeld.Parent = core

    local coreLight = Instance.new("PointLight")
    coreLight.Color = Color3.fromRGB(220, 245, 255)
    coreLight.Range = 18
    coreLight.Brightness = 10
    coreLight.Parent = core

    -- ③ Aura（メイン）
    local aura = Instance.new("Part")
    aura.Name = "Aura"
    aura.Shape = Enum.PartType.Ball
    aura.Size = Vector3.new(2.6, 2.6, 2.6)
    aura.Color = Color3.fromRGB(150, 220, 255)
    aura.Material = Enum.Material.ForceField
    aura.Transparency = 0.15
    aura.Anchored = false
    aura.CanCollide = false
    aura.Massless = true
    aura.Parent = model

    local auraWeld = Instance.new("Weld")
    auraWeld.Part0 = main
    auraWeld.Part1 = aura
    auraWeld.Parent = aura

    -- ④ オーラ層（3重）
    local auraLayers = {}
    for i = 1, 3 do
        local layer = Instance.new("Part")
        layer.Name = "AuraLayer" .. i
        layer.Shape = Enum.PartType.Ball
        local baseSize = 1.8 + i * 0.6
        layer.Size = Vector3.new(baseSize, baseSize, baseSize)
        layer.Color = (i == 1 and Color3.fromRGB(120, 200, 255))
            or (i == 2 and Color3.fromRGB(180, 130, 255))
            or Color3.fromRGB(100, 230, 255)
        layer.Material = Enum.Material.ForceField
        layer.Transparency = 0.55
        layer.Anchored = false
        layer.CanCollide = false
        layer.Massless = true
        layer.Parent = model

        local weld = Instance.new("Weld")
        weld.Part0 = main
        weld.Part1 = layer
        weld.Parent = layer

        table.insert(auraLayers, {
            part = layer,
            baseSize = baseSize,
            phase = i * math.pi / 1.5,
            speed = 1 + i * 0.4,
        })
    end

    -- ⑤ Rings
    local rings = {}
    for i = 1, 3 do
        local ring = Instance.new("Part")
        ring.Name = "Ring" .. i
        ring.Shape = Enum.PartType.Cylinder
        ring.Size = Vector3.new(0.12, 2.6, 2.6)
        ring.Color = (i == 1 and Color3.fromRGB(255, 255, 255))
            or (i == 2 and CHAKRA_COLOR)
            or Color3.fromRGB(200, 240, 255)
        ring.Material = Enum.Material.Neon
        ring.Transparency = 0.15
        ring.Anchored = false
        ring.CanCollide = false
        ring.Massless = true
        ring.Parent = model

        local weld = Instance.new("Weld")
        weld.Part0 = main
        weld.Part1 = ring
        weld.Parent = ring

        table.insert(rings, {part = ring, baseAngle = (i - 1) * math.pi / 3, speed = 4 + i * 2})
    end

    -- ⑥ Orbs
    local orbs = {}
    for i = 1, 5 do
        local orb = Instance.new("Part")
        orb.Name = "Orb" .. i
        orb.Shape = Enum.PartType.Ball
        orb.Size = Vector3.new(0.22, 0.22, 0.22)
        orb.Color = Color3.fromRGB(255, 255, 255)
        orb.Material = Enum.Material.Neon
        orb.Anchored = false
        orb.CanCollide = false
        orb.Massless = true
        orb.Parent = model

        local weld = Instance.new("Weld")
        weld.Part0 = main
        weld.Part1 = orb
        weld.Parent = orb

        local orbLight = Instance.new("PointLight")
        orbLight.Color = CHAKRA_COLOR
        orbLight.Range = 4
        orbLight.Brightness = 2
        orbLight.Parent = orb

        table.insert(orbs, {
            part = orb,
            angle = (i / 5) * math.pi * 2,
            orbitSpeed = 3 + math.random(),
            heightPhase = math.random() * math.pi * 2,
        })
    end

    -- ⑦ Sparks
    local sparks = {}
    for i = 1, 6 do
        local spark = Instance.new("Part")
        spark.Name = "Spark" .. i
        spark.Size = Vector3.new(0.08, 0.08, 1.0)
        spark.Color = Color3.fromRGB(220, 245, 255)
        spark.Material = Enum.Material.Neon
        spark.Transparency = 0.3
        spark.Anchored = false
        spark.CanCollide = false
        spark.Massless = true
        spark.Parent = model

        local weld = Instance.new("Weld")
        weld.Part0 = main
        weld.Part1 = spark
        weld.Parent = spark

        table.insert(sparks, {
            part = spark,
            angle = math.random() * math.pi * 2,
            speed = math.random(6, 15),
        })
    end

    -- ⑧ スパークルパーティクル
    local att = Instance.new("Attachment")
    att.Parent = main

    local emitter = Instance.new("ParticleEmitter")
    emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    emitter.Rate = 120
    emitter.Lifetime = NumberRange.new(0.4, 0.8)
    emitter.Speed = NumberRange.new(6, 12)
    emitter.SpreadAngle = Vector2.new(180, 180)
    emitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.7),
        NumberSequenceKeypoint.new(1, 0),
    })
    emitter.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.5, CHAKRA_COLOR),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 130, 255)),
    })
    emitter.LightEmission = 1
    emitter.Parent = att

    -- ⑨ チャクラの炎
    local flameAtt = Instance.new("Attachment")
    flameAtt.Parent = main

    local flame = Instance.new("ParticleEmitter")
    flame.Texture = "rbxasset://textures/particles/fire_main.dds"
    flame.Rate = 60
    flame.Lifetime = NumberRange.new(0.5, 1.0)
    flame.Speed = NumberRange.new(4, 10)
    flame.SpreadAngle = Vector2.new(180, 180)
    flame.Rotation = NumberRange.new(-180, 180)
    flame.RotSpeed = NumberRange.new(-90, 90)
    flame.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1.2),
        NumberSequenceKeypoint.new(0.5, 0.8),
        NumberSequenceKeypoint.new(1, 0),
    })
    flame.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 240, 255)),
        ColorSequenceKeypoint.new(0.5, CHAKRA_COLOR),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 50, 180)),
    })
    flame.LightEmission = 1
    flame.LightInfluence = 0
    flame.Parent = flameAtt

    -- ⑩ 立ち上るチャクラ
    local riseAtt = Instance.new("Attachment")
    riseAtt.Position = Vector3.new(0, -0.8, 0)
    riseAtt.Parent = main

    local rise = Instance.new("ParticleEmitter")
    rise.Texture = "rbxasset://textures/particles/smoke_main.dds"
    rise.Rate = 30
    rise.Lifetime = NumberRange.new(0.6, 1.2)
    rise.Speed = NumberRange.new(3, 6)
    rise.SpreadAngle = Vector2.new(15, 15)
    rise.Acceleration = Vector3.new(0, 4, 0)
    rise.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.6),
        NumberSequenceKeypoint.new(1, 1.4),
    })
    rise.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(1, 1),
    })
    rise.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, CHAKRA_COLOR),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 130, 255)),
    })
    rise.LightEmission = 0.8
    rise.Parent = riseAtt

    -- ⑪ 風の渦
    local swirlAtt = Instance.new("Attachment")
    swirlAtt.Parent = main

    local swirl = Instance.new("ParticleEmitter")
    swirl.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    swirl.Rate = 40
    swirl.Lifetime = NumberRange.new(0.4, 0.7)
    swirl.Speed = NumberRange.new(0.5, 1.5)
    swirl.SpreadAngle = Vector2.new(360, 360)
    swirl.Rotation = NumberRange.new(0, 360)
    swirl.RotSpeed = NumberRange.new(-360, 360)
    swirl.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(1, 0),
    })
    swirl.Color = ColorSequence.new(Color3.fromRGB(150, 220, 255))
    swirl.LightEmission = 1
    swirl.Parent = swirlAtt

    -- ⑫ Trails
    for _, p in ipairs({main, core}) do
        local a0 = Instance.new("Attachment")
        a0.Position = Vector3.new(0, p.Size.Y / 2, 0)
        a0.Parent = p
        local a1 = Instance.new("Attachment")
        a1.Position = Vector3.new(0, -p.Size.Y / 2, 0)
        a1.Parent = p

        local trail = Instance.new("Trail")
        trail.Attachment0 = a0
        trail.Attachment1 = a1
        trail.Lifetime = 0.4
        trail.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, CHAKRA_COLOR),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
        })
        trail.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.2),
            NumberSequenceKeypoint.new(1, 1),
        })
        trail.LightEmission = 1
        trail.Parent = p
    end

    model.PrimaryPart = main
    model.Parent = workspace

    -- 回転ループ
    local t0 = tick()
    local spinConn
    spinConn = RunService.Heartbeat:Connect(function(dt)
        if not model.Parent or not main.Parent then
            spinConn:Disconnect()
            return
        end

        local t = tick() - t0
        local baseCF = main.CFrame

        for i, r in ipairs(rings) do
            local angle = t * r.speed + r.baseAngle
            r.part.CFrame = baseCF * CFrame.Angles(
                math.cos(angle) * 0.7,
                math.sin(angle) * 0.7,
                angle
            )
        end

        for i, s in ipairs(sparks) do
            local angle = t * s.speed + s.angle
            s.part.CFrame = baseCF * CFrame.Angles(
                math.sin(angle * 1.3) * 2,
                math.cos(angle * 1.1) * 2,
                angle * 0.7
            )
            s.part.Transparency = 0.2 + math.random() * 0.6
        end

        for i, o in ipairs(orbs) do
            local angle = t * o.orbitSpeed + o.angle
            local height = math.sin(t * 2 + o.heightPhase) * 0.8
            local pos = Vector3.new(
                math.cos(angle) * 1.6,
                height,
                math.sin(angle) * 1.6
            )
            o.part.CFrame = baseCF * CFrame.new(pos)
            o.part.Color = Color3.fromHSV((t * 0.5 + i / #orbs) % 1, 0.6, 1)
        end

        local pulse = 1 + math.sin(t * 8) * 0.08
        core.Size = Vector3.new(0.7, 0.7, 0.7) * pulse
        aura.Size = Vector3.new(2.6, 2.6, 2.6) * (1 + math.sin(t * 3) * 0.05)

        for i, a in ipairs(auraLayers) do
            local layerPulse = 1 + math.sin(t * a.speed * 2 + a.phase) * 0.15
            a.part.Size = Vector3.new(a.baseSize, a.baseSize, a.baseSize) * layerPulse
            a.part.Transparency = 0.5 + math.sin(t * a.speed + a.phase) * 0.15
            a.part.CFrame = baseCF * CFrame.Angles(
                math.sin(t * a.speed) * 0.3,
                t * a.speed * 0.5,
                math.cos(t * a.speed) * 0.3
            )
        end

        if flame then
            flame.Rate = 50 + math.sin(t * 6) * 30
        end
        if swirl then
            swirl.Speed = NumberRange.new(0.5 + math.sin(t * 4) * 0.5, 2)
        end
    end)

    return model, main, spinConn, auraLayers
end

------------------------------------------------------------
-- 爆発演出（超派手）
------------------------------------------------------------
local function explodeAt(pos, size)
    size = size or 2
    local scale = math.clamp(size / 2, 0.5, 10)

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
            Size = Vector3.new(0, 0, 0), Transparency = 1,
        }):Play()
        TweenService:Create(coreLight, TweenInfo.new(0.4), {Brightness = 0}):Play()
    end)
    task.delay(0.7, function()
        if core and core.Parent then core:Destroy() end
    end)

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
        Size = Vector3.new(size * 10, size * 10, size * 10), Transparency = 1,
    }):Play()
    task.delay(0.7, function()
        if boom and boom.Parent then boom:Destroy() end
    end)

    local COLORS = {
        Color3.fromRGB(80, 180, 255), Color3.fromRGB(150, 220, 255),
        Color3.fromRGB(255, 255, 255), Color3.fromRGB(180, 130, 255),
    }
    local sparkCount = math.min(math.floor(40 * scale), 150)
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

        local dir = Vector3.new(math.random(-100,100), math.random(-60,100), math.random(-100,100)).Unit
        local target = pos + dir * math.random(10, 25) * scale

        TweenService:Create(spark, TweenInfo.new(
            math.random(60, 100) / 100, Enum.EasingStyle.Quad, Enum.EasingDirection.Out
        ), {
            CFrame = CFrame.new(target),
            Size = Vector3.new(0, 0, 0),
            Transparency = 1,
        }):Play()
        task.delay(1, function()
            if spark and spark.Parent then spark:Destroy() end
        end)
    end

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
                Size = Vector3.new(0.2, 25 * scale, 25 * scale), Transparency = 1,
            }):Play()
        end)
        task.delay(1, function()
            if ring and ring.Parent then ring:Destroy() end
        end)
    end

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
        Size = Vector3.new(size * 1.5, 40 * scale, size * 1.5), Transparency = 1,
    }):Play()
    task.delay(0.6, function()
        if pillar and pillar.Parent then pillar:Destroy() end
    end)

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

                local bl2 = Instance.new("PointLight")
                bl2.Color = Color3.fromRGB(150, 220, 255)
                bl2.Range = 30
                bl2.Brightness = 5
                bl2.Parent = bolt

                TweenService:Create(bolt, TweenInfo.new(0.3), {Transparency = 1}):Play()
                TweenService:Create(bl2, TweenInfo.new(0.3), {Brightness = 0}):Play()
                task.delay(0.4, function()
                    if bolt and bolt.Parent then bolt:Destroy() end
                end)
            end)
        end
    end

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
            Size = Vector3.new(35 * scale, 35 * scale, 35 * scale), Transparency = 1,
        }):Play()
        task.delay(0.9, function()
            if dome and dome.Parent then dome:Destroy() end
        end)
    end

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

    local cc = Instance.new("ColorCorrectionEffect")
    cc.Brightness = 0.5 * scale
    cc.Contrast = 0.3
    cc.Saturation = 1
    cc.TintColor = Color3.fromRGB(200, 230, 255)
    cc.Parent = Lighting

    task.delay(0.15, function()
        TweenService:Create(cc, TweenInfo.new(0.5), {
            Brightness = 0, Saturation = 0, TintColor = Color3.fromRGB(255, 255, 255),
        }):Play()
        task.wait(0.6)
        if cc and cc.Parent then cc:Destroy() end
    end)

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
            TweenService:Create(wave, TweenInfo.new(0.9 + i * 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = Vector3.new(0.3, 60 * scale, 60 * scale), Transparency = 1,
            }):Play()
        end)
        task.delay(1.5, function()
            if wave and wave.Parent then wave:Destroy() end
        end)
    end

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
        Size = Vector3.new(50 * scale, 50 * scale, 50 * scale), Transparency = 1,
    }):Play()
    task.delay(0.6, function()
        if distort and distort.Parent then distort:Destroy() end
    end)

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

    local exp = Instance.new("Explosion")
    exp.BlastPressure = 0
    exp.BlastRadius = 0
    exp.Position = pos
    exp.ExplosionType = Enum.ExplosionType.NoCraters
    exp.Parent = workspace
end

------------------------------------------------------------
-- 発射（無限・サイズ拡大）
------------------------------------------------------------
local function fireBall(model, main, spinConn, fromCF)
    if spinConn then spinConn:Disconnect() end

    -- Weldを外す（BodyWeldも含む）
    for _, p in ipairs(model:GetDescendants()) do
        if p:IsA("BasePart") then
            for _, w in ipairs(p:GetChildren()) do
                if w:IsA("Weld") and (w.Name == "BodyWeld" or w.Name == "HandWeld") then
                    w:Destroy()
                end
            end
            p.Anchored = true
        end
    end

    local dir = cam.CFrame.LookVector
    local speed = 180
    local startTime = tick()
    local lastPos = main.Position
    local hit = false

    local conn
    conn = RunService.RenderStepped:Connect(function(dt)
        if hit then conn:Disconnect() return end
        if not model.Parent or not main.Parent then conn:Disconnect() return end

        local elapsed = tick() - startTime
        local travel = elapsed * speed
        local newPos = fromCF.Position + dir * travel

        local rayDir = newPos - lastPos
        local rayLen = rayDir.Magnitude
        if rayLen > 0.01 then
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = {model, plr.Character}

            local result = workspace:Raycast(lastPos, rayDir.Unit * rayLen, params)
            if result then
                hit = true
                local hitPos = result.Position
                model:Destroy()
                explodeAt(hitPos, 8)

                local m = result.Instance:FindFirstAncestorOfClass("Model")
                if m then
                    local hum = m:FindFirstChildOfClass("Humanoid")
                    if hum then
                        pcall(function() hum.Health = 0 end)
                    end
                end
                return
            end
        end

        lastPos = newPos

        local newCF = CFrame.new(newPos) * CFrame.Angles(0, elapsed * 30, 0)
        model:PivotTo(newCF)

        local sizeRatio = math.min(travel / 300, 1)
        local scale = 1 + sizeRatio * 3.5
        for _, p in ipairs(model:GetDescendants()) do
            if p:IsA("BasePart") then
                if p.Name == "Main" then
                    p.Size = Vector3.new(1.8, 1.8, 1.8) * scale
                elseif p.Name == "Core" then
                    p.Size = Vector3.new(0.7, 0.7, 0.7) * scale
                elseif p.Name == "Aura" then
                    p.Size = Vector3.new(2.6, 2.6, 2.6) * scale
                elseif p.Name:find("AuraLayer") then
                    local n = tonumber(p.Name:match("%d+")) or 1
                    local base = 1.8 + n * 0.6
                    p.Size = Vector3.new(base, base, base) * scale
                elseif p.Name:find("Ring") then
                    p.Size = Vector3.new(0.12, 2.6, 2.6) * scale
                elseif p.Name:find("Orb") then
                    p.Size = Vector3.new(0.22, 0.22, 0.22) * scale
                elseif p.Name:find("Spark") then
                    p.Size = Vector3.new(0.08, 0.08, 1.0) * scale
                end
            end
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

    plr.CameraMode = Enum.CameraMode.Classic
end

------------------------------------------------------------
-- チャージ開始（ONで一人称に）
------------------------------------------------------------
local function startCharge()
    if charging then return end
    local char = plr.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    charging = true

    plr.CameraMode = Enum.CameraMode.LockFirstPerson

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

    local model, main, spinConn = createChakraBall(char)
    ballModel = model
    ballMain = main
    ballSpinConn = spinConn

    local chargeConn
    chargeConn = RunService.Heartbeat:Connect(function(dt)
        if not ballModel or not ballModel.Parent then
            chargeConn:Disconnect()
            return
        end

        if chargeGyro and chargeGyro.Parent and hrp and hrp.Parent then
            chargeGyro.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, chargeYaw, 0)
        end

        if chargePos and chargePos.Parent then
            chargePos.Position = chargePos.Position
        end
    end)

    task.delay(3, function()
        if chargeConn then chargeConn:Disconnect() end

        local fireFrom = ballMain and ballMain.CFrame or hrp.CFrame

        releasePlayer()

        if ballMain and ballModel and ballModel.Parent then
            fireBall(ballModel, ballMain, ballSpinConn, fireFrom)
        end
        ballModel = nil
        ballMain = nil
        ballSpinConn = nil
        charging = false
    end)
end

------------------------------------------------------------
-- ボタン
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
        if ballModel and ballModel.Parent then ballModel:Destroy() end
        ballModel = nil
        ballMain = nil
        ballSpinConn = nil
        charging = false
        releasePlayer()
    end
end)

------------------------------------------------------------
-- キャラ変更でリセット
------------------------------------------------------------
plr.CharacterAdded:Connect(function()
    if ballModel and ballModel.Parent then ballModel:Destroy() end
    ballModel = nil
    ballMain = nil
    ballSpinConn = nil
    charging = false
    ready = false
    btn.Text = "螺旋丸: OFF"
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    task.wait(0.5)
    releasePlayer()
end)

print("[Rasengan] 体の前チャクラ玉版起動")
