--[[ goukakyuu.lua - 豪火球（ON/OFFボタン・比例拡大・高速回転版） ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")

local plr = Players.LocalPlayer
local cam = workspace.CurrentCamera
local PlayerGui = plr:WaitForChild("PlayerGui")

-- 赤系パレット
local C_WHITE   = Color3.fromRGB(255, 250, 220)
local C_YELLOW  = Color3.fromRGB(255, 220, 100)
local C_ORANGE  = Color3.fromRGB(255, 140, 20)
local C_ORANGE2 = Color3.fromRGB(255, 90, 0)
local C_RED     = Color3.fromRGB(220, 30, 0)
local C_DEEP    = Color3.fromRGB(140, 10, 0)

------------------------------------------------------------
-- 状態
------------------------------------------------------------
local ready = false
local charging = false
local fireModel = nil
local fireMain = nil
local fireSpinConn = nil
local fireEffects = nil
local chargeGyro = nil
local chargePos = nil
local chargeYaw = 0

------------------------------------------------------------
-- GUI（ON/OFFボタン）
------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "GoukakyuuGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.Parent = PlayerGui

local btn = Instance.new("TextButton")
btn.Name = "ToggleButton"
btn.Size = UDim2.new(0, 160, 0, 60)
btn.Position = UDim2.new(0.05, 0, 0.4, 0)
btn.BackgroundColor3 = Color3.fromRGB(40, 10, 5)
btn.TextColor3 = Color3.fromRGB(255, 200, 150)
btn.Text = "豪火球: OFF"
btn.TextSize = 16
btn.Font = Enum.Font.GothamBold
btn.BorderSizePixel = 0
btn.Active = true
btn.Draggable = true
btn.ZIndex = 10
btn.Parent = gui
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)

-- ボタンの縁を赤く光らせる
local btnStroke = Instance.new("UIStroke")
btnStroke.Thickness = 2
btnStroke.Color = C_ORANGE
btnStroke.Parent = btn

-- ボタンのアイコン（炎の絵文字）
btn.Text = "🔥 豪火球: OFF"

------------------------------------------------------------
-- 火球を作る（比例拡大・高速回転対応）
------------------------------------------------------------
local function createFireball(char)
    local head = char:FindFirstChild("Head")
    if not head then return nil end

    local model = Instance.new("Model")
    model.Name = "GoukakyuuModel"

    -- Core
    local core = Instance.new("Part")
    core.Name = "Core"
    core.Shape = Enum.PartType.Ball
    core.Size = Vector3.new(0.5, 0.5, 0.5)
    core.Color = C_WHITE
    core.Material = Enum.Material.Neon
    core.Anchored = false
    core.CanCollide = false
    core.Massless = true
    core.Parent = model

    local coreLight = Instance.new("PointLight")
    coreLight.Color = C_YELLOW
    coreLight.Range = 30
    coreLight.Brightness = 12
    coreLight.Parent = core

    -- Mid
    local mid = Instance.new("Part")
    mid.Name = "Mid"
    mid.Shape = Enum.PartType.Ball
    mid.Size = Vector3.new(1.0, 1.0, 1.0)
    mid.Color = C_ORANGE
    mid.Material = Enum.Material.Neon
    mid.Transparency = 0.15
    mid.Anchored = false
    mid.CanCollide = false
    mid.Massless = true
    mid.Parent = model

    -- Main
    local main = Instance.new("Part")
    main.Name = "Main"
    main.Shape = Enum.PartType.Ball
    main.Size = Vector3.new(1.5, 1.5, 1.5)
    main.Color = C_ORANGE2
    main.Material = Enum.Material.Neon
    main.Transparency = 0.3
    main.Anchored = false
    main.CanCollide = false
    main.Massless = true
    main.Parent = model

    local mouthWeld = Instance.new("Weld")
    mouthWeld.Name = "MouthWeld"
    mouthWeld.Part0 = head
    mouthWeld.Part1 = main
    mouthWeld.C0 = CFrame.new(0, -0.3, -1.2)
    mouthWeld.Parent = main

    -- Shell
    local shell = Instance.new("Part")
    shell.Name = "Shell"
    shell.Shape = Enum.PartType.Ball
    shell.Size = Vector3.new(2.2, 2.2, 2.2)
    shell.Color = C_RED
    shell.Material = Enum.Material.ForceField
    shell.Transparency = 0.4
    shell.Anchored = false
    shell.CanCollide = false
    shell.Massless = true
    shell.Parent = model

    -- Heat
    local heat = Instance.new("Part")
    heat.Name = "Heat"
    heat.Shape = Enum.PartType.Ball
    heat.Size = Vector3.new(3.0, 3.0, 3.0)
    heat.Color = C_DEEP
    heat.Material = Enum.Material.ForceField
    heat.Transparency = 0.7
    heat.Anchored = false
    heat.CanCollide = false
    heat.Massless = true
    heat.Parent = model

    -- Vortex
    local vortices = {}
    for i = 1, 4 do
        local v = Instance.new("Part")
        v.Name = "Vortex" .. i
        v.Shape = Enum.PartType.Cylinder
        v.Size = Vector3.new(0.15, 2.4, 2.4)
        v.Color = (i == 1 and C_WHITE) or (i == 2 and C_ORANGE) or (i == 3 and C_RED) or C_DEEP
        v.Material = Enum.Material.Neon
        v.Transparency = 0.2
        v.Anchored = false
        v.CanCollide = false
        v.Massless = true
        v.Parent = model

        local w = Instance.new("Weld")
        w.Part0 = main
        w.Part1 = v
        w.Parent = v

        table.insert(vortices, {part = v, baseAngle = (i - 1) * math.pi / 2, speed = 8 + i * 3})
    end

    -- Ember
    local embers = {}
    for i = 1, 8 do
        local e = Instance.new("Part")
        e.Name = "Ember" .. i
        e.Shape = Enum.PartType.Ball
        e.Size = Vector3.new(0.15, 0.15, 0.15)
        e.Color = C_YELLOW
        e.Material = Enum.Material.Neon
        e.Anchored = false
        e.CanCollide = false
        e.Massless = true
        e.Parent = model

        local w = Instance.new("Weld")
        w.Part0 = main
        w.Part1 = e
        w.Parent = e

        local el = Instance.new("PointLight")
        el.Color = C_ORANGE
        el.Range = 5
        el.Brightness = 3
        el.Parent = e

        table.insert(embers, {
            part = e,
            angle = (i / 8) * math.pi * 2,
            orbitSpeed = 5 + math.random() * 3,
            heightPhase = math.random() * math.pi * 2,
        })
    end

    -- 炎パーティクル
    local att = Instance.new("Attachment")
    att.Parent = main

    local fireEmitter = Instance.new("ParticleEmitter")
    fireEmitter.Texture = "rbxasset://textures/particles/fire_main.dds"
    fireEmitter.Rate = 250
    fireEmitter.Lifetime = NumberRange.new(0.5, 1.0)
    fireEmitter.Speed = NumberRange.new(10, 20)
    fireEmitter.SpreadAngle = Vector2.new(180, 180)
    fireEmitter.Rotation = NumberRange.new(-180, 180)
    fireEmitter.RotSpeed = NumberRange.new(-200, 200)
    fireEmitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 2.0),
        NumberSequenceKeypoint.new(0.3, 1.5),
        NumberSequenceKeypoint.new(1, 0),
    })
    fireEmitter.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, C_WHITE),
        ColorSequenceKeypoint.new(0.25, C_YELLOW),
        ColorSequenceKeypoint.new(0.5, C_ORANGE),
        ColorSequenceKeypoint.new(0.75, C_RED),
        ColorSequenceKeypoint.new(1, C_DEEP),
    })
    fireEmitter.LightEmission = 1
    fireEmitter.LightInfluence = 0
    fireEmitter.Parent = att

    -- 高熱
    local hotAtt = Instance.new("Attachment")
    hotAtt.Parent = core

    local hotEmitter = Instance.new("ParticleEmitter")
    hotEmitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    hotEmitter.Rate = 80
    hotEmitter.Lifetime = NumberRange.new(0.3, 0.6)
    hotEmitter.Speed = NumberRange.new(3, 8)
    hotEmitter.SpreadAngle = Vector2.new(180, 180)
    hotEmitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.8),
        NumberSequenceKeypoint.new(1, 0),
    })
    hotEmitter.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, C_WHITE),
        ColorSequenceKeypoint.new(1, C_YELLOW),
    })
    hotEmitter.LightEmission = 1
    hotEmitter.Parent = hotAtt

    -- 煙
    local smokeAtt = Instance.new("Attachment")
    smokeAtt.Parent = main

    local smoke = Instance.new("ParticleEmitter")
    smoke.Texture = "rbxasset://textures/particles/smoke_main.dds"
    smoke.Rate = 50
    smoke.Lifetime = NumberRange.new(1.0, 2.0)
    smoke.Speed = NumberRange.new(5, 10)
    smoke.SpreadAngle = Vector2.new(180, 180)
    smoke.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1.2),
        NumberSequenceKeypoint.new(1, 3.5),
    })
    smoke.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(1, 1),
    })
    smoke.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 30, 15)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 10, 5)),
    })
    smoke.Parent = smokeAtt

    -- 火の粉
    local sparkAtt = Instance.new("Attachment")
    sparkAtt.Parent = main

    local sparkle = Instance.new("ParticleEmitter")
    sparkle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    sparkle.Rate = 150
    sparkle.Lifetime = NumberRange.new(0.4, 0.8)
    sparkle.Speed = NumberRange.new(15, 30)
    sparkle.SpreadAngle = Vector2.new(180, 180)
    sparkle.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.8),
        NumberSequenceKeypoint.new(1, 0),
    })
    sparkle.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, C_WHITE),
        ColorSequenceKeypoint.new(0.5, C_YELLOW),
        ColorSequenceKeypoint.new(1, C_ORANGE),
    })
    sparkle.LightEmission = 1
    sparkle.Parent = sparkAtt

    -- 上昇熱気
    local riseAtt = Instance.new("Attachment")
    riseAtt.Position = Vector3.new(0, -0.8, 0)
    riseAtt.Parent = main

    local rise = Instance.new("ParticleEmitter")
    rise.Texture = "rbxasset://textures/particles/smoke_main.dds"
    rise.Rate = 30
    rise.Lifetime = NumberRange.new(0.8, 1.5)
    rise.Speed = NumberRange.new(4, 8)
    rise.SpreadAngle = Vector2.new(20, 20)
    rise.Acceleration = Vector3.new(0, 6, 0)
    rise.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1.0),
        NumberSequenceKeypoint.new(1, 2.5),
    })
    rise.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.6),
        NumberSequenceKeypoint.new(1, 1),
    })
    rise.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, C_ORANGE),
        ColorSequenceKeypoint.new(1, C_DEEP),
    })
    rise.LightEmission = 0.6
    rise.Parent = riseAtt

    -- Trail
    local function addTrail(p, c1, c2)
        local a0 = Instance.new("Attachment")
        a0.Position = Vector3.new(0, p.Size.Y / 2, 0)
        a0.Parent = p
        local a1 = Instance.new("Attachment")
        a1.Position = Vector3.new(0, -p.Size.Y / 2, 0)
        a1.Parent = p

        local trail = Instance.new("Trail")
        trail.Attachment0 = a0
        trail.Attachment1 = a1
        trail.Lifetime = 0.5
        trail.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, c1),
            ColorSequenceKeypoint.new(1, c2),
        })
        trail.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.1),
            NumberSequenceKeypoint.new(1, 1),
        })
        trail.LightEmission = 1
        trail.Parent = p
    end
    addTrail(main, C_WHITE, C_ORANGE2)
    addTrail(core, C_WHITE, C_YELLOW)

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

        for i, v in ipairs(vortices) do
            local angle = t * v.speed + v.baseAngle
            v.part.CFrame = baseCF * CFrame.Angles(
                math.cos(angle) * 0.9,
                math.sin(angle) * 0.9,
                angle
            )
        end

        for i, e in ipairs(embers) do
            local angle = t * e.orbitSpeed + e.angle
            local height = math.sin(t * 3 + e.heightPhase) * 1.0
            local radius = 1.8 + math.sin(t * 2 + e.heightPhase) * 0.3
            local pos = Vector3.new(
                math.cos(angle) * radius,
                height,
                math.sin(angle) * radius
            )
            e.part.CFrame = baseCF * CFrame.new(pos)

            local hue = (math.sin(t * 4 + i) * 0.5 + 0.5)
            e.part.Color = Color3.fromRGB(255, 220 - hue * 180, 100 - hue * 100)
        end

        local pulse = 1 + math.sin(t * 15) * 0.1
        core.Size = Vector3.new(0.5, 0.5, 0.5) * pulse
        mid.Size = Vector3.new(1.0, 1.0, 1.0) * (1 + math.sin(t * 10) * 0.08)
        shell.Size = Vector3.new(2.2, 2.2, 2.2) * (1 + math.sin(t * 4) * 0.05)
        heat.Size = Vector3.new(3.0, 3.0, 3.0) * (1 + math.sin(t * 2.5) * 0.04)

        fireEmitter.Rate = 200 + math.sin(t * 12) * 80
        sparkle.Rate = 120 + math.sin(t * 8) * 50
    end)

    return model, main, spinConn, {
        fireEmitter = fireEmitter,
        hotEmitter = hotEmitter,
        smoke = smoke,
        sparkle = sparkle,
        rise = rise,
    }
end

------------------------------------------------------------
-- 大爆発
------------------------------------------------------------
local function explodeAt(pos, size)
    size = size or 2
    local scale = math.clamp(size / 2, 0.5, 30)

    local core = Instance.new("Part")
    core.Shape = Enum.PartType.Ball
    core.Size = Vector3.new(size * 0.8, size * 0.8, size * 0.8)
    core.Color = C_WHITE
    core.Material = Enum.Material.Neon
    core.Anchored = true
    core.CanCollide = false
    core.CastShadow = false
    core.CFrame = CFrame.new(pos)
    core.Parent = workspace

    local coreLight = Instance.new("PointLight")
    coreLight.Color = C_YELLOW
    coreLight.Range = 120 * scale
    coreLight.Brightness = 25 * scale
    coreLight.Parent = core

    TweenService:Create(core, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(size * 5, size * 5, size * 5),
    }):Play()
    task.delay(0.2, function()
        TweenService:Create(core, TweenInfo.new(0.8), {
            Size = Vector3.new(0, 0, 0), Transparency = 1,
        }):Play()
        TweenService:Create(coreLight, TweenInfo.new(0.8), {Brightness = 0}):Play()
    end)
    task.delay(1.2, function()
        if core and core.Parent then core:Destroy() end
    end)

    local fire = Instance.new("Part")
    fire.Shape = Enum.PartType.Ball
    fire.Size = Vector3.new(size, size, size)
    fire.Color = C_ORANGE
    fire.Material = Enum.Material.Neon
    fire.Anchored = true
    fire.CanCollide = false
    fire.CastShadow = false
    fire.CFrame = CFrame.new(pos)
    fire.Parent = workspace

    local fireLight = Instance.new("PointLight")
    fireLight.Color = C_ORANGE
    fireLight.Range = 80 * scale
    fireLight.Brightness = 15 * scale
    fireLight.Parent = fire

    TweenService:Create(fire, TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(size * 12, size * 12, size * 12), Transparency = 1,
    }):Play()
    task.delay(1.1, function()
        if fire and fire.Parent then fire:Destroy() end
    end)

    local redShell = Instance.new("Part")
    redShell.Shape = Enum.PartType.Ball
    redShell.Size = Vector3.new(size, size, size)
    redShell.Color = C_RED
    redShell.Material = Enum.Material.ForceField
    redShell.Anchored = true
    redShell.CanCollide = false
    redShell.CastShadow = false
    redShell.Transparency = 0.3
    redShell.CFrame = CFrame.new(pos)
    redShell.Parent = workspace

    TweenService:Create(redShell, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(size * 20, size * 20, size * 20), Transparency = 1,
    }):Play()
    task.delay(1.3, function()
        if redShell and redShell.Parent then redShell:Destroy() end
    end)

    for i = 1, 3 do
        local pillar = Instance.new("Part")
        pillar.Size = Vector3.new(size * (2 + i), 1, size * (2 + i))
        pillar.Color = (i == 1 and C_WHITE) or (i == 2 and C_ORANGE) or C_RED
        pillar.Material = Enum.Material.Neon
        pillar.Anchored = true
        pillar.CanCollide = false
        pillar.CastShadow = false
        pillar.Transparency = 0.2 + i * 0.1
        pillar.CFrame = CFrame.new(pos)
        pillar.Parent = workspace

        local pl = Instance.new("PointLight")
        pl.Color = (i == 1 and C_YELLOW) or C_ORANGE
        pl.Range = 40 * scale
        pl.Brightness = 8 * scale
        pl.Parent = pillar

        TweenService:Create(pillar, TweenInfo.new(0.5 + i * 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = Vector3.new(size * (2 + i), (60 + i * 20) * scale, size * (2 + i)), Transparency = 1,
        }):Play()
        task.delay(1, function()
            if pillar and pillar.Parent then pillar:Destroy() end
        end)
    end

    local emitterPart = Instance.new("Part")
    emitterPart.Size = Vector3.new(1, 1, 1)
    emitterPart.Transparency = 1
    emitterPart.Anchored = true
    emitterPart.CanCollide = false
    emitterPart.CFrame = CFrame.new(pos)
    emitterPart.Parent = workspace

    local att = Instance.new("Attachment")
    att.Parent = emitterPart

    local fireEmitter = Instance.new("ParticleEmitter")
    fireEmitter.Texture = "rbxasset://textures/particles/fire_main.dds"
    fireEmitter.Rate = 0
    fireEmitter.Lifetime = NumberRange.new(0.8, 1.8)
    fireEmitter.Speed = NumberRange.new(30, 70) * math.min(scale, 4)
    fireEmitter.SpreadAngle = Vector2.new(180, 180)
    fireEmitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 6 * scale),
        NumberSequenceKeypoint.new(0.4, 4 * scale),
        NumberSequenceKeypoint.new(1, 0),
    })
    fireEmitter.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, C_WHITE),
        ColorSequenceKeypoint.new(0.2, C_YELLOW),
        ColorSequenceKeypoint.new(0.4, C_ORANGE),
        ColorSequenceKeypoint.new(0.7, C_RED),
        ColorSequenceKeypoint.new(1, C_DEEP),
    })
    fireEmitter.LightEmission = 1
    fireEmitter.Parent = att
    fireEmitter:Emit(math.floor(200 * scale))

    task.delay(3, function()
        if emitterPart and emitterPart.Parent then emitterPart:Destroy() end
    end)

    for i = 1, 5 do
        local ring = Instance.new("Part")
        ring.Shape = Enum.PartType.Cylinder
        ring.Size = Vector3.new(0.3, 6, 6)
        ring.CFrame = CFrame.new(pos - Vector3.new(0, 0.25 * i, 0)) * CFrame.Angles(0, 0, math.rad(90))
        ring.Color = (i == 1 and C_WHITE) or (i == 2 and C_YELLOW) or (i == 3 and C_ORANGE) or (i == 4 and C_RED) or C_DEEP
        ring.Material = Enum.Material.Neon
        ring.Anchored = true
        ring.CanCollide = false
        ring.CastShadow = false
        ring.Transparency = 0.1
        ring.Parent = workspace

        task.delay(i * 0.1, function()
            TweenService:Create(ring, TweenInfo.new(1.2 + i * 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = Vector3.new(0.3, 80 * scale, 80 * scale), Transparency = 1,
            }):Play()
        end)
        task.delay(1.8, function()
            if ring and ring.Parent then ring:Destroy() end
        end)
    end

    local scorch = Instance.new("Part")
    scorch.Shape = Enum.PartType.Cylinder
    scorch.Size = Vector3.new(0.1, 15 * scale, 15 * scale)
    scorch.CFrame = CFrame.new(pos - Vector3.new(0, 1, 0)) * CFrame.Angles(0, 0, math.rad(90))
    scorch.Color = Color3.fromRGB(20, 5, 0)
    scorch.Material = Enum.Material.SmoothPlastic
    scorch.Anchored = true
    scorch.CanCollide = false
    scorch.CastShadow = false
    scorch.Transparency = 0.3
    scorch.Parent = workspace

    task.delay(8, function()
        if scorch and scorch.Parent then
            TweenService:Create(scorch, TweenInfo.new(3), {Transparency = 1}):Play()
            task.wait(3.1)
            scorch:Destroy()
        end
    end)

    task.spawn(function()
        local lingering = Instance.new("Part")
        lingering.Size = Vector3.new(5 * scale, 5 * scale, 5 * scale)
        lingering.Transparency = 1
        lingering.Anchored = true
        lingering.CanCollide = false
        lingering.CFrame = CFrame.new(pos)
        lingering.Parent = workspace

        local lAtt = Instance.new("Attachment")
        lAtt.Parent = lingering

        local lFire = Instance.new("ParticleEmitter")
        lFire.Texture = "rbxasset://textures/particles/fire_main.dds"
        lFire.Rate = 120
        lFire.Lifetime = NumberRange.new(1.0, 2.0)
        lFire.Speed = NumberRange.new(5, 15)
        lFire.SpreadAngle = Vector2.new(180, 180)
        lFire.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 5 * scale),
            NumberSequenceKeypoint.new(1, 0),
        })
        lFire.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, C_YELLOW),
            ColorSequenceKeypoint.new(0.3, C_ORANGE),
            ColorSequenceKeypoint.new(1, C_DEEP),
        })
        lFire.LightEmission = 1
        lFire.Parent = lAtt

        local lLight = Instance.new("PointLight")
        lLight.Color = C_ORANGE
        lLight.Range = 30 * scale
        lLight.Brightness = 6
        lLight.Parent = lingering

        task.wait(5)
        TweenService:Create(lFire, TweenInfo.new(2), {Rate = 0}):Play()
        TweenService:Create(lLight, TweenInfo.new(2), {Brightness = 0}):Play()
        task.wait(2.2)
        if lingering and lingering.Parent then lingering:Destroy() end
    end)

    local cc = Instance.new("ColorCorrectionEffect")
    cc.Brightness = 0.8 * math.min(scale, 3)
    cc.Contrast = 0.5
    cc.Saturation = 1.8
    cc.TintColor = Color3.fromRGB(255, 150, 100)
    cc.Parent = Lighting

    task.delay(0.2, function()
        TweenService:Create(cc, TweenInfo.new(1.2), {
            Brightness = 0, Saturation = 0, TintColor = Color3.fromRGB(255, 255, 255),
        }):Play()
        task.wait(1.4)
        if cc and cc.Parent then cc:Destroy() end
    end)

    task.spawn(function()
        local intensity = math.min(scale, 6)
        for i = 1, 35 do
            cam.CFrame = cam.CFrame * CFrame.Angles(
                math.rad(math.random(-40, 40) / 10 * intensity),
                math.rad(math.random(-40, 40) / 10 * intensity),
                math.rad(math.random(-40, 40) / 10 * intensity)
            )
            task.wait(0.02)
        end
    end)

    task.spawn(function()
        local radius = 60 * scale
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj.Anchored then
                local dist = (obj.Position - pos).Magnitude
                if dist < radius and dist > 0 then
                    local dir = (obj.Position - pos).Unit
                    local force = (1 - dist / radius) * 30 * scale
                    pcall(function()
                        local bv = Instance.new("BodyVelocity")
                        bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                        bv.Velocity = dir * force + Vector3.new(0, force * 0.6, 0)
                        bv.Parent = obj
                        task.delay(0.3, function()
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
-- 発射（比例拡大・高速回転）
------------------------------------------------------------
local function fireBall(model, main, spinConn, effects, fromCF)
    for _, p in ipairs(model:GetDescendants()) do
        if p:IsA("BasePart") then
            for _, w in ipairs(p:GetChildren()) do
                if w:IsA("Weld") and w.Name == "MouthWeld" then
                    w:Destroy()
                end
            end
            p.Anchored = true
        end
    end

    local fireEmitter = effects.fireEmitter
    local hotEmitter = effects.hotEmitter
    local smoke = effects.smoke
    local sparkle = effects.sparkle
    local rise = effects.rise

    local dir = cam.CFrame.LookVector
    local speed = 100
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
        local scale = 1 + travel / 50

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
                local finalScale = scale
                model:Destroy()
                if spinConn then spinConn:Disconnect() end
                explodeAt(hitPos, finalScale * 2)

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

        -- 1秒5回転
        local spinAngle = elapsed * 10 * math.pi
        model:PivotTo(CFrame.new(newPos) * CFrame.Angles(0, spinAngle, 0))

        for _, p in ipairs(model:GetDescendants()) do
            if p:IsA("BasePart") then
                if p.Name == "Core" then
                    p.Size = Vector3.new(0.5, 0.5, 0.5) * scale
                elseif p.Name == "Mid" then
                    p.Size = Vector3.new(1.0, 1.0, 1.0) * scale
                elseif p.Name == "Main" then
                    p.Size = Vector3.new(1.5, 1.5, 1.5) * scale
                elseif p.Name == "Shell" then
                    p.Size = Vector3.new(2.2, 2.2, 2.2) * scale
                elseif p.Name == "Heat" then
                    p.Size = Vector3.new(3.0, 3.0, 3.0) * scale
                elseif p.Name:find("Vortex") then
                    p.Size = Vector3.new(0.15, 2.4, 2.4) * scale
                elseif p.Name:find("Ember") then
                    p.Size = Vector3.new(0.15, 0.15, 0.15) * scale
                end
            end
        end

        local cappedScale = math.min(scale, 5)

        fireEmitter.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 2.0 * scale),
            NumberSequenceKeypoint.new(0.3, 1.5 * scale),
            NumberSequenceKeypoint.new(1, 0),
        })
        fireEmitter.Rate = 250 * cappedScale
        fireEmitter.Speed = NumberRange.new(10 * cappedScale, 20 * cappedScale)

        hotEmitter.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.8 * scale),
            NumberSequenceKeypoint.new(1, 0),
        })
        hotEmitter.Rate = 80 * cappedScale
        hotEmitter.Speed = NumberRange.new(3 * cappedScale, 8 * cappedScale)

        smoke.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1.2 * scale),
            NumberSequenceKeypoint.new(1, 3.5 * scale),
        })
        smoke.Rate = 50 * cappedScale
        smoke.Speed = NumberRange.new(5 * cappedScale, 10 * cappedScale)

        sparkle.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.8 * scale),
            NumberSequenceKeypoint.new(1, 0),
        })
        sparkle.Rate = 150 * cappedScale
        sparkle.Speed = NumberRange.new(15 * cappedScale, 30 * cappedScale)

        rise.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1.0 * scale),
            NumberSequenceKeypoint.new(1, 2.5 * scale),
        })
        rise.Rate = 30 * cappedScale
    end)
end

------------------------------------------------------------
-- 解放
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
-- チャージ開始
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

    local model, main, spinConn, effects = createFireball(char)
    fireModel = model
    fireMain = main
    fireSpinConn = spinConn
    fireEffects = effects

    local chargeConn
    chargeConn = RunService.Heartbeat:Connect(function(dt)
        if not fireModel or not fireModel.Parent then
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

        local fireFrom = fireMain and fireMain.CFrame or hrp.CFrame

        releasePlayer()

        if fireMain and fireModel and fireModel.Parent then
            fireBall(fireModel, fireMain, fireSpinConn, fireEffects, fireFrom)
        end
        fireModel = nil
        fireMain = nil
        fireSpinConn = nil
        fireEffects = nil
        charging = false
    end)
end

------------------------------------------------------------
-- ★ ON/OFFボタン処理
------------------------------------------------------------
btn.MouseButton1Click:Connect(function()
    ready = not ready
    if ready then
        btn.Text = "🔥 豪火球: ON"
        btn.BackgroundColor3 = Color3.fromRGB(200, 40, 10)
        btn.TextColor3 = Color3.fromRGB(255, 255, 200)
        startCharge()
    else
        btn.Text = "🔥 豪火球: OFF"
        btn.BackgroundColor3 = Color3.fromRGB(40, 10, 5)
        btn.TextColor3 = Color3.fromRGB(255, 200, 150)
        if fireModel and fireModel.Parent then fireModel:Destroy() end
        if fireSpinConn then fireSpinConn:Disconnect() end
        fireModel = nil
        fireMain = nil
        fireSpinConn = nil
        fireEffects = nil
        charging = false
        releasePlayer()
    end
end)

-- モバイル対応
btn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        btn.MouseButton1Click:Fire()
    end
end)

------------------------------------------------------------
-- キャラ変更でリセット
------------------------------------------------------------
plr.CharacterAdded:Connect(function()
    if fireModel and fireModel.Parent then fireModel:Destroy() end
    if fireSpinConn then fireSpinConn:Disconnect() end
    fireModel = nil
    fireMain = nil
    fireSpinConn = nil
    fireEffects = nil
    charging = false
    ready = false
    btn.Text = "🔥 豪火球: OFF"
    btn.BackgroundColor3 = Color3.fromRGB(40, 10, 5)
    task.wait(0.5)
    releasePlayer()
end)

print("[Goukakyuu] 豪火球（ON/OFFボタン付き最終版）起動")
