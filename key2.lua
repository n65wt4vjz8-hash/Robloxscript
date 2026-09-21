local KEY="Luck"
local SCRIPT_URL="https://raw.githubusercontent.com/n65wt4vjz8-hash/Robloxscript/main/strafe.lua?t="
local player=game.Players.LocalPlayer
local RS=game:GetService("RunService")
local CG=game:GetService("CoreGui")
local gui=Instance.new("ScreenGui")
gui.Name="DeltaKey"
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
local frame=Instance.new("Frame")
frame.Size=UDim2.new(0,300,0,200)
frame.Position=UDim2.new(0.5,-150,0.5,-100)
frame.BackgroundColor3=Color3.fromRGB(10,10,15)
frame.BorderSizePixel=0
frame.ClipsDescendants=true
frame.Parent=gui
local fc=Instance.new("UICorner")
fc.CornerRadius=UDim.new(0,20)
fc.Parent=frame
local stroke=Instance.new("UIStroke")
stroke.Color=Color3.fromRGB(255,255,255)
stroke.Thickness=2
stroke.Transparency=0.3
stroke.Parent=frame
local swirl1=Instance.new("Frame")
swirl1.Size=UDim2.new(0,200,0,200)
swirl1.Position=UDim2.new(0.5,-100,0.5,-100)
swirl1.BackgroundColor3=Color3.fromRGB(255,255,255)
swirl1.BackgroundTransparency=0.85
swirl1.BorderSizePixel=0
swirl1.Rotation=0
swirl1.Parent=frame
local s1c=Instance.new("UICorner")
s1c.CornerRadius=UDim.new(1,0)
s1c.Parent=swirl1
local swirl2=Instance.new("Frame")
swirl2.Size=UDim2.new(0,160,0,160)
swirl2.Position=UDim2.new(0.5,-80,0.5,-80)
swirl2.BackgroundColor3=Color3.fromRGB(0,0,0)
swirl2.BackgroundTransparency=0.3
swirl2.BorderSizePixel=0
swirl2.Rotation=0
swirl2.Parent=frame
local s2c=Instance.new("UICorner")
s2c.CornerRadius=UDim.new(1,0)
s2c.Parent=swirl2
local yinYang=Instance.new("Frame")
yinYang.Size=UDim2.new(0,50,0,50)
yinYang.Position=UDim2.new(0.5,-25,0.5,-25)
yinYang.BackgroundColor3=Color3.fromRGB(255,255,255)
yinYang.BorderSizePixel=0
yinYang.Parent=frame
local yyc=Instance.new("UICorner")
yyc.CornerRadius=UDim.new(1,0)
yyc.Parent=yinYang
local dark=Instance.new("Frame")
dark.Size=UDim2.new(0,25,0,50)
dark.Position=UDim2.new(0.5,0,0,0)
dark.BackgroundColor3=Color3.fromRGB(0,0,0)
dark.BorderSizePixel=0
dark.Parent=yinYang
local darkC=Instance.new("UICorner")
darkC.CornerRadius=UDim.new(0,0)
darkC.Parent=dark
local dot1=Instance.new("Frame")
dot1.Size=UDim2.new(0,10,0,10)
dot1.Position=UDim2.new(0.5,-5,0.1,0)
dot1.BackgroundColor3=Color3.fromRGB(0,0,0)
dot1.BorderSizePixel=0
dot1.Parent=yinYang
local d1c=Instance.new("UICorner")
d1c.CornerRadius=UDim.new(1,0)
d1c.Parent=dot1
local dot2=Instance.new("Frame")
dot2.Size=UDim2.new(0,10,0,10)
dot2.Position=UDim2.new(0.5,-5,0.7,0)
dot2.BackgroundColor3=Color3.fromRGB(255,255,255)
dot2.BorderSizePixel=0
dot2.Parent=yinYang
local d2c=Instance.new("UICorner")
d2c.CornerRadius=UDim.new(1,0)
d2c.Parent=dot2
local title=Instance.new("TextLabel")
title.Size=UDim2.new(1,0,0,30)
title.Position=UDim2.new(0,0,0,10)
title.BackgroundTransparency=1
title.Text="☯ DELTA ☯"
title.TextColor3=Color3.fromRGB(255,255,255)
title.Font=Enum.Font.GothamBlack
title.TextSize=20
title.ZIndex=10
title.Parent=frame
local box=Instance.new("TextBox")
box.Size=UDim2.new(0.8,0,0,36)
box.Position=UDim2.new(0.1,0,0.65,0)
box.BackgroundColor3=Color3.fromRGB(20,20,25)
box.BorderSizePixel=0
box.PlaceholderText="Enter Key..."
box.Text=""
box.TextColor3=Color3.fromRGB(255,255,255)
box.PlaceholderColor3=Color3.fromRGB(150,150,150)
box.Font=Enum.Font.GothamBold
box.TextSize=14
box.ClearTextOnFocus=false
box.ZIndex=10
box.Parent=frame
local bc=Instance.new("UICorner")
bc.CornerRadius=UDim.new(0,10)
bc.Parent=box
local boxStroke=Instance.new("UIStroke")
boxStroke.Color=Color3.fromRGB(255,255,255)
boxStroke.Thickness=1.5
boxStroke.Transparency=0.5
boxStroke.Parent=box
box.Focused:Connect(function()
    boxStroke.Color=Color3.fromRGB(255,255,255)
    boxStroke.Thickness=2
    boxStroke.Transparency=0
end)
box.FocusLost:Connect(function(enter)
    boxStroke.Color=Color3.fromRGB(255,255,255)
    boxStroke.Thickness=1.5
    boxStroke.Transparency=0.5
    if enter then btn.MouseButton1Click:Fire() end
end)
local btn=Instance.new("TextButton")
btn.Size=UDim2.new(0.8,0,0,34)
btn.Position=UDim2.new(0.1,0,0.85,0)
btn.BackgroundColor3=Color3.fromRGB(255,255,255)
btn.Text="VERIFY"
btn.TextColor3=Color3.fromRGB(0,0,0)
btn.Font=Enum.Font.GothamBlack
btn.TextSize=14
btn.ZIndex=10
btn.Parent=frame
local btc=Instance.new("UICorner")
btc.CornerRadius=UDim.new(0,10)
btc.Parent=btn
local status=Instance.new("TextLabel")
status.Size=UDim2.new(1,0,0,16)
status.Position=UDim2.new(0,0,1,-22)
status.BackgroundTransparency=1
status.Text=""
status.TextColor3=Color3.fromRGB(255,100,100)
status.Font=Enum.Font.GothamBold
status.TextSize=11
status.ZIndex=10
status.Parent=frame
local angle=0
local conn=RS.RenderStepped:Connect(function(dt)
    angle=angle+dt*30
    swirl1.Rotation=angle
    swirl2.Rotation=-angle
end)
gui.Destroying:Connect(function()
    if conn then conn:Disconnect() end
end)
btn.MouseEnter:Connect(function()
    btn.BackgroundColor3=Color3.fromRGB(220,220,220)
end)
btn.MouseLeave:Connect(function()
    btn.BackgroundColor3=Color3.fromRGB(255,255,255)
end)
btn.MouseButton1Click:Connect(function()
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
