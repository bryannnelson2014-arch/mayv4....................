--// ===== WHITELIST (MINIMAL + SAFE) =====
local Players = game:GetService("Players")
local WHITELIST_URL = "https://raw.githubusercontent.com/Wyroke/Whitelist/refs/heads/main/Calculator"

local function checkWhitelist()
    local player = Players.LocalPlayer
    if not player then
        repeat task.wait() until Players.LocalPlayer
        player = Players.LocalPlayer
    end

    local ok, data = pcall(function()
        return game:HttpGet(WHITELIST_URL, true)
    end)

    if not ok or type(data) ~= "string" then
        return false, player
    end

    for id in data:gmatch("%d+") do
        if tonumber(id) == player.UserId then
            return true, player
        end
    end

    return false, player
end
--// =====================================


--// ORIGINAL WORKING LOADER (UNCHANGED)
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end

local delfile = delfile or function(file)
	writefile(file, '')
end

local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet(
                'https://raw.githubusercontent.com/Wyroke/VapeV4ForRoblox/' ..
                readfile('newvape/profiles/commit.txt') ..
                '/' ..
                select(1, path:gsub('newvape/', '')),
                true
            )
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local function wipeFolder(path)
	if not isfolder(path) then return end
	for _, file in listfiles(path) do
		if file:find('loader') then continue end
		if isfile(file) and select(1, readfile(file):find('--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.')) == 1 then
			delfile(file)
		end
	end
end

for _, folder in {'newvape', 'newvape/games', 'newvape/profiles', 'newvape/assets', 'newvape/libraries', 'newvape/guis'} do
	if not isfolder(folder) then
		makefolder(folder)
	end
end

if not shared.VapeDeveloper then
	local _, subbed = pcall(function() 
		return game:HttpGet('https://github.com/Wyroke/VapeV4ForRoblox') 
	end)
	local commit = subbed:find('currentOid')
	commit = commit and subbed:sub(commit + 13, commit + 52) or nil
	commit = commit and #commit == 40 and commit or 'main'
	if commit == 'main' or (isfile('newvape/profiles/commit.txt') and readfile('newvape/profiles/commit.txt') or '') ~= commit then
		wipeFolder('newvape')
		wipeFolder('newvape/games')
		wipeFolder('newvape/guis')
		wipeFolder('newvape/libraries')
	end
	writefile('newvape/profiles/commit.txt', commit)
end

--// RUN WHITELIST CHECK LAST (SAFE)
local allowed, player = checkWhitelist()
if not allowed then
	task.spawn(function()
		task.wait(1)
		player:Kick("You are not whitelisted.")
	end)
	return
end

return loadstring(downloadFile('newvape/main.lua'), 'main')()
