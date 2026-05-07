--// [FFL TFB ALPHA] V1 - SOCCER: TOUCH FOOTBALL EXPLOIT
--// MADE BY ITS_BLAZE7 - AGGRESSIVE HACKER EDITION
--// FIXED: LAG, COLORS, EDITABLE KEYBINDS, GOAL SELECTION, JUMP TOGGLE, SUPPORT BUTTON

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

-- // LOAD RAYFIELD LIBRARY
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- // PERSISTENCE SYSTEM
local function saveScriptState(data)
    writefile("FFL_TFB_State.txt", game:GetService("HttpService"):JSONEncode(data))
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

-- // INITIALIZE GETGENV
getgenv().Toggles = {
    Aimbot = false,
    Powershot = false,
    NoClip = false,
    Fly = false,
    WalkSpeed = false,
    JumpPower = false   -- NEW: toggle for custom jump height
}

-- NEW: custom keybinds storage
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
if not getgenv().Values.ShotPowerVal then getgenv().Values.ShotPowerVal = 1000 end  -- increased default
if not getgenv().Values.TargetGoal then getgenv().Values.TargetGoal = "Opponent" end  -- NEW: goal selection

-- // VARIABLES
local Player = game:GetService("Players").LocalPlayer
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local flying = false
local noclipState = false
local originalProperties = {}
local flyConnection = nil
local lastBallCheck = 0   -- for throttling

-- // BALL DETECTION FUNCTION
local function findSoccerBall()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("ball") or obj.Name:lower():find("soccer")) then
            return obj
        end
    end
    return nil
end

-- // GOAL DETECTION (Opponent or My)
local function findGoal(goalType)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("goal") then
            if goalType == "Opponent" and not obj.Name:lower():find("my") then
                return obj
            elseif goalType == "My" and obj.Name:lower():find("my") then
                return obj
            end
        end
    end
    -- fallback: any goal
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("goal") then return obj end
    end
    return nil
end

-- // AIMBOT LOGIC (with goal selection)
local function aimbotShoot(ball)
    if not getgenv().Toggles.Aimbot then return end
    local targetGoal = findGoal(getgenv().Values.TargetGoal)
    if not ball or not targetGoal then return end
    local direction = (targetGoal.Position - ball.Position).unit
    local power = getgenv().Toggles.Powershot and getgenv().Values.ShotPowerVal or 75
    ball:ApplyImpulse(direction * power)
    Rayfield:Notify({Title = "⚽ AIMBOT", Content = "BLASTED TOWARD " .. getgenv().Values.TargetGoal .. " GOAL!", Duration = 1})
end

-- // FLY SYSTEM (unchanged)
local function startFly()
    if flying then return end
    flying = true
    local lplr = Player
    local char = lplr.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end
    
    hum.PlatformStand = true
    if flyConnection then flyConnection:Disconnect() end
    flyConnection = RS.RenderStepped:Connect(function()
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

-- // NO CLIP (unchanged)
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

-- // CUSTOM PASSWORD UI (unchanged)
local function showPasswordUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FFL_PasswordUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 200)
    frame.Position = UDim2.new(0.5, -175, 0.5, -100)
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
    enterBtn.Position = UDim2.new(0.1, 0, 0.65, 0)
    enterBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    enterBtn.Text = "▶ ENTER"
    enterBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    enterBtn.Font = Enum.Font.GothamBold
    enterBtn.TextSize = 16
    enterBtn.Parent = frame
    
    local getKeyBtn = Instance.new("TextButton")
    getKeyBtn.Size = UDim2.new(0.35, 0, 0, 40)
    getKeyBtn.Position = UDim2.new(0.55, 0, 0.65, 0)
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

-- // MAIN UI FUNCTION (minimally changed: theme, goal buttons, keybind inputs, support, jump toggle)
function loadMainUI()
    local Window = Rayfield:CreateWindow({
        Name = "⚽ [FFL TFB ALPHA] V1",
        Icon = 0,
        LoadingTitle = "LOADING HACKS",
        LoadingSubtitle = "PREPARING DOMINATION",
        Theme = "Obsidian",   -- Black/dark red theme (looks aggressive)
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "FFL_TFB",
            FileName = "Settings"
        }
    })
    
    -- // TAB 1: MAIN
    local mainTab = Window:CreateTab("⚽ MAIN", nil)
    
    -- NEW: Editable Keybinds Section
    local keySection = mainTab:CreateSection("⚡ CUSTOM HOTKEYS")
    
    local aimKeyInput = mainTab:CreateInput({
        Name = "Aimbot Key",
        PlaceholderText = "Single letter",
        CurrentValue = getgenv().Keybinds.Aimbot,
        Callback = function(v)
            if #v == 1 then getgenv().Keybinds.Aimbot = v:upper() saveScriptState(getgenv().Values) end
        end
    })
    local powerKeyInput = mainTab:CreateInput({
        Name = "Powershot Key",
        PlaceholderText = "Single letter",
        CurrentValue = getgenv().Keybinds.Powershot,
        Callback = function(v)
            if #v == 1 then getgenv().Keybinds.Powershot = v:upper() saveScriptState(getgenv().Values) end
        end
    })
    local noClipKeyInput = mainTab:CreateInput({
        Name = "NoClip Key",
        PlaceholderText = "Single letter",
        CurrentValue = getgenv().Keybinds.NoClip,
        Callback = function(v)
            if #v == 1 then getgenv().Keybinds.NoClip = v:upper() saveScriptState(getgenv().Values) end
        end
    })
    local flyKeyInput = mainTab:CreateInput({
        Name = "Fly Key",
        PlaceholderText = "Single letter",
        CurrentValue = getgenv().Keybinds.Fly,
        Callback = function(v)
            if #v == 1 then getgenv().Keybinds.Fly = v:upper() saveScriptState(getgenv().Values) end
        end
    })
    local extraKeyInput = mainTab:CreateInput({
        Name = "Extra Jumps Key",
        PlaceholderText = "Single letter",
        CurrentValue = getgenv().Keybinds.ExtraJumps,
        Callback = function(v)
            if #v == 1 then getgenv().Keybinds.ExtraJumps = v:upper() saveScriptState(getgenv().Values) end
        end
    })
    
    local aimSection = mainTab:CreateSection("AIMBOT")
    
    local aimbotToggle = mainTab:CreateToggle({
        Name = "⚽ AIMBOT ["..getgenv().Keybinds.Aimbot.."]",
        CurrentValue = getgenv().Toggles.Aimbot,
        Flag = "AimbotToggle",
        Callback = function(Value)
            getgenv().Toggles.Aimbot = Value
            Rayfield:Notify({Title = "AIMBOT", Content = Value and "ACTIVE ⚡" or "OFF ❌", Duration = 1})
            saveScriptState(getgenv().Values)
        end
    })
    
    local powershotToggle = mainTab:CreateToggle({
        Name = "💥 POWERSHOT ["..getgenv().Keybinds.Powershot.."]",
        CurrentValue = getgenv().Toggles.Powershot,
        Flag = "PowershotToggle",
        Callback = function(Value)
            getgenv().Toggles.Powershot = Value
            Rayfield:Notify({Title = "POWERSHOT", Content = Value and "MAX POWER 💥" or "OFF ❌", Duration = 1})
            saveScriptState(getgenv().Values)
        end
    })
    
    -- TEXT BOX for shot power (range 1-5000)
    local powerInput = mainTab:CreateInput({
        Name = "💪 SHOT POWER (1-5000)",
        PlaceholderText = "Enter power",
        CurrentValue = tostring(getgenv().Values.ShotPowerVal),
        Flag = "ShotPower",
        Callback = function(Value)
            local num = tonumber(Value)
            if num and num >= 1 and num <= 5000 then
                getgenv().Values.ShotPowerVal = num
                saveScriptState(getgenv().Values)
                Rayfield:Notify({Title = "SHOT POWER", Content = "Set to "..num, Duration = 1})
            else
                Rayfield:Notify({Title = "INVALID", Content = "Use 1-5000", Duration = 1})
            end
        end
    })
    
    -- NEW: Goal Selection Buttons (Orange highlight)
    local goalSection = mainTab:CreateSection("🎯 TARGET GOAL")
    local opponentBtn = mainTab:CreateButton({
        Name = "🎯 OPPONENT GOAL",
        Callback = function()
            getgenv().Values.TargetGoal = "Opponent"
            saveScriptState(getgenv().Values)
            opponentBtn:SetBackgroundColor(Color3.fromRGB(255, 85, 0))
            myGoalBtn:SetBackgroundColor(Color3.fromRGB(40, 40, 50))
            Rayfield:Notify({Title = "GOAL", Content = "Now targeting opponent goal"})
        end
    })
    opponentBtn:SetBackgroundColor(Color3.fromRGB(255, 85, 0))
    local myGoalBtn = mainTab:CreateButton({
        Name = "🏠 MY GOAL",
        Callback = function()
            getgenv().Values.TargetGoal = "My"
            saveScriptState(getgenv().Values)
            myGoalBtn:SetBackgroundColor(Color3.fromRGB(255, 85, 0))
            opponentBtn:SetBackgroundColor(Color3.fromRGB(40, 40, 50))
            Rayfield:Notify({Title = "GOAL", Content = "Now targeting your own goal"})
        end
    })
    myGoalBtn:SetBackgroundColor(Color3.fromRGB(40, 40, 50))
    if getgenv().Values.TargetGoal == "My" then
        myGoalBtn:SetBackgroundColor(Color3.fromRGB(255, 85, 0))
        opponentBtn:SetBackgroundColor(Color3.fromRGB(40, 40, 50))
    end
    
    local ballSection = mainTab:CreateSection("BALL CONTROL")
    
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
            wait(1)
            updateStatusLabel()
        end
    end)
    
    -- // TAB 2: POWER UPS
    local powerTab = Window:CreateTab("⚡ POWER UPS", nil)
    
    local creditLabel = powerTab:CreateLabel("🔥 MADE BY [ITS_BLAZE7] 🔥")
    
    local flySection = powerTab:CreateSection("FLIGHT")
    
    local flyToggle = powerTab:CreateToggle({
        Name = "✈️ CFrame FLY ["..getgenv().Keybinds.Fly.."]",
        CurrentValue = false,
        Flag = "FlyToggle",
        Callback = function(Value)
            if Value then
                startFly()
            else
                stopFly()
            end
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
            saveScriptState(getgenv().Values)
        end
    })
    
    local speedSection = powerTab:CreateSection("MOVEMENT")
    
    local walkspeedToggle = powerTab:CreateToggle({
        Name = "🏃 WALKSPEED HACK",
        CurrentValue = getgenv().Toggles.WalkSpeed,
        Flag = "WalkSpeedToggle",
        Callback = function(Value)
            getgenv().Toggles.WalkSpeed = Value
            if Value then
                local char = Player.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.WalkSpeed = getgenv().Values.WalkSpeedVal
                end
            else
                local char = Player.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.WalkSpeed = 16
                end
            end
            Rayfield:Notify({Title = "WALKSPEED", Content = Value and "ENABLED 🏃" or "DISABLED ❌", Duration = 1})
            saveScriptState(getgenv().Values)
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
            if getgenv().Toggles.WalkSpeed then
                local char = Player.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.WalkSpeed = Value
                end
            end
            saveScriptState(getgenv().Values)
        end
    })
    
    local jumpSection = powerTab:CreateSection("JUMP")
    
    -- NEW: Jump toggle so jump height doesn't auto-apply
    local jumpToggle = powerTab:CreateToggle({
        Name = "🦘 CUSTOM JUMP HEIGHT",
        CurrentValue = getgenv().Toggles.JumpPower,
        Flag = "JumpToggle",
        Callback = function(Value)
            getgenv().Toggles.JumpPower = Value
            if not Value then
                local char = Player.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.JumpPower = 50
                end
            end
            Rayfield:Notify({Title = "JUMP HEIGHT", Content = Value and "CUSTOM ENABLED" or "DISABLED (default 50)", Duration = 1})
            saveScriptState(getgenv().Values)
        end
    })
    
    local jumpHeightSlider = powerTab:CreateSlider({
        Name = "🦘 JUMP HEIGHT VALUE",
        Range = {30, 500},
        Increment = 10,
        Suffix = "Power",
        CurrentValue = getgenv().Values.JumpHeightVal,
        Flag = "JumpHeight",
        Callback = function(Value)
            getgenv().Values.JumpHeightVal = Value
            if getgenv().Toggles.JumpPower then
                local char = Player.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.JumpPower = Value
                end
            end
            saveScriptState(getgenv().Values)
        end
    })
    
    local extraJumpsSlider = powerTab:CreateSlider({
        Name = "✨ EXTRA JUMPS POWER ["..getgenv().Keybinds.ExtraJumps.."]",
        Range = {0, 50},
        Increment = 1,
        Suffix = "Extra Jumps",
        CurrentValue = getgenv().Values.ExtraJumpsVal,
        Flag = "ExtraJumps",
        Callback = function(Value)
            getgenv().Values.ExtraJumpsVal = Value
            saveScriptState(getgenv().Values)
        end
    })
    
    local noClipToggle = powerTab:CreateToggle({
        Name = "🔓 NO CLIP ["..getgenv().Keybinds.NoClip.."]",
        CurrentValue = getgenv().Toggles.NoClip,
        Flag = "NoClipToggle",
        Callback = function(Value)
            getgenv().Toggles.NoClip = Value
            setNoClip(Value)
            Rayfield:Notify({Title = "NOCLIP", Content = Value and "ACTIVE 🔓" or "OFF 🔒", Duration = 1})
            saveScriptState(getgenv().Values)
        end
    })
    
    -- NEW: Support button
    local supportSection = powerTab:CreateSection("🆘 SUPPORT")
    local supportBtn = powerTab:CreateButton({
        Name = "📋 JOIN DISCORD FOR HELP",
        Callback = function()
            setclipboard("https://discord.gg/nJ6P8VVSCm")
            Rayfield:Notify({Title = "DISCORD LINK", Content = "Copied to clipboard!", Duration = 2})
        end
    })
    supportBtn:SetBackgroundColor(Color3.fromRGB(255, 85, 0))
    
    -- // KEYBINDS (using dynamic keybinds)
    UIS.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        local key = input.KeyCode.Name
        
        if key == getgenv().Keybinds.Aimbot then
            aimbotToggle:Set(not aimbotToggle.CurrentValue)
        elseif key == getgenv().Keybinds.Powershot then
            powershotToggle:Set(not powershotToggle.CurrentValue)
        elseif key == getgenv().Keybinds.NoClip then
            noClipToggle:Set(not noClipToggle.CurrentValue)
        elseif key == getgenv().Keybinds.Fly then
            flyToggle:Set(not flyToggle.CurrentValue)
        elseif key == getgenv().Keybinds.ExtraJumps then
            local char = Player.Character
            if char and char:FindFirstChild("Humanoid") then
                for i = 1, getgenv().Values.ExtraJumpsVal do
                    wait(0.1)
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
    
    -- // OPTIMIZED LOOP: Heartbeat + throttled ball detection (fixes lag)
    RS.Heartbeat:Connect(function(deltaTime)
        local char = Player.Character
        if not char then return end
        
        -- WalkSpeed (only if toggled)
        if getgenv().Toggles.WalkSpeed then
            local hum = char:FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = getgenv().Values.WalkSpeedVal end
        end
        
        -- JumpPower (only if toggled)
        if getgenv().Toggles.JumpPower then
            local hum = char:FindFirstChild("Humanoid")
            if hum then hum.JumpPower = getgenv().Values.JumpHeightVal end
        end
        
        -- Aimbot detection (throttled to 10x per second)
        lastBallCheck = lastBallCheck + deltaTime
        if lastBallCheck > 0.1 then
            lastBallCheck = 0
            if getgenv().Toggles.Aimbot then
                local ball = findSoccerBall()
                if ball then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp and (hrp.Position - ball.Position).magnitude < 8 then
                        aimbotShoot(ball)
                    end
                end
            end
        end
    end)
    
    -- // NOTIFY HOTKEYS
    local hotkeyMsg = "["..getgenv().Keybinds.NoClip.."] NoClip | ["..getgenv().Keybinds.ExtraJumps.."] ExtraJumps | ["..getgenv().Keybinds.TeleportBall.."] Teleport | ["..getgenv().Keybinds.BringBall.."] Bring | ["..getgenv().Keybinds.Aimbot.."] Aimbot | ["..getgenv().Keybinds.Powershot.."] Powershot | ["..getgenv().Keybinds.Fly.."] Fly"
    Rayfield:Notify({Title = "⚡ FFL TFB ALPHA UNLOCKED ⚡", Content = hotkeyMsg, Duration = 8})
end

-- // AUTO-REEXECUTE ON TELEPORT (replace URL with your raw link)
local function autoReexecute()
    local player = game.Players.LocalPlayer
    if player then
        player.OnTeleport:Connect(function()
            wait(2)
            script:Destroy()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/itsblaze7/FireFlasklab-tfb-alpha/refs/heads/main/FFL_TFB_ALPHA.lua"))()
        end)
    end
end
autoReexecute()

-- // START PASSWORD UI
showPasswordUI()
