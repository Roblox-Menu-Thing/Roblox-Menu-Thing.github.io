-- Menu Library for Roblox
-- Black and White Theme Version

local library = {}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Default theme (Black and White)
local theme = {
    main_color = Color3.fromRGB(30, 30, 30),
    background_color = Color3.fromRGB(20, 20, 20),
    accent_color = Color3.fromRGB(255, 255, 255),
    text_color = Color3.fromRGB(255, 255, 255),
    outline_color = Color3.fromRGB(50, 50, 50)
}

-- Utility functions
local function Create(Object, Properties, Children)
    local Obj = Instance.new(Object)
    for i, v in pairs(Properties or {}) do
        Obj[i] = v
    end
    
    for _, child in pairs(Children or {}) do
        child.Parent = Obj
    end
    
    return Obj
end

local function MakeDraggable(topBarObject, object)
    local Dragging = nil
    local DragInput = nil
    local DragStart = nil
    local StartPosition = nil
    
    local function Update(input)
        local Delta = input.Position - DragStart
        object.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
    end
    
    topBarObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPosition = object.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)
    
    topBarObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            Update(input)
        end
    end)
end

local function IsMouseOverFrame(frame)
    local mousePos = UserInputService:GetMouseLocation()
    local framePos = frame.AbsolutePosition
    local frameSize = frame.AbsoluteSize
    
    if mousePos.X >= framePos.X and mousePos.X <= framePos.X + frameSize.X and
       mousePos.Y >= framePos.Y and mousePos.Y <= framePos.Y + frameSize.Y then
        return true
    end
    return false
end

-- Main menu creation
function library.new(title, folder, custom_theme)
    if custom_theme then
        for k, v in pairs(custom_theme) do
            theme[k] = v
        end
    end
    
    if not isfolder(folder) then
        makefolder(folder)
    end
    
    -- Create main GUI
    local menu = {
        values = {},
        tabs = {},
        tabbuttons = {},
        options = {},
        open = true,
        popup = nil,
        connections = {},
        folder = folder
    }
    
    -- Create ScreenGui
    menu.ScreenGui = Create("ScreenGui", {
        Name = "NemV2",
        Parent = game.CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Global
    })
    
    -- Create Main Frame
    menu.Main = Create("Frame", {
        Name = "Main",
        Parent = menu.ScreenGui,
        BackgroundColor3 = theme.main_color,
        BorderColor3 = theme.outline_color,
        BorderSizePixel = 1,
        Position = UDim2.new(0.5, -300, 0.5, -300),
        Size = UDim2.new(0, 600, 0, 600),
        ClipsDescendants = true
    })
    
    -- Create Top Bar
    menu.TopBar = Create("Frame", {
        Name = "TopBar",
        Parent = menu.Main,
        BackgroundColor3 = theme.accent_color,
        BorderColor3 = theme.outline_color,
        BorderSizePixel = 1,
        Size = UDim2.new(1, 0, 0, 30)
    })
    
    -- Create Title
    menu.Title = Create("TextLabel", {
        Name = "Title",
        Parent = menu.TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0, 200, 1, 0),
        Font = Enum.Font.SourceSansBold,
        Text = title,
        TextColor3 = theme.text_color,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Create Close Button
    menu.CloseButton = Create("TextButton", {
        Name = "CloseButton",
        Parent = menu.TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -30, 0, 0),
        Size = UDim2.new(0, 30, 1, 0),
        Font = Enum.Font.SourceSansBold,
        Text = "X",
        TextColor3 = theme.text_color,
        TextSize = 20
    })
    
    -- Create Tab Container
    menu.TabContainer = Create("Frame", {
        Name = "TabContainer",
        Parent = menu.Main,
        BackgroundColor3 = theme.background_color,
        BorderColor3 = theme.outline_color,
        BorderSizePixel = 1,
        Position = UDim2.new(0, 10, 0, 40),
        Size = UDim2.new(0, 30, 0, 550)
    })
    
    -- Create Content Container
    menu.ContentContainer = Create("Frame", {
        Name = "ContentContainer",
        Parent = menu.Main,
        BackgroundColor3 = theme.background_color,
        BorderColor3 = theme.outline_color,
        BorderSizePixel = 1,
        Position = UDim2.new(0, 50, 0, 40),
        Size = UDim2.new(0, 540, 0, 550),
        ClipsDescendants = true
    })
    
    -- Make the window draggable
    MakeDraggable(menu.TopBar, menu.Main)
    
    -- Set up close button functionality
    menu.CloseButton.MouseButton1Click:Connect(function()
        menu.ScreenGui:Destroy()
        for i, v in pairs(menu.connections) do
            v:Disconnect()
        end
    end)
    
    -- Set up toggle menu with right shift
    table.insert(menu.connections, UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.RightShift then
            menu.open = not menu.open
            menu.Main.Visible = menu.open
        end
    end))
    
    -- Save and load config functions
    function menu.save_cfg(name)
        local cfg = {}
        for i, tab in pairs(menu.values) do
            cfg[i] = {}
            for j, section in pairs(tab) do
                cfg[i][j] = {}
                for k, v in pairs(section) do
                    if v.Color ~= nil then
                        cfg[i][j][k] = {
                            Toggle = v.Toggle,
                            Dropdown = v.Dropdown,
                            Slider = v.Slider,
                            Color = {v.Color.R, v.Color.G, v.Color.B},
                            Transparency = v.Transparency
                        }
                    else
                        cfg[i][j][k] = v
                    end
                end
            end
        end
        writefile(menu.folder .. name .. ".txt", game:GetService("HttpService"):JSONEncode(cfg))
    end
    
    function menu.load_cfg(name)
        local cfg = game:GetService("HttpService"):JSONDecode(readfile(menu.folder .. name .. ".txt"))
        for i, tab in pairs(cfg) do
            for j, section in pairs(tab) do
                for k, v in pairs(section) do
                    if v.Color ~= nil then
                        v.Color = Color3.new(v.Color[1], v.Color[2], v.Color[3])
                    end
                    
                    if menu.options[i] and menu.options[i][j] and menu.options[i][j][k] then
                        local option = menu.options[i][j][k]
                        
                        if option.Type == "Toggle" then
                            option:SetValue(v.Toggle)
                        elseif option.Type == "Slider" then
                            option:SetValue(v.Slider)
                        elseif option.Type == "Dropdown" then
                            option:SetValue(v.Dropdown)
                        elseif option.Type == "Combo" then
                            option:SetValue(v.Combo)
                        elseif option.Type == "ColorPicker" then
                            option:SetValue({Color = v.Color, Transparency = v.Transparency})
                        end
                    end
                end
            end
        end
    end
    
    -- Function to create new tabs
    function menu.new_tab(icon)
        local tab = {}
        
        -- Create tab button
        local tabnum = #menu.tabs + 1
        tab.TabButton = Create("ImageButton", {
            Name = "Tab" .. tabnum,
            Parent = menu.TabContainer,
            BackgroundColor3 = theme.background_color,
            BorderColor3 = theme.outline_color,
            BorderSizePixel = 1,
            Position = UDim2.new(0, 0, 0, (#menu.tabs * 30)),
            Size = UDim2.new(1, 0, 0, 30),
            Image = icon,
            ScaleType = Enum.ScaleType.Fit,
            ImageColor3 = theme.text_color
        })
        
        -- Create tab content frame
        tab.Content = Create("ScrollingFrame", {
            Name = "Content" .. tabnum,
            Parent = menu.ContentContainer,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = theme.accent_color,
            Visible = false
        })
        
        -- Create UIListLayout for sections
        local UIListLayout = Create("UIListLayout", {
            Parent = tab.Content,
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })
        
        -- Tab Button Click to switch tabs
        tab.TabButton.MouseButton1Click:Connect(function()
            for i, v in pairs(menu.tabs) do
                v.Content.Visible = false
                v.TabButton.BackgroundColor3 = theme.background_color
            end
            tab.Content.Visible = true
            tab.TabButton.BackgroundColor3 = theme.main_color
        end)
        
        -- If this is the first tab, make it active
        if #menu.tabs == 0 then
            tab.Content.Visible = true
            tab.TabButton.BackgroundColor3 = theme.main_color
        end
        
        -- Initialize values table for this tab
        menu.values[tabnum] = {}
        menu.options[tabnum] = {}
        
        -- Function to create new sections in this tab
        function tab.new_section(name, side)
            local section = {}
            menu.values[tabnum][name] = {}
            menu.options[tabnum][name] = {}
            
            -- Create section container
            section.Container = Create("Frame", {
                Name = name,
                Parent = tab.Content,
                BackgroundColor3 = theme.main_color,
                BorderColor3 = theme.outline_color,
                BorderSizePixel = 1,
                Size = UDim2.new(0, 260, 0, 35),
                LayoutOrder = (side == "Right") and 2 or 1
            })
            
            -- Create section title
            section.Title = Create("TextLabel", {
                Name = "Title",
                Parent = section.Container,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 0, 30),
                Font = Enum.Font.SourceSansBold,
                Text = name,
                TextColor3 = theme.text_color,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            -- Create content frame for elements
            section.Content = Create("Frame", {
                Name = "Content",
                Parent = section.Container,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 5, 0, 30),
                Size = UDim2.new(1, -10, 1, -35)
            })
            
            -- Add UIListLayout for elements
            section.UIListLayout = Create("UIListLayout", {
                Parent = section.Content,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 5)
            })
            
            -- Update section size based on content
            section.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                section.Container.Size = UDim2.new(0, 260, 0, section.UIListLayout.AbsoluteContentSize.Y + 35)
                tab.Content.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
            end)
            
            -- Element creation function
            function section.element(type, name, options, callback)
                local element = {}
                element.Type = type
                element.Name = name
                element.Callback = callback
                element.Options = options or {}
                
                -- Initialize element value in menu.values
                if not menu.values[tabnum][section.Title.Text][name] then
                    if type == "Toggle" then
                        menu.values[tabnum][section.Title.Text][name] = {Toggle = false}
                    elseif type == "Slider" then
                        menu.values[tabnum][section.Title.Text][name] = {Slider = element.Options.default and element.Options.default.default or 0}
                    elseif type == "Dropdown" then
                        menu.values[tabnum][section.Title.Text][name] = {Dropdown = element.Options.default or element.Options.options[1]}
                    elseif type == "Combo" then
                        menu.values[tabnum][section.Title.Text][name] = {Combo = element.Options.default and element.Options.default.Combo or {}}
                    elseif type == "TextBox" then
                        menu.values[tabnum][section.Title.Text][name] = {Text = ""}
                    end
                end
                
                menu.options[tabnum][section.Title.Text][name] = element
                
                -- Create base container for all element types
                element.Container = Create("Frame", {
                    Name = name,
                    Parent = section.Content,
                    BackgroundColor3 = theme.background_color,
                    BorderColor3 = theme.outline_color,
                    BorderSizePixel = 1,
                    Size = UDim2.new(1, 0, 0, 30)
                })
                
                -- Create base title for all element types
                element.Title = Create("TextLabel", {
                    Name = "Title",
                    Parent = element.Container,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 5, 0, 0),
                    Size = UDim2.new(1, -10, 1, 0),
                    Font = Enum.Font.SourceSans,
                    Text = name,
                    TextColor3 = theme.text_color,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                -- Create different element types
                if type == "Toggle" then
                    -- Create toggle button
                    element.Toggle = Create("Frame", {
                        Name = "Toggle",
                        Parent = element.Container,
                        BackgroundColor3 = theme.background_color,
                        BorderColor3 = theme.outline_color,
                        BorderSizePixel = 1,
                        Position = UDim2.new(1, -25, 0.5, -8),
                        Size = UDim2.new(0, 16, 0, 16)
                    })
                    
                    element.ToggleInner = Create("Frame", {
                        Name = "Inner",
                        Parent = element.Toggle,
                        BackgroundColor3 = theme.accent_color,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 1, 0),
                        Visible = false
                    })
                    
                    -- Toggle functionality
                    element.Container.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            menu.values[tabnum][section.Title.Text][name].Toggle = not menu.values[tabnum][section.Title.Text][name].Toggle
                            element.ToggleInner.Visible = menu.values[tabnum][section.Title.Text][name].Toggle
                            
                            if element.Callback then
                                element.Callback(menu.values[tabnum][section.Title.Text][name])
                            end
                        end
                    end)
                    
                    -- Function to add keybind to toggle
                    function element:add_keybind(default, callback)
                        local keybind = {}
                        menu.values[tabnum][section.Title.Text]["$" .. name] = {Key = default or "None", Active = false}
                        
                        -- Create keybind button
                        keybind.Button = Create("TextButton", {
                            Name = "Keybind",
                            Parent = element.Container,
                            BackgroundColor3 = theme.background_color,
                            BorderColor3 = theme.outline_color,
                            BorderSizePixel = 1,
                            Position = UDim2.new(1, -50, 0.5, -8),
                            Size = UDim2.new(0, 20, 0, 16),
                            Font = Enum.Font.SourceSans,
                            Text = default or "...",
                            TextColor3 = theme.text_color,
                            TextSize = 14
                        })
                        
                        -- Keybind functionality
                        local listening = false
                        
                        keybind.Button.MouseButton1Click:Connect(function()
                            listening = true
                            keybind.Button.Text = "..."
                        end)
                        
                        UserInputService.InputBegan:Connect(function(input)
                            if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                                listening = false
                                menu.values[tabnum][section.Title.Text]["$" .. name].Key = input.KeyCode.Name
                                keybind.Button.Text = input.KeyCode.Name
                            elseif not listening and input.UserInputType == Enum.UserInputType.Keyboard then
                                if input.KeyCode.Name == menu.values[tabnum][section.Title.Text]["$" .. name].Key then
                                    menu.values[tabnum][section.Title.Text]["$" .. name].Active = not menu.values[tabnum][section.Title.Text]["$" .. name].Active
                                    
                                    if callback then
                                        callback(menu.values[tabnum][section.Title.Text]["$" .. name])
                                    end
                                end
                            end
                        end)
                        
                        return keybind
                    end
                    
                    -- Function to add color picker to toggle
                    function element:add_color(default, transparency)
                        local colorpicker = {}
                        menu.values[tabnum][section.Title.Text]["$" .. name] = {
                            Color = default and default.Color or Color3.new(1, 1, 1),
                            Transparency = default and default.Transparency or 0
                        }
                        
                        -- Create color display
                        colorpicker.Display = Create("Frame", {
                            Name = "ColorDisplay",
                            Parent = element.Container,
                            BackgroundColor3 = menu.values[tabnum][section.Title.Text]["$" .. name].Color,
                            BorderColor3 = theme.outline_color,
                            BorderSizePixel = 1,
                            Position = UDim2.new(1, -80, 0.5, -8),
                            Size = UDim2.new(0, 16, 0, 16)
                        })
                        
                        colorpicker.Display.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                -- Here we would create a color picker popup
                                -- Simplified for this example - just cycle through some colors
                                local colors = {
                                    Color3.new(1, 1, 1),     -- White
                                    Color3.new(0, 0, 0),     -- Black
                                    Color3.new(0.5, 0.5, 0.5) -- Gray
                                }
                                
                                local currentIndex = 1
                                for i, color in ipairs(colors) do
                                    if color == menu.values[tabnum][section.Title.Text]["$" .. name].Color then
                                        currentIndex = i
                                        break
                                    end
                                end
                                
                                currentIndex = currentIndex % #colors + 1
                                menu.values[tabnum][section.Title.Text]["$" .. name].Color = colors[currentIndex]
                                colorpicker.Display.BackgroundColor3 = colors[currentIndex]
                            end
                        end)
                        
                        -- For full implementation, we would need to create a complete color picker UI
                        
                        return colorpicker
                    end
                    
                    function element:SetValue(value)
                        menu.values[tabnum][section.Title.Text][name].Toggle = value
                        element.ToggleInner.Visible = value
                        
                        if element.Callback then
                            element.Callback(menu.values[tabnum][section.Title.Text][name])
                        end
                    end
                    
                elseif type == "Slider" then
                    -- Create slider
                    element.Slider = Create("Frame", {
                        Name = "Slider",
                        Parent = element.Container,
                        BackgroundColor3 = theme.background_color,
                        BorderColor3 = theme.outline_color,
                        BorderSizePixel = 1,
                        Position = UDim2.new(0, 0, 0, 30),
                        Size = UDim2.new(1, 0, 0, 20)
                    })
                    
                    element.SliderFill = Create("Frame", {
                        Name = "Fill",
                        Parent = element.Slider,
                        BackgroundColor3 = theme.accent_color,
                        BorderSizePixel = 0,
                        Size = UDim2.new(0, 0, 1, 0)
                    })
                    
                    element.SliderValue = Create("TextLabel", {
                        Name = "Value",
                        Parent = element.Slider,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        Font = Enum.Font.SourceSans,
                        Text = tostring(menu.values[tabnum][section.Title.Text][name].Slider),
                        TextColor3 = theme.text_color,
                        TextSize = 14
                    })
                    
                    -- Adjust container size for slider
                    element.Container.Size = UDim2.new(1, 0, 0, 55)
                    
                    -- Slider functionality
                    local sliding = false
                    local min = element.Options.default and element.Options.default.min or 0
                    local max = element.Options.default and element.Options.default.max or 100
                    
                    local function updateSlider(input)
                        local position = math.clamp((input.Position.X - element.Slider.AbsolutePosition.X) / element.Slider.AbsoluteSize.X, 0, 1)
                        local value = math.floor(min + (max - min) * position)
                        
                        menu.values[tabnum][section.Title.Text][name].Slider = value
                        element.SliderValue.Text = tostring(value)
                        element.SliderFill.Size = UDim2.new(position, 0, 1, 0)
                        
                        if element.Callback then
                            element.Callback(menu.values[tabnum][section.Title.Text][name])
                        end
                    end
                    
                    element.Slider.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            sliding = true
                            updateSlider(input)
                        end
                    end)
                    
                    element.Slider.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            sliding = false
                        end
                    end)
                    
                    UserInputService.InputChanged:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseMovement and sliding then
                            updateSlider(input)
                        end
                    end)
                    
                    -- Initialize slider
                    local defaultVal = element.Options.default and element.Options.default.default or min
                    local position = (defaultVal - min) / (max - min)
                    element.SliderFill.Size = UDim2.new(position, 0, 1, 0)
                    element.SliderValue.Text = tostring(defaultVal)
                    menu.values[tabnum][section.Title.Text][name].Slider = defaultVal
                    
                    function element:SetValue(value)
                        local position = (value - min) / (max - min)
                        element.SliderFill.Size = UDim2.new(position, 0, 1, 0)
                        element.SliderValue.Text = tostring(value)
                        menu.values[tabnum][section.Title.Text][name].Slider = value
                        
                        if element.Callback then
                            element.Callback(menu.values[tabnum][section.Title.Text][name])
                        end
                    end
                    
                elseif type == "Dropdown" then
                    -- Create dropdown
                    element.Dropdown = Create("Frame", {
                        Name = "Dropdown",
                        Parent = element.Container,
                        BackgroundColor3 = theme.background_color,
                        BorderColor3 = theme.outline_color,
                        BorderSizePixel = 1,
                        Position = UDim2.new(0, 0, 0, 30),
                        Size = UDim2.new(1, 0, 0, 20)
                    })
                    
                    element.DropdownButton = Create("TextButton", {
                        Name = "Button",
                        Parent = element.Dropdown,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        Font = Enum.Font.SourceSans,
                        Text = element.Options.default or element.Options.options[1],
                        TextColor3 = theme.text_color,
                        TextSize = 14
                    })
                    
                    element.DropdownItems = Create("Frame", {
                        Name = "Items",
                        Parent = element.Container,
                        BackgroundColor3 = theme.background_color,
                        BorderColor3 = theme.outline_color,
                        BorderSizePixel = 1,
                        Position = UDim2.new(0, 0, 0, 55),
                        Size = UDim2.new(1, 0, 0, 0),
                        Visible = false,
                        ClipsDescendants = true,
                        ZIndex = 10
                    })
                    
                    local UIListLayout = Create("UIListLayout", {
                        Parent = element.DropdownItems,
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })
                    
                    -- Adjust container size for dropdown
                    element.Container.Size = UDim2.new(1, 0, 0, 55)
                    
                    -- Add dropdown items
                    for _, option in ipairs(element.Options.options) do
                        local item = Create("TextButton", {
                            Name = option,
                            Parent = element.DropdownItems,
                            BackgroundColor3 = theme.background_color,
                            BackgroundTransparency = 0,
                            BorderSizePixel = 0,
                            Size = UDim2.new(1, 0, 0, 20),
                            Font = Enum.Font.SourceSans,
                            Text = option,
                            TextColor3 = theme.text_color,
                            TextSize = 14,
                            ZIndex = 11
                        })
                        
                        item.MouseButton1Click:Connect(function()
                            menu.values[tabnum][section.Title.Text][name].Dropdown = option
                            element.DropdownButton.Text = option
                            element.DropdownItems.Visible = false
                            element.DropdownItems.Size = UDim2.new(1, 0, 0, 0)
                            
                            if element.Callback then
                                element.Callback(menu.values[tabnum][section.Title.Text][name])
                            end
                        end)
                    end
                    
                    -- Dropdown button functionality
                    local dropdownOpen = false
                    
                    element.DropdownButton.MouseButton1Click:Connect(function()
                        dropdownOpen = not dropdownOpen
                        
                        if dropdownOpen then
                            element.DropdownItems.Visible = true
                            element.DropdownItems.Size = UDim2.new(1, 0, 0, #element.Options.options * 20)
                        else
                            element.DropdownItems.Visible = false
                            element.DropdownItems.Size = UDim2.new(1, 0, 0, 0)
                        end
                    end)
                    
                    function element:SetValue(value)
                        menu.values[tabnum][section.Title.Text][name].Dropdown = value
                        element.DropdownButton.Text = value
                        
                        if element.Callback then
                            element.Callback(menu.values[tabnum][section.Title.Text][name])
                        end
                    end
                    
                elseif type == "Combo" then
                    -- Create combo box (multi-select)
                    element.Combo = Create("Frame", {
                        Name = "Combo",
                        Parent = element.Container,
                        BackgroundColor3 = theme.background_color,
                        BorderColor3 = theme.outline_color,
                        BorderSizePixel = 1,
                        Position = UDim2.new(0, 0, 0, 30),
                        Size = UDim2.new(1, 0, 0, 20)
                    })
                    
                    element.ComboButton = Create("TextButton", {
                        Name = "Button",
                        Parent = element.Combo,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        Font = Enum.Font.SourceSans,
                        Text = "...",
                        TextColor3 = theme.text_color,
                        TextSize = 14
                    })
                    
                    element.ComboItems = Create("Frame", {
                        Name = "Items",
                        Parent = element.Container,
                        BackgroundColor3 = theme.background_color,
                        BorderColor3 = theme.outline_color,
                        BorderSizePixel = 1,
                        Position = UDim2.new(0, 0, 0, 55),
                        Size = UDim2.new(1, 0, 0, 0),
                        Visible = false,
                        ClipsDescendants = true,
                        ZIndex = 10
                    })
                    
                    local UIListLayout = Create("UIListLayout", {
                        Parent = element.ComboItems,
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })
                    
                    -- Adjust container size for combo
                    element.Container.Size = UDim2.new(1, 0, 0, 55)
                    
                    -- Initialize combo values
                    menu.values[tabnum][section.Title.Text][name].Combo = element.Options.default and element.Options.default.Combo or {}
                    
                    -- Update combo display text
                    local function updateComboText()
                        local selected = {}
                        for _, opt in ipairs(menu.values[tabnum][section.Title.Text][name].Combo) do
                            table.insert(selected, opt)
                        end
                        
                        if #selected == 0 then
                            element.ComboButton.Text = "..."
                        else
                            element.ComboButton.Text = table.concat(selected, ", ")
                        end
                    end
                    
                    -- Add combo items
                    for _, option in ipairs(element.Options.options) do
                        local item = Create("TextButton", {
                            Name = option,
                            Parent = element.ComboItems,
                            BackgroundColor3 = theme.background_color,
                            BackgroundTransparency = 0,
                            BorderSizePixel = 0,
                            Size = UDim2.new(1, 0, 0, 20),
                            Font = Enum.Font.SourceSans,
                            Text = option,
                            TextColor3 = theme.text_color,
                            TextSize = 14,
                            ZIndex = 11
                        })
                        
                        -- Create checkbox
                        local checkbox = Create("Frame", {
                            Name = "Checkbox",
                            Parent = item,
                            BackgroundColor3 = theme.background_color,
                            BorderColor3 = theme.outline_color,
                            BorderSizePixel = 1,
                            Position = UDim2.new(1, -20, 0.5, -7),
                            Size = UDim2.new(0, 14, 0, 14),
                            ZIndex = 12
                        })
                        
                        local checkboxFill = Create("Frame", {
                            Name = "Fill",
                            Parent = checkbox,
                            BackgroundColor3 = theme.accent_color,
                            BorderSizePixel = 0,
                            Size = UDim2.new(1, 0, 1, 0),
                            Visible = false,
                            ZIndex = 13
                        })
                        
                        -- Check if this option is selected by default
                        if element.Options.default and element.Options.default.Combo then
                            for _, default in ipairs(element.Options.default.Combo) do
                                if default == option then
                                    checkboxFill.Visible = true
                                    table.insert(menu.values[tabnum][section.Title.Text][name].Combo, option)
                                end
                            end
                        end
                        
                        item.MouseButton1Click:Connect(function()
                            local found = false
                            local foundIndex = 0
                            
                            for i, selected in ipairs(menu.values[tabnum][section.Title.Text][name].Combo) do
                                if selected == option then
                                    found = true
                                    foundIndex = i
                                    break
                                end
                            end
                            
                            if found then
                                table.remove(menu.values[tabnum][section.Title.Text][name].Combo, foundIndex)
                                checkboxFill.Visible = false
                            else
                                table.insert(menu.values[tabnum][section.Title.Text][name].Combo, option)
                                checkboxFill.Visible = true
                            end
                            
                            updateComboText()
                            
                            if element.Callback then
                                element.Callback(menu.values[tabnum][section.Title.Text][name])
                            end
                        end)
                    end
                    
                    -- Combo button functionality
                    local comboOpen = false
                    
                    element.ComboButton.MouseButton1Click:Connect(function()
                        comboOpen = not comboOpen
                        
                        if comboOpen then
                            element.ComboItems.Visible = true
                            element.ComboItems.Size = UDim2.new(1, 0, 0, #element.Options.options * 20)
                        else
                            element.ComboItems.Visible = false
                            element.ComboItems.Size = UDim2.new(1, 0, 0, 0)
                        end
                    end)
                    
                    -- Update initial text
                    updateComboText()
                    
                    function element:SetValue(value)
                        menu.values[tabnum][section.Title.Text][name].Combo = value
                        
                        -- Update checkboxes
                        for _, item in ipairs(element.ComboItems:GetChildren()) do
                            if item:IsA("TextButton") then
                                local checkbox = item:FindFirstChild("Checkbox")
                                if checkbox then
                                    local fill = checkbox:FindFirstChild("Fill")
                                    if fill then
                                        fill.Visible = false
                                        
                                        for _, selected in ipairs(value) do
                                            if selected == item.Name then
                                                fill.Visible = true
                                                break
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        
                        updateComboText()
                        
                        if element.Callback then
                            element.Callback(menu.values[tabnum][section.Title.Text][name])
                        end
                    end
                    
                elseif type == "Button" then
                    -- Create button
                    element.Container.Size = UDim2.new(1, 0, 0, 30)
                    
                    element.Button = Create("TextButton", {
                        Name = "Button",
                        Parent = element.Container,
                        BackgroundColor3 = theme.accent_color,
                        BorderColor3 = theme.outline_color,
                        BorderSizePixel = 1,
                        Position = UDim2.new(0.5, -40, 0.5, -10),
                        Size = UDim2.new(0, 80, 0, 20),
                        Font = Enum.Font.SourceSans,
                        Text = name,
                        TextColor3 = theme.text_color,
                        TextSize = 14
                    })
                    
                    element.Container.BackgroundTransparency = 1
                    element.Container.BorderSizePixel = 0
                    element.Title.Visible = false
                    
                    -- Button functionality
                    element.Button.MouseButton1Click:Connect(function()
                        if element.Callback then
                            element.Callback()
                        end
                    end)
                    
                elseif type == "TextBox" then
                    -- Create textbox
                    element.Textbox = Create("TextBox", {
                        Name = "TextBox",
                        Parent = element.Container,
                        BackgroundColor3 = theme.background_color,
                        BorderColor3 = theme.outline_color,
                        BorderSizePixel = 1,
                        Position = UDim2.new(1, -100, 0.5, -10),
                        Size = UDim2.new(0, 90, 0, 20),
                        Font = Enum.Font.SourceSans,
                        Text = "",
                        TextColor3 = theme.text_color,
                        TextSize = 14,
                        ClearTextOnFocus = false
                    })
                    
                    -- Textbox functionality
                    element.Textbox.FocusLost:Connect(function(enterPressed)
                        menu.values[tabnum][section.Title.Text][name].Text = element.Textbox.Text
                        
                        if element.Callback then
                            element.Callback(menu.values[tabnum][section.Title.Text][name])
                        end
                    end)
                    
                    function element:set_value(value)
                        element.Textbox.Text = value.Text
                        menu.values[tabnum][section.Title.Text][name].Text = value.Text
                    end
                    
                elseif type == "Scroll" then
                    -- Create scrolling list
                    element.Container.Size = UDim2.new(1, 0, 0, 120)
                    
                    element.Scroll = Create("ScrollingFrame", {
                        Name = "ScrollList",
                        Parent = element.Container,
                        BackgroundColor3 = theme.background_color,
                        BorderColor3 = theme.outline_color,
                        BorderSizePixel = 1,
                        Position = UDim2.new(0, 0, 0, 25),
                        Size = UDim2.new(1, 0, 0, 95),
                        CanvasSize = UDim2.new(0, 0, 0, 0),
                        ScrollBarThickness = 4,
                        ScrollBarImageColor3 = theme.accent_color
                    })
                    
                    local UIListLayout = Create("UIListLayout", {
                        Parent = element.Scroll,
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })
                    
                    -- Initialize scroll values
                    menu.values[tabnum][section.Title.Text][name] = {Scroll = element.Options.options[1]}
                    
                    -- Add scroll items
                    for _, option in ipairs(element.Options.options) do
                        local item = Create("TextButton", {
                            Name = option,
                            Parent = element.Scroll,
                            BackgroundColor3 = theme.background_color,
                            BorderSizePixel = 1,
                            BorderColor3 = theme.outline_color,
                            Size = UDim2.new(1, -4, 0, 25),
                            Font = Enum.Font.SourceSans,
                            Text = option,
                            TextColor3 = theme.text_color,
                            TextSize = 14
                        })
                        
                        item.MouseButton1Click:Connect(function()
                            menu.values[tabnum][section.Title.Text][name].Scroll = option
                            
                            if element.Callback then
                                element.Callback(menu.values[tabnum][section.Title.Text][name])
                            end
                        end)
                    end
                    
                    -- Update scroll canvas size
                    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                        element.Scroll.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
                    end)
                    
                    function element:add_value(value)
                        -- Check if value already exists
                        for _, child in ipairs(element.Scroll:GetChildren()) do
                            if child:IsA("TextButton") and child.Name == value then
                                return
                            end
                        end
                        
                        local item = Create("TextButton", {
                            Name = value,
                            Parent = element.Scroll,
                            BackgroundColor3 = theme.background_color,
                            BorderSizePixel = 1,
                            BorderColor3 = theme.outline_color,
                            Size = UDim2.new(1, -4, 0, 25),
                            Font = Enum.Font.SourceSans,
                            Text = value,
                            TextColor3 = theme.text_color,
                            TextSize = 14
                        })
                        
                        item.MouseButton1Click:Connect(function()
                            menu.values[tabnum][section.Title.Text][name].Scroll = value
                            
                            if element.Callback then
                                element.Callback(menu.values[tabnum][section.Title.Text][name])
                            end
                        end)
                    end
                end
                
                return element
            end
            
            return section
        end
        
        table.insert(menu.tabs, tab)
        return tab
    end
    
    -- Function to update theme
    function menu:set_theme(new_theme)
        for k, v in pairs(new_theme) do
            theme[k] = v
        end
        
        -- Update UI elements with new theme
        menu.Main.BackgroundColor3 = theme.main_color
        menu.Main.BorderColor3 = theme.outline_color
        menu.TopBar.BackgroundColor3 = theme.accent_color
        menu.TopBar.BorderColor3 = theme.outline_color
        menu.Title.TextColor3 = theme.text_color
        menu.CloseButton.TextColor3 = theme.text_color
        menu.TabContainer.BackgroundColor3 = theme.background_color
        menu.TabContainer.BorderColor3 = theme.outline_color
        menu.ContentContainer.BackgroundColor3 = theme.background_color
        menu.ContentContainer.BorderColor3 = theme.outline_color
        
        -- Update tabs and elements
        for _, tab in pairs(menu.tabs) do
            tab.TabButton.BackgroundColor3 = theme.background_color
            tab.TabButton.BorderColor3 = theme.outline_color
            tab.TabButton.ImageColor3 = theme.text_color
            
            if tab.Content.Visible then
                tab.TabButton.BackgroundColor3 = theme.main_color
            end
            
            for _, child in pairs(tab.Content:GetChildren()) do
                if child:IsA("Frame") then
                    child.BackgroundColor3 = theme.main_color
                    child.BorderColor3 = theme.outline_color
                    
                    for _, content in pairs(child:GetChildren()) do
                        if content:IsA("TextLabel") then
                            content.TextColor3 = theme.text_color
                        elseif content:IsA("Frame") and content.Name == "Content" then
                            for _, element in pairs(content:GetChildren()) do
                                if element:IsA("Frame") then
                                    element.BackgroundColor3 = theme.background_color
                                    element.BorderColor3 = theme.outline_color
                                    
                                    for _, child in pairs(element:GetChildren()) do
                                        if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                                            child.TextColor3 = theme.text_color
                                        end
                                        
                                        if child:IsA("Frame") then
                                            child.BorderColor3 = theme.outline_color
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    return menu
end

return library
