local player=game.Players.LocalPlayer
local RS=game:GetService("RunService")
local CG=game:GetService("CoreGui")
local gui=Instance.new("ScreenGui")
gui.Name="DeltaWing"
gui.ResetOnSpawn=false
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end
local btn=Instance.new("TextButton")
btn.Size=UDim2.new(0,140,0,60)
btn.Position=UDim2.new(0.05,0,0.4,0)
btn.BackgroundColor3=Color3.fromRGB(60,60,70)
btn.Text="WING: OFF"
btn.TextColor3=Color3.fromRGB(255,255,255)
btn.Font=Enum.Font.GothamBold
btn.TextSize=12
btn.Active=true
btn.Draggable=true
btn.Parent=gui
local bc=Instance.new("UICorner")
bc.CornerRadius=UDim.new(0,10)
bc.Parent=btn
local enabled=false
local radius=25
local rotationSpeed=0.5
local swayHeight=3
local swaySpeed=0.5
local wingCount=5
local backOffset=3
local angle=0
local swayTime=0
local lastTime=tick()
local function isSparkler(obj)
    if not obj:IsA("BasePart") and not obj:IsA("Model") then return false end
    local n=obj.Name:lower()
    if n:find("spark") then return true end
    return false
end
local function getHRP()
    local char=player.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end
local function arrange()
    local hrp=getHRP()
    if not hrp then return end
    local now=tick()
    local dt=now-lastTime
    lastTime=now
    angle=angle+dt*rotationSpeed*math.pi*2
    if angle>math.pi*2 then angle=angle-math.pi*2 end
    swayTime=swayTime+dt*swaySpeed*math.pi*2
    local items={}
    for _,obj in ipairs(workspace:GetDescendants()) do
        if isSparkler(obj) then
            local part=nil
            if obj:IsA("BasePart") then
                part=obj
            elseif obj:IsA("Model") then
                part=obj:FindFirstChildWhichIsA("BasePart")
            end
            if part then
                table.insert(items,{obj=obj,part=part})
            end
        end
    end
    if #items==0 then return end
    local back=hrp.CFrame.LookVector*-backOffset
    local center=hrp.Position+back
    local total=math.min(#items,wingCount)
    local right=hrp.CFrame.RightVector
    local up=hrp.CFrame.UpVector
    local forward=-hrp.CFrame.LookVector
    for i=1,total do
        local entry=items[i]
        local halfIndex=math.ceil(total/2)
        local side
        local indexOnSide
        if i<=halfIndex then
            side=1
            indexOnSide=i
        else
            side=-1
            indexOnSide=i-halfIndex
        end
        local maxOnSide=math.max(halfIndex,total-halfIndex)
        local t=(indexOnSide-0.5)/maxOnSide
        local a=angle+t*math.pi
        local phase=t*math.pi
        local yOffset=math.sin(swayTime+phase)*swayHeight
        local r=radius*(0.5+0.5*t)
        local horizontal=math.cos(a)*r
        local depth=math.sin(a)*r*0.5
        local localOffset=right*(horizontal*side)+forward*depth+up*yOffset
        local worldOffset=localOffset
        local targetPos=center+worldOffset
        local part=entry.part
        if part and part.Parent then
            pcall(function()
                if entry.obj:IsA("Model") then
                    entry.obj:PivotTo(CFrame.new(targetPos))
                else
                    part.CFrame=CFrame.new(targetPos,center)
                end
            end)
        end
    end
end
RS.Heartbeat:Connect(function()
    if not enabled then return end
    arrange()
end)
btn.MouseButton1Click:Connect(function()
    enabled=not enabled
    if enabled then
        btn.Text="WING: ON"
        btn.BackgroundColor3=Color3.fromRGB(0,150,80)
        lastTime=tick()
        swayTime=0
    else
        btn.Text="WING: OFF"
        btn.BackgroundColor3=Color3.fromRGB(60,60,70)
    end
end)
player.CharacterAdded:Connect(function()
    if enabled then
        enabled=false
        btn.Text="WING: OFF"
        btn.BackgroundColor3=Color3.fromRGB(60,60,70)
    end
end)
