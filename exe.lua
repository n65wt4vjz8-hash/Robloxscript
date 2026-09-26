local player=game.Players.LocalPlayer
local RS=game:GetService("RunService")
local CG=game:GetService("CoreGui")
local Lighting=game:GetService("Lighting")

player.CameraMode=Enum.CameraMode.LockFirstPerson
player.CameraMaxZoomDistance=0.5
player.CameraMinZoomDistance=0.5

local gui=Instance.new("ScreenGui")
gui.Name=tostring(math.random(100000,999999))
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end

local redOverlay=Instance.new("Frame")
redOverlay.Size=UDim2.new(1,0,1,0)
redOverlay.BackgroundColor3=Color3.fromRGB(120,0,0)
redOverlay.BackgroundTransparency=0.7
redOverlay.BorderSizePixel=0
redOverlay.ZIndex=1
redOverlay.Parent=gui

local blackOverlay=Instance.new("Frame")
blackOverlay.Size=UDim2.new(1,0,1,0)
blackOverlay.BackgroundColor3=Color3.fromRGB(0,0,0)
blackOverlay.BackgroundTransparency=0.3
blackOverlay.BorderSizePixel=0
blackOverlay.ZIndex=2
blackOverlay.Parent=gui

local noise=Instance.new("Sound")
noise.Name="ScaryNoise"
noise.SoundId="rbxassetid://1837879082"
noise.Volume=0.1
noise.Looped=true
noise.Parent=workspace
noise:Play()

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
Lighting.Brightness=0
Lighting.ColorShift_Top=Color3.fromRGB(255,0,0)
Lighting.ColorShift_Bottom=Color3.fromRGB(0,0,0)
Lighting.FogColor=Color3.fromRGB(20,0,0)
Lighting.FogStart=0
Lighting.FogEnd=100
Lighting.ClockTime=0
Lighting.GlobalShadows=true

local redLight=Instance.new("PointLight")
redLight.Name="ScaryLight"
redLight.Brightness=3
redLight.Range=30
redLight.Color=Color3.fromRGB(255,0,0)
redLight.Parent=workspace

local blinkTime=0
local blinkState=0
local conn=RS.Heartbeat:Connect(function(dt)
    blinkTime=blinkTime+dt
    if blinkTime>0.15 then
        blinkTime=0
        blinkState=1-blinkState
        if blinkState==1 then
            redOverlay.BackgroundTransparency=0.5
            blackOverlay.BackgroundTransparency=0.2
        else
            redOverlay.BackgroundTransparency=0.8
            blackOverlay.BackgroundTransparency=0.5
        end
    end
    Lighting.ColorShift_Top=Color3.fromRGB(
        150+math.sin(tick()*8)*100,
        0,
        0
    )
end)

local kickMessage="Your PC (or smartphone) has been infected with two types of viruses. Please take immediate action."

getgenv().StopScary=function()
    if conn then conn:Disconnect() end
    if gui then gui:Destroy() end
    if noise then noise:Destroy() end
    if redLight then redLight:Destroy() end
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
    warn("Scary 停止")
end

warn("Scary 起動")
warn("10秒後にキックします...")

task.spawn(function()
    local totalTime=10
    local startTime=tick()
    while true do
        local elapsed=tick()-startTime
        if elapsed>=totalTime then break end
        local progress=elapsed/totalTime
        local volume=0.1+progress*progress*9.9
        noise.Volume=math.min(volume,10)
        task.wait(0.05)
    end
    noise.Volume=10
    task.wait(0.3)
    if conn then conn:Disconnect() end
    player:Kick(kickMessage)
end)
