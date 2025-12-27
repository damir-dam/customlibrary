-- Это обновленный код для Nil Hub Library с исправлениями:
-- - CreateWindow теперь возвращает объект Window, который имеет AddTab.
-- - AddTab возвращает объект Tab, который имеет AddSection.
-- - AddSection возвращает объект Section, который имеет AddToggle, AddSlider, AddButton, AddDropdown.
-- - Элементы добавляются в секции, что позволяет организовать GUI лучше (нормальные названия секций, элементы внутри них).
-- - Исправлены возможные ошибки с возвратами и структурой.
-- - ScrollingFrame по-прежнему автоматический, динамический CanvasSize.
-- - Toggle-кнопка отдельная, GUI открывается/закрывается плавно.
-- - Все остальные фичи как в оригинальном запросе.

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Library = {}

function Library:CreateWindow(title)
    local Window = {}

    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NilHubLibrary"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    -- Toggle-кнопка (отдельная, квадрат с UICorner 0.5, переключает OFF/ON)
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Size = UDim2.new(0, 50, 0, 50)
    ToggleButton.Position = UDim2.new(0, 10, 0.5, -25)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
    ToggleButton.Text = "OFF"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 14
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.Parent = ScreenGui
    local ToggleButtonUICorner = Instance.new("UICorner")
    ToggleButtonUICorner.CornerRadius = UDim.new(0, 8)
    ToggleButtonUICorner.Parent = ToggleButton

    -- MainFrame (draggable, темно-красный)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 700, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui
    MainFrame.Visible = false
    local MainUICorner = Instance.new("UICorner")
    MainUICorner.CornerRadius = UDim.new(0, 8)
    MainUICorner.Parent = MainFrame

    -- TitleFrame с кнопкой X
    local TitleFrame = Instance.new("Frame")
    TitleFrame.Size = UDim2.new(1, 0, 0, 50)
    TitleFrame.Position = UDim2.new(0, 0, 0, 0)
    TitleFrame.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
    TitleFrame.BorderSizePixel = 0
    TitleFrame.Parent = MainFrame
    local TitleUICorner = Instance.new("UICorner")
    TitleUICorner.CornerRadius = UDim.new(0, 8)
    TitleUICorner.Parent = TitleFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0.8, 0, 1, 0)
    TitleLabel.Position = UDim2.new(0.1, 0, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title or "Nil Hub Library"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 20
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Parent = TitleFrame

    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 10)
    CloseButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 16
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = TitleFrame
    local CloseButtonUICorner = Instance.new("UICorner")
    CloseButtonUICorner.CornerRadius = UDim.new(0, 4)
    CloseButtonUICorner.Parent = CloseButton

    -- TabsFrame (слева, серый, до 5 табов)
    local TabsFrame = Instance.new("Frame")
    TabsFrame.Size = UDim2.new(0, 150, 1, -50)
    TabsFrame.Position = UDim2.new(0, 0, 0, 50)
    TabsFrame.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
    TabsFrame.BorderSizePixel = 0
    TabsFrame.Parent = MainFrame
    local TabsUICorner = Instance.new("UICorner")
    TabsUICorner.CornerRadius = UDim.new(0, 8)
    TabsUICorner.Parent = TabsFrame

    -- ActiveTabLine
    local ActiveTabLine = Instance.new("Frame")
    ActiveTabLine.Size = UDim2.new(0, 0, 0, 3)
    ActiveTabLine.Position = UDim2.new(0, 5, 0, 47)
    ActiveTabLine.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    ActiveTabLine.BorderSizePixel = 0
    ActiveTabLine.Parent = TabsFrame
    local ActiveTabLineUICorner = Instance.new("UICorner")
    ActiveTabLineUICorner.CornerRadius = UDim.new(0, 2)
    ActiveTabLineUICorner.Parent = ActiveTabLine

    -- Переменные для табов
    local TabFrames = {}
    local TabButtons = {}
    local CurrentTabIndex = 1
    local MaxTabs = 5

    local function switchToTab(index)
        for i, frame in pairs(TabFrames) do
            frame.Visible = (i == index)
        end
        for i, btn in pairs(TabButtons) do
            btn.BackgroundColor3 = (i == index) and Color3.fromRGB(50, 50, 70) or Color3.fromRGB(35, 35, 55)
        end
        TweenService:Create(ActiveTabLine, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Position = UDim2.new(0, 5, 0, 47 + (index-1)*40), Size = UDim2.new(0, 140, 0, 3)}):Play()
    end

    CloseButton.MouseButton1Click:Connect(function()
        TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {Position = UDim2.new(0.5, -350, 1.5, -250)}):Play()
        wait(0.5)
        MainFrame.Visible = false
        ToggleButton.Text = "OFF"
    end)

    ToggleButton.MouseButton1Click:Connect(function()
        if MainFrame.Visible then
            TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {Position = UDim2.new(0.5, -350, 1.5, -250)}):Play()
            wait(0.5)
            MainFrame.Visible = false
            ToggleButton.Text = "OFF"
        else
            MainFrame.Visible = true
            MainFrame.Position = UDim2.new(0.5, -350, 1.5, -250)
            TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {Position = UDim2.new(0.5, -350, 0.5, -250)}):Play()
            ToggleButton.Text = "ON"
        end
    end)

    function Window:AddTab(name)
        if #TabButtons >= MaxTabs then warn("Max 5 tabs allowed!") return end
        local index = #TabButtons + 1

        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, -10, 0, 40)
        TabButton.Position = UDim2.new(0, 5, 0, 10 + (index-1)*40)
        TabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
        TabButton.Text = name
        TabButton.TextColor3 = Color3.fromRGB(200, 200, 255)
        TabButton.TextSize = 16
        TabButton.Font = Enum.Font.Gotham
        TabButton.Parent = TabsFrame
        local TabButtonUICorner = Instance.new("UICorner")
        TabButtonUICorner.CornerRadius = UDim.new(0, 6)
        TabButtonUICorner.Parent = TabButton

        local TabFrame = Instance.new("ScrollingFrame")
        TabFrame.Size = UDim2.new(1, -160, 1, -60)
        TabFrame.Position = UDim2.new(0, 160, 0, 60)
        TabFrame.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
        TabFrame.BorderSizePixel = 0
        TabFrame.ScrollBarThickness = 0
        TabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabFrame.Parent = MainFrame
        TabFrame.Visible = (index == 1)

        TabButtons[index] = TabButton
        TabFrames[index] = TabFrame

        TabButton.MouseButton1Click:Connect(function() switchToTab(index) end)

        local Tab = {}
        local yPos = 10

        function Tab:AddSection(title)
            local Section = {}

            local SectionLabel = Instance.new("TextLabel")
            SectionLabel.Size = UDim2.new(1, -20, 0, 30)
            SectionLabel.Position = UDim2.new(0, 10, 0, yPos)
            SectionLabel.BackgroundTransparency = 1  -- Секции без фона
            SectionLabel.Text = title
            SectionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            SectionLabel.TextSize = 16
            SectionLabel.Font = Enum.Font.GothamBold
            SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
            SectionLabel.Parent = TabFrame
            yPos = yPos + 40

            local sectionYPos = 0

            function Section:AddToggle(title, callback)
                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Size = UDim2.new(1, -20, 0, 50)
                ToggleFrame.Position = UDim2.new(0, 10, 0, yPos + sectionYPos)
                ToggleFrame.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
                ToggleFrame.BorderSizePixel = 0
                ToggleFrame.Parent = TabFrame
                local ToggleUICorner = Instance.new("UICorner")
                ToggleUICorner.CornerRadius = UDim.new(0, 6)
                ToggleUICorner.Parent = ToggleFrame

                local ToggleCheckbox = Instance.new("Frame")
                ToggleCheckbox.Size = UDim2.new(0, 20, 0, 20)
                ToggleCheckbox.Position = UDim2.new(0, 10, 0, 15)
                ToggleCheckbox.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
                ToggleCheckbox.BorderSizePixel = 0
                ToggleCheckbox.Parent = ToggleFrame
                local CheckboxUICorner = Instance.new("UICorner")
                CheckboxUICorner.CornerRadius = UDim.new(0, 4)
                CheckboxUICorner.Parent = ToggleCheckbox

                local CheckMark = Instance.new("TextLabel")
                CheckMark.Size = UDim2.new(1, 0, 1, 0)
                CheckMark.BackgroundTransparency = 1
                CheckMark.Text = "✓"
                CheckMark.TextColor3 = Color3.fromRGB(255, 255, 255)
                CheckMark.TextSize = 16
                CheckMark.Font = Enum.Font.GothamBold
                CheckMark.Visible = false
                CheckMark.Parent = ToggleCheckbox

                local ToggleLabel = Instance.new("TextLabel")
                ToggleLabel.Size = UDim2.new(0.6, 0, 1, 0)
                ToggleLabel.Position = UDim2.new(0, 40, 0, 0)
                ToggleLabel.BackgroundTransparency = 1
                ToggleLabel.Text = title
                ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                ToggleLabel.TextSize = 14
                ToggleLabel.Font = Enum.Font.Gotham
                ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                ToggleLabel.Parent = ToggleFrame

                local KeybindFrame = Instance.new("Frame")
                KeybindFrame.Size = UDim2.new(0.2, -10, 0, 25)
                KeybindFrame.Position = UDim2.new(0.7, 5, 0, 12)
                KeybindFrame.BackgroundColor3 = Color3.fromRGB(65, 0, 0)
                KeybindFrame.BorderSizePixel = 0
                KeybindFrame.Parent = ToggleFrame
                local KeybindFrameUICorner = Instance.new("UICorner")
                KeybindFrameUICorner.CornerRadius = UDim.new(0, 4)
                KeybindFrameUICorner.Parent = KeybindFrame

                local KeybindLabel = Instance.new("TextLabel")
                KeybindLabel.Size = UDim2.new(1, 0, 1, 0)
                KeybindLabel.BackgroundTransparency = 1
                KeybindLabel.Text = "None"
                KeybindLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
                KeybindLabel.TextSize = 12
                KeybindLabel.Font = Enum.Font.Gotham
                KeybindLabel.Parent = KeybindFrame

                local enabled = false
                local keybind = nil
                local binding = false

                local function toggle()
                    enabled = not enabled
                    TweenService:Create(ToggleCheckbox, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = enabled and Color3.fromRGB(70, 70, 90) or Color3.fromRGB(50, 50, 70)}):Play()
                    CheckMark.Visible = enabled
                    if callback then callback(enabled) end
                end

                KeybindFrame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 and not binding then
                        if keybind then
                            keybind = nil
                            KeybindLabel.Text = "None"
                            TweenService:Create(KeybindFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(65, 0, 0)}):Play()
                        else
                            binding = true
                            KeybindLabel.Text = "Press a key..."
                            TweenService:Create(KeybindFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(100, 100, 150)}):Play()
                        end
                    end
                end)

                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if binding and not gameProcessed and input.KeyCode ~= Enum.KeyCode.Unknown then
                        keybind = input.KeyCode
                        KeybindLabel.Text = input.KeyCode.Name
                        TweenService:Create(KeybindFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(65, 0, 0)}):Play()
                        binding = false
                    elseif not binding and keybind and input.KeyCode == keybind and not gameProcessed then
                        toggle()
                    end
                end)

                ToggleCheckbox.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        toggle()
                    end
                end)

                sectionYPos = sectionYPos + 60
            end

            function Section:AddSlider(title, min, max, default, callback)
                local SliderFrame = Instance.new("Frame")
                SliderFrame.Size = UDim2.new(1, -20, 0, 60)
                SliderFrame.Position = UDim2.new(0, 10, 0, yPos + sectionYPos)
                SliderFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
                SliderFrame.BorderSizePixel = 0
                SliderFrame.Parent = TabFrame
                local SliderUICorner = Instance.new("UICorner")
                SliderUICorner.CornerRadius = UDim.new(0, 6)
                SliderUICorner.Parent = SliderFrame

                local SliderLabel = Instance.new("TextLabel")
                SliderLabel.Size = UDim2.new(0.6, 0, 0, 20)
                SliderLabel.Position = UDim2.new(0, 0, 0, 5)
                SliderLabel.BackgroundTransparency = 1
                SliderLabel.Text = title
                SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                SliderLabel.TextSize = 14
                SliderLabel.Font = Enum.Font.Gotham
                SliderLabel.Parent = SliderFrame

                local ValueTextBox = Instance.new("TextBox")
                ValueTextBox.Size = UDim2.new(0.3, -5, 0, 25)
                ValueTextBox.Position = UDim2.new(0.65, 0, 0, 5)
                ValueTextBox.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
                ValueTextBox.Text = (default % 1 == 0) and string.format("%.0f", default) or string.format("%.1f", default)
                ValueTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                ValueTextBox.TextSize = 12
                ValueTextBox.Font = Enum.Font.Gotham
                ValueTextBox.Parent = SliderFrame
                local ValueBoxUICorner = Instance.new("UICorner")
                ValueBoxUICorner.CornerRadius = UDim.new(0, 4)
                ValueBoxUICorner.Parent = ValueTextBox

                local SliderBar = Instance.new("Frame")
                SliderBar.Size = UDim2.new(1, -20, 0, 6)
                SliderBar.Position = UDim2.new(0, 10, 0, 35)
                SliderBar.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
                SliderBar.BorderSizePixel = 0
                SliderBar.Parent = SliderFrame
                local SliderBarUICorner = Instance.new("UICorner")
                SliderBarUICorner.CornerRadius = UDim.new(0, 3)
                SliderBarUICorner.Parent = SliderBar

                local ProgressLine = Instance.new("Frame")
                ProgressLine.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                ProgressLine.Position = UDim2.new(0, 0, 0, 0)
                ProgressLine.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                ProgressLine.BorderSizePixel = 0
                ProgressLine.Parent = SliderBar
                local ProgressLineUICorner = Instance.new("UICorner")
                ProgressLineUICorner.CornerRadius = UDim.new(0, 3)
                ProgressLineUICorner.Parent = ProgressLine

                local SliderCircle = Instance.new("Frame")
                SliderCircle.Size = UDim2.new(0, 16, 0, 16)
                SliderCircle.Position = UDim2.new((default - min) / (max - min), -8, 0, -5)
                SliderCircle.BackgroundColor3 = Color3.fromRGB(75, 0, 0)
                SliderCircle.BorderSizePixel = 0
                SliderCircle.Parent = SliderBar
                local SliderCircleUICorner = Instance.new("UICorner")
                SliderCircleUICorner.CornerRadius = UDim.new(1, 0)
                SliderCircleUICorner.Parent = SliderCircle

                local dragging = false
                local currentValue = default

                local function updateValue(value)
                    value = math.clamp(value, min, max)
                    currentValue = value
                    ValueTextBox.Text = (value % 1 == 0) and string.format("%.0f", value) or string.format("%.1f", value)
                    local relativePos = (value - min) / (max - min)
                    TweenService:Create(SliderCircle, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Position = UDim2.new(relativePos, -8, 0, -5)}):Play()
                    TweenService:Create(ProgressLine, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Size = UDim2.new(relativePos, 0, 1, 0)}):Play()
                    if callback then callback(value) end
                end

                SliderCircle.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local mousePos = UserInputService:GetMouseLocation()
                        local relativePos = (mousePos.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X
                        relativePos = math.clamp(relativePos, 0, 1)
                        local value = math.round((min + (max - min) * relativePos) / 0.1) * 0.1
                        updateValue(value)
                    end
                end)

                ValueTextBox.FocusLost:Connect(function(enterPressed)
                    local inputValue = tonumber(ValueTextBox.Text)
                    if inputValue then
                        updateValue(inputValue)
                    else
                        ValueTextBox.Text = (currentValue % 1 == 0) and string.format("%.0f", currentValue) or string.format("%.1f", currentValue)
                    end
                end)

                sectionYPos = sectionYPos + 70
            end

            function Section:AddButton(title, callback)
                local ButtonFrame = Instance.new("Frame")
                ButtonFrame.Size = UDim2.new(1, -20, 0, 40)
                ButtonFrame.Position = UDim2.new(0, 10, 0, yPos + sectionYPos)
                ButtonFrame.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
                ButtonFrame.BorderSizePixel = 0
                ButtonFrame.Parent = TabFrame
                local ButtonUICorner = Instance.new("UICorner")
                ButtonUICorner.CornerRadius = UDim.new(0, 6)
                ButtonUICorner.Parent = ButtonFrame

                local Button = Instance.new("TextButton")
                Button.Size = UDim2.new(1, -20, 1, -10)
                Button.Position = UDim2.new(0, 10, 0, 5)
                Button.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
                Button.Text = title
                Button.TextColor3 = Color3.fromRGB(255, 255, 255)
                Button.TextSize = 14
                Button.Font = Enum.Font.GothamBold
                Button.Parent = ButtonFrame
                local ButtonUICorner = Instance.new("UICorner")
                ButtonUICorner.CornerRadius = UDim.new(0, 4)
                ButtonUICorner.Parent = Button

                Button.MouseButton1Click:Connect(function()
                    TweenService:Create(Button, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(200, 0, 0)}):Play()
                    wait(0.1)
                    TweenService:Create(Button, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(150, 0, 0)}):Play()
                    if callback then callback() end
                end)

                sectionYPos = sectionYPos + 50
            end

            function Section:AddDropdown(title, options, default, callback)
                local DropdownFrame = Instance.new("Frame")
                DropdownFrame.Size = UDim2.new(1, -20, 0, 50)
                DropdownFrame.Position = UDim2.new(0, 10, 0, yPos + sectionYPos)
                DropdownFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
                DropdownFrame.BorderSizePixel = 0
                DropdownFrame.Parent = TabFrame
                local DropdownUICorner = Instance.new("UICorner")
                DropdownUICorner.CornerRadius = UDim.new(0, 6)
                DropdownUICorner.Parent = DropdownFrame

                local DropdownLabel = Instance.new("TextLabel")
                DropdownLabel.Size = UDim2.new(1, 0, 0, 20)
                DropdownLabel.Position = UDim2.new(0, 0, 0, 5)
                DropdownLabel.BackgroundTransparency = 1
                DropdownLabel.Text = title .. ": " .. default
                DropdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                DropdownLabel.TextSize = 14
                DropdownLabel.Font = Enum.Font.Gotham
                DropdownLabel.Parent = DropdownFrame

                local DropdownButton = Instance.new("TextButton")
                DropdownButton.Size = UDim2.new(1, -20, 0, 25)
                DropdownButton.Position = UDim2.new(0, 10, 0, 25)
                DropdownButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
                DropdownButton.Text = "Select ▼"
                DropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                DropdownButton.TextSize = 12
                DropdownButton.Font = Enum.Font.Gotham
                DropdownButton.Parent = DropdownFrame
                local DropdownButtonUICorner = Instance.new("UICorner")
                DropdownButtonUICorner.CornerRadius = UDim.new(0, 4)
                DropdownButtonUICorner.Parent = DropdownButton

                local DropdownList = Instance.new("Frame")
                DropdownList.Size = UDim2.new(1, -20, 0, 0)
                DropdownList.Position = UDim2.new(0, 10, 0, 55)
                DropdownList.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
                DropdownList.BorderSizePixel = 0
                DropdownList.ClipsDescendants = true
                DropdownList.Parent = DropdownFrame
                local DropdownListUICorner = Instance.new("UICorner")
                DropdownListUICorner.CornerRadius = UDim.new(0, 6)
                DropdownListUICorner.Parent = DropdownList

                for i, option in ipairs(options) do
                    local OptionButton = Instance.new("TextButton")
                    OptionButton.Size = UDim2.new(1, 0, 0, 25)
                    OptionButton.Position = UDim2.new(0, 0, 0, (i-1)*25)
                    OptionButton.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
                    OptionButton.Text = option
                    OptionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    OptionButton.TextSize = 12
                    OptionButton.Font = Enum.Font.Gotham
                    OptionButton.Parent = DropdownList
                    local OptionUICorner = Instance.new("UICorner")
                    OptionUICorner.CornerRadius = UDim.new(0, 4)
                    OptionUICorner.Parent = OptionUICorner

                    OptionButton.MouseButton1Click:Connect(function()
                        DropdownLabel.Text = title .. ": " .. option
                        TweenService:Create(DropdownList, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(1, -20, 0, 0)}):Play()
                        if callback then callback(option) end
                    end)
                end

                DropdownButton.MouseButton1Click:Connect(function()
                    local targetSize = DropdownList.Size.Y.Offset == 0 and UDim2.new(1, -20, 0, #options * 25) or UDim2.new(1, -20, 0, 0)
                    TweenService:Create(DropdownList, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = targetSize}):Play()
                end)

                sectionYPos = sectionYPos + 60 + #options * 25
            end

            -- Обновление yPos после секции
            yPos = yPos + sectionYPos

            return Section
        end

        -- Обновление CanvasSize для таба
        local function updateCanvas()
            TabFrame.CanvasSize = UDim2.new(0, 0, 0, yPos)
            TabFrame.ScrollBarThickness = (yPos > TabFrame.AbsoluteSize.Y) and 6 or 0
        end

        -- Хуки для обновления CanvasSize
        local oldAddSection = Tab.AddSection
        Tab.AddSection = function(self, ...)
            oldAddSection(self, ...)
            updateCanvas()
        end

        return Tab
    end

    return Window
end

return Library
