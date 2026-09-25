local player=game.Players.LocalPlayer
local CG=game:GetService("CoreGui")
local gui=Instance.new("ScreenGui")
gui.Name="DeltaMisairu"
gui.ResetOnSpawn=false
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end
local frame=Instance.new("Frame")
frame.Size=UDim2.new(0,180,0,110)
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
title.Text="Missile Ring"
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
local countLabel=Instance.new("TextLabel")
countLabel.Size=UDim2.new(0.5,0,0,24)
countLabel.Position=UDim2.new(0.25,0,0.28,0)
countLabel.BackgroundTransparency=1
countLabel.Text="Count: 8"
countLabel.TextColor3=Color3.fromRGB(200,220,255)
countLabel.Font=Enum.Font.GothamBold
countLabel.TextSize=12
countLabel.Parent=frame
local minusBtn=Instance.new("TextButton")
minusBtn.Size=UDim2.new(0.18,0,0,24)
minusBtn.Position=UDim2.new(0.05,0,0.28,0)
minusBtn.BackgroundColor3=Color3.fromRGB(70,50,50)
minusBtn.Text="−"
minusBtn.TextColor3=Color3.fromRGB(255,255,255)
minusBtn.Font=Enum.Font.GothamBold
minusBtn.TextSize=16
minusBtn.Parent=frame
local mbc=Instance.new("UICorner")
mbc.CornerRadius=UDim.new(0,6)
mbc.Parent=minusBtn
local plusBtn=Instance.new("TextButton")
plusBtn.Size=UDim2.new(0.18,0,0,24)
plusBtn.Position=UDim2.new(0.77,0,0.28,0)
plusBtn.BackgroundColor3=Color3.fromRGB(50,70,50)
plusBtn.Text="＋"
plusBtn.TextColor3=Color3.fromRGB(255,255,255)
plusBtn.Font=Enum.Font.GothamBold
plusBtn.TextSize=14
plusBtn.Parent=frame
local pbc=Instance.new("UICorner")
pbc.CornerRadius=UDim.new(0,6)
pbc.Parent=plusBtn
local fireBtn=Instance.new("TextButton")
fireBtn.Size=UDim2.new(0.9,0,0,32)
fireBtn.Position=UDim2.new(0.05,0,0.55,0)
fireBtn.BackgroundColor3=Color3.fromRGB(120,50,50)
fireBtn.Text="FIRE!"
fireBtn.TextColor3=Color3.fromRGB(255,255,255)
fireBtn.Font=Enum.Font.GothamBold
fireBtn.TextSize=14
fireBtn.Parent=frame
local fbc=Instance.new("UICorner")
fbc.CornerRadius=UDim.new(0,6)
fbc.Parent=fireBtn
local info=Instance.new("TextLabel")
info.Size=UDim2.new(1,0,0,14)
info.Position=UDim2.new(0,0,1,-16)
info.BackgroundTransparency=1
info.Text="Radius: 15"
info.TextColor3=Color3.fromRGB(150,160,180)
info.Font=Enum.Font.Gotham
info.TextSize=9
info.Parent=frame
local count=8
local radius=15
local function findMissileRemote()
    local RS2=game:GetService("ReplicatedStorage")
    for _,v in ipairs(RS2:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local n=v.Name:lower()
            if n:find("missile") or n:find("rocket") or n:find("launch") or n:find("fire") then
                return v
            end
        end
    end
    return nil
end
local function fireRing()
    local char=player.Character
    if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local remote=findMissileRemote()
    if not remote then
        fireBtn.Text="No Remote"
        task.wait(1)
        fireBtn.Text="FIRE!"
        return
    end
    for i=1,count do
        local angle=(i/count)*math.pi*2
        local offset=Vector3.new(math.cos(angle)*radius,0,math.sin(angle)*radius)
        local targetPos=hrp.Position+offset
        pcall(function()
            if remote:IsA("RemoteEvent") then
                remote:FireServer(targetPos)
            elseif remote:IsA("RemoteFunction") then
                remote:InvokeServer(targetPos)
            end
        end)
        task.wait(0.05)
    end
    fireBtn.Text="Fired!"
    task.wait(0.5)
    fireBtn.Text="FIRE!"
end
minusBtn.MouseButton1Click:Connect(function()
    count=math.max(1,count-1)
    countLabel.Text="Count: "..count
end)
plusBtn.MouseButton1Click:Connect(function()
    count=math.min(50,count+1)
    countLabel.Text="Count: "..count
end)
fireBtn.MouseButton1Click:Connect(fireRing)
