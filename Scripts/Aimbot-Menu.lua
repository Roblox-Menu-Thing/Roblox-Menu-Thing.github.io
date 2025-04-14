--[[
    🌟 ULTIMATE ROBLOX AIMBOT AND ESP SCRIPT WITH NEON UI 🌟
    
    Features:
    - Aimbot: Locks onto nearest player within FOV with DIRECT MOUSE MOVEMENT (right mouse button activation)
    - ESP: Draws boxes around players to see them through walls with distance-based optimization
    - Bone ESP: Shows player skeleton through walls for better visibility
    - NEON UI: Futuristic control panel with reactive elements and pulsing animations
    - Unload: Press End key to unload the script completely
    - Toggle UI: Press Right Control to show/hide the interface
    - Misc: Hitbox expander, speed changer, jump multiplier
    
    Enhanced Features:
    - Direct Mouse Movement Aimbot: Physically moves your mouse cursor for more precise aiming
    - All-Player Hitbox Expansion: Apply hitbox expansion to ALL players regardless of team
    - Larger UI: Increased UI dimensions (650x550) for better visibility and control
    
    Hotkeys:
    - Right Mouse Button: Activate aimbot with direct mouse control
    - End Key: Unload script
    - Right Control: Toggle UI
    - Left Shift: Sprint key (if speed changer is enabled with sprint option)
    
    PREMIUM UI Features:
    - Reactive neon glow effects that pulse on interaction
    - Advanced 3D shadows and light effects for depth
    - Particle effects and animated backgrounds
    - Color shifting gradient animations
    - Responsive interface with smooth transitions and elastic animations
    - Holographic tab design with 3D depth effects
    - Dynamic audio-visual feedback on all interactions
    - Customizable UI themes with presets
]]

-- Error handling and version compatibility
local success, errorMsg = pcall(function()
    -- Check if we're running in Roblox environment
    if not game then
        error("This script must be run within Roblox")
    end
end)

if not success then
    warn("Script initialization error: " .. errorMsg)
    return
end

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local ContextActionService = game:GetService("ContextActionService")

-- Local Player
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Configuration
local Settings = {
    -- Aimbot settings
    Aimbot = {
        Enabled = true,
        Key = Enum.UserInputType.MouseButton2, -- Right mouse button
        TeamCheck = true,
        TargetPart = "Head",
        FOV = 250,
        Smoothness = 0.05, -- Lower = faster (made more responsive when right-clicking)
        ShowFOV = true,
        CenterOfScreen = true, -- Makes the aimbot target center of screen instead of cursor
        TogglePriority = "Distance", -- Options: "Distance", "Health", "Level", "Random"
        AimMode = "Mouse", -- Options: "Camera", "Mouse"
    },
    
    -- ESP settings
    ESP = {
        Enabled = true,
        TeamCheck = true,
        BoxColor = Color3.fromRGB(255, 0, 0),
        TeamBoxColor = Color3.fromRGB(0, 255, 0),
        TeamMateDraw = true,
        NameDisplay = true,
        DistanceDisplay = true,
        HealthDisplay = true,
        BoxOutline = true,
        BoneESP = true, -- Enable bone lines between joints
        BoneColor = Color3.fromRGB(255, 255, 255),
        MaxRenderDistance = 2000, -- Only render ESP for players within this distance
        OptimizationEnabled = true, -- Enable performance optimizations
        UpdateRate = 0.03, -- Update ESP every X seconds (lower = smoother, higher = less lag)
    },
    
    -- Misc settings
    Misc = {
        UnloadKey = Enum.KeyCode.End,
        UIKeybind = Enum.KeyCode.RightControl, -- Right Ctrl to toggle UI
        
        -- New added features
        HitboxExpander = {
            Enabled = false,
            Size = 2,  -- Multiplier for hitbox size
            TransparencyLevel = 0.5, -- Transparency level for expanded hitboxes
            ApplyToTeam = false, -- Apply to teammates
            PartToExpand = "HumanoidRootPart" -- Which part to expand
        },
        
        SpeedChanger = {
            Enabled = false,
            SpeedMultiplier = 2, -- Multiplier for speed
            ApplyOnSprint = true, -- Only apply when sprinting
            SprintKey = Enum.KeyCode.LeftShift
        },
        
        JumpMultiplier = {
            Enabled = false,
            JumpPower = 2, -- Multiplier for jump power
            ApplyAutomatically = true, -- Apply to all jumps automatically
        }
    },
    
    -- UI settings
    UI = {
        Enabled = true,
        Color = {
            Main = Color3.fromRGB(10, 12, 20),  -- Darker, more futuristic background
            Secondary = Color3.fromRGB(18, 20, 30),
            Accent = Color3.fromRGB(0, 200, 255),  -- Neon blue accent
            NeonSecondary = Color3.fromRGB(255, 0, 200), -- Neon pink secondary accent
            NeonGreen = Color3.fromRGB(0, 255, 150), -- Neon green for highlights
            Text = Color3.fromRGB(230, 240, 255), -- Slightly blue-tinted text
            TextShadow = Color3.fromRGB(0, 0, 0), -- Text shadow color
            Glow = Color3.fromRGB(0, 150, 255, 0.5), -- Enhanced glow effect
            Toggle = {
                On = Color3.fromRGB(0, 255, 170),  -- Neon cyan-green
                Off = Color3.fromRGB(255, 50, 120),  -- Neon pink-red
                Background = Color3.fromRGB(25, 28, 40),
                Hover = Color3.fromRGB(35, 38, 55),  -- Hover state color
                Pulse = Color3.fromRGB(0, 255, 200, 0.7) -- Pulse effect color
            },
            Slider = {
                Background = Color3.fromRGB(25, 28, 40),
                Bar = Color3.fromRGB(0, 200, 255), -- Matching accent
                BarGlow = Color3.fromRGB(0, 220, 255, 0.7), -- Glow for slider bar
                Thumb = Color3.fromRGB(255, 255, 255),  -- Bright thumb
                ThumbGlow = Color3.fromRGB(0, 220, 255, 0.9), -- Glow for thumb
                ThumbHover = Color3.fromRGB(200, 255, 255),  -- Thumb hover color
                Text = Color3.fromRGB(230, 240, 255),
                ValueText = Color3.fromRGB(0, 255, 200)  -- Neon value text
            },
            Tab = {
                Selected = Color3.fromRGB(0, 220, 255), -- Neon blue for selected
                Unselected = Color3.fromRGB(40, 45, 60),
                Background = Color3.fromRGB(15, 18, 25),
                Text = Color3.fromRGB(230, 240, 255),
                TextSelected = Color3.fromRGB(255, 255, 255), -- Brighter text for selected
                Hover = Color3.fromRGB(50, 55, 70),  -- Tab hover color
                Glow = Color3.fromRGB(0, 220, 255, 0.5) -- Glow for tabs
            },
            Button = {
                Normal = Color3.fromRGB(30, 35, 45),
                Hover = Color3.fromRGB(40, 45, 60),
                Pressed = Color3.fromRGB(25, 30, 40),
                Text = Color3.fromRGB(230, 240, 255),
                Glow = Color3.fromRGB(0, 200, 255, 0.4) -- Glow for buttons
            },
            Particles = {
                Color1 = Color3.fromRGB(0, 200, 255),
                Color2 = Color3.fromRGB(255, 0, 200),
                Color3 = Color3.fromRGB(0, 255, 150)
            }
        },
        Transparency = 0.03, -- More solid for better neon contrast
        Position = UDim2.new(0.5, -325, 0.5, -275), -- Larger UI position
        Size = UDim2.new(0, 650, 0, 550), -- Significantly increased size for better visibility
        Animation = {
            Speed = 0.15,  -- Animation speed in seconds
            SliderSpeed = 0.10,  -- Slider animation speed
            ToggleSpeed = 0.12,  -- Toggle animation speed
            RippleSpeed = 0.3,   -- Ripple animation speed
            TabSwitchSpeed = 0.18, -- Tab switch animation speed
            GlowSpeed = 0.8,     -- Glow pulse speed
            ParticleSpeed = 1.2  -- Particle effect speed
        },
        Roundness = {
            Main = 12,  -- Main frame corner radius (enhanced)
            Secondary = 10,  -- Secondary elements corner radius (enhanced)
            Toggle = 16,  -- Toggle button radius (enhanced)
            Slider = 14,  -- Slider radius (enhanced)
            Button = 10,    -- Button radius (enhanced)
            GlowRadius = 20 -- Radius for glow effects
        },
        Shadow = {
            Enabled = true,
            Size = 20,
            Transparency = 0.65,
            BlurSize = 15
        },
        Particles = {
            Enabled = true,
            Count = 25,
            Size = {Min = 2, Max = 5},
            Speed = {Min = 0.5, Max = 1.5}
        },
        Theme = "Neon" -- Current theme (can be switched with multiple themes)
    }
}

-- Variables
local Loaded = false
local FOVCircle = Drawing.new("Circle")
local ESPObjects = {}
local ActiveTab = "Aimbot" -- Default active tab
local UIElements = {}
local OriginalHitboxes = {} -- Store original hitbox sizes
local OriginalSpeed = nil -- Store original speed
local OriginalJumpPower = nil -- Store original jump power
local IsUIVisible = true

-- Initialize FOV Circle
FOVCircle.Visible = Settings.Aimbot.ShowFOV
FOVCircle.Radius = Settings.Aimbot.FOV
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Transparency = 1

-- Functions
local function IsAlive(player)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    return character and humanoid and humanoid.Health > 0
end

local function IsTeammate(player)
    if not Settings.Aimbot.TeamCheck then return false end
    return player.Team == LocalPlayer.Team
end

local function GetDistance(position)
    local character = LocalPlayer.Character
    if not character then return math.huge end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return math.huge end
    
    return (rootPart.Position - position).Magnitude
end

local function IsOnScreen(position)
    local _, onScreen = Camera:WorldToViewportPoint(position)
    return onScreen
end

local function GetClosestPlayerToCursor()
    local closestPlayer = nil
    local shortestDistance = math.huge
    
    -- Get the center of the screen for center-screen aimbot
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsAlive(player) and not (Settings.Aimbot.TeamCheck and IsTeammate(player)) then
            local character = player.Character
            if not character then continue end
            
            local targetPart = character:FindFirstChild(Settings.Aimbot.TargetPart)
            if not targetPart then continue end
            
            local targetPosition = targetPart.Position
            if not IsOnScreen(targetPosition) then continue end
            
            local targetVector, onScreen = Camera:WorldToViewportPoint(targetPosition)
            if not onScreen then continue end
            
            local targetPos = Vector2.new(targetVector.X, targetVector.Y)
            
            -- Use either mouse position or screen center based on setting
            local referencePos = Settings.Aimbot.CenterOfScreen and screenCenter or Vector2.new(Mouse.X, Mouse.Y)
            local distance = (targetPos - referencePos).Magnitude
            
            if distance <= Settings.Aimbot.FOV and distance < shortestDistance then
                closestPlayer = player
                shortestDistance = distance
            end
        end
    end
    
    return closestPlayer
end

local function CreateDrawings()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            ESPObjects[player] = {
                Box = Drawing.new("Square"),
                BoxOutline = Drawing.new("Square"),
                Name = Drawing.new("Text"),
                Distance = Drawing.new("Text"),
                Health = Drawing.new("Text"),
                -- Add bone lines for skeleton ESP
                Bones = {
                    -- Spine and Torso
                    Head_UpperTorso = Drawing.new("Line"),
                    UpperTorso_LowerTorso = Drawing.new("Line"),
                    
                    -- Left Arm
                    UpperTorso_LeftUpperArm = Drawing.new("Line"),
                    LeftUpperArm_LeftLowerArm = Drawing.new("Line"),
                    LeftLowerArm_LeftHand = Drawing.new("Line"),
                    
                    -- Right Arm
                    UpperTorso_RightUpperArm = Drawing.new("Line"),
                    RightUpperArm_RightLowerArm = Drawing.new("Line"),
                    RightLowerArm_RightHand = Drawing.new("Line"),
                    
                    -- Left Leg
                    LowerTorso_LeftUpperLeg = Drawing.new("Line"),
                    LeftUpperLeg_LeftLowerLeg = Drawing.new("Line"),
                    LeftLowerLeg_LeftFoot = Drawing.new("Line"),
                    
                    -- Right Leg
                    LowerTorso_RightUpperLeg = Drawing.new("Line"),
                    RightUpperLeg_RightLowerLeg = Drawing.new("Line"),
                    RightLowerLeg_RightFoot = Drawing.new("Line"),
                }
            }
            
            -- Box settings
            ESPObjects[player].Box.Thickness = 1
            ESPObjects[player].Box.Filled = false
            ESPObjects[player].Box.Transparency = 1
            
            -- Box outline settings
            ESPObjects[player].BoxOutline.Thickness = 3
            ESPObjects[player].BoxOutline.Filled = false
            ESPObjects[player].BoxOutline.Transparency = 1
            ESPObjects[player].BoxOutline.Color = Color3.fromRGB(0, 0, 0)
            
            -- Name settings
            ESPObjects[player].Name.Size = 13
            ESPObjects[player].Name.Center = true
            ESPObjects[player].Name.Outline = true
            
            -- Distance settings
            ESPObjects[player].Distance.Size = 12
            ESPObjects[player].Distance.Center = true
            ESPObjects[player].Distance.Outline = true
            
            -- Health settings
            ESPObjects[player].Health.Size = 12
            ESPObjects[player].Health.Center = true
            ESPObjects[player].Health.Outline = true
            
            -- Bone ESP settings
            for _, bone in pairs(ESPObjects[player].Bones) do
                bone.Thickness = 1.5
                bone.Transparency = 1
                bone.Color = Settings.ESP.BoneColor
            end
        end
    end
end

local function RemoveDrawings()
    for player, objects in pairs(ESPObjects) do
        for k, drawing in pairs(objects) do
            if k ~= "Bones" then
                drawing:Remove()
            else
                for _, bone in pairs(drawing) do
                    bone:Remove()
                end
            end
        end
    end
    ESPObjects = {}
end

-- Track last ESP update time for optimization
local lastESPUpdate = 0

-- Optimized ESP function to reduce lag
local function UpdateESP()
    if not Settings.ESP.Enabled then
        -- If ESP is disabled, hide all drawings
        for _, objects in pairs(ESPObjects) do
            for k, drawing in pairs(objects) do
                if k ~= "Bones" then
                    drawing.Visible = false
                else
                    for _, bone in pairs(drawing) do
                        bone.Visible = false
                    end
                end
            end
        end
        return
    end
    
    -- Throttle ESP updates for performance
    local currentTime = tick()
    if Settings.ESP.OptimizationEnabled and (currentTime - lastESPUpdate) < Settings.ESP.UpdateRate then
        return
    end
    lastESPUpdate = currentTime

    -- For each player in the game
    for player, objects in pairs(ESPObjects) do
        local character = player.Character
        if not character or not IsAlive(player) then
            -- Hide ESP if player is not alive
            for k, drawing in pairs(objects) do
                if k ~= "Bones" then
                    drawing.Visible = false
                else
                    for _, bone in pairs(drawing) do
                        bone.Visible = false
                    end
                end
            end
            continue
        end
        
        -- Check team settings
        local isTeammate = IsTeammate(player)
        if isTeammate and not Settings.ESP.TeamMateDraw then
            -- Hide ESP for teammates if setting disabled
            for k, drawing in pairs(objects) do
                if k ~= "Bones" then
                    drawing.Visible = false
                else
                    for _, bone in pairs(drawing) do
                        bone.Visible = false
                    end
                end
            end
            continue
        end
        
        -- Check distance for optimization
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then continue end
        
        local distance = GetDistance(rootPart.Position)
        if distance > Settings.ESP.MaxRenderDistance then
            -- Hide ESP if player is too far away
            for k, drawing in pairs(objects) do
                if k ~= "Bones" then
                    drawing.Visible = false
                else
                    for _, bone in pairs(drawing) do
                        bone.Visible = false
                    end
                end
            end
            continue
        end
        
        -- Get player's screen position
        local rootPosition = rootPart.Position
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        
        -- Calculate the corners of the ESP box
        local topPosition = rootPosition + Vector3.new(0, 3, 0)
        local bottomPosition = rootPosition - Vector3.new(0, 3, 0)
        
        local topVector, topOnScreen = Camera:WorldToViewportPoint(topPosition)
        local bottomVector, bottomOnScreen = Camera:WorldToViewportPoint(bottomPosition)
        
        -- Only show ESP if player is visible on screen
        if not (topOnScreen or bottomOnScreen) then
            for k, drawing in pairs(objects) do
                if k ~= "Bones" then
                    drawing.Visible = false
                else
                    for _, bone in pairs(drawing) do
                        bone.Visible = false
                    end
                end
            end
            continue
        end
        
        -- Calculate dimensions for ESP box
        local height = math.abs(topVector.Y - bottomVector.Y)
        local width = height * 0.6
        
        local boxPosition = Vector2.new(
            topVector.X - width / 2,
            topVector.Y
        )
        
        local boxSize = Vector2.new(width, height)
        
        -- Update box drawing
        local box = objects.Box
        box.Size = boxSize
        box.Position = boxPosition
        box.Color = isTeammate and Settings.ESP.TeamBoxColor or Settings.ESP.BoxColor
        box.Visible = true
        
        -- Update box outline
        if Settings.ESP.BoxOutline then
            local boxOutline = objects.BoxOutline
            boxOutline.Size = boxSize
            boxOutline.Position = boxPosition
            boxOutline.Visible = true
        else
            objects.BoxOutline.Visible = false
        end
        
        -- Update name text
        if Settings.ESP.NameDisplay then
            local nameText = objects.Name
            nameText.Text = player.Name
            nameText.Position = Vector2.new(
                boxPosition.X + width / 2,
                boxPosition.Y - 15
            )
            nameText.Color = isTeammate and Settings.ESP.TeamBoxColor or Settings.ESP.BoxColor
            nameText.Visible = true
        else
            objects.Name.Visible = false
        end
        
        -- Update distance text
        if Settings.ESP.DistanceDisplay then
            local distanceText = objects.Distance
            distanceText.Text = math.floor(distance) .. "m"
            distanceText.Position = Vector2.new(
                boxPosition.X + width / 2,
                boxPosition.Y + boxSize.Y + 3
            )
            distanceText.Color = isTeammate and Settings.ESP.TeamBoxColor or Settings.ESP.BoxColor
            distanceText.Visible = true
        else
            objects.Distance.Visible = false
        end
        
        -- Update health text
        if Settings.ESP.HealthDisplay and humanoid then
            local healthText = objects.Health
            local healthPercent = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
            healthText.Text = healthPercent .. "HP"
            healthText.Position = Vector2.new(
                boxPosition.X + width / 2,
                boxPosition.Y + boxSize.Y + (Settings.ESP.DistanceDisplay and 18 or 3)
            )
            
            -- Color based on health percentage
            local r, g
            if healthPercent > 50 then
                r = 1 - (healthPercent - 50) / 50
                g = 1
            else
                r = 1
                g = healthPercent / 50
            end
            healthText.Color = Color3.fromRGB(r * 255, g * 255, 0)
            healthText.Visible = true
        else
            objects.Health.Visible = false
        end
        
        -- Update bone ESP
        if Settings.ESP.BoneESP then
            -- Define joint mappings for bone ESP
            local joints = {
                ["Head_UpperTorso"] = {character:FindFirstChild("Head"), character:FindFirstChild("UpperTorso")},
                ["UpperTorso_LowerTorso"] = {character:FindFirstChild("UpperTorso"), character:FindFirstChild("LowerTorso")},
                
                ["UpperTorso_LeftUpperArm"] = {character:FindFirstChild("UpperTorso"), character:FindFirstChild("LeftUpperArm")},
                ["LeftUpperArm_LeftLowerArm"] = {character:FindFirstChild("LeftUpperArm"), character:FindFirstChild("LeftLowerArm")},
                ["LeftLowerArm_LeftHand"] = {character:FindFirstChild("LeftLowerArm"), character:FindFirstChild("LeftHand")},
                
                ["UpperTorso_RightUpperArm"] = {character:FindFirstChild("UpperTorso"), character:FindFirstChild("RightUpperArm")},
                ["RightUpperArm_RightLowerArm"] = {character:FindFirstChild("RightUpperArm"), character:FindFirstChild("RightLowerArm")},
                ["RightLowerArm_RightHand"] = {character:FindFirstChild("RightLowerArm"), character:FindFirstChild("RightHand")},
                
                ["LowerTorso_LeftUpperLeg"] = {character:FindFirstChild("LowerTorso"), character:FindFirstChild("LeftUpperLeg")},
                ["LeftUpperLeg_LeftLowerLeg"] = {character:FindFirstChild("LeftUpperLeg"), character:FindFirstChild("LeftLowerLeg")},
                ["LeftLowerLeg_LeftFoot"] = {character:FindFirstChild("LeftLowerLeg"), character:FindFirstChild("LeftFoot")},
                
                ["LowerTorso_RightUpperLeg"] = {character:FindFirstChild("LowerTorso"), character:FindFirstChild("RightUpperLeg")},
                ["RightUpperLeg_RightLowerLeg"] = {character:FindFirstChild("RightUpperLeg"), character:FindFirstChild("RightLowerLeg")},
                ["RightLowerLeg_RightFoot"] = {character:FindFirstChild("RightLowerLeg"), character:FindFirstChild("RightFoot")},
            }
            
            -- Draw lines between joints
            for boneName, joint in pairs(joints) do
                local bone = objects.Bones[boneName]
                local part1, part2 = joint[1], joint[2]
                
                if part1 and part2 then
                    local p1, p1OnScreen = Camera:WorldToViewportPoint(part1.Position)
                    local p2, p2OnScreen = Camera:WorldToViewportPoint(part2.Position)
                    
                    if p1OnScreen and p2OnScreen then
                        bone.From = Vector2.new(p1.X, p1.Y)
                        bone.To = Vector2.new(p2.X, p2.Y)
                        bone.Visible = true
                        bone.Color = Settings.ESP.BoneColor
                    else
                        bone.Visible = false
                    end
                else
                    bone.Visible = false
                end
            end
        else
            -- Hide bone ESP if disabled
            for _, bone in pairs(objects.Bones) do
                bone.Visible = false
            end
        end
    end
end

-- Update FOV circle position
local function UpdateFOVCircle()
    if not Settings.Aimbot.ShowFOV then
        FOVCircle.Visible = false
        return
    end
    
    FOVCircle.Visible = true
    FOVCircle.Radius = Settings.Aimbot.FOV
    FOVCircle.Position = Settings.Aimbot.CenterOfScreen 
        and Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        or Vector2.new(Mouse.X, Mouse.Y)
end

-- Create and update UI
-- Function to create a neon glow effect for UI elements
local function CreateNeonGlow(parent, color, size, transparency, zIndex)
    local glow = Instance.new("ImageLabel")
    glow.Name = "NeonGlow"
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://4996891970" -- Radial gradient
    glow.ImageColor3 = color or Settings.UI.Color.Glow
    glow.ImageTransparency = transparency or 0.7
    glow.Size = UDim2.new(1, size or 20, 1, size or 20)
    glow.Position = UDim2.new(0.5, -(size or 20)/2, 0.5, -(size or 20)/2)
    glow.AnchorPoint = Vector2.new(0.5, 0.5)
    glow.ZIndex = zIndex or 0
    glow.Parent = parent
    
    -- Create pulsing animation
    spawn(function()
        while glow and glow.Parent do
            for i = 0.7, 0.9, 0.01 do
                if not glow or not glow.Parent then break end
                glow.ImageTransparency = i
                wait(0.05)
            end
            for i = 0.9, 0.7, -0.01 do
                if not glow or not glow.Parent then break end
                glow.ImageTransparency = i
                wait(0.05)
            end
        end
    end)
    
    return glow
end

-- Function to create particle effects
local function CreateParticleEffect(parent)
    if not Settings.UI.Particles.Enabled then return end
    
    -- Create container for particles
    local particleContainer = Instance.new("Frame")
    particleContainer.Name = "ParticleContainer"
    particleContainer.BackgroundTransparency = 1
    particleContainer.Size = UDim2.new(1, 0, 1, 0)
    particleContainer.ClipsDescendants = true
    particleContainer.ZIndex = 1
    particleContainer.Parent = parent
    
    -- Create particles
    local particles = {}
    local colors = {
        Settings.UI.Color.Particles.Color1,
        Settings.UI.Color.Particles.Color2,
        Settings.UI.Color.Particles.Color3
    }
    
    -- Generate random particles
    for i = 1, Settings.UI.Particles.Count do
        local particle = Instance.new("Frame")
        particle.Name = "Particle" .. i
        particle.BorderSizePixel = 0
        
        -- Random properties
        local size = math.random(Settings.UI.Particles.Size.Min, Settings.UI.Particles.Size.Max)
        local xPos = math.random(1, parent.AbsoluteSize.X)
        local yPos = math.random(1, parent.AbsoluteSize.Y)
        local speed = math.random(Settings.UI.Particles.Speed.Min * 100, Settings.UI.Particles.Speed.Max * 100) / 100
        local color = colors[math.random(1, #colors)]
        
        -- Apply properties
        particle.Size = UDim2.new(0, size, 0, size)
        particle.Position = UDim2.new(0, xPos, 0, yPos)
        particle.BackgroundColor3 = color
        particle.BackgroundTransparency = 0.7
        particle.ZIndex = 2
        
        -- Round corners
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0) -- Make it circular
        corner.Parent = particle
        
        -- Add glow
        local glow = Instance.new("ImageLabel")
        glow.Name = "ParticleGlow"
        glow.BackgroundTransparency = 1
        glow.Image = "rbxassetid://4996891970" -- Radial gradient
        glow.ImageColor3 = color
        glow.ImageTransparency = 0.8
        glow.Size = UDim2.new(1, 10, 1, 10)
        glow.Position = UDim2.new(0.5, -5, 0.5, -5)
        glow.AnchorPoint = Vector2.new(0.5, 0.5)
        glow.ZIndex = 1
        glow.Parent = particle
        
        particle.Parent = particleContainer
        table.insert(particles, {
            Frame = particle,
            Speed = speed,
            Direction = Vector2.new(math.random(-10, 10) / 10, math.random(-10, 10) / 10)
        })
    end
    
    -- Animate particles
    spawn(function()
        while particleContainer and particleContainer.Parent do
            for _, p in ipairs(particles) do
                if not p.Frame or not p.Frame.Parent then continue end
                
                -- Move particle
                local newX = p.Frame.Position.X.Offset + (p.Direction.X * p.Speed)
                local newY = p.Frame.Position.Y.Offset + (p.Direction.Y * p.Speed)
                
                -- Bounce off edges
                if newX <= 0 or newX >= parent.AbsoluteSize.X then
                    p.Direction = Vector2.new(-p.Direction.X, p.Direction.Y)
                    newX = math.clamp(newX, 0, parent.AbsoluteSize.X)
                end
                
                if newY <= 0 or newY >= parent.AbsoluteSize.Y then
                    p.Direction = Vector2.new(p.Direction.X, -p.Direction.Y)
                    newY = math.clamp(newY, 0, parent.AbsoluteSize.Y)
                end
                
                p.Frame.Position = UDim2.new(0, newX, 0, newY)
            end
            wait(0.03) -- Update rate
        end
    end)
    
    return particleContainer
end

-- Function to create futuristic UI header with logo
local function CreateUIHeader(parent)
    -- Create header container
    local header = Instance.new("Frame")
    header.Name = "FuturisticHeader"
    header.Size = UDim2.new(1, 0, 0, 30)
    header.BackgroundColor3 = Settings.UI.Color.Secondary
    header.BorderSizePixel = 0
    header.ZIndex = 10
    header.Parent = parent
    
    -- Add modern logo
    local logo = Instance.new("ImageLabel")
    logo.Name = "Logo"
    logo.BackgroundTransparency = 1
    logo.Image = "rbxassetid://8053238022" -- Modern tech logo
    logo.Size = UDim2.new(0, 24, 0, 24)
    logo.Position = UDim2.new(0, 8, 0, 3)
    logo.ZIndex = 11
    logo.Parent = header
    
    -- Add glow to logo
    CreateNeonGlow(logo, Settings.UI.Color.Accent, 20, 0.7, 10)
    
    -- Add title text
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Text = "NEON AIMBOT & ESP"
    title.Font = Enum.Font.GothamBold
    title.TextColor3 = Settings.UI.Color.Text
    title.TextSize = 14
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(0, 200, 1, 0)
    title.Position = UDim2.new(0, 40, 0, 0)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 11
    title.Parent = header
    
    -- Add version indicator
    local version = Instance.new("TextLabel")
    version.Name = "Version"
    version.Text = "v2.0"
    version.Font = Enum.Font.GothamSemibold
    version.TextColor3 = Settings.UI.Color.Accent
    version.TextSize = 12
    version.BackgroundTransparency = 1
    version.Size = UDim2.new(0, 40, 1, 0)
    version.Position = UDim2.new(1, -80, 0, 0)
    version.ZIndex = 11
    version.Parent = header
    
    -- Add close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Text = "×"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextColor3 = Settings.UI.Color.Text
    closeBtn.TextSize = 20
    closeBtn.BackgroundTransparency = 1
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -30, 0, 0)
    closeBtn.ZIndex = 11
    closeBtn.Parent = header
    
    -- Close button hover effect
    closeBtn.MouseEnter:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.2), {TextColor3 = Settings.UI.Color.NeonSecondary}):Play()
    end)
    
    closeBtn.MouseLeave:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.2), {TextColor3 = Settings.UI.Color.Text}):Play()
    end)
    
    -- Close button click effect
    closeBtn.MouseButton1Click:Connect(function()
        parent.Visible = false
        IsUIVisible = false
    end)
    
    -- Add gradient
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 45)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 35))
    })
    gradient.Rotation = 90
    gradient.Parent = header
    
    return header
end

local function CreateUI()
    -- Main frame
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AimbotESPGUI_Neon"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Try to parent to CoreGui (more secure) or PlayerGui if that fails
    local success, error = pcall(function()
        ScreenGui.Parent = CoreGui
    end)
    
    if not success then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Create main frame with shadow
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = Settings.UI.Size
    MainFrame.Position = Settings.UI.Position
    MainFrame.BackgroundColor3 = Settings.UI.Color.Main
    MainFrame.BorderSizePixel = 0
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Parent = ScreenGui
    
    -- Add corner radius
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, Settings.UI.Roundness.Main)
    UICorner.Parent = MainFrame
    
    -- Add shadow if enabled
    if Settings.UI.Shadow.Enabled then
        local Shadow = Instance.new("ImageLabel")
        Shadow.Name = "Shadow"
        Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
        Shadow.BackgroundTransparency = 1
        Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
        Shadow.Size = UDim2.new(1, Settings.UI.Shadow.Size * 2, 1, Settings.UI.Shadow.Size * 2)
        Shadow.ZIndex = -1
        Shadow.Image = "rbxassetid://6015897843" -- Shadow asset
        Shadow.ImageColor3 = Color3.new(0, 0, 0)
        Shadow.ImageTransparency = Settings.UI.Shadow.Transparency
        Shadow.ScaleType = Enum.ScaleType.Slice
        Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
        Shadow.Parent = MainFrame
    end
    
    -- Title bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.Position = UDim2.new(0, 0, 0, 0)
    TitleBar.BackgroundColor3 = Settings.UI.Color.Secondary
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleBarCorner = Instance.new("UICorner")
    TitleBarCorner.CornerRadius = UDim.new(0, Settings.UI.Roundness.Main)
    TitleBarCorner.Parent = TitleBar
    
    -- Patch the corners
    local TitleBarPatch = Instance.new("Frame")
    TitleBarPatch.Name = "TitleBarPatch"
    TitleBarPatch.Size = UDim2.new(1, 0, 0, 15)
    TitleBarPatch.Position = UDim2.new(0, 0, 1, -15)
    TitleBarPatch.BackgroundColor3 = Settings.UI.Color.Secondary
    TitleBarPatch.BorderSizePixel = 0
    TitleBarPatch.Parent = TitleBar
    
    -- Title text
    local TitleText = Instance.new("TextLabel")
    TitleText.Name = "TitleText"
    TitleText.Size = UDim2.new(1, -10, 1, 0)
    TitleText.Position = UDim2.new(0, 10, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = "Advanced Aimbot & ESP"
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextColor3 = Settings.UI.Color.Text
    TitleText.TextSize = 14
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar
    
    -- Close button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -30, 0, 0)
    CloseButton.BackgroundTransparency = 1
    CloseButton.Text = "×"
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextColor3 = Settings.UI.Color.Text
    CloseButton.TextSize = 20
    CloseButton.Parent = TitleBar
    
    -- Tab container
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, 0, 0, 30)
    TabContainer.Position = UDim2.new(0, 0, 0, 30)
    TabContainer.BackgroundColor3 = Settings.UI.Color.Tab.Background
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = MainFrame
    
    -- Content frame
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Size = UDim2.new(1, 0, 1, -60)
    ContentFrame.Position = UDim2.new(0, 0, 0, 60)
    ContentFrame.BackgroundColor3 = Settings.UI.Color.Main
    ContentFrame.BorderSizePixel = 0
    ContentFrame.ClipsDescendants = true
    ContentFrame.Parent = MainFrame
    
    -- Add particles to main content
    if Settings.UI.Particles.Enabled then
        -- Create particle container for background effects
        spawn(function()
            wait(0.1) -- Wait for frame to initialize
            CreateParticleEffect(ContentFrame)
        end)
    end
    
    -- Add neon border glow
    local borderGlow = Instance.new("Frame")
    borderGlow.Name = "NeonBorder"
    borderGlow.Size = UDim2.new(1, 0, 1, 0)
    borderGlow.Position = UDim2.new(0, 0, 0, 0)
    borderGlow.BackgroundTransparency = 1
    borderGlow.Parent = MainFrame
    borderGlow.ZIndex = 0
    
    -- Create pulsing border animation
    spawn(function()
        local pulseTime = Settings.UI.Animation.GlowSpeed
        local glowSize = 2
        
        while borderGlow and borderGlow.Parent do
            -- Create new stroke
            local stroke = Instance.new("UIStroke")
            stroke.Color = Settings.UI.Color.Accent
            stroke.Thickness = 1.5
            stroke.Transparency = 0.7
            stroke.Parent = borderGlow
            
            -- Animate stroke
            for i = 0.7, 1, 0.05 do
                if not stroke or not stroke.Parent then break end
                stroke.Transparency = i
                wait(pulseTime/20)
            end
            
            stroke:Destroy()
            wait(pulseTime)
        end
    end)
    
    -- Create tabs
    local TabButtons = {}
    local TabContentFrames = {}
    local tabs = {"Aimbot", "ESP", "Misc"}
    
    for i, tabName in ipairs(tabs) do
        -- Tab button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = tabName .. "Tab"
        TabButton.Size = UDim2.new(1/#tabs, 0, 1, 0)
        TabButton.Position = UDim2.new((i-1)/#tabs, 0, 0, 0)
        TabButton.BackgroundColor3 = tabName == ActiveTab and Settings.UI.Color.Tab.Selected or Settings.UI.Color.Tab.Unselected
        TabButton.BorderSizePixel = 0
        TabButton.Text = tabName
        TabButton.Font = Enum.Font.GothamSemibold
        TabButton.TextColor3 = Settings.UI.Color.Tab.Text
        TabButton.TextSize = 14
        TabButton.Parent = TabContainer
        
        -- Tab content frame
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = tabName .. "Content"
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.Position = UDim2.new(0, 0, 0, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.ScrollBarThickness = 4
        TabContent.ScrollBarImageColor3 = Settings.UI.Color.Accent
        TabContent.Visible = tabName == ActiveTab
        TabContent.Parent = ContentFrame
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will adjust based on content
        TabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
        
        -- Tab padding
        local TabPadding = Instance.new("UIPadding")
        TabPadding.PaddingLeft = UDim.new(0, 10)
        TabPadding.PaddingRight = UDim.new(0, 10)
        TabPadding.PaddingTop = UDim.new(0, 10)
        TabPadding.PaddingBottom = UDim.new(0, 10)
        TabPadding.Parent = TabContent
        
        -- Tab layout
        local TabLayout = Instance.new("UIListLayout")
        TabLayout.Padding = UDim.new(0, 10)
        TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
        TabLayout.Parent = TabContent
        
        -- Store references
        TabButtons[tabName] = TabButton
        TabContentFrames[tabName] = TabContent
        
        -- Tab button functionality
        TabButton.MouseButton1Click:Connect(function()
            -- If it's already the active tab, do nothing
            if ActiveTab == tabName then return end
            
            -- Update the active tab
            ActiveTab = tabName
            
            -- Update tab button appearances
            for name, button in pairs(TabButtons) do
                TweenService:Create(button, 
                    TweenInfo.new(Settings.UI.Animation.TabSwitchSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {BackgroundColor3 = name == ActiveTab and Settings.UI.Color.Tab.Selected or Settings.UI.Color.Tab.Unselected}
                ):Play()
            end
            
            -- Show/hide content frames
            for name, frame in pairs(TabContentFrames) do
                frame.Visible = name == ActiveTab
            end
        end)
        
        -- Tab hover effect
        TabButton.MouseEnter:Connect(function()
            if ActiveTab ~= tabName then
                TweenService:Create(TabButton, 
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {BackgroundColor3 = Settings.UI.Color.Tab.Hover}
                ):Play()
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if ActiveTab ~= tabName then
                TweenService:Create(TabButton, 
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {BackgroundColor3 = Settings.UI.Color.Tab.Unselected}
                ):Play()
            end
        end)
    end
    
    -- Helper function to create a section header
    local function CreateSection(parent, title, layoutOrder)
        local SectionFrame = Instance.new("Frame")
        SectionFrame.Name = title .. "Section"
        SectionFrame.Size = UDim2.new(1, 0, 0, 30)
        SectionFrame.BackgroundTransparency = 1
        SectionFrame.LayoutOrder = layoutOrder or 0
        SectionFrame.Parent = parent
        
        local SectionTitle = Instance.new("TextLabel")
        SectionTitle.Name = "SectionTitle"
        SectionTitle.Size = UDim2.new(1, 0, 1, 0)
        SectionTitle.Position = UDim2.new(0, 0, 0, 0)
        SectionTitle.BackgroundTransparency = 1
        SectionTitle.Text = title
        SectionTitle.Font = Enum.Font.GothamBold
        SectionTitle.TextColor3 = Settings.UI.Color.Accent
        SectionTitle.TextSize = 14
        SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
        SectionTitle.Parent = SectionFrame
        
        -- Add an underline
        local Underline = Instance.new("Frame")
        Underline.Name = "Underline"
        Underline.Size = UDim2.new(1, 0, 0, 1)
        Underline.Position = UDim2.new(0, 0, 1, -1)
        Underline.BackgroundColor3 = Settings.UI.Color.Accent
        Underline.BorderSizePixel = 0
        Underline.Transparency = 0.5
        Underline.Parent = SectionFrame
        
        return SectionFrame
    end
    
    -- Helper function to create a toggle
    local function CreateToggle(parent, title, initialValue, onChange, layoutOrder)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Name = title .. "Toggle"
        ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
        ToggleFrame.BackgroundTransparency = 1
        ToggleFrame.LayoutOrder = layoutOrder or 0
        ToggleFrame.Parent = parent
        
        local ToggleTitle = Instance.new("TextLabel")
        ToggleTitle.Name = "ToggleTitle"
        ToggleTitle.Size = UDim2.new(1, -60, 1, 0)
        ToggleTitle.Position = UDim2.new(0, 0, 0, 0)
        ToggleTitle.BackgroundTransparency = 1
        ToggleTitle.Text = title
        ToggleTitle.Font = Enum.Font.Gotham
        ToggleTitle.TextColor3 = Settings.UI.Color.Text
        ToggleTitle.TextSize = 14
        ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
        ToggleTitle.Parent = ToggleFrame
        
        -- Create the actual toggle button (improved style)
        local ToggleButton = Instance.new("Frame")
        ToggleButton.Name = "ToggleButton"
        ToggleButton.Size = UDim2.new(0, 44, 0, 22)
        ToggleButton.Position = UDim2.new(1, -50, 0.5, -11)
        ToggleButton.BackgroundColor3 = Settings.UI.Color.Toggle.Background
        ToggleButton.BorderSizePixel = 0
        ToggleButton.Parent = ToggleFrame
        
        -- Toggle button corner radius
        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, Settings.UI.Roundness.Toggle)
        ToggleCorner.Parent = ToggleButton
        
        -- Toggle knob
        local ToggleKnob = Instance.new("Frame")
        ToggleKnob.Name = "ToggleKnob"
        ToggleKnob.Size = UDim2.new(0, 18, 0, 18)
        ToggleKnob.Position = UDim2.new(0, initialValue and 24 or 2, 0.5, -9)
        ToggleKnob.BackgroundColor3 = initialValue and Settings.UI.Color.Toggle.On or Settings.UI.Color.Toggle.Off
        ToggleKnob.BorderSizePixel = 0
        ToggleKnob.Parent = ToggleButton
        
        -- Toggle knob corner radius
        local KnobCorner = Instance.new("UICorner")
        KnobCorner.CornerRadius = UDim.new(0, Settings.UI.Roundness.Toggle)
        KnobCorner.Parent = ToggleKnob
        
        -- Add indicator text
        local StatusText = Instance.new("TextLabel")
        StatusText.Name = "StatusText"
        StatusText.Size = UDim2.new(0, 30, 0, 20)
        StatusText.Position = UDim2.new(1, 5, 0.5, -10)
        StatusText.BackgroundTransparency = 1
        StatusText.Text = initialValue and "ON" or "OFF"
        StatusText.Font = Enum.Font.GothamBold
        StatusText.TextColor3 = initialValue and Settings.UI.Color.Toggle.On or Settings.UI.Color.Toggle.Off
        StatusText.TextSize = 12
        StatusText.TextXAlignment = Enum.TextXAlignment.Left
        StatusText.Parent = ToggleButton
        
        -- Add a subtle glow to the toggle when on
        local ToggleGlow = Instance.new("ImageLabel")
        ToggleGlow.Name = "ToggleGlow"
        ToggleGlow.AnchorPoint = Vector2.new(0.5, 0.5)
        ToggleGlow.BackgroundTransparency = 1
        ToggleGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
        ToggleGlow.Size = UDim2.new(1, 10, 1, 10)
        ToggleGlow.ZIndex = -1
        ToggleGlow.Image = "rbxassetid://6015897843" -- Glow asset
        ToggleGlow.ImageColor3 = Settings.UI.Color.Toggle.On
        ToggleGlow.ImageTransparency = initialValue and 0.7 or 1
        ToggleGlow.ScaleType = Enum.ScaleType.Slice
        ToggleGlow.SliceCenter = Rect.new(49, 49, 450, 450)
        ToggleGlow.Parent = ToggleButton
        
        -- Toggle functionality
        local isToggled = initialValue
        
        local function UpdateToggle(toggled, skipCallback)
            isToggled = toggled
            
            -- Animate knob position
            TweenService:Create(ToggleKnob, 
                TweenInfo.new(Settings.UI.Animation.ToggleSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Position = UDim2.new(0, toggled and 24 or 2, 0.5, -9)}
            ):Play()
            
            -- Animate knob color
            TweenService:Create(ToggleKnob, 
                TweenInfo.new(Settings.UI.Animation.ToggleSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {BackgroundColor3 = toggled and Settings.UI.Color.Toggle.On or Settings.UI.Color.Toggle.Off}
            ):Play()
            
            -- Update status text
            StatusText.Text = toggled and "ON" or "OFF"
            TweenService:Create(StatusText, 
                TweenInfo.new(Settings.UI.Animation.ToggleSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {TextColor3 = toggled and Settings.UI.Color.Toggle.On or Settings.UI.Color.Toggle.Off}
            ):Play()
            
            -- Animate glow
            TweenService:Create(ToggleGlow, 
                TweenInfo.new(Settings.UI.Animation.ToggleSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {ImageTransparency = toggled and 0.7 or 1}
            ):Play()
            
            -- Call the callback
            if not skipCallback and onChange then
                onChange(toggled)
            end
        end
        
        -- Make the entire frame clickable
        local ToggleClick = Instance.new("TextButton")
        ToggleClick.Name = "ToggleClick"
        ToggleClick.Size = UDim2.new(1, 0, 1, 0)
        ToggleClick.Position = UDim2.new(0, 0, 0, 0)
        ToggleClick.BackgroundTransparency = 1
        ToggleClick.Text = ""
        ToggleClick.Parent = ToggleFrame
        
        ToggleClick.MouseButton1Click:Connect(function()
            -- Create ripple effect
            local Ripple = Instance.new("Frame")
            Ripple.Name = "Ripple"
            Ripple.AnchorPoint = Vector2.new(0.5, 0.5)
            Ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
            Ripple.Size = UDim2.new(0, 0, 0, 0)
            Ripple.BackgroundColor3 = Settings.UI.Color.Accent
            Ripple.BackgroundTransparency = 0.8
            Ripple.BorderSizePixel = 0
            Ripple.ZIndex = 0
            Ripple.Parent = ToggleFrame
            
            local RippleCorner = Instance.new("UICorner")
            RippleCorner.CornerRadius = UDim.new(1, 0)
            RippleCorner.Parent = Ripple
            
            -- Animate ripple
            TweenService:Create(Ripple, 
                TweenInfo.new(Settings.UI.Animation.RippleSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Size = UDim2.new(1.5, 0, 1.5, 0), BackgroundTransparency = 1}
            ):Play()
            
            game.Debris:AddItem(Ripple, Settings.UI.Animation.RippleSpeed)
            
            -- Toggle the state
            UpdateToggle(not isToggled)
        end)
        
        -- Add hover effects
        ToggleClick.MouseEnter:Connect(function()
            TweenService:Create(ToggleButton, 
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {BackgroundColor3 = Settings.UI.Color.Toggle.Hover}
            ):Play()
        end)
        
        ToggleClick.MouseLeave:Connect(function()
            TweenService:Create(ToggleButton, 
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {BackgroundColor3 = Settings.UI.Color.Toggle.Background}
            ):Play()
        end)
        
        return {
            Frame = ToggleFrame,
            UpdateToggle = UpdateToggle,
            GetValue = function() return isToggled end
        }
    end
    
    -- Helper function to create a dropdown menu with options
    local function CreateDropdown(parent, title, options, initialOption, onChange, layoutOrder)
        -- Create container
        local DropdownFrame = Instance.new("Frame")
        DropdownFrame.Name = title .. "Dropdown"
        DropdownFrame.Size = UDim2.new(1, 0, 0, 60) -- Taller than toggle for dropdown list
        DropdownFrame.BackgroundTransparency = 1
        DropdownFrame.LayoutOrder = layoutOrder or 0
        DropdownFrame.Parent = parent
        
        -- Label
        local Label = Instance.new("TextLabel")
        Label.Name = "Label"
        Label.Size = UDim2.new(1, 0, 0, 20)
        Label.Position = UDim2.new(0, 0, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = title
        Label.TextColor3 = Settings.UI.Color.Text
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Font = Enum.Font.GothamBold
        Label.TextSize = 14
        Label.Parent = DropdownFrame
        
        -- Create neon text glow effect
        local TextGlow = Instance.new("ImageLabel")
        TextGlow.Name = "TextGlow"
        TextGlow.Size = UDim2.new(1, 20, 1, 20)
        TextGlow.Position = UDim2.new(0, -10, 0, -10)
        TextGlow.BackgroundTransparency = 1
        TextGlow.Image = "rbxassetid://5028857084" -- Soft glow texture
        TextGlow.ImageColor3 = Settings.UI.Color.Accent
        TextGlow.ImageTransparency = 0.7
        TextGlow.Parent = Label
        
        -- Selection button
        local SelectionButton = Instance.new("TextButton")
        SelectionButton.Name = "SelectionButton"
        SelectionButton.Size = UDim2.new(1, 0, 0, 30)
        SelectionButton.Position = UDim2.new(0, 0, 0, 25)
        SelectionButton.BackgroundColor3 = Settings.UI.Color.Secondary
        SelectionButton.TextColor3 = Settings.UI.Color.Text
        SelectionButton.Text = initialOption
        SelectionButton.Font = Enum.Font.Gotham
        SelectionButton.TextSize = 14
        SelectionButton.AutoButtonColor = false
        SelectionButton.ClipsDescendants = true
        SelectionButton.Parent = DropdownFrame
        
        -- Apply corner radius to button
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, Settings.UI.Roundness.Secondary)
        Corner.Parent = SelectionButton
        
        -- Add glow effect to button
        local ButtonGlow = Instance.new("ImageLabel")
        ButtonGlow.Name = "ButtonGlow"
        ButtonGlow.AnchorPoint = Vector2.new(0.5, 0.5)
        ButtonGlow.Size = UDim2.new(1, 20, 1, 20)
        ButtonGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
        ButtonGlow.BackgroundTransparency = 1
        ButtonGlow.Image = "rbxassetid://5028857084"
        ButtonGlow.ImageColor3 = Settings.UI.Color.Glow
        ButtonGlow.ImageTransparency = 0.8
        ButtonGlow.ZIndex = -1
        ButtonGlow.Parent = SelectionButton
        
        -- Dropdown container
        local DropdownList = Instance.new("Frame")
        DropdownList.Name = "DropdownList"
        DropdownList.Size = UDim2.new(1, 0, 0, #options * 30)
        DropdownList.Position = UDim2.new(0, 0, 1, 5)
        DropdownList.BackgroundColor3 = Settings.UI.Color.Secondary
        DropdownList.BorderSizePixel = 0
        DropdownList.ZIndex = 100
        DropdownList.Visible = false
        DropdownList.Parent = SelectionButton
        
        -- Apply corner radius to dropdown list
        local ListCorner = Instance.new("UICorner")
        ListCorner.CornerRadius = UDim.new(0, Settings.UI.Roundness.Secondary)
        ListCorner.Parent = DropdownList
        
        -- Add glow effect to dropdown list
        local ListGlow = Instance.new("ImageLabel")
        ListGlow.Name = "ListGlow"
        ListGlow.AnchorPoint = Vector2.new(0.5, 0.5)
        ListGlow.Size = UDim2.new(1, 20, 1, 20)
        ListGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
        ListGlow.BackgroundTransparency = 1
        ListGlow.Image = "rbxassetid://5028857084"
        ListGlow.ImageColor3 = Settings.UI.Color.Glow
        ListGlow.ImageTransparency = 0.8
        ListGlow.ZIndex = 99
        ListGlow.Parent = DropdownList
        
        -- Create list layout for options
        local ListLayout = Instance.new("UIListLayout")
        ListLayout.FillDirection = Enum.FillDirection.Vertical
        ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ListLayout.Padding = UDim.new(0, 2)
        ListLayout.Parent = DropdownList
        
        -- Create option buttons
        for i, option in ipairs(options) do
            local OptionButton = Instance.new("TextButton")
            OptionButton.Name = option
            OptionButton.Size = UDim2.new(1, 0, 0, 28)
            OptionButton.BackgroundColor3 = Settings.UI.Color.Secondary
            OptionButton.BackgroundTransparency = 0.5
            OptionButton.TextColor3 = Settings.UI.Color.Text
            OptionButton.Text = option
            OptionButton.Font = Enum.Font.Gotham
            OptionButton.TextSize = 14
            OptionButton.ZIndex = 101
            OptionButton.LayoutOrder = i
            OptionButton.AutoButtonColor = false
            OptionButton.ClipsDescendants = true
            OptionButton.Parent = DropdownList
            
            -- Add corner radius to option button
            local OptionCorner = Instance.new("UICorner")
            OptionCorner.CornerRadius = UDim.new(0, Settings.UI.Roundness.Button)
            OptionCorner.Parent = OptionButton
            
            -- Hover effect
            OptionButton.MouseEnter:Connect(function()
                TweenService:Create(OptionButton, TweenInfo.new(0.2), {BackgroundColor3 = Settings.UI.Color.Button.Hover}):Play()
            end)
            
            OptionButton.MouseLeave:Connect(function()
                TweenService:Create(OptionButton, TweenInfo.new(0.2), {BackgroundColor3 = Settings.UI.Color.Secondary}):Play()
            end)
            
            -- Click effect and selection
            OptionButton.MouseButton1Click:Connect(function()
                -- Ripple effect
                local Ripple = Instance.new("Frame")
                Ripple.Name = "Ripple"
                Ripple.AnchorPoint = Vector2.new(0.5, 0.5)
                Ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
                Ripple.BorderSizePixel = 0
                Ripple.BackgroundColor3 = Color3.new(1, 1, 1)
                Ripple.BackgroundTransparency = 0.8
                Ripple.ZIndex = 102
                
                -- Apply round shape to ripple
                local RippleCorner = Instance.new("UICorner")
                RippleCorner.CornerRadius = UDim.new(1, 0) -- Make it circular
                RippleCorner.Parent = Ripple
                
                local RippleSize = math.max(OptionButton.AbsoluteSize.X, OptionButton.AbsoluteSize.Y) * 2
                Ripple.Size = UDim2.new(0, 0, 0, 0)
                Ripple.Parent = OptionButton
                
                -- Animate ripple
                TweenService:Create(Ripple, TweenInfo.new(Settings.UI.Animation.RippleSpeed, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, RippleSize, 0, RippleSize),
                    BackgroundTransparency = 1
                }):Play()
                
                -- Set the selected option
                SelectionButton.Text = option
                DropdownList.Visible = false
                
                -- Trigger onChange callback
                onChange(option)
                
                -- Clean up ripple effect
                task.delay(Settings.UI.Animation.RippleSpeed, function()
                    Ripple:Destroy()
                end)
            end)
        end
        
        -- Toggle dropdown visibility when button is clicked
        SelectionButton.MouseButton1Click:Connect(function()
            DropdownList.Visible = not DropdownList.Visible
            
            -- Ripple effect
            local Ripple = Instance.new("Frame")
            Ripple.Name = "Ripple"
            Ripple.AnchorPoint = Vector2.new(0.5, 0.5)
            Ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
            Ripple.BorderSizePixel = 0
            Ripple.BackgroundColor3 = Color3.new(1, 1, 1)
            Ripple.BackgroundTransparency = 0.8
            Ripple.ZIndex = 99
            
            -- Apply round shape to ripple
            local RippleCorner = Instance.new("UICorner")
            RippleCorner.CornerRadius = UDim.new(1, 0) -- Make it circular
            RippleCorner.Parent = Ripple
            
            local RippleSize = math.max(SelectionButton.AbsoluteSize.X, SelectionButton.AbsoluteSize.Y) * 2
            Ripple.Size = UDim2.new(0, 0, 0, 0)
            Ripple.Parent = SelectionButton
            
            -- Animate ripple
            TweenService:Create(Ripple, TweenInfo.new(Settings.UI.Animation.RippleSpeed, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, RippleSize, 0, RippleSize),
                BackgroundTransparency = 1
            }):Play()
            
            -- Clean up ripple effect
            task.delay(Settings.UI.Animation.RippleSpeed, function()
                Ripple:Destroy()
            end)
        end)
        
        -- Hover effects for main button
        SelectionButton.MouseEnter:Connect(function()
            TweenService:Create(SelectionButton, TweenInfo.new(0.2), {BackgroundColor3 = Settings.UI.Color.Button.Hover}):Play()
        end)
        
        SelectionButton.MouseLeave:Connect(function()
            TweenService:Create(SelectionButton, TweenInfo.new(0.2), {BackgroundColor3 = Settings.UI.Color.Secondary}):Play()
        end)
        
        -- Close dropdown when clicking elsewhere
        UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mousePosition = Vector2.new(input.Position.X, input.Position.Y)
                if DropdownList.Visible then
                    -- Check if click is outside of dropdown area
                    local dropdownAbsPosition = DropdownList.AbsolutePosition
                    local dropdownAbsSize = DropdownList.AbsoluteSize
                    local selectionButtonAbsPosition = SelectionButton.AbsolutePosition
                    local selectionButtonAbsSize = SelectionButton.AbsoluteSize
                    
                    local inDropdown = mousePosition.X >= dropdownAbsPosition.X and
                                      mousePosition.X <= dropdownAbsPosition.X + dropdownAbsSize.X and
                                      mousePosition.Y >= dropdownAbsPosition.Y and
                                      mousePosition.Y <= dropdownAbsPosition.Y + dropdownAbsSize.Y
                                      
                    local inSelectionButton = mousePosition.X >= selectionButtonAbsPosition.X and
                                             mousePosition.X <= selectionButtonAbsPosition.X + selectionButtonAbsSize.X and
                                             mousePosition.Y >= selectionButtonAbsPosition.Y and
                                             mousePosition.Y <= selectionButtonAbsPosition.Y + selectionButtonAbsSize.Y
                    
                    if not (inDropdown or inSelectionButton) then
                        DropdownList.Visible = false
                    end
                end
            end
        end)
        
        return DropdownFrame
    end
    
    -- Helper function to create a slider
    local function CreateSlider(parent, title, min, max, initialValue, format, onChange, layoutOrder)
        format = format or "%.2f"
        
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Name = title .. "Slider"
        SliderFrame.Size = UDim2.new(1, 0, 0, 50)
        SliderFrame.BackgroundTransparency = 1
        SliderFrame.LayoutOrder = layoutOrder or 0
        SliderFrame.Parent = parent
        
        local SliderTitle = Instance.new("TextLabel")
        SliderTitle.Name = "SliderTitle"
        SliderTitle.Size = UDim2.new(1, 0, 0, 20)
        SliderTitle.Position = UDim2.new(0, 0, 0, 0)
        SliderTitle.BackgroundTransparency = 1
        SliderTitle.Text = title
        SliderTitle.Font = Enum.Font.Gotham
        SliderTitle.TextColor3 = Settings.UI.Color.Text
        SliderTitle.TextSize = 14
        SliderTitle.TextXAlignment = Enum.TextXAlignment.Left
        SliderTitle.Parent = SliderFrame
        
        -- Value text
        local ValueText = Instance.new("TextLabel")
        ValueText.Name = "ValueText"
        ValueText.Size = UDim2.new(0, 50, 0, 20)
        ValueText.Position = UDim2.new(1, -50, 0, 0)
        ValueText.BackgroundTransparency = 1
        ValueText.Text = string.format(format, initialValue)
        ValueText.Font = Enum.Font.GothamSemibold
        ValueText.TextColor3 = Settings.UI.Color.Slider.ValueText
        ValueText.TextSize = 14
        ValueText.TextXAlignment = Enum.TextXAlignment.Right
        ValueText.Parent = SliderFrame
        
        -- Slider background
        local SliderBG = Instance.new("Frame")
        SliderBG.Name = "SliderBG"
        SliderBG.Size = UDim2.new(1, 0, 0, 8)
        SliderBG.Position = UDim2.new(0, 0, 0, 30)
        SliderBG.BackgroundColor3 = Settings.UI.Color.Slider.Background
        SliderBG.BorderSizePixel = 0
        SliderBG.Parent = SliderFrame
        
        -- Slider background corner radius
        local SliderBGCorner = Instance.new("UICorner")
        SliderBGCorner.CornerRadius = UDim.new(0, Settings.UI.Roundness.Slider)
        SliderBGCorner.Parent = SliderBG
        
        -- Slider fill
        local SliderFill = Instance.new("Frame")
        SliderFill.Name = "SliderFill"
        local fillWidth = (initialValue - min) / (max - min)
        SliderFill.Size = UDim2.new(fillWidth, 0, 1, 0)
        SliderFill.Position = UDim2.new(0, 0, 0, 0)
        SliderFill.BackgroundColor3 = Settings.UI.Color.Slider.Bar
        SliderFill.BorderSizePixel = 0
        SliderFill.Parent = SliderBG
        
        -- Slider fill corner radius
        local SliderFillCorner = Instance.new("UICorner")
        SliderFillCorner.CornerRadius = UDim.new(0, Settings.UI.Roundness.Slider)
        SliderFillCorner.Parent = SliderFill
        
        -- Slider thumb
        local SliderThumb = Instance.new("Frame")
        SliderThumb.Name = "SliderThumb"
        SliderThumb.Size = UDim2.new(0, 16, 0, 16)
        SliderThumb.Position = UDim2.new(fillWidth, 0, 0.5, -8)
        SliderThumb.BackgroundColor3 = Settings.UI.Color.Slider.Thumb
        SliderThumb.BorderSizePixel = 0
        SliderThumb.ZIndex = 2
        SliderThumb.Parent = SliderBG
        
        -- Thumb shadow/glow
        local ThumbGlow = Instance.new("ImageLabel")
        ThumbGlow.Name = "ThumbGlow"
        ThumbGlow.AnchorPoint = Vector2.new(0.5, 0.5)
        ThumbGlow.BackgroundTransparency = 1
        ThumbGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
        ThumbGlow.Size = UDim2.new(1.5, 0, 1.5, 0)
        ThumbGlow.ZIndex = 1
        ThumbGlow.Image = "rbxassetid://6015897843" -- Glow asset
        ThumbGlow.ImageColor3 = Settings.UI.Color.Slider.Bar
        ThumbGlow.ImageTransparency = 0.7
        ThumbGlow.ScaleType = Enum.ScaleType.Slice
        ThumbGlow.SliceCenter = Rect.new(49, 49, 450, 450)
        ThumbGlow.Parent = SliderThumb
        
        -- Slider thumb corner radius (make it circular)
        local SliderThumbCorner = Instance.new("UICorner")
        SliderThumbCorner.CornerRadius = UDim.new(1, 0)
        SliderThumbCorner.Parent = SliderThumb
        
        -- Create invisible button for better interaction
        local SliderButton = Instance.new("TextButton")
        SliderButton.Name = "SliderButton"
        SliderButton.Size = UDim2.new(1, 0, 1, 16) -- Bigger hit area
        SliderButton.Position = UDim2.new(0, 0, 0, -8) -- Center on the bar
        SliderButton.BackgroundTransparency = 1
        SliderButton.Text = ""
        SliderButton.Parent = SliderBG
        
        -- Current value and state tracking
        local currentValue = initialValue
        local isDragging = false
        
        -- Function to update slider visuals
        local function UpdateSlider(value, skipCallback)
            -- Clamp value to min/max
            value = math.clamp(value, min, max)
            currentValue = value
            
            -- Calculate fill percentage
            local fillPercentage = (value - min) / (max - min)
            
            -- Update UI
            TweenService:Create(SliderFill, 
                TweenInfo.new(isDragging and 0 or Settings.UI.Animation.SliderSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Size = UDim2.new(fillPercentage, 0, 1, 0)}
            ):Play()
            
            TweenService:Create(SliderThumb, 
                TweenInfo.new(isDragging and 0 or Settings.UI.Animation.SliderSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Position = UDim2.new(fillPercentage, 0, 0.5, -8)}
            ):Play()
            
            -- Update value text
            ValueText.Text = string.format(format, value)
            
            -- Call callback
            if not skipCallback and onChange then
                onChange(value)
            end
        end
        
        -- Slider interaction
        SliderButton.MouseButton1Down:Connect(function()
            isDragging = true
            
            -- Enlarge thumb slightly on click for feedback
            TweenService:Create(SliderThumb, 
                TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(SliderThumb.Position.X.Scale, 0, 0.5, -9)}
            ):Play()
            
            -- Brighten thumb color
            TweenService:Create(SliderThumb, 
                TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {BackgroundColor3 = Settings.UI.Color.Slider.ThumbHover}
            ):Play()
            
            -- Start a connection that will end when mouse button is released
            local inputConnection
            inputConnection = UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    -- Calculate value from mouse position
                    local mousePos = UserInputService:GetMouseLocation()
                    local sliderPos = SliderBG.AbsolutePosition
                    local sliderSize = SliderBG.AbsoluteSize
                    
                    local relativeX = math.clamp((mousePos.X - sliderPos.X) / sliderSize.X, 0, 1)
                    local newValue = min + (relativeX * (max - min))
                    
                    UpdateSlider(newValue)
                end
            end)
            
            -- Clean up connection when button is released
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    if inputConnection then
                        inputConnection:Disconnect()
                    end
                    
                    isDragging = false
                    
                    -- Return thumb to normal size
                    TweenService:Create(SliderThumb, 
                        TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(SliderThumb.Position.X.Scale, 0, 0.5, -8)}
                    ):Play()
                    
                    -- Return thumb color to normal
                    TweenService:Create(SliderThumb, 
                        TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        {BackgroundColor3 = Settings.UI.Color.Slider.Thumb}
                    ):Play()
                end
            end)
        end)
        
        -- Click on slider to set value
        SliderButton.MouseButton1Click:Connect(function()
            -- Only handle click if we weren't dragging
            if not isDragging then
                local mousePos = UserInputService:GetMouseLocation()
                local sliderPos = SliderBG.AbsolutePosition
                local sliderSize = SliderBG.AbsoluteSize
                
                local relativeX = math.clamp((mousePos.X - sliderPos.X) / sliderSize.X, 0, 1)
                local newValue = min + (relativeX * (max - min))
                
                UpdateSlider(newValue)
                
                -- Briefly enlarge thumb for feedback then return to normal
                TweenService:Create(SliderThumb, 
                    TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(SliderThumb.Position.X.Scale, 0, 0.5, -9)}
                ):Play()
                
                TweenService:Create(SliderThumb, 
                    TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {BackgroundColor3 = Settings.UI.Color.Slider.ThumbHover}
                ):Play()
                
                wait(0.1)
                
                TweenService:Create(SliderThumb, 
                    TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(SliderThumb.Position.X.Scale, 0, 0.5, -8)}
                ):Play()
                
                TweenService:Create(SliderThumb, 
                    TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {BackgroundColor3 = Settings.UI.Color.Slider.Thumb}
                ):Play()
            end
        end)
        
        -- Hover effect for the thumb
        SliderButton.MouseEnter:Connect(function()
            if not isDragging then
                TweenService:Create(SliderThumb, 
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {BackgroundColor3 = Settings.UI.Color.Slider.ThumbHover}
                ):Play()
            end
        end)
        
        SliderButton.MouseLeave:Connect(function()
            if not isDragging then
                TweenService:Create(SliderThumb, 
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {BackgroundColor3 = Settings.UI.Color.Slider.Thumb}
                ):Play()
            end
        end)
        
        return {
            Frame = SliderFrame,
            UpdateValue = UpdateSlider,
            GetValue = function() return currentValue end
        }
    end
    
    -- Helper function to create a button
    local function CreateButton(parent, title, onClick, layoutOrder)
        local ButtonFrame = Instance.new("Frame")
        ButtonFrame.Name = title .. "Button"
        ButtonFrame.Size = UDim2.new(1, 0, 0, 35)
        ButtonFrame.BackgroundTransparency = 1
        ButtonFrame.LayoutOrder = layoutOrder or 0
        ButtonFrame.Parent = parent
        
        local Button = Instance.new("TextButton")
        Button.Name = "Button"
        Button.Size = UDim2.new(1, 0, 1, 0)
        Button.BackgroundColor3 = Settings.UI.Color.Button.Normal
        Button.BorderSizePixel = 0
        Button.Text = title
        Button.Font = Enum.Font.GothamSemibold
        Button.TextColor3 = Settings.UI.Color.Button.Text
        Button.TextSize = 14
        Button.AutoButtonColor = false
        Button.Parent = ButtonFrame
        
        -- Button corner radius
        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, Settings.UI.Roundness.Button)
        ButtonCorner.Parent = Button
        
        -- Button shadow
        local ButtonShadow = Instance.new("ImageLabel")
        ButtonShadow.Name = "ButtonShadow"
        ButtonShadow.AnchorPoint = Vector2.new(0.5, 0.5)
        ButtonShadow.BackgroundTransparency = 1
        ButtonShadow.Position = UDim2.new(0.5, 0, 0.5, 2)
        ButtonShadow.Size = UDim2.new(1, 4, 1, 4)
        ButtonShadow.ZIndex = 0
        ButtonShadow.Image = "rbxassetid://6015897843" -- Shadow asset
        ButtonShadow.ImageColor3 = Color3.new(0, 0, 0)
        ButtonShadow.ImageTransparency = 0.8
        ButtonShadow.ScaleType = Enum.ScaleType.Slice
        ButtonShadow.SliceCenter = Rect.new(49, 49, 450, 450)
        ButtonShadow.Parent = Button
        
        -- Button effects
        Button.MouseEnter:Connect(function()
            TweenService:Create(Button, 
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {BackgroundColor3 = Settings.UI.Color.Button.Hover}
            ):Play()
        end)
        
        Button.MouseLeave:Connect(function()
            TweenService:Create(Button, 
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {BackgroundColor3 = Settings.UI.Color.Button.Normal}
            ):Play()
        end)
        
        Button.MouseButton1Down:Connect(function()
            TweenService:Create(Button, 
                TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {BackgroundColor3 = Settings.UI.Color.Button.Pressed, Position = UDim2.new(0, 0, 0, 2), Size = UDim2.new(1, 0, 1, -2)}
            ):Play()
            
            TweenService:Create(ButtonShadow, 
                TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Position = UDim2.new(0.5, 0, 0.5, 0), ImageTransparency = 0.9}
            ):Play()
        end)
        
        Button.MouseButton1Up:Connect(function()
            TweenService:Create(Button, 
                TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {BackgroundColor3 = Settings.UI.Color.Button.Hover, Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(1, 0, 1, 0)}
            ):Play()
            
            TweenService:Create(ButtonShadow, 
                TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Position = UDim2.new(0.5, 0, 0.5, 2), ImageTransparency = 0.8}
            ):Play()
            
            -- Create ripple effect
            local Ripple = Instance.new("Frame")
            Ripple.Name = "Ripple"
            Ripple.AnchorPoint = Vector2.new(0.5, 0.5)
            Ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
            Ripple.Size = UDim2.new(0, 0, 0, 0)
            Ripple.BackgroundColor3 = Settings.UI.Color.Text
            Ripple.BackgroundTransparency = 0.8
            Ripple.BorderSizePixel = 0
            Ripple.ZIndex = 0
            Ripple.Parent = Button
            
            local RippleCorner = Instance.new("UICorner")
            RippleCorner.CornerRadius = UDim.new(1, 0)
            RippleCorner.Parent = Ripple
            
            -- Animate ripple
            TweenService:Create(Ripple, 
                TweenInfo.new(Settings.UI.Animation.RippleSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Size = UDim2.new(1.5, 0, 1.5, 0), BackgroundTransparency = 1}
            ):Play()
            
            game.Debris:AddItem(Ripple, Settings.UI.Animation.RippleSpeed)
        end)
        
        Button.MouseButton1Click:Connect(function()
            -- Add debug printing to help troubleshoot
            print("BUTTON CLICKED: " .. title)
            if onClick then 
                print("EXECUTING CLICK FUNCTION FOR: " .. title)
                onClick() 
                print("CLICK FUNCTION COMPLETE FOR: " .. title)
            end
        end)
        
        return {
            Frame = ButtonFrame,
            Button = Button
        }
    end
    
    -- Populate the Aimbot tab
    local AimbotContent = TabContentFrames["Aimbot"]
    
    -- Aimbot General Section
    local AimbotGeneralSection = CreateSection(AimbotContent, "General Settings", 0)
    
    -- Aimbot Enabled toggle
    local AimbotEnabledToggle = CreateToggle(AimbotContent, "Enable Aimbot", Settings.Aimbot.Enabled, function(value)
        Settings.Aimbot.Enabled = value
    end, 1)
    
    -- Mouse Aim toggle
    local MouseAimToggle = CreateToggle(AimbotContent, "Mouse Aim", Settings.Aimbot.AimMode == "Mouse", function(value)
        if value then
            -- Set to Mouse aim and update Camera toggle
            Settings.Aimbot.AimMode = "Mouse"
            if CameraAimToggle then
                CameraAimToggle.Switch.Position = UDim2.new(0, 0, 0.5, 0)
                CameraAimToggle.Switch.BackgroundColor3 = Settings.UI.Color.Switch.Off
                CameraAimToggle.Outline.BackgroundColor3 = Settings.UI.Color.Switch.OutlineOff
            end
            -- Debug message
            print("Switched to Mouse Aim mode")
        else
            -- If turning off, make sure Camera aim is on
            if not (CameraAimToggle and CameraAimToggle.Switch.Position.X.Scale > 0) then
                Settings.Aimbot.AimMode = "Camera"
                if CameraAimToggle then
                    CameraAimToggle.Switch.Position = UDim2.new(1, -10, 0.5, 0)
                    CameraAimToggle.Switch.BackgroundColor3 = Settings.UI.Color.Switch.On
                    CameraAimToggle.Outline.BackgroundColor3 = Settings.UI.Color.Switch.OutlineOn
                end
                -- Debug message
                print("Switched to Camera Aim mode (Mouse Aim toggle off)")
            end
        end
    end, 2)
    
    -- Camera Aim toggle
    local CameraAimToggle = CreateToggle(AimbotContent, "Camera Aim", Settings.Aimbot.AimMode == "Camera", function(value)
        if value then
            -- Set to Camera aim and update Mouse toggle
            Settings.Aimbot.AimMode = "Camera"
            if MouseAimToggle then
                MouseAimToggle.Switch.Position = UDim2.new(0, 0, 0.5, 0)
                MouseAimToggle.Switch.BackgroundColor3 = Settings.UI.Color.Switch.Off
                MouseAimToggle.Outline.BackgroundColor3 = Settings.UI.Color.Switch.OutlineOff
            end
            -- Debug message
            print("Switched to Camera Aim mode")
        else
            -- If turning off, make sure Mouse aim is on
            if not (MouseAimToggle and MouseAimToggle.Switch.Position.X.Scale > 0) then
                Settings.Aimbot.AimMode = "Mouse"
                if MouseAimToggle then
                    MouseAimToggle.Switch.Position = UDim2.new(1, -10, 0.5, 0)
                    MouseAimToggle.Switch.BackgroundColor3 = Settings.UI.Color.Switch.On
                    MouseAimToggle.Outline.BackgroundColor3 = Settings.UI.Color.Switch.OutlineOn
                end
                -- Debug message
                print("Switched to Mouse Aim mode (Camera Aim toggle off)")
            end
        end
    end, 3)
    
    -- FOV Settings Section
    local FOVSection = CreateSection(AimbotContent, "FOV Settings", 3)
    
    -- Show FOV Circle toggle
    local ShowFOVToggle = CreateToggle(AimbotContent, "Show FOV Circle", Settings.Aimbot.ShowFOV, function(value)
        Settings.Aimbot.ShowFOV = value
        FOVCircle.Visible = value
    end, 4)
    
    -- FOV Size slider
    local FOVSizeSlider = CreateSlider(AimbotContent, "FOV Size", 10, 800, Settings.Aimbot.FOV, "%.0f", function(value)
        Settings.Aimbot.FOV = value
        FOVCircle.Radius = value
    end, 5)
    
    -- Target Settings Section
    local TargetSection = CreateSection(AimbotContent, "Target Settings", 6)
    
    -- Team Check toggle
    local TeamCheckToggle = CreateToggle(AimbotContent, "Team Check", Settings.Aimbot.TeamCheck, function(value)
        Settings.Aimbot.TeamCheck = value
    end, 7)
    
    -- Center of Screen toggle
    local CenterScreenToggle = CreateToggle(AimbotContent, "Center of Screen", Settings.Aimbot.CenterOfScreen, function(value)
        Settings.Aimbot.CenterOfScreen = value
    end, 8)
    
    -- Smoothness slider
    local SmoothnessSlider = CreateSlider(AimbotContent, "Smoothness", 0.01, 1, Settings.Aimbot.Smoothness, "%.2f", function(value)
        Settings.Aimbot.Smoothness = value
    end, 9)
    
    -- Target Part dropdown (simplified as a button for now)
    local TargetPartButton = CreateButton(AimbotContent, "Target Part: " .. Settings.Aimbot.TargetPart, function()
        -- Cycle through common target parts
        local targets = {"Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso"}
        local currentIndex = table.find(targets, Settings.Aimbot.TargetPart) or 1
        currentIndex = currentIndex % #targets + 1
        Settings.Aimbot.TargetPart = targets[currentIndex]
        
        -- Update button text
        TargetPartButton.Button.Text = "Target Part: " .. Settings.Aimbot.TargetPart
    end, 10)
    
    -- Populate the ESP tab
    local ESPContent = TabContentFrames["ESP"]
    
    -- ESP General Section
    local ESPGeneralSection = CreateSection(ESPContent, "General Settings", 0)
    
    -- ESP Enabled toggle
    local ESPEnabledToggle = CreateToggle(ESPContent, "Enable ESP", Settings.ESP.Enabled, function(value)
        Settings.ESP.Enabled = value
    end, 1)
    
    -- Team ESP Section
    local TeamESPSection = CreateSection(ESPContent, "Team Settings", 2)
    
    -- Team Check toggle
    local ESPTeamCheckToggle = CreateToggle(ESPContent, "Team Check", Settings.ESP.TeamCheck, function(value)
        Settings.ESP.TeamCheck = value
    end, 3)
    
    -- Team ESP toggle
    local TeamESPToggle = CreateToggle(ESPContent, "Show Teammates", Settings.ESP.TeamMateDraw, function(value)
        Settings.ESP.TeamMateDraw = value
    end, 4)
    
    -- Display Section
    local DisplaySection = CreateSection(ESPContent, "Display Settings", 5)
    
    -- Box ESP toggle
    local BoxESPToggle = CreateToggle(ESPContent, "Box ESP", true, function(value)
        -- This is always enabled but controls visibility
    end, 6)
    
    -- Box Outline toggle
    local BoxOutlineToggle = CreateToggle(ESPContent, "Box Outline", Settings.ESP.BoxOutline, function(value)
        Settings.ESP.BoxOutline = value
    end, 7)
    
    -- Name Display toggle
    local NameDisplayToggle = CreateToggle(ESPContent, "Show Names", Settings.ESP.NameDisplay, function(value)
        Settings.ESP.NameDisplay = value
    end, 8)
    
    -- Distance Display toggle
    local DistanceDisplayToggle = CreateToggle(ESPContent, "Show Distance", Settings.ESP.DistanceDisplay, function(value)
        Settings.ESP.DistanceDisplay = value
    end, 9)
    
    -- Health Display toggle
    local HealthDisplayToggle = CreateToggle(ESPContent, "Show Health", Settings.ESP.HealthDisplay, function(value)
        Settings.ESP.HealthDisplay = value
    end, 10)
    
    -- Bone ESP toggle
    local BoneESPToggle = CreateToggle(ESPContent, "Skeleton ESP", Settings.ESP.BoneESP, function(value)
        Settings.ESP.BoneESP = value
    end, 11)
    
    -- Performance Section
    local PerformanceSection = CreateSection(ESPContent, "Performance Settings", 12)
    
    -- Optimization toggle
    local OptimizationToggle = CreateToggle(ESPContent, "Enable Optimization", Settings.ESP.OptimizationEnabled, function(value)
        Settings.ESP.OptimizationEnabled = value
    end, 13)
    
    -- Max Render Distance slider
    local RenderDistanceSlider = CreateSlider(ESPContent, "Max Render Distance", 100, 10000, Settings.ESP.MaxRenderDistance, "%.0f", function(value)
        Settings.ESP.MaxRenderDistance = value
    end, 14)
    
    -- Update Rate slider
    local UpdateRateSlider = CreateSlider(ESPContent, "Update Rate", 0.01, 0.5, Settings.ESP.UpdateRate, "%.2f", function(value)
        Settings.ESP.UpdateRate = value
    end, 15)
    
    -- Populate the new Misc tab
    local MiscContent = TabContentFrames["Misc"]
    
    -- Hitbox Expander Section
    local HitboxSection = CreateSection(MiscContent, "Hitbox Expander", 0)
    
    -- Hitbox Expander toggle
    local HitboxToggle = CreateToggle(MiscContent, "Enable Hitbox Expander", Settings.Misc.HitboxExpander.Enabled, function(value)
        Settings.Misc.HitboxExpander.Enabled = value
        
        -- Apply or revert hitbox changes
        if value then
            ApplyHitboxExpander()
        else
            RevertHitboxExpander()
        end
    end, 1)
    
    -- Hitbox Size slider
    local HitboxSizeSlider = CreateSlider(MiscContent, "Hitbox Size Multiplier", 1, 10, Settings.Misc.HitboxExpander.Size, "%.1f", function(value)
        Settings.Misc.HitboxExpander.Size = value
        
        -- Re-apply hitbox changes if enabled
        if Settings.Misc.HitboxExpander.Enabled then
            ApplyHitboxExpander()
        end
    end, 2)
    
    -- Hitbox Transparency slider
    local HitboxTransparencySlider = CreateSlider(MiscContent, "Hitbox Transparency", 0, 1, Settings.Misc.HitboxExpander.TransparencyLevel, "%.2f", function(value)
        Settings.Misc.HitboxExpander.TransparencyLevel = value
        
        -- Update transparency if enabled
        if Settings.Misc.HitboxExpander.Enabled then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and IsAlive(player) then
                    local character = player.Character
                    if character then
                        local part = character:FindFirstChild(Settings.Misc.HitboxExpander.PartToExpand)
                        if part then
                            part.Transparency = value
                        end
                    end
                end
            end
        end
    end, 3)
    
    -- Team Hitbox toggle
    local TeamHitboxToggle = CreateToggle(MiscContent, "Apply to Teammates", Settings.Misc.HitboxExpander.ApplyToTeam, function(value)
        Settings.Misc.HitboxExpander.ApplyToTeam = value
        
        -- Re-apply hitbox changes if enabled
        if Settings.Misc.HitboxExpander.Enabled then
            ApplyHitboxExpander()
        end
    end, 4)
    
    -- Hitbox Part dropdown (simplified as a button)
    local HitboxPartButton = CreateButton(MiscContent, "Target Part: " .. Settings.Misc.HitboxExpander.PartToExpand, function()
        -- Cycle through common target parts
        local targets = {"HumanoidRootPart", "Head", "Torso", "UpperTorso", "LowerTorso"}
        local currentIndex = table.find(targets, Settings.Misc.HitboxExpander.PartToExpand) or 1
        currentIndex = currentIndex % #targets + 1
        Settings.Misc.HitboxExpander.PartToExpand = targets[currentIndex]
        
        -- Update button text
        HitboxPartButton.Button.Text = "Target Part: " .. Settings.Misc.HitboxExpander.PartToExpand
        
        -- Re-apply hitbox changes if enabled
        if Settings.Misc.HitboxExpander.Enabled then
            RevertHitboxExpander() -- Revert first to avoid issues
            ApplyHitboxExpander()
        end
    end, 5)
    
    -- Speed Changer Section
    local SpeedSection = CreateSection(MiscContent, "Speed Changer", 6)
    
    -- Speed Changer toggle
    local SpeedToggle = CreateToggle(MiscContent, "Enable Speed Changer", Settings.Misc.SpeedChanger.Enabled, function(value)
        Settings.Misc.SpeedChanger.Enabled = value
        
        -- Apply or revert speed changes
        if value then
            ApplySpeedChanger()
        else
            RevertSpeedChanger()
        end
    end, 7)
    
    -- Speed Multiplier slider
    local SpeedMultiplierSlider = CreateSlider(MiscContent, "Speed Multiplier", 0.1, 10, Settings.Misc.SpeedChanger.SpeedMultiplier, "%.1f", function(value)
        Settings.Misc.SpeedChanger.SpeedMultiplier = value
        
        -- Re-apply speed changes if enabled
        if Settings.Misc.SpeedChanger.Enabled then
            ApplySpeedChanger()
        end
    end, 8)
    
    -- Apply on Sprint toggle
    local SprintToggle = CreateToggle(MiscContent, "Only Apply When Sprinting", Settings.Misc.SpeedChanger.ApplyOnSprint, function(value)
        Settings.Misc.SpeedChanger.ApplyOnSprint = value
    end, 9)
    
    -- Jump Multiplier Section
    local JumpSection = CreateSection(MiscContent, "Jump Multiplier", 10)
    
    -- Jump Multiplier toggle
    local JumpToggle = CreateToggle(MiscContent, "Enable Jump Multiplier", Settings.Misc.JumpMultiplier.Enabled, function(value)
        Settings.Misc.JumpMultiplier.Enabled = value
        
        -- Apply or revert jump changes
        if value then
            ApplyJumpMultiplier()
        else
            RevertJumpMultiplier()
        end
    end, 11)
    
    -- Jump Power slider
    local JumpPowerSlider = CreateSlider(MiscContent, "Jump Power Multiplier", 0.1, 10, Settings.Misc.JumpMultiplier.JumpPower, "%.1f", function(value)
        Settings.Misc.JumpMultiplier.JumpPower = value
        
        -- Re-apply jump changes if enabled
        if Settings.Misc.JumpMultiplier.Enabled then
            ApplyJumpMultiplier()
        end
    end, 12)
    
    -- Auto Apply toggle
    local AutoApplyToggle = CreateToggle(MiscContent, "Apply Automatically", Settings.Misc.JumpMultiplier.ApplyAutomatically, function(value)
        Settings.Misc.JumpMultiplier.ApplyAutomatically = value
    end, 13)
    
    -- Unload Button
    local UnloadButton = CreateButton(MiscContent, "Unload Script", function()
        UnloadScript()
    end, 14)
    
    -- Save UI elements for later reference
    UIElements = {
        MainFrame = MainFrame,
        ScreenGui = ScreenGui
    }
    
    -- Make the MainFrame draggable
    local isDragging = false
    local dragInput
    local dragStart
    local startPos
    
    local function updateDrag(input)
        local delta = input.Position - dragStart
        TweenService:Create(MainFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        }):Play()
    end
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isDragging = false
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
        if input == dragInput and isDragging then
            updateDrag(input)
        end
    end)
    
    -- Close button functionality
    CloseButton.MouseButton1Click:Connect(function()
        IsUIVisible = false
        MainFrame.Visible = false
    end)
    
    return ScreenGui
end

-- Function to apply hitbox expander
function ApplyHitboxExpander()
    -- Store original sizes and apply new sizes for all players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then  -- Don't apply to local player
            -- Apply to all players regardless of team
            -- Removed the team check to apply hitbox expansion to everyone
            
            local character = player.Character
            if character and IsAlive(player) then
                local targetPart = character:FindFirstChild(Settings.Misc.HitboxExpander.PartToExpand)
                if targetPart and targetPart:IsA("BasePart") then
                    -- Store original size if not already stored
                    if not OriginalHitboxes[player.UserId] then
                        OriginalHitboxes[player.UserId] = {
                            Size = targetPart.Size,
                            Transparency = targetPart.Transparency
                        }
                    end
                    
                    -- Apply new size
                    targetPart.Size = OriginalHitboxes[player.UserId].Size * Settings.Misc.HitboxExpander.Size
                    targetPart.Transparency = Settings.Misc.HitboxExpander.TransparencyLevel
                    targetPart.CanCollide = false -- Ensure it doesn't cause collision issues
                end
            end
        end
    end
end

-- Function to revert hitbox expander
function RevertHitboxExpander()
    for _, player in pairs(Players:GetPlayers()) do
        if OriginalHitboxes[player.UserId] then
            local character = player.Character
            if character and IsAlive(player) then
                local targetPart = character:FindFirstChild(Settings.Misc.HitboxExpander.PartToExpand)
                if targetPart and targetPart:IsA("BasePart") then
                    -- Restore original size and transparency
                    targetPart.Size = OriginalHitboxes[player.UserId].Size
                    targetPart.Transparency = OriginalHitboxes[player.UserId].Transparency
                end
            end
        end
    end
end

-- Function to apply speed changer
function ApplySpeedChanger()
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            -- Store original speed if not already stored
            if not OriginalSpeed then
                OriginalSpeed = humanoid.WalkSpeed
            end
            
            -- Apply new speed if not sprint-only or if sprint key is pressed
            if not Settings.Misc.SpeedChanger.ApplyOnSprint or UserInputService:IsKeyDown(Settings.Misc.SpeedChanger.SprintKey) then
                humanoid.WalkSpeed = OriginalSpeed * Settings.Misc.SpeedChanger.SpeedMultiplier
            else
                humanoid.WalkSpeed = OriginalSpeed
            end
        end
    end
end

-- Function to revert speed changer
function RevertSpeedChanger()
    local character = LocalPlayer.Character
    if character and OriginalSpeed then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = OriginalSpeed
        end
    end
end

-- Function to apply jump multiplier
function ApplyJumpMultiplier()
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            -- Store original jump power if not already stored
            if not OriginalJumpPower then
                OriginalJumpPower = humanoid.JumpPower
            end
            
            -- Apply new jump power
            humanoid.JumpPower = OriginalJumpPower * Settings.Misc.JumpMultiplier.JumpPower
            
            -- Connect to jump event for non-automatic application
            if not Settings.Misc.JumpMultiplier.ApplyAutomatically then
                humanoid.Jumping:Connect(function(active)
                    if active and Settings.Misc.JumpMultiplier.Enabled then
                        humanoid.JumpPower = OriginalJumpPower * Settings.Misc.JumpMultiplier.JumpPower
                    else
                        humanoid.JumpPower = OriginalJumpPower
                    end
                end)
            end
        end
    end
end

-- Function to revert jump multiplier
function RevertJumpMultiplier()
    local character = LocalPlayer.Character
    if character and OriginalJumpPower then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = OriginalJumpPower
        end
    end
end

-- Aimbot functionality
local function AimbotUpdate()
    if not Settings.Aimbot.Enabled then return end
    
    -- Update FOV circle
    UpdateFOVCircle()
    
    -- Check if key is pressed
    local isKeyDown = UserInputService:IsMouseButtonPressed(Settings.Aimbot.Key)
    if not isKeyDown then return end
    
    -- Get closest player
    local target = GetClosestPlayerToCursor()
    if not target then return end
    
    local character = target.Character
    if not character then return end
    
    local targetPart = character:FindFirstChild(Settings.Aimbot.TargetPart)
    if not targetPart then return end
    
    -- Calculate aim position with a slight randomization for less obvious aim
    local targetPosition = targetPart.Position
    
    -- Convert 3D position to 2D screen position
    local targetScreenPos, isOnScreen = Camera:WorldToScreenPoint(targetPosition)
    if not isOnScreen then return end
    
    -- Handle different aim modes
    if Settings.Aimbot.AimMode == "Camera" then
        -- Camera aim mode - adjust camera angle
        -- Get camera CFrame
        local cameraCFrame = Camera.CFrame
        
        -- Calculate direction to target
        local lookVector = (targetPosition - cameraCFrame.Position).Unit
        
        -- Calculate new CFrame with interpolation for smoothness
        local newCameraCFrame = CFrame.new(cameraCFrame.Position, cameraCFrame.Position + lookVector)
        Camera.CFrame = cameraCFrame:Lerp(newCameraCFrame, Settings.Aimbot.Smoothness)
    else
        -- Mouse aim mode - move the physical mouse
        -- Convert to Vector2 for mouse movement
        local targetPos2D = Vector2.new(targetScreenPos.X, targetScreenPos.Y)
        
        -- Get current mouse position
        local currentPos = Vector2.new(Mouse.X, Mouse.Y)
        
        -- Calculate direction and distance to target
        local moveDirection = (targetPos2D - currentPos)
        local distanceToTarget = moveDirection.Magnitude
        
        -- Only apply partial movement (smoothing) if we're not very close to the target
        -- This ensures we eventually center exactly on the target
        if distanceToTarget > 5 then -- Small threshold to consider "on target"
            -- Apply smoothing to the movement
            moveDirection = moveDirection * Settings.Aimbot.Smoothness
        else
            -- When very close to target, move directly to it
            moveDirection = targetPos2D - currentPos
        end
        
        -- Calculate new position with appropriate movement
        local newPos = currentPos + moveDirection
        
        -- Use mousemoveabs to move the mouse cursor directly to calculated position
        -- This moves the physical mouse cursor
        mousemoveabs(math.round(newPos.X), math.round(newPos.Y))
    end
end

-- Monitor player spawns for ESP and hitbox manipulation
local function SetupPlayerHandlers()
    -- Handle new players
    Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then
            -- Create ESP for new player
            ESPObjects[player] = {
                Box = Drawing.new("Square"),
                BoxOutline = Drawing.new("Square"),
                Name = Drawing.new("Text"),
                Distance = Drawing.new("Text"),
                Health = Drawing.new("Text"),
                Bones = {
                    -- Spine and Torso
                    Head_UpperTorso = Drawing.new("Line"),
                    UpperTorso_LowerTorso = Drawing.new("Line"),
                    
                    -- Left Arm
                    UpperTorso_LeftUpperArm = Drawing.new("Line"),
                    LeftUpperArm_LeftLowerArm = Drawing.new("Line"),
                    LeftLowerArm_LeftHand = Drawing.new("Line"),
                    
                    -- Right Arm
                    UpperTorso_RightUpperArm = Drawing.new("Line"),
                    RightUpperArm_RightLowerArm = Drawing.new("Line"),
                    RightLowerArm_RightHand = Drawing.new("Line"),
                    
                    -- Left Leg
                    LowerTorso_LeftUpperLeg = Drawing.new("Line"),
                    LeftUpperLeg_LeftLowerLeg = Drawing.new("Line"),
                    LeftLowerLeg_LeftFoot = Drawing.new("Line"),
                    
                    -- Right Leg
                    LowerTorso_RightUpperLeg = Drawing.new("Line"),
                    RightUpperLeg_RightLowerLeg = Drawing.new("Line"),
                    RightLowerLeg_RightFoot = Drawing.new("Line"),
                }
            }
            
            -- Box settings
            ESPObjects[player].Box.Thickness = 1
            ESPObjects[player].Box.Filled = false
            ESPObjects[player].Box.Transparency = 1
            
            -- Box outline settings
            ESPObjects[player].BoxOutline.Thickness = 3
            ESPObjects[player].BoxOutline.Filled = false
            ESPObjects[player].BoxOutline.Transparency = 1
            ESPObjects[player].BoxOutline.Color = Color3.fromRGB(0, 0, 0)
            
            -- Name settings
            ESPObjects[player].Name.Size = 13
            ESPObjects[player].Name.Center = true
            ESPObjects[player].Name.Outline = true
            
            -- Distance settings
            ESPObjects[player].Distance.Size = 12
            ESPObjects[player].Distance.Center = true
            ESPObjects[player].Distance.Outline = true
            
            -- Health settings
            ESPObjects[player].Health.Size = 12
            ESPObjects[player].Health.Center = true
            ESPObjects[player].Health.Outline = true
            
            -- Bone ESP settings
            for _, bone in pairs(ESPObjects[player].Bones) do
                bone.Thickness = 1.5
                bone.Transparency = 1
                bone.Color = Settings.ESP.BoneColor
            end
        end
    end)
    
    -- Handle player removal
    Players.PlayerRemoving:Connect(function(player)
        -- Remove ESP objects
        if ESPObjects[player] then
            for k, drawing in pairs(ESPObjects[player]) do
                if k ~= "Bones" then
                    drawing:Remove()
                else
                    for _, bone in pairs(drawing) do
                        bone:Remove()
                    end
                end
            end
            ESPObjects[player] = nil
        end
        
        -- Remove stored original hitbox data
        if OriginalHitboxes[player.UserId] then
            OriginalHitboxes[player.UserId] = nil
        end
    end)
    
    -- Handle character added for hitbox expansion
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            player.CharacterAdded:Connect(function(character)
                -- Apply hitbox expander if enabled
                if Settings.Misc.HitboxExpander.Enabled then
                    wait(1) -- Wait for character to fully load
                    
                    -- Apply to all players regardless of team (removed team check)
                    
                    local targetPart = character:FindFirstChild(Settings.Misc.HitboxExpander.PartToExpand)
                    if targetPart and targetPart:IsA("BasePart") then
                        -- Store original size
                        OriginalHitboxes[player.UserId] = {
                            Size = targetPart.Size,
                            Transparency = targetPart.Transparency
                        }
                        
                        -- Apply new size
                        targetPart.Size = OriginalHitboxes[player.UserId].Size * Settings.Misc.HitboxExpander.Size
                        targetPart.Transparency = Settings.Misc.HitboxExpander.TransparencyLevel
                        targetPart.CanCollide = false -- Ensure it doesn't cause collision issues
                    end
                end
            end)
        end
    end
    
    -- Handle local player character changes for speed and jump
    LocalPlayer.CharacterAdded:Connect(function(character)
        wait(1) -- Wait for character to fully load
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            -- Store original values
            OriginalSpeed = humanoid.WalkSpeed
            OriginalJumpPower = humanoid.JumpPower
            
            -- Apply speed changer if enabled
            if Settings.Misc.SpeedChanger.Enabled then
                ApplySpeedChanger()
            end
            
            -- Apply jump multiplier if enabled
            if Settings.Misc.JumpMultiplier.Enabled then
                ApplyJumpMultiplier()
            end
        end
    end)
    
    -- Initialize for current character
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            OriginalSpeed = humanoid.WalkSpeed
            OriginalJumpPower = humanoid.JumpPower
        end
    end
end

-- Function to unload the script
function UnloadScript()
    -- Clean up all drawing objects
    FOVCircle:Remove()
    RemoveDrawings()
    
    -- Clean up UI
    if UIElements.ScreenGui then
        UIElements.ScreenGui:Destroy()
    end
    
    -- Remove all connections
    for _, connection in pairs(getgenv().Connections or {}) do
        connection:Disconnect()
    end
    
    -- Revert any changes made
    RevertHitboxExpander()
    RevertSpeedChanger()
    RevertJumpMultiplier()
    
    -- Reset global variables
    getgenv().Connections = nil
    getgenv().Loaded = false
    
    -- Clear metatables/registry/environment entries if needed for complete unload
    
    -- Notify user
    if notification then notification("Script unloaded successfully", 3) end
end

-- Main setup
local function InitializeScript()
    if Loaded then return end
    
    -- Create UI
    local UI = CreateUI()
    
    -- Initialize drawings
    CreateDrawings()
    
    -- Set up player handlers
    SetupPlayerHandlers()
    
    -- Store connections for proper cleanup
    getgenv().Connections = getgenv().Connections or {}
    
    -- Main update loop for Aimbot
    table.insert(getgenv().Connections, RunService.RenderStepped:Connect(AimbotUpdate))
    
    -- ESP update loop
    table.insert(getgenv().Connections, RunService.RenderStepped:Connect(UpdateESP))
    
    -- Speed changer update based on sprint key
    table.insert(getgenv().Connections, RunService.Heartbeat:Connect(function()
        if Settings.Misc.SpeedChanger.Enabled and Settings.Misc.SpeedChanger.ApplyOnSprint then
            local character = LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid and OriginalSpeed then
                    if UserInputService:IsKeyDown(Settings.Misc.SpeedChanger.SprintKey) then
                        humanoid.WalkSpeed = OriginalSpeed * Settings.Misc.SpeedChanger.SpeedMultiplier
                    else
                        humanoid.WalkSpeed = OriginalSpeed
                    end
                end
            end
        end
    end))
    
    -- Input handling for toggle keys
    table.insert(getgenv().Connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        -- Unload script
        if input.KeyCode == Settings.Misc.UnloadKey then
            UnloadScript()
        end
        
        -- Toggle UI
        if input.KeyCode == Settings.Misc.UIKeybind then
            IsUIVisible = not IsUIVisible
            UIElements.MainFrame.Visible = IsUIVisible
        end
    end))
    
    Loaded = true
end

-- Start the script
InitializeScript()
