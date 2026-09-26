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

local hue=0

local trailParts={}
local trailAttachments={}

local function getHRP()
    local char=player.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function removeTrail()
    for _,v in ipairs(trailParts) do
        if v and v.Parent then v:Destroy() end
    end
    for _,v in ipairs(trailAttachments) do
        if v and v.Parent then v:Destroy() end
    end
    trailParts={}
    trailAttachments={}
end

local function createTrail()
    local char=player.Character
    if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    for i=1,3 do
        local attachment=Instance.new("Attachment")
        attachment.Name="RainbowTrail_"..i
        local offset=Vector3.new(
            math.cos(i*2)*2,
            0,
            math.sin(i*2)*2
        )
        attachment.Position=offset
        attachment.Parent=hrp
        table.insert(trailAttachments,attachment)
        
        local trail=Instance.new("Trail")
        trail.Name="RainbowTrail_"..i
        trail.Attachment0=attachment
        trail.Attachment1=attachment
        trail.Lifetime=1
        trail.MinLength=0
        trail.LightEmission=1
        trail.LightInfluence=0
        trail.WidthScale=NumberSequence.new({
            NumberSequenceKeypoint.new(0,1),
            NumberSequenceKeypoint.new(1,0)
        })
        trail.Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),
            ColorSequenceKeypoint.new(0.17,Color3.fromRGB(255,255,0)),
            ColorSequenceKeypoint.new(0.33,Color3.fromRGB(0,255,0)),
            ColorSequenceKeypoint.new(0.5,Color3.fromRGB(0,255,255)),
            ColorSequenceKeypoint.new(0.67,Color3.fromRGB(0,0,255)),
            ColorSequenceKeypoint.new(0.83,Color3.fromRGB(255,0,255)),
            ColorSequenceKeypoint.new(1,Color3.fromRGB(255,0,0))
        })
        trail.Parent=hrp
        table.insert(trailParts,trail)
    end
end

local hueTime=0
local conn=RS.Heartbeat:Connect(function(dt)
    hueTime=hueTime+dt
    hue=(hue+hueTime*0.2)%1
    local color=Color3.fromHSV(hue,1,1)
    local color2=Color3.fromHSV((hue+0.33)%1,1,1)
    local color3=Color3.fromHSV((hue+0.67)%1,1,1)
    
    Lighting.Ambient=color
    Lighting.OutdoorAmbient=color2
    Lighting.Brightness=2
    Lighting.ColorShift_Top=color
    Lighting.ColorShift_Bottom=color2
    Lighting.FogColor=color3
    Lighting.FogStart=0
    Lighting.FogEnd=500
end)

local trailConn=RS.Heartbeat:Connect(function()
    for i,trail in ipairs(trailParts) do
        if trail and trail.Parent then
            local localHue=(hue+i*0.1)%1
            local c1=Color3.fromHSV(localHue,1,1)
            local c2=Color3.fromHSV((localHue+0.17)%1,1,1)
            local c3=Color3.fromHSV((localHue+0.33)%1,1,1)
            local c4=Color3.fromHSV((localHue+0.5)%1,1,1)
            local c5=Color3.fromHSV((localHue+0.67)%1,1,1)
            local c6=Color3.fromHSV((localHue+0.83)%1,1,1)
            trail.Color=ColorSequence.new({
                ColorSequenceKeypoint.new(0,c1),
                ColorSequenceKeypoint.new(0.17,c2),
                ColorSequenceKeypoint.new(0.33,c3),
                ColorSequenceKeypoint.new(0.5,c4),
                ColorSequenceKeypoint.new(0.67,c5),
                ColorSequenceKeypoint.new(0.83,c6),
                ColorSequenceKeypoint.new(1,c1)
            })
        end
    end
end)

local function start()
    createTrail()
end

if player.Character then
    start()
else
    player.CharacterAdded:Wait()
    task.wait(1)
    start()
end

player.CharacterAdded:Connect(function()
    task.wait(1)
    removeTrail()
    createTrail()
end)

getgenv().StopRainbow=function()
    if conn then conn:Disconnect() end
    if trailConn then trailConn:Disconnect() end
    removeTrail()
    Lighting.Ambient=oldAmbient
    Lighting.OutdoorAmbient=oldOutdoor
    Lighting.Brightness=oldBrightness
    Lighting.ColorShift_Top=oldColorShift_Top
    Lighting.ColorShift_Bottom=oldColorShift_Bottom
    Lighting.FogColor=oldFogColor
    warn("Rainbow 停止")
end

warn("Rainbow 起動")
warn("止めるには: getgenv().StopRainbow()")
