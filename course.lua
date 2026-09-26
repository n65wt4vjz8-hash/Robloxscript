local player=game.Players.LocalPlayer
local CG=game:GetService("CoreGui")
local RS=game:GetService("RunService")

local platforms={}
local hiddenParts={}

local function getHRP()
    local char=player.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function hideGround()
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Anchored then
            local n=v.Name:lower()
            if n:find("baseplate") or n:find("ground") or n:find("floor") or n:find("terrain") then
                table.insert(hiddenParts,{part=v,transparency=v.Transparency,cancollide=v.CanCollide})
                v.Transparency=1
                v.CanCollide=false
            end
        end
    end
end

local function showGround()
    for _,data in ipairs(hiddenParts) do
        if data.part and data.part.Parent then
            data.part.Transparency=data.transparency
            data.part.CanCollide=data.cancollide
        end
    end
    hiddenParts={}
end

local function createCourse()
    local hrp=getHRP()
    if not hrp then return end
    local look=hrp.CFrame.LookVector
    local right=hrp.CFrame.RightVector
    local currentPos=hrp.Position+look*10
    local platformCount=100
    local heightStep=5
    local spread=50
    for i=1,platformCount do
        local platform=Instance.new("Part")
        platform.Name=tostring(math.random(100000,999999))
        platform.Size=Vector3.new(6,1,6)
        platform.Color=Color3.fromRGB(
            math.random(100,255),
            math.random(100,255),
            math.random(100,255)
        )
        platform.Material=Enum.Material.Neon
        platform.Anchored=true
        platform.CanCollide=true
        local forward=look*(math.random(8,15))
        local side=right*(math.random(-spread,spread))
        local up=Vector3.new(0,math.random(1,heightStep),0)
        currentPos=currentPos+forward+side+up
        platform.Position=currentPos
        platform.Parent=workspace
        table.insert(platforms,platform)
    end
end

local function removeCourse()
    for _,p in ipairs(platforms) do
        if p and p.Parent then
            p:Destroy()
        end
    end
    platforms={}
end

local function startCourse()
    hideGround()
    createCourse()
end

if player.Character then
    startCourse()
else
    player.CharacterAdded:Wait()
    task.wait(1)
    startCourse()
end

player.CharacterAdded:Connect(function()
    task.wait(1)
    if #platforms>0 then
        removeCourse()
        createCourse()
    end
end)

getgenv().StopCourse=function()
    showGround()
    removeCourse()
    warn("Course 停止")
end

warn("Course 起動")
warn("止めるには: getgenv().StopCourse()")
