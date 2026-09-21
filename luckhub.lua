local KEY="Luck"
local player=game.Players.LocalPlayer
local RS=game:GetService("RunService")
local CG=game:GetService("CoreGui")
local gui=Instance.new("ScreenGui")
gui.Name="LuckHub"
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
local function openHub()
    keyFrame.Visible=false
    bg.Visible=false
    local hubFrame=Instance.new("Frame")
    hubFrame.Size=UDim2.new(0,240,0,340)
    hubFrame.Position=UDim2.new(0.05,0,0.3,0)
    hubFrame.BackgroundColor3=Color3.fromRGB(15,15,25)
    hubFrame.BorderSizePixel=0
    hubFrame.Active=true
    hubFrame.Draggable=true
    hubFrame.Parent=gui
    local hfc=Instance.new("UICorner")
    hfc.CornerRadius=UDim.new(0,12)
    hfc.Parent=hubFrame
    local hStroke=Instance.new("UIStroke")
    hStroke.Color=Color3.fromRGB(120,80,255)
    hStroke.Thickness=2
    hStroke.Parent=hubFrame
    local hGrad=Instance.new("UIGradient")
    hGrad.Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,Color3.fromRGB(120,80,255)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(0,180,255))
    })
    hGrad.Rotation=45
    hGrad.Parent=hStroke
    local hTitle=Instance.new("TextLabel")
    hTitle.Size=UDim2.new(1,0,0,26)
    hTitle.BackgroundColor3=Color3.fromRGB(25,25,40)
    hTitle.BorderSizePixel=0
    hTitle.Text="LUCK HUB"
    hTitle.TextColor3=Color3.fromRGB(255,255,255)
    hTitle.Font=Enum.Font.GothamBlack
    hTitle.TextSize=14
    hTitle.Parent=hubFrame
    local htc=Instance.new("UICorner")
    htc.CornerRadius=UDim.new(0,12)
    htc.Parent=hTitle
    local minBtn=Instance.new("TextButton")
    minBtn.Size=UDim2.new(0,22,0,22)
    minBtn.Position=UDim2.new(1,-50,0,2)
    minBtn.BackgroundColor3=Color3.fromRGB(120,80,255)
    minBtn.Text="−"
    minBtn.TextColor3=Color3.fromRGB(255,255,255)
    minBtn.Font=Enum.Font.GothamBold
    minBtn.TextSize=14
    minBtn.Parent=hTitle
    local mbc=Instance.new("UICorner")
    mbc.CornerRadius=UDim.new(0,5)
    mbc.Parent=minBtn
    local closeBtn=Instance.new("TextButton")
    closeBtn.Size=UDim2.new(0,22,0,22)
    closeBtn.Position=UDim2.new(1,-25,0,2)
    closeBtn.BackgroundColor3=Color3.fromRGB(180,50,50)
    closeBtn.Text="×"
    closeBtn.TextColor3=Color3.fromRGB(255,255,255)
    closeBtn.Font=Enum.Font.GothamBold
    closeBtn.TextSize=14
    closeBtn.Parent=hTitle
    local cbc=Instance.new("UICorner")
    cbc.CornerRadius=UDim.new(0,5)
    cbc.Parent=closeBtn
    local list=Instance.new("ScrollingFrame")
    list.Size=UDim2.new(0.9,0,0,290)
    list.Position=UDim2.new(0.05,0,0.1,0)
    list.BackgroundTransparency=1
    list.BorderSizePixel=0
    list.ScrollBarThickness=4
    list.CanvasSize=UDim2.new(0,0,0,0)
    list.AutomaticCanvasSize=Enum.AutomaticSize.Y
    list.Parent=hubFrame
    local layout=Instance.new("UIListLayout")
    layout.Padding=UDim.new(0,6)
    layout.SortOrder=Enum.SortOrder.LayoutOrder
    layout.Parent=list
    local minimized=false
    local normalSize=UDim2.new(0,240,0,340)
    local miniSize=UDim2.new(0,140,0,60)
    minBtn.MouseButton1Click:Connect(function()
        minimized=not minimized
        if minimized then
            hubFrame.Size=miniSize
            list.Visible=false
            minBtn.Text="＋"
        else
            hubFrame.Size=normalSize
            list.Visible=true
            minBtn.Text="−"
        end
    end)
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    local function makeBtn(text,callback)
        local b=Instance.new("TextButton")
        b.Size=UDim2.new(1,0,0,32)
        b.BackgroundColor3=Color3.fromRGB(35,35,55)
        b.Text=text
        b.TextColor3=Color3.fromRGB(255,255,255)
        b.Font=Enum.Font.GothamBold
        b.TextSize=12
        b.Parent=list
        local c=Instance.new("UICorner")
        c.CornerRadius=UDim.new(0,6)
        c.Parent=b
        local s=Instance.new("UIStroke")
        s.Color=Color3.fromRGB(80,60,160)
        s.Thickness=1
        s.Parent=b
        b.MouseEnter:Connect(function()
            s.Color=Color3.fromRGB(120,80,255)
            s.Thickness=2
        end)
        b.MouseLeave:Connect(function()
            s.Color=Color3.fromRGB(80,60,160)
            s.Thickness=1
        end)
        b.MouseButton1Click:Connect(callback)
        return b
    end
    makeBtn("Fly",function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/n65wt4vjz8-hash/Robloxscript/main/fly3.lua?t=" .. tick()))()
    end)
    makeBtn("Tap TP",function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/n65wt4vjz8-hash/Robloxscript/main/tap_tp.lua?t=" .. tick()))()
    end)
    makeBtn("Player Cam",function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/n65wt4vjz8-hash/Robloxscript/main/player_cam.lua?t=" .. tick()))()
    end)
    makeBtn("Aimbot",function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/n65wt4vjz8-hash/Robloxscript/main/Aimbot.lua?t=" .. tick()))()
    end)
    makeBtn("ESP",function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/n65wt4vjz8-hash/Robloxscript/main/ESP.lua?t=" .. tick()))()
    end)
    makeBtn("Spin",function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/n65wt4vjz8-hash/Robloxscript/main/spin.lua?t=" .. tick()))()
    end)
    makeBtn("TP Me",function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/n65wt4vjz8-hash/Robloxscript/main/tpme.lua?t=" .. tick()))()
    end)
    makeBtn("Player TP",function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/n65wt4vjz8-hash/Robloxscript/main/ptp.lua?t=" .. tick()))()
    end)
end
kBtn.MouseButton1Click:Connect(function()
    if kBox.Text==KEY then
        kStatus.Text="SUCCESS"
        kStatus.TextColor3=Color3.fromRGB(0,220,120)
        task.wait(0.6)
        openHub()
    else
        kStatus.Text="INVALID KEY"
        kStatus.TextColor3=Color3.fromRGB(255,80,80)
        kBox.Text=""
    end
end)
kBox.FocusLost:Connect(function(enter)
    if enter then kBtn.MouseButton1Click:Fire() end
end)
