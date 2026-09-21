local player=game.Players.LocalPlayer
local RS=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local CG=game:GetService("CoreGui")
local gui=Instance.new("ScreenGui")
gui.Name="DeltaFloat"
gui.ResetOnSpawn=false
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end
local btn=Instance.new("TextButton")
btn.Size=UDim2.new(0,150,0,60)
btn.Position=UDim2.new(0.05,0,0.4,0)
btn.BackgroundColor3=Color3.fromRGB(60,60,70)
btn.Text="FLOAT: OFF"
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
local floatParts={}
local function isFloating(part)
    for _,p in ipairs(floatParts) do
        if p.part==part then return true end
    end
    return false
end
local function removeFloat(part)
    for i,p in ipairs(floatParts) do
        if p.part==part then
            if p.bv then p.bv:Destroy() end
            table.remove(floatParts,i)
            return
        end
    end
end
local function addFloat(part)
    if isFloating(part) then return end
    if not part:IsA("BasePart") then return end
    local bv=Instance.new("BodyVelocity")
    bv.MaxForce=Vector3.new(1e5,1e5,1e5)
    bv.Velocity=Vector3.zero
    bv.Parent=part
    table.insert(floatParts,{part=part,bv=bv})
end
task.spawn(function()
    while true do
        if enabled then
            for _,obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local parent=obj.Parent
                    if parent and (parent.Name:lower():find("grab") or parent.Name:lower():find("hold") or parent.Name:lower():find("carry") or parent.Name:lower():find("blob")) then
                        addFloat(obj)
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)
UIS.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.UserInputType~=Enum.UserInputType.Touch then return end
    local pos=input.Position
    local ray=workspace.CurrentCamera:ViewportPointToRay(pos.X,pos.Y)
    local params=RaycastParams.new()
    params.FilterDescendantsInstances={player.Character}
    params.FilterType=Enum.RaycastFilterType.Exclude
    local result=workspace:Raycast(ray.Origin,ray.Direction*500,params)
    if result and result.Instance then
        if isFloating(result.Instance) then
            removeFloat(result.Instance)
        end
    end
end)
btn.MouseButton1Click:Connect(function()
    enabled=not enabled
    if enabled then
        btn.Text="FLOAT: ON"
        btn.BackgroundColor3=Color3.fromRGB(0,150,80)
    else
        btn.Text="FLOAT: OFF"
        btn.BackgroundColor3=Color3.fromRGB(60,60,70)
    end
end)
player.CharacterAdded:Connect(function()
    if enabled then
        enabled=false
        btn.Text="FLOAT: OFF"
        btn.BackgroundColor3=Color3.fromRGB(60,60,70)
    end
end)
