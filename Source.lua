-- source.lua -- JustineHubLib UI Library
-- This library creates an intro UI that is customizable through a configuration table.

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local function CreateMainUI(config)
    config = config or {}

    -- Configuration defaults
    local frameColor = config.frameColor or Color3.fromRGB(0, 60, 130)
    local gradientTop = config.gradientTop or Color3.fromRGB(0, 90, 150)
    local gradientBottom = config.gradientBottom or Color3.fromRGB(0, 40, 80)
    local introText = config.introText or "Justine Hub"
    local titleText = config.titleText or "Justine Hub by Justine"
    local introSize = config.introSize or UDim2.new(0, 250, 0, 100)
    local introPosition = config.introPosition or UDim2.new(0.5, -125, 0.5, -50)
    local cornerRadius = config.cornerRadius or UDim.new(0, 12)

    -- Create GUI
    local gui = Instance.new("ScreenGui")
    gui.Name = "JustineHubLib"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = game:GetService("CoreGui")

    -- Intro Frame
    local frame = Instance.new("Frame")
    frame.Size = introSize
    frame.Position = introPosition
    frame.BackgroundTransparency = 1
    frame.BackgroundColor3 = frameColor
    frame.BorderSizePixel = 0
    frame.Parent = gui

    -- Gradient on Frame
    local gradient = Instance.new("UIGradient", frame)
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, gradientTop),
        ColorSequenceKeypoint.new(1, gradientBottom)
    }

    -- Rounded Corners
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = cornerRadius

    -- Intro Text (big cover)
    local introTitle = Instance.new("TextLabel")
    introTitle.Text = introText
    introTitle.Size = UDim2.new(1, 0, 1, 0)
    introTitle.BackgroundTransparency = 1
    introTitle.Font = Enum.Font.GothamBold
    introTitle.TextSize = 16
    introTitle.TextColor3 = Color3.new(1, 1, 1)
    introTitle.TextStrokeTransparency = 0.8
    introTitle.TextTransparency = 1
    introTitle.Parent = frame

    TweenService:Create(frame, TweenInfo.new(1), {BackgroundTransparency = 0}):Play()
    TweenService:Create(introTitle, TweenInfo.new(1), {TextTransparency = 0}):Play()

    task.wait(5)
    introTitle:Destroy()

    -- Expand Frame to main UI
    TweenService:Create(frame, TweenInfo.new(1), {
        Size = UDim2.new(0, 480, 0, 240),
        Position = UDim2.new(0.5, -140, 0.5, -120)
    }):Play()

    task.wait(1.1)

    -- Small Title (header) on top of main UI
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = titleText
    titleLabel.Size = UDim2.new(1, -10, 0, 20)
    titleLabel.Position = UDim2.new(0, 5, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 10
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = frame

    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "X"
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -30, 0, 5)
    closeBtn.BackgroundTransparency = 1
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.Parent = frame
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

    -- Minimize Button (simple: hides the frame contents below the header)
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Text = "—"
    minimizeBtn.Size = UDim2.new(0, 25, 0, 25)
    minimizeBtn.Position = UDim2.new(1, -60, 0, 5)
    minimizeBtn.BackgroundTransparency = 1
    minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.TextSize = 14
    minimizeBtn.Parent = frame
    minimizeBtn.MouseButton1Click:Connect(function()
        frame.Visible = false
    end)

    -- (Dragging logic for frame)
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    -- Draggable Toggle Button (to show/hide the main frame)
    local toggleBtn = Instance.new("ImageButton")
    toggleBtn.Size = UDim2.new(0, 60, 0, 60)
    toggleBtn.Position = UDim2.new(0, 10, 0.5, -30)
    toggleBtn.BackgroundTransparency = 1
    toggleBtn.Image = "rbxassetid://118356508526283"
    toggleBtn.Name = "JustineToggle"
    toggleBtn.Parent = gui

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBtn

    toggleBtn.MouseButton1Click:Connect(function()
        frame.Visible = not frame.Visible
    end)

    local toggleDragging = false
    local toggleStart, togglePos, toggleDragInput

    local function updateToggle(input)
        local delta = input.Position - toggleStart
        toggleBtn.Position = UDim2.new(togglePos.X.Scale, togglePos.X.Offset + delta.X,
            togglePos.Y.Scale, togglePos.Y.Offset + delta.Y)
    end

    toggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            toggleDragging = true
            toggleStart = input.Position
            togglePos = toggleBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    toggleDragging = false
                end
            end)
        end
    end)

    toggleBtn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            toggleDragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == toggleDragInput and toggleDragging then
            updateToggle(input)
        end
    end)

    return {
        Gui = gui,
        Frame = frame,
        TitleLabel = titleLabel,
        CloseButton = closeBtn,
        MinimizeButton = minimizeBtn,
        ToggleButton = toggleBtn,
    }
end

return CreateMainUI
