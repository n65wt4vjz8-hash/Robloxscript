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
redOverlay.BackgroundTransparency=0.6
redOverlay.BorderSizePixel=0
redOverlay.ZIndex=1
redOverlay.Parent=gui

local vignette=Instance.new("ImageLabel")
vignette.Size=UDim2.new(1,0,1,0)
vignette.BackgroundTransparency=1
vignette.Image="rbxassetid://5028857084"
vignette.ImageColor3=Color3.fromRGB(255,0,0)
vignette.ImageTransparency=0.4
vignette.ZIndex=3
vignette.Parent=gui

local warnLabel=Instance.new("TextLabel")
warnLabel.Size=UDim2.new(0.8,0,0.3,0)
warnLabel.Position=UDim2.new(0.1,0,0.35,0)
warnLabel.BackgroundTransparency=1
warnLabel.Text="⚠ VIRUS DETECTED ⚠"
warnLabel.TextColor3=Color3.fromRGB(255,0,0)
warnLabel.TextStrokeTransparency=0
warnLabel.TextStrokeColor3=Color3.fromRGB(0,0,0)
warnLabel.Font=Enum.Font.GothamBlack
warnLabel.TextSize=48
warnLabel.ZIndex=10
warnLabel.Parent=gui

local timerLabel=Instance.new("TextLabel")
timerLabel.Size=UDim2.new(1,0,0.2,0)
timerLabel.Position=UDim2.new(0,0,0.55,0)
timerLabel.BackgroundTransparency=1
timerLabel.Text=""
timerLabel.TextColor3=Color3.fromRGB(255,0,0)
timerLabel.TextStrokeTransparency=0
timerLabel.TextStrokeColor3=Color3.fromRGB(0,0,0)
timerLabel.Font=Enum.Font.GothamBlack
timerLabel.TextSize=80
timerLabel.ZIndex=10
timerLabel.Parent=gui

local noise=Instance.new("Sound")
noise.Name="ScaryNoise"
noise.SoundId="rbxassetid://1837879082"
noise.Volume=0.5
noise.Looped=true
noise.Parent=workspace
noise:Play()

local blinkTime=0
local blinkState=0
local conn=RS.Heartbeat:Connect(function(dt)
    blinkTime=blinkTime+dt
    if blinkTime>0.1 then
        blinkTime=0
        blinkState=1-blinkState
        if blinkState==1 then
            redOverlay.BackgroundTransparency=0.4
        else
            redOverlay.BackgroundTransparency=0.7
        end
    end
    vignette.ImageTransparency=0.3+math.sin(tick()*5)*0.15
    warnLabel.TextTransparency=0.2+math.sin(tick()*8)*0.2
end)

local oldAmbient=Lighting.Ambient
local oldOutdoor=Lighting.OutdoorAmbient
local oldBrightness=Lighting.Brightness
Lighting.Ambient=Color3.fromRGB(30,0,0)
Lighting.OutdoorAmbient=Color3.fromRGB(30,0,0)
Lighting.Brightness=0.5

local kickMessage="Your PC (or smartphone) has been infected with two types of viruses. Please take immediate action."

getgenv().StopScary=function()
    if conn then conn:Disconnect() end
    if gui then gui:Destroy() end
    if noise then noise:Destroy() end
    Lighting.Ambient=oldAmbient
    Lighting.OutdoorAmbient=oldOutdoor
    Lighting.Brightness=oldBrightness
    player.CameraMode=Enum.CameraMode.Classic
    player.CameraMaxZoomDistance=128
    player.CameraMinZoomDistance=0.5
    warn("Scary 停止")
end

warn("Scary 起動")
warn("10秒後にキックします...")

task.spawn(function()
    for i=10,1,-1 do
        timerLabel.Text=tostring(i)
        noise.Volume=0.5+(10-i)*0.05
        task.wait(1)
    end
    timerLabel.Text="0"
    task.wait(0.3)
    warnLabel.Text="SYSTEM FAILURE"
    task.wait(0.3)
    if conn then conn:Disconnect() end
    player:Kick(kickMessage)
end)
