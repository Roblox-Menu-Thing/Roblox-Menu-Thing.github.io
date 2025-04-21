local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst   = game:GetService("ReplicatedFirst")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local Lighting          = game:GetService("Lighting")
local Players           = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer.PlayerGui
local Mouse       = LocalPlayer:GetMouse()
local Camera      = workspace.CurrentCamera
RunService.RenderStepped:Connect(function()
    Camera = workspace.CurrentCamera
end)

-- Helper function for creating instances
local function Create(Object, Properties, Parent)
    local Obj = Instance.new(Object)

    for i,v in pairs (Properties) do
        Obj[i] = v
    end
    if Parent ~= nil then
        Obj.Parent = Parent
    end

    return Obj
end

-- Character utility functions
local function GetCharacter()
    return LocalPlayer.Character
end

local function GetHumanoid()
    local Character = GetCharacter()
    if Character then
        return Character:FindFirstChildOfClass("Humanoid")
    end
    return nil
end

local function GetHealth()
    local Humanoid = GetHumanoid()
    if Humanoid then
        return Humanoid.Health
    end
    return 0
end

local function GetBodypart(Part)
    local Character = GetCharacter()
    if Character then
        return Character:FindFirstChild(Part)
    end
    return nil
end

-- Initialize Menu
local menu
do
    local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Roblox-Menu-Thing/Roblox-Menu-Thing.github.io/refs/heads/main/Scripts/Menu/Lib/Lib.lua"))()

    -- Create a simplified menu with a meaningful title
    menu = library.new([[enhanced <font color="rgb(78, 93, 234)">aimbot</font>]], "simplecfg\\")
    
    -- Create only one tab instead of five
    local tabs = {
        menu.new_tab("http://www.roblox.com/asset/?id=7300477598"),
    }

    -- Create main features section
    local features = tabs[1].new_section("features")

    -- Create aimbot sector (enhanced)
    local aimbot = features.new_sector("aimbot")
    aimbot.element("Toggle", "enabled"):add_keybind()
    aimbot.element("Dropdown", "targeting mode", {options = {"mouse", "camera"}})
    aimbot.element("Dropdown", "hitbox", {options = {"head", "torso", "right arm", "left arm", "right leg", "left leg"}})
    aimbot.element("Toggle", "automatic fire")
    aimbot.element("Slider", "smoothness", {default = {min = 1, max = 10, default = 3}})
    
    -- Create FOV sector (replacing visuals)
    local fov_settings = features.new_sector("fov settings", "Right") 
    fov_settings.element("Toggle", "show fov"):add_color(Color3.fromRGB(255, 255, 255), true)
    fov_settings.element("Slider", "fov size", {default = {min = 10, max = 500, default = 100}})
    fov_settings.element("Toggle", "snap line"):add_color(Color3.fromRGB(255, 0, 0), true)
    fov_settings.element("Toggle", "visible check")
    fov_settings.element("Toggle", "team check")
    
    -- Create movement sector
    local movement = features.new_section("movement")
    movement.element("Toggle", "speed boost"):add_keybind()
    movement.element("Slider", "speed multiplier", {default = {min = 1, max = 10, default = 2}})
    movement.element("Toggle", "infinite jump"):add_keybind()
    
    -- Create utilities sector
    local utilities = movement.new_sector("utilities", "Right")
    utilities.element("Toggle", "noclip"):add_keybind()
    utilities.element("Toggle", "fullbright")
    utilities.element("Button", "respawn character", nil, function()
        local character = LocalPlayer.Character
        if character then
            character:BreakJoints()
        end
    end)
    
    -- Create config section
    local config = tabs[1].new_section("settings")
    
    -- Create configs sector
    local configs = config.new_sector("configs")
    local text
    local list = configs.element("Scroll", "config list", {options = {"none"}}, function(State)
        text:set_value({Text = State.Scroll})
    end)
    text = configs.element("TextBox", "config name")
    configs.element("Button", "save", nil, function()
        if menu.values[1].settings.configs["config name"].Text ~= "none" then
            menu.save_cfg(menu.values[1].settings.configs["config name"].Text)
        end
    end)
    configs.element("Button", "load", nil, function()
        if menu.values[1].settings.configs["config name"].Text ~= "none" then
            menu.load_cfg(menu.values[1].settings.configs["config name"].Text)
        end
    end)
    
    -- Function to update configs list
    local function update_cfgs()
        local all_cfgs = listfiles("simplecfg\\")
        for _,cfg in next, all_cfgs do
            local cfg_name = string.gsub(string.gsub(cfg, "simplecfg\\", ""), ".txt", "")
            list:add_value(cfg_name)
        end
    end 
    
    -- Initial config update
    pcall(update_cfgs)
    
    -- Periodically update configs list
    task.spawn(function()
        while true do
            wait(1)
            pcall(update_cfgs)
        end
    end)
    
    -- Create appearance sector
    local appearance = config.new_sector("appearance", "Right")
    appearance.element("Toggle", "watermark")
    appearance.element("Toggle", "keybind list")
    appearance.element("Dropdown", "menu theme", {options = {"default", "dark", "light"}})
    
    -- Create FOV Circle
    local FOVCircle = Drawing.new("Circle") 
    FOVCircle.Color = Color3.fromRGB(255, 255, 255)
    FOVCircle.Thickness = 1
    FOVCircle.Transparency = 1
    FOVCircle.Filled = false
    FOVCircle.Visible = false
    FOVCircle.NumSides = 64
    FOVCircle.Radius = 100
    
    RunService.RenderStepped:Connect(function()
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        
        -- Get config values safely
        local fovEnabled = false
        local fovSize = 100
        local fovColor = Color3.fromRGB(255, 255, 255)
        
        pcall(function()
            fovEnabled = menu.values[1].features["fov settings"]["show fov"].Toggle
            fovSize = menu.values[1].features["fov settings"]["fov size"].Slider
            fovColor = menu.values[1].features["fov settings"]["show fov"].Color
        end)
        
        -- Update FOV circle
        FOVCircle.Visible = fovEnabled
        FOVCircle.Radius = fovSize
        FOVCircle.Color = fovColor
    end)
    
    -- Create Snap Line
    local SnapLine = Drawing.new("Line")
    SnapLine.Color = Color3.fromRGB(255, 0, 0)
    SnapLine.Thickness = 1
    SnapLine.Transparency = 1
    SnapLine.Visible = false
    
    RunService.RenderStepped:Connect(function()
        -- Get config values safely
        local snapEnabled = false
        local snapColor = Color3.fromRGB(255, 0, 0)
        
        pcall(function()
            snapEnabled = menu.values[1].features["fov settings"]["snap line"].Toggle
            snapColor = menu.values[1].features["fov settings"]["snap line"].Color
        end)
        
        SnapLine.Color = snapColor
        
        -- SnapLine visibility is controlled in the aimbot function as it depends on the target
        if not snapEnabled then
            SnapLine.Visible = false
        end
    end)
    
    -- Fullbright functionality
    local originalBrightness = Lighting.Brightness
    local originalAmbient = Lighting.Ambient
    local originalOutdoorAmbient = Lighting.OutdoorAmbient
    
    utilities.element("Toggle", "fullbright", nil, function(state)
        if state.Toggle then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        else
            Lighting.Brightness = originalBrightness
            Lighting.ClockTime = Lighting.ClockTime
            Lighting.FogEnd = Lighting.FogEnd
            Lighting.GlobalShadows = true
            Lighting.OutdoorAmbient = originalOutdoorAmbient
        end
    end)
    
    -- Noclip functionality
    local noclipConnection = nil
    utilities.element("Toggle", "noclip", nil, function(state)
        if state.Toggle then
            if noclipConnection then
                noclipConnection:Disconnect()
            end
            
            noclipConnection = RunService.Stepped:Connect(function()
                local character = LocalPlayer.Character
                if character then
                    for _, part in pairs(character:GetDescendants()) do
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
            
            local character = LocalPlayer.Character
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.CanCollide = true
                    end
                end
            end
        end
    end)
    
    -- Speed boost functionality
    local speedConnection = nil
    movement.element("Toggle", "speed boost", nil, function(state)
        if state.Toggle then
            if speedConnection then
                speedConnection:Disconnect()
            end
            
            speedConnection = RunService.Heartbeat:Connect(function()
                local character = LocalPlayer.Character
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.MoveDirection.Magnitude > 0 then
                    local multiplier = menu.values[1].movement["speed multiplier"].Slider
                    character:TranslateBy(humanoid.MoveDirection * (multiplier - 1) * 0.25)
                end
            end)
        else
            if speedConnection then
                speedConnection:Disconnect()
                speedConnection = nil
            end
        end
    end)
    
    -- Infinite jump functionality
    local jumpConnection = nil
    movement.element("Toggle", "infinite jump", nil, function(state)
        if state.Toggle then
            if jumpConnection then
                jumpConnection:Disconnect()
            end
            
            jumpConnection = UserInputService.JumpRequest:Connect(function()
                local character = LocalPlayer.Character
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            if jumpConnection then
                jumpConnection:Disconnect()
                jumpConnection = nil
            end
        end
    end)
    
    -- ESP functionality
    local ESPContainer = {}
    local ESPEnabled = false
    
    local function CreateESP(player)
        if player == LocalPlayer then return end
        
        local ESP = {}
        
        -- Create Box
        ESP.Box = Drawing.new("Square")
        ESP.Box.Visible = false
        ESP.Box.Color = Color3.new(1, 1, 1)
        ESP.Box.Thickness = 1
        ESP.Box.Transparency = 1
        ESP.Box.Filled = false
        
        -- Create Name
        ESP.Name = Drawing.new("Text")
        ESP.Name.Visible = false
        ESP.Name.Color = Color3.new(1, 1, 1)
        ESP.Name.Size = 14
        ESP.Name.Center = true
        ESP.Name.Outline = true
        
        -- Create Health Bar Background
        ESP.HealthBG = Drawing.new("Square")
        ESP.HealthBG.Visible = false
        ESP.HealthBG.Color = Color3.new(0, 0, 0)
        ESP.HealthBG.Thickness = 1
        ESP.HealthBG.Transparency = 0.5
        ESP.HealthBG.Filled = true
        
        -- Create Health Bar
        ESP.Health = Drawing.new("Square")
        ESP.Health.Visible = false
        ESP.Health.Color = Color3.new(0, 1, 0)
        ESP.Health.Thickness = 1
        ESP.Health.Transparency = 1
        ESP.Health.Filled = true
        
        ESPContainer[player] = ESP
    end
    
    local function RemoveESP(player)
        if ESPContainer[player] then
            for _, drawing in pairs(ESPContainer[player]) do
                pcall(function() drawing:Remove() end)
            end
            ESPContainer[player] = nil
        end
    end
    
    -- Create ESP for all players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreateESP(player)
        end
    end
    
    -- Handle when players join
    Players.PlayerAdded:Connect(function(player)
        CreateESP(player)
    end)
    
    -- Handle when players leave
    Players.PlayerRemoving:Connect(function(player)
        RemoveESP(player)
    end)
    
    -- Update ESP
    RunService.RenderStepped:Connect(function()
        -- Get config values safely
        local espEnabled = false
        local boxEnabled = false
        local nameEnabled = false
        local healthEnabled = false
        local boxColor = Color3.new(1, 1, 1)
        local nameColor = Color3.new(1, 1, 1)
        local teamCheck = false
        
        pcall(function()
            espEnabled = menu.values[1].features.visuals["esp enabled"].Toggle
            boxEnabled = menu.values[1].features.visuals["box esp"].Toggle
            nameEnabled = menu.values[1].features.visuals["name esp"].Toggle
            healthEnabled = menu.values[1].features.visuals["health bar"].Toggle
            boxColor = menu.values[1].features.visuals["box esp"].Color
            nameColor = menu.values[1].features.visuals["name esp"].Color
            teamCheck = menu.values[1].features["fov settings"]["team check"].Toggle
        end)
        
        -- Update all ESP elements
        for player, esp in pairs(ESPContainer) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid") then
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                local hrp = player.Character.HumanoidRootPart
                
                -- Check if player should be visible (team check)
                local shouldShow = true
                if teamCheck and player.Team == LocalPlayer.Team then
                    shouldShow = false
                end
                
                -- Only show ESP if enabled and player should be visible
                if espEnabled and shouldShow then
                    local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    
                    if onScreen then
                        -- Calculate player dimensions for ESP
                        local headPos = Camera:WorldToViewportPoint(player.Character.Head.Position)
                        local legPos = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position - Vector3.new(0, 3, 0))
                        
                        local height = math.abs(headPos.Y - legPos.Y)
                        local width = height * 0.6
                        
                        -- Update box
                        esp.Box.Visible = boxEnabled
                        esp.Box.Color = boxColor
                        esp.Box.Size = Vector2.new(width, height)
                        esp.Box.Position = Vector2.new(vector.X - width / 2, vector.Y - height / 2)
                        
                        -- Update name
                        esp.Name.Visible = nameEnabled
                        esp.Name.Text = player.Name
                        esp.Name.Color = nameColor
                        esp.Name.Position = Vector2.new(vector.X, vector.Y - height / 2 - 15)
                        
                        -- Update health bar background
                        esp.HealthBG.Visible = healthEnabled
                        esp.HealthBG.Size = Vector2.new(5, height)
                        esp.HealthBG.Position = Vector2.new(vector.X - width / 2 - 7, vector.Y - height / 2)
                        
                        -- Update health bar
                        esp.Health.Visible = healthEnabled
                        local healthPercent = humanoid.Health / humanoid.MaxHealth
                        esp.Health.Size = Vector2.new(5, height * healthPercent)
                        esp.Health.Position = Vector2.new(vector.X - width / 2 - 7, vector.Y - height / 2 + height * (1 - healthPercent))
                        esp.Health.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                    else
                        -- Hide ESP if not on screen
                        esp.Box.Visible = false
                        esp.Name.Visible = false
                        esp.HealthBG.Visible = false
                        esp.Health.Visible = false
                    end
                else
                    -- Hide ESP if not enabled
                    esp.Box.Visible = false
                    esp.Name.Visible = false
                    esp.HealthBG.Visible = false
                    esp.Health.Visible = false
                end
            end
        end
    end)
    
    -- Aimbot implementation
    local aimTarget = nil
    local aimPart = nil
    
    -- Function to get the closest player for aimbot
    local function GetClosestPlayerToCursor(fov)
        local closestPlayer = nil
        local closestDistance = math.huge
        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                -- Get selected body part
                local targetPart = nil
                local hitboxSelection = menu.values[1].features.aimbot.hitbox.Dropdown
                
                if hitboxSelection == "head" and player.Character:FindFirstChild("Head") then
                    targetPart = player.Character.Head
                elseif hitboxSelection == "torso" and player.Character:FindFirstChild("UpperTorso") then
                    targetPart = player.Character.UpperTorso
                elseif hitboxSelection == "torso" and player.Character:FindFirstChild("Torso") then
                    targetPart = player.Character.Torso
                elseif hitboxSelection == "right arm" and player.Character:FindFirstChild("RightUpperArm") then
                    targetPart = player.Character.RightUpperArm
                elseif hitboxSelection == "left arm" and player.Character:FindFirstChild("LeftUpperArm") then
                    targetPart = player.Character.LeftUpperArm
                elseif hitboxSelection == "right leg" and player.Character:FindFirstChild("RightUpperLeg") then
                    targetPart = player.Character.RightUpperLeg
                elseif hitboxSelection == "left leg" and player.Character:FindFirstChild("LeftUpperLeg") then
                    targetPart = player.Character.LeftUpperLeg
                else
                    -- Default to HumanoidRootPart if specified part isn't found
                    targetPart = player.Character.HumanoidRootPart
                end
                
                -- Check team
                local teamCheck = menu.values[1].features["fov settings"]["team check"].Toggle
                local skipPlayer = false
                
                if teamCheck and player.Team == LocalPlayer.Team then
                    skipPlayer = true
                end
                
                -- Check visibility
                if not skipPlayer then
                    local visibleCheck = menu.values[1].features["fov settings"]["visible check"].Toggle
                    if visibleCheck then
                        local rayOrigin = Camera.CFrame.Position
                        local rayDirection = (targetPart.Position - rayOrigin).Unit * 100
                        local ray = Ray.new(rayOrigin, rayDirection)
                        local hit, _ = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
                        
                        if hit and hit:IsDescendantOf(player.Character) == false then
                            skipPlayer = true
                        end
                    end
                end
                
                if not skipPlayer then
                    -- Calculate distance from cursor
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local screenPosition = Vector2.new(screenPos.X, screenPos.Y)
                        local distance = (screenPosition - screenCenter).Magnitude
                        
                        if distance < fov and distance < closestDistance then
                            closestPlayer = player
                            closestDistance = distance
                            aimPart = targetPart
                        end
                    end
                end
            end
        end
        
        return closestPlayer
    end
    
    -- Function to aim at a target
    local function AimAt(targetPos, smoothness)
        local targetPosition = Camera:WorldToViewportPoint(targetPos)
        local mousePosition = UserInputService:GetMouseLocation()
        
        -- Calculate the vector from current position to target
        local aimVector = Vector2.new(
            targetPosition.X - mousePosition.X,
            targetPosition.Y - mousePosition.Y
        )
        
        -- Apply smoothing
        aimVector = aimVector / smoothness
        
        -- Get targeting mode
        local targetingMode = menu.values[1].features.aimbot["targeting mode"].Dropdown
        
        if targetingMode == "mouse" then
            -- Move the mouse (using Roblox's mouse1 functions for compatibility)
            -- Note: In an actual Roblox environment, you'd use mousemoverel
            -- For testing purposes we'll use a simulated version
            local function simulateMouseMove(x, y)
                -- This is a placeholder for the actual mousemoverel functionality
                -- In a real Roblox environment this would move the mouse
                print("Mouse moved by: " .. x .. ", " .. y)
            end
            
            simulateMouseMove(aimVector.X, aimVector.Y)
        else -- camera mode
            -- Get current camera angles
            local currentAngles = Camera.CFrame.Rotation:ToEulerAnglesYXZ()
            
            -- Calculate new camera angles (simplified, not perfect)
            local newCameraCFrame = CFrame.new(Camera.CFrame.Position) * CFrame.Angles(
                currentAngles.X - math.rad(aimVector.Y * 0.1),
                currentAngles.Y - math.rad(aimVector.X * 0.1),
                0
            )
            
            -- Set new camera CFrame
            Camera.CFrame = newCameraCFrame
        end
    end
    
    -- Main aimbot loop
    RunService.RenderStepped:Connect(function()
        -- Get aimbot configuration
        local aimbotEnabled = false
        local fovSize = 100
        local smoothness = 2
        local snapLineEnabled = false
        
        pcall(function()
            aimbotEnabled = menu.values[1].features.aimbot.enabled.Toggle
            fovSize = menu.values[1].features["fov settings"]["fov size"].Slider
            smoothness = menu.values[1].features.aimbot.smoothness.Slider
            snapLineEnabled = menu.values[1].features["fov settings"]["snap line"].Toggle
        end)
        
        -- Find target if aimbot is enabled
        if aimbotEnabled then
            aimTarget = GetClosestPlayerToCursor(fovSize)
            
            -- Aim at target if found
            if aimTarget and aimPart then
                -- Update snap line
                if snapLineEnabled then
                    local targetPos = Camera:WorldToViewportPoint(aimPart.Position)
                    SnapLine.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    SnapLine.To = Vector2.new(targetPos.X, targetPos.Y)
                    SnapLine.Visible = true
                else
                    SnapLine.Visible = false
                end
                
                -- Aim at target
                AimAt(aimPart.Position, smoothness)
                
                -- Check for automatic fire
                local autoFire = menu.values[1].features.aimbot["automatic fire"].Toggle
                if autoFire then
                    -- Simulate mouse1 press and release for auto-firing
                    -- In actual Roblox environment, you'd use mouse1press() and mouse1release()
                    local function simulateMouseClick()
                        -- This is a placeholder for mouse clicking functionality
                        print("Auto-fire clicked")
                    end
                    
                    simulateMouseClick()
                    -- Brief delay between clicks
                    task.delay(0.1, function() end)
                end
            else
                SnapLine.Visible = false
            end
        else
            SnapLine.Visible = false
            aimTarget = nil
        end
    end)
    
    -- Add keybind functionality for aimbot
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed then
            -- Check for aimbot keybind
            pcall(function()
                local keybind = menu.values[1].features.aimbot.enabled.Keybind
                if keybind and input.KeyCode == keybind then
                    menu.values[1].features.aimbot.enabled.Toggle = not menu.values[1].features.aimbot.enabled.Toggle
                end
            end)
        end
    end)
end
