local player=game.Players.LocalPlayer
local RS=game:GetService("RunService")
local CG=game:GetService("CoreGui")
local cam=workspace.CurrentCamera
local gui=Instance.new("ScreenGui")
gui.Name="DeltaPlayerCam"
gui.ResetOnSpawn=false
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end
local frame=Instance.new("Frame")
frame.Size=UDim2.new(0,140,0,160)
frame.Position=UDim2.new(0.05,0,0.3,0)
frame.BackgroundColor3=Color3.fromRGB(20,20,25)
frame.BorderSizePixel=0
frame.Active=true
frame.Draggable=true
frame.Parent=gui
local fc=Instance.new("UICorner")
fc.CornerRadius=UDim.new(0,8)
fc.Parent=frame
local title=Instance.new("TextLabel")
title.Size=UDim2.new(1,0,0,22)
title.BackgroundColor3=Color3.fromRGB(35,35,45)
title.BorderSizePixel=0
title.Text="Player Cam"
title.TextColor3=Color3.fromRGB(255,255,255)
title.Font=Enum.Font.GothamBold
title.TextSize=11
title.Parent=frame
local tc=Instance.new("UICorner")
tc.CornerRadius=UDim.new(0,8)
tc.Parent=title
local closeBtn=Instance.new("TextButton")
closeBtn.Size=UDim2.new(0,20,0,20)
closeBtn.Position=UDim2.new(1,-22,0,1)
closeBtn.BackgroundColor3=Color3.fromRGB(180,50,50)
closeBtn.Text="×"
closeBtn.TextColor3=Color3.fromRGB(255,255,255)
closeBtn.Font=Enum.Font.GothamBold
closeBtn.TextSize=13
closeBtn.Parent=title
local cc=Instance.new("UICorner")
cc.CornerRadius=UDim.new(0,5)
cc.Parent=closeBtn
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)
local stopBtn=Instance.new("TextButton")
stopBtn.Size=UDim2.new(0.9,0,0,22)
stopBtn.Position=UDim2.new(0.05,0,0.16,0)
stopBtn.BackgroundColor3=Color3.fromRGB(80,50,50)
stopBtn.Text="解除"
stopBtn.TextColor3=Color3.fromRGB(255,255,255)
stopBtn.Font=Enum.Font.GothamBold
stopBtn.TextSize=10
stopBtn.Parent=frame
local sc=Instance.new("UICorner")
sc.CornerRadius=UDim.new(0,5)
sc.Parent=stopBtn
local list=Instance.new("ScrollingFrame")
list.Size=UDim2.new(0.9,0,0,90)
list.Position=UDim2.new(0.05,0,0.34,0)
list.BackgroundColor3=Color3.fromRGB(15,15,20)
list.BorderSizePixel=0
list.ScrollBarThickness=3
list.CanvasSize=UDim2.new(0,0,0,0)
list.AutomaticCanvasSize=Enum.AutomaticSize.Y
list.Parent=frame
local lc=Instance.new("UICorner")
lc.CornerRadius=UDim.new(0,5)
lc.Parent=list
local layout=Instance.new("UIListLayout")
layout.Padding=UDim.new(0,2)
layout.SortOrder=Enum.SortOrder.LayoutOrder
layout.Parent=list
local padding=Instance.new("UIPadding")
padding.PaddingTop=UDim.new(0,3)
padding.PaddingLeft=UDim.new(0,3)
padding.PaddingRight=UDim.new(0,3)
padding.Parent=list
local targetPlayer=nil
local conn
local function stopCam()
    if conn then conn:Disconnect() conn=nil end
    targetPlayer=nil
end
local function lockTo(pl)
    stopCam()
    targetPlayer=pl
    conn=RS.RenderStepped:Connect(function()
        if not targetPlayer then return end
        if not targetPlayer.Character then return end
        local hrp=targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local myChar=player.Character
        local myPos=myChar and myChar:FindFirstChild("HumanoidRootPart") and myChar.HumanoidRootPart.Position or cam.CFrame.Position
        cam.CFrame=CFrame.new(myPos,hrp.Position)
    end)
end
local function addPlayer(pl)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(1,-6,0,22)
    b.BackgroundColor3=Color3.fromRGB(45,45,60)
    b.Text=pl.Name
    b.TextColor3=Color3.fromRGB(255,255,255)
    b.Font=Enum.Font.GothamBold
    b.TextSize=10
    b.Parent=list
    local c=Instance.new("UICorner")
    c.CornerRadius=UDim.new(0,4)
    c.Parent=b
    b.MouseButton1Click:Connect(function()
        lockTo(pl)
        b.BackgroundColor3=Color3.fromRGB(0,150,80)
        for _,other in ipairs(list:GetChildren()) do
            if other:IsA("TextButton") and other~=b then
                other.BackgroundColor3=Color3.fromRGB(45,45,60)
            end
        end
    end)
end
for _,pl in ipairs(game.Players:GetPlayers()) do
    if pl~=player then addPlayer(pl) end
end
game.Players.PlayerAdded:Connect(function(pl)
    if pl~=player then addPlayer(pl) end
end)
game.Players.PlayerRemoving:Connect(function(pl)
    for _,b in ipairs(list:GetChildren()) do
        if b:IsA("TextButton") and b.Text==pl.Name then
            b:Destroy()
        end
    end
    if targetPlayer==pl then stopCam() end
end)
stopBtn.MouseButton1Click:Connect(function()
    stopCam()
    for _,b in ipairs(list:GetChildren()) do
        if b:IsA("TextButton") then
            b.BackgroundColor3=Color3.fromRGB(45,45,60)
        end
    end
end)
