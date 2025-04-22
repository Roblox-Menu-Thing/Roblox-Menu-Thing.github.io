-- This is a Roblox-specific script and will only run properly in Roblox environment
-- The UI has been enhanced to use a tabbed interface for better organization

-- Services
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

---------------------------
-- ENHANCED TABBED UI
---------------------------

-- Create panel with increased width for a more spacious layout
local Panel = Instance.new("Frame")
Panel.Name = "MainPanel"
Panel.Size = UDim2.new(0, 500, 0, 500) -- Increased width to 500 (was 450)
Panel.Position = UDim2.new(1, -510, 0.5, -250) -- Adjusted position for wider panel
Panel.BackgroundColor3 = Color3.fromRGB(10, 10, 15) -- Darker black background
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

-- Title bar (slightly taller to accommodate tabs below it)
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
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255) -- Changed to white
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

-- NEW: Left sidebar tab container (wider for icon-only tabs)
local TabBar = Instance.new("Frame")
TabBar.Name = "TabBar"
TabBar.Size = UDim2.new(0, 70, 1, -40) -- Vertical tabs bar on left side (50 wider than before)
TabBar.Position = UDim2.new(0, 0, 0, 40) -- Position below title bar
TabBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20) -- Dark black color
TabBar.BorderSizePixel = 0
TabBar.Parent = Panel

-- Tab button container for organization
local TabContainer = Instance.new("Frame")
TabContainer.Name = "TabContainer"
TabContainer.Size = UDim2.new(1, -10, 1, -10)
TabContainer.Position = UDim2.new(0, 5, 0, 5)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = TabBar

-- Add UIListLayout for tab buttons (now vertical)
local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Vertical -- Changed to vertical
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLayout.VerticalAlignment = Enum.VerticalAlignment.Top
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Padding = UDim.new(0, 10) -- More padding between vertical tabs
TabLayout.Parent = TabContainer

-- Content area for tab panels (adjusted for side tabs)
local ContentArea = Instance.new("Frame")
local ContentSize = UDim2.new(1, -80, 1, -50) -- Adjust for narrower left tab bar
local ContentPosition = UDim2.new(0, 75, 0, 45) -- Position right of tab bar

ContentArea.Name = "ContentArea"
ContentArea.Size = ContentSize
ContentArea.Position = ContentPosition
ContentArea.BackgroundTransparency = 1
ContentArea.ClipsDescendants = true
ContentArea.Parent = Panel

-- Create tab content frames (these will contain the settings for each tab)
local TabContents = {}
local Tabs = {"ESP", "Camera Aimbot", "Mouse Aimbot", "Settings"}

-- Map of TabName -> List of settings belonging to that tab
local SettingsMap = {
    ["ESP"] = {
        "ESP.Enabled", "ESP.Boxes", "ESP.Names", "ESP.Distance", 
        "ESP.Health", "ESP.Snaplines", "ESP.TeamCheck", "ESP.Rainbow", 
        "ESP.BoxColor"
    },
    ["Camera Aimbot"] = {
        "Aimbot.Enabled", "Aimbot.TeamCheck", "Aimbot.Smoothness", "Aimbot.FOV",
        "Aimbot.TargetPart", "Aimbot.ShowFOV", "Aimbot.SnapLineVisible", 
        "Aimbot.AimAtSnapLine", "Aimbot.PrecisionFactor", "Aimbot.AimMode"
    },
    ["Mouse Aimbot"] = {
        "MouseAimbot.Enabled", "MouseAimbot.TeamCheck", "MouseAimbot.Smoothness", 
        "MouseAimbot.FOV", "MouseAimbot.TargetPart", "MouseAimbot.PrecisionFactor", 
        "MouseAimbot.HeadPrecision", "MouseAimbot.OffsetY", "MouseAimbot.OffsetX", 
        "MouseAimbot.SnapLineVisible"
    },
    ["Settings"] = {
        -- General settings that didn't fit in other categories
        -- You can add more as needed
    }
}

-- Function to create a tab button with just an icon (no text)
local function CreateTabButton(name, index)
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name .. "Button"
    tabButton.Size = UDim2.new(0, 60, 0, 60) -- Square icon buttons
    tabButton.BackgroundColor3 = Color3.fromRGB(20, 20, 25) -- Darker background
    tabButton.TextColor3 = Color3.fromRGB(0, 0, 0) -- Hide text
    tabButton.TextSize = 0
    tabButton.TextTransparency = 1
    tabButton.Font = Enum.Font.SourceSansBold
    tabButton.Text = ""
    tabButton.LayoutOrder = index
    tabButton.BorderSizePixel = 0
    tabButton.AutoButtonColor = false
    tabButton.Parent = TabContainer
    
    -- Add rounded corners to tab buttons
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = tabButton
    
    -- Create icon for the tab (placeholder for Roblox asset ID)
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 35, 0, 35)
    icon.Position = UDim2.new(0.5, -17.5, 0.5, -17.5) -- Center icon
    icon.BackgroundTransparency = 1
    icon.ImageColor3 = Color3.fromRGB(255, 255, 255) -- White icon color
    icon.Image = "rbxassetid://0" -- Placeholder ID, user will replace
    
    -- Different image IDs for each tab (placeholders)
    if name == "ESP" then
        icon.Image = "rbxassetid://4034483344" -- Example placeholder
    elseif name == "Camera Aimbot" then
        icon.Image = "rbxassetid://4034483344" -- Example placeholder
    elseif name == "Mouse Aimbot" then
        icon.Image = "rbxassetid://4034483344" -- Example placeholder
    elseif name == "Settings" then
        icon.Image = "rbxassetid://4034483344" -- Example placeholder
    end
    
    icon.Parent = tabButton
    
    return tabButton
end

-- Create tab content frames and buttons
for i, tabName in ipairs(Tabs) do
    -- Create content frame for this tab
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = tabName .. "Content"
    contentFrame.Size = UDim2.new(1, 0, 1, 0)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.ScrollBarThickness = 4
    contentFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 0, 255)
    contentFrame.Visible = i == 1 -- First tab visible by default
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 500) -- Will be updated based on content
    contentFrame.Parent = ContentArea
    
    -- Add UI layout for content
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = contentFrame
    
    -- Store reference to content frame
    TabContents[tabName] = contentFrame
    
    -- Create tab button
    local button = CreateTabButton(tabName, i)
    
    -- Set active appearance for first tab
    if i == 1 then
        button.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- White active color
        local iconObject = button:FindFirstChild("Icon")
        if iconObject then
            iconObject.ImageColor3 = Color3.fromRGB(0, 0, 0) -- Black icon when active
        end
    end
    
    -- Button click handler
    button.MouseButton1Click:Connect(function()
        -- Hide all content frames
        for _, content in pairs(TabContents) do
            content.Visible = false
        end
        
        -- Reset all button appearances
        for _, child in pairs(TabContainer:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = Color3.fromRGB(20, 20, 25) -- Dark background
                local childIcon = child:FindFirstChild("Icon")
                if childIcon then
                    childIcon.ImageColor3 = Color3.fromRGB(255, 255, 255) -- White icon color
                end
            end
        end
        
        -- Show this tab's content
        contentFrame.Visible = true
        
        -- Set active appearance
        button.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- White active background
        local iconObject = button:FindFirstChild("Icon")
        if iconObject then
            iconObject.ImageColor3 = Color3.fromRGB(0, 0, 0) -- Black icon when active
        end
    end)
    
    -- Button hover effects
    button.MouseEnter:Connect(function()
        if not contentFrame.Visible then  -- Only apply hover effect to inactive tabs
            button.BackgroundColor3 = Color3.fromRGB(30, 30, 35) -- Slightly lighter on hover
        end
    end)
    
    button.MouseLeave:Connect(function()
        if not contentFrame.Visible then  -- Only reset inactive tabs
            button.BackgroundColor3 = Color3.fromRGB(20, 20, 25) -- Back to dark background
        end
    end)
end

-- Function to create a section header (same as before but can go in any tab)
local function CreateHeader(tabName, text, order)
    local header = Instance.new("TextLabel")
    header.Name = text .. "Header"
    header.Size = UDim2.new(1, 0, 0, 30)
    header.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    header.BorderSizePixel = 0
    header.Text = text
    header.TextColor3 = Color3.fromRGB(255, 255, 255)
    header.TextSize = 16
    header.Font = Enum.Font.SourceSansBold
    header.LayoutOrder = order
    
    -- Add rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = header
    
    header.Parent = TabContents[tabName]
    return header
end

-- Function to create a toggle button (same as before but can go in any tab)
local function CreateToggle(tabName, name, initialState, callback, order)
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
    button.BackgroundColor3 = initialState and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(30, 30, 35)
    button.BorderSizePixel = 0
    button.Parent = toggleFrame
    
    -- Add rounded corners to button
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 10)
    buttonCorner.Parent = button
    
    -- Toggle indicator
    local indicator = Instance.new("Frame")
    indicator.Name = "Indicator"
    indicator.Size = UDim2.new(0, 16, 0, 16)
    indicator.Position = initialState and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    indicator.BorderSizePixel = 0
    indicator.Parent = button
    
    -- Add rounded corners to indicator
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(0, 8)
    indicatorCorner.Parent = indicator
    
    -- Click handler for the toggle
    local toggled = initialState
    toggleFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggled = not toggled
            
            -- Update visual state
            button.BackgroundColor3 = toggled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(30, 30, 35)
            
            -- Animate indicator position
            local targetPosition = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            local tween = TweenService:Create(indicator, TweenInfo.new(0.2), {Position = targetPosition})
            tween:Play()
            
            -- Call the callback function
            if callback then
                callback(toggled)
            end
        end
    end)
    
    toggleFrame.Parent = TabContents[tabName]
    return toggleFrame, toggled
end

-- Function to create a slider (same as before but can go in any tab)
local function CreateSlider(tabName, name, min, max, initialValue, decimals, callback, order)
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
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 14
    label.Font = Enum.Font.SourceSans
    label.Text = name
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = sliderFrame
    
    -- Value display
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "Value"
    valueLabel.Size = UDim2.new(0, 40, 0, 20)
    valueLabel.Position = UDim2.new(1, -50, 0, 5)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueLabel.TextSize = 14
    valueLabel.Font = Enum.Font.SourceSansBold
    valueLabel.Text = tostring(initialValue)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = sliderFrame
    
    -- Slider background
    local sliderBg = Instance.new("Frame")
    sliderBg.Name = "SliderBg"
    sliderBg.Size = UDim2.new(1, -20, 0, 6)
    sliderBg.Position = UDim2.new(0, 10, 0, 35)
    sliderBg.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = sliderFrame
    
    -- Add rounded corners to slider background
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 3)
    sliderCorner.Parent = sliderBg
    
    -- Slider fill
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "SliderFill"
    local fillPercent = (initialValue - min) / (max - min)
    sliderFill.Size = UDim2.new(fillPercent, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg
    
    -- Add rounded corners to slider fill
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = sliderFill
    
    -- Slider knob
    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new(fillPercent, -6, 0.5, -6)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 2
    knob.Parent = sliderBg
    
    -- Add rounded corners to knob
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0) -- Fully rounded (circle)
    knobCorner.Parent = knob
    
    -- Slider functionality
    local dragging = false
    local currentValue = initialValue
    
    -- Helper function to update slider
    local function updateSlider(input)
        -- Calculate the position based on mouse/touch
        local sliderPosition = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        
        -- Calculate the actual value
        local newValue = min + (sliderPosition * (max - min))
        
        -- Round to specified decimal places
        if decimals then
            local factor = 10 ^ decimals
            newValue = math.floor(newValue * factor + 0.5) / factor
        else
            newValue = math.floor(newValue + 0.5)
        end
        
        -- Clamp the value
        newValue = math.clamp(newValue, min, max)
        
        -- Only update if the value has changed
        if newValue ~= currentValue then
            currentValue = newValue
            
            -- Update the visual elements
            sliderFill.Size = UDim2.new(sliderPosition, 0, 1, 0)
            knob.Position = UDim2.new(sliderPosition, -6, 0.5, -6)
            valueLabel.Text = tostring(currentValue)
            
            -- Call the callback
            if callback then
                callback(currentValue)
            end
        end
    end
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateSlider(input)
        end
    end)
    
    sliderBg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)
    
    sliderFrame.Parent = TabContents[tabName]
    return sliderFrame, currentValue
end

-- Function to create a dropdown (for target part selection)
local function CreateDropdown(tabName, name, options, initialSelection, callback, order)
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Name = name .. "Dropdown"
    dropdownFrame.Size = UDim2.new(1, 0, 0, 60) -- Height will be adjusted based on expanded state
    dropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    dropdownFrame.BorderSizePixel = 0
    dropdownFrame.ClipsDescendants = true -- Important for dropdown animation
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
    
    -- Selected value button
    local selectedButton = Instance.new("TextButton")
    selectedButton.Name = "SelectedButton"
    selectedButton.Size = UDim2.new(1, -20, 0, 25)
    selectedButton.Position = UDim2.new(0, 10, 0, 30)
    selectedButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    selectedButton.TextColor3 = Color3.fromRGB(180, 180, 180)
    selectedButton.TextSize = 14
    selectedButton.Font = Enum.Font.SourceSans
    selectedButton.Text = initialSelection or "Select"
    selectedButton.TextXAlignment = Enum.TextXAlignment.Left
    selectedButton.BorderSizePixel = 0
    selectedButton.AutoButtonColor = false
    selectedButton.Parent = dropdownFrame
    
    -- Add rounded corners to selected button
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = selectedButton
    
    -- Dropdown arrow
    local dropdownArrow = Instance.new("TextLabel")
    dropdownArrow.Name = "Arrow"
    dropdownArrow.Size = UDim2.new(0, 25, 0, 25)
    dropdownArrow.Position = UDim2.new(1, -25, 0, 0)
    dropdownArrow.BackgroundTransparency = 1
    dropdownArrow.TextColor3 = Color3.fromRGB(180, 180, 180)
    dropdownArrow.TextSize = 14
    dropdownArrow.Font = Enum.Font.SourceSansBold
    dropdownArrow.Text = "▼"
    dropdownArrow.Parent = selectedButton
    
    -- Options container
    local optionsContainer = Instance.new("Frame")
    optionsContainer.Name = "OptionsContainer"
    optionsContainer.Size = UDim2.new(1, -20, 0, #options * 25) -- Height based on number of options
    optionsContainer.Position = UDim2.new(0, 10, 0, 60)
    optionsContainer.BackgroundTransparency = 1
    optionsContainer.Visible = false
    optionsContainer.Parent = dropdownFrame
    
    -- Create option buttons
    for i, option in ipairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Name = option .. "Option"
        optionButton.Size = UDim2.new(1, 0, 0, 25)
        optionButton.Position = UDim2.new(0, 0, 0, (i-1) * 25)
        optionButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        optionButton.TextColor3 = Color3.fromRGB(180, 180, 180)
        optionButton.TextSize = 14
        optionButton.Font = Enum.Font.SourceSans
        optionButton.Text = option
        optionButton.TextXAlignment = Enum.TextXAlignment.Left
        optionButton.BorderSizePixel = 0
        optionButton.AutoButtonColor = false
        
        -- Add padding to text
        local textPadding = Instance.new("UIPadding")
        textPadding.PaddingLeft = UDim.new(0, 5)
        textPadding.Parent = optionButton
        
        -- Highlight selected option
        if option == initialSelection then
            optionButton.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
            optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
        
        -- Option button behavior
        optionButton.MouseEnter:Connect(function()
            if option ~= selectedButton.Text then
                optionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            end
        end)
        
        optionButton.MouseLeave:Connect(function()
            if option ~= selectedButton.Text then
                optionButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            end
        end)
        
        optionButton.MouseButton1Click:Connect(function()
            -- Update selected value
            selectedButton.Text = option
            
            -- Reset all option colors
            for _, child in pairs(optionsContainer:GetChildren()) do
                if child:IsA("TextButton") then
                    child.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
                    child.TextColor3 = Color3.fromRGB(180, 180, 180)
                end
            end
            
            -- Highlight selected option
            optionButton.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
            optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            
            -- Close dropdown
            optionsContainer.Visible = false
            dropdownFrame.Size = UDim2.new(1, 0, 0, 60)
            dropdownArrow.Text = "▼"
            
            -- Call callback
            if callback then
                callback(option)
            end
        end)
        
        optionButton.Parent = optionsContainer
    end
    
    -- Add rounded corners to all option buttons
    for _, child in pairs(optionsContainer:GetChildren()) do
        if child:IsA("TextButton") then
            local optionCorner = Instance.new("UICorner")
            optionCorner.CornerRadius = UDim.new(0, 4)
            optionCorner.Parent = child
        end
    end
    
    -- Dropdown toggle functionality
    local expanded = false
    
    selectedButton.MouseButton1Click:Connect(function()
        expanded = not expanded
        
        if expanded then
            -- Show options
            optionsContainer.Visible = true
            dropdownFrame.Size = UDim2.new(1, 0, 0, 60 + optionsContainer.Size.Y.Offset)
            dropdownArrow.Text = "▲"
        else
            -- Hide options
            optionsContainer.Visible = false
            dropdownFrame.Size = UDim2.new(1, 0, 0, 60)
            dropdownArrow.Text = "▼"
        end
    end)
    
    dropdownFrame.Parent = TabContents[tabName]
    return dropdownFrame, initialSelection
end

-- Function to create a color picker
local function CreateColorPicker(tabName, name, initialColor, callback, order)
    local pickerFrame = Instance.new("Frame")
    pickerFrame.Name = name .. "ColorPicker"
    pickerFrame.Size = UDim2.new(1, 0, 0, 60)
    pickerFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    pickerFrame.BorderSizePixel = 0
    pickerFrame.LayoutOrder = order
    
    -- Add rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = pickerFrame
    
    -- Picker label
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
    label.Parent = pickerFrame
    
    -- Color preview
    local colorPreview = Instance.new("Frame")
    colorPreview.Name = "ColorPreview"
    colorPreview.Size = UDim2.new(0, 30, 0, 30)
    colorPreview.Position = UDim2.new(0, 10, 0.5, 0)
    colorPreview.BackgroundColor3 = initialColor or Color3.fromRGB(255, 0, 255)
    colorPreview.BorderSizePixel = 0
    colorPreview.Parent = pickerFrame
    
    -- Add rounded corners to color preview
    local previewCorner = Instance.new("UICorner")
    previewCorner.CornerRadius = UDim.new(0, 4)
    previewCorner.Parent = colorPreview
    
    -- Create color sliders (simplified implementation)
    -- In a real implementation, you would create RGB sliders here
    -- For simplicity, we'll just use a button to toggle between preset colors
    
    local colorButton = Instance.new("TextButton")
    colorButton.Name = "ChangeColor"
    colorButton.Size = UDim2.new(0, 120, 0, 30)
    colorButton.Position = UDim2.new(0, 50, 0.5, 0)
    colorButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    colorButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    colorButton.TextSize = 12
    colorButton.Font = Enum.Font.SourceSans
    colorButton.Text = "Change Color"
    colorButton.BorderSizePixel = 0
    colorButton.Parent = pickerFrame
    
    -- Add rounded corners to button
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = colorButton
    
    -- Predefined colors to cycle through
    local colors = {
        Color3.fromRGB(255, 0, 255), -- Magenta
        Color3.fromRGB(255, 0, 0),   -- Red
        Color3.fromRGB(0, 255, 0),   -- Green
        Color3.fromRGB(0, 0, 255),   -- Blue
        Color3.fromRGB(255, 255, 0), -- Yellow
        Color3.fromRGB(0, 255, 255), -- Cyan
        Color3.fromRGB(255, 165, 0), -- Orange
        Color3.fromRGB(128, 0, 128)  -- Purple
    }
    
    local currentColorIndex = 1
    -- Find initial color in the list, or default to first color
    for i, color in ipairs(colors) do
        if color == initialColor then
            currentColorIndex = i
            break
        end
    end
    
    -- Button click handler
    colorButton.MouseButton1Click:Connect(function()
        currentColorIndex = (currentColorIndex % #colors) + 1
        local newColor = colors[currentColorIndex]
        
        -- Update preview
        colorPreview.BackgroundColor3 = newColor
        
        -- Call callback
        if callback then
            callback(newColor)
        end
    end)
    
    pickerFrame.Parent = TabContents[tabName]
    return pickerFrame
end

-- Now let's populate our tabs with the actual ESP and aimbot settings

-- ESP TAB
CreateHeader("ESP", "ESP Settings", 1)

-- ESP Toggles
CreateToggle("ESP", "ESP Enabled", Settings.ESP.Enabled, function(value)
    Settings.ESP.Enabled = value
end, 2)

CreateToggle("ESP", "Show Boxes", Settings.ESP.Boxes, function(value)
    Settings.ESP.Boxes = value
end, 3)

CreateToggle("ESP", "Show Names", Settings.ESP.Names, function(value)
    Settings.ESP.Names = value
end, 4)

CreateToggle("ESP", "Show Distance", Settings.ESP.Distance, function(value)
    Settings.ESP.Distance = value
end, 5)

CreateToggle("ESP", "Show Health", Settings.ESP.Health, function(value)
    Settings.ESP.Health = value
end, 6)

CreateToggle("ESP", "Show Snaplines", Settings.ESP.Snaplines, function(value)
    Settings.ESP.Snaplines = value
end, 7)

CreateToggle("ESP", "Team Check", Settings.ESP.TeamCheck, function(value)
    Settings.ESP.TeamCheck = value
end, 8)

CreateToggle("ESP", "Rainbow Color", Settings.ESP.Rainbow, function(value)
    Settings.ESP.Rainbow = value
end, 9)

-- ESP Color Picker
CreateColorPicker("ESP", "ESP Color", Settings.ESP.BoxColor, function(color)
    Settings.ESP.BoxColor = color
end, 10)

-- CAMERA AIMBOT TAB
CreateHeader("Camera Aimbot", "Camera Aimbot Settings", 1)

CreateToggle("Camera Aimbot", "Camera Aimbot Enabled", Settings.Aimbot.Enabled, function(value)
    Settings.Aimbot.Enabled = value
    CameraAimbotIndicator.Text = "Camera Aimbot: " .. (value and "ON" or "OFF")
    CameraAimbotIndicator.Color = value and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(155, 0, 0)
end, 2)

CreateToggle("Camera Aimbot", "Team Check", Settings.Aimbot.TeamCheck, function(value)
    Settings.Aimbot.TeamCheck = value
end, 3)

CreateSlider("Camera Aimbot", "Smoothness", 0.01, 1, Settings.Aimbot.Smoothness, 2, function(value)
    Settings.Aimbot.Smoothness = value
end, 4)

CreateSlider("Camera Aimbot", "FOV", 10, 500, Settings.Aimbot.FOV, 0, function(value)
    Settings.Aimbot.FOV = value
    FOVCircle.Radius = value
end, 5)

CreateDropdown("Camera Aimbot", "Target Part", {"Head", "Torso", "HumanoidRootPart"}, Settings.Aimbot.TargetPart, function(value)
    Settings.Aimbot.TargetPart = value
end, 6)

CreateToggle("Camera Aimbot", "Show FOV", Settings.Aimbot.ShowFOV, function(value)
    Settings.Aimbot.ShowFOV = value
    FOVCircle.Visible = value
end, 7)

CreateToggle("Camera Aimbot", "Show Snap Line", Settings.Aimbot.SnapLineVisible, function(value)
    Settings.Aimbot.SnapLineVisible = value
end, 8)

CreateToggle("Camera Aimbot", "Aim At Snap Line", Settings.Aimbot.AimAtSnapLine, function(value)
    Settings.Aimbot.AimAtSnapLine = value
end, 9)

CreateSlider("Camera Aimbot", "Precision Factor", 0.5, 1, Settings.Aimbot.PrecisionFactor, 2, function(value)
    Settings.Aimbot.PrecisionFactor = value
end, 10)

CreateDropdown("Camera Aimbot", "Aim Mode", {"Camera", "Mouse"}, Settings.Aimbot.AimMode, function(value)
    Settings.Aimbot.AimMode = value
    AimMethodIndicator.Text = "Aim Method: " .. value
end, 11)

-- MOUSE AIMBOT TAB
CreateHeader("Mouse Aimbot", "Mouse Aimbot Settings", 1)

CreateToggle("Mouse Aimbot", "Mouse Aimbot Enabled", Settings.MouseAimbot.Enabled, function(value)
    Settings.MouseAimbot.Enabled = value
    MouseAimbotIndicator.Text = "Mouse Aimbot: " .. (value and "ON" or "OFF")
    MouseAimbotIndicator.Color = value and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(0, 155, 155)
end, 2)

CreateToggle("Mouse Aimbot", "Team Check", Settings.MouseAimbot.TeamCheck, function(value)
    Settings.MouseAimbot.TeamCheck = value
end, 3)

CreateSlider("Mouse Aimbot", "Smoothness", 0.01, 1, Settings.MouseAimbot.Smoothness, 2, function(value)
    Settings.MouseAimbot.Smoothness = value
end, 4)

CreateSlider("Mouse Aimbot", "FOV", 10, 500, Settings.MouseAimbot.FOV, 0, function(value)
    Settings.MouseAimbot.FOV = value
    MouseFOVCircle.Radius = value
end, 5)

CreateDropdown("Mouse Aimbot", "Target Part", {"Head", "Torso", "HumanoidRootPart"}, Settings.MouseAimbot.TargetPart, function(value)
    Settings.MouseAimbot.TargetPart = value
end, 6)

CreateToggle("Mouse Aimbot", "Head Precision", Settings.MouseAimbot.HeadPrecision, function(value)
    Settings.MouseAimbot.HeadPrecision = value
end, 7)

CreateSlider("Mouse Aimbot", "Horizontal Offset", -10, 10, Settings.MouseAimbot.OffsetX, 1, function(value)
    Settings.MouseAimbot.OffsetX = value
end, 8)

CreateSlider("Mouse Aimbot", "Vertical Offset", -10, 10, Settings.MouseAimbot.OffsetY, 1, function(value)
    Settings.MouseAimbot.OffsetY = value
end, 9)

CreateSlider("Mouse Aimbot", "Precision Factor", 0.5, 1, Settings.MouseAimbot.PrecisionFactor, 3, function(value)
    Settings.MouseAimbot.PrecisionFactor = value
end, 10)

CreateToggle("Mouse Aimbot", "Show Snap Line", Settings.MouseAimbot.SnapLineVisible, function(value)
    Settings.MouseAimbot.SnapLineVisible = value
end, 11)

-- SETTINGS TAB
CreateHeader("Settings", "General Settings", 1)

-- Reset button 
local resetButton = Instance.new("TextButton")
resetButton.Name = "ResetButton"
resetButton.Size = UDim2.new(1, -20, 0, 40)
resetButton.Position = UDim2.new(0, 10, 0, 50)
resetButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
resetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
resetButton.TextSize = 16
resetButton.Font = Enum.Font.SourceSansBold
resetButton.Text = "Reset All Settings"
resetButton.BorderSizePixel = 0
resetButton.LayoutOrder = 2
resetButton.Parent = TabContents["Settings"]

-- Add rounded corners to reset button
local resetCorner = Instance.new("UICorner")
resetCorner.CornerRadius = UDim.new(0, 6)
resetCorner.Parent = resetButton

-- Reset button click handler
resetButton.MouseButton1Click:Connect(function()
    -- Reset all settings to default
    Settings.ESP.Enabled = true
    Settings.ESP.Boxes = true
    Settings.ESP.Names = true
    Settings.ESP.Distance = true
    Settings.ESP.Health = true
    Settings.ESP.Snaplines = true
    Settings.ESP.TeamCheck = false
    Settings.ESP.Rainbow = true
    Settings.ESP.BoxColor = Color3.fromRGB(255, 0, 255)
    
    Settings.Aimbot.Enabled = true
    Settings.Aimbot.TeamCheck = false
    Settings.Aimbot.Smoothness = 0.15
    Settings.Aimbot.FOV = 100
    Settings.Aimbot.TargetPart = "Head"
    Settings.Aimbot.ShowFOV = true
    Settings.Aimbot.SnapLineVisible = true
    Settings.Aimbot.AimAtSnapLine = true
    Settings.Aimbot.PrecisionFactor = 0.99
    Settings.Aimbot.AimMode = "Camera"
    
    Settings.MouseAimbot.Enabled = true
    Settings.MouseAimbot.TeamCheck = false
    Settings.MouseAimbot.Smoothness = 0.1
    Settings.MouseAimbot.FOV = 100
    Settings.MouseAimbot.TargetPart = "Head"
    Settings.MouseAimbot.PrecisionFactor = 0.995
    Settings.MouseAimbot.HeadPrecision = true
    Settings.MouseAimbot.OffsetY = 0
    Settings.MouseAimbot.OffsetX = 0
    Settings.MouseAimbot.SnapLineVisible = true
    
    -- Update UI to reflect changes
    -- Ideally we would update all UI elements here, but for simplicity,
    -- we'll just tell the user to reopen the UI
    resetButton.Text = "Settings Reset! Reopen UI"
    wait(2)
    resetButton.Text = "Reset All Settings"
end)

-- Information section
local infoText = Instance.new("TextLabel")
infoText.Name = "InfoText"
infoText.Size = UDim2.new(1, -20, 0, 100)
infoText.Position = UDim2.new(0, 10, 0, 100)
infoText.BackgroundTransparency = 1
infoText.TextColor3 = Color3.fromRGB(200, 200, 200)
infoText.TextSize = 14
infoText.Font = Enum.Font.SourceSans
infoText.Text = "Hotkeys:\n• Right Mouse Button: Activate Camera Aimbot\n• Left Alt: Toggle Mouse Aimbot\n• F1: Toggle UI Visibility"
infoText.TextXAlignment = Enum.TextXAlignment.Left
infoText.TextYAlignment = Enum.TextYAlignment.Top
infoText.LayoutOrder = 3
infoText.Parent = TabContents["Settings"]

-- Credits section
local creditsText = Instance.new("TextLabel")
creditsText.Name = "CreditsText"
creditsText.Size = UDim2.new(1, -20, 0, 60)
creditsText.Position = UDim2.new(0, 10, 0, 210)
creditsText.BackgroundTransparency = 1
creditsText.TextColor3 = Color3.fromRGB(255, 0, 255)
creditsText.TextSize = 14
creditsText.Font = Enum.Font.SourceSansBold
creditsText.Text = "Ultimate Aimbot + ESP\nVersion 2.0\n© Enhanced UI Edition"
creditsText.TextXAlignment = Enum.TextXAlignment.Center
creditsText.LayoutOrder = 4
creditsText.Parent = TabContents["Settings"]

-- Make each tab's canvas size adjust to its content
for _, tab in pairs(TabContents) do
    local function updateCanvasSize()
        local contentHeight = tab.UIListLayout.AbsoluteContentSize.Y + 20
        tab.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
    end
    
    tab.UIListLayout.Changed:Connect(updateCanvasSize)
    updateCanvasSize()
end

-- UI Management
-- Toggle key to hide/show the UI
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F1 then
        Panel.Visible = not Panel.Visible
    end
end)

-- The rest of the game functionality would continue from the original script
-- including ESP drawing, aimbot calculations, etc.
