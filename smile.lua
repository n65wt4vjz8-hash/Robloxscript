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

local function getChar()
    return player.Character
end
local function getHRP()
    local char=getChar()
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local originalColors={}

local function applyGold()
    local char=getChar()
    if not char then return end
    for _,part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            if not originalColors[part] then
                originalColors[part]={color=part.Color,material=part.Material,transparency=part.Transparency}
            end
            part.Color=Color3.fromRGB(255,215,0)
            part.Material=Enum.Material.Neon
            part.Transparency=0
        end
    end
    local head=char:FindFirstChild("Head")
    if head then
        local face=head:FindFirstChildOfClass("Decal")
        if face then
            originalColors[face]={texture=face.Texture}
            face.Texture="rbxasset://textures/face.png"
        end
    end
end

local glowParts={}

local function createGlow()
    local char=getChar()
    if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local light=Instance.new("PointLight")
    light.Name="SmileLight"
    light.Brightness=5
    light.Range=30
    light.Color=Color3.fromRGB(255,215,0)
    light.Parent=hrp
    table.insert(glowParts,light)
    
    local attachment=Instance.new("Attachment")
    attachment.Name="SmileAttachment"
    attachment.Parent=hrp
    table.insert(glowParts,attachment)
    
    local emitter=Instance.new("ParticleEmitter")
    emitter.Name="SmileParticles"
    emitter.Texture="rbxassetid://243098098"
    emitter.Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,200)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(255,215,0))
    })
    emitter.Size=NumberSequence.new({
        NumberSequenceKeypoint.new(0,1),
        NumberSequenceKeypoint.new(1,3)
    })
    emitter.Transparency=NumberSequence.new({
        NumberSequenceKeypoint.new(0,0.3),
        NumberSequenceKeypoint.new(1,1)
    })
    emitter.Lifetime=NumberRange.new(1,3)
    emitter.Rate=50
    emitter.Speed=NumberRange.new(3,6)
    emitter.SpreadAngle=Vector2.new(360,360)
    emitter.Parent=attachment
    table.insert(glowParts,emitter)
    
    local sparkles=Instance.new("Sparkles")
    sparkles.SparkleColor=Color3.fromRGB(255,255,200)
    sparkles.Parent=hrp
    table.insert(glowParts,sparkles)
end

local sunLight=Instance.new("PointLight")
sunLight.Name="SunLight"
sunLight.Brightness=10
sunLight.Range=200
sunLight.Color=Color3.fromRGB(255,255,255)
sunLight.Parent=workspace

local flashTime=0
local flashConn=RS.Heartbeat:Connect(function(dt)
    flashTime=flashTime+dt
    whiteOverlay.BackgroundTransparency=0.2+math.sin(flashTime*2)*0.15
    Lighting.Brightness=3+math.sin(flashTime*3)*1
end)

player.CharacterAdded:Connect(function()
    task.wait(1)
    applyGold()
    createGlow()
end)

if player.Character then
    applyGold()
    createGlow()
end

getgenv().StopSmile=function()
    if flashConn then flashConn:Disconnect() end
    for _,v in ipairs(glowParts) do
        if v and v.Parent then v:Destroy() end
    end
    glowParts={}
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
    local char=getChar()
    if char then
        for _,part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                local orig=originalColors[part]
                if orig and orig.color then
                    part.Color=orig.color
                    part.Material=orig.material
                    part.Transparency=orig.transparency
                end
            elseif part:IsA("Decal") then
                local orig=originalColors[part]
                if orig and orig.texture then
                    part.Texture=orig.texture
                end
            end
        end
    end
    warn("Smile 停止")
end

task.spawn(function()
    task.wait(15)
    if flashConn then flashConn:Disconnect() end
    local kickMessage="You have been blessed. Ascend to the light."
    player:Kick(kickMessage)
end)

warn("Smile 起動")
warn("15秒後にキックします...")
