
---

### 2. `Aimbot_ESP.lua` File

This is the actual script. Create a file named `Aimbot_ESP.lua` in the same directory and paste the code below into it. This is the same script from the previous answer, formatted for a single file.

```lua
-- =============================================
-- ==           BASIC AIMBOT & ESP           ==
-- ==      Educational Purposes Only        ==
-- =============================================

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local GuiService = game:GetService("GuiService")

-- Player
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- == CUSTOMIZABLE SETTINGS ==
local AimbotEnabled = false
local ESPEnabled = false
local TeamCheck = true -- Set to false to target everyone
local AimPart = "Head" -- "Head" or "HumanoidRootPart"
local AimbotKey = Enum.KeyCode.Q -- Key to hold for aimbot
-- ============================

-- ESP Table to store drawing objects
local ESP = {}

-- GUI Elements
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleBar = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local AimbotToggle = Instance.new("TextButton")
local ESPToggle = Instance.new("TextButton")
local TeamCheckToggle = Instance.new("TextButton")

-- Function to create the GUI
local function createGUI()
    -- Protect GUI from being reset
    if syn then
        syn.protect_gui(ScreenGui)
    end
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Main Frame
    MainFrame.Parent = ScreenGui
    MainFrame.Active = true
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0, 100, 0, 100)
    MainFrame.Size = UDim2.new(0, 200, 0, 150)

    -- Title Bar
    TitleBar.Parent = MainFrame
    TitleBar.Active = true
    TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TitleBar.BorderSizePixel = 0
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    
    -- Title Label
    TitleLabel.Parent = TitleBar
    TitleLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.BackgroundTransparency = 1.000
    TitleLabel.Size = UDim2.new(1, 0, 1, 0)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = "Cheat Hub"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 14.000

    -- Aimbot Toggle Button
    AimbotToggle.Parent = MainFrame
    AimbotToggle.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    AimbotToggle.BorderSizePixel = 0
    AimbotToggle.Position = UDim2.new(0, 10, 0, 40)
    AimbotToggle.Size = UDim2.new(0, 180, 0, 30)
    AimbotToggle.Font = Enum.Font.Gotham
    AimbotToggle.Text = "Aimbot: OFF"
    AimbotToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    AimbotToggle.TextSize = 14.000

    -- ESP Toggle Button
    ESPToggle.Parent = MainFrame
    ESPToggle.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    ESPToggle.BorderSizePixel = 0
    ESPToggle.Position = UDim2.new(0, 10, 0, 80)
    ESPToggle.Size = UDim2.new(0, 180, 0, 30)
    ESPToggle.Font = Enum.Font.Gotham
    ESPToggle.Text = "ESP: OFF"
    ESPToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    ESPToggle.TextSize = 14.000
    
    -- Team Check Toggle Button
    TeamCheckToggle.Parent = MainFrame
    TeamCheckToggle.BackgroundColor3 = Color3.fromRGB(50, 255, 50) -- Starts ON
    TeamCheckToggle.BorderSizePixel = 0
    TeamCheckToggle.Position = UDim2.new(0, 10, 0, 120)
    TeamCheckToggle.Size = UDim2.new(0, 180, 0, 30)
    TeamCheckToggle.Font = Enum.Font.Gotham
    TeamCheckToggle.Text = "Team Check: ON"
    TeamCheckToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    TeamCheckToggle.TextSize = 14.000

    -- Button Functions
    AimbotToggle.MouseButton1Click:Connect(function()
        AimbotEnabled = not AimbotEnabled
        AimbotToggle.Text = "Aimbot: " .. (AimbotEnabled and "ON" or "OFF")
        AimbotToggle.BackgroundColor3 = AimbotEnabled and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
    end)

    ESPToggle.MouseButton1Click:Connect(function()
        ESPEnabled = not ESPEnabled
        ESPToggle.Text = "ESP: " .. (ESPEnabled and "ON" or "OFF")
        ESPToggle.BackgroundColor3 = ESPEnabled and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
        -- Toggle visibility of all ESP objects
        for _, v in pairs(ESP) do
            if v.Box then v.Box.Visible = ESPEnabled end
            if v.NameText then v.NameText.Visible = ESPEnabled end
        end
    end)
    
    TeamCheckToggle.MouseButton1Click:Connect(function()
        TeamCheck = not TeamCheck
        TeamCheckToggle.Text = "Team Check: " .. (TeamCheck and "ON" or "OFF")
        TeamCheckToggle.BackgroundColor3 = TeamCheck and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
    end)

    -- Dragging GUI
    local dragging = false
    local dragStart = nil
    local startPos = nil

    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Function to get the closest player to the mouse/cursor
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChildOfClass("Humanoid") and player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
            if not TeamCheck or player.Team ~= LocalPlayer.Team then
                local character = player.Character
                local targetPart = character:FindFirstChild(AimPart)
                if targetPart then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local mousePos = UserInputService:GetMouseLocation()
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            closestPlayer = player
                        end
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- Aimbot Loop
RunService.Heartbeat:Connect(function()
    if AimbotEnabled and UserInputService:IsKeyDown(AimbotKey) then
        local target = getClosestPlayer()
        if target and target.Character then
            local targetPart = target.Character:FindFirstChild(AimPart)
            if targetPart then
                -- Smooth aiming
                local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 0.1) -- 0.1 is the smoothness factor (lower = smoother)
            end
        end
    end
end)

-- ESP Functions
local function createESP(player)
    if ESP[player] then return end -- Already has ESP
    
    ESP[player] = {}
    
    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Color = Color3.new(1, 1, 1)
    box.Transparency = 1
    box.Visible = false
    
    local nameText = Drawing.new("Text")
    nameText.Size = 14
    nameText.Center = true
    nameText.Outline = true
    nameText.Color = Color3.new(1, 1, 1)
    nameText.Visible = false
    
    ESP[player].Box = box
    ESP[player].NameText = nameText
end

local function removeESP(player)
    if ESP[player] then
        for _, drawingObject in pairs(ESP[player]) do
            drawingObject:Remove()
        end
        ESP[player] = nil
    end
end

local function updateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChildOfClass("Humanoid") and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Head") then
            if not TeamCheck or player.Team ~= LocalPlayer.Team then
                local humanoidRootPart = player.Character.HumanoidRootPart
                local head = player.Character.Head
                local screenPosRoot, onScreenRoot = Camera:WorldToViewportPoint(humanoidRootPart.Position)
                local screenPosHead, onScreenHead = Camera:WorldToViewportPoint(head.Position)
                
                if onScreenRoot then
                    if not ESP[player] then
                        createESP(player)
                    end
                    
                    local espObjects = ESP[player]
                    if espObjects then
                        -- Update Box
                        local boxSize = Vector2.new(2500 / screenPosRoot.Z, (screenPosRoot.Y - screenPosHead.Y))
                        espObjects.Box.Size = boxSize
                        espObjects.Box.Position = Vector2.new(screenPosRoot.X - boxSize.X / 2, screenPosRoot.Y - boxSize.Y / 2)
                        espObjects.Box.Visible = ESPEnabled
                        
                        -- Update Name Text
                        espObjects.NameText.Position = Vector2.new(screenPosRoot.X, screenPosRoot.Y - boxSize.Y / 2 - 15)
                        espObjects.NameText.Text = player.Name .. " [" .. math.floor((humanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) .. "m]"
                        espObjects.NameText.Visible = ESPEnabled
                    end
                else
                    if ESP[player] then
                        for _, drawingObject in pairs(ESP[player]) do
                            drawingObject.Visible = false
                        end
                    end
                end
            else
                removeESP(player)
            end
        else
            removeESP(player)
        end
    end
end

-- ESP Loop
RunService.RenderStepped:Connect(updateESP)

-- Player Connections
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        createESP(player)
    end)
end)

Players.PlayerRemoving:Connect(removeESP)

-- Initialize
createGUI()

-- Create ESP for players already in the game
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createESP(player)
    end
end