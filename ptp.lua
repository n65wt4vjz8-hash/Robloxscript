local KEY="Clover"
local SCRIPT_URL="https://raw.githubusercontent.com/n65wt4vjz8-hash/Robloxscript/main/ptp.lua?t="
local player=game.Players.LocalPlayer
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
local keyFrame=Instance.new("Frame")
keyFrame.Size=UDim2.new(0,300,0,200)
keyFrame.Position=UDim2.new(0.5,-150,0.5,-100)
keyFrame.BackgroundColor3=Color3.fromRGB(15,15,25)
keyFrame.BorderSizePixel=0
keyFrame.Parent=gui
local kfc=Instance.new("UICorner")
kfc.CornerRadius=UDim.new(0,16)
kfc.Parent=keyFrame
local kStroke=Instance.new("UIStroke")
kStroke.Color=Color3.fromRGB(120,80,255)
kStroke.Thickness=2
kStroke.Parent=keyFrame
local kGrad=Instance.new("UIGradient")
kGrad.Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(120,80,255)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(0,180,255))
})
kGrad.Rotation=45
kGrad.Parent=kStroke
local kTitle=Instance.new("TextLabel")
kTitle.Size=UDim2.new(1,0,0,40)
kTitle.Position=UDim2.new(0,0,0,15)
kTitle.BackgroundTransparency=1
kTitle.Text="LUCK HUB"
kTitle.TextColor3=Color3.fromRGB(255,255,255)
kTitle.Font=Enum.Font.GothamBlack
kTitle.TextSize=28
kTitle.Parent=keyFrame
local kTitleGrad=Instance.new("UIGradient")
kTitleGrad.Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(180,120,255)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(80,200,255))
})
kTitleGrad.Parent=kTitle
local kSub=Instance.new("TextLabel")
kSub.Size=UDim2.new(1,0,0,16)
kSub.Position=UDim2.new(0,0,0,52)
kSub.BackgroundTransparency=1
kSub.Text="KEY SYSTEM"
kSub.TextColor3=Color3.fromRGB(150,150,180)
kSub.Font=Enum.Font.GothamBold
kSub.TextSize=10
kSub.Parent=keyFrame
local kBox=Instance.new("TextBox")
kBox.Size=UDim2.new(0.8,0,0,40)
kBox.Position=UDim2.new(0.1,0,0.42,0)
kBox.BackgroundColor3=Color3.fromRGB(25,25,40)
kBox.BorderSizePixel=0
kBox.PlaceholderText="Enter Key..."
kBox.Text=""
kBox.TextColor3=Color3.fromRGB(255,255,255)
kBox.PlaceholderColor3=Color3.fromRGB(100,100,130)
kBox.Font=Enum.Font.GothamBold
kBox.TextSize=14
kBox.ClearTextOnFocus=false
kBox.Parent=keyFrame
local kbc=Instance.new("UICorner")
kbc.CornerRadius=UDim.new(0,10)
kbc.Parent=kBox
local kBoxStroke=Instance.new("UIStroke")
kBoxStroke.Color=Color3.fromRGB(80,80,120)
kBoxStroke.Thickness=1.5
kBoxStroke.Parent=kBox
kBox.Focused:Connect(function()
    kBoxStroke.Color=Color3.fromRGB(120,80,255)
    kBoxStroke.Thickness=2
end)
kBox.FocusLost:Connect(function()
    kBoxStroke.Color=Color3.fromRGB(80,80,120)
    kBoxStroke.Thickness=1.5
end)
local kBtn=Instance.new("TextButton")
kBtn.Size=UDim2.new(0.8,0,0,38)
kBtn.Position=UDim2.new(0.1,0,0.72,0)
kBtn.BackgroundColor3=Color3.fromRGB(120,80,255)
kBtn.Text="VERIFY"
kBtn.TextColor3=Color3.fromRGB(255,255,255)
kBtn.Font=Enum.Font.GothamBold
kBtn.TextSize=15
kBtn.Parent=keyFrame
local kbtc=Instance.new("UICorner")
kbtc.CornerRadius=UDim.new(0,10)
kbtc.Parent=kBtn
local kBtnGrad=Instance.new("UIGradient")
kBtnGrad.Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(140,90,255)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(80,160,255))
})
kBtnGrad.Parent=kBtn
local kStatus=Instance.new("TextLabel")
kStatus.Size=UDim2.new(1,0,0,16)
kStatus.Position=UDim2.new(0,0,1,-20)
kStatus.BackgroundTransparency=1
kStatus.Text=""
kStatus.TextColor3=Color3.fromRGB(255,100,100)
kStatus.Font=Enum.Font.GothamBold
kStatus.TextSize=11
kStatus.Parent=keyFrame
kBtn.MouseButton1Click:Connect(function()
    if kBox.Text==KEY then
        kStatus.Text="SUCCESS"
        kStatus.TextColor3=Color3.fromRGB(0,220,120)
        task.wait(0.6)
        gui:Destroy()
        loadstring(game:HttpGet(SCRIPT_URL..tick()))()
    else
        kStatus.Text="INVALID KEY"
        kStatus.TextColor3=Color3.fromRGB(255,80,80)
        kBox.Text=""
    end
end)
kBox.FocusLost:Connect(function(enter)
    if enter then kBtn.MouseButton1Click:Fire() end
end)
