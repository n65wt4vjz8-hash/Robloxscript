local player=game.Players.LocalPlayer
local RS=game:GetService("RunService")
local CG=game:GetService("CoreGui")
local gui=Instance.new("ScreenGui")
gui.Name=tostring(math.random(100000,999999))
gui.ResetOnSpawn=false
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end
local btn=Instance.new("TextButton")
btn.Name=tostring(math.random(100000,999999))
btn.Size=UDim2.new(0,140,0,60)
btn.Position=UDim2.new(0.05,0,0.4,0)
btn.BackgroundColor3=Color3.fromRGB(60,60,70)
btn.Text="SHIELD: OFF"
btn.TextColor3=Color3.fromRGB(255,255,255)
btn.Font=Enum.Font.GothamBold
btn.TextSize=13
btn.Active=true
btn.Draggable=true
btn.Parent=gui
local bc=Instance.new("UICorner")
bc.CornerRadius=UDim.new(0,10)
bc.Parent=btn
local enabled=false
local radius=20
local power=300
local shield=nil
local shielded={}
local function getHRP()
    local char=player.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end
local function isPlayerPart(part)
    for _,pl in ipairs(game.Players:GetPlayers()) do
        if pl~=player then
            local char=pl.Character
            if char and part:IsDescendantOf(char) then return pl end
        end
    end
    return nil
end
local function blast(target)
    if not target then return end
    local char=target.Character
    if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local now=tick()
    if shielded[target] and now-shielded[target]<1 then return end
    shielded[target]=now
    local bv=Instance.new("BodyVelocity")
    bv.MaxForce=Vector3.new(1e5,1e6,1e5)
    local myHrp=getHRP()
    local dir=Vector3.new(0,1,0)
    if myHrp then
        dir=(hrp.Position-myHrp.Position)
        if dir.Magnitude<0.1 then
            dir=Vector3.new(math.random(-1,1),1,math.random(-1,1))
        end
        dir=dir.Unit
    end
    bv.Velocity=Vector3.new(
        dir.X*power*0.5,
        power,
        dir.Z*power*0.5
    )
    bv.Parent=hrp
    game:GetService("Debris"):AddItem(bv,0.5)
end
local function createShield()
    local hrp=getHRP()
    if not hrp then return nil end
    local s=Instance.new("Part")
    s.Name="GhostShield"
    s.Shape=Enum.PartType.Ball
    s.Size=Vector3.new(radius*2,radius*2,radius*2)
    s.Transparency=0.85
    s.Color=Color3.fromRGB(100,150,255)
    s.Material=Enum.Material.ForceField
    s.CanCollide=false
    s.Massless=true
    s.Anchored=false
    s.Parent=workspace
    local weld=Instance.new("WeldConstraint")
    weld.Part0=hrp
    weld.Part1=s
    weld.Parent=s
    s.CFrame=hrp.CFrame
    return s
end
local function removeShield()
    if shield and shield.Parent then
        shield:Destroy()
    end
    shield=nil
end
local function onTouched(hit)
    if not enabled then return end
    local pl=isPlayerPart(hit)
    if pl then
        blast(pl)
    end
end
btn.MouseButton1Click:Connect(function()
    enabled=not enabled
    if enabled then
        btn.Text="SHIELD: ON"
        btn.BackgroundColor3=Color3.fromRGB(0,150,80)
        shield=createShield()
        if shield then
            shield.Touched:Connect(onTouched)
        end
    else
        btn.Text="SHIELD: OFF"
        btn.BackgroundColor3=Color3.fromRGB(60,60,70)
        removeShield()
    end
end)
player.CharacterAdded:Connect(function()
    if enabled then
        task.wait(1)
        removeShield()
        shield=createShield()
        if shield then
            shield.Touched:Connect(onTouched)
        end
    end
end)
