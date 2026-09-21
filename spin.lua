local player=game.Players.LocalPlayer
local UIS=game:GetService("UserInputService")
local CG=game:GetService("CoreGui")
local gui=Instance.new("ScreenGui")
gui.Name="DeltaSpin"
gui.ResetOnSpawn=false
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end
local frame=Instance.new("Frame")
frame.Size=UDim2.new(0,180,0,130)
frame.Position=UDim2.new(0.05,0,0.4,0)
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
title.Text="Spin"
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
local btn=Instance.new("TextButton")
btn.Size=UDim2.new(0.9,0,0,32)
btn.Position=UDim2.new(0.05,0,0.24,0)
btn.BackgroundColor3=Color3.fromRGB(60,60,70)
btn.Text="SPIN: OFF"
btn.TextColor3=Color3.fromRGB(255,255,255)
btn.Font=Enum.Font.GothamBold
btn.TextSize=14
btn.Parent=frame
local bc=Instance.new("UICorner")
bc.CornerRadius=UDim.new(0,6)
bc.Parent=btn
local lbl=Instance.new("TextLabel")
lbl.Size=UDim2.new(0.5,0,0,26)
lbl.Position=UDim2.new(0.25,0,0.55,0)
lbl.BackgroundTransparency=1
lbl.Text="Speed: 100"
lbl.TextColor3=Color3.fromRGB(200,220,255)
lbl.Font=Enum.Font.GothamBold
lbl.TextSize=12
lbl.Parent=frame
local minus=Instance.new("TextButton")
minus.Size=UDim2.new(0.18,0,0,26)
minus.Position=UDim2.new(0.05,0,0.55,0)
minus.BackgroundColor3=Color3.fromRGB(70,50,50)
minus.Text="−"
minus.TextColor3=Color3.fromRGB(255,255,255)
minus.Font=Enum.Font.GothamBold
minus.TextSize=16
minus.Parent=frame
local mc=Instance.new("UICorner")
mc.CornerRadius=UDim.new(0,6)
mc.Parent=minus
local plus=Instance.new("TextButton")
plus.Size=UDim2.new(0.18,0,0,26)
plus.Position=UDim2.new(0.77,0,0.55,0)
plus.BackgroundColor3=Color3.fromRGB(50,70,50)
plus.Text="＋"
plus.TextColor3=Color3.fromRGB(255,255,255)
plus.Font=Enum.Font.GothamBold
plus.TextSize=14
plus.Parent=frame
local pc=Instance.new("UICorner")
pc.CornerRadius=UDim.new(0,6)
pc.Parent=plus
local reset=Instance.new("TextButton")
reset.Size=UDim2.new(0.9,0,0,22)
reset.Position=UDim2.new(0.05,0,0.78,0)
reset.BackgroundColor3=Color3.fromRGB(45,45,55)
reset.Text="Reset"
reset.TextColor3=Color3.fromRGB(220,220,220)
reset.Font=Enum.Font.Gotham
reset.TextSize=11
reset.Parent=frame
local rc=Instance.new("UICorner")
rc.CornerRadius=UDim.new(0,6)
rc.Parent=reset
local enabled=false
local speed=100
local spinParts={}
local function isSpinning(part)
    for _,p in ipairs(spinParts) do
        if p.part==part then return true end
    end
    return false
end
local function removeSpin(part)
    for i,p in ipairs(spinParts) do
        if p.part==part then
            if p.bav then p.bav:Destroy() end
            table.remove(spinParts,i)
            return
        end
    end
end
local function addSpin(part)
    if isSpinning(part) then return end
    if not part:IsA("BasePart") then return end
    local bav=Instance.new("BodyAngularVelocity")
    bav.MaxTorque=Vector3.new(0,1e5,0)
    bav.AngularVelocity=Vector3.new(0,speed,0)
    bav.Parent=part
    table.insert(spinParts,{part=part,bav=bav})
end
task.spawn(function()
    while true do
        if enabled then
            for _,obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and not obj.Anchored then
                    local parent=obj.Parent
                    if parent and (parent.Name:lower():find("grab") or parent.Name:lower():find("hold") or parent.Name:lower():find("carry") or parent.Name:lower():find("blob")) then
                        addSpin(obj)
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)
UIS.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.UserInputType~=Enum.UserInputType.Touch then return end
    local pos=input.Position
    local ray=workspace.CurrentCamera:ViewportPointToRay(pos.X,pos.Y)
    local params=RaycastParams.new()
    params.FilterDescendantsInstances={player.Character}
    params.FilterType=Enum.RaycastFilterType.Exclude
    local result=workspace:Raycast(ray.Origin,ray.Direction*500,params)
    if result and result.Instance then
        if isSpinning(result.Instance) then
            removeSpin(result.Instance)
        else
            addSpin(result.Instance)
        end
    end
end)
btn.MouseButton1Click:Connect(function()
    enabled=not enabled
    if enabled then
        btn.Text="SPIN: ON"
        btn.BackgroundColor3=Color3.fromRGB(0,150,80)
    else
        btn.Text="SPIN: OFF"
        btn.BackgroundColor3=Color3.fromRGB(60,60,70)
        for _,p in ipairs(spinParts) do
            if p.bav then p.bav:Destroy() end
        end
        spinParts={}
    end
end)
minus.MouseButton1Click:Connect(function()
    speed=math.max(10,speed-10)
    lbl.Text="Speed: "..speed
    for _,p in ipairs(spinParts) do
        if p.bav and p.bav.Parent then
            p.bav.AngularVelocity=Vector3.new(0,speed,0)
        end
    end
end)
plus.MouseButton1Click:Connect(function()
    speed=math.min(1000,speed+10)
    lbl.Text="Speed: "..speed
    for _,p in ipairs(spinParts) do
        if p.bav and p.bav.Parent then
            p.bav.AngularVelocity=Vector3.new(0,speed,0)
        end
    end
end)
reset.MouseButton1Click:Connect(function()
    speed=100
    lbl.Text="Speed: "..speed
    for _,p in ipairs(spinParts) do
        if p.bav and p.bav.Parent then
            p.bav.AngularVelocity=Vector3.new(0,speed,0)
        end
    end
end)
player.CharacterAdded:Connect(function()
    if enabled then
        enabled=false
        btn.Text="SPIN: OFF"
        btn.BackgroundColor3=Color3.fromRGB(60,60,70)
        for _,p in ipairs(spinParts) do
            if p.bav then p.bav:Destroy() end
        end
        spinParts={}
    end
end)
