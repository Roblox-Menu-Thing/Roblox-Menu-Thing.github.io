local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Create the UI framework
local TabUI = {}
TabUI.__index = TabUI

function TabUI.new()
    local self = setmetatable({}, TabUI)
    
    -- Main UI components
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "TabUISystem"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Try to use CoreGui if possible (more persistent)
    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(self.ScreenGui)
            self.ScreenGui.Parent = game:GetService("CoreGui")
        else
            self.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end
    end)
    
    -- Main frame
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = UDim2.new(0, 600, 0, 350)
    self.MainFrame.Position = UDim2.new(0.5, -300, 0.5, -175)
    self.MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Parent = self.ScreenGui
    
    -- Make the frame draggable
    self:MakeDraggable(self.MainFrame)
    
    -- Add rounded corners
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = self.MainFrame
    
    -- Add shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.BackgroundTransparency = 1
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Shadow.Size = UDim2.new(1, 30, 1, 30)
    Shadow.ZIndex = -1
    Shadow.Image = "rbxassetid://5554236805"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.6
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    Shadow.Parent = self.MainFrame
    
    -- Title bar
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Name = "TitleBar"
    self.TitleBar.Size = UDim2.new(1, 0, 0, 30)
    self.TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    self.TitleBar.BorderSizePixel = 0
    self.TitleBar.Parent = self.MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = self.TitleBar
    
    -- Fix the bottom corners of title bar
    local BottomFrame = Instance.new("Frame")
    BottomFrame.Name = "BottomFrame"
    BottomFrame.Size = UDim2.new(1, 0, 0.5, 0)
    BottomFrame.Position = UDim2.new(0, 0, 0.5, 0)
    BottomFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    BottomFrame.BorderSizePixel = 0
    BottomFrame.ZIndex = 0
    BottomFrame.Parent = self.TitleBar
    
    -- Title text
    self.TitleText = Instance.new("TextLabel")
    self.TitleText.Name = "TitleText"
    self.TitleText.Size = UDim2.new(1, -10, 1, 0)
    self.TitleText.Position = UDim2.new(0, 10, 0, 0)
    self.TitleText.BackgroundTransparency = 1
    self.TitleText.Text = "Roblox UI System"
    self.TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.TitleText.TextSize = 16
    self.TitleText.Font = Enum.Font.GothamSemibold
    self.TitleText.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleText.Parent = self.TitleBar
    
    -- Close button
    self.CloseButton = Instance.new("TextButton")
    self.CloseButton.Name = "CloseButton"
    self.CloseButton.Size = UDim2.new(0, 24, 0, 24)
    self.CloseButton.Position = UDim2.new(1, -27, 0, 3)
    self.CloseButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    self.CloseButton.Text = ""
    self.CloseButton.Parent = self.TitleBar
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 12)
    CloseCorner.Parent = self.CloseButton
    
    self.CloseButton.MouseButton1Click:Connect(function()
        self.ScreenGui:Destroy()
    end)
    
    -- Tab container (left side)
    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Name = "TabContainer"
    self.TabContainer.Size = UDim2.new(0, 60, 1, -30)
    self.TabContainer.Position = UDim2.new(0, 0, 0, 30)
    self.TabContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    self.TabContainer.BorderSizePixel = 0
    self.TabContainer.Parent = self.MainFrame
    
    local TabContainerCorner = Instance.new("UICorner")
    TabContainerCorner.CornerRadius = UDim.new(0, 8)
    TabContainerCorner.Parent = self.TabContainer
    
    -- Fix the right corners of tab container
    local RightFrame = Instance.new("Frame")
    RightFrame.Name = "RightFrame"
    RightFrame.Size = UDim2.new(0.5, 0, 1, 0)
    RightFrame.Position = UDim2.new(0.5, 0, 0, 0)
    RightFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    RightFrame.BorderSizePixel = 0
    RightFrame.ZIndex = 0
    RightFrame.Parent = self.TabContainer
    
    -- Tab content container (right side)
    self.ContentContainer = Instance.new("Frame")
    self.ContentContainer.Name = "ContentContainer"
    self.ContentContainer.Size = UDim2.new(1, -70, 1, -40)
    self.ContentContainer.Position = UDim2.new(0, 65, 0, 35)
    self.ContentContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    self.ContentContainer.BorderSizePixel = 0
    self.ContentContainer.Parent = self.MainFrame
    
    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 8)
    ContentCorner.Parent = self.ContentContainer
    
    -- Tab buttons layout
    self.TabButtonsLayout = Instance.new("UIListLayout")
    self.TabButtonsLayout.FillDirection = Enum.FillDirection.Vertical
    self.TabButtonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    self.TabButtonsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    self.TabButtonsLayout.Padding = UDim.new(0, 10)
    self.TabButtonsLayout.Parent = self.TabContainer
    
    -- Add padding at the top
    local TabPadding = Instance.new("UIPadding")
    TabPadding.PaddingTop = UDim.new(0, 10)
    TabPadding.Parent = self.TabContainer
    
    -- Store tabs
    self.Tabs = {}
    self.ActiveTab = nil
    
    return self
end

function TabUI:MakeDraggable(frame)
    local dragging = false
    local dragInput, mousePos, framePos
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position
        end
    end)
    
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            dragInput = input
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput and mousePos then
            local delta = dragInput.Position - mousePos
            frame.Position = UDim2.new(
                framePos.X.Scale, 
                framePos.X.Offset + delta.X, 
                framePos.Y.Scale, 
                framePos.Y.Offset + delta.Y
            )
        end
    end)
end

function TabUI:NewTab(iconId, name)
    local tabIndex = #self.Tabs + 1
    
    -- Create tab button
    local TabButton = Instance.new("ImageButton")
    TabButton.Name = "TabButton_" .. tabIndex
    TabButton.Size = UDim2.new(0, 40, 0, 40)
    TabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    TabButton.Image = iconId
    TabButton.ScaleType = Enum.ScaleType.Fit
    TabButton.ImageColor3 = Color3.fromRGB(200, 200, 200)
    TabButton.LayoutOrder = tabIndex
    TabButton.Parent = self.TabContainer
    
    local TabButtonCorner = Instance.new("UICorner")
    TabButtonCorner.CornerRadius = UDim.new(0, 8)
    TabButtonCorner.Parent = TabButton
    
    -- Create tab content frame
    local TabContent = Instance.new("ScrollingFrame")
    TabContent.Name = "TabContent_" .. tabIndex
    TabContent.Size = UDim2.new(1, -20, 1, -20)
    TabContent.Position = UDim2.new(0, 10, 0, 10)
    TabContent.BackgroundTransparency = 1
    TabContent.BorderSizePixel = 0
    TabContent.ScrollBarThickness = 4
    TabContent.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    TabContent.Visible = false
    TabContent.Parent = self.ContentContainer
    TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    -- Add padding to tab content
    local ContentPadding = Instance.new("UIPadding")
    ContentPadding.PaddingTop = UDim.new(0, 10)
    ContentPadding.PaddingLeft = UDim.new(0, 10)
    ContentPadding.PaddingRight = UDim.new(0, 10)
    ContentPadding.PaddingBottom = UDim.new(0, 10)
    ContentPadding.Parent = TabContent
    
    -- Add layout for sections
    local SectionLayout = Instance.new("UIListLayout")
    SectionLayout.FillDirection = Enum.FillDirection.Vertical
    SectionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SectionLayout.Padding = UDim.new(0, 10)
    SectionLayout.Parent = TabContent
    
    -- Tab data
    local tab = {
        Button = TabButton,
        Content = TabContent,
        Name = name or "Tab " .. tabIndex,
        Sections = {}
    }
    
    -- Tab button click handler
    TabButton.MouseButton1Click:Connect(function()
        self:SelectTab(tabIndex)
    end)
    
    -- Add hover effect
    TabButton.MouseEnter:Connect(function()
        if self.ActiveTab ~= tabIndex then
            TweenService:Create(TabButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(55, 55, 60),
                ImageColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
        end
    end)
    
    TabButton.MouseLeave:Connect(function()
        if self.ActiveTab ~= tabIndex then
            TweenService:Create(TabButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(45, 45, 50),
                ImageColor3 = Color3.fromRGB(200, 200, 200)
            }):Play()
        end
    end)
    
    table.insert(self.Tabs, tab)
    
    -- If this is the first tab, select it
    if tabIndex == 1 then
        self:SelectTab(1)
    end
    
    -- Return methods for this tab
    return {
        NewSection = function(sectionName)
            return self:NewSection(tabIndex, sectionName)
        end
    }
end

function TabUI:SelectTab(tabIndex)
    -- Hide all tabs
    for i, tab in ipairs(self.Tabs) do
        tab.Content.Visible = false
        
        -- Reset button appearance
        TweenService:Create(tab.Button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(45, 45, 50),
            ImageColor3 = Color3.fromRGB(200, 200, 200)
        }):Play()
    end
    
    -- Show selected tab
    local selectedTab = self.Tabs[tabIndex]
    if selectedTab then
        selectedTab.Content.Visible = true
        
        -- Update button appearance
        TweenService:Create(selectedTab.Button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(60, 120, 255),
            ImageColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
        
        -- Update title text
        self.TitleText.Text = selectedTab.Name
        
        self.ActiveTab = tabIndex
    end
end

function TabUI:NewSection(tabIndex, sectionName)
    local tab = self.Tabs[tabIndex]
    if not tab then return end
    
    local sectionIndex = #tab.Sections + 1
    
    -- Create section frame
    local SectionFrame = Instance.new("Frame")
    SectionFrame.Name = "Section_" .. sectionIndex
    SectionFrame.Size = UDim2.new(1, 0, 0, 40) -- Initial size, will auto-resize
    SectionFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    SectionFrame.BorderSizePixel = 0
    SectionFrame.AutomaticSize = Enum.AutomaticSize.Y
    SectionFrame.LayoutOrder = sectionIndex
    SectionFrame.Parent = tab.Content
    
    local SectionCorner = Instance.new("UICorner")
    SectionCorner.CornerRadius = UDim.new(0, 6)
    SectionCorner.Parent = SectionFrame
    
    -- Section title
    local SectionTitle = Instance.new("TextLabel")
    SectionTitle.Name = "SectionTitle"
    SectionTitle.Size = UDim2.new(1, -20, 0, 30)
    SectionTitle.Position = UDim2.new(0, 10, 0, 5)
    SectionTitle.BackgroundTransparency = 1
    SectionTitle.Text = sectionName or "Section " .. sectionIndex
    SectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    SectionTitle.TextSize = 14
    SectionTitle.Font = Enum.Font.GothamSemibold
    SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    SectionTitle.Parent = SectionFrame
    
    -- Container for section elements
    local ElementsContainer = Instance.new("Frame")
    ElementsContainer.Name = "ElementsContainer"
    ElementsContainer.Size = UDim2.new(1, -20, 0, 0)
    ElementsContainer.Position = UDim2.new(0, 10, 0, 35)
    ElementsContainer.BackgroundTransparency = 1
    ElementsContainer.AutomaticSize = Enum.AutomaticSize.Y
    ElementsContainer.Parent = SectionFrame
    
    -- Layout for elements
    local ElementsLayout = Instance.new("UIListLayout")
    ElementsLayout.FillDirection = Enum.FillDirection.Vertical
    ElementsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ElementsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ElementsLayout.Padding = UDim.new(0, 8)
    ElementsLayout.Parent = ElementsContainer
    
    -- Add padding at the bottom
    local BottomPadding = Instance.new("Frame")
    BottomPadding.Name = "BottomPadding"
    BottomPadding.Size = UDim2.new(1, 0, 0, 5)
    BottomPadding.BackgroundTransparency = 1
    BottomPadding.LayoutOrder = 999999 -- Make sure it's at the bottom
    BottomPadding.Parent = ElementsContainer
    
    -- Section data
    local section = {
        Frame = SectionFrame,
        Container = ElementsContainer,
        Name = sectionName or "Section " .. sectionIndex,
        Elements = {}
    }
    
    table.insert(tab.Sections, section)
    
    -- Return methods for this section
    return {
        AddButton = function(text, callback)
            return self:AddButton(tabIndex, sectionIndex, text, callback)
        end,
        AddToggle = function(text, default, callback)
            return self:AddToggle(tabIndex, sectionIndex, text, default, callback)
        end,
        AddSlider = function(text, min, max, default, callback)
            return self:AddSlider(tabIndex, sectionIndex, text, min, max, default, callback)
        end,
        AddTextbox = function(text, placeholder, callback)
            return self:AddTextbox(tabIndex, sectionIndex, text, placeholder, callback)
        end,
        AddDropdown = function(text, options, callback)
            return self:AddDropdown(tabIndex, sectionIndex, text, options, callback)
        end,
        AddLabel = function(text)
            return self:AddLabel(tabIndex, sectionIndex, text)
        end
    }
end

function TabUI:AddButton(tabIndex, sectionIndex, text, callback)
    local tab = self.Tabs[tabIndex]
    if not tab then return end
    
    local section = tab.Sections[sectionIndex]
    if not section then return end
    
    local elementIndex = #section.Elements + 1
    
    -- Create button
    local Button = Instance.new("TextButton")
    Button.Name = "Button_" .. elementIndex
    Button.Size = UDim2.new(1, 0, 0, 32)
    Button.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    Button.Text = text or "Button"
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 14
    Button.Font = Enum.Font.Gotham
    Button.LayoutOrder = elementIndex
    Button.Parent = section.Container
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 4)
    ButtonCorner.Parent = Button
    
    -- Button effects
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(60, 60, 65)
        }):Play()
    end)
    
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        }):Play()
    end)
    
    Button.MouseButton1Down:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(70, 120, 255)
        }):Play()
    end)
    
    Button.MouseButton1Up:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(60, 60, 65)
        }):Play()
    end)
    
    -- Button click handler
    Button.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)
    
    local element = {
        Type = "Button",
        Instance = Button
    }
    
    table.insert(section.Elements, element)
    return element
end

function TabUI:AddToggle(tabIndex, sectionIndex, text, default, callback)
    local tab = self.Tabs[tabIndex]
    if not tab then return end
    
    local section = tab.Sections[sectionIndex]
    if not section then return end
    
    local elementIndex = #section.Elements + 1
    
    -- Create toggle container
    local ToggleContainer = Instance.new("Frame")
    ToggleContainer.Name = "Toggle_" .. elementIndex
    ToggleContainer.Size = UDim2.new(1, 0, 0, 32)
    ToggleContainer.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    ToggleContainer.LayoutOrder = elementIndex
    ToggleContainer.Parent = section.Container
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 4)
    ToggleCorner.Parent = ToggleContainer
    
    -- Toggle text
    local ToggleText = Instance.new("TextLabel")
    ToggleText.Name = "ToggleText"
    ToggleText.Size = UDim2.new(1, -60, 1, 0)
    ToggleText.Position = UDim2.new(0, 10, 0, 0)
    ToggleText.BackgroundTransparency = 1
    ToggleText.Text = text or "Toggle"
    ToggleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleText.TextSize = 14
    ToggleText.Font = Enum.Font.Gotham
    ToggleText.TextXAlignment = Enum.TextXAlignment.Left
    ToggleText.Parent = ToggleContainer
    
    -- Toggle indicator background
    local ToggleBackground = Instance.new("Frame")
    ToggleBackground.Name = "ToggleBackground"
    ToggleBackground.Size = UDim2.new(0, 40, 0, 20)
    ToggleBackground.Position = UDim2.new(1, -50, 0.5, -10)
    ToggleBackground.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    ToggleBackground.Parent = ToggleContainer
    
    local BackgroundCorner = Instance.new("UICorner")
    BackgroundCorner.CornerRadius = UDim.new(1, 0)
    BackgroundCorner.Parent = ToggleBackground
    
    -- Toggle indicator
    local ToggleIndicator = Instance.new("Frame")
    ToggleIndicator.Name = "ToggleIndicator"
    ToggleIndicator.Size = UDim2.new(0, 16, 0, 16)
    ToggleIndicator.Position = UDim2.new(0, 2, 0.5, -8)
    ToggleIndicator.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    ToggleIndicator.Parent = ToggleBackground
    
    local IndicatorCorner = Instance.new("UICorner")
    IndicatorCorner.CornerRadius = UDim.new(1, 0)
    IndicatorCorner.Parent = ToggleIndicator
    
    -- Toggle state
    local toggled = default or false
    
    -- Update toggle appearance
    local function updateToggle()
        if toggled then
            TweenService:Create(ToggleBackground, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(60, 120, 255)
            }):Play()
            
            TweenService:Create(ToggleIndicator, TweenInfo.new(0.2), {
                Position = UDim2.new(0, 22, 0.5, -8),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
        else
            TweenService:Create(ToggleBackground, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            }):Play()
            
            TweenService:Create(ToggleIndicator, TweenInfo.new(0.2), {
                Position = UDim2.new(0, 2, 0.5, -8),
                BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            }):Play()
        end
        
        if callback then
            callback(toggled)
        end
    end
    
    -- Initial state
    updateToggle()
    
    -- Toggle click handler
    ToggleContainer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggled = not toggled
            updateToggle()
        end
    end)
    
    -- Hover effect
    ToggleContainer.MouseEnter:Connect(function()
        TweenService:Create(ToggleContainer, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(55, 55, 60)
        }):Play()
    end)
    
    ToggleContainer.MouseLeave:Connect(function()
        TweenService:Create(ToggleContainer, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        }):Play()
    end)
    
    local element = {
        Type = "Toggle",
        Instance = ToggleContainer,
        Set = function(value)
            toggled = value
            updateToggle()
        end,
        Get = function()
            return toggled
        end
    }
    
    table.insert(section.Elements, element)
    return element
end

function TabUI:AddSlider(tabIndex, sectionIndex, text, min, max, default, callback)
    local tab = self.Tabs[tabIndex]
    if not tab then return end
    
    local section = tab.Sections[sectionIndex]
    if not section then return end
    
    local elementIndex = #section.Elements + 1
    
    min = min or 0
    max = max or 100
    default = default or min
    
    -- Clamp default value
    default = math.clamp(default, min, max)
    
    -- Create slider container
    local SliderContainer = Instance.new("Frame")
    SliderContainer.Name = "Slider_" .. elementIndex
    SliderContainer.Size = UDim2.new(1, 0, 0, 50)
    SliderContainer.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    SliderContainer.LayoutOrder = elementIndex
    SliderContainer.Parent = section.Container
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 4)
    SliderCorner.Parent = SliderContainer
    
    -- Slider text
    local SliderText = Instance.new("TextLabel")
    SliderText.Name = "SliderText"
    SliderText.Size = UDim2.new(1, -20, 0, 20)
    SliderText.Position = UDim2.new(0, 10, 0, 5)
    SliderText.BackgroundTransparency = 1
    SliderText.Text = text or "Slider"
    SliderText.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderText.TextSize = 14
    SliderText.Font = Enum.Font.Gotham
    SliderText.TextXAlignment = Enum.TextXAlignment.Left
    SliderText.Parent = SliderContainer
    
    -- Value display
    local ValueText = Instance.new("TextLabel")
    ValueText.Name = "ValueText"
    ValueText.Size = UDim2.new(0, 50, 0, 20)
    ValueText.Position = UDim2.new(1, -60, 0, 5)
    ValueText.BackgroundTransparency = 1
    ValueText.Text = tostring(default)
    ValueText.TextColor3 = Color3.fromRGB(255, 255, 255)
    ValueText.TextSize = 14
    ValueText.Font = Enum.Font.Gotham
    ValueText.TextXAlignment = Enum.TextXAlignment.Right
    ValueText.Parent = SliderContainer
    
    -- Slider background
    local SliderBackground = Instance.new("Frame")
    SliderBackground.Name = "SliderBackground"
    SliderBackground.Size = UDim2.new(1, -20, 0, 10)
    SliderBackground.Position = UDim2.new(0, 10, 0, 30)
    SliderBackground.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    SliderBackground.Parent = SliderContainer
    
    local BackgroundCorner = Instance.new("UICorner")
    BackgroundCorner.CornerRadius = UDim.new(0, 5)
    BackgroundCorner.Parent = SliderBackground
    
    -- Slider fill
    local SliderFill = Instance.new("Frame")
    SliderFill.Name = "SliderFill"
    SliderFill.Size = UDim2.new(0, 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
    SliderFill.Parent = SliderBackground
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 5)
    FillCorner.Parent = SliderFill
    
    -- Slider value and state
    local value = default
    local sliding = false
    
    -- Update slider appearance
    local function updateSlider()
        local percent = (value - min) / (max - min)
        SliderFill.Size = UDim2.new(percent, 0, 1, 0)
        ValueText.Text = tostring(math.floor(value * 100) / 100)
        
        if callback then
            callback(value)
        end
    end
    
    -- Initial state
    updateSlider()
    
    -- Slider interaction
    SliderBackground.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = true
            
            -- Calculate value based on mouse position
            local mousePos = UserInputService:GetMouseLocation().X
            local sliderPos = SliderBackground.AbsolutePosition.X
            local sliderWidth = SliderBackground.AbsoluteSize.X
            local percent = math.clamp((mousePos - sliderPos) / sliderWidth, 0, 1)
            value = min + (max - min) * percent
            
            updateSlider()
        end
    end)
    
    SliderBackground.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
            -- Calculate value based on mouse position
            local mousePos = UserInputService:GetMouseLocation().X
            local sliderPos = SliderBackground.AbsolutePosition.X
            local sliderWidth = SliderBackground.AbsoluteSize.X
            local percent = math.clamp((mousePos - sliderPos) / sliderWidth, 0, 1)
            value = min + (max - min) * percent
            
            updateSlider()
        end
    end)
    
    -- Hover effect
    SliderContainer.MouseEnter:Connect(function()
        TweenService:Create(SliderContainer, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(55, 55, 60)
        }):Play()
    end)
    
    SliderContainer.MouseLeave:Connect(function()
        TweenService:Create(SliderContainer, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        }):Play()
    end)
    
    local element = {
        Type = "Slider",
        Instance = SliderContainer,
        Set = function(newValue)
            value = math.clamp(newValue, min, max)
            updateSlider()
        end,
        Get = function()
            return value
        end
    }
    
    table.insert(section.Elements, element)
    return element
end

function TabUI:AddTextbox(tabIndex, sectionIndex, text, placeholder, callback)
    local tab = self.Tabs[tabIndex]
    if not tab then return end
    
    local section = tab.Sections[sectionIndex]
    if not section then return end
    
    local elementIndex = #section.Elements + 1
    
    -- Create textbox container
    local TextboxContainer = Instance.new("Frame")
    TextboxContainer.Name = "Textbox_" .. elementIndex
    TextboxContainer.Size = UDim2.new(1, 0, 0, 50)
    TextboxContainer.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    TextboxContainer.LayoutOrder = elementIndex
    TextboxContainer.Parent = section.Container
    
    local TextboxCorner = Instance.new("UICorner")
    TextboxCorner.CornerRadius = UDim.new(0, 4)
    TextboxCorner.Parent = TextboxContainer
    
    -- Textbox label
    local TextboxLabel = Instance.new("TextLabel")
    TextboxLabel.Name = "TextboxLabel"
    TextboxLabel.Size = UDim2.new(1, -20, 0, 20)
    TextboxLabel.Position = UDim2.new(0, 10, 0, 5)
    TextboxLabel.BackgroundTransparency = 1
    TextboxLabel.Text = text or "Textbox"
    TextboxLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextboxLabel.TextSize = 14
    TextboxLabel.Font = Enum.Font.Gotham
    TextboxLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextboxLabel.Parent = TextboxContainer
    
    -- Textbox background
    local TextboxBackground = Instance.new("Frame")
    TextboxBackground.Name = "TextboxBackground"
    TextboxBackground.Size = UDim2.new(1, -20, 0, 24)
    TextboxBackground.Position = UDim2.new(0, 10, 0, 25)
    TextboxBackground.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    TextboxBackground.Parent = TextboxContainer
    
    local BackgroundCorner = Instance.new("UICorner")
    BackgroundCorner.CornerRadius = UDim.new(0, 4)
    BackgroundCorner.Parent = TextboxBackground
    
    -- Textbox
    local Textbox = Instance.new("TextBox")
    Textbox.Name = "Textbox"
    Textbox.Size = UDim2.new(1, -10, 1, 0)
    Textbox.Position = UDim2.new(0, 5, 0, 0)
    Textbox.BackgroundTransparency = 1
    Textbox.Text = ""
    Textbox.PlaceholderText = placeholder or "Enter text..."
    Textbox.TextColor3 = Color3.fromRGB(255, 255, 255)
    Textbox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    Textbox.TextSize = 14
    Textbox.Font = Enum.Font.Gotham
    Textbox.TextXAlignment = Enum.TextXAlignment.Left
    Textbox.ClearTextOnFocus = false
    Textbox.Parent = TextboxBackground
    
    -- Textbox events
    Textbox.FocusLost:Connect(function(enterPressed)
        if callback then
            callback(Textbox.Text, enterPressed)
        end
    end)
    
    -- Hover effect
    TextboxContainer.MouseEnter:Connect(function()
        TweenService:Create(TextboxContainer, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(55, 55, 60)
        }):Play()
    end)
    
    TextboxContainer.MouseLeave:Connect(function()
        TweenService:Create(TextboxContainer, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        }):Play()
    end)
    
    local element = {
        Type = "Textbox",
        Instance = TextboxContainer,
        Set = function(value)
            Textbox.Text = value
        end,
        Get = function()
            return Textbox.Text
        end
    }
    
    table.insert(section.Elements, element)
    return element
end

function TabUI:AddDropdown(tabIndex, sectionIndex, text, options, callback)
    local tab = self.Tabs[tabIndex]
    if not tab then return end
    
    local section = tab.Sections[sectionIndex]
    if not section then return end
    
    local elementIndex = #section.Elements + 1
    options = options or {}
    
    -- Create dropdown container
    local DropdownContainer = Instance.new("Frame")
    DropdownContainer.Name = "Dropdown_" .. elementIndex
    DropdownContainer.Size = UDim2.new(1, 0, 0, 50)
    DropdownContainer.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    DropdownContainer.LayoutOrder = elementIndex
    DropdownContainer.Parent = section.Container
    
    local DropdownCorner = Instance.new("UICorner")
    DropdownCorner.CornerRadius = UDim.new(0, 4)
    DropdownCorner.Parent = DropdownContainer
    
    -- Dropdown label
    local DropdownLabel = Instance.new("TextLabel")
    DropdownLabel.Name = "DropdownLabel"
    DropdownLabel.Size = UDim2.new(1, -20, 0, 20)
    DropdownLabel.Position = UDim2.new(0, 10, 0, 5)
    DropdownLabel.BackgroundTransparency = 1
    DropdownLabel.Text = text or "Dropdown"
    DropdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownLabel.TextSize = 14
    DropdownLabel.Font = Enum.Font.Gotham
    DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
    DropdownLabel.Parent = DropdownContainer
    
    -- Dropdown button
    local DropdownButton = Instance.new("TextButton")
    DropdownButton.Name = "DropdownButton"
    DropdownButton.Size = UDim2.new(1, -20, 0, 24)
    DropdownButton.Position = UDim2.new(0, 10, 0, 25)
    DropdownButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    DropdownButton.Text = ""
    DropdownButton.Parent = DropdownContainer
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 4)
    ButtonCorner.Parent = DropdownButton
    
    -- Selected text
    local SelectedText = Instance.new("TextLabel")
    SelectedText.Name = "SelectedText"
    SelectedText.Size = UDim2.new(1, -30, 1, 0)
    SelectedText.Position = UDim2.new(0, 10, 0, 0)
    SelectedText.BackgroundTransparency = 1
    SelectedText.Text = "Select..."
    SelectedText.TextColor3 = Color3.fromRGB(200, 200, 200)
    SelectedText.TextSize = 14
    SelectedText.Font = Enum.Font.Gotham
    SelectedText.TextXAlignment = Enum.TextXAlignment.Left
    SelectedText.Parent = DropdownButton
    
    -- Arrow icon
    local ArrowIcon = Instance.new("ImageLabel")
    ArrowIcon.Name = "ArrowIcon"
    ArrowIcon.Size = UDim2.new(0, 16, 0, 16)
    ArrowIcon.Position = UDim2.new(1, -20, 0.5, -8)
    ArrowIcon.BackgroundTransparency = 1
    ArrowIcon.Image = "rbxassetid://7072706663"
    ArrowIcon.ImageColor3 = Color3.fromRGB(200, 200, 200)
    ArrowIcon.Parent = DropdownButton
    
    -- Dropdown menu
    local DropdownMenu = Instance.new("Frame")
    DropdownMenu.Name = "DropdownMenu"
    DropdownMenu.Size = UDim2.new(1, 0, 0, 0)
    DropdownMenu.Position = UDim2.new(0, 0, 1, 5)
    DropdownMenu.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    DropdownMenu.BorderSizePixel = 0
    DropdownMenu.ClipsDescendants = true
    DropdownMenu.Visible = false
    DropdownMenu.ZIndex = 10
    DropdownMenu.Parent = DropdownButton
    
    local MenuCorner = Instance.new("UICorner")
    MenuCorner.CornerRadius = UDim.new(0, 4)
    MenuCorner.Parent = DropdownMenu
    
    -- Options list
    local OptionsList = Instance.new("ScrollingFrame")
    OptionsList.Name = "OptionsList"
    OptionsList.Size = UDim2.new(1, -10, 1, -10)
    OptionsList.Position = UDim2.new(0, 5, 0, 5)
    OptionsList.BackgroundTransparency = 1
    OptionsList.BorderSizePixel = 0
    OptionsList.ScrollBarThickness = 2
    OptionsList.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    OptionsList.ZIndex = 10
    OptionsList.Parent = DropdownMenu
    OptionsList.CanvasSize = UDim2.new(0, 0, 0, 0)
    OptionsList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    -- Options layout
    local OptionsLayout = Instance.new("UIListLayout")
    OptionsLayout.FillDirection = Enum.FillDirection.Vertical
    OptionsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    OptionsLayout.Padding = UDim.new(0, 2)
    OptionsLayout.Parent = OptionsList
    
    -- Dropdown state
    local isOpen = false
    local selectedOption = nil
    
    -- Toggle dropdown
    local function toggleDropdown()
        isOpen = not isOpen
        
        if isOpen then
            DropdownMenu.Visible = true
            TweenService:Create(ArrowIcon, TweenInfo.new(0.2), {
                Rotation = 180
            }):Play()
            
            -- Calculate height based on number of options (max 150)
            local optionsHeight = math.min(#options * 30, 150)
            TweenService:Create(DropdownMenu, TweenInfo.new(0.2), {
                Size = UDim2.new(1, 0, 0, optionsHeight)
            }):Play()
        else
            TweenService:Create(ArrowIcon, TweenInfo.new(0.2), {
                Rotation = 0
            }):Play()
            
            TweenService:Create(DropdownMenu, TweenInfo.new(0.2), {
                Size = UDim2.new(1, 0, 0, 0)
            }):Play()
            
            -- Hide menu after animation
            delay(0.2, function()
                if not isOpen then
                    DropdownMenu.Visible = false
                end
            end)
        end
    end
    
    -- Add options
    for i, option in ipairs(options) do
        local OptionButton = Instance.new("TextButton")
        OptionButton.Name = "Option_" .. i
        OptionButton.Size = UDim2.new(1, 0, 0, 28)
        OptionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        OptionButton.Text = option
        OptionButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        OptionButton.TextSize = 14
        OptionButton.Font = Enum.Font.Gotham
        OptionButton.LayoutOrder = i
        OptionButton.ZIndex = 10
        OptionButton.Parent = OptionsList
        
        local OptionCorner = Instance.new("UICorner")
        OptionCorner.CornerRadius = UDim.new(0, 4)
        OptionCorner.Parent = OptionButton
        
        -- Option button events
        OptionButton.MouseEnter:Connect(function()
            TweenService:Create(OptionButton, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(60, 60, 65)
            }):Play()
        end)
        
        OptionButton.MouseLeave:Connect(function()
            TweenService:Create(OptionButton, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            }):Play()
        end)
        
        OptionButton.MouseButton1Click:Connect(function()
            selectedOption = option
            SelectedText.Text = option
            SelectedText.TextColor3 = Color3.fromRGB(255, 255, 255)
            
            toggleDropdown()
            
            if callback then
                callback(option)
            end
        end)
    end
    
    -- Dropdown button events
    DropdownButton.MouseButton1Click:Connect(toggleDropdown)
    
    -- Close dropdown when clicking elsewhere
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            local buttonPos = DropdownButton.AbsolutePosition
            local buttonSize = DropdownButton.AbsoluteSize
            
            if isOpen and (mousePos.X < buttonPos.X or mousePos.X > buttonPos.X + buttonSize.X or
                mousePos.Y < buttonPos.Y or mousePos.Y > buttonPos.Y + buttonSize.Y + DropdownMenu.AbsoluteSize.Y) then
                toggleDropdown()
            end
        end
    end)
    
    -- Hover effect
    DropdownContainer.MouseEnter:Connect(function()
        TweenService:Create(DropdownContainer, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(55, 55, 60)
        }):Play()
    end)
    
    DropdownContainer.MouseLeave:Connect(function()
        TweenService:Create(DropdownContainer, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        }):Play()
    end)
    
    local element = {
        Type = "Dropdown",
        Instance = DropdownContainer,
        Set = function(option)
            if table.find(options, option) then
                selectedOption = option
                SelectedText.Text = option
                SelectedText.TextColor3 = Color3.fromRGB(255, 255, 255)
                
                if callback then
                    callback(option)
                end
            end
        end,
        Get = function()
            return selectedOption
        end,
        Refresh = function(newOptions)
            options = newOptions
            selectedOption = nil
            SelectedText.Text = "Select..."
            SelectedText.TextColor3 = Color3.fromRGB(200, 200, 200)
            
            -- Clear existing options
            for _, child in pairs(OptionsList:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end
            
            -- Add new options
            for i, option in ipairs(options) do
                local OptionButton = Instance.new("TextButton")
                OptionButton.Name = "Option_" .. i
                OptionButton.Size = UDim2.new(1, 0, 0, 28)
                OptionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
                OptionButton.Text = option
                OptionButton.TextColor3 = Color3.fromRGB(200, 200, 200)
                OptionButton.TextSize = 14
                OptionButton.Font = Enum.Font.Gotham
                OptionButton.LayoutOrder = i
                OptionButton.ZIndex = 10
                OptionButton.Parent = OptionsList
                
                local OptionCorner = Instance.new("UICorner")
                OptionCorner.CornerRadius = UDim.new(0, 4)
                OptionCorner.Parent = OptionButton
                
                -- Option button events
                OptionButton.MouseEnter:Connect(function()
                    TweenService:Create(OptionButton, TweenInfo.new(0.1), {
                        BackgroundColor3 = Color3.fromRGB(60, 60, 65)
                    }):Play()
                end)
                
                OptionButton.MouseLeave:Connect(function()
                    TweenService:Create(OptionButton, TweenInfo.new(0.1), {
                        BackgroundColor3 = Color3.fromRGB(50, 50, 55)
                    }):Play()
                end)
                
                OptionButton.MouseButton1Click:Connect(function()
                    selectedOption = option
                    SelectedText.Text = option
                    SelectedText.TextColor3 = Color3.fromRGB(255, 255, 255)
                    
                    toggleDropdown()
                    
                    if callback then
                        callback(option)
                    end
                end)
            end
        end
    }
    
    table.insert(section.Elements, element)
    return element
end

function TabUI:AddLabel(tabIndex, sectionIndex, text)
    local tab = self.Tabs[tabIndex]
    if not tab then return end
    
    local section = tab.Sections[sectionIndex]
    if not section then return end
    
    local elementIndex = #section.Elements + 1
    
    -- Create label
    local Label = Instance.new("TextLabel")
    Label.Name = "Label_" .. elementIndex
    Label.Size = UDim2.new(1, 0, 0, 30)
    Label.BackgroundTransparency = 1
    Label.Text = text or "Label"
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextSize = 14
    Label.Font = Enum.Font.Gotham
    Label.LayoutOrder = elementIndex
    Label.Parent = section.Container
    
    local element = {
        Type = "Label",
        Instance = Label,
        Set = function(newText)
            Label.Text = newText
        end,
        Get = function()
            return Label.Text
        end
    }
    
    table.insert(section.Elements, element)
    return element
end

return TabUI
