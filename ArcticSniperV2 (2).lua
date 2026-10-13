--[[
    AS | ARCTIC SNIPER V2 — FROST EDITION
    Standalone GUI | Local UI/demo tools
    Scanner, spawn feed, and Discord panels are previews only.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local OLD = PlayerGui:FindFirstChild("ArcticSniperV2")
if OLD then OLD:Destroy() end

local C = {
    BG = Color3.fromRGB(5, 10, 20),
    PANEL = Color3.fromRGB(10, 20, 35),
    PANEL2 = Color3.fromRGB(16, 34, 54),
    BLUE = Color3.fromRGB(70, 180, 255),
    ICE = Color3.fromRGB(190, 235, 255),
    WHITE = Color3.fromRGB(240, 248, 255),
    MUTED = Color3.fromRGB(125, 155, 182),
    GREEN = Color3.fromRGB(83, 225, 168),
    RED = Color3.fromRGB(255, 105, 125),
}

local gui = Instance.new("ScreenGui")
gui.Name = "ArcticSniperV2"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = PlayerGui

local function make(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do obj[k] = v end
    obj.Parent = parent
    return obj
end

local function round(obj, radius)
    make("UICorner", {CornerRadius = UDim.new(0, radius or 10)}, obj)
end

local function stroke(obj, color, thickness, transparency)
    make("UIStroke", {
        Color = color or C.BLUE,
        Thickness = thickness or 1,
        Transparency = transparency == nil and 0.5 or transparency
    }, obj)
end

local function label(parent, text, size, position, fontSize, color)
    return make("TextLabel", {
        BackgroundTransparency = 1,
        Text = text,
        Size = size,
        Position = position,
        Font = Enum.Font.Gotham,
        TextSize = fontSize or 13,
        TextColor3 = color or C.WHITE,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextWrapped = true,
    }, parent)
end

local function button(parent, text, size, position, callback)
    local b = make("TextButton", {
        Size = size,
        Position = position,
        BackgroundColor3 = C.PANEL2,
        Text = text,
        TextColor3 = C.WHITE,
        TextSize = 12,
        Font = Enum.Font.GothamSemibold,
        AutoButtonColor = false,
    }, parent)
    round(b, 8)
    stroke(b, C.BLUE, 1, 0.72)
    b.Activated:Connect(function()
        if callback then callback() end
    end)
    return b
end

local function input(parent, placeholder, size, position)
    local box = make("TextBox", {
        Size = size,
        Position = position,
        BackgroundColor3 = C.BG,
        Text = "",
        PlaceholderText = placeholder,
        PlaceholderColor3 = C.MUTED,
        TextColor3 = C.WHITE,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false,
    }, parent)
    round(box, 8)
    stroke(box, C.BLUE, 1, 0.8)
    return box
end

-- Compact window; UIScale keeps it within the current viewport.
local main = make("Frame", {
    Name = "Main",
    Size = UDim2.fromOffset(560, 420),
    Position = UDim2.new(0.5, -280, 0.5, -210),
    BackgroundColor3 = C.BG,
    BorderSizePixel = 0,
    ClipsDescendants = true,
}, gui)
round(main, 14)
stroke(main, C.BLUE, 1.5, 0.3)

local scale = make("UIScale", {Scale = 1}, main)

local function updateScale()
    local camera = workspace.CurrentCamera
    if not camera then return end
    local viewport = camera.ViewportSize
    scale.Scale = math.min(1, viewport.X / 580, viewport.Y / 440)
end

updateScale()
if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end

local header = make("Frame", {
    Name = "Header",
    Size = UDim2.new(1, 0, 0, 58),
    BackgroundColor3 = C.PANEL,
    BorderSizePixel = 0,
    ZIndex = 2,
}, main)
round(header, 14)
make("Frame", {
    Size = UDim2.new(1, 0, 0, 15),
    Position = UDim2.new(0, 0, 1, -15),
    BackgroundColor3 = C.PANEL,
    BorderSizePixel = 0,
}, header)
make("Frame", {
    Size = UDim2.new(1, -28, 0, 2),
    Position = UDim2.new(0, 14, 1, -1),
    BackgroundColor3 = C.BLUE,
    BorderSizePixel = 0,
}, header)

label(header, "❄", UDim2.new(0, 32, 0, 38), UDim2.new(0, 12, 0, 8), 26, C.BLUE)
label(header, "ARCTIC SNIPER", UDim2.new(0, 220, 0, 24), UDim2.new(0, 48, 0, 8), 16, C.ICE)
label(header, "V2  •  FROST EDITION", UDim2.new(0, 220, 0, 18), UDim2.new(0, 50, 0, 31), 9, C.MUTED)

local mini -- assigned below; close button hides panel so AS can reopen it
local close = button(header, "–", UDim2.new(0, 32, 0, 30), UDim2.new(1, -42, 0, 13), function()
    main.Visible = false
    if mini then mini.Visible = true end
end)

-- Main window drag (mouse and touch).
do
    local dragging = false
    local dragStart, startPosition
    header.InputBegan:Connect(function(io)
        if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = io.Position
            startPosition = main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(io)
        if dragging and (io.UserInputType == Enum.UserInputType.MouseMovement or io.UserInputType == Enum.UserInputType.Touch) then
            local delta = io.Position - dragStart
            main.Position = UDim2.new(
                startPosition.X.Scale, startPosition.X.Offset + delta.X,
                startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(io)
        if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- Floating AS control; drag with touch/mouse, tap to toggle.
mini = button(gui, "❄ AS", UDim2.fromOffset(64, 38), UDim2.new(0, 16, 0.5, -19), nil)
mini.Visible = true
mini.ZIndex = 20
mini.TextSize = 13
local miniStroke = mini:FindFirstChildOfClass("UIStroke")
if miniStroke then miniStroke.Thickness = 1.5; miniStroke.Transparency = 0.15 end

do
    local dragging = false
    local moved = false
    local dragStart, startPosition
    local activeInput
    mini.InputBegan:Connect(function(io)
        if io.UserInputType == Enum.UserInputType.Touch or io.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            moved = false
            dragStart = io.Position
            startPosition = mini.Position
            activeInput = io
        end
    end)
    UserInputService.InputChanged:Connect(function(io)
        if not dragging then return end
        if io.UserInputType == Enum.UserInputType.Touch or io.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = io.Position - dragStart
            if math.abs(delta.X) > 6 or math.abs(delta.Y) > 6 then moved = true end
            if moved then
                local camera = workspace.CurrentCamera
                if not camera then return end
                local viewport = camera.ViewportSize
                local x = startPosition.X.Offset + delta.X
                local y = startPosition.Y.Offset + delta.Y
                x = math.clamp(x, 0, math.max(0, viewport.X - mini.AbsoluteSize.X))
                y = math.clamp(y, 0, math.max(0, viewport.Y - mini.AbsoluteSize.Y))
                mini.Position = UDim2.fromOffset(x, y)
            end
        end
    end)
    UserInputService.InputEnded:Connect(function(io)
        if not dragging then return end
        if io.UserInputType == Enum.UserInputType.Touch or io.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            if not moved then
                main.Visible = not main.Visible
                if main.Visible then mini.Visible = false else mini.Visible = true end
            end
            activeInput = nil
        end
    end)
end

local sidebar = make("Frame", {
    Size = UDim2.new(0, 112, 1, -74),
    Position = UDim2.new(0, 8, 0, 66),
    BackgroundColor3 = C.PANEL,
    BorderSizePixel = 0,
}, main)
round(sidebar, 10)
label(sidebar, "MENU", UDim2.new(1, -16, 0, 22), UDim2.new(0, 10, 0, 7), 9, C.MUTED)

local content = make("Frame", {
    Size = UDim2.new(1, -136, 1, -74),
    Position = UDim2.new(0, 126, 0, 66),
    BackgroundTransparency = 1,
}, main)

local pageNames = {"Home", "Scanner", "Redeemer", "Brainrots", "Discord", "Settings", "Activity Log"}
local pages, navButtons, logs = {}, {}, {}
local scanEnabled, spawnEnabled, autoSubmit, notifications = false, false, false, true

local function addLog(message)
    table.insert(logs, 1, "[" .. os.date("%H:%M:%S") .. "] " .. message)
    if #logs > 80 then table.remove(logs) end
    local logPage = pages["Activity Log"]
    local list = logPage and logPage:FindFirstChild("LogList")
    if list then
        for _, child in ipairs(list:GetChildren()) do
            if child:IsA("TextLabel") then child:Destroy() end
        end
        for i = 1, math.min(#logs, 22) do
            label(list, logs[i], UDim2.new(1, -12, 0, 25), UDim2.new(0, 6, 0, (i - 1) * 27), 10, C.ICE)
        end
        list.CanvasSize = UDim2.new(0, 0, 0, math.min(#logs, 22) * 27)
    end
end

local function newPage(name)
    local p = make("ScrollingFrame", {
        Name = name,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = C.BLUE,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
    }, content)
    make("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, p)
    make("UIPadding", {
        PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 7)
    }, p)
    pages[name] = p
    return p
end

local function card(parent, title, description, height)
    local frame = make("Frame", {
        Size = UDim2.new(1, -4, 0, height or 85),
        BackgroundColor3 = C.PANEL,
        BorderSizePixel = 0,
    }, parent)
    round(frame, 10)
    stroke(frame, C.BLUE, 1, 0.83)
    label(frame, title, UDim2.new(1, -20, 0, 23), UDim2.new(0, 10, 0, 6), 12, C.ICE)
    if description then
        label(frame, description, UDim2.new(1, -20, 0, 38), UDim2.new(0, 10, 0, 30), 10, C.MUTED)
    end
    return frame
end

local function switch(parent, title, initial, callback)
    local frame = make("Frame", {
        Size = UDim2.new(1, -4, 0, 42),
        BackgroundColor3 = C.PANEL,
        BorderSizePixel = 0,
    }, parent)
    round(frame, 9)
    label(frame, title, UDim2.new(1, -82, 1, 0), UDim2.new(0, 10, 0, 0), 10, C.WHITE)
    local on = initial
    local b = button(frame, on and "ON" or "OFF", UDim2.new(0, 54, 0, 27), UDim2.new(1, -62, 0.5, -13), nil)
    local function refresh()
        b.Text = on and "ON" or "OFF"
        b.BackgroundColor3 = on and Color3.fromRGB(20, 76, 94) or C.PANEL2
        b.TextColor3 = on and C.GREEN or C.MUTED
    end
    b.Activated:Connect(function()
        on = not on
        refresh()
        if callback then callback(on) end
    end)
    refresh()
    return frame, function() return on end
end

local function goTo(name)
    for pageName, p in pairs(pages) do p.Visible = pageName == name end
    for pageName, b in pairs(navButtons) do
        b.BackgroundColor3 = pageName == name and C.PANEL2 or C.PANEL
        b.TextColor3 = pageName == name and C.ICE or C.MUTED
    end
end

for i, name in ipairs(pageNames) do
    local b = button(sidebar, name, UDim2.new(1, -12, 0, 32), UDim2.new(0, 6, 0, 34 + (i - 1) * 37), function()
        goTo(name)
    end)
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.Text = " " .. name
    b.TextSize = 10
    b.BackgroundColor3 = C.PANEL
    b.TextColor3 = C.MUTED
    navButtons[name] = b
end
label(sidebar, "FROST V2", UDim2.new(1, -16, 0, 20), UDim2.new(0, 9, 1, -25), 8, C.MUTED)

-- HOME
do
    local p = newPage("Home")
    local welcome = card(p, "WELCOME TO ARCTIC SNIPER", "A compact frosty control panel for scanner tools and notifications.", 94)
    label(welcome, "❄  SYSTEM READY", UDim2.new(1, -20, 0, 18), UDim2.new(0, 10, 1, -23), 10, C.GREEN)
    local stats = card(p, "QUICK STATUS", nil, 80)
    label(stats, "Scanner: DEMO", UDim2.new(0.5, -10, 0, 22), UDim2.new(0, 10, 0, 12), 10, C.ICE)
    label(stats, "Spawn feed: TEST", UDim2.new(0.5, -10, 0, 22), UDim2.new(0.5, 0, 0, 12), 10, C.ICE)
    label(stats, "Redeemer: Preview only", UDim2.new(1, -20, 0, 18), UDim2.new(0, 10, 0, 42), 10, C.MUTED)
    local actions = card(p, "QUICK ACTIONS", nil, 75)
    button(actions, "SCANNER", UDim2.new(0.48, -4, 0, 29), UDim2.new(0, 8, 0, 37), function() goTo("Scanner") end)
    button(actions, "SPAWN FEED", UDim2.new(0.48, -4, 0, 29), UDim2.new(0.52, 0, 0, 37), function() goTo("Brainrots") end)
    card(p, "IMPORTANT", "Demo interface only; it cannot detect private game events by itself.", 67)
end

-- SCANNER
do
    local p = newPage("Scanner")
    card(p, "CODE SCANNER", "Paste text to test phrases like 'use code' or 'the code is'.", 70)
    local textBox = input(p, "Paste announcement text...", UDim2.new(1, -4, 0, 38), UDim2.new(0, 0, 0, 0))
    textBox.LayoutOrder = 2
    local result = card(p, "SCAN RESULT", "Waiting for text...", 80)
    result.LayoutOrder = 3
    button(result, "TEST SCAN", UDim2.new(0, 92, 0, 27), UDim2.new(1, -102, 1, -34), function()
        local text = textBox.Text
        local old = result:FindFirstChild("ScanStatus")
        if old then old:Destroy() end
        local lower = string.lower(text)
        local found = text ~= "" and (string.find(lower, "use code", 1, true) or string.find(lower, "the code is", 1, true) or string.find(lower, "code:", 1, true))
        local status = label(result, text == "" and "Enter text first." or (found and "Potential code phrase detected." or "No code phrase detected."), UDim2.new(1, -20, 0, 20), UDim2.new(0, 10, 0, 31), 10, text == "" and C.RED or (found and C.GREEN or C.MUTED))
        status.Name = "ScanStatus"
        addLog(text == "" and "Scanner test: empty input" or (found and "Test scanner detected a code phrase" or "Test scan completed"))
    end)
    switch(p, "Scanner enabled (demo)", false, function(value)
        scanEnabled = value
        addLog("Scanner demo " .. (value and "enabled" or "disabled"))
    end)
    card(p, "HOW IT WORKS", "Tests only the text you enter; it does not read game announcements automatically.", 75)
end

-- REDEEMER
do
    local p = newPage("Redeemer")
    card(p, "CODE REDEEMER", "Check code formatting and preview it; this does not redeem in-game.", 70)
    local codeBox = input(p, "Enter code...", UDim2.new(1, -4, 0, 38), UDim2.new(0, 0, 0, 0))
    codeBox.LayoutOrder = 2
    local preview = card(p, "CODE PREVIEW", "No code entered.", 78)
    preview.LayoutOrder = 3
    button(preview, "CHECK", UDim2.new(0, 72, 0, 27), UDim2.new(1, -82, 1, -33), function()
        local value = string.gsub(codeBox.Text, "^%s*(.-)%s*$", "%1")
        local old = preview:FindFirstChild("CodeStatus")
        if old then old:Destroy() end
        local message, color
        if value == "" then message, color = "Enter a code first.", C.RED
        elseif #value > 64 then message, color = "Code is too long.", C.RED
        elseif string.find(value, "%s") then message, color = "Code contains spaces.", C.RED
        else message, color = "Input looks valid: " .. value, C.GREEN end
        local status = label(preview, message, UDim2.new(1, -20, 0, 20), UDim2.new(0, 10, 0, 30), 10, color)
        status.Name = "CodeStatus"
        addLog("Code format checked")
    end)
    switch(p, "Auto-submit preference", false, function(value)
        autoSubmit = value
        addLog("Auto-submit preference " .. (value and "enabled" or "disabled"))
    end)
    card(p, "SAFETY NOTE", "This toggle only saves a UI preference; it does not submit anything.", 68)
end

-- BRAINROTS
do
    local p = newPage("Brainrots")
    card(p, "BRAINROT SPAWN FEED", "Preview how a spawn notification could look.", 70)
    local feed = card(p, "LATEST EVENT", "No test events yet.", 82)
    local feedText = label(feed, "Waiting for a test event...", UDim2.new(1, -20, 0, 20), UDim2.new(0, 10, 0, 30), 10, C.MUTED)
    button(feed, "TEST SPAWN", UDim2.new(0, 96, 0, 27), UDim2.new(1, -106, 1, -33), function()
        feedText.Text = "TEST • Sample Brainrot appeared"
        feedText.TextColor3 = C.GREEN
        addLog("Sample Brainrot spawn event")
    end)
    switch(p, "Spawn notifications (demo)", false, function(value)
        spawnEnabled = value
        addLog("Spawn feed demo " .. (value and "enabled" or "disabled"))
    end)
    card(p, "LIVE EVENTS", "Live detection needs a supported, authorized event source; this panel does not inspect game internals.", 78)
end

-- DISCORD
do
    local p = newPage("Discord")
    card(p, "DISCORD NOTIFICATIONS", "Preview a message format for your own bot/backend.", 70)
    local discordBox = input(p, "Notification text...", UDim2.new(1, -4, 0, 38), UDim2.new(0, 0, 0, 0))
    discordBox.LayoutOrder = 2
    local preview = card(p, "MESSAGE PREVIEW", "❄ ARCTIC SNIPER\nNo message created yet.", 100)
    preview.LayoutOrder = 3
    button(preview, "PREVIEW", UDim2.new(0, 82, 0, 27), UDim2.new(1, -92, 1, -33), function()
        local value = discordBox.Text
        if value == "" then value = "Sample notification" end
        local old = preview:FindFirstChild("DiscordMessage")
        if old then old:Destroy() end
        local msg = label(preview, "❄ ARCTIC SNIPER\n" .. value, UDim2.new(1, -20, 0, 42), UDim2.new(0, 10, 0, 29), 10, C.ICE)
        msg.Name = "DiscordMessage"
        addLog("Discord message preview created")
    end)
    card(p, "CONNECTION STATUS", "Preview only; no webhook or Discord message is sent.", 68)
end

-- SETTINGS
do
    local p = newPage("Settings")
    card(p, "PERSONALIZATION", "Adjust preferences for this GUI session.", 65)
    switch(p, "Notifications preference", true, function(value)
        notifications = value
        addLog("Notification preference " .. (value and "enabled" or "disabled"))
    end)
    switch(p, "Show floating AS button", true, function(value)
        mini.Visible = value or not main.Visible
    end)
    local theme = card(p, "THEME", "Current theme: Arctic Ice Blue", 70)
    button(theme, "ICE BLUE ✓", UDim2.new(0, 94, 0, 27), UDim2.new(1, -104, 1, -33), function()
        addLog("Arctic Ice Blue theme selected")
    end)
    card(p, "WINDOW CONTROLS", "Drag the header to move the panel. Tap AS to reopen it.", 68)
end

-- ACTIVITY LOG
do
    local p = newPage("Activity Log")
    local frame = make("Frame", {
        Size = UDim2.new(1, -4, 0, 330),
        BackgroundColor3 = C.PANEL,
        BorderSizePixel = 0,
    }, p)
    round(frame, 10)
    stroke(frame, C.BLUE, 1, 0.8)
    label(frame, "ACTIVITY LOG", UDim2.new(1, -20, 0, 26), UDim2.new(0, 10, 0, 6), 12, C.ICE)
    local list = make("ScrollingFrame", {
        Name = "LogList",
        Size = UDim2.new(1, -16, 1, -72),
        Position = UDim2.new(0, 8, 0, 36),
        BackgroundColor3 = C.BG,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = C.BLUE,
        CanvasSize = UDim2.new(0, 0, 0, 0),
    }, frame)
    round(list, 8)
    button(frame, "CLEAR LOG", UDim2.new(0, 82, 0, 26), UDim2.new(1, -92, 1, -31), function()
        table.clear(logs)
        for _, child in ipairs(list:GetChildren()) do
            if child:IsA("TextLabel") then child:Destroy() end
        end
        list.CanvasSize = UDim2.new(0, 0, 0, 0)
    end)
end

-- Screen-wide snowfall, independent of whether the main panel is open.
task.spawn(function()
    while gui.Parent do
        local camera = workspace.CurrentCamera
        if camera then
            local viewport = camera.ViewportSize
            local snow = make("TextLabel", {
                BackgroundTransparency = 1,
                Text = "❄",
                TextColor3 = C.ICE,
                TextTransparency = 0.25,
                TextSize = math.random(10, 18),
                Font = Enum.Font.Gotham,
                Size = UDim2.fromOffset(22, 22),
                Position = UDim2.fromOffset(math.random(0, math.max(1, viewport.X)), -24),
                ZIndex = 50,
                Active = false,
            }, gui)
            local duration = math.random(5, 9)
            local endX = snow.Position.X.Offset + math.random(-60, 60)
            local tween = TweenService:Create(snow, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
                Position = UDim2.fromOffset(endX, viewport.Y + 24),
                TextTransparency = 1,
            })
            tween:Play()
            tween.Completed:Connect(function()
                if snow.Parent then snow:Destroy() end
            end)
        end
        task.wait(0.3)
    end
end)

addLog("Arctic Sniper V2 interface loaded")
goTo("Home")
