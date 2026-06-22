-- main.lua intentionally stays small so Ethos can register the tool without
-- loading the full implementation, parameters table, or form-building code.

local function compiledPath(path)
	return string.gsub(path, "%.lua$", ".luac")
end

local function loadCompiled(path)
	local compiled = compiledPath(path)
	local chunk, err = loadfile(compiled)
	if chunk then
		return chunk
	end

	if system and type(system.compile) == "function" then
		local ok, compileErr = pcall(system.compile, path)
		chunk, err = loadfile(compiled)
		if chunk then
			return chunk
		end
		if not ok then
			err = compileErr
		end
	end

	chunk, err = loadfile(path)
	return chunk, err
end

local lazy = assert(loadCompiled("lazy.lua"))()

local ESCAPE32_DEVICE_APP_ID_START = 0x0B30
local ESCAPE32_DEVICE_APP_ID_END = 0x0B7F

local page = lazy.wrap(
	{name = "ESCape32"},
	"ui.lua",
	{"create", "wakeup", "close"}
)


local icon = (lcd.loadBitmap and lcd.loadBitmap("SCRIPTS:/escape32/icon.png")) or
				(lcd.loadMask  and lcd.loadMask("SCRIPTS:/escape32/icon.png"))

local function init()


	if system.registerDeviceConfig then
		system.registerDeviceConfig({
			category   = DEVICE_CATEGORY_ESC,
			name       = page.name,
			bitmap     = icon,
			appIdStart = ESCAPE32_DEVICE_APP_ID_START,
			appIdEnd   = ESCAPE32_DEVICE_APP_ID_END,
			version    = "1.0.0",
			pages      = {page},
		})
	else
		system.registerSystemTool({
			name   = page.name,
			icon   = icon,
			create = page.create,
			wakeup = page.wakeup,
			close  = page.close,
		})
	end
end

return {init = init}
