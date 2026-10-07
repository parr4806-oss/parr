-- OCEANA GUI + DARK ADMIN / TESTING UTILITY
-- Place in: StarterPlayer > StarterPlayerScripts
-- RIGHT SHIFT: Show / Hide dashboard
--============================================================
-- Script 12 functionality is integrated into this OCEANA GUI build.
-- The 1-Tap system remains intentionally removed.
--============================================================

Players = game:GetService("Players")
ReplicatedStorage = game:GetService("ReplicatedStorage")

--============================================================
-- MAX MAP RENDER / STREAMING DISTANCE
--============================================================
pcall(function()
	workspace.StreamingTargetRadius = 1000000
end)
pcall(function()
	workspace.StreamingMinRadius = 1000000
end)
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
CollectionService = game:GetService("CollectionService")
ProximityPromptService = game:GetService("ProximityPromptService")
TweenService = game:GetService("TweenService")

LocalPlayer = Players.LocalPlayer
PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--============================================================
-- GUI STARTUP WATCHDOG
--============================================================
task.spawn(function()
	task.wait(3)
	if PlayerGui:FindFirstChild("OCEANA Script") then
		return
	end

	local recovery = Instance.new("ScreenGui")
	recovery.Name = "OCEANA Startup Recovery"
	recovery.ResetOnSpawn = false
	recovery.IgnoreGuiInset = true
	recovery.DisplayOrder = 9999
	recovery.Parent = PlayerGui

	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromOffset(420, 190)
	frame.Position = UDim2.new(0.5, -210, 0.5, -95)
	frame.BackgroundColor3 = Color3.fromRGB(7, 10, 18)
	frame.Parent = frame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 16)
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(70, 150, 255)
	stroke.Thickness = 2
	stroke.Parent = frame

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(1, -30, 0, 35)
	title.Position = UDim2.fromOffset(15, 18)
	title.Text = "OCEANA STARTUP ERROR"
	title.TextColor3 = Color3.fromRGB(245, 247, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 18
	title.Parent = frame

	local info = Instance.new("TextLabel")
	info.BackgroundTransparency = 1
	info.Size = UDim2.new(1, -30, 0, 70)
	info.Position = UDim2.fromOffset(15, 58)
	info.Text = "The main interface failed before it could initialize.\nCheck the Roblox Developer Console (F9) for the OCEANA error."
	info.TextColor3 = Color3.fromRGB(160, 170, 190)
	info.Font = Enum.Font.Gotham
	info.TextSize = 12
	info.TextWrapped = true
	info.Parent = frame

	local close = Instance.new("TextButton")
	close.Size = UDim2.fromOffset(130, 34)
	close.Position = UDim2.new(0.5, -65, 1, -48)
	close.BackgroundColor3 = Color3.fromRGB(70, 150, 255)
	close.Text = "CLOSE"
	close.TextColor3 = Color3.new(1,1,1)
	close.Font = Enum.Font.GothamBold
	close.TextSize = 12
	close.Parent = frame

	local cc = Instance.new("UICorner")
	cc.CornerRadius = UDim.new(0, 9)
	cc.Parent = close
	close.MouseButton1Click:Connect(function() recovery:Destroy() end)
end)

--============================================================
-- CONFIG
--============================================================
Config = {
	DEFAULT_WALK_SPEED = 16,
	WALK_SPEED = 32,
	WALK_SPEED_ENABLED = true,
	JUMP_POWER = 50,
	FLY_SPEED = 70,
	GRAB_RANGE = 30,
	AIM_STRENGTH = 100,
	AIM_FOV = 60,
	AIM_MIN = 10,
	AIM_MAX = 200,
	FOV_MIN = 10,
	FOV_MAX = 120,
	TEAM_CHECK = false,
	VISIBILITY_CHECK = true,
	INSTANT_PICKUP = false,
	AUTO_FARM = false,
	AUTO_FARM_DELAY = 1,
	DELIVERY_SPEED = 75,
	DELIVERY_TIMEOUT = 60,
}

--============================================================
-- STATE
--============================================================
Character = nil
Humanoid = nil
RootPart = nil

Flying = false
Noclip = false
AutoGrab = false
SkeletonESPEnabled = false
NormalESPEnabled = false
DistanceESPEnabled = false
HealthESPEnabled = false
AimAssist = false
AimHolding = false
InfiniteJumpEnabled = false

CurrentTarget = nil
AimTarget = nil
SilentAimEnabled = false
SharedWhitelist = {}

function isWhitelistedTarget(player)
	if not player then
		return false
	end
	local userId = player.UserId
	local username = string.lower(player.Name or "")
	local displayName = string.lower(player.DisplayName or "")
	return SharedWhitelist[userId] == true or SharedWhitelist[username] == true or SharedWhitelist[displayName] == true
end

FlyBV = nil
FlyBG = nil
MenuVisible = true
Minimized = false
ESPObjects = {}
CurrentBike = nil
UsedBikes = {}
AutoFarmRunning = false
SOURCE_A_POSITION = Vector3.new(0, 0, 0)
DELIVERY_ZONE_POSITION = nil

--============================================================
-- GUI REFERENCES
--============================================================
GUI = nil
MainFrame = nil
MainContent = nil
Sidebar = nil
StatusText = nil
BikeText = nil
AutoFarmButton = nil
Pages = {}
sidebarButtons = {}

--============================================================
-- CARSON COLORS
--============================================================
BG = Color3.fromRGB(4, 6, 11)
PANEL = Color3.fromRGB(8, 12, 21)
PANEL2 = Color3.fromRGB(13, 19, 32)
PANEL3 = Color3.fromRGB(21, 32, 52)
WHITE = Color3.fromRGB(245, 247, 255)
MUTED = Color3.fromRGB(145, 151, 170)
BLUE = Color3.fromRGB(70, 150, 255)
BLUE2 = Color3.fromRGB(130, 195, 255)
GREEN = Color3.fromRGB(75, 230, 135)
RED = Color3.fromRGB(255, 75, 95)
BORDER = Color3.fromRGB(46, 67, 98)

--============================================================
-- CHARACTER
--============================================================
function applyWalkSpeed()
	if not Humanoid or not Humanoid.Parent then
		return
	end
	if Config.WALK_SPEED_ENABLED then
		Humanoid.WalkSpeed = Config.WALK_SPEED
	else
		Humanoid.WalkSpeed = Config.DEFAULT_WALK_SPEED
	end
end

function applyJumpPower()
	if not Humanoid or not Humanoid.Parent then
		return
	end
	Humanoid.UseJumpPower = true
	Humanoid.JumpPower = Config.JUMP_POWER
end

function setupCharacter(character)
	Character = character
	Humanoid = character:WaitForChild("Humanoid", 10)
	RootPart = character:WaitForChild("HumanoidRootPart", 10)
	Flying = false
	if Humanoid and Config.WALK_SPEED_ENABLED then
		Humanoid.WalkSpeed = Config.WALK_SPEED
	end
end

if LocalPlayer.Character then
	task.spawn(function()
		setupCharacter(LocalPlayer.Character)
	end)
end

LocalPlayer.CharacterAdded:Connect(function(character)
	if FlyBV then
		FlyBV:Destroy()
		FlyBV = nil
	end
	if FlyBG then
		FlyBG:Destroy()
		FlyBG = nil
	end
	task.wait(0.5)
	setupCharacter(character)
end)

--============================================================
-- INFINITE JUMP
--============================================================
UserInputService.JumpRequest:Connect(function()
	if not InfiniteJumpEnabled then
		return
	end
	if Humanoid and Humanoid.Parent then
		Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

--============================================================
-- PERSISTENT WALK SPEED
--============================================================
RunService.Heartbeat:Connect(function()
	if not Config.WALK_SPEED_ENABLED then
		return
	end
	if not Humanoid or not Humanoid.Parent then
		return
	end
	if Humanoid.WalkSpeed ~= Config.WALK_SPEED then
		Humanoid.WalkSpeed = Config.WALK_SPEED
	end
end)

--============================================================
-- GUI HELPERS
--============================================================
function create(className, properties, parent)
	local object = Instance.new(className)
	for property, value in pairs(properties or {}) do
		object[property] = value
	end
	object.Parent = parent
	return object
end

function corner(object, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 8)
	c.Parent = object
	return c
end

function stroke(object, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color or BORDER
	s.Thickness = thickness or 1
	s.Transparency = transparency or 0.35
	s.Parent = object
	return s
end

function label(parent, text, size, position, fontSize)
	return create("TextLabel", {
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = WHITE,
		TextSize = fontSize or 14,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		Size = size,
		Position = position,
	}, parent)
end

function makeDraggable(frame, handle)
	local dragging = false
	local dragStart
	local startPosition

	handle.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end
		dragging = true
		dragStart = input.Position
		startPosition = frame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement then
			return
		end
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end)
end

function button(parent, text, position, size)
	local b = create("TextButton", {
		BackgroundColor3 = PANEL2,
		BackgroundTransparency = 0.06,
		Text = text,
		TextColor3 = WHITE,
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
		AutoButtonColor = false,
		Size = size,
		Position = position,
	}, parent)

	corner(b, 9)
	stroke(b, BORDER, 1, 0.3)

	local accent = create("Frame", {
		BackgroundColor3 = BLUE,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(3, 18),
		Position = UDim2.fromOffset(0, 11),
	}, b)

	corner(accent, 3)

	b.MouseEnter:Connect(function()
  TweenService:Create(b, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {BackgroundColor3 = PANEL3, TextColor3 = BLUE2}):Play()
TweenService:Create(accent, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
end)
b.MouseLeave:Connect(function()
TweenService:Create(b, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {BackgroundColor3 = PANEL2, TextColor3 = WHITE}):Play()
TweenService:Create(accent, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
end)
return b
end
--============================================================
-- SCREEN GUI
--============================================================
oldGui = PlayerGui:FindFirstChild("OCEANA Script")
if oldGui then
oldGui:Destroy()
end
GUI = create("ScreenGui", {
Name = "OCEANA Script",
ResetOnSpawn = false,
IgnoreGuiInset = true,
ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
DisplayOrder = 50,
}, PlayerGui)
GUI.Enabled = true
--============================================================
-- MAIN WINDOW (FORCE ENABLED BY DEFAULT)
--============================================================
MainFrame = create("Frame", {
Name = "MainFrame",
BackgroundColor3 = BG,
Size = UDim2.fromOffset(940, 620),
Position = UDim2.new(0.5, -470, 0.5, -310),
Visible = true, -- Changed to straight access without keys
ZIndex = 10,
}, GUI)
corner(MainFrame, 18)
stroke(MainFrame, BLUE, 1, 0.25)
MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new({
ColorSequenceKeypoint.new(0, Color3.fromRGB(7, 13, 24)),
ColorSequenceKeypoint.new(0.55, Color3.fromRGB(5, 8, 15)),
ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 17, 30)),
})
MainGradient.Rotation = 25
MainGradient.Parent = MainFrame
MainGlow = create("Frame", {
Name = "AmbientGlow",
BackgroundColor3 = BLUE,
BackgroundTransparency = 0.94,
Size = UDim2.new(1, -30, 0, 5),
Position = UDim2.fromOffset(15, 65),
ZIndex = 13,
}, MainFrame)
corner(MainGlow, 4)
task.spawn(function()
while GUI and GUI.Parent do
local a = TweenService:Create(MainGlow, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.82})
a:Play()
a.Completed:Wait()
if not (GUI and GUI.Parent) then break end
local b = TweenService:Create(MainGlow, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.96})
b:Play()
b.Completed:Wait()
end
end)
if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
local MobileScale = Instance.new("UIScale")
MobileScale.Name = "MobileGUIScale"
MobileScale.Scale = 0.56
MobileScale.Parent = MainFrame
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.fromScale(0.5, 0.5)
end
--============================================================
-- GUI RESIZE HANDLE
--============================================================
local ResizeHandle = Instance.new("TextButton")
ResizeHandle.Name = "ResizeHandle"
ResizeHandle.Text = ""
ResizeHandle.AutoButtonColor = false
ResizeHandle.BackgroundTransparency = 1
ResizeHandle.Size = UDim2.fromOffset(22, 22)
ResizeHandle.AnchorPoint = Vector2.new(1, 1)
ResizeHandle.Position = UDim2.fromScale(1, 1)
ResizeHandle.ZIndex = 100
ResizeHandle.Parent = MainFrame
local ResizeLine1 = Instance.new("Frame")
ResizeLine1.BorderSizePixel = 0
ResizeLine1.BackgroundColor3 = BLUE
ResizeLine1.BackgroundTransparency = 0.15
ResizeLine1.Size = UDim2.fromOffset(10, 2)
ResizeLine1.AnchorPoint = Vector2.new(1, 1)
ResizeLine1.Position = UDim2.new(1, -2, 1, -5)
ResizeLine1.Rotation = -45
ResizeLine1.ZIndex = 101
ResizeLine1.Parent = ResizeHandle
local ResizeLine2 = ResizeLine1:Clone()
ResizeLine2.Size = UDim2.fromOffset(7, 2)
ResizeLine2.Position = UDim2.new(1, -2, 1, -10)
ResizeLine2.Parent = ResizeHandle
local resizing = false
local resizeStart
local startSize
local MIN_WIDTH, MIN_HEIGHT = 520, 360
ResizeHandle.InputBegan:Connect(function(input)
if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
resizing = true
resizeStart = input.Position
startSize = MainFrame.Size
end)
UserInputService.InputChanged:Connect(function(input)
if not resizing or input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
local delta = input.Position - resizeStart
local newW = math.max(MIN_WIDTH, startSize.X.Offset + delta.X)
local newH = math.max(MIN_HEIGHT, startSize.Y.Offset + delta.Y)
MainFrame.Size = UDim2.fromOffset(newW, newH)
MainFrame.Position = UDim2.new(0.5, -newW / 2, 0.5, -newH / 2)
end)
UserInputService.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
resizing = false
end
end)
--============================================================
-- TOP BAR
--============================================================
TopBar = create("Frame", {
Name = "TopBar",
BackgroundColor3 = PANEL,
Size = UDim2.new(1, 0, 0, 66),
ZIndex = 12,
}, MainFrame)
corner(TopBar, 18)
TopAccent = create("Frame", {
BackgroundColor3 = BLUE,
Size = UDim2.new(1, -28, 0, 3),
Position = UDim2.fromOffset(14, 0),
ZIndex = 15,
}, TopBar)
corner(TopAccent, 3)
Logo = create("Frame", {
BackgroundColor3 = BLUE,
Size = UDim2.fromOffset(38, 38),
Position = UDim2.fromOffset(14, 15),
ZIndex = 15,
}, TopBar)
corner(Logo, 10)
LogoText = label(Logo, "C", UDim2.fromScale(1, 1), UDim2.fromOffset(0, 0), 18)
LogoText.TextXAlignment = Enum.TextXAlignment.Center
LogoText.Font = Enum.Font.GothamBlack
Title = label(TopBar, "OCEANA SCRIPT", UDim2.new(1, -180, 0, 24), UDim2.fromOffset(64, 10), 16)
Title.Font = Enum.Font.GothamBlack
SubTitle = label(TopBar, "OCEANA  •  NEXT-GEN UTILITY", UDim2.new(1, -180, 0, 17), UDim2.fromOffset(65, 34), 9)
SubTitle.TextColor3 = BLUE2
SubTitle.Font = Enum.Font.GothamBold
StatusPill = create("Frame", {
Name = "StatusPill",
BackgroundColor3 = Color3.fromRGB(8, 22, 34),
BackgroundTransparency = 0.05,
Size = UDim2.fromOffset(104, 26),
Position = UDim2.new(1, -188, 0, 18),
ZIndex = 16,
}, TopBar)
corner(StatusPill, 13)
stroke(StatusPill, BLUE, 1, 0.35)
StatusDot = create("Frame", {
Name = "StatusDot",
BackgroundColor3 = Color3.fromRGB(80, 220, 140),
Size = UDim2.fromOffset(7, 7),
Position = UDim2.fromOffset(11, 10),
ZIndex = 17,
}, StatusPill)
corner(StatusDot, 7)
StatusLabel = label(StatusPill, "ONLINE  •  READY", UDim2.new(1, -27, 1, 0), UDim2.fromOffset(24, 0), 8)
StatusLabel.TextColor3 = Color3.fromRGB(150, 220, 255)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextYAlignment = Enum.TextYAlignment.Center
task.spawn(function()
while GUI and GUI.Parent and StatusDot.Parent do
local fade = TweenService:Create(StatusDot, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.65})
fade:Play()
fade.Completed:Wait()
if not (GUI and GUI.Parent and StatusDot.Parent) then break end
local glow = TweenService:Create(StatusDot, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0})
glow:Play()
glow.Completed:Wait()
end
end)
Minimize = create("TextButton", {
BackgroundColor3 = PANEL2,
Text = "—",
TextColor3 = MUTED,
TextSize = 16,
Font = Enum.Font.GothamBold,
AutoButtonColor = false,
Size = UDim2.fromOffset(32, 32),
Position = UDim2.new(1, -77, 0, 17),
ZIndex = 16,
}, TopBar)
corner(Minimize, 9)
stroke(Minimize, BORDER, 1, 0.3)
CloseButton = create("TextButton", {
BackgroundColor3 = PANEL2,
Text = "×",
TextColor3 = RED,
TextSize = 18,
Font = Enum.Font.GothamBold,
AutoButtonColor = false,
Size = UDim2.fromOffset(32, 32),
Position = UDim2.new(1, -39, 0, 17),
ZIndex = 16,
}, TopBar)
corner(CloseButton, 9)
stroke(CloseButton, BORDER, 1, 0.3)
--============================================================
-- SIDEBAR / CONTENT
--============================================================
Sidebar = create("Frame", {
Name = "Sidebar",
BackgroundColor3 = PANEL,
Size = UDim2.fromOffset(208, 552),
Position = UDim2.fromOffset(0, 66),
ZIndex = 12,
}, MainFrame)
corner(Sidebar, 13)
stroke(Sidebar, BORDER, 1, 0.5)
SidebarTitle = label(Sidebar, "NAVIGATION", UDim2.new(1, -28, 0, 25), UDim2.fromOffset(14, 15), 10)
SidebarTitle.TextColor3 = MUTED
SidebarTitle.Font = Enum.Font.GothamBold
SidebarList = create("ScrollingFrame", {
Name = "SidebarList",
BackgroundTransparency = 1,
BorderSizePixel = 0,
Size = UDim2.new(1, -8, 1, -52),
Position = UDim2.fromOffset(4, 48),
CanvasSize = UDim2.new(),
AutomaticCanvasSize = Enum.AutomaticSize.Y,
ScrollBarThickness = 3,
ScrollBarImageColor3 = BLUE,
ScrollBarImageTransparency = 0.2,
ScrollingDirection = Enum.ScrollingDirection.Y,
VerticalScrollBarInset = Enum.ScrollBarInset.None,
ZIndex = 15,
}, Sidebar)
create("UIPadding", {
PaddingLeft = UDim.new(0, 6),
PaddingRight = UDim.new(0, 6),
PaddingBottom = UDim.new(0, 8),
}, SidebarList)
create("UIListLayout", {
Padding = UDim.new(0, 4),
SortOrder = Enum.SortOrder.LayoutOrder,
}, SidebarList)
MainContent = create("Frame", {
Name = "MainContent",
BackgroundTransparency = 1,
Size = UDim2.new(1, -230, 1, -88),
Position = UDim2.fromOffset(222, 78),
ZIndex = 12,
}, MainFrame)
--============================================================
-- PAGES
--============================================================
function addVisualTabBackground(page, variant)
local bg = create("Frame", {
Name = "VisualBackground",
BackgroundColor3 = Color3.fromRGB(3, 10, 24),
BackgroundTransparency = 0.08,
BorderSizePixel = 0,
Size = UDim2.fromScale(1, 1),
Position = UDim2.fromScale(0, 0),
ZIndex = 11,
}, MainContent)
corner(bg, 16)
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
ColorSequenceKeypoint.new(0, Color3.fromRGB(3, 12, 30)),
ColorSequenceKeypoint.new(0.45, Color3.fromRGB(5, 23, 55)),
ColorSequenceKeypoint.new(1, Color3.fromRGB(2, 8, 22)),
})
gradient.Rotation = 18
gradient.Parent = bg
local glow = create("Frame", {
Name = "MovingGlow",
BackgroundColor3 = BLUE,
BackgroundTransparency = 0.90,
BorderSizePixel = 0,
Size = UDim2.fromOffset(280, 280),
Position = UDim2.new(-0.12, 0, 0.08, 0),
ZIndex = 2,
}, bg)
corner(glow, 140)
local glow2 = create("Frame", {
Name = "MovingGlow2",
BackgroundColor3 = BLUE2,
BackgroundTransparency = 0.94,
BorderSizePixel = 0,
Size = UDim2.fromOffset(220, 220),
Position = UDim2.new(0.70, 0, 0.52, 0),
ZIndex = 2,
}, bg)
corner(glow2, 110)
local skyline = create("Frame", {
Name = "Skyline",
BackgroundTransparency = 1,
Size = UDim2.new(1, 0, 0, 105),
Position = UDim2.new(0, 0, 1, -105),
ZIndex = 2,
}, bg)
local heights = {42, 68, 35, 86, 55, 74, 48, 92, 58, 40, 78, 51, 70, 45, 88}
for i, h in ipairs(heights) do
local building = create("Frame", {
BackgroundColor3 = Color3.fromRGB(4, 18, 42),
BackgroundTransparency = 0.08,
BorderSizePixel = 0,
Size = UDim2.new(1 / #heights, -3, 0, h),
Position = UDim2.new((i - 1) / #heights, 1, 1, -h),
ZIndex = 2,
}, skyline)
corner(building, 3)
for w = 1, 2 do
local win = create("Frame", {
BackgroundColor3 = BLUE2,
BackgroundTransparency = 0.45,
BorderSizePixel = 0,
Size = UDim2.fromOffset(3, 3),
Position = UDim2.new(0.25 + (w - 1) * 0.45, 0, 0.25 + ((i * 13 + w * 7) % 45) / 100, 0),
ZIndex = 3,
}, building)
corner(win, 1)
end
end
local moon = create("Frame", {
Name = "Moon",
BackgroundColor3 = Color3.fromRGB(115, 205, 255),
BackgroundTransparency = 0.18,
BorderSizePixel = 0,
Size = UDim2.fromOffset(44, 44),
Position = UDim2.new(0.70, 0, 0.08, 0),
ZIndex = 2,
}, bg)
corner(moon, 22)
stroke(moon, BLUE, 1, 0.45)
local waveHolder = create("Frame", {
Name = "MovingWaves",
BackgroundTransparency = 1,
ClipsDescendants = true,
Size = UDim2.new(1, 0, 0, 90),
Position = UDim2.new(0, 0, 1, -90),
ZIndex = 4,
}, bg)
for i = 1, 7 do
local wave = create("Frame", {
BackgroundColor3 = i % 2 == 0 and BLUE or BLUE2,
BackgroundTransparency = 0.90,
BorderSizePixel = 0,
Size = UDim2.new(1.25, 0, 0, 2),
Position = UDim2.new(-0.12, 0, 0, i * 12),
Rotation = i % 2 == 0 and -2 or 2,
ZIndex = 4,
}, waveHolder)
corner(wave, 2)
local from = wave.Position
local to = UDim2.new(0.04, 0, from.Y.Scale, from.Y.Offset)
task.spawn(function()
while wave.Parent do
local a = TweenService:Create(wave, TweenInfo.new(3.2 + i * 0.22, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = to})
a:Play(); a.Completed:Wait()
if not wave.Parent then break end
local b = TweenService:Create(wave, TweenInfo.new(3.2 + i * 0.22, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = from})
b:Play(); b.Completed:Wait()
end
end)
end
task.spawn(function()
local t = 0
while page.Parent do
t = t + 0.018
glow.Position = UDim2.new(-0.12 + math.sin(t) * 0.16, 0, 0.08 + math.cos(t * 0.7) * 0.08, 0)
glow2.Position = UDim2.new(0.70 + math.cos(t * 0.8) * 0.12, 0, 0.52 + math.sin(t * 0.65) * 0.10, 0)
gradient.Rotation = 18 + math.sin(t * 0.35) * 16
task.wait()
end
end)
return bg
end
function createPage(name)
local page = create("ScrollingFrame", {
Name = name,
BackgroundTransparency = 1,
Size = UDim2.new(1, 0, 1, 0),
CanvasSize = UDim2.new(),
ScrollBarThickness = 3,
ScrollBarImageColor3 = BLUE,
ScrollBarImageTransparency = 0.25,
Visible = false,
AutomaticCanvasSize = Enum.AutomaticSize.Y,
ZIndex = 14,
}, MainContent)
create("UIPadding", {
PaddingRight = UDim.new(0, 8),
PaddingBottom = UDim.new(0, 10),
}, page)
create("UIListLayout", {
Padding = UDim.new(0, 9),
SortOrder = Enum.SortOrder.LayoutOrder,
}, page)
Pages[name] = page
return page
end
function pageTitle(page, text)
local title = label(page, text, UDim2.new(1, -10, 0, 38), UDim2.fromOffset(0, 0), 21)
title.Font = Enum.Font.GothamBlack
title.ZIndex = 16
title.LayoutOrder = 1
return title
end
--============================================================
-- TOGGLE KEYBINDS
--============================================================
local ToggleKeybinds = {}
local ToggleKeybindEntries = {}
local ToggleKeybindDefaults = {}
local ToggleKeybindIndex = 0
local KeybindCapture = nil
local registerToggleKeybind
function pageButton(page, text, callback)
local b = button(page, text, UDim2.fromOffset(0, 0), UDim2.new(1, -10, 0, 42))
b.ZIndex = 16
b.LayoutOrder = #page:GetChildren() + 1
local toggleName, toggleState = string.match(text, "^(.-):%s*(%a+)$")
if toggleName and (toggleState == "ON" or toggleState == "OFF") then
b.TextTransparency = 1
local toggleLabel = label(b, toggleName, UDim2.new(1, -70, 1, 0), UDim2.fromOffset(14, 0), 13)
toggleLabel.Visible = true
toggleLabel.Font = Enum.Font.GothamMedium
toggleLabel.ZIndex = 3
local track = create("Frame", {
Name = "ToggleTrack",
BackgroundColor3 = BORDER,
BorderSizePixel = 0,
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -12, 0.5, 0),
Size = UDim2.fromOffset(36, 20),
ZIndex = 3,
}, b)
corner(track, 10)
local knob = create("Frame", {
Name = "ToggleKnob",
BackgroundColor3 = WHITE,
BorderSizePixel = 0,
AnchorPoint = Vector2.new(0.5, 0.5),
Size = UDim2.fromOffset(14, 14),
ZIndex = 4,
}, track)
corner(knob, 7)
local function refreshToggle()
local state = string.match(b.Text, ":%s*(%a+)$")
local enabled = state == "ON"
toggleLabel.Text = toggleName
track.BackgroundColor3 = enabled and BLUE or BORDER
knob.Position = enabled and UDim2.new(1, -9, 0.5, 0) or UDim2.new(0, 9, 0.5, 0)
end
b:GetPropertyChangedSignal("Text"):Connect(refreshToggle)
refreshToggle()
ToggleKeybindIndex += 1
local keybindEntry = registerToggleKeybind(b, toggleName, ToggleKeybindDefaults[ToggleKeybindIndex] or Enum.KeyCode.Unknown)
if keybindEntry then
keybindEntry.Callback = callback
end
end
if callback then
b.MouseButton1Click:Connect(callback)
end
return b
end
function pageSlider(page, titleText, minValue, maxValue, initialValue, callback)
local row = create("Frame", {
Name = titleText:gsub("%W", "") .. "Slider",
BackgroundColor3 = PANEL2,
Size = UDim2.new(1, -10, 0, 64),
LayoutOrder = #page:GetChildren() + 1,
}, page)
corner(row, 9)
stroke(row, BORDER, 1, 0.3)
local valueLabel = label(row, titleText .. ": " .. tostring(initialValue), UDim2.new(1, -20, 0, 23), UDim2.fromOffset(10, 5), 12)
valueLabel.Font = Enum.Font.GothamMedium
local track = create("TextButton", {
Name = "Track", Text = "", AutoButtonColor = false,
BackgroundColor3 = BORDER, BorderSizePixel = 0,
Position = UDim2.new(0, 12, 0, 39), Size = UDim2.new(1, -24, 0, 8),
}, row)
corner(track, 5)
local fill = create("Frame", {BackgroundColor3 = BLUE, BorderSizePixel = 0, Size = UDim2.new(0, 0, 1, 0)}, track)
corner(fill, 5)
local knob = create("Frame", {BackgroundColor3 = WHITE, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.fromOffset(16, 16), ZIndex = 3}, track)
corner(knob, 8)
local value = math.clamp(initialValue, minValue, maxValue)
local dragging = false
local function setFromX(x)
local width = math.max(track.AbsoluteSize.X, 1)
local alpha = math.clamp((x - track.AbsolutePosition.X) / width, 0, 1)
value = math.floor(minValue + (maxValue - minValue) * alpha + 0.5)
fill.Size = UDim2.new(alpha, 0, 1, 0)
knob.Position = UDim2.new(alpha, 0, 0.5, 0)
valueLabel.Text = titleText .. ": " .. tostring(value)
callback(value)
end
local function begin(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
dragging = true
setFromX(input.Position.X)
end
end
track.InputBegan:Connect(begin)
knob.InputBegan:Connect(begin)
UserInputService.InputChanged:Connect(function(input)
if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then setFromX(input.Position.X) end
end)
UserInputService.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)
local alpha = (value - minValue) / (maxValue - minValue)
fill.Size = UDim2.new(alpha, 0, 1, 0)
knob.Position = UDim2.new(alpha, 0, 0.5, 0)
return row
end
InfoPage = createPage("Information")
PlayerPage = createPage("Player")
TeleportPage = createPage("Teleport")
CombatPage = createPage("Combat")
VisualPage = createPage("Visuals")
CarsPage = createPage("Cars")
PlayersPage = createPage("Players")
AutoFarmPage = createPage("Auto Farm")
NittyAutoFarmPage = createPage("Nitty AUTO FARM")
ChatPage = createPage("Chat")
NameChangerPage = createPage("Name Changer")
SettingsPage = createPage("Settings")
addVisualTabBackground(MainContent)
pageTitle(InfoPage, "Information")
pageTitle(PlayerPage, "Player")
pageTitle(TeleportPage, "Teleport")
pageTitle(CombatPage, "Combat")
pageTitle(VisualPage, "Visuals")
pageTitle(CarsPage, "Cars")
pageTitle(PlayersPage, "Players")
pageTitle(AutoFarmPage, "Auto Farm")
pageTitle(NittyAutoFarmPage, "Nitty AUTO FARM")
pageTitle(ChatPage, "Chat")
pageTitle(NameChangerPage, "Name Changer")
pageTitle(SettingsPage, "Settings")
for _, page in pairs(Pages) do
for _, obj in ipairs(page:GetDescendants()) do
if obj:IsA("GuiButton") or obj:IsA("TextLabel") or obj:IsA("TextBox") or obj:IsA("Frame") then
if not (page:FindFirstChild("VisualBackground") and obj:IsDescendantOf(page.VisualBackground)) then
obj.ZIndex = math.max(obj.ZIndex, 20)
end
end
end
end
registerToggleKeybind = function(toggleButton, toggleName, defaultKey)
local entry = {
Button = toggleButton,
Name = toggleName,
Key = defaultKey,
KeyButton = nil,
Callback = nil,
}
table.insert(ToggleKeybindEntries, entry)
local keyButton = create("TextButton", {
Name = "ToggleKeybind",
BackgroundColor3 = PANEL2,
BackgroundTransparency = 0.15,
BorderSizePixel = 0,
Size = UDim2.fromOffset(130, 24),
AnchorPoint = Vector2.new(0.5, 0.5),
Position = UDim2.new(0.5, 0, 0.5, 0),
Text = defaultKey and defaultKey.Name or "NONE",
TextColor3 = WHITE,
TextSize = 10,
Font = Enum.Font.GothamBold,
AutoButtonColor = false,
ZIndex = 4,
}, toggleButton)
corner(keyButton, 7)
stroke(keyButton, BORDER, 1, 0.25)
entry.KeyButton = keyButton
local cancelButton = create("TextButton", {
Name = "ToggleKeybindCancel",
BackgroundColor3 = PANEL2,
BackgroundTransparency = 0.15,
BorderSizePixel = 0,
Size = UDim2.fromOffset(18, 18),
AnchorPoint = Vector2.new(0, 0.5),
Position = UDim2.new(0.5, 21, 0.5, 0),
Text = "X",
TextColor3 = WHITE,
TextSize = 10,
Font = Enum.Font.GothamBold,
AutoButtonColor = false,
Visible = false,
ZIndex = 5,
}, toggleButton)
corner(cancelButton, 6)
stroke(cancelButton, BORDER, 1, 0.25)
entry.CancelButton = cancelButton
local function stopCapture()
if KeybindCapture == entry then
KeybindCapture = nil
end
cancelButton.Visible = false
keyButton.Text = entry.Key and entry.Key.Name or "NONE"
end
keyButton.MouseButton1Click:Connect(function()
if KeybindCapture == entry then
return
end
if KeybindCapture and KeybindCapture ~= entry then
local old = KeybindCapture
KeybindCapture = nil
if old.KeyButton then old.KeyButton.Text = old.Key and old.Key.Name or "NONE" end
if old.CancelButton then old.CancelButton.Visible = false end
end
KeybindCapture = entry
cancelButton.Visible = true
end)
cancelButton.MouseButton1Click:Connect(stopCapture)
return entry
end
UserInputService.InputBegan:Connect(function(input, processed)
if KeybindCapture then
if input.UserInputType == Enum.UserInputType.Keyboard then
if input.KeyCode ~= Enum.KeyCode.Unknown then
local entry = KeybindCapture
entry.Key = input.KeyCode
KeybindCapture = nil
if entry.KeyButton then entry.KeyButton.Text = entry.Key.Name end
if entry.CancelButton then entry.CancelButton.Visible = false end
return
end
end
return
end
if processed or input.UserInputType ~= Enum.UserInputType.Keyboard then
return
end
for _, entry in ipairs(ToggleKeybindEntries) do
if entry.Key == input.KeyCode and entry.Button and entry.Button.Parent and entry.Button.Parent.Visible then
if entry.Callback then
entry.Callback()
end
break
end
end
end)
local SettingsInfo = label(SettingsPage, "Interface settings", UDim2.new(1, -10, 0, 28), UDim2.fromOffset(0, 0), 11)
SettingsInfo.TextColor3 = MUTED
SettingsInfo.LayoutOrder = 2
local StatusDisplayButton
StatusDisplayButton = pageButton(SettingsPage, "Status Display: ON", function()
local enabled = string.match(StatusDisplayButton.Text, ":%s*(%a+)$") == "ON"
StatusDisplayButton.Text = "Status Display: " .. (enabled and "OFF" or "ON")
if StatusPill then
StatusPill.Visible = not enabled
end
end)
StatusDisplayButton.LayoutOrder = 3
--============================================================
-- NAME CHANGER
--============================================================
do
local originalLabelText = {}
local customDisplayName = ""
local customSecondLine = ""
local function getCharacter()
return LocalPlayer.Character
end
local function applyNameChanger()
local character = getCharacter()
if not character then return end
local humanoid = character:FindFirstChildOfClass("Humanoid")
if humanoid and customDisplayName ~= "" then
pcall(function() humanoid.DisplayName = customDisplayName end)
end
if customSecondLine == "" and customDisplayName == "" then return end
for _, obj in ipairs(character:GetDescendants()) do
if obj:IsA("TextLabel") or obj:IsA("TextButton") then
local text = obj.Text
if typeof(text) == "string" and text ~= "" then
local trimmed = text:gsub("^%s+", ""):gsub("%s+$", "")
if trimmed == LocalPlayer.Name or trimmed == LocalPlayer.DisplayName or trimmed == tostring(LocalPlayer.UserId) or originalLabelText[obj] ~= nil then
if originalLabelText[obj] == nil then
originalLabelText[obj] = text
end
local original = originalLabelText[obj]
if original == LocalPlayer.Name or original == LocalPlayer.DisplayName then
if customDisplayName ~= "" then obj.Text = customDisplayName end
elseif original == tostring(LocalPlayer.UserId) then
if customSecondLine ~= "" then obj.Text = customSecondLine end
end
end
end
end
end
end
local function resetNameChanger()
customDisplayName = ""
customSecondLine = ""
local character = getCharacter()
if character then
local humanoid = character:FindFirstChildOfClass("Humanoid")
if humanoid then
pcall(function() humanoid.DisplayName = LocalPlayer.DisplayName end)
end
end
for obj, original in pairs(originalLabelText) do
if obj and obj.Parent then obj.Text = original end
end
table.clear(originalLabelText)
end
local NameDisplayBox = create("TextBox", {
Name = "NameDisplayBox", BackgroundColor3 = PANEL2, TextColor3 = WHITE,
PlaceholderText = "New display name", PlaceholderColor3 = MUTED, Text = "",
TextSize = 13, Font = Enum.Font.GothamMedium, ClearTextOnFocus = false,
Size = UDim2.new(1, -10, 0, 42), Position = UDim2.fromOffset(0, 0),
}, NameChangerPage)
corner(NameDisplayBox, 9)
stroke(NameDisplayBox, BORDER, 1, 0.3)
NameDisplayBox.LayoutOrder = #NameChangerPage:GetChildren() + 1
local NameSecondLineBox = create("TextBox", {
Name = "NameSecondLineBox", BackgroundColor3 = PANEL2, TextColor3 = WHITE,
PlaceholderText = "New username / ID line", PlaceholderColor3 = MUTED, Text = "",
TextSize = 13, Font = Enum.Font.GothamMedium, ClearTextOnFocus = false,
Size = UDim2.new(1, -10, 0, 42), Position = UDim2.fromOffset(0, 0),
}, NameChangerPage)
corner(NameSecondLineBox, 9)
stroke(NameSecondLineBox, BORDER, 1, 0.3)
NameSecondLineBox.LayoutOrder = #NameChangerPage:GetChildren() + 1
pageButton(NameChangerPage, "Apply Name", function()
customDisplayName = (NameDisplayBox.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")
customSecondLine = (NameSecondLineBox.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")
applyNameChanger()
end)
pageButton(NameChangerPage, "Reset Name", function()
resetNameChanger()
NameDisplayBox.Text = ""
NameSecondLineBox.Text = ""
end)
label(NameChangerPage, "Changes are local to your client.", UDim2.new(1, -10, 0, 28), UDim2.fromOffset(0, 0), 11).TextColor3 = MUTED
LocalPlayer.CharacterAdded:Connect(function()
task.wait(0.5)
if customDisplayName ~= "" or customSecondLine ~= "" then applyNameChanger() end
end)
end
--============================================================
-- CHAT PAGE
--============================================================
do
local TextChatService = game:GetService("TextChatService")
local running = false
local ChatMessageBox = create("TextBox", {
Name = "ChatMessageBox", BackgroundColor3 = PANEL2, TextColor3 = WHITE,
PlaceholderColor3 = MUTED, PlaceholderText = "Message", Text = "/pay 25000",
TextSize = 13, Font = Enum.Font.GothamMedium, ClearTextOnFocus = false,
TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, -10, 0, 42), LayoutOrder = 2,
}, ChatPage)
corner(ChatMessageBox, 9)
stroke(ChatMessageBox, BORDER, 1, 0.3)
local ChatIntervalBox = create("TextBox", {
Name = "ChatIntervalBox", BackgroundColor3 = PANEL2, TextColor3 = WHITE,
PlaceholderColor3 = MUTED, PlaceholderText = "Interval", Text = "0.1",
TextSize = 13, Font = Enum.Font.GothamMedium, ClearTextOnFocus = false,
TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, -10, 0, 42), LayoutOrder = 3,
}, ChatPage)
corner(ChatIntervalBox, 9)
stroke(ChatIntervalBox, BORDER, 1, 0.3)
local ChatStatus = label(ChatPage, "Private repeat test: OFF", UDim2.new(1, -10, 0, 30), UDim2.fromOffset(0, 0), 12)
ChatStatus.TextColor3 = MUTED
ChatStatus.LayoutOrder = 4
local function sendMessage()
local channels = TextChatService:FindFirstChild("TextChannels")
local channel = channels and channels:FindFirstChild("RBXGeneral")
if channel then channel:SendAsync(ChatMessageBox.Text) end
end
local ChatToggleButton
ChatToggleButton = pageButton(ChatPage, "Chat Test: OFF", function()
running = not running
if running then
ChatToggleButton.Text = "Chat Test: ON"
ChatStatus.Text = "Private repeat test: ON"
ChatStatus.TextColor3 = GREEN
sendMessage()
task.spawn(function()
while running do
print("[PRIVATE TEST] " .. ChatMessageBox.Text)
local delayTime = tonumber(ChatIntervalBox.Text) or 0.1
delayTime = math.max(delayTime, 0.05)
task.wait(delayTime)
end
end)
else
ChatToggleButton.Text = "Chat Test: OFF"
ChatStatus.Text = "Private repeat test: OFF"
ChatStatus.TextColor3 = MUTED
end
end)
ChatToggleButton.LayoutOrder = 5
end
--============================================================
-- INFORMATION
--============================================================
info = label(InfoPage, "Thank you for using OCEANA", UDim2.new(1, -10, 0, 220), UDim2.fromOffset(0, 0), 14)
info.TextWrapped = true
info.LayoutOrder = 2
--============================================================
-- PLAYER PAGE
--============================================================
pageSlider(PlayerPage, "Walk Speed", 16, 32, Config.WALK_SPEED, function(value)
Config.WALK_SPEED = value
applyWalkSpeed()
end)
pageSlider(PlayerPage, "Jump Power", 50, 150, Config.JUMP_POWER, function(value)
Config.JUMP_POWER = value
applyJumpPower()
end)
pageSlider(PlayerPage, "Fly Speed", 30, 70, Config.FLY_SPEED, function(value)
Config.FLY_SPEED = value
end)
WalkToggleButton = pageButton(PlayerPage, "Walk Speed: " .. (Config.WALK_SPEED_ENABLED and "ON" or "OFF"), function()
Config.WALK_SPEED_ENABLED = not Config.WALK_SPEED_ENABLED
WalkToggleButton.Text = "Walk Speed: " .. (Config.WALK_SPEED_ENABLED and "ON" or "OFF")
applyWalkSpeed()
end)
InfinteStaminaButton = pageButton(PlayerPage, "Infinite Stamina: OFF", function()
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local staminaValue = character:FindFirstChild("StaminaValue")
if not staminaValue then return end
local enabled = InfinteStaminaButton.Text == "Infinite Stamina: ON"
if enabled then
staminaValue.Value = 100
InfinteStaminaButton.Text = "Infinite Stamina: OFF"
else
staminaValue.Value = math.huge
InfinteStaminaButton.Text = "Infinite Stamina: ON"
end
end)
--============================================================
-- FLY
--============================================================
function startFly()
if Flying then return end
if not RootPart or not Humanoid then return end
Flying = true
Humanoid.AutoRotate = false
Humanoid.PlatformStand = true
FlyBV = Instance.new("BodyVelocity")
FlyBV.Name = "AdminFlyVelocity"
FlyBV.MaxForce = Vector3.new(1e6, 1e6, 1e6)
FlyBV.P = 25000
FlyBV.Velocity = Vector3.zero
FlyBV.Parent = RootPart
FlyBG = Instance.new("BodyGyro")
FlyBG.Name = "AdminFlyGyro"
FlyBG.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
FlyBG.P = 30000
FlyBG.D = 1000
FlyBG.CFrame = RootPart.CFrame
FlyBG.Parent = RootPart
end
function stopFly()
Flying = false
if FlyBV then FlyBV:Destroy(); FlyBV = nil end
if FlyBG then FlyBG:Destroy(); FlyBG = nil end
if Humanoid then Humanoid.PlatformStand = false; Humanoid.AutoRotate = true end
if RootPart then
RootPart.AssemblyLinearVelocity = Vector3.zero
RootPart.AssemblyAngularVelocity = Vector3.zero
end
end
FlyButton = pageButton(PlayerPage, "Fly: OFF", function()
if Flying then stopFly() else startFly() end
FlyButton.Text = "Fly: " .. (Flying and "ON" or "OFF")
updateAutoFarmStateText(Config.AUTO_FARM, Flying, Noclip, 1, false, false)
end)
NoclipButton = pageButton(PlayerPage, "NoClip: OFF", function()
Noclip = not Noclip
NoclipButton.Text = "NoClip: " .. (Noclip and "ON" or "OFF")
updateAutoFarmStateText(Config.AUTO_FARM, Flying, Noclip, 1, false, false)
end)
PickupButton = pageButton(PlayerPage, "Instant Pickup: OFF", function()
Config.INSTANT_PICKUP = not Config.INSTANT_PICKUP
PickupButton.Text = "Instant Pickup: " .. (Config.INSTANT_PICKUP and "ON" or "OFF")
end)
InfiniteJumpButton = pageButton(PlayerPage, "Infinite Jump: OFF", function()
InfiniteJumpEnabled = not InfiniteJumpEnabled
InfiniteJumpButton.Text = "Infinite Jump: " .. (InfiniteJumpEnabled and "ON" or "OFF")
InfiniteJumpButton.TextColor3 = InfiniteJumpEnabled and GREEN or WHITE
end)
pageButton(PlayerPage, "Reset Character", function()
if Humanoid then Humanoid.Health = 0 end
end)
--============================================================
-- TELEPORT
--============================================================
TeleportStatus = label(TeleportPage, "Status: Ready", UDim2.new(1, -10, 0, 30), UDim2.fromOffset(0, 0), 13)
TeleportStatus.TextColor3 = MUTED
function teleportToCoordinates(position, labelText)
local character = LocalPlayer.Character
local root = character and character:FindFirstChild("HumanoidRootPart")
local humanoid = character and character:FindFirstChildOfClass("Humanoid")
if not character or not root then
TeleportStatus.Text = "Status: Character not ready"
TeleportStatus.TextColor3 = RED
return
end
local destination = CFrame.new(position)
local seat = humanoid and humanoid.SeatPart
local vehicle = nil
if seat and (seat:IsA("VehicleSeat") or seat:IsA("Seat")) then
vehicle = seat:FindFirstAncestorOfClass("Model")
end
if vehicle and vehicle ~= character then
vehicle:PivotTo(destination)
for _, obj in ipairs(vehicle:GetDescendants()) do
if obj:IsA("BasePart") then
obj.AssemblyLinearVelocity = Vector3.zero
obj.AssemblyAngularVelocity = Vector3.zero
end
end
else
character:PivotTo(destination)
root.AssemblyLinearVelocity = Vector3.zero
root.AssemblyAngularVelocity = Vector3.zero
end
TeleportStatus.Text = "Status: Teleported to " .. labelText
TeleportStatus.TextColor3 = GREEN
end
DOCKS_POSITION = Vector3.new(949, 41, -2367)
HOUSE_TOP_FLOOR_POSITION = Vector3.new(271, 133, 2090)
KNIFE_CRATE_POSITION = Vector3.new(1469, 3, -419)
MAIN_POSITION = Vector3.new(-617, 3, -299)
GROW_YARD_POSITION = Vector3.new(287, 71, 1622)
BANK_POSITION = Vector3.new(1617, 7, 1550)
JEWELLERY_POSITION = Vector3.new(414, 3, 2719)
BANK_JEWELLERY_DROPOFF_POSITION = Vector3.new(383, 3, 154)
pageButton(TeleportPage, "Docks", function() teleportToCoordinates(DOCKS_POSITION, "Docks") end)
pageButton(TeleportPage, "House - Top Floor", function() teleportToCoordinates(HOUSE_TOP_FLOOR_POSITION, "House - Top Floor") end)
pageButton(TeleportPage, "Knife crate", function() teleportToCoordinates(KNIFE_CRATE_POSITION, "Knife crate") end)
pageButton(TeleportPage, "Main", function() teleportToCoordinates(MAIN_POSITION, "Main") end)
pageButton(TeleportPage, "Grow yard", function() teleportToCoordinates(GROW_YARD_POSITION, "Grow yard") end)
pageButton(TeleportPage, "Bank", function() teleportToCoordinates(BANK_POSITION, "Bank") end)
pageButton(TeleportPage, "Jewellery", function() teleportToCoordinates(JEWELLERY_POSITION, "Jewellery") end)
pageButton(TeleportPage, "Bank/jewellery Drop off", function() teleportToCoordinates(BANK_JEWELLERY_DROPOFF_POSITION, "Bank/jewellery Drop off") end)
pageButton(TeleportPage, "Seed shop", function() teleportToCoordinates(Vector3.new(-355, 3, 955), "Seed shop") end)
TeleportInfo = label(TeleportPage, "Teleport locations are hidden", UDim2.new(1, -10, 0, 28), UDim2.fromOffset(0, 0), 12)
TeleportInfo.TextWrapped = true
TeleportInfo.TextColor3 = MUTED
--============================================================
-- COMBAT / AIM
--============================================================
local EquipAllKnivesBusy = false
local function equipAllKnives()
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
if not backpack then return 0 end
local found = 0
for _, item in ipairs(backpack:GetChildren()) do
if item:IsA("Tool") then
item.Parent = character
found += 1
task.wait(0.03)
end
end
for _, item in ipairs(character:GetChildren()) do
if item:IsA("Tool") then found += 1 end
end
return found
end
EquipAllKnivesButton = pageButton(CombatPage, "EQUIP ALL KNIVES", function()
if EquipAllKnivesBusy then return end
EquipAllKnivesBusy = true
EquipAllKnivesButton.Text = "EQUIPPING..."
task.spawn(function()
equipAllKnives()
task.wait(0.5)
if EquipAllKnivesButton and EquipAllKnivesButton.Parent then
EquipAllKnivesButton.Text = "EQUIP ALL KNIVES"
EquipAllKnivesBusy = false
end
end)
end)
TargetLabel = label(CombatPage, "Target: None", UDim2.new(1, -10, 0, 30), UDim2.fromOffset(0, 0), 13)
TargetLabel.LayoutOrder = 2
AimButton = pageButton(CombatPage, "Aim Assist: OFF", function()
AimAssist = not AimAssist
AimButton.Text = "Aim Assist: " .. (AimAssist and "ON" or "OFF")
end)
pageButton(CombatPage, "Aim FOV: 60", function()
Config.AIM_FOV += 10
if Config.AIM_FOV > Config.FOV_MAX then Config.AIM_FOV = Config.FOV_MIN end
for _, child in ipairs(CombatPage:GetChildren()) do
if child:IsA("TextButton") and string.find(child.Text, "Aim FOV:", 1, true) then
child.Text = "Aim FOV: " .. Config.AIM_FOV
break
end
end
end)
pageButton(CombatPage, "Aim Strength: 100", function()
Config.AIM_STRENGTH += 10
if Config.AIM_STRENGTH > Config.AIM_MAX then Config.AIM_STRENGTH = Config.AIM_MIN end
for _, child in ipairs(CombatPage:GetChildren()) do
if child:IsA("TextButton") and string.find(child.Text, "Aim Strength:", 1, true) then
child.Text = "Aim Strength: " .. Config.AIM_STRENGTH
break
end
end
end)
