local player=game.Players.LocalPlayer
local RS=game:GetService("RunService")
local CG=game:GetService("CoreGui")
local gui=Instance.new("ScreenGui")
gui.Name="DeltaStrafe"
gui.ResetOnSpawn=false
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end
local btn=Instance.new("TextButton")
btn.Size=UDim2.new(0,140,0,60)
btn.Position=UDim2.new(0.05,0,0.4,0)
btn.BackgroundColor3=Color3.fromRGB(60,60,70)
btn.Text="STRAFE: OFF"
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
local conn
local power=25
local toggle=1
local function startStrafe()
    if conn then return end
    conn=RS.RenderStepped:Connect(function()
        if not enabled then return end
        local char=player.Character
        if not char then return end
        local hrp=char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local right=hrp.CFrame.RightVector
        hrp.CFrame=hrp.CFrame+right*power*toggle
        toggle=-toggle
    end)
end
local function stopStrafe()
    if conn then conn:Disconnect() conn=nil end
    toggle=1
end
btn.MouseButton1Click:Connect(function()
    enabled=not enabled
    if enabled then
        btn.Text="STRAFE: ON"
        btn.BackgroundColor3=Color3.fromRGB(0,150,80)
        startStrafe()
    else
        btn.Text="STRAFE: OFF"
        btn.BackgroundColor3=Color3.fromRGB(60,60,70)
        stopStrafe()
    end
end)
player.CharacterAdded:Connect(function()
    if enabled then
        enabled=false
        btn.Text="STRAFE: OFF"
        btn.BackgroundColor3=Color3.fromRGB(60,60,70)
        stopStrafe()
    end
end)
