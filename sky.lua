local player=game.Players.LocalPlayer
local RS=game:GetService("RunService")
local CG=game:GetService("CoreGui")
local gui=Instance.new("ScreenGui")
gui.Name="DeltaAirlift"
gui.ResetOnSpawn=false
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end
local btn=Instance.new("TextButton")
btn.Size=UDim2.new(0,140,0,60)
btn.Position=UDim2.new(0.05,0,0.4,0)
btn.BackgroundColor3=Color3.fromRGB(60,60,70)
btn.Text="SKY: OFF"
btn.TextColor3=Color3.fromRGB(255,255,255)
btn.Font=Enum.Font.GothamBold
btn.TextSize=13
btn.Active=true
btn.Draggable=true
btn.Parent=gui
local bc=Instance.new("UICorner")
bc.CornerRadius=UDim.new(0,10)
bc.Parent=btn
local enabled=false
local power=300
local function airlift(target)
    if not target then return end
    local char=target.Character
    if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local bv=Instance.new("BodyVelocity")
    bv.MaxForce=Vector3.new(1e5,1e6,1e5)
    bv.Velocity=Vector3.new(
        math.random(-50,50),
        power,
        math.random(-50,50)
    )
    bv.Parent=hrp
    game:GetService("Debris"):AddItem(bv,0.3)
end
RS.Heartbeat:Connect(function()
    if not enabled then return end
    for _,pl in ipairs(game.Players:GetPlayers()) do
        if pl~=player then
            airlift(pl)
        end
    end
end)
btn.MouseButton1Click:Connect(function()
    enabled=not enabled
    if enabled then
        btn.Text="SKY: ON"
        btn.BackgroundColor3=Color3.fromRGB(0,150,80)
    else
        btn.Text="SKY: OFF"
        btn.BackgroundColor3=Color3.fromRGB(60,60,70)
    end
end)
player.CharacterAdded:Connect(function()
    if enabled then
        enabled=false
        btn.Text="SKY: OFF"
        btn.BackgroundColor3=Color3.fromRGB(60,60,70)
    end
end)
