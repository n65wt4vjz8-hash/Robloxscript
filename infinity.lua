local player=game.Players.LocalPlayer
local RS=game:GetService("RunService")
local CG=game:GetService("CoreGui")
local gui=Instance.new("ScreenGui")
gui.Name="DeltaInfinity"
gui.ResetOnSpawn=false
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end
local btn=Instance.new("TextButton")
btn.Size=UDim2.new(0,140,0,60)
btn.Position=UDim2.new(0.05,0,0.4,0)
btn.BackgroundColor3=Color3.fromRGB(60,60,70)
btn.Text="GAUNTLET: OFF"
btn.TextColor3=Color3.fromRGB(255,255,255)
btn.Font=Enum.Font.GothamBold
btn.TextSize=12
btn.Active=true
btn.Draggable=true
btn.Parent=gui
local bc=Instance.new("UICorner")
bc.CornerRadius=
UDim.new(0,10)
bc.Parent=   btn
local enabled=false
 locallocal gauntlet=nil
local jewels fire={}
local aura=nil
local gemData={
    {name="Space",color=Color3.fromRGB(50,100,255)},
    {name="Mind",color=Color3.fromRGB(255,220,50)},
    {name="Reality",color=Color3.fromRGB(255,50,50)},
    {name="Power",color=Color3.fromRGB(180,50,255)},
    {name="Time",color=Color3.fromRGB(50,255,100)},
    {name="Soul",color=Color3.fromRGB(255,150,50)}
}
local function getHand()
    local char=player.Character
    if not char then return nil end
    local hand=char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
    return hand
end
local function createGauntlet(hand)
    local g=Instance.new("Part")
    g.Name="InfinityGauntlet"
    g.Size=Vector3.new(1.4,1.4,1.4)
    g.Color=Color3.fromRGB(200,170,50)
    g.Material=Enum.Material.Metal
    g.CanCollide=false
    g.Massless=true
    g.Anchored=false
    g.Parent=workspace
    local weld=Instance.new("WeldConstraint")
    weld.Part0=hand
    weld.Part1=g
    weld.Parent=g
    g.CFrame=hand.CFrame
    local light=Instance.new("PointLight")
    light.Brightness=3
    light.Range=15
    light.Color=Color3.fromRGB(255,220,100)
    light.Parent=g
    local sparkles=Instance.new("Sparkles")
    sparkles.SparkleColor=Color3.fromRGB(255,220,100)
    sparkles.Parent=g=Instance.new("Fire")
    fire.Color=Color3.fromRGB(255,200,50)
    fire.SecondaryColor=Color3.fromRGB(255,100,50)
    fire.Size=3
    fire.Heat=2
    fire.Parent=g
    return g
end
local function createJewel(gauntlet,data,index)
    local j=Instance.new("Part")
    j.Name="Jewel_"..data.name
    j.Shape=Enum.PartType.Ball
    j.Size=Vector3.new(0.35,0.35,0.35)
    j.Color=data.color
    j.Material=Enum.Material.Neon
    j.CanCollide=false
    j.Massless=true
    j.Anchored=false
    j.Parent=workspace
    local angles=(index-1)*(math.pi*2/6)
    local offset=Vector3.new(
        math.cos(angles)*0.8,
        math.sin(angles)*0.8,
        0
    )
    local attach=Instance.new("Attachment")
    attach.Position=offset
    attach.Parent=gauntlet
    local weld=Instance.new("WeldConstraint")
    weld.Part0=gauntlet
    weld.Part1=j
    weld.Parent=j
    j.CFrame=gauntlet.CFrame*CFrame.new(offset)
    local light=Instance.new("PointLight")
    light.Brightness=4
    light.Range=10
    light.Color=data.color
    light.Parent=j
    return j
end
local function createAura(hand)
    local a=Instance.new("Part")
    a.Name="InfinityAura"
    a.Shape=Enum.PartType.Ball
    a.Size=Vector3.new(3,3,3)
    a.Color=Color3.fromRGB(255,200,100)
    a.Material=Enum.Material.ForceField
    a.Transparency=0.7
    a.CanCollide=false
    a.Massless=true
    a.Anchored=false
    a.Parent=workspace
    local weld=Instance.new("WeldConstraint")
    weld.Part0=hand
    weld.Part1=a
    weld.Parent=a
    a.CFrame=hand.CFrame
    return a
end
local function removeAll()
    if gauntlet and gauntlet.Parent then gauntlet:Destroy() end
    if aura and aura.Parent then aura:Destroy() end
    for _,j in ipairs(jewels) do
        if j and j.Parent then j:Destroy() end
    end
    gauntlet=nil
    aura=nil
    jewels={}
end
local function equip()
    local hand=getHand()
    if not hand then return end
    removeAll()
    gauntlet=createGauntlet(hand)
    for i,data in ipairs(gemData) do
        local j=createJewel(gauntlet,data,i)
        table.insert(jewels,j)
    end
    aura=createAura(hand)
end
btn.MouseButton1Click:Connect(function()
    enabled=not enabled
    if enabled then
        btn.Text="GAUNTLET: ON"
        btn.BackgroundColor3=Color3.fromRGB(0,150,80)
        equip()
    else
        btn.Text="GAUNTLET: OFF"
        btn.BackgroundColor3=Color3.fromRGB(60,60,70)
        removeAll()
    end
end)
player.CharacterAdded:Connect(function()
    if enabled then
        task.wait(1)
        equip()
    end
end)
