local player=game.Players.LocalPlayer
local RS=game:GetService("RunService")
local CG=game:GetService("CoreGui")
local SoundService=game:GetService("SoundService")

-- 既存のBGMを止める
local originalSounds={}
for _,v in ipairs(game:GetDescendants()) do
    if v:IsA("Sound") then
        originalSounds[v]={volume=v.Volume,playing=v.Playing}
        v.Volume=0
    end
end

-- GUI
local gui=Instance.new("ScreenGui")
gui.Name=tostring(math.random(100000,999999))
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end

-- 虹色背景
local rainbowFrame=Instance.new("Frame")
rainbowFrame.Size=UDim2.new(1,0,1,0)
rainbowFrame.BackgroundColor3=Color3.fromRGB(255,255,255)
rainbowFrame.BorderSizePixel=0
rainbowFrame.ZIndex=1
rainbowFrame.Parent=gui

local gradient=Instance.new("UIGradient")
gradient.Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),
    ColorSequenceKeypoint.new(0.17,Color3.fromRGB(255,255,0)),
    ColorSequenceKeypoint.new(0.33,Color3.fromRGB(0,255,0)),
    ColorSequenceKeypoint.new(0.5,Color3.fromRGB(0,255,255)),
    ColorSequenceKeypoint.new(0.67,Color3.fromRGB(0,0,255)),
    ColorSequenceKeypoint.new(0.83,Color3.fromRGB(255,0,255)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(255,0,0))
})
gradient.Rotation=0
gradient.Parent=rainbowFrame

-- キー入力画面
local keyFrame=Instance.new("Frame")
keyFrame.Size=UDim2.new(0,260,0,160)
keyFrame.Position=UDim2.new(0.5,-130,0.5,-80)
keyFrame.BackgroundColor3=Color3.fromRGB(15,15,20)
keyFrame.BorderSizePixel=0
keyFrame.ZIndex=10
keyFrame.Parent=gui

local kfc=Instance.new("UICorner")
kfc.CornerRadius=UDim.new(0,12)
kfc.Parent=keyFrame

local kStroke=Instance.new("UIStroke")
kStroke.Color=Color3.fromRGB(255,255,255)
kStroke.Thickness=2
kStroke.Parent=keyFrame

local kTitle=Instance.new("TextLabel")
kTitle.Size=UDim2.new(1,0,0,30)
kTitle.BackgroundTransparency=1
kTitle.Text="🌈 Enter Key 🌈"
kTitle.TextColor3=Color3.fromRGB(255,255,255)
kTitle.Font=Enum.Font.GothamBold
kTitle.TextSize=16
kTitle.ZIndex=11
kTitle.Parent=keyFrame

local kBox=Instance.new("TextBox")
kBox.Size=UDim2.new(0.8,0,0,36)
kBox.Position=UDim2.new(0.1,0,0.28,0)
kBox.BackgroundColor3=Color3.fromRGB(40,40,55)
kBox.BorderSizePixel=0
kBox.PlaceholderText="Key..."
kBox.Text=""
kBox.TextColor3=Color3.fromRGB(255,255,255)
kBox.Font=Enum.Font.GothamBold
kBox.TextSize=14
kBox.ZIndex=11
kBox.Parent=keyFrame

local kbc=Instance.new("UICorner")
kbc.CornerRadius=UDim.new(0,6)
kbc.Parent=kBox

local kBtn=Instance.new("TextButton")
kBtn.Size=UDim2.new(0.8,0,0,32)
kBtn.Position=UDim2.new(0.1,0,0.62,0)
kBtn.BackgroundColor3=Color3.fromRGB(100,50,150)
kBtn.Text="VERIFY"
kBtn.TextColor3=Color3.fromRGB(255,255,255)
kBtn.Font=Enum.Font.GothamBold
kBtn.TextSize=14
kBtn.ZIndex=11
kBtn.Parent=keyFrame

local kbtc=Instance.new("UICorner")
kbtc.CornerRadius=UDim.new(0,6)
kbtc.Parent=kBtn

-- 虹色アニメーション
local hue=0
local conn=RS.Heartbeat:Connect(function(dt)
    hue=(hue+dt*0.4)%1
    gradient.Rotation=(gradient.Rotation+dt*60)%360
    local c1=Color3.fromHSV(hue,1,1)
    local c2=Color3.fromHSV((hue+0.17)%1,1,1)
    local c3=Color3.fromHSV((hue+0.33)%1,1,1)
    local c4=Color3.fromHSV((hue+0.5)%1,1,1)
    local c5=Color3.fromHSV((hue+0.67)%1,1,1)
    local c6=Color3.fromHSV((hue+0.83)%1,1,1)
    gradient.Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,c1),
        ColorSequenceKeypoint.new(0.17,c2),
        ColorSequenceKeypoint.new(0.33,c3),
        ColorSequenceKeypoint.new(0.5,c4),
        ColorSequenceKeypoint.new(0.67,c5),
        ColorSequenceKeypoint.new(0.83,c6),
        ColorSequenceKeypoint.new(1,c1)
    })
    kStroke.Color=Color3.fromHSV((hue+0.5)%1,1,1)
end)

-- キー
local KEY="rainbow"

-- キックメッセージ
local KICK_MSG="Your body has been swallowed up by a rainbow-colored vortex! Rainbooooooooooow!"

-- 音楽を爆音で流してキック
local function playAndKick()
    local music=Instance.new("Sound")
    music.Name="LoudMusic"
    music.SoundId="rbxassetid://1837879082"
    music.Volume=10
    music.Looped=false
    music.Parent=SoundService
    music:Play()

    task.wait(5)
    if conn then conn:Disconnect() end
    player:Kick(KICK_MSG)
end

kBtn.MouseButton1Click:Connect(function()
    if kBox.Text==KEY then
        keyFrame:Destroy()
        playAndKick()
    else
        kBtn.Text="Wrong Key"
        kBtn.BackgroundColor3=Color3.fromRGB(180,50,50)
        task.wait(1)
        kBtn.Text="VERIFY"
        kBtn.BackgroundColor3=Color3.fromRGB(100,50,150)
        kBox.Text=""
    end
end)

getgenv().StopRainbowKick=function()
    if conn then conn:Disconnect() end
    if gui then gui:Destroy() end
    for s,data in pairs(originalSounds) do
        if s and s.Parent then
            s.Volume=data.volume
        end
    end
    warn("RainbowKick 停止")
end

warn("RainbowKick 起動")
warn("キー: "..KEY)
