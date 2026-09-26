local player=game.Players.LocalPlayer
local RS=game:GetService("RunService")
local CG=game:GetService("CoreGui")
local gui=Instance.new("ScreenGui")
gui.Name="DeltaEggESP"
gui.ResetOnSpawn=false
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end
local frame=Instance.new("Frame")
frame.Size=UDim2.new(0,200,0,240)
frame.Position=UDim2.new(0.05,0,0.3,0)
frame.BackgroundColor3=Color3.fromRGB(20,20,25)
frame.BorderSizePixel=0
frame.Active=true
frame.Draggable=true
frame.Parent=gui
local fc=Instance.new("UICorner")
fc.CornerRadius=UDim.new(0,10)
fc.Parent=frame
local title=Instance.new("TextLabel")
title.Size=UDim2.new(1,0,0,24)
title.BackgroundColor3=Color3.fromRGB(35,35,45)
title.BorderSizePixel=0
title.Text="Egg ESP"
title.TextColor3=Color3.fromRGB(255,255,255)
title.Font=Enum.Font.GothamBold
title.TextSize=13
title.Parent=frame
local tc=Instance.new("UICorner")
tc.CornerRadius=UDim.new(0,10)
tc.Parent=title
local closeBtn=Instance.new("TextButton")
closeBtn.Size=UDim2.new(0,22,0,22)
closeBtn.Position=UDim2.new(1,-25,0,1)
closeBtn.BackgroundColor3=Color3.fromRGB(180,50,50)
closeBtn.Text="×"
closeBtn.TextColor3=Color3.fromRGB(255,255,255)
closeBtn.Font=Enum.Font.GothamBold
closeBtn.TextSize=14
closeBtn.Parent=title
local cc=Instance.new("UICorner")
cc.CornerRadius=UDim.new(0,5)
cc.Parent=closeBtn
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)
local eggTypes={
    {name="Common",keyword="common",color=Color3.fromRGB(200,200,200)},
    {name="Rare",keyword="rare",color=Color3.fromRGB(80,150,255)},
    {name="Epic",keyword="epic",color=Color3.fromRGB(180,80,255)},
    {name="Legendary",keyword="legend",color=Color3.fromRGB(255,180,50)},
    {name="Galaxy",keyword="galaxy",color=Color3.fromRGB(100,100,255)},
    {name="Black Hole",keyword="black",color=Color3.fromRGB(255,50,50)}
}
local enabled={}
local function makeToggle(eggType,y)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(0.9,0,0,24)
    b.Position=UDim2.new(0.05,0,y,0)
    b.BackgroundColor3=Color3.fromRGB(45,45,60)
    b.Text="☐ "..eggType.name
    b.TextColor3=eggType.color
    b.Font=Enum.Font.GothamBold
    b.TextSize=11
    b.Parent=frame
    local c=Instance.new("UICorner")
    c.CornerRadius=UDim.new(0,5)
    c.Parent=b
    enabled[eggType.keyword]=false
    b.MouseButton1Click:Connect(function()
        enabled[eggType.keyword]=not enabled[eggType.keyword]
        if enabled[eggType.keyword] then
            b.Text="☑ "..eggType.name
            b.BackgroundColor3=Color3.fromRGB(0,100,60)
        else
            b.Text="☐ "..eggType.name
            b.BackgroundColor3=Color3.fromRGB(45,45,60)
        end
    end)
end
for i,eggType in ipairs(eggTypes) do
    makeToggle(eggType,30+(i-1)*26)
end
local tags={}
local function getEggType(name)
    local n=name:lower()
    if not n:find("egg") then return nil end
    for _,eggType in ipairs(eggTypes) do
        if n:find(eggType.keyword) then
            return eggType
        end
    end
    return nil
end
local function isEnabled(eggType)
    if not eggType then return false end
    return enabled[eggType.keyword]
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
    local hrp=getHRP()
    if not hrp then return end
    for _,obj in ipairs(workspace:GetDescendants()) do
        local eggType=getEggType(obj.Name)
        if eggType and isEnabled(eggType) and (obj:IsA("BasePart") or obj:IsA("Model")) then
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
        else
            local eggType=getEggType(obj.Name)
            if not eggType or not isEnabled(eggType) then
                data.tag.Enabled=false
            end
        end
    end
end
RS.RenderStepped:Connect(function()
    update()
end)
player.CharacterAdded:Connect(function()
    for obj,data in pairs(tags) do
        data.tag:Destroy()
    end
    tags={}
end)
