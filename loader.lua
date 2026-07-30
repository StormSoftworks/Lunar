local HttpService = game:GetService("HttpService")

local BaseGit = "https://github.com/StormSoftworks/Lunar/tree/main"
local BaseRaw = BaseGit:gsub("github.com", "raw.githubusercontent.com"):gsub("/tree/", "/")
local BaseApi = "https://api.github.com/repos/StormSoftworks/Lunar/contents"

local LunarDir = "Lunar"
local GamesDir = LunarDir .. "/games"
local LibDir = LunarDir .. "/library"

local isInstalled = isfolder(LunarDir) and isfolder(GamesDir) and isfolder(LibDir)

if not isInstalled then
	if not isfolder(LunarDir) then makefolder(LunarDir) end
	if not isfolder(GamesDir) then makefolder(GamesDir) end
	if not isfolder(LibDir) then makefolder(LibDir) end

	local libUrl = BaseRaw .. "/library/lib.lua"
	local libSuccess, libContent = pcall(function() return game:HttpGet(libUrl) end)
	if libSuccess and libContent and not libContent:find("404: Not Found") then
		writefile(LibDir .. "/lib.lua", libContent)
	end

	local uniUrl = BaseRaw .. "/universal.lua"
	local uniSuccess, uniContent = pcall(function() return game:HttpGet(uniUrl) end)
	if uniSuccess and uniContent and not uniContent:find("404: Not Found") then
		writefile(LunarDir .. "/universal.lua", uniContent)
	end

	local gamesApiUrl = BaseApi .. "/games"
	local apiSuccess, apiResponse = pcall(function() return game:HttpGet(gamesApiUrl) end)

	if apiSuccess and apiResponse then
		local jsonSuccess, files = pcall(function() return HttpService:JSONDecode(apiResponse) end)
		if jsonSuccess and type(files) == "table" then
			for _, file in ipairs(files) do
				if file.type == "file" and file.name:match("%.lua$") then
					local fileContent = game:HttpGet(file.download_url)
					writefile(GamesDir .. "/" .. file.name, fileContent)
				end
			end
		end
	end
end

local placeId = tostring(game.PlaceId)
local localGameFile = GamesDir .. "/" .. placeId .. ".lua"
local localUniversalFile = LunarDir .. "/universal.lua"

if isfile(localGameFile) then
	loadstring(readfile(localGameFile))()
elseif isfile(localUniversalFile) then
	loadstring(readfile(localUniversalFile))()
else
	loadstring(game:HttpGet(BaseRaw .. "/universal.lua"))()
end
