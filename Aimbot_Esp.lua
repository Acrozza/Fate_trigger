-- =============================================
-- ==      ADVANCED AIMBOT & ESP (FPS)       ==
-- ==         Optimized for FPS Games        ==
-- ==      Educational Purposes Only        ==
-- =============================================

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local GuiService = game:GetService("GuiService")
local StarterGui = game:GetService("StarterGui")

-- Player
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- == SETTINGS ==
local AimbotSettings = {
    Enabled = true,
    Keybind = Enum.KeyCode.Q,
    Smoothness = 0.08, -- Lower = Snappier, Higher = Smoother
    AimPart = {"Head", "HumanoidRootPart"}, -- Priority order
    FOV = 70, -- Field of View in degrees
    TeamCheck = true
}

local ESPSettings = {
    Enabled = true,
    TeamCheck = true,
    ShowNames = true,
    ShowDistance = true,
    ShowBox = true
}
-- ==============

-- GUI & Drawing Objects
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local FovCircle = Drawing.new("Circle")
local ESP = {}

-- Function to create the GUI
local function createGUI()
    if syn then syn.protect_gui(ScreenGui) end
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Main Frame
    MainFrame.Parent = ScreenGui
    MainFrame.Active = true
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0, 100, 0, 100)
    MainFrame.Size = UDim2.new(0, 200, 0, 180)
    MainFrame.Draggable = true

    -- Title Label
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Parent = MainFrame
    TitleLabel.Size = UDim2.new(1, 0, 0, 30)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = "Fate Trigger Hub"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TitleLabel.BorderSizePixel = 0

    -- Aimbot Toggle
    local AimbotToggle = Instance.new("TextButton")
    AimbotToggle.Parent = MainFrame
    AimbotToggle.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    AimbotToggle.BorderSizePixel = 0
    AimbotToggle.Position = UDim2.new(0, 10, 0, 40)
    AimbotToggle.Size = UDim2.new(0, 180, 0, 30)
    AimbotToggle.Font = Enum.Font.Gotham
    AimbotToggle.Text = "Aimbot: OFF"
    AimbotToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    AimbotToggle.TextSize = 14.000

    -- ESP Toggle
    local ESPToggle = Instance.new("TextButton")
    ESPToggle.Parent = MainFrame
    ESPToggle.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    ESPToggle.BorderSizePixel = 0
    ESPToggle.Position = UDim2.new(0, 10, 0, 80)
    ESPToggle.Size = UDim2.new(0, 180, 0, 30)
    ESPToggle.Font = Enum.Font.Gotham
    ESPToggle.Text = "ESP: OFF"
    ESPToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    ESPToggle.TextSize = 14.000
    
    -- Team Check Toggle
    local TeamCheckToggle = Instance.new("TextButton")
    TeamCheckToggle.Parent = MainFrame
    TeamCheckToggle.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
    TeamCheckToggle.BorderSizePixel = 0
    TeamCheckToggle.Position = UDim2.new(0, 10, 0, 120)
    TeamCheckToggle.Size = UDim2.new(0, 180, 0, 30)
    TeamCheckToggle.Font = Enum.Font.Gotham
    TeamCheckToggle.Text = "Team Check: ON"
    TeamCheckToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    TeamCheckToggle.TextSize = 14.000
    
    local NotificationLabel = Instance.new("TextLabel")
    NotificationLabel.Parent = MainFrame
    NotificationLabel.Size = UDim2.new(1, 0, 0, 30)
    NotificationLabel.Position = UDim2.new(0,0,1,-30)
    NotificationLabel.Font = Enum.Font.Gotham
    NotificationLabel.Text = "Hub Loaded"
    NotificationLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    NotificationLabel.BackgroundTransparency = 1
    NotificationLabel.TextSize = 12

    -- Button Functions
    AimbotToggle.MouseButton1Click:Connect(function()
        AimbotSettings.Enabled = not AimbotSettings.Enabled
        AimbotToggle.Text = "Aimbot: " .. (AimbotSettings.Enabled and "ON" or "OFF")
        AimbotToggle.BackgroundColor3 = AimbotSettings.Enabled and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
        FovCircle.Visible = AimbotSettings.Enabled
        NotificationLabel.Text = "Aimbot " .. (AimbotSettings.Enabled and "Enabled" or "Disabled")
    end)

    ESPToggle.MouseButton1Click:Connect(function()
        ESPSettings.Enabled = not ESPSettings.Enabled
        ESPToggle.Text = "ESP: " .. (ESPSettings.Enabled and "ON" or "OFF")
        ESPToggle.BackgroundColor3 = ESPSettings.Enabled and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
        NotificationLabel.Text = "ESP " .. (ESPSettings.Enabled and "Enabled" or "Disabled")
    end)
    
    TeamCheckToggle.MouseButton1Click:Connect(function()
        AimbotSettings.TeamCheck = not AimbotSettings.TeamCheck
        ESPSettings.TeamCheck = not ESPSettings.TeamCheck
        TeamCheckToggle.Text = "Team Check: " .. (AimbotSettings.TeamCheck and "ON" or "OFF")
        TeamCheckToggle.BackgroundColor3 = AimbotSettings.TeamCheck and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
        NotificationLabel.Text = "Team Check " .. (AimbotSettings.TeamCheck and "Enabled" or "Disabled")
    end)
end

-- Function to check if a part is visible
local function isVisible(part)
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin).unit
    local ray = Ray.new(origin, direction * 1000)
    
    local hit, position = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
    if not hit then return false end
    
    local distance = (position - part.Position).magnitude
    return distance < 5 -- If the ray hit is very close to the target part, it's visible
end

-- Function to get the closest player in FOV
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChildOfClass("Humanoid") and player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
            if not AimbotSettings.TeamCheck or player.Team ~= LocalPlayer.Team then
                local targetPart = nil
                for _, partName in ipairs(AimbotSettings.AimPart) do
                    targetPart = player.Character:FindFirstChild(partName)
                    if targetPart then break end
                end

                if targetPart then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        local fovRadius = (Camera.ViewportSize.X / 2) * math.tan(math.rad(AimbotSettings.FOV / 2))
                        
                        if distance < fovRadius and distance < shortestDistance and isVisible(targetPart) then
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
    if AimbotSettings.Enabled and UserInputService:IsKeyDown(AimbotSettings.Keybind) and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local target = getClosestPlayer()
        if target and target.Character then
            local targetPart = nil
            for _, partName in ipairs(AimbotSettings.AimPart) do
                targetPart = target.Character:FindFirstChild(partName)
                if targetPart then break end
            end
            
            if targetPart then
                local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, AimbotSettings.Smoothness)
            end
        end
    end
end)

-- ESP Functions
local function createESP(player)
    if ESP[player] then return end
    ESP[player] = {}
    
    if ESPSettings.ShowBox then
        local box = Drawing.new("Square")
        box.Thickness = 1
        box.Color = Color3.new(1, 1, 1)
        box.Transparency = 1
        box.Visible = false
        ESP[player].Box = box
    end

    if ESPSettings.ShowNames or ESPSettings.ShowDistance then
        local text = Drawing.new("Text")
        text.Size = 14
        text.Center = true
        text.Outline = true
        text.Color = Color3.new(1, 1, 1)
        text.Visible = false
        ESP[player].Text = text
    end
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
            if not ESPSettings.TeamCheck or player.Team ~= LocalPlayer.Team then
                local humanoidRootPart = player.Character.HumanoidRootPart
                local head = player.Character.Head
                local screenPosRoot, onScreenRoot = Camera:WorldToViewportPoint(humanoidRootPart.Position)
                local screenPosHead = Camera:WorldToViewportPoint(head.Position)
                
                if onScreenRoot then
                    if not ESP[player] then createESP(player) end
                    
                    local espObjects = ESP[player]
                    if espObjects then
                        if espObjects.Box then
                            local boxSize = Vector2.new(2500 / screenPosRoot.Z, (screenPosRoot.Y - screenPosHead.Y))
                            espObjects.Box.Size = boxSize
                            espObjects.Box.Position = Vector2.new(screenPosRoot.X - boxSize.X / 2, screenPosRoot.Y - boxSize.Y / 2)
                            espObjects.Box.Visible = ESPSettings.Enabled
                        end
                        
                        if espObjects.Text then
                            local displayText = ""
                            if ESPSettings.ShowNames then displayText = player.Name end
                            if ESPSettings.ShowDistance then
                                local dist = math.floor((humanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
                                displayText = displayText .. " [" .. dist .. "m]"
                            end
                            espObjects.Text.Text = displayText
                            espObjects.Text.Position = Vector2.new(screenPosRoot.X, screenPosRoot.Y - (espObjects.Box and espObjects.Box.Size.Y/2 or 20) - 15)
                            espObjects.Text.Visible = ESPSettings.Enabled
                        end
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

-- FOV Circle Update
RunService.RenderStepped:Connect(function()
    FovCircle.Radius = (Camera.ViewportSize.X / 2) * math.tan(math.rad(AimbotSettings.FOV / 2))
    FovCircle.Position = Camera.ViewportSize / 2
    FovCircle.Color = Color3.fromRGB(255, 255, 255)
    FovCircle.Thickness = 1
    FovCircle.Transparency = 0.5
    FovCircle.Visible = AimbotSettings.Enabled
end)

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
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createESP(player)
    end
end

