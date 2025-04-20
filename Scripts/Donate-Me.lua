local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Configuration
local ROBUX_AMOUNT = 5
local PRODUCT_ID = 1234567890  -- Replace with your actual product ID for the 5 Robux donation
local EXTERNAL_SCRIPT_URL = "https://example.com/script.lua"  -- Replace with your actual script URL

-- Cleanup any existing GUI with the same name
local function cleanupExistingGui()
    pcall(function()
        if CoreGui:FindFirstChild("BWDonationMenu") then
            CoreGui.BWDonationMenu:Destroy()
        end
        
        if game:GetService("Lighting"):FindFirstChild("MenuBlur") then
            game:GetService("Lighting").MenuBlur:Destroy()
        end
    end)
end

-- GUI Creation
local function createDonationGui()
    -- Clean up any existing GUI first
    cleanupExistingGui()
    
    -- Create ScreenGui with protection from being destroyed
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BWDonationMenu"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global -- Ensure maximum Z-index behavior
    screenGui.DisplayOrder = 2147483647  -- Maximum integer value for DisplayOrder, absolutely over EVERYTHING
    
    -- Apply protection for external executors
    pcall(function()
        screenGui.IgnoreGuiInset = true  -- Ignore the TopBar inset
        
        -- Synapse X and other executors protection
        syn = syn or {}
        if syn and syn.protect_gui then
            syn.protect_gui(screenGui)
        end
        
        -- Try different parent methods for compatibility
        if gethui then
            screenGui.Parent = gethui()
        elseif CoreGui:FindFirstChild("RobloxGui") then
            screenGui.Parent = CoreGui.RobloxGui
        else
            screenGui.Parent = CoreGui
        end
    end)
    
    if not screenGui.Parent then
        screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Create blur effect for background (100% maximized)
    local blurEffect = Instance.new("BlurEffect")
    blurEffect.Size = 0  -- Start at 0, will be tweened to maximum
    blurEffect.Name = "MenuBlur"
    blurEffect.Parent = game:GetService("Lighting")
    
    -- Background dim overlay (full screen)
    local backgroundDim = Instance.new("Frame")
    backgroundDim.Name = "BackgroundDim"
    backgroundDim.Size = UDim2.new(1, 0, 1, 0)
    backgroundDim.Position = UDim2.new(0, 0, 0, 0)
    backgroundDim.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    backgroundDim.BackgroundTransparency = 1
    backgroundDim.ZIndex = 5
    backgroundDim.Parent = screenGui
    
    -- Create main frame with clean black design
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 340, 0, 220)
    mainFrame.Position = UDim2.new(0.5, -170, 0.5, -110)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15) -- Almost black
    mainFrame.BackgroundTransparency = 0.1 -- Almost solid
    mainFrame.BorderSizePixel = 0
    mainFrame.ZIndex = 10
    mainFrame.Parent = screenGui
    
    -- Add Active property to false to prevent dragging
    mainFrame.Active = false
    
    -- Create rounded corners
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 10)
    uiCorner.Parent = mainFrame
    
    -- Add border outline
    local borderStroke = Instance.new("UIStroke")
    borderStroke.Color = Color3.fromRGB(255, 255, 255)
    borderStroke.Thickness = 1.5
    borderStroke.Transparency = 0.7
    borderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    borderStroke.Parent = mainFrame
    
    -- Create title with clean styling
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, 0, 0, 50)
    titleLabel.Position = UDim2.new(0, 0, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = "DONATION MENU"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 24
    titleLabel.ZIndex = 12
    titleLabel.Parent = mainFrame
    
    -- Create description with simple styling
    local descriptionLabel = Instance.new("TextLabel")
    descriptionLabel.Name = "DescriptionLabel"
    descriptionLabel.Size = UDim2.new(1, -60, 0, 40)
    descriptionLabel.Position = UDim2.new(0, 30, 0, 60)
    descriptionLabel.BackgroundTransparency = 1
    descriptionLabel.Font = Enum.Font.Gotham
    descriptionLabel.Text = "Would you like to donate 5 Robux?"
    descriptionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    descriptionLabel.TextSize = 16
    descriptionLabel.TextWrapped = true
    descriptionLabel.ZIndex = 12
    descriptionLabel.Parent = mainFrame
    
    -- Create donate button with white styling
    local donateButton = Instance.new("TextButton")
    donateButton.Name = "DonateButton"
    donateButton.Size = UDim2.new(0, 140, 0, 50)
    donateButton.Position = UDim2.new(0, 30, 1, -70)
    donateButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    donateButton.Font = Enum.Font.GothamBold
    donateButton.Text = "DONATE 5R$"
    donateButton.TextColor3 = Color3.fromRGB(10, 10, 10)
    donateButton.TextSize = 16
    donateButton.ZIndex = 12
    donateButton.Parent = mainFrame
    
    -- Create rounded corners for donate button
    local donateCorner = Instance.new("UICorner")
    donateCorner.CornerRadius = UDim.new(0, 8)
    donateCorner.Parent = donateButton
    
    -- Create no button with black styling
    local noButton = Instance.new("TextButton")
    noButton.Name = "NoButton"
    noButton.Size = UDim2.new(0, 100, 0, 50)
    noButton.Position = UDim2.new(1, -130, 1, -70)
    noButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    noButton.Font = Enum.Font.GothamBold
    noButton.Text = "Fuck No"
    noButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    noButton.TextSize = 16
    noButton.ZIndex = 12
    noButton.Parent = mainFrame
    
    -- Create rounded corners for no button
    local noCorner = Instance.new("UICorner")
    noCorner.CornerRadius = UDim.new(0, 8)
    noCorner.Parent = noButton
    
    -- Add white outline to no button
    local noBorder = Instance.new("UIStroke")
    noBorder.Color = Color3.fromRGB(100, 100, 100)
    noBorder.Thickness = 1
    noBorder.Transparency = 0.5
    noBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    noBorder.Parent = noButton
    
    -- Add shadow effect
    local mainShadow = Instance.new("ImageLabel")
    mainShadow.Name = "Shadow"
    mainShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    mainShadow.BackgroundTransparency = 1
    mainShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainShadow.Size = UDim2.new(1, 30, 1, 30)
    mainShadow.ZIndex = 9
    mainShadow.Image = "rbxassetid://6014261993"  -- Shadow asset
    mainShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    mainShadow.ImageTransparency = 0.6
    mainShadow.Parent = mainFrame
    
    -- Button hover effects with subtle animations
    local function buttonHoverEffect(button, isWhite)
        local originalColor = button.BackgroundColor3
        local hoverColor = isWhite and Color3.fromRGB(230, 230, 230) or Color3.fromRGB(40, 40, 40)
        local originalTextColor = button.TextColor3
        local hoverTextColor = isWhite and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
        
        button.MouseEnter:Connect(function()
            -- Color animation
            local colorTween = TweenService:Create(button, TweenInfo.new(0.3), {
                BackgroundColor3 = hoverColor,
                TextColor3 = hoverTextColor
            })
            colorTween:Play()
        end)
        
        button.MouseLeave:Connect(function()
            -- Color animation
            local colorTween = TweenService:Create(button, TweenInfo.new(0.3), {
                BackgroundColor3 = originalColor,
                TextColor3 = originalTextColor
            })
            colorTween:Play()
        end)
    end
    
    buttonHoverEffect(donateButton, true)  -- White button
    buttonHoverEffect(noButton, false)     -- Black button
    
    -- Add blur effect animation (100% maximized)
    local blurTween = TweenService:Create(blurEffect, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = 56  -- Maximum blur effect (100%)
    })
    blurTween:Play()
    
    -- Add background dim animation (darker for better visibility)
    local dimTween = TweenService:Create(backgroundDim, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.3  -- More opaque for better visibility
    })
    dimTween:Play()
    
    -- Adding a subtle floating animation to the main frame
    spawn(function()
        local floatTween = TweenService:Create(mainFrame, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
            Position = mainFrame.Position + UDim2.new(0, 0, 0, 5)  -- Subtle vertical movement
        })
        floatTween:Play()
    end)
    
    -- Prevent dragging through input checking
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            -- Check if click is within main frame
            local mousePos = UserInputService:GetMouseLocation()
            local framePos = mainFrame.AbsolutePosition
            local frameSize = mainFrame.AbsoluteSize
            
            if mousePos.X >= framePos.X and mousePos.X <= framePos.X + frameSize.X and
               mousePos.Y >= framePos.Y and mousePos.Y <= framePos.Y + frameSize.Y then
                -- Prevent default behavior to ensure no dragging
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            -- Reset position if it somehow moved
                            mainFrame.Position = UDim2.new(0.5, -170, 0.5, -110)
                        end
                    end)
                end
            end
        end
    end)
    
    return screenGui, donateButton, noButton, blurEffect, backgroundDim
end

-- Function to load external script
local function loadExternalScript()
    local success, result = pcall(function()
        return loadstring(game:HttpGet(EXTERNAL_SCRIPT_URL, true))()
    end)
    
    if not success then
        warn("Failed to load external script: " .. tostring(result))
    else
        print("External script loaded successfully!")
    end
end

-- Function to handle donation
local function processDonation()
    local success, result = pcall(function()
        MarketplaceService:PromptProductPurchase(LocalPlayer, PRODUCT_ID)
    end)
    
    if not success then
        warn("Failed to process donation: " .. tostring(result))
    end
end

-- Main function to create and set up the menu
local function setupDonationMenu()
    -- Create the GUI
    local gui, donateButton, noButton, blurEffect, backgroundDim = createDonationGui()
    
    -- Set up button events
    donateButton.MouseButton1Click:Connect(function()
        -- Process donation
        processDonation()
        
        -- Animate closing
        local blurTween = TweenService:Create(blurEffect, TweenInfo.new(0.5), {
            Size = 0
        })
        
        local dimTween = TweenService:Create(backgroundDim, TweenInfo.new(0.5), {
            BackgroundTransparency = 1
        })
        
        blurTween:Play()
        dimTween:Play()
        
        -- Load external script
        spawn(function()
            loadExternalScript()
        end)
        
        -- Remove GUI after animation
        delay(0.5, function()
            gui:Destroy()
            blurEffect:Destroy()
        end)
    end)
    
    noButton.MouseButton1Click:Connect(function()
        -- Animate closing
        local blurTween = TweenService:Create(blurEffect, TweenInfo.new(0.5), {
            Size = 0
        })
        
        local dimTween = TweenService:Create(backgroundDim, TweenInfo.new(0.5), {
            BackgroundTransparency = 1
        })
        
        blurTween:Play()
        dimTween:Play()
        
        -- Load external script
        spawn(function()
            loadExternalScript()
        end)
        
        -- Remove GUI after animation
        delay(0.5, function()
            gui:Destroy()
            blurEffect:Destroy()
        end)
    end)
    
    -- Make sure UI never gets moved/dragged by checking position every frame
    RunService.RenderStepped:Connect(function()
        if gui and gui.Parent and gui:FindFirstChild("MainFrame") then
            local mainFrame = gui.MainFrame
            if mainFrame.Position ~= UDim2.new(0.5, -170, 0.5, -110) then
                mainFrame.Position = UDim2.new(0.5, -170, 0.5, -110)
            end
        else
            -- GUI was destroyed, disconnect this connection
            for _, connection in pairs(getconnections(RunService.RenderStepped)) do
                if connection.Function and string.find(tostring(connection.Function), "MainFrame") then
                    connection:Disconnect()
                end
            end
        end
    end)
end

-- Execute the script
setupDonationMenu()
