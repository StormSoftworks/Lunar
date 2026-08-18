local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local EncodingService = game:GetService("EncodingService")

local LocalPlayer = Players.LocalPlayer


--// User list

local List = loadstring(game:HttpGet("https://raw.githubusercontent.com/StormSoftworks/Lunar/refs/heads/main/whitelist/wishlist.lua"))()


--// Decode Base64 UserIds

local UserData = {}

for encodedUserId, data in pairs(List) do
	local success, decodedBuffer = pcall(function()
		return EncodingService:Base64Decode(
			buffer.fromstring(encodedUserId)
		)
	end)

	if success and decodedBuffer then
		local decodedUserId = buffer.tostring(decodedBuffer)
		local userId = tonumber(decodedUserId)

		if userId then
			UserData[userId] = data
		end
	end
end


--// Helpers

local function IsListed(player)
	return UserData[player.UserId] ~= nil
end


local function ResetPlayer(player)
	if player == LocalPlayer then
		return
	end

	local character = player.Character

	if character then
		character:BreakJoints()
	end
end


local function GetRoot(player)
	local character = player.Character

	if not character then
		return nil
	end

	return character:FindFirstChild("HumanoidRootPart")
end


local function FlingPlayer(player)
	if player == LocalPlayer then
		return
	end

	local root = GetRoot(player)

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


--// Commands

local Commands = {

	kill = {

		default = {
			Superiority = false,

			Execute = function(executor)
				-- Don't affect the executor.
				-- Only affect the target represented by default.
				ResetPlayer(executor)
			end,
		},

		all = {
			Superiority = true,

			Execute = function(executor)
				for _, player in Players:GetPlayers() do
					if player ~= executor then
						ResetPlayer(player)
					end
				end
			end,
		},
	},


	void = {

		default = {
			Superiority = false,

			Execute = function(executor)
				FlingPlayer(executor)
			end,
		},

		all = {
			Superiority = true,

			Execute = function(executor)
				for _, player in Players:GetPlayers() do
					if player ~= executor then
						FlingPlayer(player)
					end
				end
			end,
		},
	},

}


--// Command parser

local function ExecuteCommand(executor, message, data)
	if not data.Commands then
		return
	end

	local arguments = string.split(message:lower(), " ")

	local commandName = arguments[1]

	if not commandName or commandName:sub(1, 1) ~= "." then
		return
	end

	commandName = commandName:sub(2)

	local parameter = arguments[2] or "default"

	if parameter ~= "default" and parameter ~= "all" then
		return
	end

	local command = Commands[commandName]

	if not command then
		return
	end

	local action = command[parameter]

	if not action then
		return
	end

	if action.Superiority and not data.commandSuperiority then
		return
	end

	action.Execute(executor)
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

	-- Only listed users get the special title/command behavior.
	if not data then
		return properties
	end

	-- React to the message.
	print(string.format(
		"[%s] %s: %s",
		data.Title,
		player.Name,
		message.Text
		))

	ExecuteCommand(player, message.Text, data)

	-- Chat title.
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
