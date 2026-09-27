--[[ Rainbow Chaos Script - Free Movement Edition ]]
-- ⚠️ ジョークスクリプト。自分のゲーム/Studioでのみ実行してください。

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local UIS = game:GetService("UserInputService")

local plr = Players.LocalPlayer
local cam = workspace.CurrentCamera
local PlayerGui = plr:WaitForChild("PlayerGui")

local KEY_TEXT = "rainbow"
local MUSIC_ID = "rbxassetid://1837879082"
local ROTATE_TIME = 3
local FLIP_TIME = 10

------------------------------------------------------------
-- Key画面
------------------------------------------------------------
local keyGui = Instance.new("ScreenGui")
keyGui.Name = "RainbowKeyGui"
keyGui.ResetOnSpawn = false
keyGui.IgnoreGuiInset = true
keyGui.DisplayOrder = 999
keyGui.Parent = PlayerGui

local bg = Instance.new("Frame")
bg.Size = UDim2.new(1, 0, 1, 0)
bg.Position = UDim2.new(0, 0, 0, 0)
bg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
bg.BorderSizePixel = 0
bg.ZIndex = 0
bg.Parent = keyGui

local grad = Instance.new("UIGradient")
grad.Rotation = 0
grad.Parent = bg

local function makeRainbow(hueOffset)
    local keys = {}
    local steps = 6
    for i = 0, steps do
        local p = i / steps
        local hue = (hueOffset + p) % 1
        table.insert(keys, ColorSequenceKeypoint.new(p, Color3.fromHSV(hue, 1, 1)))
    end
    return ColorSequence.new(keys)
end

grad.Color = makeRainbow(0)

local hueShift = 0
local gradConn
gradConn = RunService.RenderStepped:Connect(function(dt)
    grad.Rotation = (grad.Rotation + dt * 90) % 360
    hueShift = (hueShift + dt * 0.25) % 1
    grad.Color = makeRainbow(hueShift)
end)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 90)
title.Position = UDim2.new(0, 0, 0.20, 0)
title.BackgroundTransparency = 1
title.Text = "🌈 RAINBOW KEY 🌈"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextStrokeTransparency = 0
title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
title.TextScaled = true
title.Font = Enum.Font.GothamBlack
title.ZIndex = 2
title.Parent = keyGui

local box = Instance.new("TextBox")
box.Size = UDim2.new(0, 320, 0, 65)
box.Position = UDim2.new(0.5, -160, 0.5, -80)
box.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
box.BackgroundTransparency = 0.15
box.TextColor3 = Color3.fromRGB(255, 255, 255)
box.PlaceholderText = "Keyを入力..."
box.PlaceholderColor3 = Color3.fromRGB(200, 200, 200)
box.Text = ""
box.TextSize = 24
box.Font = Enum.Font.GothamBold
box.ClearTextOnFocus = false
box.BorderSizePixel = 0
box.ZIndex = 2
box.Parent = keyGui
Instance.new("UICorner", box).CornerRadius = UDim.new(0, 14)

local boxStroke = Instance.new("UIStroke")
boxStroke.Thickness = 3
boxStroke.Parent = box
local strokeGrad = Instance.new("UIGradient")
strokeGrad.Parent = boxStroke

local enterBtn = Instance.new("TextButton")
enterBtn.Size = UDim2.new(0, 200, 0, 55)
enterBtn.Position = UDim2.new(0.5, -100, 0.5, 10)
enterBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
enterBtn.BackgroundTransparency = 0.1
enterBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
enterBtn.Text = "決定"
enterBtn.TextSize = 24
enterBtn.Font = Enum.Font.GothamBold
enterBtn.BorderSizePixel = 0
enterBtn.ZIndex = 2
enterBtn.Parent = keyGui
Instance.new("UICorner", enterBtn).CornerRadius = UDim.new(0, 14)

local enterStroke = Instance.new("UIStroke")
enterStroke.Thickness = 3
enterStroke.Parent = enterBtn
local enterStrokeGrad = Instance.new("UIGradient")
enterStrokeGrad.Parent = enterStroke

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 0, 45)
status.Position = UDim2.new(0, 0, 0.66, 0)
status.BackgroundTransparency = 1
status.Text = "キーを入力して決定を押す"
status.TextColor3 = Color3.fromRGB(255, 255, 255)
status.TextStrokeTransparency = 0
status.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
status.TextScaled = true
status.Font = Enum.Font.GothamBold
status.ZIndex = 2
status.Parent = keyGui

RunService.RenderStepped:Connect(function()
    strokeGrad.Color = grad.Color
    strokeGrad.Rotation = grad.Rotation
    enterStrokeGrad.Color = grad.Color
    enterStrokeGrad.Rotation = grad.Rotation
end)

------------------------------------------------------------
-- ステージ2：認証後のカオス（自分は自由）
------------------------------------------------------------

-- ▼ 自分と自分のパーツを判定するヘルパー
local function isMine(obj)
    local char = plr.Character
    if not char then return false end
    return obj:IsDescendantOf(char)
end

-- ▼ マップ虹色化（自分の視界だけ）
local function rainbowMap()
    local colorCorrection = Instance.new("ColorCorrectionEffect")
    colorCorrection.Name = "RainbowCC"
    colorCorrection.Brightness = 0.2
    colorCorrection.Contrast = 0.3
    colorCorrection.Saturation = 2
    colorCorrection.Parent = Lighting

    local atmos = Instance.new("Atmosphere")
    atmos.Name = "RainbowAtmo"
    atmos.Density = 0.4
    atmos.Offset = 0.5
    atmos.Color = Color3.fromRGB(255, 0, 255)
    atmos.Decay = Color3.fromRGB(100, 200, 255)
    atmos.Glare = 0.5
    atmos.Haze = 2
    atmos.Parent = Lighting

    task.spawn(function()
        local t = 0
        while colorCorrection.Parent do
            t = t + task.wait()
            local hue = (t * 0.3) % 1
            colorCorrection.TintColor = Color3.fromHSV(hue, 1, 1)
            atmos.Color = Color3.fromHSV(hue, 0.8, 1)
            atmos.Decay = Color3.fromHSV((hue + 0.5) % 1, 0.8, 1)
        end
    end)
end

-- ▼ 爆音BGM
local function blastMusic()
    local snd = Instance.new("Sound")
    snd.Name = "RainbowBlast"
    snd.SoundId = MUSIC_ID
    snd.Volume = 10
    snd.Looped = true
    snd.Parent = SoundService
    snd:Play()
    for i = 1, 3 do
        local s2 = snd:Clone()
        s2.Volume = 5
        s2.Parent = SoundService
        s2:Play()
    end
    return snd
end

-- ▼ 画面反転（自分には影響しないよう、カメラの基準CFrameを保持して自分だけ除外）
-- ※ Robloxのカメラは1つしかないので、LocalPlayerのカメラ操作を優先するため
--    「画面反転」はビジュアルエフェクトとしてのみ行い、自分の移動は通常通り
local function flipScreen(duration)
    -- 画面全体に虹色オーバーレイで「反転してる風」に見せる代わりに
    -- 実際のカメラ回転は行わず、自分は自由に動けるようにする
    -- ここでは演出として「画面を揺らす」だけにする
    local conn
    local t0 = tick()
    conn = RunService.RenderStepped:Connect(function()
        local elapsed = tick() - t0
        if elapsed >= duration then
            conn:Disconnect()
            return
        end
        -- カメラには触らず、FOVを少し揺らすだけ（自分は動ける）
        cam.FieldOfView = 70 + math.sin(elapsed * 15) * 10
    end)
    -- 終了後にFOVを戻す
    task.delay(duration, function()
        TweenService:Create(cam, TweenInfo.new(0.5), {FieldOfView = 70}):Play()
    end)
end

-- ▼ 画面回転（自分には影響しないよう、FOVの揺れで表現）
local function spinScreen(duration)
    local conn
    local t0 = tick()
    conn = RunService.RenderStepped:Connect(function()
        local elapsed = tick() - t0
        if elapsed >= duration then
            conn:Disconnect()
            return
        end
        cam.FieldOfView = 70 + math.sin(elapsed * 30) * 15
    end)
    task.delay(duration, function()
        TweenService:Create(cam, TweenInfo.new(0.3), {FieldOfView = 70}):Play()
    end)
end

-- ▼ FTAPカオス（自分のパーツは除外）
local function chaosParts()
    local originals = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj.Anchored then
            -- ★ 自分のキャラのパーツは除外
            if not isMine(obj) then
                table.insert(originals, {
                    part = obj,
                    rotSpeed = Vector3.new(
                        math.random(-200, 200),
                        math.random(-200, 200),
                        math.random(-200, 200)
                    ) / 100,
                    moveSpeed = Vector3.new(
                        math.random(-50, 50),
                        math.random(-50, 50),
                        math.random(-50, 50)
                    ) / 100,
                })
            end
        end
    end
    return RunService.Heartbeat:Connect(function(dt)
        for _, d in ipairs(originals) do
            if d.part and d.part.Parent and not isMine(d.part) then
                d.part.CFrame = d.part.CFrame * CFrame.Angles(
                    d.rotSpeed.X * dt,
                    d.rotSpeed.Y * dt,
                    d.rotSpeed.Z * dt
                )
                local offset = Vector3.new(
                    math.sin(tick() * d.moveSpeed.X * 3) * 3,
                    math.sin(tick() * d.moveSpeed.Y * 3) * 3,
                    math.sin(tick() * d.moveSpeed.Z * 3) * 3
                )
                d.part.CFrame = d.part.CFrame + offset * dt
            end
        end
    end)
end

------------------------------------------------------------
-- 認証処理
------------------------------------------------------------
local authed = false

local function onAuthSuccess()
    if authed then return end
    authed = true

    if gradConn then gradConn:Disconnect() end
    TweenService:Create(bg, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
    TweenService:Create(title, TweenInfo.new(0.6), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
    TweenService:Create(box, TweenInfo.new(0.6), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
    TweenService:Create(boxStroke, TweenInfo.new(0.6), {Transparency = 1}):Play()
    TweenService:Create(enterBtn, TweenInfo.new(0.6), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
    TweenService:Create(enterStroke, TweenInfo.new(0.6), {Transparency = 1}):Play()
    TweenService:Create(status, TweenInfo.new(0.6), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()

    task.wait(1.2)
    keyGui:Destroy()

    rainbowMap()
    blastMusic()

    flipScreen(FLIP_TIME)

    task.delay(0.5, function()
        spinScreen(ROTATE_TIME)
    end)

    chaosParts()

    -- 虹色オーバーレイ
    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    overlay.BackgroundTransparency = 0.85
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 10
    overlay.Parent = PlayerGui

    local oGrad = Instance.new("UIGradient")
    oGrad.Color = grad.Color
    oGrad.Rotation = 0
    oGrad.Parent = overlay

    RunService.RenderStepped:Connect(function(dt)
        oGrad.Rotation = (oGrad.Rotation + dt * 200) % 360
        oGrad.Color = grad.Color
    end)
end

local function tryKey()
    if box.Text == KEY_TEXT then
        status.Text = "✅ 認証成功！"
        status.TextColor3 = Color3.fromRGB(0, 255, 100)
        onAuthSuccess()
    else
        status.Text = "❌ キーが違うよ"
        status.TextColor3 = Color3.fromRGB(255, 80, 80)
        box.Text = ""
        local base = box.Position
        for i = 1, 6 do
            box.Position = base + UDim2.new(0, math.random(-8, 8), 0, math.random(-8, 8))
            task.wait(0.04)
        end
        box.Position = base
    end
end

enterBtn.MouseButton1Click:Connect(tryKey)
enterBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        tryKey()
    end
end)
box.FocusLost:Connect(function(enterPressed)
    if enterPressed then tryKey() end
end)

print("[Rainbow Chaos] Key画面表示中... key = rainbow")
