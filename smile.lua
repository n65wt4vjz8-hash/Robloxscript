local player=game.Players.LocalPlayer
local RS=game:GetService("RunService")
local CG=game:GetService("CoreGui")
local Lighting=game:GetService("Lighting")

local oldAmbient=Lighting.Ambient
local oldOutdoor=Lighting.OutdoorAmbient
local oldBrightness=Lighting.Brightness
local oldColorShift_Top=Lighting.ColorShift_Top
local oldColorShift_Bottom=Lighting.ColorShift_Bottom
local oldFogColor=Lighting.FogColor
local oldFogEnd=Lighting.FogEnd
local oldFogStart=Lighting.FogStart
local oldClockTime=Lighting.ClockTime

Lighting.Ambient=Color3.fromRGB(255,255,255)
Lighting.OutdoorAmbient=Color3.fromRGB(255,255,255)
Lighting.Brightness=3
Lighting.ColorShift_Top=Color3.fromRGB(255,255,255)
Lighting.ColorShift_Bottom=Color3.fromRGB(255,255,255)
Lighting.FogColor=Color3.fromRGB(255,255,255)
Lighting.FogStart=0
Lighting.FogEnd=300
Lighting.ClockTime=14
Lighting.GlobalShadows=false

local whiteOverlay=Instance.new("Frame")
whiteOverlay.Size=UDim2.new(1,0,1,0)
whiteOverlay.BackgroundColor3=Color3.fromRGB(255,255,255)
whiteOverlay.BackgroundTransparency=0.3
whiteOverlay.BorderSizePixel=0
whiteOverlay.ZIndex=100
whiteOverlay.Parent=CG

local sunLight=Instance.new("PointLight")
sunLight.Name="SunLight"
sunLight.Brightness=10
sunLight.Range=200
sunLight.Color=Color3.fromRGB(255,255,255)
sunLight.Parent=workspace

local originalSounds={}
for _,v in ipairs(game:GetDescendants()) do
    if v:IsA("Sound") then
        originalSounds[v]={volume=v.Volume}
        v.Volume=10
    end
end

local soundConn=RS.Heartbeat:Connect(function()
    for _,v in ipairs(game:GetDescendants()) do
        if v:IsA("Sound") and v.Volume<10 then
            v.Volume=10
        end
    end
end)

local flashTime=0
local flashConn=RS.Heartbeat:Connect(function(dt)
    flashTime=flashTime+dt
    whiteOverlay.BackgroundTransparency=0.2+math.sin(flashTime*2)*0.15
    Lighting.Brightness=3+math.sin(flashTime*3)*1
end)

getgenv().StopSmile=function()
    if flashConn then flashConn:Disconnect() end
    if soundConn then soundConn:Disconnect() end
    if sunLight and sunLight.Parent then sunLight:Destroy() end
    if whiteOverlay and whiteOverlay.Parent then whiteOverlay:Destroy() end
    Lighting.Ambient=oldAmbient
    Lighting.OutdoorAmbient=oldOutdoor
    Lighting.Brightness=oldBrightness
    Lighting.ColorShift_Top=oldColorShift_Top
    Lighting.ColorShift_Bottom=oldColorShift_Bottom
    Lighting.FogColor=oldFogColor
    Lighting.FogEnd=oldFogEnd
    Lighting.FogStart=oldFogStart
    Lighting.ClockTime=oldClockTime
    for s,data in pairs(originalSounds) do
        if s and s.Parent then
            s.Volume=data.volume
        end
    end
    warn("Smile 停止")
end

task.spawn(function()
    task.wait(15)
    if flashConn then flashConn:Disconnect() end
    if soundConn then soundConn:Disconnect() end
    local kickMessage="You have been blessed. Ascend to the light."
    player:Kick(kickMessage)
end)

warn("Smile 起動")
warn("15秒後にキックします...")
