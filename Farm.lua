local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

local AnimationID = 15660817775
local loopConnection
local animConnection
local iframeConnection
local noclipConnection
local debugConnection
local enabled = false
local iframeEnabled = false
local noclipEnabled = false
local debugEnabled = false
local selectedTarget = "Devotion_M"
local animationMode = "Todo v1"
local customAnimID = ""

local Window = Library:CreateWindow({
    Title = "Kill Farming UI",
    Footer = "Devotion_M on discord",
    Icon = 95816097006870,
    NotifySide = "Right",
    ShowCustomCursor = false,
})

local Tabs = {
    Main = Window:AddTab("Main", "zap"),
    FPS = Window:AddTab("FPS", "gauge"),
    Settings = Window:AddTab("Settings", "settings"),
}

local TargetGroupBox = Tabs.Main:AddLeftGroupbox("Target Configuration", "target")

TargetGroupBox:AddDropdown("TargetPlayer", {
    Values = {"Devotion_M", "azrisKitten", "neden_arkadasimyok"},
    Default = 1,
    Multi = false,
    Text = "Target Player",
    Callback = function(Value)
        selectedTarget = Value
    end,
})

TargetGroupBox:AddDropdown("AnimationMode", {
    Values = {"Todo v1", "Dabi v1", "Custom"},
    Default = 1,
    Multi = false,
    Text = "Animation Mode",
    Callback = function(Value)
        animationMode = Value
        if Value == "Todo v1" then
            AnimationID = 15660817775
        elseif Value == "Dabi v1" then
            AnimationID = 14911560173
        elseif Value == "Custom" then
            if customAnimID ~= "" then
                AnimationID = tonumber(customAnimID) or 15660817775
            end
        end
    end,
})

TargetGroupBox:AddInput("CustomAnimationID", {
    Default = "",
    Numeric = true,
    Finished = false,
    Text = "Custom Animation ID",
    Placeholder = "Enter Animation ID",
    Callback = function(Value)
        customAnimID = Value
        if animationMode == "Custom" and Value ~= "" then
            AnimationID = tonumber(Value) or AnimationID
        end
    end,
})

local FarmGroupBox = Tabs.Main:AddRightGroupbox("Farming Controls", "play")

local KillFarmToggle = FarmGroupBox:AddToggle("KillFarm", {
    Text = "Kill Farm",
    Default = false,
    Callback = function(Value)
        enabled = Value
        if enabled then
            loopConnection = RunService.Heartbeat:Connect(function()
                local targetPlayer = getTargetPlayer()
                if targetPlayer and targetPlayer.Character then
                    local targetRoot = getRoot(targetPlayer.Character)
                    local myRoot = getRoot(LocalPlayer.Character)
                    
                    if targetRoot and myRoot then
                        local offset = targetRoot.CFrame.LookVector * 5
                        myRoot.CFrame = targetRoot.CFrame + offset
                    end
                end
            end)
            
            checkAnimation()
        else
            if loopConnection then
                loopConnection:Disconnect()
            end
        end
    end,
})

KillFarmToggle:AddKeyPicker("KillFarmKeybind", {
    Text = "Kill Farm",
    Mode = "Toggle",
    Callback = function()
        KillFarmToggle:SetValue(not Toggles.KillFarm.Value)
    end,
})

local IframeToggle = FarmGroupBox:AddToggle("Iframe", {
    Text = "Iframe",
    Default = false,
    Callback = function(Value)
        iframeEnabled = Value
        if iframeEnabled then
            iframeConnection = RunService.Heartbeat:Connect(function()
                local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                local humanoid = character:WaitForChild("Humanoid")
                
                humanoid:Move(Vector3.new(0, 0, -0.01), true)
                task.wait(0.05)
                humanoid:Move(Vector3.zero, true)
                task.wait(0.1)
            end)
        else
            if iframeConnection then
                iframeConnection:Disconnect()
            end
        end
    end,
})

IframeToggle:AddKeyPicker("IframeKeybind", {
    Text = "Iframe",
    Mode = "Toggle",
    Callback = function()
        IframeToggle:SetValue(not Toggles.Iframe.Value)
    end,
})

local NoclipToggle = FarmGroupBox:AddToggle("Noclip", {
    Text = "Noclip",
    Default = false,
    Callback = function(Value)
        noclipEnabled = Value
        if noclipEnabled then
            noclipConnection = RunService.Stepped:Connect(function()
                if LocalPlayer.Character then
                    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
            end
            if LocalPlayer.Character then
                local torso = LocalPlayer.Character:FindFirstChild("Torso") or LocalPlayer.Character:FindFirstChild("UpperTorso")
                if torso then
                    torso.CanCollide = true
                end
            end
        end
    end,
})

NoclipToggle:AddKeyPicker("NoclipKeybind", {
    Text = "Noclip",
    Mode = "Toggle",
    Callback = function()
        NoclipToggle:SetValue(not Toggles.Noclip.Value)
    end,
})

local DebugToggle = FarmGroupBox:AddToggle("Debug", {
    Text = "Debug",
    Default = false,
    Callback = function(Value)
        debugEnabled = Value
        if debugEnabled then
            debugConnection = RunService.Heartbeat:Connect(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.Health = 0
                end
            end)
        else
            if debugConnection then
                debugConnection:Disconnect()
                debugConnection = nil
            end
        end
    end,
})

DebugToggle:AddKeyPicker("DebugKeybind", {
    Text = "Debug",
    Mode = "Toggle",
    Callback = function()
        DebugToggle:SetValue(not Toggles.Debug.Value)
    end,
})

FarmGroupBox:AddButton({
    Text = "Anim Logger",
    Func = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/MicIsPro/ArchivedPrivate/refs/heads/main/animlogger.lua"))()
    end,
    Tooltip = "Opens animation logger",
})

local TeleportGroupBox = Tabs.Main:AddLeftGroupbox("Teleport Tools", "map-pin")

TeleportGroupBox:AddButton({
    Text = "Setup",
    Func = function()
        task.spawn(function()
            local targetPlayer = getTargetPlayer()
            if not targetPlayer or not targetPlayer.Character then
                Library:Notify({
                    Title = "Error",
                    Description = "Target player not found",
                    Time = 2,
                })
                return
            end
            
            local targetRoot = getRoot(targetPlayer.Character)
            local myRoot = getRoot(LocalPlayer.Character)
            
            if not targetRoot or not myRoot then return end
            
            local backAttachConnection = RunService.Heartbeat:Connect(function()
                local tRoot = getRoot(targetPlayer.Character)
                local mRoot = getRoot(LocalPlayer.Character)
                
                if tRoot and mRoot then
                    local offset = tRoot.CFrame.LookVector * -3
                    mRoot.CFrame = CFrame.new(tRoot.Position + offset, tRoot.Position)
                end
            end)
            
            task.wait(0.2)
            
            local vim = game:GetService("VirtualInputManager")
            vim:SendKeyEvent(true, Enum.KeyCode.One, false, game)
            vim:SendKeyEvent(false, Enum.KeyCode.One, false, game)
            
            task.wait(0.7)
            
            backAttachConnection:Disconnect()
            
            local myRootFinal = getRoot(LocalPlayer.Character)
            if myRootFinal then
                local teleportPosition = Vector3.new(-73, 86, 941)
                myRootFinal.CFrame = CFrame.new(teleportPosition)
            end
            
            Library:Notify({
                Title = "Setup Complete",
                Description = "Sequence finished",
                Time = 2,
            })
        end)
    end,
    Tooltip = "Setup sequence: Back attach to target, press 1, return",
})

TeleportGroupBox:AddButton({
    Text = "Setup 1",
    Func = function()
        task.spawn(function()
            local targetPlayer = nil
            for _, player in pairs(Players:GetPlayers()) do
                if player.Name == "j07_01" then
                    targetPlayer = player
                    break
                end
            end
            
            if not targetPlayer or not targetPlayer.Character then
                Library:Notify({
                    Title = "Error",
                    Description = "j07_01 not found",
                    Time = 2,
                })
                return
            end
            
            local targetRoot = getRoot(targetPlayer.Character)
            local myRoot = getRoot(LocalPlayer.Character)
            
            if not targetRoot or not myRoot then return end
            
            local backAttachConnection = RunService.Heartbeat:Connect(function()
                local tRoot = getRoot(targetPlayer.Character)
                local mRoot = getRoot(LocalPlayer.Character)
                
                if tRoot and mRoot then
                    local offset = tRoot.CFrame.LookVector * -3
                    mRoot.CFrame = CFrame.new(tRoot.Position + offset, tRoot.Position)
                end
            end)
            
            task.wait(0.2)
            
            local vim = game:GetService("VirtualInputManager")
            vim:SendKeyEvent(true, Enum.KeyCode.One, false, game)
            vim:SendKeyEvent(false, Enum.KeyCode.One, false, game)
            
            task.wait(0.7)
            
            backAttachConnection:Disconnect()
            
            local myRootFinal = getRoot(LocalPlayer.Character)
            if myRootFinal then
                local teleportPosition = Vector3.new(-73, 86, 941)
                myRootFinal.CFrame = CFrame.new(teleportPosition)
            end
            
            Library:Notify({
                Title = "Setup 1 Complete",
                Description = "Sequence finished for j07_01",
                Time = 2,
            })
        end)
    end,
    Tooltip = "Setup sequence for j07_01 only",
})

TeleportGroupBox:AddButton({
    Text = "TP to Plate",
    Func = function()
        local myRoot = getRoot(LocalPlayer.Character)
        if myRoot then
            local platePosition = Vector3.new(-73, 86, 941)
            myRoot.CFrame = CFrame.new(platePosition)
            Library:Notify({
                Title = "Teleported",
                Description = "Teleported to plate",
                Time = 2,
            })
        end
    end,
    Tooltip = "Teleport to plate position",
})

TeleportGroupBox:AddButton({
    Text = "Create TP Tool",
    Func = function()
        createTeleportTool()
        Library:Notify({
            Title = "TP Tool Created",
            Description = "WayPoint Tool added to backpack",
            Time = 2,
        })
    end,
    Tooltip = "Creates a teleport tool in your backpack",
})

TeleportGroupBox:AddButton({
    Text = "TP to Target Player",
    Func = function()
        local targetPlayer = getTargetPlayer()
        if targetPlayer and targetPlayer.Character then
            local targetRoot = getRoot(targetPlayer.Character)
            local myRoot = getRoot(LocalPlayer.Character)
            
            if targetRoot and myRoot then
                myRoot.CFrame = targetRoot.CFrame
                Library:Notify({
                    Title = "Teleported",
                    Description = "Teleported to " .. targetPlayer.Name,
                    Time = 2,
                })
            end
        else
            Library:Notify({
                Title = "Error",
                Description = "Target player not found",
                Time = 2,
            })
        end
    end,
    Tooltip = "Teleport to the selected target player",
})

local StatusGroupBox = Tabs.Main:AddRightGroupbox("Status", "users")

StatusGroupBox:AddButton({
    Text = "ALT Status",
    Func = function()
        local UserInputService = game:GetService("UserInputService")

        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "AccountStatusGUI"
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ScreenGui.ResetOnSpawn = false
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

        local MainFrame = Instance.new("Frame")
        MainFrame.Size = UDim2.new(0, 420, 0, 600)
        MainFrame.Position = UDim2.new(0.5, -210, 0.5, -300)
        MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        MainFrame.BorderSizePixel = 0
        MainFrame.Parent = ScreenGui

        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 8)
        UICorner.Parent = MainFrame

        local UIStroke = Instance.new("UIStroke")
        UIStroke.Color = Color3.fromRGB(39, 39, 42)
        UIStroke.Thickness = 1
        UIStroke.Parent = MainFrame

        local TopBar = Instance.new("Frame")
        TopBar.Size = UDim2.new(1, 0, 0, 40)
        TopBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        TopBar.BorderSizePixel = 0
        TopBar.Parent = MainFrame

        local TopBarCorner = Instance.new("UICorner")
        TopBarCorner.CornerRadius = UDim.new(0, 8)
        TopBarCorner.Parent = TopBar

        local TopBarBorder = Instance.new("Frame")
        TopBarBorder.Size = UDim2.new(1, 0, 0, 1)
        TopBarBorder.Position = UDim2.new(0, 0, 1, 0)
        TopBarBorder.BackgroundColor3 = Color3.fromRGB(39, 39, 42)
        TopBarBorder.BorderSizePixel = 0
        TopBarBorder.Parent = TopBar

        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, -50, 1, 0)
        Title.Position = UDim2.new(0, 15, 0, 0)
        Title.BackgroundTransparency = 1
        Title.Text = "Account Status"
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.TextSize = 14
        Title.Font = Enum.Font.GothamBold
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Parent = TopBar

        local CloseButton = Instance.new("TextButton")
        CloseButton.Size = UDim2.new(0, 30, 0, 30)
        CloseButton.Position = UDim2.new(1, -35, 0.5, -15)
        CloseButton.BackgroundTransparency = 1
        CloseButton.Text = "×"
        CloseButton.TextColor3 = Color3.fromRGB(161, 161, 170)
        CloseButton.TextSize = 24
        CloseButton.Font = Enum.Font.GothamBold
        CloseButton.Parent = TopBar

        CloseButton.MouseButton1Click:Connect(function()
            ScreenGui:Destroy()
        end)

        CloseButton.MouseEnter:Connect(function()
            CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)

        CloseButton.MouseLeave:Connect(function()
            CloseButton.TextColor3 = Color3.fromRGB(161, 161, 170)
        end)

        local ScrollFrame = Instance.new("ScrollingFrame")
        ScrollFrame.Size = UDim2.new(1, -20, 1, -50)
        ScrollFrame.Position = UDim2.new(0, 10, 0, 45)
        ScrollFrame.BackgroundTransparency = 1
        ScrollFrame.BorderSizePixel = 0
        ScrollFrame.ScrollBarThickness = 4
        ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(39, 39, 42)
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        ScrollFrame.Parent = MainFrame

        local UIListLayout = Instance.new("UIListLayout")
        UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout.Padding = UDim.new(0, 0)
        UIListLayout.Parent = ScrollFrame

        local accounts = {"Devotion_M", "Neden_arkadasimyok", "j07_01"}
        for i = 2, 14 do
            table.insert(accounts, "07_01j" .. i)
        end

        local accountFrames = {}

        local function updateStatuses()
            for accountName, elements in pairs(accountFrames) do
                local isInServer = false
                for _, player in ipairs(Players:GetPlayers()) do
                    if player.Name == accountName then
                        isInServer = true
                        break
                    end
                end
                
                if isInServer then
                    elements.StatusLabel.Text = "✓ In Server"
                    elements.StatusLabel.TextColor3 = Color3.fromRGB(34, 197, 94)
                else
                    elements.StatusLabel.Text = "✗ Not Here"
                    elements.StatusLabel.TextColor3 = Color3.fromRGB(239, 68, 68)
                end
            end
        end

        for index, accountName in ipairs(accounts) do
            local isInServer = false
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Name == accountName then
                    isInServer = true
                    break
                end
            end
            
            local AccountFrame = Instance.new("Frame")
            AccountFrame.Size = UDim2.new(1, 0, 0, 35)
            AccountFrame.BackgroundTransparency = 1
            AccountFrame.LayoutOrder = index
            AccountFrame.Parent = ScrollFrame
            
            local AccountName = Instance.new("TextLabel")
            AccountName.Size = UDim2.new(0.5, 0, 1, 0)
            AccountName.Position = UDim2.new(0, 0, 0, 0)
            AccountName.BackgroundTransparency = 1
            AccountName.Text = accountName
            AccountName.TextColor3 = Color3.fromRGB(212, 212, 216)
            AccountName.TextSize = 13
            AccountName.Font = Enum.Font.Gotham
            AccountName.TextXAlignment = Enum.TextXAlignment.Left
            AccountName.Parent = AccountFrame
            
            local StatusLabel = Instance.new("TextLabel")
            StatusLabel.Size = UDim2.new(0.5, -10, 1, 0)
            StatusLabel.Position = UDim2.new(0.5, 0, 0, 0)
            StatusLabel.BackgroundTransparency = 1
            StatusLabel.TextSize = 12
            StatusLabel.Font = Enum.Font.GothamBold
            StatusLabel.TextXAlignment = Enum.TextXAlignment.Right
            StatusLabel.Parent = AccountFrame
            
            if isInServer then
                StatusLabel.Text = "✓ In Server"
                StatusLabel.TextColor3 = Color3.fromRGB(34, 197, 94)
            else
                StatusLabel.Text = "✗ Not Here"
                StatusLabel.TextColor3 = Color3.fromRGB(239, 68, 68)
            end
            
            local Divider = Instance.new("Frame")
            Divider.Size = UDim2.new(1, 0, 0, 1)
            Divider.Position = UDim2.new(0, 0, 1, 0)
            Divider.BackgroundColor3 = Color3.fromRGB(24, 24, 27)
            Divider.BorderSizePixel = 0
            Divider.Parent = AccountFrame
            
            accountFrames[accountName] = {
                StatusLabel = StatusLabel
            }
        end

        Players.PlayerAdded:Connect(function(player)
            updateStatuses()
        end)

        Players.PlayerRemoving:Connect(function(player)
            updateStatuses()
        end)

        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)

        local dragging = false
        local dragInput
        local dragStart
        local startPos

        local function update(input)
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end

        TopBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = MainFrame.Position
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)

        TopBar.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                update(input)
            end
        end)
        
        Library:Notify({
            Title = "ALT Status",
            Description = "Account status GUI opened",
            Time = 2,
        })
    end,
    Tooltip = "Opens account status tracker",
})

local WorldGroupBox = Tabs.FPS:AddLeftGroupbox("World Modifications", "trash-2")

WorldGroupBox:AddButton({
    Text = "Delete Invis Walls",
    Func = function()
        local tempCollision = workspace:FindFirstChild("TempCollision")
        if tempCollision then
            tempCollision:Destroy()
            Library:Notify({
                Title = "Success",
                Description = "Invisible walls deleted",
                Time = 2,
            })
        else
            Library:Notify({
                Title = "Not Found",
                Description = "TempCollision not found",
                Time = 2,
            })
        end
    end,
    Tooltip = "Deletes workspace.TempCollision",
})

WorldGroupBox:AddButton({
    Text = "Anti Lag",
    Func = function()
        local map = workspace:FindFirstChild("Map")
        if map then
            local destroyableParts = map:FindFirstChild("DestroyableParts")
            local bar = map:FindFirstChild("BAR")
            
            if destroyableParts then
                destroyableParts:Destroy()
            end
            
            if bar then
                bar:Destroy()
            end
            
            Library:Notify({
                Title = "Success",
                Description = "Anti lag applied",
                Time = 2,
            })
        else
            Library:Notify({
                Title = "Error",
                Description = "Map not found",
                Time = 2,
            })
        end
    end,
    Tooltip = "Deletes DestroyableParts and BAR",
})

WorldGroupBox:AddButton({
    Text = "Potato Mode",
    Func = function()
        local effects = workspace:FindFirstChild("Effects")
        if effects then
            for _, child in pairs(effects:GetChildren()) do
                if child.Name ~= "PreloadingAnimsDontDeleteTHREE" and child.Name ~= "PreloadingAnimsDontDeleteTWO" then
                    child:Destroy()
                end
            end
        end
        
        local tempCollision = workspace:FindFirstChild("TempCollision")
        if tempCollision then
            tempCollision:Destroy()
        end
        
        Library:Notify({
            Title = "Success",
            Description = "Potato mode applied",
            Time = 2,
        })
    end,
    Tooltip = "Deletes Effects (except preloading) and TempCollision",
})

WorldGroupBox:AddButton({
    Text = "Delete Map (Not Full)",
    Func = function()
        local map = workspace:FindFirstChild("Map")
        if map then
            for _, child in pairs(map:GetChildren()) do
                if child.Name:lower() ~= "baseplate" then
                    child:Destroy()
                end
            end
            Library:Notify({
                Title = "Success",
                Description = "Map deleted (Baseplate kept)",
                Time = 2,
            })
        else
            Library:Notify({
                Title = "Error",
                Description = "Map not found",
                Time = 2,
            })
        end
    end,
    Tooltip = "Deletes map except baseplate",
})

WorldGroupBox:AddButton({
    Text = "Delete FULL Map",
    Func = function()
        local map = workspace:FindFirstChild("Map")
        if map then
            map:Destroy()
            Library:Notify({
                Title = "Success",
                Description = "Full map deleted",
                Time = 2,
            })
        else
            Library:Notify({
                Title = "Error",
                Description = "Map not found",
                Time = 2,
            })
        end
    end,
    Tooltip = "Deletes entire workspace.Map",
})

local MiscGroupBox = Tabs.FPS:AddRightGroupbox("Miscellaneous", "box")

MiscGroupBox:AddButton({
    Text = "Bring LB",
    Func = function()
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        local monthlyFrame = workspace:FindFirstChild("MonthlyLeaderboard")
        
        if monthlyFrame then
            monthlyFrame.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 5, 0)
            Library:Notify({
                Title = "Success",
                Description = "Leaderboard brought to you",
                Time = 2,
            })
        else
            Library:Notify({
                Title = "Error",
                Description = "MonthlyLeaderboard not found",
                Time = 2,
            })
        end
    end,
    Tooltip = "Brings MonthlyLeaderboard to your position",
})

local InfoGroupBox = Tabs.Settings:AddLeftGroupbox("Information", "info")

InfoGroupBox:AddLabel("Created by: Devotion_M")
InfoGroupBox:AddLabel("Version: 1.1")
InfoGroupBox:AddDivider()
InfoGroupBox:AddLabel("Discord: Devotion_M")

local MenuGroup = Tabs.Settings:AddRightGroupbox("Menu", "settings")

MenuGroup:AddDropdown("NotificationSide", {
    Values = { "Left", "Right" },
    Default = 2,
    Multi = false,
    Text = "Notification Side",
    Callback = function(Value)
        Library:SetNotifySide(Value)
    end,
})

MenuGroup:AddDivider()

MenuGroup:AddLabel("Menu Keybind"):AddKeyPicker("MenuKeybind", { 
    Default = "N", 
    NoUI = true, 
    Text = "Menu keybind" 
})

MenuGroup:AddButton({
    Text = "Unload",
    Func = function()
        Library:Unload()
    end,
})

function getRoot(char)
    return char:FindFirstChild('HumanoidRootPart') or char:FindFirstChild('Torso') or char:FindFirstChild('UpperTorso')
end

function getTargetPlayer()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name:lower():find(selectedTarget:lower()) or player.DisplayName:lower():find(selectedTarget:lower()) then
            return player
        end
    end
    return nil
end

function checkAnimation()
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if animConnection then animConnection:Disconnect() end
            animConnection = humanoid.AnimationPlayed:Connect(function(animationTrack)
                if enabled and string.find(animationTrack.Animation.AnimationId, tostring(AnimationID)) then
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                        LocalPlayer.Character.Humanoid.Health = 0
                    end
                end
            end)
        end
    end
end

function createTeleportTool()
    local backpack = LocalPlayer:WaitForChild("Backpack")
    local teleportPosition = Vector3.new(-73, 86, 941)
    
    local tool = Instance.new("Tool")
    tool.Name = "WayPoint Tool"
    tool.RequiresHandle = false

    tool.Equipped:Connect(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(teleportPosition)
        end
    end)

    tool.Parent = backpack
end

LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    if enabled then
        checkAnimation()
    end
end)

Library:OnUnload(function()
    if loopConnection then
        loopConnection:Disconnect()
    end
    if animConnection then
        animConnection:Disconnect()
    end
    if iframeConnection then
        iframeConnection:Disconnect()
    end
    if noclipConnection then
        noclipConnection:Disconnect()
    end
    if debugConnection then
        debugConnection:Disconnect()
    end
end)

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

ThemeManager:SetFolder("KillFarmUI")
SaveManager:SetFolder("KillFarmUI/configs")
