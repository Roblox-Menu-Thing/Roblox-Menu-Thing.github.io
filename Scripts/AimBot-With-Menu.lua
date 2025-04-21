local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Function to check if player can be damaged
local function CanDamagePlayer(player)
    -- Check if friendly fire is on (can damage teammates)
    local friendlyFire = workspace:FindFirstChild("FriendlyFire")
    if friendlyFire and friendlyFire:IsA("BoolValue") and friendlyFire.Value then
        return true
    end
    
    -- Check if player is on enemy team
    if player.Team ~= LocalPlayer.Team then
        return true
    end
    
    -- Try to check if player is damageable through other means
    -- Some games have a "Damage" or "CanDamage" function/value
    local character = player.Character
    if character then
        -- Some games use a TeamTag or TeamColor to determine teams
        local teamTag = character:FindFirstChild("TeamTag")
        if teamTag and teamTag:IsA("StringValue") then
            local localCharacter = LocalPlayer.Character
            if localCharacter then
                local localTeamTag = localCharacter:FindFirstChild("TeamTag")
                if localTeamTag and localTeamTag:IsA("StringValue") then
                    return localTeamTag.Value ~= teamTag.Value
                end
            end
        end
        
        -- Some games use a "Humanoid" property to check teams
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            -- Check if we can damage this humanoid (some games set properties on the humanoid)
            local localCharacter = LocalPlayer.Character
            if localCharacter and localCharacter:FindFirstChildOfClass("Humanoid") then
                return true -- In most games you can damage other humanoids
            end
        end
    end
    
    -- Default to allowing targeting if all checks fail
    return true
end

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
        SnapLineVisible = true, -- Always show snap line (modified)
        AimAtSnapLine = true, -- Aim directly at target (modified)
        PrecisionFactor = 0.99, -- How precisely to aim (0.99 = 99% accuracy)
        Active = false, -- Track if right mouse is currently held
        AimMode = "Camera" -- "Camera" or "Mouse" - NEW SETTING
    },
    MouseAimbot = { -- NEW SECTION
        Enabled = true, -- Enabled by default now
        TeamCheck = false,
        Smoothness = 0.1, -- Lower = smoother (more precise by default)
        FOV = 100,
        TargetPart = "Head",
        PrecisionFactor = 0.995, -- Higher precision (99.5%)
        Active = false,
        HeadPrecision = true, -- NEW - More precise head targeting
        OffsetY = 0, -- Vertical offset for head targeting
        OffsetX = 0,  -- Horizontal offset for head targeting
        SnapLineVisible = true -- Always show mouse snap line (added)
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

-- Mouse FOV Circle (NEW)
local MouseFOVCircle = Drawing.new("Circle")
MouseFOVCircle.Thickness = 2
MouseFOVCircle.NumSides = 100
MouseFOVCircle.Radius = 100
MouseFOVCircle.Filled = false
MouseFOVCircle.Visible = false
MouseFOVCircle.ZIndex = 999
MouseFOVCircle.Transparency = 1
MouseFOVCircle.Color = Color3.fromRGB(0, 255, 255) -- Different color for mouse FOV

-- Aimbot Snap Line
local AimbotSnapLine = Drawing.new("Line")
AimbotSnapLine.Visible = false
AimbotSnapLine.Thickness = 1.5
AimbotSnapLine.Color = Color3.fromRGB(255, 0, 0) -- Red snap line
AimbotSnapLine.Transparency = 0.8
AimbotSnapLine.ZIndex = 1000

-- Mouse Aimbot Snap Line (NEW)
local MouseAimbotSnapLine = Drawing.new("Line")
MouseAimbotSnapLine.Visible = false
MouseAimbotSnapLine.Thickness = 1.5
MouseAimbotSnapLine.Color = Color3.fromRGB(0, 255, 255) -- Cyan for mouse snap line
MouseAimbotSnapLine.Transparency = 0.8
MouseAimbotSnapLine.ZIndex = 1000

-- Method indicator text
local AimMethodIndicator = Drawing.new("Text")
AimMethodIndicator.Visible = true
AimMethodIndicator.Size = 20
AimMethodIndicator.Center = true
AimMethodIndicator.Outline = true
AimMethodIndicator.Color = Color3.fromRGB(255, 0, 255)
AimMethodIndicator.Text = "Aim Method: Camera"
AimMethodIndicator.Position = Vector2.new(Camera.ViewportSize.X / 2, 30)
AimMethodIndicator.ZIndex = 1001

-- Camera aimbot indicator
local CameraAimbotIndicator = Drawing.new("Text")
CameraAimbotIndicator.Visible = true
CameraAimbotIndicator.Size = 18
CameraAimbotIndicator.Center = true
CameraAimbotIndicator.Outline = true
CameraAimbotIndicator.Color = Color3.fromRGB(155, 0, 0)
CameraAimbotIndicator.Text = "Camera Aimbot: OFF"
CameraAimbotIndicator.Position = Vector2.new(Camera.ViewportSize.X / 2, 55)
CameraAimbotIndicator.ZIndex = 1001

-- Mouse aimbot indicator
local MouseAimbotIndicator = Drawing.new("Text")
MouseAimbotIndicator.Visible = true
MouseAimbotIndicator.Size = 18
MouseAimbotIndicator.Center = true
MouseAimbotIndicator.Outline = true
MouseAimbotIndicator.Color = Color3.fromRGB(0, 155, 155)
MouseAimbotIndicator.Text = "Mouse Aimbot: OFF"
MouseAimbotIndicator.Position = Vector2.new(Camera.ViewportSize.X / 2, 80)
MouseAimbotIndicator.ZIndex = 1001



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
Panel.Size = UDim2.new(0, 250, 0, 500) -- Increased panel height to see more content
Panel.Position = UDim2.new(1, -260, 0.5, -250) -- Adjusted position to center the larger panel
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
TitleText.Text = "Ultimate Aimbot + Mouse"
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
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 1200) -- Significantly increased to allow more scrolling
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
    
    track.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
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
    
    handle.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    sliderFrame.Parent = ScrollFrame
    return sliderFrame
end

-- Function to create a dropdown menu
local function CreateDropdown(name, options, initialValue, callback, order)
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Name = name .. "Dropdown"
    dropdownFrame.Size = UDim2.new(1, 0, 0, 60) -- Initial size, will adjust
    dropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    dropdownFrame.BorderSizePixel = 0
    dropdownFrame.LayoutOrder = order
    
    -- Add rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = dropdownFrame
    
    -- Dropdown label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 14
    label.Font = Enum.Font.SourceSans
    label.Text = name
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = dropdownFrame
    
    -- Selected value display
    local selectionDisplay = Instance.new("TextButton")
    selectionDisplay.Name = "Selection"
    selectionDisplay.Size = UDim2.new(1, -20, 0, 30)
    selectionDisplay.Position = UDim2.new(0, 10, 0, 25)
    selectionDisplay.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    selectionDisplay.BorderSizePixel = 0
    selectionDisplay.TextColor3 = Color3.fromRGB(200, 200, 200)
    selectionDisplay.TextSize = 14
    selectionDisplay.Font = Enum.Font.SourceSans
    selectionDisplay.Text = " " .. initialValue -- Add spacing
    selectionDisplay.TextXAlignment = Enum.TextXAlignment.Left
    selectionDisplay.Parent = dropdownFrame
    
    -- Add rounded corners to selection
    local selectionCorner = Instance.new("UICorner")
    selectionCorner.CornerRadius = UDim.new(0, 4)
    selectionCorner.Parent = selectionDisplay
    
    -- Dropdown arrow
    local arrow = Instance.new("TextLabel")
    arrow.Name = "Arrow"
    arrow.Size = UDim2.new(0, 20, 0, 20)
    arrow.Position = UDim2.new(1, -25, 0, 5)
    arrow.BackgroundTransparency = 1
    arrow.TextColor3 = Color3.fromRGB(200, 200, 200)
    arrow.TextSize = 14
    arrow.Font = Enum.Font.SourceSansBold
    arrow.Text = "▼"
    arrow.Parent = selectionDisplay
    
    -- Options container
    local optionsContainer = Instance.new("Frame")
    optionsContainer.Name = "Options"
    optionsContainer.Size = UDim2.new(1, 0, 0, 0) -- Will adjust based on options
    optionsContainer.Position = UDim2.new(0, 0, 1, 5)
    optionsContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    optionsContainer.BorderSizePixel = 0
    optionsContainer.Visible = false
    optionsContainer.ZIndex = 5
    optionsContainer.Parent = selectionDisplay
    
    -- Add rounded corners to options
    local optionsCorner = Instance.new("UICorner")
    optionsCorner.CornerRadius = UDim.new(0, 4)
    optionsCorner.Parent = optionsContainer
    
    -- Create options
    local optionsLayout = Instance.new("UIListLayout")
    optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    optionsLayout.Parent = optionsContainer
    
    local currentSelection = initialValue
    local isOpen = false
    
    -- Create option buttons
    for i, option in ipairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Name = option
        optionButton.Size = UDim2.new(1, 0, 0, 25)
        optionButton.BackgroundTransparency = 1
        optionButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        optionButton.TextSize = 14
        optionButton.Font = Enum.Font.SourceSans
        optionButton.Text = " " .. option  -- Add spacing
        optionButton.TextXAlignment = Enum.TextXAlignment.Left
        optionButton.ZIndex = 6
        optionButton.LayoutOrder = i
        optionButton.Parent = optionsContainer
        
        optionButton.MouseButton1Click:Connect(function()
            currentSelection = option
            selectionDisplay.Text = " " .. option
            isOpen = false
            optionsContainer.Visible = false
            arrow.Text = "▼"
            callback(option)
        end)
    end
    
    -- Adjust options container size
    optionsContainer.Size = UDim2.new(1, 0, 0, 25 * #options)
    
    -- Toggle dropdown
    selectionDisplay.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        optionsContainer.Visible = isOpen
        arrow.Text = isOpen and "▲" or "▼"
    end)
    
    -- Close dropdown if clicked elsewhere
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and isOpen then
            local mousePos = UserInputService:GetMouseLocation()
            local dropdownPos = selectionDisplay.AbsolutePosition
            local dropdownSize = selectionDisplay.AbsoluteSize
            local optionsSize = optionsContainer.AbsoluteSize
            
            if not (mousePos.X >= dropdownPos.X and mousePos.X <= dropdownPos.X + dropdownSize.X and 
                (mousePos.Y >= dropdownPos.Y and mousePos.Y <= dropdownPos.Y + dropdownSize.Y + optionsSize.Y)) then
                isOpen = false
                optionsContainer.Visible = false
                arrow.Text = "▼"
            end
        end
    end)
    
    dropdownFrame.Parent = ScrollFrame
    return dropdownFrame, currentSelection
end

-- Create the UI elements
-- ESP Section
local espHeader = CreateHeader("ESP Settings", 0)

local espToggle = CreateToggle("ESP Enabled", Settings.ESP.Enabled, function(value)
    Settings.ESP.Enabled = value
end, 1)

local boxesToggle = CreateToggle("Show Boxes", Settings.ESP.Boxes, function(value)
    Settings.ESP.Boxes = value
end, 2)

local namesToggle = CreateToggle("Show Names", Settings.ESP.Names, function(value)
    Settings.ESP.Names = value
end, 3)

local distanceToggle = CreateToggle("Show Distance", Settings.ESP.Distance, function(value)
    Settings.ESP.Distance = value
end, 4)

local healthToggle = CreateToggle("Show Health", Settings.ESP.Health, function(value)
    Settings.ESP.Health = value
end, 5)

local snaplinesToggle = CreateToggle("Show Snaplines", Settings.ESP.Snaplines, function(value)
    Settings.ESP.Snaplines = value
end, 6)

local teamCheckToggle = CreateToggle("Team Check", Settings.ESP.TeamCheck, function(value)
    Settings.ESP.TeamCheck = value
end, 7)

local rainbowToggle = CreateToggle("Rainbow ESP", Settings.ESP.Rainbow, function(value)
    Settings.ESP.Rainbow = value
end, 8)

-- Aimbot Section
local aimbotHeader = CreateHeader("Camera Aimbot Settings", 9)

local aimbotToggle = CreateToggle("Aimbot Enabled", Settings.Aimbot.Enabled, function(value)
    Settings.Aimbot.Enabled = value
end, 10)

local aimTeamCheckToggle = CreateToggle("Team Check", Settings.Aimbot.TeamCheck, function(value)
    Settings.Aimbot.TeamCheck = value
end, 11)

local smoothnessSlider = CreateSlider("Smoothness", 0.01, 1, Settings.Aimbot.Smoothness, function(value)
    Settings.Aimbot.Smoothness = value
end, 12)

local fovSlider = CreateSlider("FOV", 10, 800, Settings.Aimbot.FOV, function(value)
    Settings.Aimbot.FOV = value
    FOVCircle.Radius = value
end, 13)

local showFOVToggle = CreateToggle("Show FOV Circle", Settings.Aimbot.ShowFOV, function(value)
    Settings.Aimbot.ShowFOV = value
    FOVCircle.Visible = value
end, 14)

local snapLineToggle = CreateToggle("Show Snap Line", Settings.Aimbot.SnapLineVisible, function(value)
    Settings.Aimbot.SnapLineVisible = value
end, 15)

local targetPartDropdown, selectedPart = CreateDropdown("Target Part", {"Head", "Torso", "HumanoidRootPart"}, Settings.Aimbot.TargetPart, function(option)
    Settings.Aimbot.TargetPart = option
end, 16)

-- NEW: Aim Mode Dropdown
local aimModeDropdown, selectedAimMode = CreateDropdown("Aim Mode", {"Camera", "Mouse"}, Settings.Aimbot.AimMode, function(option)
    Settings.Aimbot.AimMode = option
    
    -- Update the method indicator when aim mode is changed
    AimMethodIndicator.Text = "Aim Method: " .. option
    
    -- Change colors based on selected method
    if option == "Camera" then
        AimMethodIndicator.Color = Color3.fromRGB(255, 0, 0) -- Red for camera
        ActiveAimbotIndicator.Color = Color3.fromRGB(155, 0, 0) -- Dimmed red when inactive
        ActiveAimbotIndicator.Text = "Camera Aimbot: OFF"
    else
        AimMethodIndicator.Color = Color3.fromRGB(0, 255, 255) -- Cyan for mouse
        MouseAimbotIndicator.Color = Color3.fromRGB(0, 155, 155) -- Dimmed cyan when inactive
        MouseAimbotIndicator.Text = "Mouse Aimbot: OFF"
    end
end, 17)

-- NEW: Mouse Aimbot Section
local mouseAimbotHeader = CreateHeader("Mouse Aimbot Settings", 18)

local mouseAimbotToggle = CreateToggle("Mouse Aimbot Enabled", Settings.MouseAimbot.Enabled, function(value)
    Settings.MouseAimbot.Enabled = value
end, 19)

local mouseTeamCheckToggle = CreateToggle("Team Check", Settings.MouseAimbot.TeamCheck, function(value)
    Settings.MouseAimbot.TeamCheck = value
end, 20)

local mouseSmoothSlider = CreateSlider("Smoothness", 0.01, 1, Settings.MouseAimbot.Smoothness, function(value)
    Settings.MouseAimbot.Smoothness = value
end, 21)

local mouseFOVSlider = CreateSlider("FOV", 10, 800, Settings.MouseAimbot.FOV, function(value)
    Settings.MouseAimbot.FOV = value
    MouseFOVCircle.Radius = value
end, 22)

local mouseShowFOVToggle = CreateToggle("Show Mouse FOV Circle", true, function(value)
    MouseFOVCircle.Visible = value
end, 23)

local precisionHeadToggle = CreateToggle("Precise Head Targeting", Settings.MouseAimbot.HeadPrecision, function(value)
    Settings.MouseAimbot.HeadPrecision = value
end, 24)

local verticalOffsetSlider = CreateSlider("Vertical Offset", -10, 10, Settings.MouseAimbot.OffsetY, function(value)
    Settings.MouseAimbot.OffsetY = value
end, 25)

local horizontalOffsetSlider = CreateSlider("Horizontal Offset", -10, 10, Settings.MouseAimbot.OffsetX, function(value)
    Settings.MouseAimbot.OffsetX = value
end, 26)

-- Function to get closest enemy player to the mouse cursor
local function GetClosestPlayerToMouse(fov)
    local closestPlayer = nil
    local shortestDistance = fov or math.huge

    local mouse = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            -- Team check
            if (Settings.MouseAimbot.TeamCheck and CanDamagePlayer(player)) or not Settings.MouseAimbot.TeamCheck then
                local character = player.Character
                if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                    local targetPart = character:FindFirstChild(Settings.Aimbot.TargetPart)
                    if targetPart then
                        local pos, onScreen = Camera:WorldToScreenPoint(targetPart.Position)
                        if onScreen then
                            local distance = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                            if distance < shortestDistance then
                                closestPlayer = player
                                shortestDistance = distance
                            end
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer, shortestDistance
end

-- Function to get closest enemy player to the camera
local function GetClosestPlayerToCamera(fov)
    local closestPlayer = nil
    local shortestDistance = fov or math.huge
    local mouse = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            -- Team check
            if (Settings.Aimbot.TeamCheck and CanDamagePlayer(player)) or not Settings.Aimbot.TeamCheck then
                local character = player.Character
                if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                    local targetPart = character:FindFirstChild(Settings.Aimbot.TargetPart)
                    if targetPart then
                        local pos, onScreen = Camera:WorldToScreenPoint(targetPart.Position)
                        if onScreen then
                            local distance = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                            if distance < shortestDistance then
                                closestPlayer = player
                                shortestDistance = distance
                            end
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer, shortestDistance
end

-- NEW: Helper function to move the mouse cursor to a target position
local function MoveMouse(targetPosition, smoothness)
    local currentPosition = UserInputService:GetMouseLocation()
    local newPosition = currentPosition:Lerp(targetPosition, 1 - smoothness)
    
    -- Use mousemoveabs if available (preferred method)
    if mousemoveabs then
        mousemoveabs(newPosition.X, newPosition.Y)
    else
        -- Fallback to mouse movement delta if absolute positioning isn't available
        local delta = newPosition - currentPosition
        if mousemoverel then
            mousemoverel(delta.X, delta.Y)
        end
    end
    
    return newPosition
end

-- Update aim method display
local function UpdateAimMethodDisplay()
    if Settings.Aimbot.AimMode == "Camera" then
        AimMethodIndicator.Text = "Aim Method: Camera"
        AimMethodIndicator.Color = Color3.fromRGB(255, 0, 0)
    else
        AimMethodIndicator.Text = "Aim Method: Mouse"
        AimMethodIndicator.Color = Color3.fromRGB(0, 255, 255)
    end
end

-- Update FOV circles
RunService.RenderStepped:Connect(function()
    -- Update FOV circles position
    local mousePos = UserInputService:GetMouseLocation()
    FOVCircle.Position = mousePos
    FOVCircle.Visible = Settings.Aimbot.ShowFOV and Settings.Aimbot.Enabled
    FOVCircle.Radius = Settings.Aimbot.FOV
    
    -- Update Mouse FOV circle
    MouseFOVCircle.Position = mousePos
    MouseFOVCircle.Visible = MouseFOVCircle.Visible and Settings.MouseAimbot.Enabled
    MouseFOVCircle.Radius = Settings.MouseAimbot.FOV
end)

-- Process aimbot targeting
RunService.RenderStepped:Connect(function()
    -- Camera-based aimbot
    if Settings.Aimbot.Enabled then
        local player, distance = GetClosestPlayerToCamera(Settings.Aimbot.FOV)
        
        if player then
            local character = player.Character
            if character then
                local targetPart = character:FindFirstChild(Settings.Aimbot.TargetPart)
                if targetPart then
                    -- Get screen position of target - aim directly at center of head
                    local headCenterPos = targetPart.Position
                    local pos, onScreen = Camera:WorldToScreenPoint(headCenterPos)
                    
                    if onScreen then
                        -- Always update aimbot snap line regardless of active state
                        local mousePosition = UserInputService:GetMouseLocation()
                        AimbotSnapLine.From = Vector2.new(mousePosition.X, mousePosition.Y)
                        AimbotSnapLine.To = Vector2.new(pos.X, pos.Y)
                        AimbotSnapLine.Visible = true
                        
                        -- Only do aiming if active
                        if Settings.Aimbot.Active then
                            if Settings.Aimbot.AimMode == "Camera" then
                            -- Camera-based aiming
                            local targetPosition = targetPart.Position
                            
                            -- Apply precision factor
                            local currentCameraPosition = Camera.CFrame.Position
                            local aimDirection = (targetPosition - currentCameraPosition).Unit
                            local precision = Settings.Aimbot.PrecisionFactor
                            
                            -- Create a slightly offset target position based on precision
                            local randomOffset = Vector3.new(
                                (math.random() - 0.5) * (1 - precision) * 2,
                                (math.random() - 0.5) * (1 - precision) * 2,
                                (math.random() - 0.5) * (1 - precision) * 2
                            )
                            
                            local adjustedTargetPosition = targetPosition + randomOffset
                            
                            -- Calculate the target rotation
                            local targetCFrame = CFrame.lookAt(currentCameraPosition, adjustedTargetPosition)
                            
                            -- Apply smoothing
                            local smoothness = Settings.Aimbot.Smoothness
                            local currentRotation = Camera.CFrame - Camera.CFrame.Position
                            local targetRotation = targetCFrame - targetCFrame.Position
                            
                            local smoothedRotation = currentRotation:Lerp(targetRotation, 1 - smoothness)
                            Camera.CFrame = CFrame.new(currentCameraPosition) * smoothedRotation
                        elseif Settings.Aimbot.AimMode == "Mouse" then
                            -- Use camera aimbot settings for mouse movement
                            local mousePosition = UserInputService:GetMouseLocation()
                            local targetVector = Vector2.new(pos.X, pos.Y)
                            
                            -- Apply smoothing to mouse movement
                            MoveMouse(targetVector, Settings.Aimbot.Smoothness)
                        end
                    else
                        AimbotSnapLine.Visible = false
                    end
                end
            end
        else
            AimbotSnapLine.Visible = false
        end
    else
        AimbotSnapLine.Visible = false
    end
    
    -- NEW: Mouse-based aimbot (separately implemented for precision)
    if Settings.MouseAimbot.Enabled then
        local player, distance = GetClosestPlayerToMouse(Settings.MouseAimbot.FOV)
        
        if player then
            local character = player.Character
            if character then
                local targetPart = character:FindFirstChild(Settings.Aimbot.TargetPart)
                if targetPart then
                    -- Always aim at center of the head
                    local headCenterPos = targetPart.Position
                    local pos, onScreen = Camera:WorldToScreenPoint(headCenterPos)
                    
                    if onScreen then
                        -- Apply precision head targeting if enabled
                        if Settings.MouseAimbot.HeadPrecision and Settings.Aimbot.TargetPart == "Head" then
                            -- Apply custom offsets for more precise head targeting
                            pos = Vector3.new(
                                pos.X + Settings.MouseAimbot.OffsetX,
                                pos.Y + Settings.MouseAimbot.OffsetY, 
                                pos.Z
                            )
                        end
                        
                        -- Always show mouse aimbot snap line regardless of active state
                        local mousePosition = UserInputService:GetMouseLocation()
                        MouseAimbotSnapLine.From = Vector2.new(mousePosition.X, mousePosition.Y)
                        MouseAimbotSnapLine.To = Vector2.new(pos.X, pos.Y)
                        MouseAimbotSnapLine.Visible = Settings.MouseAimbot.SnapLineVisible
                        
                        -- Only move mouse if active
                        if Settings.MouseAimbot.Active then
                            -- Move mouse with higher precision
                            local targetVector = Vector2.new(pos.X, pos.Y)
                            MoveMouse(targetVector, Settings.MouseAimbot.Smoothness)
                        end
                    else
                        MouseAimbotSnapLine.Visible = false
                    end
                end
            end
        else
            MouseAimbotSnapLine.Visible = false
        end
    else
        MouseAimbotSnapLine.Visible = false
    end
end
end)

-- Handle aimbot activation
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then  -- Right mouse button
        Settings.Aimbot.Active = true
        -- Update camera aimbot indicator when active
        CameraAimbotIndicator.Text = "Camera Aimbot: ON"
        CameraAimbotIndicator.Color = Color3.fromRGB(255, 0, 0) -- Bright red when active
    end
    
    -- Use separate key for mouse-based aimbot (Shift key)
    if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
        Settings.MouseAimbot.Active = true
        -- Update mouse aimbot indicator when active
        MouseAimbotIndicator.Text = "Mouse Aimbot: ON"
        MouseAimbotIndicator.Color = Color3.fromRGB(0, 255, 255) -- Bright cyan when active
    end
    
    -- Toggle aim mode with a key (M key)
    if input.KeyCode == Enum.KeyCode.M then
        Settings.Aimbot.AimMode = (Settings.Aimbot.AimMode == "Camera") and "Mouse" or "Camera"
        UpdateAimMethodDisplay()
        
        -- Notify of mode change
        Notify("Switched to " .. Settings.Aimbot.AimMode .. " aiming mode", 2)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then  -- Right mouse button
        Settings.Aimbot.Active = false
        -- Update camera aimbot indicator when inactive
        CameraAimbotIndicator.Text = "Camera Aimbot: OFF"
        CameraAimbotIndicator.Color = Color3.fromRGB(155, 0, 0) -- Dimmer red when inactive
        -- Don't hide snap line, keep it visible at all times
    end
    
    -- Release mouse-based aimbot
    if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
        Settings.MouseAimbot.Active = false
        -- Update mouse aimbot indicator when inactive
        MouseAimbotIndicator.Text = "Mouse Aimbot: OFF"
        MouseAimbotIndicator.Color = Color3.fromRGB(0, 155, 155) -- Dimmer cyan when inactive
        -- Don't hide snap line, keep it visible at all times
    end
end)

-- Notification when script is loaded
local function Notify(text, duration)
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.new(0, 300, 0, 50)
    notification.Position = UDim2.new(0.5, -150, 0, -60)
    notification.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    notification.BorderSizePixel = 0
    notification.Parent = DropShadowHolder
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = notification
    
    local message = Instance.new("TextLabel")
    message.Name = "Message"
    message.Size = UDim2.new(1, -20, 1, 0)
    message.Position = UDim2.new(0, 10, 0, 0)
    message.BackgroundTransparency = 1
    message.TextColor3 = Color3.fromRGB(255, 0, 255)
    message.TextSize = 16
    message.Font = Enum.Font.SourceSans
    message.Text = text
    message.Parent = notification
    
    -- Animate notification in
    notification:TweenPosition(UDim2.new(0.5, -150, 0, 20), "Out", "Quad", 0.5, true)
    
    -- Remove after duration
    task.delay(duration, function()
        notification:TweenPosition(UDim2.new(0.5, -150, 0, -60), "In", "Quad", 0.5, true, function()
            notification:Destroy()
        end)
    end)
end

-- Add ESP system
-- Draw empty tables for ESP elements
Settings.ESP.Boxes = {}
Settings.ESP.Names = {}
Settings.ESP.Distances = {}
Settings.ESP.HealthBars = {}
Settings.ESP.Tracers = {}

-- Function to create ESP elements for a player
local function CreatePlayerESP(player)
    -- Create box
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Settings.ESP.BoxColor
    box.Thickness = 1
    box.Transparency = 1
    box.Filled = false
    
    -- Create name text
    local name = Drawing.new("Text")
    name.Visible = false
    name.Color = Settings.ESP.BoxColor
    name.Size = 14
    name.Center = true
    name.Outline = true
    
    -- Create distance text
    local distance = Drawing.new("Text")
    distance.Visible = false
    distance.Color = Settings.ESP.BoxColor
    distance.Size = 12
    distance.Center = true
    distance.Outline = true
    
    -- Create health bar outline
    local healthOutline = Drawing.new("Square")
    healthOutline.Visible = false
    healthOutline.Color = Color3.fromRGB(0, 0, 0)
    healthOutline.Thickness = 1
    healthOutline.Transparency = 1
    healthOutline.Filled = false
    
    -- Create health bar fill
    local healthBar = Drawing.new("Square")
    healthBar.Visible = false
    healthBar.Color = Color3.fromRGB(0, 255, 0)
    healthBar.Thickness = 1
    healthBar.Transparency = 1
    healthBar.Filled = true
    
    -- Create tracer
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = Settings.ESP.BoxColor
    tracer.Thickness = 1
    tracer.Transparency = 1
    
    -- Store elements
    Settings.ESP.Boxes[player] = box
    Settings.ESP.Names[player] = name
    Settings.ESP.Distances[player] = distance
    Settings.ESP.HealthBars[player] = {outline = healthOutline, fill = healthBar}
    Settings.ESP.Tracers[player] = tracer
end

-- Function to update ESP for all players
local function UpdateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            -- Create ESP elements if they don't exist
            if not Settings.ESP.Boxes[player] then
                CreatePlayerESP(player)
            end
            
            -- Only show ESP if enabled
            if Settings.ESP.Enabled then
                -- Check if player should be shown based on team check
                local character = player.Character
                local shouldShowESP = true
                
                -- If not using CanDamagePlayer function directly, we can check if they're on a different team
                if Settings.ESP.TeamCheck then
                    shouldShowESP = CanDamagePlayer(player)
                end
                
                if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 and shouldShowESP then
                    local humanoid = character.Humanoid
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    local head = character:FindFirstChild("Head")
                    
                    if rootPart and head then
                        local rootPos, rootOnScreen = Camera:WorldToScreenPoint(rootPart.Position)
                        local headPos = Camera:WorldToScreenPoint(head.Position)
                        
                        if rootOnScreen then
                            -- Calculate box dimensions
                            local boxSize = Vector2.new(1000 / rootPos.Z, headPos.Y - rootPos.Y)
                            local boxPosition = Vector2.new(rootPos.X - boxSize.X / 2, rootPos.Y - boxSize.Y / 2)
                            
                            -- Update box
                            local box = Settings.ESP.Boxes[player]
                            box.Size = boxSize
                            box.Position = boxPosition
                            box.Visible = Settings.ESP.Boxes
                            
                            -- Update name text
                            local name = Settings.ESP.Names[player]
                            name.Text = player.Name
                            name.Position = Vector2.new(rootPos.X, boxPosition.Y - 15)
                            name.Visible = Settings.ESP.Names
                            
                            -- Update distance text
                            local dist = Settings.ESP.Distances[player]
                            local distance = math.floor((Camera.CFrame.Position - rootPart.Position).Magnitude)
                            dist.Text = tostring(distance) .. "m"
                            dist.Position = Vector2.new(rootPos.X, boxPosition.Y + boxSize.Y + 5)
                            dist.Visible = Settings.ESP.Distance
                            
                            -- Update health bar
                            local healthBars = Settings.ESP.HealthBars[player]
                            local healthOutline = healthBars.outline
                            local healthBar = healthBars.fill
                            
                            healthOutline.Size = Vector2.new(5, boxSize.Y)
                            healthOutline.Position = Vector2.new(boxPosition.X - 7, boxPosition.Y)
                            healthOutline.Visible = Settings.ESP.Health
                            
                            local healthPercent = humanoid.Health / humanoid.MaxHealth
                            healthBar.Size = Vector2.new(3, boxSize.Y * healthPercent)
                            healthBar.Position = Vector2.new(boxPosition.X - 6, boxPosition.Y + boxSize.Y * (1 - healthPercent))
                            healthBar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                            healthBar.Visible = Settings.ESP.Health
                            
                            -- Update tracer
                            local tracer = Settings.ESP.Tracers[player]
                            tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                            tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                            tracer.Visible = Settings.ESP.Snaplines
                            
                            -- Apply rainbow color if enabled
                            if Settings.ESP.Rainbow then
                                local hue = tick() % 5 / 5
                                local color = Color3.fromHSV(hue, 1, 1)
                                
                                box.Color = color
                                name.Color = color
                                dist.Color = color
                                tracer.Color = color
                            else
                                box.Color = Settings.ESP.BoxColor
                                name.Color = Settings.ESP.BoxColor
                                dist.Color = Settings.ESP.BoxColor
                                tracer.Color = Settings.ESP.BoxColor
                            end
                        else
                            -- Hide ESP if off screen
                            Settings.ESP.Boxes[player].Visible = false
                            Settings.ESP.Names[player].Visible = false
                            Settings.ESP.Distances[player].Visible = false
                            Settings.ESP.HealthBars[player].outline.Visible = false
                            Settings.ESP.HealthBars[player].fill.Visible = false
                            Settings.ESP.Tracers[player].Visible = false
                        end
                    else
                        -- Hide ESP if no root part or head
                        Settings.ESP.Boxes[player].Visible = false
                        Settings.ESP.Names[player].Visible = false
                        Settings.ESP.Distances[player].Visible = false
                        Settings.ESP.HealthBars[player].outline.Visible = false
                        Settings.ESP.HealthBars[player].fill.Visible = false
                        Settings.ESP.Tracers[player].Visible = false
                    end
                else
                    -- Hide ESP if player is not valid
                    Settings.ESP.Boxes[player].Visible = false
                    Settings.ESP.Names[player].Visible = false
                    Settings.ESP.Distances[player].Visible = false
                    Settings.ESP.HealthBars[player].outline.Visible = false
                    Settings.ESP.HealthBars[player].fill.Visible = false
                    Settings.ESP.Tracers[player].Visible = false
                end
            else
                -- Hide ESP if disabled
                Settings.ESP.Boxes[player].Visible = false
                Settings.ESP.Names[player].Visible = false
                Settings.ESP.Distances[player].Visible = false
                Settings.ESP.HealthBars[player].outline.Visible = false
                Settings.ESP.HealthBars[player].fill.Visible = false
                Settings.ESP.Tracers[player].Visible = false
            end
        end
    end
end

-- Clean up ESP elements when player leaves
Players.PlayerRemoving:Connect(function(player)
    if Settings.ESP.Boxes[player] then
        Settings.ESP.Boxes[player]:Remove()
        Settings.ESP.Names[player]:Remove()
        Settings.ESP.Distances[player]:Remove()
        Settings.ESP.HealthBars[player].outline:Remove()
        Settings.ESP.HealthBars[player].fill:Remove()
        Settings.ESP.Tracers[player]:Remove()
        
        Settings.ESP.Boxes[player] = nil
        Settings.ESP.Names[player] = nil
        Settings.ESP.Distances[player] = nil
        Settings.ESP.HealthBars[player] = nil
        Settings.ESP.Tracers[player] = nil
    end
end)

-- Update ESP on RenderStepped
RunService.RenderStepped:Connect(UpdateESP)

-- Initial setup
UpdateAimMethodDisplay()

-- Notify on load
Notify("Enhanced Aimbot Loaded! Press Shift for mouse aimbot, M to toggle aim mode", 5)

-- Print controls to console for reference
print("=== Enhanced Aimbot Controls ===")
print("Right Mouse Button: Activate regular aimbot")
print("Shift Key: Activate mouse precision aimbot")
print("M Key: Toggle between Camera and Mouse aim modes")
print("===========================")
