local R=function() return tostring(math.random(100000,999999)) end
local player=game.Players.LocalPlayer
local CG=game:GetService("CoreGui")
local gui=Instance.new("ScreenGui")
gui.Name="g"..R()
gui.ResetOnSpawn=false
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end
local frame=Instance.new("Frame")
frame.Name="f"..R()
frame.Size=UDim2.new(0,200,0,370)
frame.Position=UDim2.new(0.05,0,0.2,0)
frame.BackgroundColor3=Color3.fromRGB(20,20,25)
frame.BorderSizePixel=0
frame.Active=true
frame.Draggable=true
frame.Parent=gui
local fc=Instance.new("UICorner")
fc.CornerRadius=UDim.new(0,10)
fc.Parent=frame
local title=Instance.new("TextLabel")
title.Name="t"..R()
title.Size=UDim2.new(1,0,0,26)
title.BackgroundColor3=Color3.fromRGB(35,35,45)
title.BorderSizePixel=0
title.Text="Point"
title.TextColor3=Color3.fromRGB(255,255,255)
title.Font=Enum.Font.GothamBold
title.TextSize=14
title.Parent=frame
local tc=Instance.new("UICorner")
tc.CornerRadius=UDim.new(0,10)
tc.Parent=title
local minBtn=Instance.new("TextButton")
minBtn.Name="m"..R()
minBtn.Size=UDim2.new(0,24,0,24)
minBtn.Position=UDim2.new(1,-56,0,1)
minBtn.BackgroundColor3=Color3.fromRGB(80,80,100)
minBtn.Text="C"
minBtn.TextColor3=Color3.fromRGB(255,255,255)
minBtn.Font=Enum.Font.GothamBold
minBtn.TextSize=13
minBtn.Parent=title
local mc=Instance.new("UICorner")
mc.CornerRadius=UDim.new(0,6)
mc.Parent=minBtn
local closeBtn=Instance.new("TextButton")
closeBtn.Name="c"..R()
closeBtn.Size=UDim2.new(0,24,0,24)
closeBtn.Position=UDim2.new(1,-28,0,1)
closeBtn.BackgroundColor3=Color3.fromRGB(180,50,50)
closeBtn.Text="×"
closeBtn.TextColor3=Color3.fromRGB(255,255,255)
closeBtn.Font=Enum.Font.GothamBold
closeBtn.TextSize=16
closeBtn.Parent=title
local cc=Instance.new("UICorner")
cc.CornerRadius=UDim.new(0,6)
cc.Parent=closeBtn
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)
local positions={}
local slots={}
local compressed=false
local function getHRP()
    local char=player.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end
local function makeSlot(num,y)
    local slotFrame=Instance.new("Frame")
    slotFrame.Name="s"..R()
    slotFrame.Size=UDim2.new(0.9,0,0,58)
    slotFrame.Position=UDim2.new(0.05,0,y,0)
    slotFrame.BackgroundColor3=Color3.fromRGB(30,30,40)
    slotFrame.BorderSizePixel=0
    slotFrame.Parent=frame
    local sfc=Instance.new("UICorner")
    sfc.CornerRadius=UDim.new(0,8)
    sfc.Parent=slotFrame
    local label=Instance.new("TextLabel")
    label.Name="l"..R()
    label.Size=UDim2.new(1,0,0,18)
    label.BackgroundTransparency=1
    label.Text="Slot "..num
    label.TextColor3=Color3.fromRGB(200,220,255)
    label.Font=Enum.Font.GothamBold
    label.TextSize=12
    label.Parent=slotFrame
    local saveBtn=Instance.new("TextButton")
    saveBtn.Name="sv"..R()
    saveBtn.Size=UDim2.new(0.4,0,0,26)
    saveBtn.Position=UDim2.new(0.03,0,0.42,0)
    saveBtn.BackgroundColor3=Color3.fromRGB(50,70,110)
    saveBtn.Text="Save"
    saveBtn.TextColor3=Color3.fromRGB(255,255,255)
    saveBtn.Font=Enum.Font.GothamBold
    saveBtn.TextSize=12
    saveBtn.Parent=slotFrame
    local sbc=Instance.new("UICorner")
    sbc.CornerRadius=UDim.new(0,6)
    sbc.Parent=saveBtn
    local tpBtn=Instance.new("TextButton")
    tpBtn.Name="tp"..R()
    tpBtn.Size=UDim2.new(0.4,0,0,26)
    tpBtn.Position=UDim2.new(0.45,0,0.42,0)
    tpBtn.BackgroundColor3=Color3.fromRGB(50,90,60)
    tpBtn.Text="TP"
    tpBtn.TextColor3=Color3.fromRGB(255,255,255)
    tpBtn.Font=Enum.Font.GothamBold
    tpBtn.TextSize=12
    tpBtn.Parent=slotFrame
    local tbc=Instance.new("UICorner")
    tbc.CornerRadius=UDim.new(0,6)
    tbc.Parent=tpBtn
    local delBtn=Instance.new("TextButton")
    delBtn.Name="d"..R()
    delBtn.Size=UDim2.new(0.13,0,0,26)
    delBtn.Position=UDim2.new(0.86,0,0.42,0)
    delBtn.BackgroundColor3=Color3.fromRGB(90,50,50)
    delBtn.Text="×"
    delBtn.TextColor3=Color3.fromRGB(255,255,255)
    delBtn.Font=Enum.Font.GothamBold
    delBtn.TextSize=14
    delBtn.Parent=slotFrame
    local dbc=Instance.new("UICorner")
    dbc.CornerRadius=UDim.new(0,6)
    dbc.Parent=delBtn
    saveBtn.MouseButton1Click:Connect(function()
        local hrp=getHRP()
        if not hrp then return end
        positions[num]=hrp.CFrame
        saveBtn.Text="OK"
        saveBtn.BackgroundColor3=Color3.fromRGB(0,150,80)
        task.wait(1)
        saveBtn.Text="Save"
        saveBtn.BackgroundColor3=Color3.fromRGB(50,70,110)
    end)
    tpBtn.MouseButton1Click:Connect(function()
        if not positions[num] then
            tpBtn.Text="Empty"
            task.wait(1)
            tpBtn.Text="TP"
            return
        end
        local hrp=getHRP()
        if not hrp then return end
        hrp.CFrame=positions[num]
    end)
    delBtn.MouseButton1Click:Connect(function()
        positions[num]=nil
        delBtn.Text="✓"
        task.wait(0.5)
        delBtn.Text="×"
    end)
    slots[num]=slotFrame
end
makeSlot(1,32)
makeSlot(2,94)
makeSlot(3,156)
makeSlot(4,218)
makeSlot(5,280)
minBtn.MouseButton1Click:Connect(function()
    compressed=not compressed
    if compressed then
        for i=2,5 do
            if slots[i] then slots[i].Visible=false end
        end
        frame.Size=UDim2.new(0,200,0,96)
        minBtn.Text="E"
    else
        for i=2,5 do
            if slots[i] then slots[i].Visible=true end
        end
        frame.Size=UDim2.new(0,200,0,370)
        minBtn.Text="C"
    end
end)
