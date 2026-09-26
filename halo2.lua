local player=game.Players.LocalPlayer
local RS=game:GetService("RunService")
local CG=game:GetService("CoreGui")
local gui=Instance.new("ScreenGui")
gui.Name="DeltaHalo2"
gui.ResetOnSpawn=false
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end
local btn=Instance.new("TextButton")
btn.Size=UDim2.new(0,140,0,60)
btn.Position=UDim2.new(0.05,0,0.4,0)
btn.BackgroundColor3=Color3.fromRGB(60,60,70)
btn.Text="ANGEL: OFF"
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
local baseRadius=5
local radiusPulse=2
local rotationSpeed=2
local pulseSpeed=1
local heightOffset=2
local angle=0
local pulseTime=0
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
    pulseTime=pulseTime+dt*pulseSpeed*math.pi*2
    local currentRadius=baseRadius+math.sin(pulseTime)*radiusPulse
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
    local center=hrp.Position+Vector3.new(0,heightOffset,0)
    local total=#items
    for i,entry in ipairs(items) do
        local a=angle+(i/total)*math.pi*2
        local offset=Vector3.new(math.cos(a)*currentRadius,0,math.sin(a)*currentRadius)
        local targetPos=center+offset
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
        btn.Text="ANGEL: ON"
        btn.BackgroundColor3=Color3.fromRGB(0,150,80)
        lastTime=tick()
        pulseTime=0
    else
        btn.Text="ANGEL: OFF"
        btn.BackgroundColor3=Color3.fromRGB(60,60,70)
    end
end)
player.CharacterAdded:Connect(function()
    if enabled then
        enabled=false
        btn.Text="ANGEL: OFF"
        btn.BackgroundColor3=Color3.fromRGB(60,60,70)
    end
end)
