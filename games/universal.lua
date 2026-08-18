local HttpService = game:GetService("HttpService")

local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/StormSoftworks/Lunar/refs/heads/main/library/lib.lua"))()
local Window = lib:Window({ Name = "LUNAR", Keybind = Enum.KeyCode.RightShift })

local CombatTab = Window:Tab({ Name = "Combat" })
local MovementTab = Window:Tab({ Name = "Movement" })
local RenderTab = Window:Tab({ Name = "Render" })
local WorldTab = Window:Tab({ Name = "World" })
local SettingsTab = Window:Tab({ Name = "Settings" })

CombatTab:Module({ Name = "Combat Main" })
MovementTab:Module({ Name = "Movement Main" })
RenderTab:Module({ Name = "Visuals" })
WorldTab:Module({ Name = "World Main" })

local ConfigSection = SettingsTab:Module({ Name = "Config Management" })

local placeId = tostring(game.PlaceId)
local rootDir = "Lunar"
local configsDir = rootDir .. "/configs"
local gameDir = configsDir .. "/" .. placeId

if not isfolder(rootDir) then makefolder(rootDir) end
if not isfolder(configsDir) then makefolder(configsDir) end
if not isfolder(gameDir) then makefolder(gameDir) end

local defaultPath = gameDir .. "/default.lua"
if not isfile(defaultPath) then
	writefile(defaultPath, HttpService:JSONEncode({}))
end

local currentConfig = "default"

ConfigSection:TextBox({
	Name = "Config Path",
	Placeholder = "cfgName",
	Default = currentConfig,
	Flag = "ConfigName",
	Callback = function(text)
		if text and #text > 0 then
			currentConfig = text:gsub("%.lua$", "")
		end
	end
})

ConfigSection:Button({
	Name = "Save Config",
	Flag = "SaveCfgBtn",
	Callback = function()
		local filePath = gameDir .. "/" .. currentConfig .. ".lua"
		local data = HttpService:JSONEncode(Window:SaveCfg())
		writefile(filePath, data)
		Window:Notification({ Text = "Saved to " .. filePath, Duration = 2 })
	end
})

ConfigSection:Button({
	Name = "Load Config",
	Flag = "LoadCfgBtn",
	Callback = function()
		local filePath = gameDir .. "/" .. currentConfig .. ".lua"
		if isfile(filePath) then
			local success, decoded = pcall(function()
				return HttpService:JSONDecode(readfile(filePath))
			end)
			if success and type(decoded) == "table" then
				Window:LoadCfg(decoded)
				Window:Notification({ Text = "Loaded " .. currentConfig .. ".lua", Duration = 2 })
			else
				Window:Notification({ Text = "Error reading config file.", Duration = 2 })
			end
		else
			Window:Notification({ Text = "Config not found!", Duration = 2 })
		end
	end
})

Window:Notification({ Text = "Lunar Initialized.", Duration = 2 })
