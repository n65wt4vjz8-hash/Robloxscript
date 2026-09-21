local player=game.Players.LocalPlayer
local RS=game:GetService("RunService")
local CG=game:GetService("CoreGui")
local gui=Instance.new("ScreenGui")
gui.Name="DeltaNoclip"
gui.ResetOnSpawn=false
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end
local btn=Instance.new("TextButton")
btn.Size=UDim2.new(0,140,0,60)
btn.Position=UDim2.new(0.05,0,0.4,0)
btn.BackgroundColor3=Color3.fromRGB(60,60,70)
btn.Text="NOCLIP: OFF"
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
local function setCollide(state)
    local char=player.Character
    if not char then return end
    for _,part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide=state
        end
    end
end
local function start()
    if conn then return end
    conn=RS.Stepped:Connect(function()
        if not enabled then return end
        setCollide(false)
    end)
end
local function stop()
    if conn then conn:Disconnect() conn=nil end
    setCollide(true)
end
btn.MouseButton1Click:Connect(function()
    enabled=not enabled
    if enabled then
        btn.Text="NOCLIP: ON"
        btn.BackgroundColor3=Color3.fromRGB(0,150,80)
        start()
    else
        btn.Text="NOCLIP: OFF"
        btn.BackgroundColor3=Color3.fromRGB(60,60,70)
        stop()
    end
end)
player.CharacterAdded:Connect(function()
    if enabled then
        enabled=false
        btn.Text="NOCLIP: OFF"
        btn.BackgroundColor3=Color3.fromRGB(60,60,70)
        if conn then conn:Disconnect() conn=nil end
    end
end)
