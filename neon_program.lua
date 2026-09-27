--[[ neon_program.lua - 完全版（ハブ開閉トグル付き） ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")

local plr = Players.LocalPlayer
local cam = workspace.CurrentCamera
local PlayerGui = plr:WaitForChild("PlayerGui")

local function getGuiParent()
    local ok = pcall(function()
        local t = Instance.new("ScreenGui")
        t.Parent = CoreGui
        t:Destroy()
    end)
    if ok then return CoreGui end
    return PlayerGui
end
local guiParent = getGuiParent()

local C_GREEN  = Color3.fromRGB(0, 255, 100)
local C_GREEN2 = Color3.fromRGB(0, 180, 70)
local C_CYAN   = Color3.fromRGB(0, 255, 255)
local C_RED    = Color3.fromRGB(255, 60, 80)
local C_YELLOW = Color3.fromRGB(255, 220, 60)
local C_PURPLE = Color3.fromRGB(180, 80, 255)
local C_BG     = Color3.fromRGB(0, 3, 0)
local C_PANEL  = Color3.fromRGB(0, 8, 3)
local C_LINE   = Color3.fromRGB(0, 60, 30)

local MUSIC_ID = "rbxassetid://116079585368153"
local MUSIC_VOLUME = 3
local MUSIC_LOOPED = true
local musicInstance = nil

local authed = false
local selectedPlayers = {}
local playerButtons = {}
local espData = {}
local fpsValue = 60
local msValue = 16.7
local fpsTimer = 0
local frameCount = 0
local defaultFOV = cam.FieldOfView
local currentFOV = defaultFOV
local flyEnabled = false
local flySpeed = 80
local speedEnabled = false
local speedValue = 16
local jumpEnabled = false
local jumpValue = 50
local infJumpEnabled = false
local fullbrightEnabled = false
local noFogEnabled = false
local tracerEnabled = false

-- ANTI設定
local antiKickEnabled = false
local antiFlingEnabled = false
local antiVoidEnabled = false
local antiTeleportEnabled = false
local antiAnchorEnabled = false
local antiGrabEnabled = false
local protectionCount = 0
local lastResetTime = 0
local lastCFrame = nil
local antiConns = {}

-- ★ flyBV / flyBG を先に宣言（antiGrab から参照するため）
local flyBV, flyBG, flyConn

local originalLighting = {
    Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
    Brightness = Lighting.Brightness, FogStart = Lighting.FogStart, FogEnd = Lighting.FogEnd,
}
local tracers = {}

local function addTerminalCorners(parent, color, size, zindex)
    size = size or 10; color = color or C_GREEN; zindex = zindex or 11
    local positions = {{0,0,1,1},{1,0,-1,1},{0,1,1,-1},{1,1,-1,-1}}
    for _, pos in ipairs(positions) do
        local h = Instance.new("Frame")
        h.Size = UDim2.new(0, size, 0, 2)
        h.Position = UDim2.new(pos[1], pos[3] == 1 and 0 or -size, pos[2], pos[4] == 1 and 0 or -2)
        h.BackgroundColor3 = color; h.BorderSizePixel = 0; h.ZIndex = zindex; h.Parent = parent
        local v = Instance.new("Frame")
        v.Size = UDim2.new(0, 2, 0, size)
        v.Position = UDim2.new(pos[1], pos[3] == 1 and 0 or -2, pos[2], pos[4] == 1 and 0 or -size)
        v.BackgroundColor3 = color; v.BorderSizePixel = 0; v.ZIndex = zindex; v.Parent = parent
    end
end

local function bindClick(btn, callback)
    local lastClick = 0
    local function tryClick()
        local now = tick()
        if now - lastClick < 0.2 then return end
        lastClick = now; callback()
    end
    btn.MouseButton1Click:Connect(tryClick)
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then tryClick() end
    end)
end

local function makeDraggable(frame, dragBar)
    dragBar = dragBar or frame
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
    dragBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    dragBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

RunService.RenderStepped:Connect(function(dt)
    frameCount = frameCount + 1; fpsTimer = fpsTimer + dt
    if fpsTimer >= 0.5 then
        fpsValue = math.floor(frameCount / fpsTimer)
        msValue = (fpsTimer / frameCount) * 1000
        frameCount = 0; fpsTimer = 0
    end
end)

------------------------------------------------------------
-- 音楽
------------------------------------------------------------
local function startMusic()
    if musicInstance then return end
    musicInstance = Instance.new("Sound")
    musicInstance.Name = "NeonProgramMusic"
    musicInstance.SoundId = MUSIC_ID
    musicInstance.Volume = MUSIC_VOLUME
    musicInstance.Looped = MUSIC_LOOPED
    musicInstance.Parent = SoundService
    musicInstance:Play()
end
local function stopMusic()
    if musicInstance then musicInstance:Destroy(); musicInstance = nil end
end

------------------------------------------------------------
-- ANTI 機能
------------------------------------------------------------
local function startAntiKick()
    if antiConns.kick then return end
    antiConns.kick = RunService.Heartbeat:Connect(function()
        if not antiKickEnabled then return end
        local char = plr.Character; if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local speed = hrp.AssemblyLinearVelocity.Magnitude
        if speed > 200 then
            local now = tick()
            if now - lastResetTime > 0.5 then
                lastResetTime = now
                protectionCount = protectionCount + 1
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end
        end
    end)
end

local function startAntiFling()
    if antiConns.fling then return end
    antiConns.fling = RunService.Heartbeat:Connect(function()
        if not antiFlingEnabled then return end
        local char = plr.Character; if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local vel = hrp.AssemblyLinearVelocity.Magnitude
        local angVel = hrp.AssemblyAngularVelocity.Magnitude
        if vel > 300 or angVel > 50 then
            local now = tick()
            if now - lastResetTime > 0.3 then
                lastResetTime = now
                protectionCount = protectionCount + 1
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end
        end
    end)
end

local function startAntiVoid()
    if antiConns.void then return end
    antiConns.void = RunService.Heartbeat:Connect(function()
        if not antiVoidEnabled then return end
        local char = plr.Character; if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        if hrp.Position.Y < -50 then
            local now = tick()
            if now - lastResetTime > 1 then
                lastResetTime = now
                protectionCount = protectionCount + 1
                hrp.CFrame = CFrame.new(0, 50, 0)
                hrp.AssemblyLinearVelocity = Vector3.zero
            end
        end
    end)
end

local function startAntiTeleport()
    if antiConns.tp then return end
    local char = plr.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then lastCFrame = hrp.CFrame end
    end
    antiConns.tp = RunService.Heartbeat:Connect(function()
        if not antiTeleportEnabled then return end
        local c = plr.Character; if not c then return end
        local hrp = c:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        if lastCFrame then
            local dist = (hrp.Position - lastCFrame.Position).Magnitude
            if dist > 25 then
                protectionCount = protectionCount + 1
                hrp.CFrame = lastCFrame
                hrp.AssemblyLinearVelocity = Vector3.zero
                return
            end
        end
        lastCFrame = hrp.CFrame
    end)
end

local function startAntiAnchor()
    if antiConns.anchor then return end
    antiConns.anchor = RunService.Heartbeat:Connect(function()
        if not antiAnchorEnabled then return end
        local c = plr.Character; if not c then return end
        local hrp = c:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        if hrp.Anchored then
            hrp.Anchored = false
            protectionCount = protectionCount + 1
        end
        local hum = c:FindFirstChildOfClass("Humanoid")
        if hum then
            if hum.PlatformStand and not flyEnabled then
                hum.PlatformStand = false
                protectionCount = protectionCount + 1
            end
        end
    end)
end

-- ANTI_GRAB：掴まれたら引き剥がす
local function startAntiGrab()
    if antiConns.grab then return end
    antiConns.grab = RunService.Heartbeat:Connect(function()
        if not antiGrabEnabled then return end
        local c = plr.Character; if not c then return end
        local hrp = c:FindFirstChild("HumanoidRootPart"); if not hrp then return end

        for _, obj in ipairs(hrp:GetChildren()) do
            if obj:IsA("Weld") or obj:IsA("WeldConstraint") or obj:IsA("Motor6D") then
                local p0 = obj.Part0
                local p1 = obj.Part1
                local p0Mine = p0 and p0:IsDescendantOf(c)
                local p1Mine = p1 and p1:IsDescendantOf(c)
                if not (p0Mine and p1Mine) then
                    obj:Destroy()
                    protectionCount = protectionCount + 1
                end
            end
        end

        for _, obj in ipairs(hrp:GetChildren()) do
            if obj:IsA("BodyVelocity")
                or obj:IsA("BodyPosition")
                or obj:IsA("BodyGyro")
                or obj:IsA("BodyThrust")
                or obj:IsA("BodyAngularVelocity")
                or obj:IsA("BodyForce") then
                if obj ~= flyBV and obj ~= flyBG then
                    obj:Destroy()
                    protectionCount = protectionCount + 1
                end
            end
        end

        for _, part in ipairs(c:GetDescendants()) do
            if part:IsA("BasePart") then
                for _, obj in ipairs(part:GetChildren()) do
                    if obj:IsA("Weld") or obj:IsA("WeldConstraint") then
                        local p0 = obj.Part0
                        local p1 = obj.Part1
                        local p0Mine = p0 and p0:IsDescendantOf(c)
                        local p1Mine = p1 and p1:IsDescendantOf(c)
                        if not (p0Mine and p1Mine) then
                            obj:Destroy()
                            protectionCount = protectionCount + 1
                        end
                    end
                end
            end
        end

        local hum = c:FindFirstChildOfClass("Humanoid")
        if hum then
            local state = hum:GetState()
            if state == Enum.HumanoidStateType.FallingDown
                or state == Enum.HumanoidStateType.Ragdoll then
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                protectionCount = protectionCount + 1
            end
        end
    end)
end

------------------------------------------------------------
-- 移動機能
------------------------------------------------------------
local function startFly()
    local char = plr.Character; if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    flyEnabled = true; hum.PlatformStand = true
    flyBV = Instance.new("BodyVelocity"); flyBV.MaxForce = Vector3.new(1e5,1e5,1e5)
    flyBV.Velocity = Vector3.zero; flyBV.Parent = hrp
    flyBG = Instance.new("BodyGyro"); flyBG.MaxTorque = Vector3.new(1e5,1e5,1e5)
    flyBG.P = 1e4; flyBG.CFrame = hrp.CFrame; flyBG.Parent = hrp
    flyConn = RunService.RenderStepped:Connect(function()
        if not flyEnabled or not hrp or not hrp.Parent then return end
        local moveDir = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir += cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir -= cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir -= cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir += cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir -= Vector3.new(0,1,0) end
        flyBV.Velocity = moveDir.Magnitude > 0 and (moveDir.Unit * flySpeed) or Vector3.zero
        flyBG.CFrame = cam.CFrame
    end)
end
local function stopFly()
    flyEnabled = false
    if flyConn then flyConn:Disconnect() end
    if flyBV then flyBV:Destroy() end
    if flyBG then flyBG:Destroy() end
    local char = plr.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end
local function applySpeed()
    local char = plr.Character; if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = speedEnabled and speedValue or 16 end
end
local function applyJump()
    local char = plr.Character; if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = jumpEnabled and jumpValue or 50 end
end
UIS.JumpRequest:Connect(function()
    if not infJumpEnabled then return end
    local char = plr.Character; if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

local function applyFullbright()
    if fullbrightEnabled then
        Lighting.Ambient = Color3.fromRGB(200,200,200)
        Lighting.OutdoorAmbient = Color3.fromRGB(200,200,200)
        Lighting.Brightness = 3
    else
        Lighting.Ambient = originalLighting.Ambient
        Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
        Lighting.Brightness = originalLighting.Brightness
    end
end
local function applyNoFog()
    if noFogEnabled then
        Lighting.FogEnd = math.huge; Lighting.FogStart = math.huge
    else
        Lighting.FogStart = originalLighting.FogStart; Lighting.FogEnd = originalLighting.FogEnd
    end
end
local function updateTracers()
    if not tracerEnabled then
        for _, t in pairs(tracers) do if t.line and t.line.Parent then t.line:Destroy() end end
        tracers = {}; return
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= plr then
            local c = p.Character
            if c then
                local hrp = c:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local line = tracers[p]
                    if not line or not line.line or not line.line.Parent then
                        local l = Instance.new("Part"); l.Anchored = true; l.CanCollide = false
                        l.CastShadow = false; l.Material = Enum.Material.Neon
                        l.Color = C_RED; l.Transparency = 0.3; l.Parent = workspace
                        tracers[p] = {line = l}; line = tracers[p]
                    end
                    local from = cam.CFrame.Position - Vector3.new(0,2,0)
                    local to = hrp.Position
                    line.line.Size = Vector3.new(0.1,0.1,(to-from).Magnitude)
                    line.line.CFrame = CFrame.new(from, to) * CFrame.Angles(math.pi/2,0,0)
                end
            end
        end
    end
end
RunService.RenderStepped:Connect(updateTracers)

local function makeToggle(parent, text, yPos, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -12, 0, 24); row.Position = UDim2.new(0, 6, 0, yPos)
    row.BackgroundColor3 = Color3.fromRGB(0,10,3); row.BackgroundTransparency = 0.3
    row.BorderSizePixel = 0; row.ZIndex = 12; row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 2)
    local stroke = Instance.new("UIStroke"); stroke.Thickness = 1
    stroke.Color = C_GREEN2; stroke.Transparency = 0.5; stroke.Parent = row
    local statusBar = Instance.new("Frame"); statusBar.Size = UDim2.new(0,3,1,0)
    statusBar.Position = UDim2.new(0,0,0,0); statusBar.BackgroundColor3 = C_GREEN2
    statusBar.BorderSizePixel = 0; statusBar.ZIndex = 13; statusBar.Parent = row
    local state = false
    local promptLbl = Instance.new("TextLabel")
    promptLbl.Size = UDim2.new(0,10,1,0); promptLbl.Position = UDim2.new(0,8,0,0)
    promptLbl.BackgroundTransparency = 1; promptLbl.Text = ">"
    promptLbl.TextColor3 = C_GREEN; promptLbl.TextSize = 10
    promptLbl.Font = Enum.Font.Code; promptLbl.TextXAlignment = Enum.TextXAlignment.Left
    promptLbl.ZIndex = 13; promptLbl.Parent = row
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-60,1,0); lbl.Position = UDim2.new(0,22,0,0)
    lbl.BackgroundTransparency = 1; lbl.Text = text; lbl.TextColor3 = C_GREEN
    lbl.TextSize = 10; lbl.Font = Enum.Font.Code
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 13; lbl.Parent = row
    local statusLbl = Instance.new("TextLabel")
    statusLbl.Size = UDim2.new(0,46,1,0); statusLbl.Position = UDim2.new(1,-48,0,0)
    statusLbl.BackgroundTransparency = 1; statusLbl.Text = "[OFF]"
    statusLbl.TextColor3 = C_GREEN2; statusLbl.TextSize = 9
    statusLbl.Font = Enum.Font.Code; statusLbl.TextXAlignment = Enum.TextXAlignment.Right
    statusLbl.ZIndex = 13; statusLbl.Parent = row
    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1,0,1,0); clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""; clickBtn.ZIndex = 14; clickBtn.Parent = row
    bindClick(clickBtn, function()
        state = not state
        if state then
            statusBar.BackgroundColor3 = C_GREEN; stroke.Color = C_GREEN
            stroke.Transparency = 0.1; lbl.TextColor3 = C_GREEN
            promptLbl.TextColor3 = C_GREEN
            statusLbl.Text = "[ ON]"; statusLbl.TextColor3 = C_GREEN
        else
            statusBar.BackgroundColor3 = C_GREEN2; stroke.Color = C_GREEN2
            stroke.Transparency = 0.5; lbl.TextColor3 = C_GREEN
            promptLbl.TextColor3 = C_GREEN2
            statusLbl.Text = "[OFF]"; statusLbl.TextColor3 = C_GREEN2
        end
        callback(state)
    end)
end

local scrollFrameRef
local function buildPlayerSelectGui(parent)
    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(1,-12,1,-12); panel.Position = UDim2.new(0,6,0,6)
    panel.BackgroundTransparency = 1; panel.ZIndex = 10; panel.Parent = parent
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1,0,1,0); scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0; scrollFrame.ScrollBarThickness = 3
    scrollFrame.ScrollBarImageColor3 = C_GREEN; scrollFrame.CanvasSize = UDim2.new(0,0,0,0)
    scrollFrame.ZIndex = 11; scrollFrame.Parent = panel
    local scrollLayout = Instance.new("UIListLayout")
    scrollLayout.Padding = UDim.new(0,2); scrollLayout.SortOrder = Enum.SortOrder.Name
    scrollLayout.Parent = scrollFrame
    scrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0,0,0,scrollLayout.AbsoluteContentSize.Y + 6)
    end)
    scrollFrameRef = scrollFrame
end

local function makePlayerButton(targetPlayer)
    if targetPlayer == plr then return end
    if playerButtons[targetPlayer] then return end
    if not scrollFrameRef then return end
    local btn = Instance.new("Frame")
    btn.Size = UDim2.new(1,-4,0,22); btn.BackgroundColor3 = Color3.fromRGB(0,10,3)
    btn.BackgroundTransparency = 0.3; btn.BorderSizePixel = 0
    btn.ZIndex = 11; btn.Parent = scrollFrameRef
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,2)
    local stroke = Instance.new("UIStroke"); stroke.Thickness = 1
    stroke.Color = C_GREEN2; stroke.Transparency = 0.5; stroke.Parent = btn
    local statusDot = Instance.new("Frame")
    statusDot.Size = UDim2.new(0,5,0,5); statusDot.Position = UDim2.new(0,6,0.5,-2.5)
    statusDot.BackgroundColor3 = C_GREEN2; statusDot.BorderSizePixel = 0
    statusDot.ZIndex = 12; statusDot.Parent = btn
    Instance.new("UICorner", statusDot).CornerRadius = UDim.new(1,0)
    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1,-50,1,0); nameLbl.Position = UDim2.new(0,16,0,0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = string.upper(targetPlayer.DisplayName)
    nameLbl.TextColor3 = C_GREEN; nameLbl.TextSize = 10
    nameLbl.Font = Enum.Font.Code; nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
    nameLbl.ZIndex = 12; nameLbl.Parent = btn
    local tpBtn = Instance.new("TextButton")
    tpBtn.Size = UDim2.new(0,26,0,16); tpBtn.Position = UDim2.new(1,-30,0.5,-8)
    tpBtn.BackgroundColor3 = Color3.fromRGB(0,30,15); tpBtn.BackgroundTransparency = 0.3
    tpBtn.Text = "TP"; tpBtn.TextColor3 = C_GREEN; tpBtn.TextSize = 9
    tpBtn.Font = Enum.Font.Code; tpBtn.BorderSizePixel = 0
    tpBtn.ZIndex = 14; tpBtn.Parent = btn
    Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0,2)
    local tpStroke = Instance.new("UIStroke"); tpStroke.Thickness = 1
    tpStroke.Color = C_GREEN; tpStroke.Transparency = 0.4; tpStroke.Parent = tpBtn
    bindClick(tpBtn, function()
        local myChar = plr.Character; if not myChar then return end
        local myHrp = myChar:FindFirstChild("HumanoidRootPart"); if not myHrp then return end
        local targetChar = targetPlayer.Character; if not targetChar then return end
        local targetHrp = targetChar:FindFirstChild("HumanoidRootPart"); if not targetHrp then return end
        local offset = -targetHrp.CFrame.LookVector * 3
        myHrp.CFrame = targetHrp.CFrame + offset + Vector3.new(0,1,0)
        tpBtn.TextColor3 = C_CYAN; tpStroke.Color = C_CYAN
        task.wait(0.3)
        if tpBtn and tpBtn.Parent then tpBtn.TextColor3 = C_GREEN; tpStroke.Color = C_GREEN end
    end)
    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1,-30,1,0); clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""; clickBtn.ZIndex = 13; clickBtn.Parent = btn
    bindClick(clickBtn, function()
        selectedPlayers[targetPlayer] = not selectedPlayers[targetPlayer]
        if selectedPlayers[targetPlayer] then
            statusDot.BackgroundColor3 = C_CYAN; stroke.Color = C_GREEN
            stroke.Transparency = 0.1; nameLbl.TextColor3 = C_CYAN
            btn.BackgroundColor3 = Color3.fromRGB(0,20,10)
        else
            statusDot.BackgroundColor3 = C_GREEN2; stroke.Color = C_GREEN2
            stroke.Transparency = 0.5; nameLbl.TextColor3 = C_GREEN
            btn.BackgroundColor3 = Color3.fromRGB(0,10,3)
        end
    end)
    playerButtons[targetPlayer] = {btn = btn, statusDot = statusDot, stroke = stroke, nameLbl = nameLbl}
end

local function removePlayerButton(targetPlayer)
    if playerButtons[targetPlayer] then
        local b = playerButtons[targetPlayer]
        if b.btn and b.btn.Parent then b.btn:Destroy() end
        playerButtons[targetPlayer] = nil
    end
end

local function createESP(targetPlayer)
    if targetPlayer == plr then return end
    if espData[targetPlayer] then return end
    local char = targetPlayer.Character; if not char then return end
    local highlight = Instance.new("Highlight")
    highlight.FillColor = C_GREEN; highlight.OutlineColor = C_CYAN
    highlight.FillTransparency = 0.6; highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = char; highlight.Enabled = false; highlight.Parent = char
    local head = char:FindFirstChild("Head"); local bb
    if head then
        bb = Instance.new("BillboardGui")
        bb.Size = UDim2.new(0,220,0,60); bb.StudsOffset = Vector3.new(0,3.5,0)
        bb.AlwaysOnTop = true; bb.MaxDistance = math.huge
        bb.Enabled = false; bb.Parent = head
        local p2 = Instance.new("Frame")
        p2.Size = UDim2.new(1,0,1,0); p2.BackgroundColor3 = Color3.fromRGB(0,5,2)
        p2.BackgroundTransparency = 0.3; p2.BorderSizePixel = 0; p2.Parent = bb
        Instance.new("UICorner", p2).CornerRadius = UDim.new(0,2)
        local s2 = Instance.new("UIStroke"); s2.Thickness = 1
        s2.Color = C_GREEN; s2.Transparency = 0.3; s2.Parent = p2
        local nameLbl = Instance.new("TextLabel")
        nameLbl.Size = UDim2.new(1,-8,0,22); nameLbl.Position = UDim2.new(0,4,0,4)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text = "> " .. string.upper(targetPlayer.DisplayName)
        nameLbl.TextColor3 = C_GREEN; nameLbl.TextSize = 13
        nameLbl.Font = Enum.Font.Code
        nameLbl.TextXAlignment = Enum.TextXAlignment.Center; nameLbl.Parent = p2
        local distLbl = Instance.new("TextLabel")
        distLbl.Size = UDim2.new(1,-8,0,14); distLbl.Position = UDim2.new(0,4,0,28)
        distLbl.BackgroundTransparency = 1; distLbl.Text = "DIST: 0.0m"
        distLbl.TextColor3 = C_GREEN2; distLbl.TextSize = 10
        distLbl.Font = Enum.Font.Code
        distLbl.TextXAlignment = Enum.TextXAlignment.Center; distLbl.Parent = p2
        local hpBg = Instance.new("Frame")
        hpBg.Size = UDim2.new(1,-8,0,4); hpBg.Position = UDim2.new(0,4,1,-7)
        hpBg.BackgroundColor3 = Color3.fromRGB(0,10,3); hpBg.BorderSizePixel = 0; hpBg.Parent = p2
        local hpFill = Instance.new("Frame")
        hpFill.Size = UDim2.new(1,0,1,0); hpFill.BackgroundColor3 = C_GREEN
        hpFill.BorderSizePixel = 0; hpFill.Parent = hpBg
        espData[targetPlayer] = {highlight = highlight, billboard = bb, distLbl = distLbl, hpFill = hpFill}
    else
        espData[targetPlayer] = {highlight = highlight}
    end
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not targetPlayer or not targetPlayer.Parent then
            if conn then conn:Disconnect() end; return
        end
        local data = espData[targetPlayer]; if not data then return end
        local isSelected = selectedPlayers[targetPlayer] == true
        if data.highlight then data.highlight.Enabled = isSelected end
        if data.billboard then data.billboard.Enabled = isSelected end
        if not isSelected then return end
        local c = targetPlayer.Character; if not c then return end
        local hrp = c:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local myChar = plr.Character; if not myChar then return end
        local myHrp = myChar:FindFirstChild("HumanoidRootPart"); if not myHrp then return end
        local dist = (hrp.Position - myHrp.Position).Magnitude
        if data.distLbl then
            data.distLbl.Text = string.format("DIST: %.1fm", dist)
            if dist < 30 then
                data.distLbl.TextColor3 = C_RED
                if data.highlight then data.highlight.FillColor = C_RED; data.highlight.OutlineColor = C_RED end
            elseif dist < 100 then
                data.distLbl.TextColor3 = C_YELLOW
                if data.highlight then data.highlight.FillColor = C_YELLOW; data.highlight.OutlineColor = C_YELLOW end
            else
                data.distLbl.TextColor3 = C_GREEN
                if data.highlight then data.highlight.FillColor = C_GREEN; data.highlight.OutlineColor = C_CYAN end
            end
        end
        local hum = c:FindFirstChildOfClass("Humanoid")
        if hum and data.hpFill then
            local ratio = hum.Health / hum.MaxHealth
            data.hpFill.Size = UDim2.new(ratio,0,1,0)
            if ratio > 0.6 then data.hpFill.BackgroundColor3 = C_GREEN
            elseif ratio > 0.3 then data.hpFill.BackgroundColor3 = C_YELLOW
            else data.hpFill.BackgroundColor3 = C_RED end
        end
    end)
    espData[targetPlayer].conn = conn
end

local function removeESP(targetPlayer)
    if espData[targetPlayer] then
        local d = espData[targetPlayer]
        if d.highlight and d.highlight.Parent then d.highlight:Destroy() end
        if d.billboard and d.billboard.Parent then d.billboard:Destroy() end
        if d.conn then d.conn:Disconnect() end
        espData[targetPlayer] = nil
    end
end

local gui = Instance.new("ScreenGui")
gui.Name = "NeonProgramGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = guiParent

------------------------------------------------------------
-- 横線オーバーレイ
------------------------------------------------------------
local scanOverlay = Instance.new("ScreenGui")
scanOverlay.Name = "ScanlinesOverlay"
scanOverlay.ResetOnSpawn = false
scanOverlay.IgnoreGuiInset = true
scanOverlay.DisplayOrder = 998
scanOverlay.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
scanOverlay.Parent = guiParent

local scanContainer = Instance.new("Frame")
scanContainer.Size = UDim2.new(1, 0, 1, 0)
scanContainer.BackgroundTransparency = 1
scanContainer.BorderSizePixel = 0
scanContainer.ZIndex = 1
scanContainer.Parent = scanOverlay

task.spawn(function()
    task.wait(0.1)
    local screenHeight = scanContainer.AbsoluteSize.Y
    if screenHeight <= 0 then screenHeight = 1080 end
    local count = 0
    for y = 0, screenHeight, 3 do
        local line = Instance.new("Frame")
        line.Size = UDim2.new(1, 0, 0, 1)
        line.Position = UDim2.new(0, 0, 0, y)
        line.BackgroundColor3 = C_GREEN
        line.BackgroundTransparency = 0.85
        line.BorderSizePixel = 0
        line.ZIndex = 1
        line.Parent = scanContainer
        count = count + 1
        if count % 100 == 0 then task.wait() end
    end
end)

------------------------------------------------------------
-- KEY入力画面
------------------------------------------------------------
local keyScreen = Instance.new("Frame")
keyScreen.Size = UDim2.new(1,0,1,0); keyScreen.BackgroundColor3 = C_BG
keyScreen.BackgroundTransparency = 0.1; keyScreen.BorderSizePixel = 0
keyScreen.ZIndex = 10; keyScreen.Parent = gui

addTerminalCorners(keyScreen, C_GREEN, 30, 3)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,60); title.Position = UDim2.new(0,0,0.17,0)
title.BackgroundTransparency = 1; title.Text = "[ ACCESS TERMINAL ]"
title.TextColor3 = C_GREEN; title.TextStrokeTransparency = 1
title.TextSize = 42; title.Font = Enum.Font.Code
title.ZIndex = 11; title.Parent = keyScreen

local inputPanel = Instance.new("Frame")
inputPanel.Size = UDim2.new(0,450,0,120)
inputPanel.Position = UDim2.new(0.5,-225,0.45,0)
inputPanel.BackgroundColor3 = C_PANEL; inputPanel.BackgroundTransparency = 0.05
inputPanel.BorderSizePixel = 0; inputPanel.ZIndex = 11; inputPanel.Parent = keyScreen
Instance.new("UICorner", inputPanel).CornerRadius = UDim.new(0,3)
addTerminalCorners(inputPanel, C_GREEN, 12, 13)

local keyBox = Instance.new("TextBox")
keyBox.Size = UDim2.new(1,-24,0,48); keyBox.Position = UDim2.new(0,12,0,26)
keyBox.BackgroundColor3 = Color3.fromRGB(0,8,3); keyBox.BackgroundTransparency = 0.1
keyBox.TextColor3 = C_GREEN; keyBox.PlaceholderText = "> enter key _"
keyBox.PlaceholderColor3 = C_GREEN2; keyBox.Text = ""
keyBox.TextSize = 20; keyBox.Font = Enum.Font.Code
keyBox.ClearTextOnFocus = false; keyBox.BorderSizePixel = 0
keyBox.ZIndex = 14; keyBox.Parent = inputPanel
Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0,2)

local verifyBtn = Instance.new("TextButton")
verifyBtn.Size = UDim2.new(1,-24,0,30); verifyBtn.Position = UDim2.new(0,12,1,-40)
verifyBtn.BackgroundColor3 = Color3.fromRGB(0,15,5); verifyBtn.BackgroundTransparency = 0.3
verifyBtn.TextColor3 = C_GREEN; verifyBtn.Text = "> VERIFY"
verifyBtn.TextSize = 12; verifyBtn.Font = Enum.Font.Code
verifyBtn.BorderSizePixel = 0; verifyBtn.ZIndex = 14; verifyBtn.Parent = inputPanel
Instance.new("UICorner", verifyBtn).CornerRadius = UDim.new(0,2)

local statusLbl = Instance.new("TextLabel")
statusLbl.Size = UDim2.new(1,0,0,30); statusLbl.Position = UDim2.new(0,0,0.66,0)
statusLbl.BackgroundTransparency = 1; statusLbl.Text = ""
statusLbl.TextColor3 = C_RED; statusLbl.TextSize = 16
statusLbl.Font = Enum.Font.Code; statusLbl.ZIndex = 11; statusLbl.Parent = keyScreen

------------------------------------------------------------
-- ロード画面
------------------------------------------------------------
local loadScreen = Instance.new("Frame")
loadScreen.Size = UDim2.new(1,0,1,0); loadScreen.BackgroundColor3 = C_BG
loadScreen.BackgroundTransparency = 0.1; loadScreen.BorderSizePixel = 0
loadScreen.ZIndex = 20; loadScreen.Visible = false; loadScreen.Parent = gui

local loadTitle = Instance.new("TextLabel")
loadTitle.Size = UDim2.new(1,0,0,50); loadTitle.Position = UDim2.new(0,0,0.15,0)
loadTitle.BackgroundTransparency = 1; loadTitle.Text = "[ LOADING ]"
loadTitle.TextColor3 = C_GREEN; loadTitle.TextSize = 36
loadTitle.Font = Enum.Font.Code; loadTitle.ZIndex = 24; loadTitle.Parent = loadScreen

local logFrame = Instance.new("Frame")
logFrame.Size = UDim2.new(0,540,0,220); logFrame.Position = UDim2.new(0.5,-270,0.35,0)
logFrame.BackgroundColor3 = C_PANEL; logFrame.BackgroundTransparency = 0.05
logFrame.BorderSizePixel = 0; logFrame.ZIndex = 24; logFrame.Parent = loadScreen
Instance.new("UICorner", logFrame).CornerRadius = UDim.new(0,3)
addTerminalCorners(logFrame, C_GREEN, 12, 26)

local logContainer = Instance.new("Frame")
logContainer.Size = UDim2.new(1,-20,1,-20); logContainer.Position = UDim2.new(0,10,0,10)
logContainer.BackgroundTransparency = 1; logContainer.ZIndex = 27; logContainer.Parent = logFrame
local logLayout = Instance.new("UIListLayout")
logLayout.Padding = UDim.new(0,3); logLayout.Parent = logContainer

local barFrame = Instance.new("Frame")
barFrame.Size = UDim2.new(0,540,0,20); barFrame.Position = UDim2.new(0.5,-270,0.75,0)
barFrame.BackgroundColor3 = Color3.fromRGB(0,8,3); barFrame.BackgroundTransparency = 0.2
barFrame.BorderSizePixel = 0; barFrame.ZIndex = 24; barFrame.Parent = loadScreen

local SEG_COUNT = 50
local segFrames = {}
for i = 1, SEG_COUNT do
    local seg = Instance.new("Frame")
    seg.Size = UDim2.new(1/SEG_COUNT - 0.005, 0, 1, 0)
    seg.Position = UDim2.new((i-1)/SEG_COUNT, 0, 0, 0)
    seg.BackgroundColor3 = C_GREEN2; seg.BorderSizePixel = 0
    seg.ZIndex = 25; seg.Parent = barFrame
    table.insert(segFrames, seg)
end

------------------------------------------------------------
-- 右上FPSパネル
------------------------------------------------------------
local fpsPanel = Instance.new("Frame")
fpsPanel.Size = UDim2.new(0,170,0,60); fpsPanel.Position = UDim2.new(1,-180,0,16)
fpsPanel.BackgroundColor3 = C_PANEL; fpsPanel.BackgroundTransparency = 0.1
fpsPanel.BorderSizePixel = 0; fpsPanel.ZIndex = 50
fpsPanel.Visible = false; fpsPanel.Parent = gui
Instance.new("UICorner", fpsPanel).CornerRadius = UDim.new(0,3)
addTerminalCorners(fpsPanel, C_GREEN, 8, 52)

local fpsHeader = Instance.new("TextLabel")
fpsHeader.Size = UDim2.new(1,-8,0,14); fpsHeader.Position = UDim2.new(0,6,0,2)
fpsHeader.BackgroundTransparency = 1; fpsHeader.Text = "> PERFORMANCE"
fpsHeader.TextColor3 = C_GREEN; fpsHeader.TextSize = 9
fpsHeader.Font = Enum.Font.Code
fpsHeader.TextXAlignment = Enum.TextXAlignment.Left
fpsHeader.ZIndex = 53; fpsHeader.Parent = fpsPanel

local fpsLbl = Instance.new("TextLabel")
fpsLbl.Size = UDim2.new(0,80,0,16); fpsLbl.Position = UDim2.new(0,6,0,20)
fpsLbl.BackgroundTransparency = 1; fpsLbl.Text = "FPS: 60"
fpsLbl.TextColor3 = C_GREEN; fpsLbl.TextSize = 11
fpsLbl.Font = Enum.Font.Code
fpsLbl.TextXAlignment = Enum.TextXAlignment.Left
fpsLbl.ZIndex = 53; fpsLbl.Parent = fpsPanel

local msLbl = Instance.new("TextLabel")
msLbl.Size = UDim2.new(0,80,0,16); msLbl.Position = UDim2.new(1,-86,0,20)
msLbl.BackgroundTransparency = 1; msLbl.Text = "MS: 16.7"
msLbl.TextColor3 = C_GREEN2; msLbl.TextSize = 11
msLbl.Font = Enum.Font.Code
msLbl.TextXAlignment = Enum.TextXAlignment.Right
msLbl.ZIndex = 53; msLbl.Parent = fpsPanel

local fpsStatus = Instance.new("TextLabel")
fpsStatus.Size = UDim2.new(1,-8,0,12); fpsStatus.Position = UDim2.new(0,6,1,-16)
fpsStatus.BackgroundTransparency = 1; fpsStatus.Text = "> RUNNING"
fpsStatus.TextColor3 = C_GREEN2; fpsStatus.TextSize = 9
fpsStatus.Font = Enum.Font.Code
fpsStatus.TextXAlignment = Enum.TextXAlignment.Left
fpsStatus.ZIndex = 53; fpsStatus.Parent = fpsPanel

task.spawn(function()
    while gui.Parent do
        task.wait(0.25)
        fpsLbl.Text = "FPS: " .. fpsValue
        msLbl.Text = string.format("MS: %.1f", msValue)
        if fpsValue < 30 then
            fpsLbl.TextColor3 = C_RED
            fpsStatus.Text = "> CRITICAL"
            fpsStatus.TextColor3 = C_RED
        elseif fpsValue < 50 then
            fpsLbl.TextColor3 = C_YELLOW
            fpsStatus.Text = "> WARNING"
            fpsStatus.TextColor3 = C_YELLOW
        else
            fpsLbl.TextColor3 = C_GREEN
            fpsStatus.Text = "> RUNNING"
            fpsStatus.TextColor3 = C_GREEN2
        end
    end
end)

------------------------------------------------------------
-- メインUI
------------------------------------------------------------
local mainUI = Instance.new("Frame")
mainUI.Size = UDim2.new(0,260,0,380)
mainUI.Position = UDim2.new(0,20,0.5,-190)
mainUI.BackgroundColor3 = C_PANEL; mainUI.BackgroundTransparency = 0.2
mainUI.BorderSizePixel = 0; mainUI.Visible = false
mainUI.ZIndex = 100; mainUI.Parent = gui
Instance.new("UICorner", mainUI).CornerRadius = UDim.new(0,3)
addTerminalCorners(mainUI, C_GREEN, 12, 103)

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1,0,0,26); titleBar.BackgroundColor3 = C_GREEN
titleBar.BackgroundTransparency = 0.7; titleBar.BorderSizePixel = 0
titleBar.ZIndex = 104; titleBar.Parent = mainUI

local titleBarLbl = Instance.new("TextLabel")
titleBarLbl.Size = UDim2.new(1,-70,1,0); titleBarLbl.Position = UDim2.new(0,10,0,0)
titleBarLbl.BackgroundTransparency = 1
titleBarLbl.Text = "> NEON_PROGRAM"
titleBarLbl.TextColor3 = C_GREEN; titleBarLbl.TextSize = 11
titleBarLbl.Font = Enum.Font.Code
titleBarLbl.TextXAlignment = Enum.TextXAlignment.Left
titleBarLbl.ZIndex = 105; titleBarLbl.Parent = titleBar

local musicBtn = Instance.new("TextButton")
musicBtn.Size = UDim2.new(0, 22, 1, 0)
musicBtn.Position = UDim2.new(1, -44, 0, 0)
musicBtn.BackgroundColor3 = C_GREEN
musicBtn.BackgroundTransparency = 0.5
musicBtn.Text = "♪"
musicBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
musicBtn.TextSize = 12
musicBtn.Font = Enum.Font.GothamBold
musicBtn.BorderSizePixel = 0
musicBtn.ZIndex = 105
musicBtn.Parent = titleBar
bindClick(musicBtn, function()
    if musicInstance then stopMusic(); musicBtn.TextColor3 = C_GREEN2
    else startMusic(); musicBtn.TextColor3 = Color3.fromRGB(255, 255, 255) end
end)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0,22,1,0); closeBtn.Position = UDim2.new(1,-22,0,0)
closeBtn.BackgroundColor3 = C_RED; closeBtn.BackgroundTransparency = 0.5
closeBtn.Text = "✕"; closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.TextSize = 11; closeBtn.Font = Enum.Font.Code
closeBtn.BorderSizePixel = 0; closeBtn.ZIndex = 105; closeBtn.Parent = titleBar
makeDraggable(mainUI, titleBar)

-- ★ ハブ開閉用フローティングボタン
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 44, 0, 44)
toggleBtn.Position = UDim2.new(0, 20, 0.5, 200)
toggleBtn.BackgroundColor3 = C_PANEL
toggleBtn.BackgroundTransparency = 0.15
toggleBtn.Text = ">_"
toggleBtn.TextColor3 = C_GREEN
toggleBtn.TextSize = 16
toggleBtn.Font = Enum.Font.Code
toggleBtn.BorderSizePixel = 0
toggleBtn.AutoButtonColor = false
toggleBtn.Visible = false
toggleBtn.ZIndex = 200
toggleBtn.Parent = gui
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 4)
addTerminalCorners(toggleBtn, C_GREEN, 8, 202)

local function setHubVisible(v)
    mainUI.Visible = v
    toggleBtn.Visible = not v
end

bindClick(toggleBtn, function()
    setHubVisible(true)
end)

bindClick(closeBtn, function()
    setHubVisible(false)
end)

-- ★ キーボードショートカット（右Shiftで開閉）
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not authed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        setHubVisible(not mainUI.Visible)
    end
end)

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1,0,0,22); tabBar.Position = UDim2.new(0,0,0,26)
tabBar.BackgroundColor3 = Color3.fromRGB(0,5,2); tabBar.BackgroundTransparency = 0.3
tabBar.BorderSizePixel = 0; tabBar.ZIndex = 104; tabBar.Parent = mainUI

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0,1); tabLayout.Parent = tabBar

local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1,-12,1,-60); contentArea.Position = UDim2.new(0,6,0,54)
contentArea.BackgroundColor3 = Color3.fromRGB(0,5,2)
contentArea.BackgroundTransparency = 0.3; contentArea.BorderSizePixel = 0
contentArea.ZIndex = 104; contentArea.Parent = mainUI
Instance.new("UICorner", contentArea).CornerRadius = UDim.new(0,2)

local tabs = {}
local tabContents = {}

local function selectTab(tabName)
    for name, tab in pairs(tabs) do
        if name == tabName then
            tab.TextColor3 = C_GREEN
            tab.BackgroundColor3 = Color3.fromRGB(0,30,10)
            tab.BackgroundTransparency = 0.3
            tab.Text = "[ " .. tab:GetAttribute("label") .. " ]"
        else
            tab.TextColor3 = C_GREEN2
            tab.BackgroundColor3 = Color3.fromRGB(0,8,3)
            tab.BackgroundTransparency = 0.4
            tab.Text = " " .. tab:GetAttribute("label") .. " "
        end
    end
    for name, content in pairs(tabContents) do
        content.Visible = (name == tabName)
    end
end

local function makeTab(name, label)
    local tab = Instance.new("TextButton")
    tab.Size = UDim2.new(0,48,1,0); tab.BackgroundColor3 = Color3.fromRGB(0,8,3)
    tab.BackgroundTransparency = 0.4; tab.TextColor3 = C_GREEN2
    tab.Text = " " .. label .. " "; tab.TextSize = 9
    tab.Font = Enum.Font.Code; tab.BorderSizePixel = 0
    tab.ZIndex = 105; tab:SetAttribute("label", label); tab.Parent = tabBar
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1,0,1,0); content.BackgroundTransparency = 1
    content.Visible = false; content.ZIndex = 105; content.Parent = contentArea
    bindClick(tab, function() selectTab(name) end)
    tabs[name] = tab; tabContents[name] = content
    return content
end

local tabMain = makeTab("main", "MAIN")
local tabMove = makeTab("move", "MOVE")
local tabVisual = makeTab("visual", "VISUAL")
local tabAnti = makeTab("anti", "ANTI")
local tabPlayers = makeTab("players", "PLAYERS")

------------------------------------------------------------
-- MAIN タブ
------------------------------------------------------------
local fovLbl = Instance.new("TextLabel")
fovLbl.Size = UDim2.new(1,-12,0,14); fovLbl.Position = UDim2.new(0,6,0,8)
fovLbl.BackgroundTransparency = 1
fovLbl.Text = "> FOV := " .. math.floor(currentFOV)
fovLbl.TextColor3 = C_GREEN; fovLbl.TextSize = 11
fovLbl.Font = Enum.Font.Code
fovLbl.TextXAlignment = Enum.TextXAlignment.Left
fovLbl.ZIndex = 106; fovLbl.Parent = tabMain

local fovMinus = Instance.new("TextButton")
fovMinus.Size = UDim2.new(0,30,0,20); fovMinus.Position = UDim2.new(0,6,0,26)
fovMinus.BackgroundColor3 = Color3.fromRGB(0,15,5)
fovMinus.BackgroundTransparency = 0.3; fovMinus.Text = "[-]"
fovMinus.TextColor3 = C_GREEN; fovMinus.TextSize = 11
fovMinus.Font = Enum.Font.Code; fovMinus.BorderSizePixel = 0
fovMinus.ZIndex = 106; fovMinus.Parent = tabMain

local fovPlus = Instance.new("TextButton")
fovPlus.Size = UDim2.new(0,30,0,20); fovPlus.Position = UDim2.new(0,40,0,26)
fovPlus.BackgroundColor3 = Color3.fromRGB(0,15,5)
fovPlus.BackgroundTransparency = 0.3; fovPlus.Text = "[+]"
fovPlus.TextColor3 = C_GREEN; fovPlus.TextSize = 11
fovPlus.Font = Enum.Font.Code; fovPlus.BorderSizePixel = 0
fovPlus.ZIndex = 106; fovPlus.Parent = tabMain

local fovReset = Instance.new("TextButton")
fovReset.Size = UDim2.new(0,80,0,20); fovReset.Position = UDim2.new(0,74,0,26)
fovReset.BackgroundColor3 = Color3.fromRGB(15,0,15)
fovReset.BackgroundTransparency = 0.3; fovReset.Text = "[RESET]"
fovReset.TextColor3 = C_PURPLE; fovReset.TextSize = 10
fovReset.Font = Enum.Font.Code; fovReset.BorderSizePixel = 0
fovReset.ZIndex = 106; fovReset.Parent = tabMain

local function updateFOV(v)
    v = math.clamp(v, 30, 120)
    currentFOV = v; cam.FieldOfView = v
    fovLbl.Text = "> FOV := " .. math.floor(v)
end
bindClick(fovMinus, function() updateFOV(currentFOV - 5) end)
bindClick(fovPlus, function() updateFOV(currentFOV + 5) end)
bindClick(fovReset, function() updateFOV(defaultFOV) end)

local speedLbl = Instance.new("TextLabel")
speedLbl.Size = UDim2.new(1,-12,0,14); speedLbl.Position = UDim2.new(0,6,0,54)
speedLbl.BackgroundTransparency = 1; speedLbl.Text = "> SPEED := 16"
speedLbl.TextColor3 = C_GREEN; speedLbl.TextSize = 11
speedLbl.Font = Enum.Font.Code
speedLbl.TextXAlignment = Enum.TextXAlignment.Left
speedLbl.ZIndex = 106; speedLbl.Parent = tabMain

local speedMinus = Instance.new("TextButton")
speedMinus.Size = UDim2.new(0,30,0,20); speedMinus.Position = UDim2.new(0,6,0,72)
speedMinus.BackgroundColor3 = Color3.fromRGB(0,15,5)
speedMinus.BackgroundTransparency = 0.3; speedMinus.Text = "[-]"
speedMinus.TextColor3 = C_GREEN; speedMinus.TextSize = 11
speedMinus.Font = Enum.Font.Code; speedMinus.BorderSizePixel = 0
speedMinus.ZIndex = 106; speedMinus.Parent = tabMain

local speedPlus = Instance.new("TextButton")
speedPlus.Size = UDim2.new(0,30,0,20); speedPlus.Position = UDim2.new(0,40,0,72)
speedPlus.BackgroundColor3 = Color3.fromRGB(0,15,5)
speedPlus.BackgroundTransparency = 0.3; speedPlus.Text = "[+]"
speedPlus.TextColor3 = C_GREEN; speedPlus.TextSize = 11
speedPlus.Font = Enum.Font.Code; speedPlus.BorderSizePixel = 0
speedPlus.ZIndex = 106; speedPlus.Parent = tabMain

bindClick(speedMinus, function()
    speedValue = math.max(0, speedValue - 5)
    speedLbl.Text = "> SPEED := " .. math.floor(speedValue)
    if speedEnabled then applySpeed() end
end)
bindClick(speedPlus, function()
    speedValue = math.min(500, speedValue + 5)
    speedLbl.Text = "> SPEED := " .. math.floor(speedValue)
    if speedEnabled then applySpeed() end
end)

local jumpLbl = Instance.new("TextLabel")
jumpLbl.Size = UDim2.new(1,-12,0,14); jumpLbl.Position = UDim2.new(0,6,0,100)
jumpLbl.BackgroundTransparency = 1; jumpLbl.Text = "> JUMP := 50"
jumpLbl.TextColor3 = C_GREEN; jumpLbl.TextSize = 11
jumpLbl.Font = Enum.Font.Code
jumpLbl.TextXAlignment = Enum.TextXAlignment.Left
jumpLbl.ZIndex = 106; jumpLbl.Parent = tabMain

local jumpMinus = Instance.new("TextButton")
jumpMinus.Size = UDim2.new(0,30,0,20); jumpMinus.Position = UDim2.new(0,6,0,118)
jumpMinus.BackgroundColor3 = Color3.fromRGB(0,15,5)
jumpMinus.BackgroundTransparency = 0.3; jumpMinus.Text = "[-]"
jumpMinus.TextColor3 = C_GREEN; jumpMinus.TextSize = 11
jumpMinus.Font = Enum.Font.Code; jumpMinus.BorderSizePixel = 0
jumpMinus.ZIndex = 106; jumpMinus.Parent = tabMain

local jumpPlus = Instance.new("TextButton")
jumpPlus.Size = UDim2.new(0,30,0,20); jumpPlus.Position = UDim2.new(0,40,0,118)
jumpPlus.BackgroundColor3 = Color3.fromRGB(0,15,5)
jumpPlus.BackgroundTransparency = 0.3; jumpPlus.Text = "[+]"
jumpPlus.TextColor3 = C_GREEN; jumpPlus.TextSize = 11
jumpPlus.Font = Enum.Font.Code; jumpPlus.BorderSizePixel = 0
jumpPlus.ZIndex = 106; jumpPlus.Parent = tabMain

bindClick(jumpMinus, function()
    jumpValue = math.max(0, jumpValue - 10)
    jumpLbl.Text = "> JUMP := " .. math.floor(jumpValue)
    if jumpEnabled then applyJump() end
end)
bindClick(jumpPlus, function()
    jumpValue = math.min(500, jumpValue + 10)
    jumpLbl.Text = "> JUMP := " .. math.floor(jumpValue)
    if jumpEnabled then applyJump() end
end)

------------------------------------------------------------
-- MOVE タブ
------------------------------------------------------------
makeToggle(tabMove, "FLY", 6, function(state)
    if state then startFly() else stopFly() end
end)
makeToggle(tabMove, "SPEED_HACK", 34, function(state)
    speedEnabled = state; applySpeed()
end)
makeToggle(tabMove, "JUMP_POWER", 62, function(state)
    jumpEnabled = state; applyJump()
end)
makeToggle(tabMove, "INFINITE_JUMP", 90, function(state)
    infJumpEnabled = state
end)

------------------------------------------------------------
-- VISUAL タブ
------------------------------------------------------------
makeToggle(tabVisual, "FULLBRIGHT", 6, function(state)
    fullbrightEnabled = state; applyFullbright()
end)
makeToggle(tabVisual, "NO_FOG", 34, function(state)
    noFogEnabled = state; applyNoFog()
end)
makeToggle(tabVisual, "TRACER", 62, function(state)
    tracerEnabled = state
    if not state then
        for _, t in pairs(tracers) do if t.line and t.line.Parent then t.line:Destroy() end end
        tracers = {}
    end
end)

------------------------------------------------------------
-- ANTI タブ
------------------------------------------------------------
makeToggle(tabAnti, "ANTI_KICK", 6, function(state)
    antiKickEnabled = state
    if state then startAntiKick() end
end)
makeToggle(tabAnti, "ANTI_FLING", 34, function(state)
    antiFlingEnabled = state
    if state then startAntiFling() end
end)
makeToggle(tabAnti, "ANTI_GRAB", 62, function(state)
    antiGrabEnabled = state
    if state then startAntiGrab() end
end)
makeToggle(tabAnti, "ANTI_VOID", 90, function(state)
    antiVoidEnabled = state
    if state then startAntiVoid() end
end)
makeToggle(tabAnti, "ANTI_TELEPORT", 118, function(state)
    antiTeleportEnabled = state
    if state then
        local c = plr.Character
        if c then
            local hrp = c:FindFirstChild("HumanoidRootPart")
            if hrp then lastCFrame = hrp.CFrame end
        end
        startAntiTeleport()
    end
end)
makeToggle(tabAnti, "ANTI_ANCHOR", 146, function(state)
    antiAnchorEnabled = state
    if state then startAntiAnchor() end
end)

local protectionLbl = Instance.new("TextLabel")
protectionLbl.Size = UDim2.new(1,-12,0,14)
protectionLbl.Position = UDim2.new(0,6,0,178)
protectionLbl.BackgroundTransparency = 1
protectionLbl.Text = "  DEFENDED: 0"
protectionLbl.TextColor3 = C_CYAN
protectionLbl.TextSize = 10
protectionLbl.Font = Enum.Font.Code
protectionLbl.TextXAlignment = Enum.TextXAlignment.Left
protectionLbl.ZIndex = 106
protectionLbl.Parent = tabAnti

task.spawn(function()
    while gui.Parent do
        task.wait(0.3)
        protectionLbl.Text = "  DEFENDED: " .. protectionCount
    end
end)

buildPlayerSelectGui(tabPlayers)

local function runLoadSequence()
    keyScreen.Visible = false; loadScreen.Visible = true
    for _, c in ipairs(logContainer:GetChildren()) do
        if c:IsA("TextLabel") then c:Destroy() end
    end
    for _, seg in ipairs(segFrames) do seg.BackgroundColor3 = C_GREEN2 end
    task.wait(0.3)
    local steps = {
        {"[ OK ] boot sequence", 12},
        {"[ OK ] loading kernel modules", 28},
        {"[ OK ] scanning network", 45},
        {"[ OK ] mounting ESP subsystem", 62},
        {"[ OK ] loading ANTI drivers", 78},
        {"[ OK ] initializing visual engine", 92},
        {"[ OK ] system ready", 100},
    }
    for _, step in ipairs(steps) do
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1,0,0,16); lbl.BackgroundTransparency = 1
        lbl.Text = "  " .. step[1]; lbl.TextColor3 = C_GREEN2
        lbl.TextSize = 11; lbl.Font = Enum.Font.Code
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 28; lbl.Parent = logContainer
        task.wait(0.4)
        local segCount = math.floor(SEG_COUNT * step[2] / 100)
        for i = 1, segCount do
            if segFrames[i] then segFrames[i].BackgroundColor3 = C_GREEN end
        end
        lbl.Text = "  " .. step[1]; lbl.TextColor3 = C_GREEN
    end
    loadTitle.Text = "[ SYSTEM READY ]"
    loadTitle.TextColor3 = C_GREEN
    task.wait(0.5)
end

local function onAuthSuccess()
    if authed then return end
    authed = true
    statusLbl.Text = "> ACCESS_GRANTED"
    statusLbl.TextColor3 = C_GREEN
    task.wait(0.6)
    task.spawn(function()
        runLoadSequence()
        loadScreen.Visible = false
        keyScreen.Visible = false
        mainUI.Visible = true
        toggleBtn.Visible = false   -- ★ ハブが開いている時はボタン非表示
        fpsPanel.Visible = true
        selectTab("main")
        startMusic()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= plr then
                makePlayerButton(p)
                if p.Character then createESP(p) end
                p.CharacterAdded:Connect(function()
                    task.wait(1); removeESP(p); createESP(p)
                end)
            end
        end
        Players.PlayerAdded:Connect(function(p)
            task.wait(1.5)
            if p ~= plr then
                makePlayerButton(p)
                if p.Character then createESP(p) end
                p.CharacterAdded:Connect(function()
                    task.wait(1); removeESP(p); createESP(p)
                end)
            end
        end)
        Players.PlayerRemoving:Connect(function(p)
            removeESP(p); removePlayerButton(p); selectedPlayers[p] = nil
        end)
        print("[NeonProgram] 起動完了")
    end)
end

local function verify()
    if authed then return end
    if keyBox.Text:lower() == plr.DisplayName:lower() then
        onAuthSuccess()
    else
        statusLbl.Text = "> ACCESS_DENIED"
        statusLbl.TextColor3 = C_RED
        keyBox.Text = ""
    end
end

bindClick(verifyBtn, verify)
keyBox.FocusLost:Connect(function(entered)
    if entered then verify() end
end)

task.wait(0.3)
keyBox:CaptureFocus()

print("[NeonProgram] Key = " .. plr.DisplayName)
