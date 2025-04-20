-- Rivals Aimbot Made By Syfer-eng
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

-- Core variables
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Settings (feel free to modify)
local Settings = {
    AimPart = "Head",          -- Which part to target (Head, HumanoidRootPart, Torso)
    TeamCheck = false,         -- Skip teammates
    FOV = 500,                 -- Field of view size
    Smoothness = 0.5,          -- Lower = faster (0.01-1)
    Prediction = 0.13,         -- Prediction multiplier
    AlwaysOn = false,          -- If true, don't need to hold right click
    
    -- Visual settings
    CircleVisible = true,      -- Show FOV circle
    SnapLineVisible = true,    -- Show snap lines
    CircleColor = Color3.fromRGB(255, 0, 0),
    SnapLineColor = Color3.fromRGB(255, 0, 0),
    CircleThickness = 2,
    SnapLineThickness = 2
}

-- State variables
local Aiming = false            -- Actively aiming
local Visual = {}               -- Visual elements
local ClosestTarget = nil       -- Current target

-- Create FOV circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = Settings.CircleVisible
FOVCircle.Transparency = 1
FOVCircle.Color = Settings.CircleColor
FOVCircle.Thickness = Settings.CircleThickness
FOVCircle.Filled = false
FOVCircle.Radius = Settings.FOV

-- Create snap line
local SnapLine = Drawing.new("Line")
SnapLine.Visible = false
SnapLine.Transparency = 1
SnapLine.Color = Settings.SnapLineColor
SnapLine.Thickness = Settings.SnapLineThickness

-- Get closest player to mouse
local function GetClosestPlayer()
    local MaxDist = Settings.FOV
    local Target = nil
    
    -- Get mouse position
    local MousePos = UserInputService:GetMouseLocation()
    
    -- Update FOV circle position
    FOVCircle.Position = MousePos
    
    -- Loop through all players
    for _, Player in pairs(Players:GetPlayers()) do
        -- Skip LocalPlayer
        if Player == LocalPlayer then continue end
        
        -- Team check
        if Settings.TeamCheck and Player.Team == LocalPlayer.Team then continue end
        
        -- Character check
        local Character = Player.Character
        if not Character then continue end
        
        -- Get target part
        local TargetPart = Character:FindFirstChild(Settings.AimPart)
        if not TargetPart then 
            TargetPart = Character:FindFirstChild("Head") 
            if not TargetPart then continue end
        end
        
        -- Check if alive
        local Humanoid = Character:FindFirstChild("Humanoid")
        if not Humanoid or Humanoid.Health <= 0 then continue end
        
        -- Get target on screen
        local PartPos, OnScreen = Camera:WorldToViewportPoint(TargetPart.Position)
        if not OnScreen then continue end
        
        -- Get distance from mouse
        local Distance = (Vector2.new(PartPos.X, PartPos.Y) - MousePos).Magnitude
        
        -- Check if within FOV
        if Distance < MaxDist then
            MaxDist = Distance
            Target = TargetPart
        end
    end
    
    return Target
end

-- Update functions for each frame
local function Update()
    -- Update FOV circle
    FOVCircle.Visible = Settings.CircleVisible
    FOVCircle.Radius = Settings.FOV
    FOVCircle.Color = Settings.CircleColor
    FOVCircle.Thickness = Settings.CircleThickness
    
    -- Get target
    ClosestTarget = GetClosestPlayer()
    
    -- Update snap line
    if Settings.SnapLineVisible and ClosestTarget then
        local MousePos = UserInputService:GetMouseLocation()
        local TargetPos = Camera:WorldToViewportPoint(ClosestTarget.Position)
        
        SnapLine.From = MousePos
        SnapLine.To = Vector2.new(TargetPos.X, TargetPos.Y)
        SnapLine.Visible = true
        SnapLine.Color = Settings.SnapLineColor
        SnapLine.Thickness = Settings.SnapLineThickness
    else
        SnapLine.Visible = false
    end
    
    -- Actual aimbot logic
    if (Aiming or Settings.AlwaysOn) and ClosestTarget then
        -- Get target position
        local Position = ClosestTarget.Position
        local HRP = ClosestTarget.Parent:FindFirstChild("HumanoidRootPart")
        
        -- Add prediction
        if HRP and HRP:IsA("BasePart") then
            Position = Position + (HRP.Velocity * Vector3.new(Settings.Prediction, 0, Settings.Prediction))
        end
        
        -- Calculate aim position
        local TargetPos = Camera:WorldToViewportPoint(Position)
        local MousePos = UserInputService:GetMouseLocation()
        
        -- Calculate movement
        local AimOffset = Vector2.new(
            (TargetPos.X - MousePos.X) * Settings.Smoothness,
            (TargetPos.Y - MousePos.Y) * Settings.Smoothness
        )
        
        -- Move mouse
        mousemoverel(AimOffset.X, AimOffset.Y)
    end
end

-- Toggle aiming state with right mouse button
UserInputService.InputBegan:Connect(function(Input, Processed)
    if Processed then return end
    
    if Input.UserInputType == Enum.UserInputType.MouseButton2 then
        Aiming = true
    end
    
    -- Toggle FOV circle with Home key
    if Input.KeyCode == Enum.KeyCode.Home then
        Settings.CircleVisible = not Settings.CircleVisible
    end
    
    -- Toggle snap line with Insert key
    if Input.KeyCode == Enum.KeyCode.Insert then
        Settings.SnapLineVisible = not Settings.SnapLineVisible
    end
    
    -- Toggle always on with End key
    if Input.KeyCode == Enum.KeyCode.End then
        Settings.AlwaysOn = not Settings.AlwaysOn
        print("Always On: " .. tostring(Settings.AlwaysOn))
    end
end)

UserInputService.InputEnded:Connect(function(Input, Processed)
    if Processed then return end
    
    if Input.UserInputType == Enum.UserInputType.MouseButton2 then
        Aiming = false
    end
end)

-- Connect to RenderStepped for smooth performance
RunService.RenderStepped:Connect(Update)

-- Notification on load
print("==============================")
print("Simple Aimbot Loaded!")
print("Right Click: Activate aimbot")
print("Home: Toggle FOV circle")
print("Insert: Toggle snap line") 
print("End: Toggle always-on mode")
print("==============================")
