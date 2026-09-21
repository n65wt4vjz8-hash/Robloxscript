local KEY="Luck"
local SCRIPT_URL="https://raw.githubusercontent.com/n65wt4vjz8-hash/Robloxscript/main/ptp.lua?t="
local player=game.Players.LocalPlayer
local RS=game:GetService("RunService")
local CG=game:GetService("CoreGui")
local gui=Instance.new("ScreenGui")
gui.Name="LuckHubKey"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end
local bg=Instance.new("Frame")
bg.Size=UDim2.new(1,0,1,0)
bg.BackgroundColor3=Color3.fromRGB(0,0,0)
bg.BackgroundTransparency=0.5
bg.BorderSizePixel=0
bg.Parent=gui
local container=Instance.new("Frame")
container.Size=UDim2.new(0,360,0,420)
container.Position=UDim2.new(0.5,-180,0.5,-210)
container.BackgroundTransparency=1
container.Parent=gui
local title=Instance.new("TextLabel")
title.Size=UDim2.new(1,0,0,40)
title.Position=UDim2.new(0,0,0,0)
title.BackgroundTransparency=1
title.Text="LUCK HUB"
title.TextColor3=Color3.fromRGB(255,255,255)
title.TextStrokeTransparency=0
title.TextStrokeColor3=Color3.fromRGB(0,0,0)
title.Font=Enum.Font.GothamBlack
title.TextSize=32
title.ZIndex=10
title.Parent=container
local yinContainer=Instance.new("Frame")
yinContainer.Size=UDim2.new(0,300,0,300)
yinContainer.Position=UDim2.new(0.5,-150,0,90)
yinContainer.BackgroundTransparency=1
yinContainer.Parent=container
local whiteCircle=Instance.new("ImageLabel")
whiteCircle.Size=UDim2.new(0,300,0,300)
whiteCircle.Position=UDim2.new(0,0,0,0)
whiteCircle.BackgroundTransparency=1
whiteCircle.Image="rbxassetid://3570695787"
whiteCircle.ImageColor3=Color3.fromRGB(255,255,255)
whiteCircle.ZIndex=1
whiteCircle.Parent=yinContainer
local blackHalfMask=Instance.new("Frame")
blackHalfMask.Size=UDim2.new(0,150,0,300)
blackHalfMask.Position=UDim2.new(0,150,0,0)
blackHalfMask.BackgroundColor3=Color3.fromRGB(0,0,0)
blackHalfMask.BorderSizePixel=0
blackHalfMask.ZIndex=2
blackHalfMask.Parent=yinContainer
local blackTopMask=Instance.new("Frame")
blackTopMask.Size=UDim2.new(0,150,0,150)
blackTopMask.Position=UDim2.new(0,75,0,0)
blackTopMask.BackgroundColor3=Color3.fromRGB(0,0,0)
blackTopMask.BorderSizePixel=0
blackTopMask.ZIndex=3
blackTopMask.Parent=yinContainer
local btc=Instance.new("UICorner")
btc.CornerRadius=UDim.new(0.5,0)
btc.Parent=blackTopMask
local whiteBottomMask=Instance.new("Frame")
whiteBottomMask.Size=UDim2.new(0,150,0,150)
whiteBottomMask.Position=UDim2.new(0,75,0,150)
whiteBottomMask.BackgroundColor3=Color3.fromRGB(255,255,255)
whiteBottomMask.BorderSizePixel=0
whiteBottomMask.ZIndex=3
whiteBottomMask.Parent=yinContainer
local wbc=Instance.new("UICorner")
wbc.CornerRadius=UDim.new(0.5,0)
wbc.Parent=whiteBottomMask
local blackDot=Instance.new("ImageLabel")
blackDot.Size=UDim2.new(0,40,0,40)
blackDot.Position=UDim2.new(0,130,0,55)
blackDot.BackgroundTransparency=1
blackDot.Image="rbxassetid://3570695787"
blackDot.ImageColor3=Color3.fromRGB(0,0,0)
blackDot.ZIndex=4
blackDot.Parent=yinContainer
local whiteDot=Instance.new("ImageLabel")
whiteDot.Size=UDim2.new(0,40,0,40)
whiteDot.Position=UDim2.new(0,130,0,205)
whiteDot.BackgroundTransparency=1
whiteDot.Image="rbxassetid://3570695787"
whiteDot.ImageColor3=Color3.fromRGB(255,255,255)
whiteDot.ZIndex=4
whiteDot.Parent=yinContainer
local blackRightMask=Instance.new("ImageLabel")
blackRightMask.Size=UDim2.new(0,150,0,300)
blackRightMask.Position=UDim2.new(0,150,0,0)
blackRightMask.BackgroundTransparency=1
blackRightMask.Image="rbxassetid://3570695787"
blackRightMask.ImageColor3=Color3.fromRGB(0,0,0)
blackRightMask.ZIndex=5
blackRightMask.Parent=yinContainer
local blackTopCircle=Instance.new("ImageLabel")
blackTopCircle.Size=UDim2.new(0,150,0,150)
blackTopCircle.Position=UDim2.new(0,75,0,0)
blackTopCircle.BackgroundTransparency=1
blackTopCircle.Image="rbxassetid://3570695787"
blackTopCircle.ImageColor3=Color3.fromRGB(0,0,0)
blackTopCircle.ZIndex=6
blackTopCircle.Parent=yinContainer
local whiteBottomCircle=Instance.new("ImageLabel")
whiteBottomCircle.Size=UDim2.new(0,150,0,150)
whiteBottomCircle.Position=UDim2.new(0,75,0,150)
whiteBottomCircle.BackgroundTransparency=1
whiteBottomCircle.Image="rbxassetid://3570695787"
whiteBottomCircle.ImageColor3=Color3.fromRGB(255,255,255)
whiteBottomCircle.ZIndex=6
whiteBottomCircle.Parent=yinContainer
local overlay=Instance.new("Frame")
overlay.Size=UDim2.new(1,0,1,0)
overlay.BackgroundTransparency=1
overlay.ZIndex=20
overlay.Parent=container
local keyLabel=Instance.new("TextLabel")
keyLabel.Size=UDim2.new(1,0,0,30)
keyLabel.Position=UDim2.new(0,0,0.5,-50)
keyLabel.BackgroundTransparency=1
keyLabel.Text="「KEY」"
keyLabel.TextColor3=Color3.fromRGB(255,255,255)
keyLabel.TextStrokeTransparency=0
keyLabel.TextStrokeColor3=Color3.fromRGB(0,0,0)
keyLabel.Font=Enum.Font.GothamBlack
keyLabel.TextSize=28
keyLabel.ZIndex=21
keyLabel.Parent=overlay
local box=Instance.new("TextBox")
box.Size=UDim2.new(0.5,0,0,36)
box.Position=UDim2.new(0.25,0,0.5,-15)
box.BackgroundColor3=Color3.fromRGB(30,30,30)
box.BackgroundTransparency=0.2
box.BorderSizePixel=0
box.PlaceholderText=""
box.Text=""
box.TextColor3=Color3.fromRGB(255,255,255)
box.Font=Enum.Font.GothamBold
box.TextSize=16
box.ZIndex=21
box.Parent=overlay
local bc=Instance.new("UICorner")
bc.CornerRadius=UDim.new(0,8)
bc.Parent=box
local boxStroke=Instance.new("UIStroke")
boxStroke.Color=Color3.fromRGB(255,255,255)
boxStroke.Thickness=2
boxStroke.Parent=box
local verify=Instance.new("TextButton")
verify.Size=UDim2.new(0.7,0,0,42)
verify.Position=UDim2.new(0.15,0,0.5,40)
verify.BackgroundColor3=Color3.fromRGB(0,0,0)
verify.BackgroundTransparency=0.2
verify.Text="VERIFY"
verify.TextColor3=Color3.fromRGB(255,255,255)
verify.TextStrokeTransparency=0
verify.TextStrokeColor3=Color3.fromRGB(0,0,0)
verify.Font=Enum.Font.GothamBlack
verify.TextSize=24
verify.ZIndex=21
verify.Parent=overlay
local vc=Instance.new("UICorner")
vc.CornerRadius=UDim.new(0,10)
vc.Parent=verify
local vStroke=Instance.new("UIStroke")
vStroke.Color=Color3.fromRGB(255,255,255)
vStroke.Thickness=2
vStroke.Parent=verify
local status=Instance.new("TextLabel")
status.Size=UDim2.new(1,0,0,24)
status.Position=UDim2.new(0,0,0.5,90)
status.BackgroundTransparency=1
status.Text=""
status.TextColor3=Color3.fromRGB(255,100,100)
status.TextStrokeTransparency=0
status.TextStrokeColor3=Color3.fromRGB(0,0,0)
status.Font=Enum.Font.GothamBlack
status.TextSize=16
status.ZIndex=21
status.Parent=overlay
local angle=0
local conn=RS.RenderStepped:Connect(function(dt)
    angle=angle+dt*45
    yinContainer.Rotation=angle
end)
gui.Destroying:Connect(function()
    if conn then conn:Disconnect() end
end)
verify.MouseEnter:Connect(function()
    vStroke.Thickness=3
end)
verify.MouseLeave:Connect(function()
    vStroke.Thickness=2
end)
verify.MouseButton1Click:Connect(function()
    if box.Text==KEY then
        status.Text="SUCCESS"
        status.TextColor3=Color3.fromRGB(0,220,120)
        task.wait(0.6)
        if conn then conn:Disconnect() end
        gui:Destroy()
        loadstring(game:HttpGet(SCRIPT_URL..tick()))()
    else
        status.Text="INVALID KEY"
        status.TextColor3=Color3.fromRGB(255,80,80)
        box.Text=""
    end
end)
box.FocusLost:Connect(function(enter)
    if enter then verify.MouseButton1Click:Fire() end
end)
