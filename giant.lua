local player=game.Players.LocalPlayer
local RS=game:GetService("RunService")
local CG=game:GetService("CoreGui")
local Lighting=game:GetService("Lighting")

player.CameraMode=Enum.CameraMode.Classic
player.CameraMaxZoomDistance=128
player.CameraMinZoomDistance=0.5

local originalSounds={}
for _,v in ipairs(game:GetDescendants()) do
    if v:IsA("Sound") then
        originalSounds[v]={volume=v.Volume,playing=v.Playing}
        v.Volume=0
    end
end

local oldAmbient=Lighting.Ambient
local oldOutdoor=Lighting.OutdoorAmbient
local oldBrightness=Lighting.Brightness
local oldColorShift_Top=Lighting.ColorShift_Top
local oldColorShift_Bottom=Lighting.ColorShift_Bottom
local oldFogColor=Lighting.FogColor
local oldFogEnd=Lighting.FogEnd
local oldFogStart=Lighting.FogStart
local oldClockTime=Lighting.ClockTime

Lighting.Ambient=Color3.fromRGB(40,0,0)
Lighting.OutdoorAmbient=Color3.fromRGB(30,0,0)
Lighting.Brightness=0.5
Lighting.ColorShift_Top=Color3.fromRGB(150,0,0)
Lighting.ColorShift_Bottom=Color3.fromRGB(0,0,0)
Lighting.FogColor=Color3.fromRGB(20,0,0)
Lighting.FogStart=100
Lighting.FogEnd=500
Lighting.ClockTime=0
Lighting.GlobalShadows=true

local function getChar()
    return player.Character
end
local function getHRP()
    local char=getChar()
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local originalColors={}
local distortConn=nil
local distortTime=0

local function applySkin()
    local char=getChar()
    if not char then return end
    for _,part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            if not originalColors[part] then
                originalColors[part]={color=part.Color,size=part.Size}
            end
            part.Color=Color3.fromRGB(255,0,0)
            part.Material=Enum.Material.Neon
        end
    end
end

local function startDistort()
    if distortConn then return end
    distortConn=RS.Heartbeat:Connect(function(dt)
        distortTime=distortTime+dt
        local char=getChar()
        if not char then return end
        for _,part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                local orig=originalColors[part]
                if orig then
                    local sx=1+math.sin(distortTime*3+part.Position.X)*0.2
                    local sy=1+math.cos(distortTime*4+part.Position.Y)*0.2
                    local sz=1+math.sin(distortTime*5+part.Position.Z)*0.2
                    part.Size=Vector3.new(
                        orig.size.X*sx,
                        orig.size.Y*sy,
                        orig.size.Z*sz
                    )
                end
            end
        end
    end)
end

local giant=Instance.new("Part")
giant.Name="TheGiant"
giant.Size=Vector3.new(50,50,50)
giant.Color=Color3.fromRGB(0,0,0)
giant.Material=Enum.Material.Neon
giant.Anchored=true
giant.CanCollide=false
giant.Transparency=0
giant.Parent=workspace

local surfaceGui=Instance.new("SurfaceGui")
surfaceGui.Face=Enum.NormalId.Front
surfaceGui.Parent=giant

local noiseImage=Instance.new("ImageLabel")
noiseImage.Size=UDim2.new(1,0,1,0)
noiseImage.BackgroundTransparency=1
noiseImage.Image="rbxassetid://5028857084"
noiseImage.ImageColor3=Color3.fromRGB(255,0,0)
noiseImage.ImageTransparency=0.3
noiseImage.Parent=surfaceGui

local redLight=Instance.new("PointLight")
redLight.Brightness=5
redLight.Range=100
redLight.Color=Color3.fromRGB(255,0,0)
redLight.Parent=giant

local noise=Instance.new("Sound")
noise.Name="ScaryNoise"
noise.SoundId="rbxassetid://1837879082"
noise.Volume=0.1
noise.Looped=true
noise.Parent=workspace
noise:Play()

local gui=Instance.new("ScreenGui")
gui.Name=tostring(math.random(100000,999999))
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end

local redOverlay=Instance.new("Frame")
redOverlay.Size=UDim2.new(1,0,1,0)
redOverlay.BackgroundColor3=Color3.fromRGB(120,0,0)
redOverlay.BackgroundTransparency=0.6
redOverlay.BorderSizePixel=0
redOverlay.ZIndex=1
redOverlay.Parent=gui

local blackOverlay=Instance.new("Frame")
blackOverlay.Size=UDim2.new(1,0,1,0)
blackOverlay.BackgroundColor3=Color3.fromRGB(0,0,0)
blackOverlay.BackgroundTransparency=0.4
blackOverlay.BorderSizePixel=0
blackOverlay.ZIndex=2
blackOverlay.Parent=gui

local blinkTime=0
local blinkState=0
local conn=RS.Heartbeat:Connect(function(dt)
    blinkTime=blinkTime+dt
    if blinkTime>0.15 then
        blinkTime=0
        blinkState=1-blinkState
        if blinkState==1 then
            redOverlay.BackgroundTransparency=0.4
            blackOverlay.BackgroundTransparency=0.3
        else
            redOverlay.BackgroundTransparency=0.7
            blackOverlay.BackgroundTransparency=0.5
        end
    end
    surfaceGui.Rotation=math.random(-5,5)
end)

local startTime=tick()
local totalTime=10
local startPos=nil
local targetPos=nil
local zigzagOffset=0
local zigzagTime=0

local moveConn=RS.Heartbeat:Connect(function(dt)
    local hrp=getHRP()
    if not hrp then return end
    if not startPos then
        local look=hrp.CFrame.LookVector
        startPos=hrp.Position-look*500+Vector3.new(0,25,0)
        targetPos=hrp.Position
        giant.CFrame=CFrame.new(startPos)
    end
    local elapsed=tick()-startTime
    local progress=math.min(elapsed/totalTime,1)
    targetPos=hrp.Position
    local basePos=startPos+(targetPos-startPos)*progress
    zigzagTime=zigzagTime+dt
    zigzagOffset=math.sin(zigzagTime*3)*30
    local right=hrp.CFrame.RightVector
    local finalPos=basePos+right*zigzagOffset
    local rot=CFrame.Angles(
        zigzagTime*2,
        zigzagTime*3,
        zigzagTime*2.5
    )
    giant.CFrame=CFrame.new(finalPos)*rot
end)

task.spawn(function()
    local st=tick()
    while true do
        local elapsed=tick()-st
        if elapsed>=totalTime then break end
        local progress=elapsed/totalTime
        local volume=0.1+progress*progress*9.9
        noise.Volume=math.min(volume,10)
        task.wait(0.05)
    end
    noise.Volume=10
    task.wait(0.3)
end)

player.CharacterAdded:Connect(function()
    task.wait(1)
    applySkin()
    startDistort()
end)

if player.Character then
    applySkin()
    startDistort()
end

getgenv().StopGiant=function()
    if conn then conn:Disconnect() end
    if moveConn then moveConn:Disconnect() end
    if distortConn then distortConn:Disconnect() end
    if giant and giant.Parent then giant:Destroy() end
    if noise then noise:Destroy() end
    if redLight then redLight:Destroy() end
    if gui then gui:Destroy() end
    Lighting.Ambient=oldAmbient
    Lighting.OutdoorAmbient=oldOutdoor
    Lighting.Brightness=oldBrightness
    Lighting.ColorShift_Top=oldColorShift_Top
    Lighting.ColorShift_Bottom=oldColorShift_Bottom
    Lighting.FogColor=oldFogColor
    Lighting.FogEnd=oldFogEnd
    Lighting.FogStart=oldFogStart
    Lighting.ClockTime=oldClockTime
    player.CameraMode=Enum.CameraMode.Classic
    player.CameraMaxZoomDistance=128
    player.CameraMinZoomDistance=0.5
    local char=getChar()
    if char then
        for _,part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                local orig=originalColors[part]
                if orig then
                    part.Color=orig.color
                    part.Size=orig.size
                    part.Material=Enum.Material.Plastic
                end
            end
        end
    end
    for s,data in pairs(originalSounds) do
        if s and s.Parent then
            s.Volume=data.volume
        end
    end
    warn("Giant 停止")
end

task.spawn(function()
    task.wait(10)
    if conn then conn:Disconnect() end
    if moveConn then moveConn:Disconnect() end
    local kickMessage="Your PC (or smartphone) has been infected with two types of viruses. Please take immediate action."
    player:Kick(kickMessage)
end)

warn("Giant 起動")
warn("止めるには: getgenv().StopGiant()")
