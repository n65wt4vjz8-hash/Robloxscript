local KEY="Luck"
local SCRIPT_URL="https://raw.githubusercontent.com/n65wt4vjz8-hash/Robloxscript/main/Aimbot.lua?t="
local player=game.Players.LocalPlayer
local CG=game:GetService("CoreGui")
local gui=Instance.new("ScreenGui")
gui.Name="DeltaKey"
gui.ResetOnSpawn=false
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end
local frame=Instance.new("Frame")
frame.Size=UDim2.new(0,220,0,130)
frame.Position=UDim2.new(0.5,-110,0.5,-65)
frame.BackgroundColor3=Color3.fromRGB(20,20,25)
frame.BorderSizePixel=0
frame.Parent=gui
local fc=Instance.new("UICorner")
fc.CornerRadius=UDim.new(0,10)
fc.Parent=frame
local title=Instance.new("TextLabel")
title.Size=UDim2.new(1,0,0,30)
title.BackgroundColor3=Color3.fromRGB(35,35,45)
title.BorderSizePixel=0
title.Text="Key System"
title.TextColor3=Color3.fromRGB(255,255,255)
title.Font=Enum.Font.GothamBold
title.TextSize=14
title.Parent=frame
local tc=Instance.new("UICorner")
tc.CornerRadius=UDim.new(0,10)
tc.Parent=title
local box=Instance.new("TextBox")
box.Size=UDim2.new(0.9,0,0,32)
box.Position=UDim2.new(0.05,0,0.3,0)
box.BackgroundColor3=Color3.fromRGB(45,45,55)
box.PlaceholderText="Key..."
box.Text=""
box.TextColor3=Color3.fromRGB(255,255,255)
box.Font=Enum.Font.GothamBold
box.TextSize=13
box.ClearTextOnFocus=false
box.Parent=frame
local bc=Instance.new("UICorner")
bc.CornerRadius=UDim.new(0,6)
bc.Parent=box
local btn=Instance.new("TextButton")
btn.Size=UDim2.new(0.9,0,0,32)
btn.Position=UDim2.new(0.05,0,0.58,0)
btn.BackgroundColor3=Color3.fromRGB(0,150,80)
btn.Text="OK"
btn.TextColor3=Color3.fromRGB(255,255,255)
btn.Font=Enum.Font.GothamBold
btn.TextSize=14
btn.Parent=frame
local btc=Instance.new("UICorner")
btc.CornerRadius=UDim.new(0,6)
btc.Parent=btn
local status=Instance.new("TextLabel")
status.Size=UDim2.new(1,0,0,20)
status.Position=UDim2.new(0,0,0.84,0)
status.BackgroundTransparency=1
status.Text=""
status.TextColor3=Color3.fromRGB(255,100,100)
status.Font=Enum.Font.GothamBold
status.TextSize=11
status.Parent=frame
btn.MouseButton1Click:Connect(function()
    if box.Text==KEY then
        status.Text="OK"
        status.TextColor3=Color3.fromRGB(0,220,120)
        task.wait(0.5)
        gui:Destroy()
        loadstring(game:HttpGet(SCRIPT_URL..tick()))()
    else
        status.Text="Wrong"
        box.Text=""
    end
end)
box.FocusLost:Connect(function(enter)
    if enter then btn.MouseButton1Click:Fire() end
end)
