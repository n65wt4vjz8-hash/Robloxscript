local player=game.Players.LocalPlayer
local RS=game:GetService("RunService")
local CG=game:GetService("CoreGui")
local gui=Instance.new("ScreenGui")
gui.Name=tostring(math.random(100000,999999))
gui.ResetOnSpawn=false
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end
local btn=Instance.new("TextButton")
btn.Name=tostring(math.random(100000,999999))
btn.Size=UDim2.new(0,140,0,60)
btn.Position=UDim2.new(0.05,0,0.4,0)
btn.BackgroundColor3=Color3.fromRGB(60,60,70)
btn.Text="LAG: OFF"
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
local spawnCount=100
local spawnRadius=50
local spawned={}
local lastSpawn=0
local function getHRP()
    local char=player.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end
local function spawnBoards()
    local hrp=getHRP()
    if not hrp then return end
    local center=hrp.Position
    for i=1,spawnCount do
        local board=Instance.new("Part")
        board.Name=tostring(math.random(100000,999999))
        board.Size=Vector3.new(4,0.2,4)
        board.Position=center+Vector3.new(
            math.random(-spawnRadius,spawnRadius),
            math.random(10,40),
            math.random(-spawnRadius,spawnRadius)
        )
        board.Anchored=true
        board.CanCollide=false
        board.Transparency=1
        board.Parent=workspace
        table.insert(spawned,board)
    end
end
local function clearAll()
    for _,b in ipairs(spawned) do
        if b and b.Parent then
            b:Destroy()
        end
    end
    spawned={}
end
RS.Heartbeat:Connect(function()
    if not enabled then return end
    local now=tick()
    if now-lastSpawn<1 then return end
    lastSpawn=now
    spawnBoards()
end)
btn.MouseButton1Click:Connect(function()
    enabled=not enabled
    if enabled then
        btn.Text="LAG: ON"
        btn.BackgroundColor3=Color3.fromRGB(180,50,50)
        lastSpawn=tick()
    else
        btn.Text="LAG: OFF"
        btn.BackgroundColor3=Color3.fromRGB(60,60,70)
    end
end)
player.CharacterAdded:Connect(function()
    if enabled then
        enabled=false
        btn.Text="LAG: OFF"
        btn.BackgroundColor3=Color3.fromRGB(60,60,70)
    end
end)
