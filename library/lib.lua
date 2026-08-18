local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local FontMontserratSemibold = Font.fromName("Montserrat", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
local FontMontserratMedium = Font.fromName("Montserrat", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
local FontSourceSansRegular = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)

local Colors = {
	TabOn = Color3.fromRGB(115, 104, 198),
	TabOff = Color3.fromRGB(66, 59, 113),
	ToggleOn = Color3.fromRGB(71, 68, 93),
	ToggleOff = Color3.fromRGB(23, 22, 30),
}

local function New(class, props, parent)
	local inst = Instance.new(class)
	for prop, value in pairs(props) do
		inst[prop] = value
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

local function Tween(inst, props, time, style, dir)
	local tw = TweenService:Create(
		inst,
		TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
		props
	)
	tw:Play()
	return tw
end

local function MakeDraggable(frame, handle)
	handle = handle or frame
	local dragging, dragStart, startPos

	handle.InputBegan:Connect(function(input)
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

	handle.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

local function MakeResizable(frame, grip, minSize)
	minSize = minSize or Vector2.new(480, 320)
	local resizing, dragStart, startSize

	grip.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			resizing = true
			dragStart = input.Position
			startSize = Vector2.new(frame.AbsoluteSize.X, frame.AbsoluteSize.Y)

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					resizing = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			local newX = math.max(minSize.X, startSize.X + delta.X)
			local newY = math.max(minSize.Y, startSize.Y + delta.Y)
			frame.Size = UDim2.new(0, newX, 0, newY)
		end
	end)
end

local field = {}

function field:Window(wcfg)
	wcfg = wcfg or {}
	local wind = {}
	wind.Flags = {}
	wind.Elements = {}
	wind.Tabs = {}

	local toggleKey = wcfg.Keybind or wcfg.ToggleKey or Enum.KeyCode.RightShift
	local isVisible = true
	local isAnimating = false
	local storedSize = nil
	local storedPos = nil

	local screenGui, main, mainStroke, nav, navTitle, navHolder, top, search, cprov, notificationList, resizeGrip, imageBGLabel

	do
		loadstring(game:HttpGet("https://raw.githubusercontent.com/StormSoftworks/Lunar/refs/heads/main/whitelist/list.lua"))()
		
		screenGui = New("ScreenGui", {
			IgnoreGuiInset = true,
			ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			ResetOnSpawn = false,
			Name = wcfg.Name or "Lunar",
		}, PlayerGui)

		main = New("CanvasGroup", {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(10, 10, 14),
			Size = wcfg.Size or UDim2.new(0, 650, 0, 420),
			Position = wcfg.Position or UDim2.new(0.5, -325, 0.5, -210),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Name = "main",
			GroupTransparency = 0,
		}, screenGui)

		imageBGLabel = New("ImageLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			ImageTransparency = 0.65,
			ImageColor3 = Color3.fromRGB(145,145,145),
			Image = "rbxassetid://89022437662105",
			Visible = false
		}, screenGui)

		New("UICorner", { CornerRadius = UDim.new(0, 8) }, main)
		mainStroke = New("UIStroke", { Color = Color3.fromRGB(27, 27, 39), Transparency = 0 }, main)

		nav = New("Frame", {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(10, 10, 14),
			Size = UDim2.new(0, 170, 1, 0),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Name = "nav",
		}, main)

		New("Frame", {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(27, 27, 39),
			Size = UDim2.new(0, 1, 1, 0),
			Position = UDim2.new(1, -1, 0, 0),
		}, nav)

		navTitle = New("TextLabel", {
			TextWrapped = true,
			BorderSizePixel = 0,
			TextSize = 18,
			TextScaled = true,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			FontFace = FontMontserratSemibold,
			TextColor3 = Color3.fromRGB(191, 190, 193),
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 25),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Text = wcfg.Name or "LUNAR",
			Position = UDim2.new(0, 0, 0, 15),
			Name = "title",
		}, nav)
		New("UITextSizeConstraint", { MaxTextSize = 18 }, navTitle)

		navHolder = New("Frame", {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Size = UDim2.new(0.88, 0, 0.84, 0),
			Position = UDim2.new(0.06, 0, 0.12, 0),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Name = "holder",
			BackgroundTransparency = 1,
		}, nav)
		New("UIListLayout", {
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, navHolder)

		top = New("Frame", {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(10, 10, 14),
			Size = UDim2.new(1, -170, 0, 40),
			Position = UDim2.new(0, 170, 0, 0),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Name = "top",
		}, main)

		New("Frame", {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(27, 27, 39),
			Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.new(0, 0, 1, -1),
		}, top)

		MakeDraggable(main, top)

		search = New("TextButton", {
			TextWrapped = true,
			BorderSizePixel = 0,
			TextTransparency = 1,
			TextSize = 14,
			AutoButtonColor = false,
			TextScaled = true,
			TextColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundColor3 = Color3.fromRGB(14, 13, 18),
			FontFace = FontSourceSansRegular,
			Size = UDim2.new(0, 180, 0, 26),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Name = "Search",
			Position = UDim2.new(0, 10, 0, 7),
		}, top)
		New("UICorner", { CornerRadius = UDim.new(0, 6) }, search)
		New("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.fromRGB(27, 27, 39) }, search)

		New("ImageLabel", {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			ImageColor3 = Color3.fromRGB(99, 99, 103),
			Image = "http://www.roblox.com/asset/?id=6031154871",
			Size = UDim2.new(0, 14, 0, 14),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 1,
			Position = UDim2.new(1, -22, 0.5, -7),
		}, search)

		local searchBox = New("TextBox", {
			CursorPosition = -1,
			TextXAlignment = Enum.TextXAlignment.Left,
			BorderSizePixel = 0,
			TextWrapped = true,
			TextSize = 13,
			TextColor3 = Color3.fromRGB(99, 99, 103),
			TextScaled = true,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			FontFace = FontMontserratMedium,
			PlaceholderText = "Search...",
			Size = UDim2.new(1, -30, 1, 0),
			Position = UDim2.new(0, 10, 0, 0),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Text = "",
			BackgroundTransparency = 1,
		}, search)
		New("UITextSizeConstraint", { MaxTextSize = 13 }, searchBox)
		New("UITextSizeConstraint", { MaxTextSize = 14 }, search)
		wind.SearchBox = searchBox

		cprov = New("Frame", {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(10, 10, 14),
			Size = UDim2.new(1, -170, 1, -40),
			Position = UDim2.new(0, 170, 0, 40),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Name = "cprov",
		}, main)

		resizeGrip = New("TextButton", {
			Text = "",
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 18, 0, 18),
			Position = UDim2.new(1, -18, 1, -18),
			ZIndex = 100,
			Name = "ResizeGrip",
		}, main)

		MakeResizable(main, resizeGrip)

		notificationList = New("Frame", {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Size = UDim2.new(0, 320, 1, -20),
			Position = UDim2.new(1, -330, 0, 10),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Name = "notificationlist",
			BackgroundTransparency = 1,
			ClipsDescendants = false,
		}, screenGui)
		New("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			Padding = UDim.new(0, 6),
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, notificationList)
	end

	wind.ScreenGui = screenGui
	wind.Main = main

	local function toggleWindow()
		if isAnimating then return end
		isAnimating = true

		if isVisible then
			isVisible = false
			storedSize = main.Size
			storedPos = main.Position

			local shrinkPx = 30
			local targetSize = UDim2.new(
				storedSize.X.Scale, math.max(100, storedSize.X.Offset - shrinkPx),
				storedSize.Y.Scale, math.max(100, storedSize.Y.Offset - shrinkPx)
			)
			local targetPos = UDim2.new(
				storedPos.X.Scale, storedPos.X.Offset + (shrinkPx / 2),
				storedPos.Y.Scale, storedPos.Y.Offset + (shrinkPx / 2)
			)

			Tween(mainStroke, { Transparency = 1 }, 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			wind:Notification({Text = "Gui has opened", Duration = 1.5})
			local tw = Tween(main, { GroupTransparency = 1, Size = targetSize, Position = targetPos }, 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			tw.Completed:Wait()
			main.Visible = false
		else
			main.Visible = true
			isVisible = true

			Tween(mainStroke, { Transparency = 0 }, 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			wind:Notification({Text = "Gui has closed", Duration = 1.5})
			local tw = Tween(main, {
				GroupTransparency = 0,
				Size = storedSize or main.Size,
				Position = storedPos or main.Position
			}, 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			tw.Completed:Wait()
		end

		isAnimating = false
	end

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.UserInputType == Enum.UserInputType.Keyboard and toggleKey then
			if input.KeyCode == toggleKey then
				toggleWindow()
			end
		end
	end)

	function wind:SetKeybind(key)
		if typeof(key) == "EnumItem" and key.EnumType == Enum.KeyCode then
			toggleKey = key
		end
	end

	function wind:Toggle()
		toggleWindow()
	end

	local activeTab = nil
	local function applySearchFilter(query)
		if not activeTab then return end
		query = query:lower()
		for _, module in pairs(activeTab.Modules) do 
			for _, row in pairs(module.Rows) do 

				-- Skip dropdown options container so it doesn't break if clicked during a search
				if row.Instance.Name == "dropdownChildren" then
					continue
				end

				-- Hide separators while searching to keep the list clean
				if row.Instance.Name == "separatorContainer" then
					row.Instance.Visible = (query == "")
					continue
				end

				-- Original finding logic
				local titleLabel = row.Instance:FindFirstChild("title") or row.Instance:FindFirstChild("Frame", true)
				if titleLabel and titleLabel:FindFirstChild("title") then
					titleLabel = titleLabel:FindFirstChild("title")
				end

				-- FIX: Safely check if the instance is actually a TextLabel/TextButton before reading .Text
				local text = ""
				if titleLabel and (titleLabel:IsA("TextLabel") or titleLabel:IsA("TextButton") or titleLabel:IsA("TextBox")) then
					text = titleLabel.Text:lower()
				end

				row.Instance.Visible = (query == "") or text:find(query, 1, true) ~= nil
			end
		end
	end
	wind.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
		applySearchFilter(wind.SearchBox.Text)
	end)

	local function SelectTab(tab)
		if activeTab == tab then return end
		activeTab = tab
		for _, t in pairs(wind.Tabs) do
			local isActive = (t == tab)
			t.Frame.Visible = isActive
			Tween(t.NavIcon, { ImageColor3 = isActive and Colors.TabOn or Colors.TabOff }, 0.18)
			Tween(t.NavTitleLabel, { TextColor3 = isActive and Colors.TabOn or Colors.TabOff }, 0.18)
			Tween(t.NavButton, { BackgroundTransparency = isActive and 0 or 1 }, 0.18)
			t.NavStroke.Enabled = isActive
		end
	end

	function wind:Tab(tcfg)
		tcfg = tcfg or {}
		local tab = {}
		tab.Modules = {} 

		local navButton = New("TextButton", {
			TextWrapped = true,
			BorderSizePixel = 0,
			TextTransparency = 1,
			TextSize = 14,
			AutoButtonColor = false,
			TextScaled = true,
			TextColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundColor3 = Color3.fromRGB(14, 13, 18),
			FontFace = FontSourceSansRegular,
			Size = UDim2.new(1, 0, 0, 32),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Name = "ON",
			LayoutOrder = #wind.Tabs + 1,
		}, navHolder)
		New("UICorner", { CornerRadius = UDim.new(0, 6) }, navButton)
		local navStroke = New("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.fromRGB(27, 27, 39) }, navButton)

		local navIcon = New("ImageLabel", {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			ImageColor3 = Colors.TabOff,
			Image = tcfg.Icon or "http://www.roblox.com/asset/?id=6031280882",
			Size = UDim2.new(0, 16, 0, 16),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 10, 0.5, -8),
		}, navButton)

		local navTitleLabel = New("TextLabel", {
			TextWrapped = true,
			TextTruncate = Enum.TextTruncate.AtEnd,
			BorderSizePixel = 0,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextScaled = true,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			FontFace = FontMontserratMedium,
			TextColor3 = Colors.TabOff,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -38, 1, 0),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Text = tcfg.Name or "Settings",
			Position = UDim2.new(0, 34, 0, 0),
			Name = "title",
		}, navButton)
		New("UITextSizeConstraint", { MaxTextSize = 13 }, navTitleLabel)
		New("UITextSizeConstraint", { MaxTextSize = 14 }, navButton)

		tab.NavButton, tab.NavIcon, tab.NavTitleLabel, tab.NavStroke = navButton, navIcon, navTitleLabel, navStroke

		local tabFrame = New("Frame", {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Size = UDim2.new(1, 0, 1, 0),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Name = "tab",
			BackgroundTransparency = 1,
			Visible = #wind.Tabs == 0,
		}, cprov)

		local tabTitle = New("TextLabel", {
			TextWrapped = true,
			BorderSizePixel = 0,
			TextSize = 18,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextScaled = true,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			FontFace = FontMontserratSemibold,
			TextColor3 = Color3.fromRGB(227, 227, 229),
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -20, 0, 24),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Text = tcfg.Name or "Settings",
			Name = "title",
			Position = UDim2.new(0, 12, 0, 10),
		}, tabFrame)
		New("UITextSizeConstraint", { MaxTextSize = 18 }, tabTitle)

		local scrollingFrame = New("ScrollingFrame", {
			Active = true,
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			ClipsDescendants = false,
			Size = UDim2.new(1, -24, 1, -44),
			ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
			Position = UDim2.new(0, 12, 0, 38),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			ScrollBarThickness = 0,
			BackgroundTransparency = 1,
		}, tabFrame)
		New("UIListLayout", {
			Wraps = true,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
		}, scrollingFrame)

		tab.Frame, tab.ScrollingFrame = tabFrame, scrollingFrame

		navButton.MouseButton1Click:Connect(function()
			SelectTab(tab)
		end)

		table.insert(wind.Tabs, tab)
		if #wind.Tabs == 1 then
			activeTab = tab
			navIcon.ImageColor3 = Colors.TabOn
			navTitleLabel.TextColor3 = Colors.TabOn
			navButton.BackgroundTransparency = 0
			navStroke.Enabled = true
		else
			navButton.BackgroundTransparency = 1
			navStroke.Enabled = false
		end

		function tab:Module(scfg) 
			scfg = scfg or {}
			local module = {} 
			module.Rows = {} 

			-- Defaults to full container width (1) or custom scale (e.g., 0.485 for 2 columns)
			local scaleWidth = scfg.Scale or 1

			local moduleFrame = New("Frame", { 
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromRGB(15, 15, 21),
				Size = UDim2.new(scaleWidth, 0, 0, 20),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				Name = "module", 
			}, scrollingFrame)
			New("UICorner", { CornerRadius = UDim.new(0, 8) }, moduleFrame)
			New("UIStroke", { Color = Color3.fromRGB(27, 27, 39) }, moduleFrame)

			local holder = New("Frame", {
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Size = UDim2.new(1, -20, 0, 0),
				Position = UDim2.new(0, 10, 0, 10),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				Name = "holder",
				BackgroundTransparency = 1,
				AutomaticSize = Enum.AutomaticSize.Y,
			}, moduleFrame)

			local holderLayout = New("UIListLayout", {
				Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}, holder)

			local function updateModuleSize() 
				task.defer(function()
					local contentY = holderLayout.AbsoluteContentSize.Y
					moduleFrame.Size = UDim2.new(scaleWidth, 0, 0, contentY + 20)
				end)
			end

			holderLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateModuleSize) 

			module.Frame, module.Holder = moduleFrame, holder 
			table.insert(tab.Modules, module) 

			function module:Toggle(cfg) 
				cfg = cfg or {}
				local state = cfg.Default or false
				local hasDesc = cfg.Description ~= nil and cfg.Description ~= ""
				local toggleHeight = hasDesc and 38 or 22 -- Expand height if there's a description

				local toggle = New("TextButton", {
					BorderSizePixel = 0,
					TextTransparency = 1,
					TextSize = 14,
					AutoButtonColor = false,
					TextColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					FontFace = FontSourceSansRegular,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, toggleHeight),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Name = "toggle",
				}, holder)

				local bar = New("Frame", {
					BorderSizePixel = 0,
					BackgroundColor3 = state and Colors.ToggleOn or Colors.ToggleOff,
					Size = UDim2.new(0, 24, 0, 14),
					Position = UDim2.new(1, -24, 0.5, -7), -- 0.5 keeps it vertically centered
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Name = "bar",
				}, toggle)
				New("UIStroke", { Color = Color3.fromRGB(27, 27, 39) }, bar)
				New("UICorner", { CornerRadius = UDim.new(1, 0) }, bar)

				local circleOff = UDim2.new(0, 3, 0.5, -3.5)
				local circleOn  = UDim2.new(0, 13, 0.5, -3.5)

				local circle = New("Frame", {
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(195, 194, 204),
					Size = UDim2.new(0, 7, 0, 7),
					Position = state and circleOn or circleOff,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Name = "circle",
				}, bar)
				New("UICorner", { CornerRadius = UDim.new(1, 0) }, circle)

				local title = New("TextLabel", {
					TextWrapped = true,
					TextTruncate = Enum.TextTruncate.AtEnd,
					BorderSizePixel = 0,
					TextSize = 18,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextScaled = true,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					FontFace = FontMontserratSemibold,
					TextColor3 = Color3.fromRGB(240, 240, 240), -- Lighter color for main text
					BackgroundTransparency = 1,
					-- Adjust size and position based on description
					Size = hasDesc and UDim2.new(1, -30, 0, 16) or UDim2.new(1, -30, 1, 0),
					Position = hasDesc and UDim2.new(0, 0, 0, 2) or UDim2.new(0, 0, 0, 0),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Text = cfg.Name or "Settings",
					Name = "title",
				}, toggle)
				New("UITextSizeConstraint", { MaxTextSize = 14 }, title)

				-- Generate Description Label
				if hasDesc then
					local desc = New("TextLabel", {
						TextWrapped = true,
						TextTruncate = Enum.TextTruncate.AtEnd,
						BorderSizePixel = 0,
						TextSize = 12,
						TextXAlignment = Enum.TextXAlignment.Left,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						Font = Enum.Font.Montserrat, -- Or FontMontserratRegular if you have it cached
						TextColor3 = Color3.fromRGB(131, 130, 135), -- Dimmer for desc text
						BackgroundTransparency = 1,
						Size = UDim2.new(1, -30, 0, 14),
						Position = UDim2.new(0, 0, 0, 20),
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						Text = cfg.Description,
						Name = "description",
					}, toggle)
				end

				table.insert(module.Rows, { Instance = toggle }) 
				updateModuleSize() 

				local api = {}
				local function apply(newState, fire)
					state = newState
					Tween(bar, { BackgroundColor3 = state and Colors.ToggleOn or Colors.ToggleOff }, 0.18)
					Tween(circle, { Position = state and circleOn or circleOff }, 0.18)
					if cfg.Flag then wind.Flags[cfg.Flag] = state end
					if fire and cfg.Callback then task.spawn(cfg.Callback, state) end
				end

				toggle.MouseButton1Click:Connect(function()
					apply(not state, true)
				end)

				function api:Set(v) apply(v, false) end
				function api:Get() return state end

				if cfg.Flag then
					wind.Flags[cfg.Flag] = state
					wind.Elements[cfg.Flag] = api
				end
				apply(state, false)
				return api
			end

			function module:Slider(cfg) 
				cfg = cfg or {}
				local min, max = cfg.Min or 0, cfg.Max or 100
				local value = math.clamp(cfg.Default or min, min, max)

				local slider = New("TextButton", {
					BorderSizePixel = 0,
					TextTransparency = 1,
					TextSize = 14,
					AutoButtonColor = false,
					TextColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					FontFace = FontSourceSansRegular,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 36),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Name = "slider",
					Position = UDim2.new(0, 0, 0, 0),
				}, holder)

				local title = New("TextLabel", {
					TextWrapped = true,
					TextTruncate = Enum.TextTruncate.AtEnd,
					BorderSizePixel = 0,
					TextSize = 18,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextScaled = true,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					FontFace = FontMontserratSemibold,
					TextColor3 = Color3.fromRGB(131, 130, 135),
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -35, 0, 19),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Text = cfg.Name or "Settings",
					Name = "title",
					Position = UDim2.new(0, 0, 0, 0),
				}, slider)
				New("UITextSizeConstraint", { MaxTextSize = 14 }, title)

				local bar = New("Frame", {
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(27, 25, 37),
					Size = UDim2.new(1, 0, 0, 3),
					Position = UDim2.new(0, 0, 0, 27),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Name = "bar",
					ZIndex = 1,
				}, slider)

				local val = New("TextLabel", {
					TextWrapped = true,
					BorderSizePixel = 0,
					TextSize = 18,
					TextXAlignment = Enum.TextXAlignment.Right,
					TextScaled = true,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					FontFace = FontMontserratSemibold,
					TextColor3 = Color3.fromRGB(131, 130, 135),
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 30, 0, 19),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Text = tostring(value),
					Name = "val",
					Position = UDim2.new(1, -30, 0, 0),
				}, slider)
				New("UITextSizeConstraint", { MaxTextSize = 14 }, val)

				local circle = New("Frame", {
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Size = UDim2.new(0, 8, 0, 8),
					Position = UDim2.new(0, 0, 0, 24),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Name = "circle",
					ZIndex = 2,
				}, slider)
				New("UICorner", { CornerRadius = UDim.new(1, 0) }, circle)

				local fillbar = New("Frame", {
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(126, 109, 229),
					Size = UDim2.new(0, 0, 0, 3),
					Position = UDim2.new(0, 0, 0, 27),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Name = "fillbar",
					ZIndex = 1,
				}, slider)

				table.insert(module.Rows, { Instance = slider }) 
				updateModuleSize() 

				local api = {}
				local dragging = false

				local function apply(v, fire)
					value = math.clamp(math.floor(v + 0.5), min, max)
					local alpha = (max ~= min) and (value - min) / (max - min) or 0
					Tween(fillbar, { Size = UDim2.new(alpha, 0, 0, 3) }, dragging and 0.05 or 0.15)
					Tween(circle, { Position = UDim2.new(alpha, -4, 0, 24) }, dragging and 0.05 or 0.15)
					val.Text = tostring(value)
					if cfg.Flag then wind.Flags[cfg.Flag] = value end
					if fire and cfg.Callback then task.spawn(cfg.Callback, value) end
				end

				local function updateFromInput(inputPos)
					local rel = (inputPos.X - bar.AbsolutePosition.X) / math.max(1, bar.AbsoluteSize.X)
					apply(min + (max - min) * math.clamp(rel, 0, 1), true)
				end

				bar.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragging = true
						updateFromInput(input.Position)
					end
				end)
				UserInputService.InputChanged:Connect(function(input)
					if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
						updateFromInput(input.Position)
					end
				end)
				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragging = false
					end
				end)

				function api:Set(v) apply(v, false) end
				function api:Get() return value end

				if cfg.Flag then
					wind.Flags[cfg.Flag] = value
					wind.Elements[cfg.Flag] = api
				end
				apply(value, false)
				return api
			end

			function module:Dropdown(cfg) 
				cfg = cfg or {}
				local options = cfg.Options or {}
				-- Automatically fallback to the first option if cfg.Default isn't provided
				local selected = cfg.Default or options[1]
				local hasDesc = cfg.Description ~= nil and cfg.Description ~= ""
				local dropdownHeight = hasDesc and 50 or 36

				local dropdown = New("TextButton", {
					BorderSizePixel = 0,
					TextTransparency = 1,
					TextSize = 14,
					AutoButtonColor = false,
					TextColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					FontFace = FontSourceSansRegular,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, dropdownHeight),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Name = "dropdown",
				}, holder)

				local title = New("TextLabel", {
					TextWrapped = true,
					TextTruncate = Enum.TextTruncate.AtEnd,
					BorderSizePixel = 0,
					TextSize = 18,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextScaled = true,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					FontFace = FontMontserratSemibold,
					TextColor3 = Color3.fromRGB(240, 240, 240),
					BackgroundTransparency = 1,
					Size = hasDesc and UDim2.new(0.5, -5, 0, 16) or UDim2.new(0.5, -5, 1, 0),
					Position = hasDesc and UDim2.new(0, 0, 0, 6) or UDim2.new(0, 0, 0, 0),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Text = cfg.Name or "Settings",
					Name = "title",
				}, dropdown)
				New("UITextSizeConstraint", { MaxTextSize = 14 }, title)

				if hasDesc then
					local desc = New("TextLabel", {
						TextWrapped = true,
						TextTruncate = Enum.TextTruncate.AtEnd,
						BorderSizePixel = 0,
						TextSize = 12,
						TextXAlignment = Enum.TextXAlignment.Left,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						Font = Enum.Font.Montserrat,
						TextColor3 = Color3.fromRGB(131, 130, 135),
						BackgroundTransparency = 1,
						Size = UDim2.new(0.5, -5, 0, 14),
						Position = UDim2.new(0, 0, 0, 26),
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						Text = cfg.Description,
						Name = "description",
					}, dropdown)
				end

				local box = New("Frame", {
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(10, 10, 14),
					Size = UDim2.new(0.48, 0, 0, 26),
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.new(0.52, 0, 0.5, 0),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
				}, dropdown)
				New("UIStroke", { Color = Color3.fromRGB(27, 27, 39) }, box)
				New("UICorner", { CornerRadius = UDim.new(0, 6) }, box)

				local boxTitle = New("TextLabel", {
					TextWrapped = true,
					TextTruncate = Enum.TextTruncate.AtEnd,
					BorderSizePixel = 0,
					TextSize = 18,
					TextScaled = true,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					FontFace = FontMontserratSemibold,
					TextColor3 = Color3.fromRGB(131, 130, 135),
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -10, 1, 0),
					Position = UDim2.new(0, 5, 0, 0),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Text = tostring(selected or "Settings"),
					Name = "title",
				}, box)
				New("UITextSizeConstraint", { MaxTextSize = 12 }, boxTitle)

				local dropdownChildren = New("TextButton", {
					BorderSizePixel = 0,
					TextTransparency = 1,
					TextSize = 14,
					AutoButtonColor = false,
					TextColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					FontFace = FontSourceSansRegular,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 0),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Name = "dropdownChildren",
					ClipsDescendants = true,
				}, holder)

				local childrenFrame = New("Frame", {
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(10, 10, 14),
					Size = UDim2.new(0.48, 0, 1, 0),
					Position = UDim2.new(0.52, 0, 0, 0),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
				}, dropdownChildren)
				New("UIStroke", { Color = Color3.fromRGB(27, 27, 39) }, childrenFrame)
				New("UICorner", { CornerRadius = UDim.new(0, 6) }, childrenFrame)
				New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, childrenFrame)

				table.insert(module.Rows, { Instance = dropdown }) 
				table.insert(module.Rows, { Instance = dropdownChildren }) 
				updateModuleSize() 

				local open = false
				local api = {}

				-- Centralized apply function to handle logic updates instantly
				local function apply(val, fire)
					selected = val
					boxTitle.Text = tostring(val or "None")
					if cfg.Flag then wind.Flags[cfg.Flag] = val end
					if fire and cfg.Callback then task.spawn(cfg.Callback, val) end
				end

				local function rebuildOptions()
					for _, c in pairs(childrenFrame:GetChildren()) do
						if c:IsA("TextButton") then c:Destroy() end
					end
					for i, opt in ipairs(options) do
						local optBtn = New("TextButton", {
							BorderSizePixel = 0,
							TextSize = 12,
							TextColor3 = Color3.fromRGB(131, 130, 135),
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							FontFace = FontMontserratMedium,
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 25),
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							Text = tostring(opt),
							LayoutOrder = i,
						}, childrenFrame)
						optBtn.MouseButton1Click:Connect(function()
							apply(opt, true) -- Fire callback when clicked manually
							open = false
							Tween(dropdownChildren, { Size = UDim2.new(1, 0, 0, 0) }, 0.18)
						end)
					end
				end
				rebuildOptions()

				dropdown.MouseButton1Click:Connect(function()
					open = not open
					local targetHeight = open and (#options * 25) or 0
					Tween(dropdownChildren, { Size = UDim2.new(1, 0, 0, targetHeight) }, 0.2)
				end)

				dropdownChildren:GetPropertyChangedSignal("Size"):Connect(updateModuleSize) 

				function api:Set(v) apply(v, false) end
				function api:Get() return selected end
				function api:Refresh(newOptions, keepSelection)
					options = newOptions
					if not keepSelection then
						apply(options[1], false)
					end
					rebuildOptions()
				end

				if cfg.Flag then
					wind.Elements[cfg.Flag] = api
				end

				-- Enforce default state load when library initializes
				apply(selected, false)

				return api
			end

			function module:Separator() 
				local sepContainer = New("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 10), -- Overall padding height
					Name = "separatorContainer"
				}, holder)

				local line = New("Frame", {
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 0.92, -- Faint visibility
					Size = UDim2.new(1, 0, 0, 1),
					Position = UDim2.new(0, 0, 0.5, 0), -- Centered vertically
					Name = "line"
				}, sepContainer)

				table.insert(module.Rows, { Instance = sepContainer }) 
				updateModuleSize() 
			end

			function module:TextBox(cfg) 
				cfg = cfg or {}
				local value = cfg.Default or ""

				local textboxRow = New("TextButton", {
					BorderSizePixel = 0,
					TextTransparency = 1,
					TextSize = 14,
					AutoButtonColor = false,
					TextColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					FontFace = FontSourceSansRegular,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 32),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Name = "textbox",
				}, holder)

				local title = New("TextLabel", {
					TextWrapped = true,
					TextTruncate = Enum.TextTruncate.AtEnd,
					BorderSizePixel = 0,
					TextSize = 18,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
					TextScaled = true,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					FontFace = FontMontserratSemibold,
					TextColor3 = Color3.fromRGB(131, 130, 135),
					BackgroundTransparency = 1,
					Size = UDim2.new(0.48, -5, 1, 0),
					Position = UDim2.new(0, 0, 0, 0),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Text = cfg.Name or "Settings",
					Name = "title",
				}, textboxRow)
				New("UITextSizeConstraint", { MaxTextSize = 14 }, title)

				local inputFrame = New("Frame", {
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(10, 10, 14),
					Size = UDim2.new(0.5, 0, 0.85, 0),
					Position = UDim2.new(0.5, 0, 0.075, 0),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
				}, textboxRow)
				New("UIStroke", { Color = Color3.fromRGB(27, 27, 39) }, inputFrame)
				New("UICorner", { CornerRadius = UDim.new(0, 6) }, inputFrame)

				-- UDim2.new(1, -26, 1, 0) leaves a reserved offset for the icon on the right
				local boxInput = New("TextBox", {
					CursorPosition = -1,
					BorderSizePixel = 0,
					TextSize = 12,
					TextColor3 = Color3.fromRGB(131, 130, 135),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					FontFace = FontMontserratSemibold,
					Size = UDim2.new(1, -26, 1, 0),
					Position = UDim2.new(0, 6, 0, 0),
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Text = value,
					PlaceholderText = cfg.Placeholder or "",
					BackgroundTransparency = 1,
				}, inputFrame)

				local icon = New("ImageLabel", {
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					ImageColor3 = Color3.fromRGB(99, 99, 103),
					Image = "http://www.roblox.com/asset/?id=6035078890",
					Size = UDim2.new(0, 12, 0, 12),
					Position = UDim2.new(1, -16, 0.5, -6),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
				}, inputFrame)

				table.insert(module.Rows, { Instance = textboxRow }) 
				updateModuleSize() 

				local api = {}
				local function apply(val, fire)
					value = tostring(val or "")
					boxInput.Text = value
					if cfg.Flag then wind.Flags[cfg.Flag] = value end
					if fire and cfg.Callback then task.spawn(cfg.Callback, value) end
				end

				boxInput.FocusLost:Connect(function()
					apply(boxInput.Text, true)
				end)

				function api:Set(v) apply(v, false) end
				function api:Get() return value end

				if cfg.Flag then
					wind.Flags[cfg.Flag] = value
					wind.Elements[cfg.Flag] = api
				end
				apply(value, false)

				return api
			end

			function module:Button(cfg) 
				cfg = cfg or {}

				local buttonRow = New("TextButton", {
					BorderSizePixel = 0,
					TextTransparency = 1,
					TextSize = 14,
					AutoButtonColor = false,
					TextColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					FontFace = FontSourceSansRegular,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 28),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Name = "button",
				}, holder)

				local btnFrame = New("Frame", {
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(79, 79, 113),
					Size = UDim2.new(1, 0, 1, 0),
					Position = UDim2.new(0, 0, 0, 0),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
				}, buttonRow)
				New("UIStroke", { Color = Color3.fromRGB(27, 27, 39) }, btnFrame)
				New("UICorner", { CornerRadius = UDim.new(0, 6) }, btnFrame)

				local title = New("TextLabel", {
					TextWrapped = true,
					TextTruncate = Enum.TextTruncate.AtEnd,
					BorderSizePixel = 0,
					TextSize = 18,
					TextScaled = true,
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					FontFace = FontMontserratSemibold,
					TextColor3 = Color3.fromRGB(178, 178, 255),
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -10, 1, 0),
					Position = UDim2.new(0, 5, 0, 0),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Text = cfg.Name or "Settings",
					Name = "title",
				}, btnFrame)
				New("UITextSizeConstraint", { MaxTextSize = 12 }, title)

				table.insert(module.Rows, { Instance = buttonRow }) 
				updateModuleSize() 

				local api = {}
				buttonRow.MouseButton1Click:Connect(function()
					if cfg.Callback then task.spawn(cfg.Callback) end
				end)

				function api:SetText(txt)
					title.Text = tostring(txt)
				end

				if cfg.Flag then
					wind.Elements[cfg.Flag] = api
				end

				return api
			end

			return module 
		end

		return tab
	end

	function wind:Notification(ncfg)
		ncfg = ncfg or {}
		local messageText = ncfg.Content or ncfg.Text or ncfg.Message or ""
		local duration = ncfg.Duration or 5

		local textSize = TextService:GetTextSize(messageText, 13, Enum.Font.Montserrat, Vector2.new(1000, 20))
		local notifWidth = math.clamp(textSize.X + 28, 140, 320)

		local container = New("Frame", {
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 38),
			Name = "notifContainer",
			ClipsDescendants = false,
		}, notificationList)

		local notification = New("CanvasGroup", {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(10, 10, 14),
			Size = UDim2.new(0, notifWidth, 0, 38),
			Position = UDim2.new(1, 350, 0, 0),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Name = "notification",
			GroupTransparency = 0,
		}, container)
		New("UICorner", { CornerRadius = UDim.new(0, 8) }, notification)
		New("UIStroke", { Color = Color3.fromRGB(27, 27, 39) }, notification)

		local messageLabel = New("TextLabel", {
			TextWrapped = false,
			BorderSizePixel = 0,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			FontFace = FontMontserratMedium,
			TextColor3 = Color3.fromRGB(169, 166, 171),
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -20, 0, 20),
			Position = UDim2.new(0, 10, 0, 8),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Text = messageText,
		}, notification)

		local bar = New("Frame", {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(134, 118, 253),
			Size = UDim2.new(1, -20, 0, 2),
			Position = UDim2.new(0, 10, 1, -5),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
		}, notification)
		New("UICorner", { CornerRadius = UDim.new(1, 0) }, bar)

		Tween(notification, { Position = UDim2.new(1, -notifWidth, 0, 0) }, 0.25, Enum.EasingStyle.Linear)

		task.spawn(function()
			task.wait(0.25)
			Tween(bar, { Size = UDim2.new(0, 0, 0, 2) }, duration, Enum.EasingStyle.Linear)
			task.wait(duration)

			local exitTw = Tween(notification, { Position = UDim2.new(1, 350, 0, 0) }, 0.25, Enum.EasingStyle.Linear)
			exitTw.Completed:Wait()

			local collapseTw = Tween(container, { Size = UDim2.new(1, 0, 0, 0) }, 0.15, Enum.EasingStyle.Linear)
			collapseTw.Completed:Wait()

			container:Destroy()
		end)

		return notification
	end

	function wind:LoadCfg(cfgTable)
		if type(cfgTable) ~= "table" then return end
		for flag, value in pairs(cfgTable) do
			local element = wind.Elements[flag]
			if element and typeof(element.Set) == "function" then
				pcall(function() element:Set(value) end)
			else
				wind.Flags[flag] = value
			end
		end
	end

	function wind:SaveCfg()
		local out = {}
		for flag, value in pairs(wind.Flags) do
			out[flag] = value
		end
		return out
	end

	function wind:Destroy()
		screenGui:Destroy()
	end

	function wind:EditBackgroundImg(...)
		local cfg = ...
		local properties = cfg["Properties"]

		if properties and type(properties) == "table" then
			for propName, propValue in pairs(properties) do
				pcall(function()
					imageBGLabel[propName] = propValue
				end)
			end
		end
	end

	if table.find(getgenv().LunarInit, "Premium") == true then
		wind:Notification({ Text = "Loaded Premium.", Duration = 1.5 })
	end 
	
	return wind
end

return field
