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

-- Load the menu library (modified to be black and white)
local library = loadstring(readfile("https://raw.githubusercontent.com/Roblox-Menu-Thing/Roblox-Menu-Thing.github.io/refs/heads/main/Scripts/Lib-Test/Lib.lua"))()

-- Create the menu with black and white theme
local menu = library.new([[universal <font color="rgb(255, 255, 255)">v1</font>]], "nemv2\\", {
    main_color = Color3.fromRGB(30, 30, 30),
    background_color = Color3.fromRGB(20, 20, 20),
    accent_color = Color3.fromRGB(255, 255, 255),
    text_color = Color3.fromRGB(255, 255, 255),
    outline_color = Color3.fromRGB(50, 50, 50)
})

local tabs = {
    menu.new_tab("http://www.roblox.com/asset/?id=7300477598"),
    menu.new_tab("http://www.roblox.com/asset/?id=7300535052"),
    menu.new_tab("http://www.roblox.com/asset/?id=7300480952"),
    menu.new_tab("http://www.roblox.com/asset/?id=7300486042"),
    menu.new_tab("http://www.roblox.com/asset/?id=7300489566"),
}

do
    local _menu = tabs[5].new_section("menu")

    local all_cfgs

    local configs = _menu.new_sector("configs")
    local text
    local list = configs.element("Scroll", "config list", {options = {"none"}}, function(State)
        text:set_value({Text = State.Scroll})
    end)
    text = configs.element("TextBox", "config name")
    configs.element("Button", "save", nil, function()
        if menu.values[5].menu.configs["config name"].Text ~= "none" then
            menu.save_cfg(menu.values[5].menu.configs["config name"].Text)
        end
    end)
    configs.element("Button", "load", nil, function()
        if menu.values[5].menu.configs["config name"].Text ~= "none" then
            menu.load_cfg(menu.values[5].menu.configs["config name"].Text)
        end
    end)

    local function update_cfgs()
        all_cfgs = listfiles("nemv2\\")
        for _,cfg in next, all_cfgs do
            all_cfgs[_] = string.gsub(string.gsub(cfg, "nemv2\\", ""), ".txt", "")
            list:add_value(all_cfgs[_])
        end
    end update_cfgs()

    task.spawn(function()
        while true do
            wait(1)
            update_cfgs()
        end
    end)

    local methods = _menu.new_sector("methods", "Right")
    methods.element("Combo", "mouse types", {options = {"target", "hit"}})
    methods.element("Dropdown", "ray method", {options = {"none", "findpartonray", "findpartonraywithignorelist", "raycast"}})
    methods.element("Slider", "minimum ray ignore", {default = {min = 0, max = 100, default = 3}})
    methods.element("Combo", "must include", {options = {"camera", "character"}, default = {Combo = {"camera", "character"}}})

    local playercheck = _menu.new_sector("player check")
    playercheck.element("Toggle", "free for all")
    playercheck.element("Toggle", "forcefield check")
end

do
    local aimbot = tabs[1].new_section("aimbot")

    local main = aimbot.new_sector("main")
    main.element("Toggle", "enabled"):add_keybind()
    main.element("Dropdown", "origin", {options = {"camera", "head"}})
    main.element("Dropdown", "hitbox", {options = {"head", "torso"}})
    main.element("Toggle", "automatic fire")

    local antiaim = tabs[1].new_section("antiaim")

    local direction = antiaim.new_sector("direction")
    direction.element("Toggle", "enabled"):add_keybind()
    direction.element("Dropdown", "yaw base", {options = {"camera", "random", "spin"}})
    direction.element("Slider", "yaw offset", {default = {min = -180, max = 180, default = 0}})
    direction.element("Dropdown", "yaw modifier", {options = {"none", "jitter", "offset jitter"}})
    direction.element("Slider", "modifier offset", {default = {min = -180, max = 180, default = 0}})
    direction.element("Toggle", "force angles")

    local fakelag = antiaim.new_sector("fakelag", "Right")
    fakelag.element("Toggle", "enabled"):add_keybind()
    fakelag.element("Dropdown", "method", {options = {"static", "random"}})
    fakelag.element("Slider", "limit", {default = {min = 1, max = 16, default = 6}})
    fakelag.element("Toggle", "visualize"):add_color({Color = Color3.new(1,1,1), Transparency = 0.5}, true)
    fakelag.element("Toggle", "freeze world", nil, function(state)
        if menu.values[1].antiaim.fakelag["freeze world"].Toggle and menu.values[1].antiaim.fakelag["$freeze world"].Active then
            settings().Network.IncomingReplicationLag = 1000
        else
            settings().Network.IncomingReplicationLag = 0
        end
    end):add_keybind(nil, function(state)
        if menu.values[1].antiaim.fakelag["freeze world"].Toggle and menu.values[1].antiaim.fakelag["$freeze world"].Active then
            settings().Network.IncomingReplicationLag = 1000
        else
            settings().Network.IncomingReplicationLag = 0
        end
    end)

    local Line = Drawing.new("Line")
    Line.Visible = false
    Line.Transparency = 1
    Line.Color = Color3.new(1,1,1)
    Line.Thickness = 1
    Line.ZIndex = 1

    local EnabledPosition = Vector3.new()
    fakelag.element("Toggle", "no send", nil, function(State)
        if menu.values[1].antiaim.fakelag["no send"].Toggle and menu.values[1].antiaim.fakelag["$no send"].Active then
            local SelfCharacter = LocalPlayer.Character
            local SelfRootPart, SelfHumanoid = SelfCharacter and SelfCharacter:FindFirstChild("HumanoidRootPart"), SelfCharacter and SelfCharacter:FindFirstChildOfClass("Humanoid")
            if not SelfCharacter or not SelfRootPart or not SelfHumanoid then Line.Visible = false return end

            EnabledPosition = SelfRootPart.Position
        end
    end):add_keybind(nil, function(State)
        if menu.values[1].antiaim.fakelag["no send"].Toggle and menu.values[1].antiaim.fakelag["$no send"].Active then
            local SelfCharacter = LocalPlayer.Character
            local SelfRootPart, SelfHumanoid = SelfCharacter and SelfCharacter:FindFirstChild("HumanoidRootPart"), SelfCharacter and SelfCharacter:FindFirstChildOfClass("Humanoid")
            if not SelfCharacter or not SelfRootPart or not SelfHumanoid then Line.Visible = false return end

            EnabledPosition = SelfRootPart.Position
        end
    end)

    local WasEnabled = false
    local FakelagLoop = RunService.Heartbeat:Connect(function()
        local Enabled = menu.values[1].antiaim.fakelag["no send"].Toggle and menu.values[1].antiaim.fakelag["$no send"].Active or false

        local SelfCharacter = LocalPlayer.Character
        local SelfRootPart, SelfHumanoid = SelfCharacter and SelfCharacter:FindFirstChild("HumanoidRootPart"), SelfCharacter and SelfCharacter:FindFirstChildOfClass("Humanoid")
        if not SelfCharacter or not SelfRootPart or not SelfHumanoid then Line.Visible = false return end

        sethiddenproperty(SelfRootPart, "NetworkIsSleeping", Enabled)

        Line.Visible = Enabled
        local StartPos = Camera:WorldToViewportPoint(SelfRootPart.Position)
        Line.From = Vector2.new(StartPos.X, StartPos.Y)
        local EndPos, OnScreen = Camera:WorldToViewportPoint(EnabledPosition)
        if not OnScreen then
            Line.Visible = false
        end
        Line.To = Vector2.new(EndPos.X, EndPos.Y)
    end)

    task.spawn(function()
        local Network = game:GetService("NetworkClient")
        local LagTick = 0

        while true do
            wait(1/16)
            LagTick = math.clamp(LagTick + 1, 0, menu.values[1].antiaim.fakelag.limit.Slider)
            if menu.values[1].antiaim.fakelag.enabled.Toggle and menu.values[1].antiaim.fakelag["$enabled"].Active and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                if LagTick == (menu.values[1].antiaim.fakelag.method.Dropdown == "static" and menu.values[1].antiaim.fakelag.limit.Slider or math.random(1, menu.values[1].antiaim.fakelag.limit.Slider)) then
                    Network:SetOutgoingKBPSLimit(9e9)
                    LagTick = 0

                    if LocalPlayer.Character:FindFirstChild("Fakelag") then
                        LocalPlayer.Character:FindFirstChild("Fakelag"):ClearAllChildren()
                    else
                        local Folder = Instance.new("Folder")
                        Folder.Name = "Fakelag"
                        Folder.Parent = LocalPlayer.Character
                    end
                    if menu.values[1].antiaim.fakelag.visualize.Toggle then
                        LocalPlayer.Character.Archivable = true
                        local Clone = LocalPlayer.Character:Clone()
                        for _,Obj in next, Clone:GetDescendants() do
                            if Obj.Name == "HumanoidRootPart" or Obj:IsA("Humanoid") or Obj:IsA("LocalScript") or Obj:IsA("Script") or Obj:IsA("Decal") then
                                Obj:Destroy()
                            elseif Obj:IsA("BasePart") or Obj:IsA("Meshpart") or Obj:IsA("Part") then
                                if Obj.Transparency == 1 then
                                    Obj:Destroy()
                                else
                                    Obj.CanCollide = false
                                    Obj.Anchored = true
                                    Obj.Material = "ForceField"
                                    Obj.Color = menu.values[1].antiaim.fakelag["$visualize"].Color
                                    Obj.Transparency = menu.values[1].antiaim.fakelag["$visualize"].Transparency
                                    Obj.Size = Obj.Size + Vector3.new(0.03, 0.03, 0.03)
                                end
                            end
                            pcall(function()
                                Obj.CanCollide = false
                            end)
                        end
                        Clone.Parent = LocalPlayer.Character.Fakelag
                    end
                else
                    Network:SetOutgoingKBPSLimit(1)
                end
            else
                if LocalPlayer.Character then
                    if LocalPlayer.Character:FindFirstChild("Fakelag") then
                        LocalPlayer.Character:FindFirstChild("Fakelag"):ClearAllChildren()
                    else
                        local Folder = Instance.new("Folder")
                        Folder.Name = "Fakelag"
                        Folder.Parent = LocalPlayer.Character
                    end
                end
                Network:SetOutgoingKBPSLimit(9e9)
            end
        end
    end)
end

-- Create the FOV circle with black and white color scheme
local Circle = Drawing.new("Circle") do
    Circle.Color = Color3.fromRGB(255, 255, 255) -- White color
    Circle.Thickness = 1
    Circle.Transparency = 1
    Circle.Radius = 100
    Circle.Visible = false

    RunService.RenderStepped:Connect(function()
        Circle.Position = UserInputService:GetMouseLocation()
        if menu.values[2].advanced["mouse offset"].enabled.Toggle then
            Circle.Position = Circle.Position + Vector2.new(menu.values[2].advanced["mouse offset"]["x offset"].Slider, menu.values[2].advanced["mouse offset"]["y offset"].Slider)
        end
    end)
end

-- ESP Section (Black and White theme)
do
    local esp = tabs[2].new_section("esp")
    
    local drawings = esp.new_sector("drawings")
    drawings.element("Toggle", "enabled")
    drawings.element("Toggle", "box"):add_color({Color = Color3.new(1,1,1)}, true)
    drawings.element("Toggle", "name"):add_color({Color = Color3.new(1,1,1)})
    drawings.element("Toggle", "health"):add_color({Color = Color3.new(1,1,1)})
    drawings.element("Toggle", "weapon"):add_color({Color = Color3.new(1,1,1)})
    drawings.element("Toggle", "distance"):add_color({Color = Color3.new(1,1,1)})
    
    local options = esp.new_sector("options", "Right")
    options.element("Slider", "max distance", {default = {min = 100, max = 5000, default = 1000}})
    options.element("Toggle", "team check")
    options.element("Toggle", "visible check")
    
    local chams = esp.new_sector("chams")
    chams.element("Toggle", "enabled")
    chams.element("Toggle", "visible only")
    chams.element("Dropdown", "material", {options = {"SmoothPlastic", "ForceField", "Neon"}})
    chams.element("Slider", "transparency", {default = {min = 0, max = 1, default = 0.5}})
    chams.element("Toggle", "visible chams"):add_color({Color = Color3.new(1,1,1), Transparency = 0.5})
    chams.element("Toggle", "invisible chams"):add_color({Color = Color3.new(0.5,0.5,0.5), Transparency = 0.5})
end

-- Visuals Section
do
    local visuals = tabs[3].new_section("visuals")
    
    local world = visuals.new_sector("world")
    world.element("Toggle", "force time"):add_color({Color = Color3.new(1,1,1)})
    world.element("Slider", "time", {default = {min = 0, max = 24, default = 12}})
    world.element("Toggle", "brightness")
    world.element("Slider", "brightness amount", {default = {min = 0, max = 10, default = 2}})
    world.element("Toggle", "ambient"):add_color({Color = Color3.new(1,1,1)})
    
    local camera = visuals.new_sector("camera", "Right")
    camera.element("Toggle", "fov changer")
    camera.element("Slider", "field of view", {default = {min = 30, max = 120, default = 70}})
    camera.element("Toggle", "no zoom")
end

-- Crosshair Section
do
    local cross = tabs[2].new_section("crosshair", "Right")
    
    local main = cross.new_sector("main")
    main.element("Toggle", "enabled")
    main.element("Toggle", "position"):add_color({Color = Color3.new(1,1,1)})
    
    local settings = cross.new_sector("settings")
    settings.element("Slider", "length", {default = {min = 1, max = 100, default = 10}})
    settings.element("Slider", "gap", {default = {min = 0, max = 20, default = 2}})
    settings.element("Slider", "thickness", {default = {min = 1, max = 10, default = 1}})
end

-- FOV Settings
do
    local fovsettings = tabs[1].new_section("fov", "Right")
    
    local main = fovsettings.new_sector("main")
    main.element("Toggle", "enabled")
    main.element("Toggle", "filled"):add_color({Color = Color3.new(1,1,1), Transparency = 0.1}, true)
    main.element("Toggle", "outline"):add_color({Color = Color3.new(0,0,0)})
    main.element("Slider", "size", {default = {min = 10, max = 300, default = 100}})
    
    local target = fovsettings.new_sector("target", "right")
    target.element("Toggle", "enabled")
    target.element("Toggle", "filled"):add_color({Color = Color3.new(1,1,1), Transparency = 0.1}, true)
    target.element("Toggle", "outline"):add_color({Color = Color3.new(0,0,0)})
    target.element("Slider", "size", {default = {min = 10, max = 300, default = 50}})
end

-- Apply black and white theme on all existing UI elements
menu:set_theme({
    main_color = Color3.fromRGB(30, 30, 30),
    background_color = Color3.fromRGB(20, 20, 20),
    accent_color = Color3.fromRGB(255, 255, 255),
    text_color = Color3.fromRGB(255, 255, 255),
    outline_color = Color3.fromRGB(50, 50, 50)
})
