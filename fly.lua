
local player=game.Players.LocalPlayer
local UIS=game:GetService("UserInputService")
local RS=game:GetService("RunService")
local CG=game:GetService("CoreGui")
local flying=false
local speed=60
local bv,bg,conn
local moveDir=Vector3.zero
local gui=Instance.new("ScreenGui")
gui.Name="DeltaFly"
gui.ResetOnSpawn=false
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end
local frame=Instance.new("Frame")
frame.Size=UDim2.new(0,180,0,130)
frame.Position=UDim2.new(0,20,0.3,0)
frame.BackgroundColor3=Color3.fromRGB(25,25,30)
frame.BorderSizePixel=0
frame.Active=true
frame.Draggable=true
frame.Parent=gui
local c1=Instance.new("UICorner")
c1.CornerRadius=UDim.new(0,8)
c1.Parent=frame
local btn=Instance.new("TextButton")
btn.Size=UDim2.new(0.9,0,0,32)
btn.Position=UDim2.new(0.05,0,0.12,0)
btn.BackgroundColor3=Color3.fromRGB(60,60,70)
btn.Text="OFF"
btn.TextColor3=Color3.fromRGB(255,255,255)
btn.Font=Enum.Font.GothamBold
btn.TextSize=14
btn.Parent=frame
local c2=Instance.new("UICorner")
c2.CornerRadius=UDim.new(0,6)
c2.Parent=btn
local lbl=Instance.new("TextLabel")
lbl.Size=UDim2.new(0.5,0,0,28)
lbl.Position=UDim2.new(0.25,0,0.5,0)
lbl.BackgroundTransparency=1
lbl.Text="Speed: "..speed
lbl.TextColor3=Color3.fromRGB(200,220,255)
lbl.Font=Enum.Font.GothamBold
lbl.TextSize=13
lbl.Parent=frame
local minus=Instance.new("TextButton")
minus.Size=UDim2.new(0.18,0,0,28)
minus.Position=UDim2.new(0.05,0,0.5,0)
minus.BackgroundColor3=Color3.fromRGB(70,50,50)
minus.Text="−"
minus.TextColor3=Color3.fromRGB(255,255,255)
minus.Font=Enum.Font.GothamBold
minus.TextSize=18
minus.Parent=frame
local c3=Instance.new("UICorner")
c3.CornerRadius=UDim.new(0,6)
c3.Parent=minus
local plus=Instance.new("TextButton")
plus.Size=UDim2.new(0.18,0,0,28)
plus.Position=UDim2.new(0.77,0,0.5,0)
plus.BackgroundColor3=Color3.fromRGB(50,70,50)
plus.Text="＋"
plus.TextColor3=Color3.fromRGB(255,255,255)
plus.Font=Enum.Font.GothamBold
plus.TextSize=16
plus.Parent=frame
local c4=Instance.new("UICorner")
c4.CornerRadius=UDim.new(0,6)
c4.Parent=plus
local reset=Instance.new("TextButton")
reset.Size=UDim2.new(0.9,0,0,22)
reset.Position=UDim2.new(0.05,0,0.75,0)
reset.BackgroundColor3=Color3.fromRGB(45,45,55)
reset.Text="Reset"
reset.TextColor3=Color3.fromRGB(220,220,220)
reset.Font=Enum.Font.Gotham
reset.TextSize=11
reset.Parent=frame
local c5=Instance.new("UICorner")
c5.CornerRadius=UDim.new(0,6)
c5.Parent=reset
local function makeArrow(text,pos,dirFunc)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(0,50,0,50)
    b.Position=pos
    b.BackgroundColor3=Color3.fromRGB(40,40,50)
    b.Text=text
    b.TextColor3=Color3.fromRGB(255,255,255)
    b.Font=Enum.Font.GothamBold
    b.TextSize=20
    b.Parent=gui
    local c=Instance.new("UICorner")
    c.CornerRadius=UDim.new(0,8)
    c.Parent=b
    b.MouseButton1Down:Connect(function() moveDir=dirFunc() end)
    b.MouseButton1Up:Connect(function() moveDir=Vector3.zero end)
    b.MouseLeave:Connect(function() moveDir=Vector3.zero end)
end
local bx=0.05
local by=0.75
makeArrow("↑",UDim2.new(bx,55,by,0),function() return Vector3.new(0,0,-1) end)
makeArrow("↓",UDim2.new(bx,55,by,110),function() return Vector3.new(0,0,1) end)
makeArrow("←",UDim2.new(bx,0,by,55),function() return Vector3.new(-1,0,0) end)
makeArrow("→",UDim2.new(bx,110,by,55),function() return Vector3.new(1,0,0) end)
makeArrow("▲",UDim2.new(0.85,0,0.75,0),function() return Vector3.new(0,1,0) end)
makeArrow("▼",UDim2.new(0.85,0,0.75,110),function() return Vector3.new(0,-1,0) end)
local function startFly()
    if flying then return end
    local char=player.Character or player.CharacterAdded:Wait()
    local hrp=char:WaitForChild("HumanoidRootPart")
    local hum=char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    flying=true
    hum.PlatformStand=true
    bv=Instance.new("BodyVelocity")
    bv.MaxForce=Vector3.new(1e5,1e5,1e5)
    bv.Velocity=Vector3.zero
    bv.Parent=hrp
    bg=Instance.new("BodyGyro")
    bg.MaxTorque=Vector3.new(1e5,1e5,1e5)
    bg.P=1e4
    bg.CFrame=hrp.CFrame
    bg.Parent=hrp
    conn=RS.RenderStepped:Connect(function()
        if not flying then return end
        local cam=workspace.CurrentCamera
        local dir=Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir+=cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir-=cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir-=cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir+=cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir+=Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir-=Vector3.new(0,1,0) end
        if moveDir.Magnitude>0 then dir+=cam.CFrame:VectorToWorldSpace(moveDir) end
        if dir.Magnitude>0 then bv.Velocity=dir.Unit*speed else bv.Velocity=Vector3.zero end
        bg.CFrame=cam.CFrame
    end)
    btn.Text="ON"
    btn.BackgroundColor3=Color3.fromRGB(0,170,90)
end
local function stopFly()
    if not flying then return end
    flying=false
    if conn then conn:Disconnect() conn=nil end
    if bv then bv:Destroy() bv=nil end
    if bg then bg:Destroy() bg=nil end
    local char=player.Character
    local hum=char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand=false end
    btn.Text="OFF"
    btn.BackgroundColor3=Color3.fromRGB(60,60,70)
end
minus.MouseButton1Click:Connect(function()
    speed=math.max(5,speed-5)
    lbl.Text="Speed: "..speed
end)
plus.MouseButton1Click:Connect(function()
    speed=math.min(500,speed+5)
    lbl.Text="Speed: "..speed
end)
reset.MouseButton1Click:Connect(function()
    speed=60
    lbl.Text="Speed: "..speed
end)
btn.MouseButton1Click:Connect(function()
    if flying then stopFly() else startFly() end
end)
player.CharacterAdded:Connect(function()
    if flying then stopFly() end
end)
