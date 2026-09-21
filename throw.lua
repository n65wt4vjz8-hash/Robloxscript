local player=game.Players.LocalPlayer
local RS=game:GetService("RunService")
local CG=game:GetService("CoreGui")
local gui=Instance.new("ScreenGui")
gui.Name="DeltaThrowPower"
gui.ResetOnSpawn=false
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end
local btn=Instance.new("TextButton")
btn.Size=UDim2.new(0,160,0,60)
btn.Position=UDim2.new(0.05,0,0.4,0)
btn.BackgroundColor3=Color3.fromRGB(60,60,70)
btn.Text="THROW: OFF"
btn.TextColor3=Color3.fromRGB(255,255,255)
btn.Font=Enum.Font.GothamBold
btn.TextSize=14
btn.Active=true
btn.Draggable=true
btn.Parent=gui
local bc=Instance.new("UICorner")
bc.CornerRadius=UDim.new(0,10)
bc.Parent=btn
local enabled=false
local power=200
local conn
local function boost()
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj.Anchored then
            local char=player.Character
            if char and obj:IsDescendantOf(char) then continue end
            if obj.Velocity.Magnitude>10 then
                obj.Velocity=obj.Velocity.Unit*power
            end
        end
    end
end
btn.MouseButton1Click:Connect(function()
    enabled=not enabled
    if enabled then
        btn.Text="THROW: ON"
        btn.BackgroundColor3=Color3.fromRGB(0,150,80)
        conn=RS.Heartbeat:Connect(function()
            if not enabled then return end
            boost()
        end)
    else
        btn.Text="THROW: OFF"
        btn.BackgroundColor3=Color3.fromRGB(60,60,70)
        if conn then conn:Disconnect() conn=nil end
    end
end)
player.CharacterAdded:Connect(function()
    if enabled then
        enabled=false
        btn.Text="THROW: OFF"
        btn.BackgroundColor3=Color3.fromRGB(60,60,70)
        if conn then conn:Disconnect() conn=nil end
    end
end)
