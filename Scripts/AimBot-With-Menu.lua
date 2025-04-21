local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Settings Initialization
local Settings = {
    ESP = {
        Enabled = true,
        Boxes = true,
        Names = true,
        Distance = true,
        Health = true,
        Snaplines = true,
        TeamCheck = false,
        Rainbow = true,
        BoxColor = Color3.fromRGB(255, 0, 255),
        Players = {},
        Tracers = {}
    },
    Aimbot = {
        Enabled = true,
        TeamCheck = false,
        Smoothness = 0.15, -- Lower = smoother
        FOV = 100,
        TargetPart = "Head",
        ShowFOV = true,
        SnapLineVisible = false, -- Hide aimbot snap line
        AimAtSnapLine = false, -- Aim directly at target
        PrecisionFactor = 0.99, -- How precisely to aim (0.99 = 99% accuracy)
        Active = false -- Track if right mouse is currently held
    }
}

-- FOV Circle Setup
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 100
FOVCircle.Radius = 100
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.ZIndex = 999
FOVCircle.Transparency = 1
FOVCircle.Color = Color3.fromRGB(255, 0, 255)

-- Aimbot Snap Line
local AimbotSnapLine = Drawing.new("Line")
AimbotSnapLine.Visible = false
AimbotSnapLine.Thickness = 1.5
AimbotSnapLine.Color = Color3.fromRGB(255, 0, 0) -- Red snap line
AimbotSnapLine.Transparency = 0.8
AimbotSnapLine.ZIndex = 1000

-- Create a drop shadow GUI for the button panel
local DropShadowHolder = Instance.new("ScreenGui")
DropShadowHolder.Name = "AimbotControlPanel"
DropShadowHolder.ResetOnSpawn = false
DropShadowHolder.Enabled = true

-- Handle protection based on executor
if syn and syn.protect_gui then 
    syn.protect_gui(DropShadowHolder)
    DropShadowHolder.Parent = game.CoreGui
elseif gethui then
    DropShadowHolder.Parent = gethui()
elseif CoreGui:FindFirstChild("RobloxGui") then
    DropShadowHolder.Parent = CoreGui.RobloxGui
else
    DropShadowHolder.Parent = CoreGui
end

-- Create panel
local Panel = Instance.new("Frame")
Panel.Name = "MainPanel"
Panel.Size = UDim2.new(0, 250, 0, 430)
Panel.Position = UDim2.new(1, -260, 0.5, -215)
Panel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Panel.BorderSizePixel = 0
Panel.Parent = DropShadowHolder

-- Add rounded corners
local PanelCorner = Instance.new("UICorner")
PanelCorner.CornerRadius = UDim.new(0, 8)
PanelCorner.Parent = Panel

-- Add shadow
local Shadow = Instance.new("Frame")
Shadow.Name = "Shadow"
Shadow.Size = UDim2.new(1, 20, 1, 20)
Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Shadow.BackgroundTransparency = 0.6
Shadow.BorderSizePixel = 0
Shadow.ZIndex = 0
Shadow.Parent = Panel

-- Add rounded corners to shadow
local ShadowCorner = Instance.new("UICorner")
ShadowCorner.CornerRadius = UDim.new(0, 10)
ShadowCorner.Parent = Shadow

-- Title bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Panel

-- Add title bar rounded corners (just top)
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

-- Create a frame to square off the bottom corners
local BottomFrame = Instance.new("Frame")
BottomFrame.Name = "BottomFrame"
BottomFrame.Size = UDim2.new(1, 0, 0.5, 0)
BottomFrame.Position = UDim2.new(0, 0, 0.5, 0)
BottomFrame.BackgroundColor3 = TitleBar.BackgroundColor3
BottomFrame.BorderSizePixel = 0
BottomFrame.ZIndex = TitleBar.ZIndex
BottomFrame.Parent = TitleBar

-- Title text
local TitleText = Instance.new("TextLabel")
TitleText.Name = "Title"
TitleText.Size = UDim2.new(1, -40, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.TextColor3 = Color3.fromRGB(255, 0, 255)
TitleText.TextSize = 18
TitleText.Font = Enum.Font.SourceSansBold
TitleText.Text = "Ultimate Aimbot"
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.ZIndex = TitleBar.ZIndex + 1
TitleText.Parent = TitleBar

-- Make the UI draggable
local dragging, dragInput, dragStart, startPos
    
local function updateDrag(input)
    local delta = input.Position - dragStart
    Panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Panel.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateDrag(input)
    end
end)

-- Create scrolling frame for buttons
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "SettingsScroll"
ScrollFrame.Size = UDim2.new(1, -20, 1, -50)
ScrollFrame.Position = UDim2.new(0, 10, 0, 45)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 0, 255)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 700) -- Increased to fit all content
ScrollFrame.Parent = Panel

-- Create UI Layout for buttons
local UILayout = Instance.new("UIListLayout")
UILayout.Padding = UDim.new(0, 10)
UILayout.SortOrder = Enum.SortOrder.LayoutOrder
UILayout.Parent = ScrollFrame

-- Function to create a section header
local function CreateHeader(text, order)
    local header = Instance.new("TextLabel")
    header.Name = text .. "Header"
    header.Size = UDim2.new(1, 0, 0, 30)
    header.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    header.BorderSizePixel = 0
    header.Text = text
    header.TextColor3 = Color3.fromRGB(255, 0, 255)
    header.TextSize = 16
    header.Font = Enum.Font.SourceSansBold
    header.LayoutOrder = order
    
    -- Add rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = header
    
    header.Parent = ScrollFrame
    return header
end

-- Function to create a toggle button
local function CreateToggle(name, initialState, callback, order)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = name .. "Toggle"
    toggleFrame.Size = UDim2.new(1, 0, 0, 30)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    toggleFrame.BorderSizePixel = 0
    toggleFrame.LayoutOrder = order
    
    -- Add rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = toggleFrame
    
    -- Toggle label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 14
    label.Font = Enum.Font.SourceSans
    label.Text = name
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    -- Toggle button
    local button = Instance.new("Frame")
    button.Name = "Button"
    button.Size = UDim2.new(0, 40, 0, 20)
    button.Position = UDim2.new(1, -50, 0.5, -10)
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    button.BorderSizePixel = 0
    button.Parent = toggleFrame
    
    -- Add rounded corners to button
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(1, 0)
    buttonCorner.Parent = button
    
    -- Toggle indicator
    local indicator = Instance.new("Frame")
    indicator.Name = "Indicator"
    indicator.Size = UDim2.new(0, 16, 0, 16)
    indicator.Position = initialState and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    indicator.BackgroundColor3 = initialState and Color3.fromRGB(255, 0, 255) or Color3.fromRGB(80, 80, 80)
    indicator.BorderSizePixel = 0
    indicator.Parent = button
    
    -- Add rounded corners to indicator
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(1, 0)
    indicatorCorner.Parent = indicator
    
    -- Make the toggle interactive
    local toggled = initialState
    
    toggleFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggled = not toggled
            
            -- Animate indicator
            local targetPosition = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            local targetColor = toggled and Color3.fromRGB(255, 0, 255) or Color3.fromRGB(80, 80, 80)
            
            TweenService:Create(indicator, TweenInfo.new(0.2), {
                Position = targetPosition,
                BackgroundColor3 = targetColor
            }):Play()
            
            -- Execute callback
            callback(toggled)
        end
    end)
    
    toggleFrame.Parent = ScrollFrame
    return toggleFrame, toggled
end

-- Function to create a slider
local function CreateSlider(name, min, max, initialValue, callback, order)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = name .. "Slider"
    sliderFrame.Size = UDim2.new(1, 0, 0, 50)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    sliderFrame.BorderSizePixel = 0
    sliderFrame.LayoutOrder = order
    
    -- Add rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = sliderFrame
    
    -- Slider label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -60, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 14
    label.Font = Enum.Font.SourceSans
    label.Text = name
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = sliderFrame
    
    -- Value display
    local valueDisplay = Instance.new("TextLabel")
    valueDisplay.Name = "Value"
    valueDisplay.Size = UDim2.new(0, 50, 0, 20)
    valueDisplay.Position = UDim2.new(1, -60, 0, 5)
    valueDisplay.BackgroundTransparency = 1
    valueDisplay.TextColor3 = Color3.fromRGB(200, 200, 200)
    valueDisplay.TextSize = 14
    valueDisplay.Font = Enum.Font.SourceSans
    valueDisplay.Text = tostring(initialValue)
    valueDisplay.TextXAlignment = Enum.TextXAlignment.Center
    valueDisplay.Parent = sliderFrame
    
    -- Slider track
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.new(1, -20, 0, 6)
    track.Position = UDim2.new(0, 10, 0, 30)
    track.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    track.BorderSizePixel = 0
    track.Parent = sliderFrame
    
    -- Add rounded corners to track
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track
    
    -- Slider handle
    local handle = Instance.new("Frame")
    handle.Name = "Handle"
    handle.Size = UDim2.new(0, 16, 0, 16)
    local relativePos = (initialValue - min) / (max - min)
    handle.Position = UDim2.new(relativePos, -8, 0.5, -8)
    handle.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
    handle.BorderSizePixel = 0
    handle.Parent = track
    
    -- Add rounded corners to handle
    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(1, 0)
    handleCorner.Parent = handle
    
    -- Make the slider interactive
    local dragging = false
    
    local function updateSlider(input)
        local trackAbsPos = track.AbsolutePosition
        local trackAbsSize = track.AbsoluteSize
        local relativeX = math.clamp((input.Position.X - trackAbsPos.X) / trackAbsSize.X, 0, 1)
        local value = min + (relativeX * (max - min))
        
        -- Round value if necessary (for integers)
        if min % 1 == 0 and max % 1 == 0 then
            value = math.floor(value + 0.5)
        else
            -- Round to 2 decimal places for floats
            value = math.floor(value * 100 + 0.5) / 100
        end
        
        -- Update handle position
        handle.Position = UDim2.new(relativeX, -8, 0.5, -8)
        
        -- Update value display
        valueDisplay.Text = tostring(value)
        
        -- Execute callback
        callback(value)
    end
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input)
        end
    end)
    
    track.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            updateSlider(input)
        end
    end)
    
    sliderFrame.Parent = ScrollFrame
    return sliderFrame, initialValue
end

-- Create UI elements
-- ESP Section
local espHeader = CreateHeader("ESP Settings", 0)

local espToggle = CreateToggle("ESP Enabled", Settings.ESP.Enabled, function(state)
    Settings.ESP.Enabled = state
end, 1)

local boxesToggle = CreateToggle("Show Boxes", Settings.ESP.Boxes, function(state)
    Settings.ESP.Boxes = state
end, 2)

local namesToggle = CreateToggle("Show Names", Settings.ESP.Names, function(state)
    Settings.ESP.Names = state
end, 3)

local distanceToggle = CreateToggle("Show Distance", Settings.ESP.Distance, function(state)
    Settings.ESP.Distance = state
end, 4)

local snaplinesToggle = CreateToggle("Show ESP Snaplines", Settings.ESP.Snaplines, function(state)
    Settings.ESP.Snaplines = state
end, 5)

local teamCheckToggle = CreateToggle("Team Check", Settings.ESP.TeamCheck, function(state)
    Settings.ESP.TeamCheck = state
    Settings.Aimbot.TeamCheck = state
end, 6)

local rainbowToggle = CreateToggle("Rainbow ESP", Settings.ESP.Rainbow, function(state)
    Settings.ESP.Rainbow = state
end, 7)

-- Aimbot Section
local aimbotHeader = CreateHeader("Aimbot Settings", 100)

local aimbotToggle = CreateToggle("Aimbot Enabled", Settings.Aimbot.Enabled, function(state)
    Settings.Aimbot.Enabled = state
end, 101)

local fovCircleToggle = CreateToggle("Show FOV Circle", Settings.Aimbot.ShowFOV, function(state)
    Settings.Aimbot.ShowFOV = state
    FOVCircle.Visible = Settings.Aimbot.Enabled and state
end, 102)

local aimbotSnapLineToggle = CreateToggle("Show Aimbot Snap Line", Settings.Aimbot.SnapLineVisible, function(state)
    Settings.Aimbot.SnapLineVisible = state
end, 103)

local aimAtSnapLineToggle = CreateToggle("Aim At Snap Line", Settings.Aimbot.AimAtSnapLine, function(state)
    Settings.Aimbot.AimAtSnapLine = state
end, 104)

local fovSlider = CreateSlider("FOV Size", 10, 400, Settings.Aimbot.FOV, function(value)
    Settings.Aimbot.FOV = value
    FOVCircle.Radius = value
end, 105)

local smoothnessSlider = CreateSlider("Smoothness", 0.01, 1, Settings.Aimbot.Smoothness, function(value)
    Settings.Aimbot.Smoothness = value
end, 106)

-- Add an additional aimbot sensitivity slider
local aimSpeedSlider = CreateSlider("Aim Speed", 1, 10, 5, function(value)
    -- Higher values make the aimbot more snappy, lower values make it smoother
    local adjustedSpeed = value / 10
    Settings.Aimbot.AimSpeed = adjustedSpeed
end, 107)

local precisionSlider = CreateSlider("Precision", 0.9, 1, Settings.Aimbot.PrecisionFactor, function(value)
    Settings.Aimbot.PrecisionFactor = value
end, 108)

-- Target Part Dropdown
local targetPartFrame = Instance.new("Frame")
targetPartFrame.Name = "TargetPartFrame"
targetPartFrame.Size = UDim2.new(1, 0, 0, 30)
targetPartFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
targetPartFrame.BorderSizePixel = 0
targetPartFrame.LayoutOrder = 109
targetPartFrame.Parent = ScrollFrame

-- Add rounded corners
local targetPartCorner = Instance.new("UICorner")
targetPartCorner.CornerRadius = UDim.new(0, 6)
targetPartCorner.Parent = targetPartFrame

-- Target part label
local targetPartLabel = Instance.new("TextLabel")
targetPartLabel.Name = "Label"
targetPartLabel.Size = UDim2.new(0, 80, 1, 0)
targetPartLabel.Position = UDim2.new(0, 10, 0, 0)
targetPartLabel.BackgroundTransparency = 1
targetPartLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
targetPartLabel.TextSize = 14
targetPartLabel.Font = Enum.Font.SourceSans
targetPartLabel.Text = "Target Part:"
targetPartLabel.TextXAlignment = Enum.TextXAlignment.Left
targetPartLabel.Parent = targetPartFrame

-- Target part dropdown button
local targetPartButton = Instance.new("TextButton")
targetPartButton.Name = "DropdownButton"
targetPartButton.Size = UDim2.new(0, 120, 0, 24)
targetPartButton.Position = UDim2.new(1, -130, 0.5, -12)
targetPartButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
targetPartButton.BorderSizePixel = 0
targetPartButton.Text = Settings.Aimbot.TargetPart
targetPartButton.TextColor3 = Color3.fromRGB(200, 200, 200)
targetPartButton.TextSize = 14
targetPartButton.Font = Enum.Font.SourceSans
targetPartButton.Parent = targetPartFrame

-- Add rounded corners to dropdown button
local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 4)
buttonCorner.Parent = targetPartButton

-- Dropdown menu
local dropdownMenu = Instance.new("Frame")
dropdownMenu.Name = "DropdownMenu"
dropdownMenu.Size = UDim2.new(0, 120, 0, 0)
dropdownMenu.Position = UDim2.new(1, -130, 1, 2)
dropdownMenu.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
dropdownMenu.BorderSizePixel = 0
dropdownMenu.Visible = false
dropdownMenu.ZIndex = 10
dropdownMenu.ClipsDescendants = true
dropdownMenu.Parent = targetPartFrame

-- Add rounded corners to dropdown menu
local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 4)
menuCorner.Parent = dropdownMenu

-- Add options to dropdown
local options = {"Head", "Torso", "HumanoidRootPart", "UpperTorso", "LowerTorso"}
local optionButtons = {}

for i, option in ipairs(options) do
    local optionButton = Instance.new("TextButton")
    optionButton.Name = option .. "Option"
    optionButton.Size = UDim2.new(1, 0, 0, 24)
    optionButton.Position = UDim2.new(0, 0, 0, (i-1) * 24)
    optionButton.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    optionButton.BackgroundTransparency = 1
    optionButton.BorderSizePixel = 0
    optionButton.Text = option
    optionButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    optionButton.TextSize = 14
    optionButton.Font = Enum.Font.SourceSans
    optionButton.ZIndex = 10
    optionButton.Parent = dropdownMenu
    
    optionButton.MouseEnter:Connect(function()
        TweenService:Create(optionButton, TweenInfo.new(0.1), {BackgroundTransparency = 0.8}):Play()
    end)
    
    optionButton.MouseLeave:Connect(function()
        TweenService:Create(optionButton, TweenInfo.new(0.1), {BackgroundTransparency = 1}):Play()
    end)
    
    optionButton.MouseButton1Click:Connect(function()
        Settings.Aimbot.TargetPart = option
        targetPartButton.Text = option
        toggleDropdown(false)
    end)
    
    table.insert(optionButtons, optionButton)
end

-- Toggle dropdown function
local dropdownOpen = false
function toggleDropdown(state)
    if state == nil then
        state = not dropdownOpen
    end
    
    dropdownOpen = state
    dropdownMenu.Visible = state
    
    if state then
        -- Expand menu
        TweenService:Create(dropdownMenu, TweenInfo.new(0.2), {Size = UDim2.new(0, 120, 0, #options * 24)}):Play()
    else
        -- Collapse menu
        TweenService:Create(dropdownMenu, TweenInfo.new(0.2), {Size = UDim2.new(0, 120, 0, 0)}):Play()
        wait(0.2)
        dropdownMenu.Visible = false
    end
end

-- Toggle dropdown when button is clicked
targetPartButton.MouseButton1Click:Connect(function()
    toggleDropdown()
end)

-- Utility function to get the closest player
local function GetClosestPlayer()
    local closestPlayer, shortestDistance = nil, math.huge
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if Settings.Aimbot.TeamCheck and player.Team == LocalPlayer.Team then 
                continue 
            end

            local character = player.Character
            if character then
                local targetPart = character:FindFirstChild(Settings.Aimbot.TargetPart)
                if targetPart then
                    local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                        if distance <= Settings.Aimbot.FOV and distance < shortestDistance then
                            closestPlayer, shortestDistance = player, distance
                        end
                    end
                end
            end
        end
    end

    return closestPlayer
end

-- Utility function to create ESP for a player
local function CreateESP(player)
    local esp = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Snapline = Drawing.new("Line")
    }

    esp.Box.Visible = false
    esp.Box.Color = Settings.ESP.BoxColor
    esp.Box.Thickness = 2
    esp.Box.Filled = false
    esp.Box.Transparency = 1

    esp.Name.Visible = false
    esp.Name.Color = Color3.new(1, 1, 1)
    esp.Name.Size = 14
    esp.Name.Center = true
    esp.Name.Outline = true

    esp.Distance.Visible = false
    esp.Distance.Color = Color3.new(1, 1, 1)
    esp.Distance.Size = 12
    esp.Distance.Center = true
    esp.Distance.Outline = true

    esp.Snapline.Visible = false
    esp.Snapline.Color = Settings.ESP.BoxColor
    esp.Snapline.Thickness = 1
    esp.Snapline.Transparency = 1

    Settings.ESP.Players[player] = esp
end

-- Utility function to update ESP for all players
local function UpdateESP()
    for player, esp in pairs(Settings.ESP.Players) do
        if player.Character and player ~= LocalPlayer and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoidRootPart = player.Character.HumanoidRootPart
            local head = player.Character:FindFirstChild("Head")
            local screenPos, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)

            if onScreen and Settings.ESP.Enabled then
                if Settings.ESP.TeamCheck and player.Team == LocalPlayer.Team then
                    esp.Box.Visible, esp.Name.Visible, esp.Distance.Visible, esp.Snapline.Visible = false, false, false, false
                    continue
                end

                -- Update Box ESP
                if Settings.ESP.Boxes then
                    local size = (Camera:WorldToViewportPoint(humanoidRootPart.Position + Vector3.new(3, 6, 0)).Y - Camera:WorldToViewportPoint(humanoidRootPart.Position + Vector3.new(-3, -3, 0)).Y) / 2
                    esp.Box.Size = Vector2.new(size * 0.7, size * 1)
                    esp.Box.Position = Vector2.new(screenPos.X - esp.Box.Size.X / 2, screenPos.Y - esp.Box.Size.Y / 2)
                    esp.Box.Color = Settings.ESP.Rainbow and Color3.fromHSV(tick() % 5 / 5, 1, 1) or Settings.ESP.BoxColor
                    esp.Box.Visible = true
                else
                    esp.Box.Visible = false
                end

                -- Snaplines
                if Settings.ESP.Snaplines then
                    esp.Snapline.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    esp.Snapline.To = Vector2.new(screenPos.X, screenPos.Y)
                    esp.Snapline.Color = Settings.ESP.Rainbow and Color3.fromHSV(tick() % 5 / 5, 1, 1) or Settings.ESP.BoxColor
                    esp.Snapline.Visible = true
                else
                    esp.Snapline.Visible = false
                end

                -- Names and Distance
                if Settings.ESP.Names and head then
                    esp.Name.Position = Vector2.new(screenPos.X, screenPos.Y - esp.Box.Size.Y / 2 - 15)
                    esp.Name.Text = player.Name
                    esp.Name.Visible = true
                else
                    esp.Name.Visible = false
                end

                if Settings.ESP.Distance then
                    local distance = math.floor((humanoidRootPart.Position - Camera.CFrame.Position).Magnitude)
                    esp.Distance.Position = Vector2.new(screenPos.X, screenPos.Y + esp.Box.Size.Y / 2 + 5)
                    esp.Distance.Text = tostring(distance) .. " studs"
                    esp.Distance.Visible = true
                else
                    esp.Distance.Visible = false
                end
            else
                esp.Box.Visible, esp.Name.Visible, esp.Distance.Visible, esp.Snapline.Visible = false, false, false, false
            end
        else
            esp.Box.Visible, esp.Name.Visible, esp.Distance.Visible, esp.Snapline.Visible = false, false, false, false
        end
    end
end

-- Add button to toggle UI visibility
local toggleUIButton = Instance.new("TextButton")
toggleUIButton.Name = "ToggleUIButton"
toggleUIButton.Size = UDim2.new(0, 40, 0, 40)
toggleUIButton.Position = UDim2.new(0.5, -20, 0, 10)
toggleUIButton.AnchorPoint = Vector2.new(0.5, 0)
toggleUIButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
toggleUIButton.BorderSizePixel = 0
toggleUIButton.Text = "UI"
toggleUIButton.TextColor3 = Color3.fromRGB(255, 0, 255)
toggleUIButton.TextSize = 16
toggleUIButton.Font = Enum.Font.SourceSansBold
toggleUIButton.Visible = false
toggleUIButton.Parent = DropShadowHolder

-- Add rounded corners to toggle button
local toggleUICorner = Instance.new("UICorner")
toggleUICorner.CornerRadius = UDim.new(0, 10)
toggleUICorner.Parent = toggleUIButton

-- Function to toggle UI
local function ToggleUI()
    Panel.Visible = not Panel.Visible
    toggleUIButton.Visible = not Panel.Visible
end

-- Handle UI toggle button click
toggleUIButton.MouseButton1Click:Connect(function()
    ToggleUI()
end)

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundTransparency = 1
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
closeButton.TextSize = 20
closeButton.Font = Enum.Font.SourceSansBold
closeButton.Parent = TitleBar

-- Handle close button click
closeButton.MouseButton1Click:Connect(function()
    ToggleUI()
end)

-- Initialize ESP for all existing players
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

-- Handle new players
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end)

-- Handle player removal
Players.PlayerRemoving:Connect(function(player)
    if Settings.ESP.Players[player] then
        for _, drawing in pairs(Settings.ESP.Players[player]) do
            drawing:Remove()
        end
        Settings.ESP.Players[player] = nil
    end
end)

-- Handle user input for aimbot activation
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton2 then
        Settings.Aimbot.Active = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Settings.Aimbot.Active = false
    end
end)

-- Main Update Loop
RunService.RenderStepped:Connect(function()
    -- Update ESP
    UpdateESP()

    -- Update FOV circle
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Radius = Settings.Aimbot.FOV
    FOVCircle.Visible = Settings.Aimbot.Enabled and Settings.Aimbot.ShowFOV

    -- Only update snap line if it's visible
    if Settings.Aimbot.SnapLineVisible then
        AimbotSnapLine.From = UserInputService:GetMouseLocation()
        AimbotSnapLine.Visible = Settings.Aimbot.Enabled
    else
        AimbotSnapLine.Visible = false
    end

    -- Use the new camera-based aiming method like in the sample code
    if Settings.Aimbot.Enabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetClosestPlayer()
        if target and target.Character then
            local targetPart = target.Character:FindFirstChild(Settings.Aimbot.TargetPart)
            if targetPart then
                -- Update snap line endpoint if needed
                local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    if Settings.Aimbot.SnapLineVisible then
                        AimbotSnapLine.To = Vector2.new(pos.X, pos.Y)
                    end
                    
                    -- Use direct camera manipulation like in the sample code
                    local targetPos = targetPart.Position
                    local currentCFrame = Camera.CFrame
                    local targetCFrame = CFrame.new(currentCFrame.Position, targetPos)
                    
                    -- Apply smoothness - higher values = smoother motion
                    local smoothValue = Settings.Aimbot.Smoothness
                    Camera.CFrame = currentCFrame:Lerp(targetCFrame, smoothValue)
                end
            end
        end
    end
end)

-- Print confirmation message
print("Ultimate Aimbot loaded successfully!")
print("Hold right mouse button to activate aimbot")
