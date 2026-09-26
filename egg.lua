local player=game.Players.LocalPlayer
local RS=game:GetService("RunService")
local CG=game:GetService("CoreGui")
local gui=Instance.new("ScreenGui")
gui.Name="DeltaEggESP"
gui.ResetOnSpawn=false
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end
local btn=Instance.new("TextButton")
btn.Size=UDim2.new(0,140,0,60)
btn.Position=UDim2.new(0.05,0,0.4,0)
btn.BackgroundColor3=Color3.fromRGB(60,60,70)
btn.Text="EGG: OFF"
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
local eggTypes={
    {name="Common",keyword="common",color=Color3.fromRGB(200,200,200)},
    {name="Rare",keyword="rare",color=Color3.fromRGB(80,150,255)},
    {name="Epic",keyword="epic",color=Color3.fromRGB(180,80,255)},
    {name="Legendary",keyword="legend",color=Color3.fromRGB(255,180,50)},
    {name="Galaxy",keyword="galaxy",color=Color3.fromRGB(100,100,255)},
    {name="Black Hole",keyword="black",color=Color3.fromRGB(255,50,50)}
}
local tags={}
local function getEggType(name)
    local n=name:lower()
    if not n:find("egg") then return nil end
    for _,eggType in ipairs(eggTypes) do
        if n:find(eggType.keyword) then
            return eggType
        end
    end
    return {name="Egg",keyword="egg",color=Color3.fromRGB(255,255,255)}
end
local function createTag(obj,eggType)
    local box=Instance.new("BillboardGui")
    box.Name="EggESP_"..obj.Name
    box.Size=UDim2.new(0,150,0,50)
    box.StudsOffset=Vector3.new(0,3,0)
    box.AlwaysOnTop=true
    box.Parent=gui
    local label=Instance.new("TextLabel")
    label.Size=UDim2.new(1,0,0.5,0)
    label.BackgroundTransparency=1
    label.Text=obj.Name
    label.TextColor3=eggType.color
    label.TextStrokeTransparency=0
    label.TextStrokeColor3=Color3.fromRGB(0,0,0)
    label.Font=Enum.Font.GothamBold
    label.TextSize=13
    label.Parent=box
    local distLabel=Instance.new("TextLabel")
    distLabel.Size=UDim2.new(1,0,0.5,0)
    distLabel.Position=UDim2.new(0,0,0.5,0)
    distLabel.BackgroundTransparency=1
    distLabel.Text=""
    distLabel.TextColor3=Color3.fromRGB(255,255,255)
    distLabel.TextStrokeTransparency=0
    distLabel.TextStrokeColor3=Color3.fromRGB(0,0,0)
    distLabel.Font=Enum.Font.GothamBold
    distLabel.TextSize=11
    distLabel.Parent=box
    return box,distLabel
end
local function getHRP()
    local char=player.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end
local function update()
    if not enabled then return end
    local hrp=getHRP()
    if not hrp then return end
    for _,obj in ipairs(workspace:GetDescendants()) do
        local eggType=getEggType(obj.Name)
        if eggType and (obj:IsA("BasePart") or obj:IsA("Model")) then
            if not tags[obj] then
                local tag,distLabel=createTag(obj,eggType)
                tags[obj]={tag=tag,distLabel=distLabel,type=eggType}
            end
            local data=tags[obj]
            if data then
                local part=nil
                if obj:IsA("BasePart") then
                    part=obj
                elseif obj:IsA("Model") then
                    part=obj:FindFirstChildWhichIsA("BasePart")
                end
                if part then
                    data.tag.Adornee=part
                    data.tag.Enabled=true
                    local dist=(part.Position-hrp.Position).Magnitude
                    data.distLabel.Text=math.floor(dist).." studs"
                else
                    data.tag.Enabled=false
                end
            end
        end
    end
    for obj,data in pairs(tags) do
        if not obj.Parent then
            data.tag:Destroy()
            tags[obj]=nil
        end
    end
end
RS.RenderStepped:Connect(function()
    if enabled then
        update()
    end
end)
btn.MouseButton1Click:Connect(function()
    enabled=not enabled
    if enabled then
        btn.Text="EGG: ON"
        btn.BackgroundColor3=Color3.fromRGB(0,150,80)
        update()
    else
        btn.Text="EGG: OFF"
        btn.BackgroundColor3=Color3.fromRGB(60,60,70)
        for obj,data in pairs(tags) do
            data.tag.Enabled=false
        end
    end
end)
player.CharacterAdded:Connect(function()
    for obj,data in pairs(tags) do
        data.tag:Destroy()
    end
    tags={}
end)
