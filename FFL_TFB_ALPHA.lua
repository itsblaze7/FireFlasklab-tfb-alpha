--// [FFL TFB ALPHA] V1 - SOCCER: TOUCH FOOTBALL EXPLOIT
--// MADE BY ITS_BLAZE7 - AGGRESSIVE HACKER EDITION
--// OPTIMIZED, LAG-FREE, FULLY CUSTOMIZABLE

print("                                         ")
print(" █████▒▄▄▄█████▓ ▄▄▄▄    ▄▄▄        ██▓    ▓█████  ▒██   ██▒")
print("▓██   ▒ ▓  ██▒ ▓▒▓█████▄ ▒████▄     ▓██▒    ▓█   ▀  ▒▒ █ █ ▒░")
print("▒████ ░ ▒ ▓██░ ▒░▒██▒ ▄██▒██  ▀█▄   ▒██░    ▒███    ░░  █   ░")
print("░▓█▒  ░ ░ ▓██▓ ░ ▒██░█▀  ░██▄▄▄▄██  ▒██░    ▒▓█  ▄   ░ █ █ ▒ ")
print("░▒█░      ▒██▒ ░ ░▓█  ▀█▓ ▓█   ▓██▒ ░██████▒░▒████▒ ▒██▒ ▒██▒")
print(" ▒ ░      ▒ ░░   ░▒▓███▀▒ ▒▒   ▓▒█░ ░ ▒░▓  ░░░ ▒░ ░ ▒▒ ░ ░▓ ░")
print(" ░          ░     ░▒   ▒   ▒   ▒▒ ░ ░ ░ ▒  ░ ░ ░  ░ ░░   ░▒ ░")
print("░ ░       ░        ░   ░   ░   ▒      ░ ░      ░     ░    ░  ")
print("                     ░         ░  ░     ░  ░   ░  ░   ░ ░    ")
print("                                                          ")
print("==========[ FFL TFB ALPHA ]==========")
print("VERSION: V1 | EXPLOIT ACTIVE")
print("MADE BY: ITS_BLAZE7")
print("PASSWORD REQUIRED - UNLOCK THE POWER")
print("=====================================")

--// LOAD RAYFIELD LIBRARY
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

--// PERSISTENCE SYSTEM
local function saveScriptState()
    writefile("FFL_TFB_State.txt", game:GetService("HttpService"):JSONEncode(getgenv().Values))
end

local function loadScriptState()
    if isfile("FFL_TFB_State.txt") then
        local success, result = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile("FFL_TFB_State.txt"))
        end)
        if success then return result end
    end
    return {}
end

--// INITIALIZE GETGENV
getgenv().Toggles = {
    Aimbot = false,
    Powershot = false,
    NoClip = false,
    Fly = false,
    WalkSpeed = false
}

getgenv().Keybinds = {
    Aimbot = "B",
    Powershot = "P",
    NoClip = "N",
    Fly = "G",
    TeleportBall = "F",
    BringBall = "Q",
    ExtraJumps = "M"
}

getgenv().Values = loadScriptState()

if not getgenv().Values.WalkSpeedVal then getgenv().Values.WalkSpeedVal = 16 end
if not getgenv().Values.JumpHeightVal then getgenv().Values.JumpHeightVal = 50 end
if not getgenv().Values.ExtraJumpsVal then getgenv().Values.ExtraJumpsVal = 0 end
if not getgenv().Values.FlySpeedVal then getgenv().Values.FlySpeedVal = 50 end
if not getgenv().Values.ShotPowerVal then getgenv().Values.ShotPowerVal = 250 end
if not getgenv().Values.TargetGoal then getgenv().Values.TargetGoal = "OpponentGoal" end

--// VARIABLES
local Player = game:GetService("Players").LocalPlayer
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local flying = false
local noclipState = false
local originalProperties = {}
local flyConnection = nil
local heartbeatConnection = nil
local currentGoal = nil
local selectedGoalButton = nil

--// BALL DETECTION FUNCTION
local function findSoccerBall()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("ball") or obj.Name:lower():find("soccer")) then
            return obj
        end
    end
    return nil
end

--// FIND GOALS
local function findOpponentGoal()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("goal") and not obj.Name:lower():find("mygoal")) then
            return obj
        end
    end
    return nil
end

local function findMyGoal()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("mygoal")) then
            return obj
        end
    end
    return nil
end

--// AIMBOT LOGIC - SHOOTS TOWARD SELECTED GOAL
local function aimbotShoot(ball)
    if not getgenv().Toggles.Aimbot then return end
    
    local targetGoal
    if getgenv().Values.TargetGoal == "OpponentGoal" then
        targetGoal = findOpponentGoal()
    else
        targetGoal = findMyGoal()
    end
    
    if ball and targetGoal then
        local direction = (targetGoal.Position - ball.Position).unit
        local power = getgenv().Toggles.Powershot and getgenv().Values.ShotPowerVal or 75
        ball:ApplyImpulse(direction * power)
        Rayfield:Notify({Title = "⚽ AIMBOT", Content = "BLASTED TOWARD " .. getgenv().Values.TargetGoal:upper(), Duration = 1})
    end
end

--// FLY SYSTEM
local function startFly()
    if flying then return end
    flying = true
    local char = Player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end
    
    hum.PlatformStand = true
    if flyConnection then flyConnection:Disconnect() end
    flyConnection = RS.RenderStepped:Connect(function(deltaTime)
        if not flying or not hrp or not hum then
            if flyConnection then flyConnection:Disconnect() end
            return
        end
        local speed = getgenv().Values.FlySpeedVal
        local moveDirection = Vector3.new()
        if UIS:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then moveDirection = moveDirection - Vector3.new(0, 1, 0) end
        
        hrp.Velocity = moveDirection * speed
    end)
end

local function stopFly()
    if not flying then return end
    flying = false
    if flyConnection then flyConnection:Disconnect() end
    local char = Player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.PlatformStand = false
    end
end

--// NO CLIP
local function setNoClip(state)
    noclipState = state
    local char = Player.Character
    if not char then return end
    if state then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                originalProperties[part] = part.CanCollide
                part.CanCollide = false
            end
        end
    else
        for part, original in pairs(originalProperties) do
            if part and part.Parent then
                part.CanCollide = original
            end
        end
        originalProperties = {}
    end
end

--// CUSTOM PASSWORD UI
local function showPasswordUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FFL_PasswordUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 220)
    frame.Position = UDim2.new(0.5, -175, 0.5, -110)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    frame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    title.Text = "🔐 FFL TFB ALPHA - KEY REQUIRED"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = frame
    
    local keyBox = Instance.new("TextBox")
    keyBox.Size = UDim2.new(0.8, 0, 0, 40)
    keyBox.Position = UDim2.new(0.1, 0, 0.35, 0)
    keyBox.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyBox.Font = Enum.Font.Gotham
    keyBox.TextSize = 16
    keyBox.PlaceholderText = "Enter your key..."
    keyBox.Text = ""
    keyBox.ClearTextOnFocus = false
    keyBox.Parent = frame
    
    local enterBtn = Instance.new("TextButton")
    enterBtn.Size = UDim2.new(0.35, 0, 0, 40)
    enterBtn.Position = UDim2.new(0.55, 0, 0.65, 0)
    enterBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    enterBtn.Text = "▶ ENTER"
    enterBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    enterBtn.Font = Enum.Font.GothamBold
    enterBtn.TextSize = 16
    enterBtn.Parent = frame
    
    local getKeyBtn = Instance.new("TextButton")
    getKeyBtn.Size = UDim2.new(0.35, 0, 0, 40)
    getKeyBtn.Position = UDim2.new(0.1, 0, 0.65, 0)
    getKeyBtn.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
    getKeyBtn.Text = "🔑 GET KEY"
    getKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    getKeyBtn.Font = Enum.Font.GothamBold
    getKeyBtn.TextSize = 16
    getKeyBtn.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, 0, 0, 30)
    status.Position = UDim2.new(0, 0, 0.85, 0)
    status.BackgroundTransparency = 1
    status.Text = ""
    status.TextColor3 = Color3.fromRGB(255, 100, 100)
    status.Font = Enum.Font.Gotham
    status.TextSize = 14
    status.Parent = frame
    
    enterBtn.MouseButton1Click:Connect(function()
        if keyBox.Text == "Blazexfire1" then
            screenGui:Destroy()
            loadMainUI()
        else
            status.Text = "INVALID KEY! ACCESS DENIED"
            wait(2)
            status.Text = ""
        end
    end)
    
    getKeyBtn.MouseButton1Click:Connect(function()
        setclipboard("https://discord.gg/nJ6P8VVSCm")
        status.Text = "DISCORD LINK COPIED!"
        wait(2)
        status.Text = ""
    end)
end

--// OPTIMIZED RUNSERVICE LOOP
local function setupMainLoop()
    if heartbeatConnection then heartbeatConnection:Disconnect() end
    local lastBallCheck = 0
    heartbeatConnection = RS.Heartbeat:Connect(function(deltaTime)
        local char = Player.Character
        if not char then return end
        
        -- WALKSPEED (only if toggled)
        if getgenv().Toggles.WalkSpeed and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = getgenv().Values.WalkSpeedVal
        elseif char:FindFirstChild("Humanoid") and not getgenv().Toggles.WalkSpeed then
            char.Humanoid.WalkSpeed = 16
        end
        
        -- JUMP POWER (only if toggled)
        if char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = getgenv().Values.JumpHeightVal
        end
        
        -- BALL DETECTION AND AIMBOT (throttled)
        lastBallCheck = lastBallCheck + deltaTime
        if lastBallCheck > 0.1 then
            lastBallCheck = 0
            local ball = findSoccerBall()
            if ball and getgenv().Toggles.Aimbot then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp and (hrp.Position - ball.Position).magnitude < 8 then
                    aimbotShoot(ball)
                end
            end
        end
    end)
end

--// MAIN UI FUNCTION
function loadMainUI()
    local Window = Rayfield:CreateWindow({
        Name = "⚽ [FFL TFB ALPHA] V1",
        Icon = 0,
        LoadingTitle = "LOADING HACKS",
        LoadingSubtitle = "PREPARING DOMINATION",
        Theme = "Default",
        ToggleUIKeybind = "K",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "FFL_TFB",
            FileName = "Settings"
        }
    })
    
    -- Apply custom theme colors (Orange, Black, Dark Red)
    local customTheme = {
        Background = Color3.fromRGB(25, 25, 35),
        Accent = Color3.fromRGB(255, 85, 0),
        Secondary = Color3.fromRGB(139, 0, 0),
        Text = Color3.fromRGB(255, 255, 255)
    }
    -- Note: Rayfield doesn't directly support custom themes, but we can modify UI elements
    -- after creation. For now, we'll use Default and rely on element colors.
    
    --// TAB 1: MAIN
    local mainTab = Window:CreateTab("⚽ MAIN", nil)
    
    -- Customizable Keybind Section
    local keybindSection = mainTab:CreateSection("⚡ HOTKEY SETTINGS")
    
    -- Keybind Inputs
    local aimbotKeybind = mainTab:CreateInput({
        Name = "Aimbot Keybind",
        PlaceholderText = "Key (e.g., B)",
        CurrentValue = getgenv().Keybinds.Aimbot,
        Flag = "AimbotKey",
        Callback = function(Value)
            if #Value == 1 then
                getgenv().Keybinds.Aimbot = Value:upper()
                saveScriptState()
                Rayfield:Notify({Title = "KEYBIND UPDATED", Content = "Aimbot: "..Value:upper(), Duration = 1})
            else
                Rayfield:Notify({Title = "INVALID", Content = "Single character only", Duration = 1})
            end
        end
    })
    
    local powershotKeybind = mainTab:CreateInput({
        Name = "Powershot Keybind",
        PlaceholderText = "Key (e.g., P)",
        CurrentValue = getgenv().Keybinds.Powershot,
        Flag = "PowershotKey",
        Callback = function(Value)
            if #Value == 1 then
                getgenv().Keybinds.Powershot = Value:upper()
                saveScriptState()
                Rayfield:Notify({Title = "KEYBIND UPDATED", Content = "Powershot: "..Value:upper(), Duration = 1})
            else
                Rayfield:Notify({Title = "INVALID", Content = "Single character only", Duration = 1})
            end
        end
    })
    
    local noclipKeybind = mainTab:CreateInput({
        Name = "NoClip Keybind",
        PlaceholderText = "Key (e.g., N)",
        CurrentValue = getgenv().Keybinds.NoClip,
        Flag = "NoClipKey",
        Callback = function(Value)
            if #Value == 1 then
                getgenv().Keybinds.NoClip = Value:upper()
                saveScriptState()
                Rayfield:Notify({Title = "KEYBIND UPDATED", Content = "NoClip: "..Value:upper(), Duration = 1})
            else
                Rayfield:Notify({Title = "INVALID", Content = "Single character only", Duration = 1})
            end
        end
    end
    
    local flyKeybind = mainTab:CreateInput({
        Name = "Fly Keybind",
        PlaceholderText = "Key (e.g., G)",
        CurrentValue = getgenv().Keybinds.Fly,
        Flag = "FlyKey",
        Callback = function(Value)
            if #Value == 1 then
                getgenv().Keybinds.Fly = Value:upper()
                saveScriptState()
                Rayfield:Notify({Title = "KEYBIND UPDATED", Content = "Fly: "..Value:upper(), Duration = 1})
            else
                Rayfield:Notify({Title = "INVALID", Content = "Single character only", Duration = 1})
            end
        end
    end
    
    local aimSection = mainTab:CreateSection("⚽ AIMBOT")
    
    local aimbotToggle = mainTab:CreateToggle({
        Name = "Aimbot ["..getgenv().Keybinds.Aimbot.."]",
        CurrentValue = getgenv().Toggles.Aimbot,
        Flag = "AimbotToggle",
        Callback = function(Value)
            getgenv().Toggles.Aimbot = Value
            aimbotToggle:SetName("Aimbot ["..getgenv().Keybinds.Aimbot.."]")
            Rayfield:Notify({Title = "AIMBOT", Content = Value and "ACTIVE ⚡" or "OFF ❌", Duration = 1})
        end
    })
    
    local powershotToggle = mainTab:CreateToggle({
        Name = "Powershot ["..getgenv().Keybinds.Powershot.."]",
        CurrentValue = getgenv().Toggles.Powershot,
        Flag = "PowershotToggle",
        Callback = function(Value)
            getgenv().Toggles.Powershot = Value
            powershotToggle:SetName("Powershot ["..getgenv().Keybinds.Powershot.."]")
            Rayfield:Notify({Title = "POWERSHOT", Content = Value and "MAX POWER 💥" or "OFF ❌", Duration = 1})
        end
    })
    
    local powerInput = mainTab:CreateInput({
        Name = "💪 SHOT POWER",
        PlaceholderText = "Enter power (50-500)",
        CurrentValue = tostring(getgenv().Values.ShotPowerVal),
        Flag = "ShotPower",
        Callback = function(Value)
            local num = tonumber(Value)
            if num and num >= 50 and num <= 500 then
                getgenv().Values.ShotPowerVal = num
                saveScriptState()
                Rayfield:Notify({Title = "SHOT POWER", Content = "Set to "..num, Duration = 1})
            else
                Rayfield:Notify({Title = "INVALID", Content = "Use 50-500", Duration = 1})
            end
        end
    })
    
    -- Goal Selection Section
    local goalSection = mainTab:CreateSection("🎯 GOAL SELECTION")
    
    local function highlightGoalButton(button, isSelected)
        if isSelected then
            button:SetBackgroundColor(Color3.fromRGB(255, 85, 0))
        else
            button:SetBackgroundColor(Color3.fromRGB(40, 40, 50))
        end
    end
    
    local opponentGoalBtn = mainTab:CreateButton({
        Name = "🎯 OPPONENT GOAL",
        Callback = function()
            getgenv().Values.TargetGoal = "OpponentGoal"
            saveScriptState()
            highlightGoalButton(opponentGoalBtn, true)
            highlightGoalButton(myGoalBtn, false)
            Rayfield:Notify({Title = "GOAL SET", Content = "Targeting opponent goal", Duration = 1})
        end
    })
    opponentGoalBtn:SetBackgroundColor(Color3.fromRGB(255, 85, 0))
    
    local myGoalBtn = mainTab:CreateButton({
        Name = "🏠 MY GOAL",
        Callback = function()
            getgenv().Values.TargetGoal = "MyGoal"
            saveScriptState()
            highlightGoalButton(myGoalBtn, true)
            highlightGoalButton(opponentGoalBtn, false)
            Rayfield:Notify({Title = "GOAL SET", Content = "Targeting my goal", Duration = 1})
        end
    })
    myGoalBtn:SetBackgroundColor(Color3.fromRGB(40, 40, 50))
    
    if getgenv().Values.TargetGoal == "MyGoal" then
        highlightGoalButton(myGoalBtn, true)
    else
        highlightGoalButton(opponentGoalBtn, true)
    end
    
    local ballSection = mainTab:CreateSection("⚽ BALL CONTROL")
    
    local teleportBtn = mainTab:CreateButton({
        Name = "📍 TELEPORT TO BALL ["..getgenv().Keybinds.TeleportBall.."]",
        Callback = function()
            local ball = findSoccerBall()
            if ball and Player.Character then
                Player.Character:SetPrimaryPartCFrame(ball.CFrame + Vector3.new(0, 3, 0))
                Rayfield:Notify({Title = "TELEPORT", Content = "BALL REACHED", Duration = 1})
            end
        end
    })
    
    local bringBtn = mainTab:CreateButton({
        Name = "🔄 BRING BALL TO ME ["..getgenv().Keybinds.BringBall.."]",
        Callback = function()
            local ball = findSoccerBall()
            if ball and Player.Character then
                ball.CFrame = Player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                Rayfield:Notify({Title = "BRING", Content = "BALL OBTAINED", Duration = 1})
            end
        end
    })
    
    local statusLabel = mainTab:CreateLabel("🔍 SEARCHING FOR BALL...")
    local function updateStatusLabel()
        local ball = findSoccerBall()
        if ball then
            statusLabel:Set("⚽ BALL FOUND | READY TO DOMINATE")
        else
            statusLabel:Set("❌ BALL NOT FOUND | SEARCHING...")
        end
    end
    updateStatusLabel()
    spawn(function()
        while true do
            wait(2)
            updateStatusLabel()
        end
    end)
    
    --// TAB 2: POWER UPS
    local powerTab = Window:CreateTab("⚡ POWER UPS", nil)
    
    local creditLabel = powerTab:CreateLabel("🔥 MADE BY [ITS_BLAZE7] 🔥")
    
    local flySection = powerTab:CreateSection("✈️ FLIGHT")
    
    local flyToggle = powerTab:CreateToggle({
        Name = "CFrame Fly ["..getgenv().Keybinds.Fly.."]",
        CurrentValue = false,
        Flag = "FlyToggle",
        Callback = function(Value)
            if Value then
                startFly()
            else
                stopFly()
            end
            flyToggle:SetName("CFrame Fly ["..getgenv().Keybinds.Fly.."]")
            Rayfield:Notify({Title = "FLY MODE", Content = Value and "ACTIVE ✈️" or "OFF ❌", Duration = 1})
        end
    })
    
    local flySpeedSlider = powerTab:CreateSlider({
        Name = "🚀 FLY SPEED",
        Range = {10, 200},
        Increment = 5,
        Suffix = "Speed",
        CurrentValue = getgenv().Values.FlySpeedVal,
        Flag = "FlySpeed",
        Callback = function(Value)
            getgenv().Values.FlySpeedVal = Value
            saveScriptState()
        end
    })
    
    local speedSection = powerTab:CreateSection("🏃 MOVEMENT")
    
    local walkspeedToggle = powerTab:CreateToggle({
        Name = "WalkSpeed Hack",
        CurrentValue = getgenv().Toggles.WalkSpeed,
        Flag = "WalkSpeedToggle",
        Callback = function(Value)
            getgenv().Toggles.WalkSpeed = Value
            Rayfield:Notify({Title = "WALKSPEED", Content = Value and "ENABLED 🏃" or "DISABLED ❌", Duration = 1})
        end
    })
    
    local speedSlider = powerTab:CreateSlider({
        Name = "🏃 WALKSPEED VALUE",
        Range = {8, 120},
        Increment = 1,
        Suffix = "Speed",
        CurrentValue = getgenv().Values.WalkSpeedVal,
        Flag = "WalkSpeed",
        Callback = function(Value)
            getgenv().Values.WalkSpeedVal = Value
            saveScriptState()
        end
    })
    
    local jumpSection = powerTab:CreateSection("🦘 JUMP")
    
    local jumpHeightSlider = powerTab:CreateSlider({
        Name = "Jump Height",
        Range = {30, 500},
        Increment = 10,
        Suffix = "Power",
        CurrentValue = getgenv().Values.JumpHeightVal,
        Flag = "JumpHeight",
        Callback = function(Value)
            getgenv().Values.JumpHeightVal = Value
            saveScriptState()
        end
    })
    
    local extraJumpsSlider = powerTab:CreateSlider({
        Name = "Extra Jumps Power ["..getgenv().Keybinds.ExtraJumps.."]",
        Range = {0, 50},
        Increment = 1,
        Suffix = "Extra Jumps",
        CurrentValue = getgenv().Values.ExtraJumpsVal,
        Flag = "ExtraJumps",
        Callback = function(Value)
            getgenv().Values.ExtraJumpsVal = Value
            saveScriptState()
        end
    })
    
    local noClipToggle = powerTab:CreateToggle({
        Name = "No Clip ["..getgenv().Keybinds.NoClip.."]",
        CurrentValue = getgenv().Toggles.NoClip,
        Flag = "NoClipToggle",
        Callback = function(Value)
            getgenv().Toggles.NoClip = Value
            setNoClip(Value)
            noClipToggle:SetName("No Clip ["..getgenv().Keybinds.NoClip.."]")
            Rayfield:Notify({Title = "NOCLIP", Content = Value and "ACTIVE 🔓" or "OFF 🔒", Duration = 1})
        end
    })
    
    --// SUPPORT BUTTON
    local supportSection = powerTab:CreateSection("🆘 SUPPORT")
    local supportBtn = powerTab:CreateButton({
        Name = "🆘 NEED HELP? JOIN DISCORD",
        Callback = function()
            setclipboard("https://discord.gg/nJ6P8VVSCm")
            Rayfield:Notify({Title = "DISCORD LINK COPIED", Content = "Join for support", Duration = 2})
        end
    })
    supportBtn:SetBackgroundColor(Color3.fromRGB(255, 85, 0))
    
    --// KEYBINDS WITH CUSTOMIZABLE KEYS
    UIS.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        local key = input.KeyCode.Name
        
        if key == getgenv().Keybinds.Aimbot then
            aimbotToggle:Set(not aimbotToggle.CurrentValue)
            aimbotToggle:SetName("Aimbot ["..getgenv().Keybinds.Aimbot.."]")
        elseif key == getgenv().Keybinds.Powershot then
            powershotToggle:Set(not powershotToggle.CurrentValue)
            powershotToggle:SetName("Powershot ["..getgenv().Keybinds.Powershot.."]")
        elseif key == getgenv().Keybinds.NoClip then
            noClipToggle:Set(not noClipToggle.CurrentValue)
            noClipToggle:SetName("No Clip ["..getgenv().Keybinds.NoClip.."]")
        elseif key == getgenv().Keybinds.Fly then
            flyToggle:Set(not flyToggle.CurrentValue)
            flyToggle:SetName("CFrame Fly ["..getgenv().Keybinds.Fly.."]")
        elseif key == getgenv().Keybinds.ExtraJumps then
            local char = Player.Character
            if char and char:FindFirstChild("Humanoid") then
                for i = 1, getgenv().Values.ExtraJumpsVal do
                    task.wait(0.05)
                    char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
                Rayfield:Notify({Title = "EXTRA JUMPS", Content = "POWER ACTIVATED", Duration = 1})
            end
        elseif key == getgenv().Keybinds.TeleportBall then
            teleportBtn:Call()
        elseif key == getgenv().Keybinds.BringBall then
            bringBtn:Call()
        end
    end)
    
    -- Start the optimized main loop
    setupMainLoop()
    
    -- NOTIFY HOTKEYS
    local hotkeyMsg = "["..getgenv().Keybinds.Aimbot.."] Aimbot | ["..getgenv().Keybinds.Powershot.."] Powershot | ["..getgenv().Keybinds.NoClip.."] NoClip | ["..getgenv().Keybinds.Fly.."] Fly"
    Rayfield:Notify({Title = "🔥 FFL TFB ALPHA UNLOCKED 🔥", Content = hotkeyMsg, Duration = 8})
end

--// AUTO-REEXECUTE ON TELEPORT
local function autoReexecute()
    local player = game.Players.LocalPlayer
    if player then
        player.OnTeleport:Connect(function()
            task.wait(2)
            loadstring(game:HttpGet("https://raw.githubusercontent.com/itsblaze7/FireFlasklab-tfb-alpha/refs/heads/main/FFL_TFB_ALPHA.lua"))()
        end)
    end
end
autoReexecute()

--// START PASSWORD UI
showPasswordUI()
