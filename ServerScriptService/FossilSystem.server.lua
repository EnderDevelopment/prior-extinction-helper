-- Server-authoritative fossil teleport and collection system.

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local CollectionService = game:GetService("CollectionService")

local FOSSIL_FOLDER_NAME = "Fossils"
local FOSSIL_TAG = "Fossil"
local TELEPORT_COMMAND = "!fossil"
local COLLECT_COMMAND = "!collectfossil"
local TELEPORT_OFFSET = CFrame.new(0, 4, 8)
local COLLECTION_DISTANCE = 14
local TELEPORT_COOLDOWN = 3
local DATASTORE_NAME = "FossilInventory_v1"

local fossilStore = DataStoreService:GetDataStore(DATASTORE_NAME)
local teleportTimes = {}
local collecting = {}

local fossilsFolder = workspace:FindFirstChild(FOSSIL_FOLDER_NAME)
if not fossilsFolder then
	fossilsFolder = Instance.new("Folder")
	fossilsFolder.Name = FOSSIL_FOLDER_NAME
	fossilsFolder.Parent = workspace
end

local function getFossils()
	local fossils = {}
	for _, object in ipairs(fossilsFolder:GetDescendants()) do
		if object:IsA("BasePart") then
			table.insert(fossils, object)
		end
	end
	for _, object in ipairs(CollectionService:GetTagged(FOSSIL_TAG)) do
		if object:IsA("BasePart") and object:IsDescendantOf(workspace) and not table.find(fossils, object) then
			table.insert(fossils, object)
		end
	end
	return fossils
end

local function getRoot(player)
	local character = player.Character
	if not character then
		return nil
	end
	return character:FindFirstChild("HumanoidRootPart")
end

local function getCountValue(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	return leaderstats and leaderstats:FindFirstChild("Fossils")
end

local function savePlayer(player)
	local countValue = getCountValue(player)
	if not countValue then
		return
	end
	local success, errorMessage = pcall(function()
		fossilStore:SetAsync(tostring(player.UserId), countValue.Value)
	end)
	if not success then
		warn("Could not save fossils for " .. player.Name .. ": " .. errorMessage)
	end
end

local function collectFossil(player, fossil)
	if collecting[player] or not fossil or not fossil.Parent then
		return false
	end
	local root = getRoot(player)
	local countValue = getCountValue(player)
	if not root or not countValue then
		return false
	end
	if (root.Position - fossil.Position).Magnitude > COLLECTION_DISTANCE then
		return false
	end

	collecting[player] = true
	countValue.Value += 1
	fossil:SetAttribute("CollectedBy", player.UserId)
	fossil.Transparency = 1
	fossil.CanCollide = false
	fossil.CanTouch = false
	fossil.CanQuery = false
	local prompt = fossil:FindFirstChildOfClass("ProximityPrompt")
	if prompt then
		prompt.Enabled = false
	end
	print(player.Name .. " collected a fossil.")
	collecting[player] = nil
	return true
end

local function addPrompt(fossil)
	if not fossil:IsA("BasePart") or fossil:FindFirstChildOfClass("ProximityPrompt") then
		return
	end
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "CollectFossilPrompt"
	prompt.ActionText = "Collect"
	prompt.ObjectText = "Fossil"
	prompt.HoldDuration = 0.5
	prompt.MaxActivationDistance = COLLECTION_DISTANCE
	prompt.RequiresLineOfSight = false
	prompt.Parent = fossil
	prompt.Triggered:Connect(function(player)
		collectFossil(player, fossil)
	end)
end

local function findNearestAvailableFossil(player)
	local root = getRoot(player)
	if not root then
		return nil
	end
	local nearest
	local nearestDistance = math.huge
	for _, fossil in ipairs(getFossils()) do
		if fossil.Transparency < 1 and not fossil:GetAttribute("CollectedBy") then
			local distance = (root.Position - fossil.Position).Magnitude
			if distance < nearestDistance then
				nearest = fossil
				nearestDistance = distance
			end
		end
	end
	return nearest
end

local function teleportToFossil(player)
	local now = os.clock()
	if now - (teleportTimes[player] or 0) < TELEPORT_COOLDOWN then
		return
	end
	local root = getRoot(player)
	local fossil = findNearestAvailableFossil(player)
	if not root or not fossil then
		return
	end
	teleportTimes[player] = now
	root.CFrame = fossil.CFrame * TELEPORT_OFFSET
end

local function setupPlayer(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local fossils = Instance.new("IntValue")
	fossils.Name = "Fossils"
	fossils.Parent = leaderstats

	local success, savedCount = pcall(function()
		return fossilStore:GetAsync(tostring(player.UserId))
	end)
	if success and typeof(savedCount) == "number" then
		fossils.Value = math.max(0, savedCount)
	end

	player.Chatted:Connect(function(message)
		local command = string.lower(message):match("^%s*(%S+)")
		if command == TELEPORT_COMMAND then
			teleportToFossil(player)
		elseif command == COLLECT_COMMAND then
			local root = getRoot(player)
			if root then
				for _, fossil in ipairs(getFossils()) do
					if fossil.Transparency < 1 and (root.Position - fossil.Position).Magnitude <= COLLECTION_DISTANCE then
						collectFossil(player, fossil)
						break
					end
				end
			end
		end
	end)
end

for _, fossil in ipairs(getFossils()) do
	addPrompt(fossil)
end
fossilsFolder.DescendantAdded:Connect(function(object)
	if object:IsA("BasePart") then
		addPrompt(object)
	end
end)

Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(function(player)
	savePlayer(player)
	teleportTimes[player] = nil
	collecting[player] = nil
end)

game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		savePlayer(player)
	end
end)
