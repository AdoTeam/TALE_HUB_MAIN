local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

--------------------------------------------------
-- GUI ANA EKRAN
--------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomMenuGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 100
screenGui.Parent = playerGui

--------------------------------------------------
-- ⚠️ BİLDİRİM SİSTEMİ (NOTIFICATION SYSTEM)
--------------------------------------------------
local function showNotification(message)
	local notifFrame = Instance.new("Frame")
	notifFrame.Name = "CustomNotification"
	notifFrame.Size = UDim2.new(0, 240, 0, 35)
	notifFrame.Position = UDim2.new(0.5, -120, 0, -50) -- Ekranın dışından başlar
	notifFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	notifFrame.BorderSizePixel = 0
	notifFrame.BackgroundTransparency = 0.1
	notifFrame.Parent = screenGui

	local notifCorner = Instance.new("UICorner", notifFrame)
	notifCorner.CornerRadius = UDim.new(0, 6)

	local notifStroke = Instance.new("UIStroke", notifFrame)
	notifStroke.Color = Color3.fromRGB(0, 170, 255)
	notifStroke.Thickness = 1

	local notifLabel = Instance.new("TextLabel", notifFrame)
	notifLabel.Size = UDim2.new(1, 0, 1, 0)
	notifLabel.BackgroundTransparency = 1
	notifLabel.Text = message
	notifLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
	notifLabel.Font = Enum.Font.GothamMedium
	notifLabel.TextSize = 13
	notifLabel.Parent = notifFrame

	-- Giriş Animasyonu (Yukarıdan aşağı kayar)
	TweenService:Create(notifFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -120, 0, 45)}):Play()
	
	-- 3.5 Saniye Bekle ve Kapat
	task.delay(3.5, function()
		local fadeTween = TweenService:Create(notifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0.5, -120, 0, -50)})
		fadeTween:Play()
		fadeTween.Completed:Connect(function()
			notifFrame:Destroy()
		end)
	end)
end

--------------------------------------------------
-- BAŞLANGIÇ DEĞERLERİNİ OYUNDAN ALMA
--------------------------------------------------
local MAX_VAL = 400
local MIN_VAL = 0

-- Karakter ilk yüklendiğinde oyunun orijinal değerlerini çekiyoruz
local currentTargetJump = 50
local currentTargetSpeed = 16
local initialValuesSet = false

local function syncWithGame()
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid", 5)
	if hum then
		currentTargetSpeed = hum.WalkSpeed
		currentTargetJump = hum.UseJumpPower and hum.JumpPower or (hum.JumpHeight > 0 and hum.JumpHeight or 50)
		initialValuesSet = true
	end
end
syncWithGame()

-- Kullanıcı slider'ı elle hareket ettirdi mi kontrolü
local sliderJumpChanged = false
local sliderSpeedChanged = false

--------------------------------------------------
-- SLIDER HIZ & ZIPLAMA MENÜSÜ (3. BUTONA BAĞLI)
--------------------------------------------------
local menuImage = Instance.new("ImageLabel")
menuImage.Name = "MenuBackground"
menuImage.Size = UDim2.new(0, 500, 0, 200) 
menuImage.Position = UDim2.new(0.5, -250, 1, -200)
menuImage.BackgroundTransparency = 1
menuImage.Image = "rbxassetid://115169890200285" 
menuImage.Visible = false
menuImage.Parent = screenGui

-- Zıplama Barı
local jumpBar = Instance.new("ImageLabel")
jumpBar.Name = "JumpBar"
jumpBar.Size = UDim2.new(0, 400, 0, 25) 
jumpBar.Position = UDim2.new(0.5, -200, 0.4, 0)
jumpBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40) 
jumpBar.BorderSizePixel = 0
jumpBar.Image = "rbxassetid://98637810629619" 
jumpBar.Parent = menuImage

local jumpButton = Instance.new("ImageButton")
jumpButton.Name = "JumpButton"
jumpButton.Size = UDim2.new(0, 35, 0, 35) 
jumpButton.Position = UDim2.new(0, 0, 0.5, -17.5) 
jumpButton.BackgroundColor3 = Color3.fromRGB(240, 240, 240) 
jumpButton.BorderSizePixel = 0
jumpButton.Image = "rbxassetid://92380938444775" 
jumpButton.Parent = jumpBar

local jumpLabel = Instance.new("TextLabel")
jumpLabel.Size = UDim2.new(0, 200, 0, 20)
jumpLabel.Position = UDim2.new(0.5, -100, 0, -22)
jumpLabel.BackgroundTransparency = 1
jumpLabel.Text = "Jump Power: " .. currentTargetJump
jumpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpLabel.Font = Enum.Font.SourceSansBold
jumpLabel.TextSize = 16 
jumpLabel.Parent = jumpBar

Instance.new("UICorner", jumpBar).CornerRadius = UDim.new(0, 12)

-- Hız Barı
local speedBar = Instance.new("ImageLabel")
speedBar.Name = "SpeedBar"
speedBar.Size = UDim2.new(0, 400, 0, 25) 
speedBar.Position = UDim2.new(0.5, -200, 0.75, 0)
speedBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40) 
speedBar.BorderSizePixel = 0
speedBar.Image = "rbxassetid://98637810629619" 
speedBar.Parent = menuImage

local speedButton = Instance.new("ImageButton")
speedButton.Name = "SpeedButton"
speedButton.Size = UDim2.new(0, 35, 0, 35) 
speedButton.Position = UDim2.new(0, 0, 0.5, -17.5) 
speedButton.BackgroundColor3 = Color3.fromRGB(240, 240, 240) 
speedButton.BorderSizePixel = 0
speedButton.Image = "rbxassetid://92380938444775" 
speedButton.Parent = speedBar

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 200, 0, 20)
speedLabel.Position = UDim2.new(0.5, -100, 0, -22)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed: " .. currentTargetSpeed
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.Font = Enum.Font.SourceSansBold
speedLabel.TextSize = 16 
speedLabel.Parent = speedBar

Instance.new("UICorner", speedBar).CornerRadius = UDim.new(0, 12)

-- Buton Başlangıç Konumlarını Ayarla
local function updateSliderPositions()
	local jumpRatio = math.clamp((currentTargetJump - MIN_VAL) / (MAX_VAL - MIN_VAL), 0, 1)
	jumpButton.Position = UDim2.new(jumpRatio, -17.5, 0.5, -17.5)
	
	local speedRatio = math.clamp((currentTargetSpeed - MIN_VAL) / (MAX_VAL - MIN_VAL), 0, 1)
	speedButton.Position = UDim2.new(speedRatio, -17.5, 0.5, -17.5)
end
updateSliderPositions()

local dragJump = false
local dragSpeed = false

jumpButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragJump = true
		sliderJumpChanged = true
	end
end)

speedButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragSpeed = true
		sliderSpeedChanged = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragJump = false
		dragSpeed = false
	end
end)

--------------------------------------------------
-- TALEHUB STATUS
--------------------------------------------------
local PlusUsers = {"Usta_R"}
local function HasPlus(username)
	for _, name in ipairs(PlusUsers) do
		if string.lower(name) == string.lower(username) then return true end
	end
	return false
end

local statusLabel = Instance.new("TextLabel", screenGui)
statusLabel.Size = UDim2.new(0,180,0,20)
statusLabel.Position = UDim2.new(0,5,0,5)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 16

if HasPlus(player.Name) then
	statusLabel.Text = "TaleHub [+] Active"
	task.spawn(function()
		local hue = 0
		while statusLabel.Parent do
			statusLabel.TextColor3 = Color3.fromHSV(hue,1,1)
			hue = (hue + 0.01) % 1
			task.wait()
		end
	end)
else
	statusLabel.Text = "TaleHub Free Active"
	statusLabel.TextColor3 = Color3.fromRGB(255,0,0)
end

--------------------------------------------------
-- TOGGLE BUTTON & MAIN MENU
--------------------------------------------------
local toggleButton = Instance.new("ImageButton", screenGui)
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0,100,0,90)
toggleButton.Position = UDim2.new(0,20,0.5,-45)
toggleButton.BackgroundTransparency = 1
toggleButton.Image = "rbxassetid://111412181088124"
toggleButton.Active = true

local mainMenu = Instance.new("ImageLabel", screenGui)
mainMenu.Name = "MainMenu"
mainMenu.Size = UDim2.new(0,600,0,420)
mainMenu.Position = UDim2.new(0.5,-300,-1,0)
mainMenu.BackgroundTransparency = 1
mainMenu.Image = "rbxassetid://125015751189692"
mainMenu.Visible = false

--------------------------------------------------
-- 🌟 YENİ EKLENEN GÖRSEL VE RENKLİ YAZI (TALE HUB)
--------------------------------------------------
local image = Instance.new("ImageLabel")
image.Name = "CustomHeaderImage"
image.Size = UDim2.new(0, 350, 0, 110)
image.Position = UDim2.new(0.5, -190, 0.5, -255)
image.BackgroundTransparency = 1
image.Image = "rbxassetid://132520586139694"
image.Parent = mainMenu

local rainbowText = Instance.new("TextLabel")
rainbowText.Name = "RainbowText"
rainbowText.Size = UDim2.new(1, 0, 0.85, 0)
rainbowText.Position = UDim2.new(0, 0, 0.15, 0)
rainbowText.BackgroundTransparency = 1
rainbowText.Text = "Tale HUB"
rainbowText.Font = Enum.Font.FredokaOne
rainbowText.TextSize = 70 
rainbowText.TextWrapped = true
rainbowText.Parent = image

-- Yavaş Renk Akışı (Rainbow) Animasyonu
task.spawn(function()
	local hue = 0
	while rainbowText.Parent do
		rainbowText.TextColor3 = Color3.fromHSV(hue, 0.75, 1)
		hue = (hue + 0.004) % 1
		task.wait()
	end
end)
--------------------------------------------------

local extraButton = Instance.new("ImageButton", mainMenu)
extraButton.Name = "ExtraButton"
extraButton.Size = UDim2.new(0,100,0,50)
extraButton.Position = UDim2.new(0,20,0,20)
extraButton.BackgroundTransparency = 1
extraButton.Image = "rbxassetid://101930796312023"
extraButton.Visible = false

local adGui = Instance.new("ImageLabel", screenGui)
adGui.Name = "AdGui"
adGui.Size = UDim2.new(0,210,0,270)
adGui.Position = UDim2.new(0.5,-540,0.5,-150)
adGui.BackgroundTransparency = 1
adGui.Image = "rbxassetid://71591013400418"
adGui.Visible = false

local closeButton = Instance.new("ImageButton", mainMenu)
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0,80,0,54)
closeButton.Position = UDim2.new(1,-73,0,9)
closeButton.BackgroundTransparency = 1
closeButton.Image = "rbxassetid://137716314304146"
closeButton.Visible = false

local scrollFrame = Instance.new("ScrollingFrame", mainMenu)
scrollFrame.Name = "ScrollMenu"
scrollFrame.Size = UDim2.new(0,540,0,300)
scrollFrame.Position = UDim2.new(0,30,0,90)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 6

local grid = Instance.new("UIGridLayout", scrollFrame)
grid.CellSize = UDim2.new(0,170,0,75)
grid.CellPadding = UDim2.new(0,10,0,10)
grid.FillDirectionMaxCells = 3

--------------------------------------------------
-- 🎯 REFRESHABLE EN YAKIN OYUNCU AIMBOT MANTIĞI
--------------------------------------------------
local lockOnEnabled = false
local cameraConnection = nil
local currentTargetPlayer = nil 

local function getClosestPlayer()
	if currentTargetPlayer and currentTargetPlayer.Character and currentTargetPlayer.Character:FindFirstChild("HumanoidRootPart") and currentTargetPlayer.Character:FindFirstChildOfClass("Humanoid") and currentTargetPlayer.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
		return currentTargetPlayer
	end

	local closestPlayer = nil
	local shortestDistance = math.huge
	local localCharacter = player.Character
	
	if localCharacter and localCharacter:FindFirstChild("HumanoidRootPart") then
		local localHRP = localCharacter.HumanoidRootPart
		for _, otherPlayer in ipairs(Players:GetPlayers()) do
			if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") and otherPlayer.Character:FindFirstChildOfClass("Humanoid") and otherPlayer.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
				
				local targetHRP = otherPlayer.Character.HumanoidRootPart
				local distance = (localHRP.Position - targetHRP.Position).Magnitude
				
				if distance < shortestDistance then
					shortestDistance = distance
					closestPlayer = otherPlayer
				end
			end
		end
	end
	return closestPlayer
end

local function toggleLockOn(state)
	lockOnEnabled = state
	if state then
		currentTargetPlayer = getClosestPlayer()
		if not cameraConnection then
			cameraConnection = RunService.RenderStepped:Connect(function()
				if lockOnEnabled then
					if not currentTargetPlayer or not currentTargetPlayer.Character or not currentTargetPlayer.Character:FindFirstChild("HumanoidRootPart") or not currentTargetPlayer.Character:FindFirstChildOfClass("Humanoid") or currentTargetPlayer.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then
						currentTargetPlayer = getClosestPlayer()
					end
					
					if currentTargetPlayer and currentTargetPlayer.Character then
						local targetPart = currentTargetPlayer.Character:FindFirstChild("Head") or currentTargetPlayer.Character:FindFirstChild("HumanoidRootPart")
						if targetPart then 
							camera.CFrame = CFrame.new(camera.CFrame.Position, targetPart.Position) 
						end
					end
				end
			end)
		end
	else
		currentTargetPlayer = nil
		if cameraConnection then
			cameraConnection:Disconnect()
			cameraConnection = nil
		end
	end
end

--------------------------------------------------
-- INF JUMP (SINIRSIZ ZIPLAMA) MANTIĞI
--------------------------------------------------
local infJumpEnabled = false
UserInputService.JumpRequest:Connect(function()
	if infJumpEnabled then
		local character = player.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end
	end
end)

--------------------------------------------------
-- 👁️ 1. BUTON: GELİŞMİŞ ESP SİSTEMİ (BOX, AD, CAN, UZAKLIK)
--------------------------------------------------
local espEnabled = false
local espObjects = {}

local function createEsp(targetPlayer)
	if espObjects[targetPlayer] then return end

	local espContainer = Instance.new("Folder")
	espContainer.Name = "ESP_" .. targetPlayer.Name
	espContainer.Parent = screenGui

	local boxLines = {}
	for i = 1, 4 do
		local line = Instance.new("Frame")
		line.BackgroundColor3 = Color3.fromRGB(0, 255, 100) 
		line.BorderSizePixel = 0
		line.Parent = espContainer
		table.insert(boxLines, line)
	end

	local topText = Instance.new("TextLabel")
	topText.BackgroundTransparency = 1
	topText.TextColor3 = Color3.fromRGB(255, 255, 255)
	topText.Font = Enum.Font.SourceSansBold
	topText.TextSize = 14
	topText.TextStrokeTransparency = 0 
	topText.Parent = espContainer

	local bottomText = Instance.new("TextLabel")
	bottomText.BackgroundTransparency = 1
	bottomText.TextColor3 = Color3.fromRGB(255, 230, 100) 
	bottomText.Font = Enum.Font.SourceSansBold
	bottomText.TextSize = 13
	bottomText.TextStrokeTransparency = 0
	bottomText.Parent = espContainer

	espObjects[targetPlayer] = {
		Container = espContainer,
		Lines = boxLines,
		TopText = topText,
		BottomText = bottomText
	}
end

local function removeEsp(targetPlayer)
	if espObjects[targetPlayer] then
		espObjects[targetPlayer].Container:Destroy()
		espObjects[targetPlayer] = nil
	end
end

-- Tüm ESP kutularını tamamen temizleyen yardımcı fonksiyon
local function clearAllEsp()
	for p, _ in pairs(espObjects) do 
		removeEsp(p) 
	end
end

RunService.RenderStepped:Connect(function()
	-- 🛠️ EĞER ESP KAPALIYSA: Ekranda hiçbir şey bırakma ve döngüden çık!
	if not espEnabled then
		clearAllEsp()
		return
	end

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player then
			local char = p.Character
			local localChar = player.Character
			
			if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") and char:FindFirstChildOfClass("Humanoid").Health > 0 and localChar and localChar:FindFirstChild("HumanoidRootPart") then
				
				local hrp = char.HumanoidRootPart
				local hum = char:FindFirstChildOfClass("Humanoid")
				local hrpPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
				
				if onScreen then
					createEsp(p)
					local esp = espObjects[p]
					
					local distance = (localChar.HumanoidRootPart.Position - hrp.Position).Magnitude
					local sizeX = math.clamp(2000 / distance, 10, 150)
					local sizeY = math.clamp(3000 / distance, 15, 220)
					
					local posX = hrpPos.X - (sizeX / 2)
					local posY = hrpPos.Y - (sizeY / 2)

					esp.Lines[1].Position = UDim2.new(0, posX, 0, posY) 
					esp.Lines[1].Size = UDim2.new(0, sizeX, 0, 2)
					
					esp.Lines[2].Position = UDim2.new(0, posX, 0, posY + sizeY) 
					esp.Lines[2].Size = UDim2.new(0, sizeX + 2, 0, 2)
					
					esp.Lines[3].Position = UDim2.new(0, posX, 0, posY) 
					esp.Lines[3].Size = UDim2.new(0, 2, 0, sizeY)
					
					esp.Lines[4].Position = UDim2.new(0, posX + sizeX, 0, posY) 
					esp.Lines[4].Size = UDim2.new(0, 2, 0, sizeY)

					esp.TopText.Visible = true
					esp.TopText.Position = UDim2.new(0, posX, 0, posY - 20)
					esp.TopText.Size = UDim2.new(0, sizeX, 0, 15)
					esp.TopText.Text = p.Name .. " [" .. math.floor(hum.Health) .. " HP]"

					esp.BottomText.Visible = true
					esp.BottomText.Position = UDim2.new(0, posX, 0, posY + sizeY + 5)
					esp.BottomText.Size = UDim2.new(0, sizeX, 0, 15)
					esp.BottomText.Text = math.floor(distance) .. "m"
				else
					removeEsp(p)
				end
			else
				removeEsp(p)
			end
		end
	end
end)

Players.PlayerRemoving:Connect(removeEsp)

--------------------------------------------------
-- ROBLOX ONAY PANELİ VE MİNİ BUTON
--------------------------------------------------
local promptFrame = Instance.new("Frame")
promptFrame.Name = "AimlockPrompt"
promptFrame.Size = UDim2.new(0, 260, 0, 120)
promptFrame.Position = UDim2.new(0, 20, 1, 20)
promptFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
promptFrame.BorderSizePixel = 0
promptFrame.Parent = screenGui

local promptCorner = Instance.new("UICorner", promptFrame)
promptCorner.CornerRadius = UDim.new(0, 8)

local promptTitle = Instance.new("TextLabel", promptFrame)
promptTitle.Size = UDim2.new(1, -20, 0, 30)
promptTitle.Position = UDim2.new(0, 10, 0, 5)
promptTitle.BackgroundTransparency = 1
promptTitle.Text = "Aimlock Toggle"
promptTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
promptTitle.Font = Enum.Font.GothamBold
promptTitle.TextSize = 16
promptTitle.TextXAlignment = Enum.TextXAlignment.Left

local promptDesc = Instance.new("TextLabel", promptFrame)
promptDesc.Size = UDim2.new(1, -20, 0, 30)
promptDesc.Position = UDim2.new(0, 10, 0, 35)
promptDesc.BackgroundTransparency = 1
promptDesc.Text = "Do you want toggle?"
promptDesc.TextColor3 = Color3.fromRGB(200, 200, 200)
promptDesc.Font = Enum.Font.Gotham
promptDesc.TextSize = 14
promptDesc.TextXAlignment = Enum.TextXAlignment.Left

local yesButton = Instance.new("TextButton", promptFrame)
yesButton.Size = UDim2.new(0, 105, 0, 32)
yesButton.Position = UDim2.new(0, 10, 1, -42)
yesButton.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
yesButton.Text = "Evet"
yesButton.TextColor3 = Color3.fromRGB(255, 255, 255)
yesButton.Font = Enum.Font.GothamBold
yesButton.TextSize = 14
Instance.new("UICorner", yesButton).CornerRadius = UDim.new(0, 6)

local noButton = Instance.new("TextButton", promptFrame)
noButton.Size = UDim2.new(0, 105, 0, 32)
noButton.Position = UDim2.new(1, -115, 1, -42)
noButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
noButton.Text = "Hayır"
noButton.TextColor3 = Color3.fromRGB(255, 255, 255)
noButton.Font = Enum.Font.GothamBold
noButton.TextSize = 14
Instance.new("UICorner", noButton).CornerRadius = UDim.new(0, 6)

local customAimButton = Instance.new("ImageButton", screenGui)
customAimButton.Name = "CustomAimButton"
customAimButton.Size = UDim2.new(0, 170, 0, 75) 
customAimButton.Position = UDim2.new(0.1, 0, 0.7, 0) 
customAimButton.BackgroundTransparency = 1
customAimButton.Image = "rbxassetid://135078564647103"
customAimButton.Visible = false

local customAimActive = false

local cabDragging, cabDragInput, cabDragStart, cabStartPos
customAimButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		cabDragging = true
		cabDragStart = input.Position
		cabStartPos = customAimButton.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then cabDragging = false end
		end)
	end
end)

customAimButton.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		cabDragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == cabDragInput and cabDragging then
		local delta = input.Position - cabDragStart
		customAimButton.Position = UDim2.new(cabStartPos.X.Scale, cabStartPos.X.Offset + delta.X, cabStartPos.Y.Scale, cabStartPos.Y.Offset + delta.Y)
	end
end)

customAimButton.MouseButton1Click:Connect(function()
	customAimActive = not customAimActive
	customAimButton.Image = customAimActive and "rbxassetid://97488569724496" or "rbxassetid://135078564647103"
	toggleLockOn(customAimActive)
end)

local function showPrompt()
	TweenService:Create(promptFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 20, 1, -140)}):Play()
end

local function hidePrompt()
	TweenService:Create(promptFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0, 20, 1, 20)}):Play()
end

noButton.MouseButton1Click:Connect(hidePrompt)
yesButton.MouseButton1Click:Connect(function()
	hidePrompt()
	customAimButton.Visible = true
end)

--------------------------------------------------
-- BUTON SİSTEMLERİ VE TIKLAMA MANTIKLARI
--------------------------------------------------
local buttonInstances = {}
local buttons = {
	{Name="Button1", EnabledImage="rbxassetid://91126967723487", DisabledImage="rbxassetid://97978638406688"}, 
	{Name="Button2", EnabledImage="rbxassetid://135078564647103", DisabledImage="rbxassetid://135078564647103"}, 
	{Name="Button3", EnabledImage="rbxassetid://90674886492428", DisabledImage="rbxassetid://90674886492428"}, 
	{Name="Button4", EnabledImage="rbxassetid://101941029424417", DisabledImage="rbxassetid://105835877369813"}, 
	{Name="Button5", EnabledImage="rbxassetid://139259486887463", DisabledImage="rbxassetid://139259486887463"},
	{Name="Button6", EnabledImage="rbxassetid://130857407373890", DisabledImage="rbxassetid://130857407373890"},
	{Name="Button7", EnabledImage="rbxassetid://128924268283713", DisabledImage="rbxassetid://128924268283713"},
	{Name="Button8", EnabledImage="rbxassetid://128924268283713", DisabledImage="rbxassetid://128924268283713"}
}

for _, data in ipairs(buttons) do
	local button = Instance.new("ImageButton", scrollFrame)
	button.BackgroundTransparency = 1
	button.Image = data.DisabledImage

	buttonInstances[data.Name] = {Instance = button, Data = data, Enabled = false}

	button.MouseButton1Click:Connect(function()
		local bState = buttonInstances[data.Name]
		bState.Enabled = not bState.Enabled
		button.Image = bState.Enabled and data.EnabledImage or data.DisabledImage

		if data.Name == "Button1" then
			espEnabled = bState.Enabled
			if not espEnabled then
				clearAllEsp() 
			end
		elseif data.Name == "Button2" then
			if bState.Enabled then showPrompt() else hidePrompt() end
		elseif data.Name == "Button3" then
			menuImage.Visible = bState.Enabled
			updateSliderPositions()
		elseif data.Name == "Button4" then
			infJumpEnabled = bState.Enabled
		elseif data.Name == "Button5" then
			-- 5. Buton: Guardian Scriptini Çalıştırır ve Üstte Bildirim Gösterir (YENİ 🚀)
			if bState.Enabled then
				showNotification("Guardian Beta Executed Successfully!") -- 3.5 saniyelik İngilizce bildirim
				pcall(function()
					loadstring(game:HttpGet("https://raw.githubusercontent.com/AdoTeam/TA_Guardian_obs/refs/heads/main/Guardian_obs_beta.lua"))()
				end)
			end
		elseif data.Name == "Button6" then
			-- 6. Buton: Fly Gui Scriptini Çalıştırır ve Üstte Bildirim Gösterir
			if bState.Enabled then
				showNotification("Fly Gui Executed Successfully!")
				pcall(function()
					loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
				end)
			end
		end
	end)
end

local function updateCanvas() scrollFrame.CanvasSize = UDim2.new(0,0,0,grid.AbsoluteContentSize.Y + 20) end
grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
updateCanvas()

--------------------------------------------------
-- MENU TOGGLE (SENKRONİZE KAPATMA)
--------------------------------------------------
local opened = false
local function setMenu(state)
	opened = state
	mainMenu.Visible = true
	adGui.Visible = state
	closeButton.Visible = state
	extraButton.Visible = state

	if buttonInstances["Button3"].Enabled then
		menuImage.Visible = state
	end

	if state then
		TweenService:Create(mainMenu, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5,-300,0.5,-180)}):Play()
	else
		local tween = TweenService:Create(mainMenu, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0.5,-300,-1,0)})
		tween:Play()
		tween.Completed:Connect(function() mainMenu.Visible = false end)
	end
end

toggleButton.MouseButton1Click:Connect(function() setMenu(not opened) end)
closeButton.MouseButton1Click:Connect(function() setMenu(false) end)

--------------------------------------------------
-- 🔁 DÖNGÜ: DİNAMİK SLIDER VE OYUNA SADIK DEĞER KONTROLÜ
--------------------------------------------------
RunService.RenderStepped:Connect(function()
	local mousePos = UserInputService:GetMouseLocation()
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid and humanoid.Health > 0 and not dragJump and not dragSpeed then
		if not sliderSpeedChanged then
			currentTargetSpeed = humanoid.WalkSpeed
		end
		if not sliderJumpChanged then
			currentTargetJump = humanoid.UseJumpPower and humanoid.JumpPower or (humanoid.JumpHeight > 0 and humanoid.JumpHeight or 50)
		end
	end

	if dragJump then
		local barPosX = jumpBar.AbsolutePosition.X
		local barWidth = jumpBar.AbsoluteSize.X
		local relativeX = mousePos.X - barPosX
		local clampedX = math.clamp(relativeX, 0, barWidth)
		
		jumpButton.Position = UDim2.new(0, clampedX - (jumpButton.AbsoluteSize.X / 2), 0.5, -17.5)
		currentTargetJump = math.floor(MIN_VAL + ((clampedX / barWidth) * (MAX_VAL - MIN_VAL)))
	end
	
	if dragSpeed then
		local barPosX = speedBar.AbsolutePosition.X
		local barWidth = speedBar.AbsoluteSize.X
		local relativeX = mousePos.X - barPosX
		local clampedX = math.clamp(relativeX, 0, barWidth)
		
		speedButton.Position = UDim2.new(0, clampedX - (speedButton.AbsoluteSize.X / 2), 0.5, -17.5)
		currentTargetSpeed = math.floor(MIN_VAL + ((clampedX / barWidth) * (MAX_VAL - MIN_VAL)))
	end
	
	jumpLabel.Text = "Jump Power: " .. tostring(currentTargetJump)
	speedLabel.Text = "Speed: " .. tostring(currentTargetSpeed)

	if humanoid and humanoid.Health > 0 then
		humanoid.UseJumpPower = true
		
		if sliderSpeedChanged then
			if humanoid.WalkSpeed ~= currentTargetSpeed then humanoid.WalkSpeed = currentTargetSpeed end
		end
		
		if sliderJumpChanged then
			if humanoid.JumpPower ~= currentTargetJump then humanoid.JumpPower = currentTargetJump end
		end
	end
end)

player.CharacterAdded:Connect(function(character)
	local humanoid = character:WaitForChild("Humanoid", 5)
	if humanoid then
		task.wait(0.5)
		humanoid.UseJumpPower = true
		
		if sliderSpeedChanged then 
			humanoid.WalkSpeed = currentTargetSpeed 
		else
			currentTargetSpeed = humanoid.WalkSpeed
		end
		
		if sliderJumpChanged then 
			humanoid.JumpPower = currentTargetJump 
		else
			currentTargetJump = humanoid.UseJumpPower and humanoid.JumpPower or 50
		end
		
		updateSliderPositions()
	end
end)

--------------------------------------------------
-- DRAG SYSTEM (TOGGLE BUTON SÜRÜKLEME)
--------------------------------------------------
local dragging, dragInput, dragStart, startPos
local function update(input)
	local delta = input.Position - dragStart
	toggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

toggleButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true dragStart = input.Position startPos = toggleButton.Position
		input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
	end
end)
toggleButton.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then update(input) end end)

