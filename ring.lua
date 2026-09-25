local player=game.Players.LocalPlayer
local RS=game:GetService("RunService")
local CG=game:GetService("CoreGui")
local gui=Instance.new("ScreenGui")
gui.Name="DeltaRing"
gui.ResetOnSpawn=false
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end
local btn=Instance.new("TextButton")
btn.Size=UDim2.new(0,140,0,60)
btn.Position=UDim2.new(0.05,0,0.4,0)
btn.BackgroundColor3=Color3.fromRGB(60,60,70)
btn.Text="RING: OFF"
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
local radius=15
local rotationSpeed=8
local angle=0
local lastTime=tick()
local function isMissile(obj)
    if not obj:IsA("BasePart") and not obj:IsA("Model") then return false end
    local n=obj.Name:lower()
    if n:find("missile") or n:find("rocket") or n:find("projectile") then return true end
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
    local missiles={}
    for _,obj in ipairs(workspace:GetDescendants()) do
        if isMissile(obj) then
            local part=nil
            if obj:IsA("BasePart") then
                part=obj
            elseif obj:IsA("Model") then
                part=obj:FindFirstChildWhichIsA("BasePart")
            end
            if part then
                table.insert(missiles,{obj=obj,part=part})
            end
        end
    end
    if #missiles==0 then return end
    local center=hrp.Position
    for i,entry in ipairs(missiles) do
        local a=angle+(i/#missiles)*math.pi*2
        local offset=Vector3.new(math.cos(a)*radius,0,math.sin(a)*radius)
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
        btn.Text="RING: ON"
        btn.BackgroundColor3=Color3.fromRGB(0,150,80)
        lastTime=tick()
    else
        btn.Text="RING: OFF"
        btn.BackgroundColor3=Color3.fromRGB(60,60,70)
    end
end)
player.CharacterAdded:Connect(function()
    if enabled then
        enabled=false
        btn.Text="RING: OFF"
        btn.BackgroundColor3=Color3.fromRGB(60,60,70)
    end
end)
