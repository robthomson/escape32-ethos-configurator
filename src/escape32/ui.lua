local LUA_VERSION = "1.0.0"

local config = {
	toolName = "ESCape32",
	icon = "SCRIPTS:/escape32/icon.png",
	version = {major = 0, minor = 2, revision = 0, suffix = "dev"},
}

local SPORT_LOCAL_SENSOR_ID = 0x0D
local SPORT_REQUEST_FRAME_ID = 0x30
local SPORT_REPLY_FRAME_ID = 0x32
local SPORT_MSP_PAYLOAD_SIZE = 6
local MSP_VERSION = 0x20
local MSP_START = 0x10
local MSP_ERROR = 0x80
local MSP_SEQ_MASK = 0x0F

local MSP_ESC_PARAMETERS = 217
local MSP_SET_ESC_PARAMETERS = 218
local MSP_EEPROM_WRITE = 250
local MSP_ES32_INFO = 0xF0
local ES32_CONFIG_VERSION = 1

local parameters = {
	{id = 1,  name = "Arm on startup",     min = 0,    max = 1,    default = 1,    bool = true},
	{id = 2,  name = "Active freewheel",   min = 0,    max = 1,    default = 1,    bool = true},
	{id = 3,  name = "Reverse direction",  min = 0,    max = 1,    default = 0,    bool = true},
	{id = 4,  name = "Brushed mode",       min = 0,    max = 1,    default = 0,    bool = true},
	{id = 5,  name = "Timing",             min = 1,    max = 31,   default = 16,   suffix = " deg"},
	{id = 6,  name = "Sine range",         min = 0,    max = 25,   default = 0,    suffix = "%"},
	{id = 7,  name = "Sine power",         min = 1,    max = 15,   default = 8,    suffix = "%"},
	{id = 8,  name = "PWM min freq",       min = 16,   max = 48,   default = 24,   suffix = " kHz"},
	{id = 9,  name = "PWM max freq",       min = 16,   max = 96,   default = 48,   suffix = " kHz"},
	{id = 10, name = "Duty min",           min = 1,    max = 100,  default = 1,    suffix = "%"},
	{id = 11, name = "Duty max",           min = 1,    max = 100,  default = 100,  suffix = "%"},
	{id = 12, name = "Spin-up duty",       min = 1,    max = 100,  default = 15,   suffix = "%"},
	{id = 13, name = "Duty ramp",          min = 0,    max = 100,  default = 0,    suffix = " kERPM"},
	{id = 14, name = "Duty slew",          min = 1,    max = 100,  default = 30},
	{id = 15, name = "Drag brake",         min = 0,    max = 100,  default = 0,    suffix = "%"},
	{id = 16, name = "Active drag",        min = 0,    max = 2,    default = 0,
		choices = {{"Off", 0}, {"Soft", 1}, {"Hard", 2}}},
	{id = 17, name = "Throttle mode",      min = 0,    max = 3,    default = 0,
		choices = {{"Forward", 0}, {"Fwd/rev", 1}, {"Fwd/brk/rev", 2}, {"Fwd/brk", 3}}},
	{id = 18, name = "Reverse limit",      min = 0,    max = 3,    default = 0,
		choices = {{"100%", 0}, {"75%", 1}, {"50%", 2}, {"25%", 3}}},
	{id = 19, name = "Brake power",        min = 0,    max = 100,  default = 100,  suffix = "%"},
	{id = 20, name = "Preset throttle",    min = 0,    max = 100,  default = 0,    suffix = "%"},
	{id = 21, name = "Zero coasting",      min = 0,    max = 1,    default = 0,    bool = true},
	{id = 22, name = "Throttle cal",       min = 0,    max = 1,    default = 1,    bool = true},
	{id = 23, name = "Throttle min",       min = 900,  max = 1900, default = 1000, suffix = " us"},
	{id = 24, name = "Throttle mid",       min = 1000, max = 2000, default = 1500, suffix = " us"},
	{id = 25, name = "Throttle max",       min = 1100, max = 2100, default = 2000, suffix = " us"},
	{id = 26, name = "Analog min",         min = 0,    max = 3200, default = 100,  suffix = " mV"},
	{id = 27, name = "Analog max",         min = 200,  max = 3400, default = 3200, suffix = " mV"},
	{id = 28, name = "Input mode",         min = 0,    max = 7,    default = 0,
		choices = {{"Auto", 0}, {"Analog", 1}, {"Serial", 2}, {"iBUS", 3}, {"SBUS", 4}, {"CRSF", 5}, {"EXBUS", 6}, {"HoTT", 7}}},
	{id = 29, name = "Throttle channel",   min = 0,    max = 32,   default = 0},
	{id = 30, name = "Aux channel",        min = 0,    max = 32,   default = 0},
	{id = 31, name = "Telemetry mode",     min = 0,    max = 6,    default = 0,
		choices = {{"KISS", 0}, {"KISS auto", 1}, {"iBUS", 2}, {"S.Port", 3}, {"CRSF", 4}, {"MSB", 5}, {"HoTT", 6}}},
	{id = 32, name = "Telemetry ID",       min = 0,    max = 28,   default = 0},
	{id = 33, name = "Motor poles",        min = 2,    max = 100,  default = 14},
	{id = 34, name = "Voltage cal",        min = -80,  max = 160,  default = 0,    signed = true},
	{id = 35, name = "Current cal",        min = -100, max = 200,  default = 0,    signed = true},
	{id = 36, name = "Stall ERPM",         min = 0,    max = 3500, default = 0},
	{id = 37, name = "Temp cutoff",        min = 0,    max = 140,  default = 0,    suffix = "C"},
	{id = 38, name = "Temp sensor",        min = 0,    max = 2,    default = 0,
		choices = {{"ESC", 0}, {"Motor", 1}, {"Both", 2}}},
	{id = 39, name = "Volt cutoff",        min = 0,    max = 38,   default = 0},
	{id = 40, name = "Cells",              min = 0,    max = 24,   default = 0},
	{id = 41, name = "Current limit",      min = 0,    max = 999,  default = 0,    suffix = "A"},
	{id = 42, name = "Parking speed",      min = 0,    max = 4,    default = 0},
	{id = 44, name = "Sound volume",       min = 0,    max = 100,  default = 25,   suffix = "%"},
	{id = 45, name = "Beacon volume",      min = 0,    max = 100,  default = 50,   suffix = "%"},
	{id = 46, name = "BEC voltage",        min = 0,    max = 4,    default = 0,
		choices = {{"5.5V", 0}, {"6.5V", 1}, {"7.4V", 2}, {"8.4V", 3}, {"12V", 4}}},
	{id = 47, name = "LED bits",           min = 0,    max = 15,   default = 0}
}

local state = {
	status = "Ready",
	sensor = nil,
	pending = nil,
	loaded = false,
	txBuf = nil,
	txIndex = 1,
	txSeq = 0,
	txCrc = 0,
	rxBuf = {},
	rxSize = 0,
	rxCmd = 0,
	rxSeq = 0,
	rxStarted = false,
	lastFrame = nil,
	fields = {},
	dirty = false
}

-- ── helpers ──────────────────────────────────────────────────────────────────

local function versionString()
	local v = config.version
	local suffix = v.suffix and v.suffix ~= "" and ("-" .. v.suffix) or ""
	return string.format("%d.%d.%d%s", v.major, v.minor, v.revision, suffix)
end

local function markDirty()
	state.dirty = true
end

local function setStatus(text)
	state.status = text
	if state.fields.status and state.fields.status.value then
		state.fields.status:value(text)
	end
	markDirty()
end

local function ensureSensor()
	if state.sensor then
		return state.sensor
	end
	if not sport or not sport.getSensor then
		setStatus("S.Port API unavailable")
		return nil
	end
	state.sensor = sport.getSensor({module = 0, primId = SPORT_REPLY_FRAME_ID})
	if not state.sensor then
		setStatus("No S.Port sensor")
	end
	return state.sensor
end

local function pushMspPayload(payload)
	local sensor = ensureSensor()
	if not sensor then return false end
	local dataId = payload[1] | (payload[2] << 8)
	local value = payload[3] | (payload[4] << 8) | (payload[5] << 16) | (payload[6] << 24)
	local ok = sensor:pushFrame({
		physId = SPORT_LOCAL_SENSOR_ID,
		primId = SPORT_REQUEST_FRAME_ID,
		appId = dataId,
		value = value
	})
	if ok == false then
		setStatus("Send failed")
		return false
	end
	return true
end

local function processTx()
	if not state.txBuf then return false end
	local payload = {}
	payload[1] = MSP_VERSION | (state.txSeq & MSP_SEQ_MASK)
	state.txSeq = (state.txSeq + 1) & MSP_SEQ_MASK
	if state.txIndex == 1 then
		payload[1] = payload[1] | MSP_START
	end
	local i = 2
	while i <= SPORT_MSP_PAYLOAD_SIZE and state.txIndex <= #state.txBuf do
		payload[i] = state.txBuf[state.txIndex]
		state.txCrc = state.txCrc ~ payload[i]
		state.txIndex = state.txIndex + 1
		i = i + 1
	end
	if i <= SPORT_MSP_PAYLOAD_SIZE then
		payload[i] = state.txCrc
		i = i + 1
		while i <= SPORT_MSP_PAYLOAD_SIZE do
			payload[i] = 0
			i = i + 1
		end
		state.txBuf = nil
		state.txIndex = 1
		state.txCrc = 0
	end
	return pushMspPayload(payload)
end

local function sendMsp(command, payload)
	if state.pending or state.txBuf then
		return false
	end
	payload = payload or {}
	state.txBuf = {#payload, command & 0xFF}
	for i = 1, #payload do
		state.txBuf[#state.txBuf + 1] = payload[i] & 0xFF
	end
	state.txIndex = 1
	state.txCrc = 0
	state.pending = {command = command, sentAt = os.clock()}
	return processTx()
end

local function requestPing()
	if sendMsp(MSP_ES32_INFO) then
		setStatus("Finding ESC...")
	end
end

local function readU16(buf, index)
	return (buf[index] or 0) | ((buf[index + 1] or 0) << 8)
end

local function writeU16(buf, value)
	value = value or 0
	if value < 0 then value = value + 0x10000 end
	buf[#buf + 1] = value & 0xFF
	buf[#buf + 1] = (value >> 8) & 0xFF
end

local function applyConfigImage(buf)
	local count = #parameters
	if #buf ~= 6 + count * 2 then return false end
	if buf[1] ~= 0x45 or buf[2] ~= 0x53 or buf[3] ~= 0x33 or buf[4] ~= 0x32 then return false end
	if buf[5] ~= ES32_CONFIG_VERSION or buf[6] ~= count then return false end
	for i = 1, count do
		local param = parameters[i]
		local value = readU16(buf, 7 + (i - 1) * 2)
		if param.signed and value >= 0x8000 then
			value = value - 0x10000
		end
		param.value = value
	end
	state.loaded = true
	markDirty()
	return true
end

local function buildConfigImage()
	if not state.loaded then return nil end
	local buf = {0x45, 0x53, 0x33, 0x32, ES32_CONFIG_VERSION, #parameters}
	for i = 1, #parameters do
		local param = parameters[i]
		local value = param.value
		if value == nil then value = param.default or 0 end
		writeU16(buf, value)
	end
	return buf
end

local function readAll()
	if sendMsp(MSP_ESC_PARAMETERS) then
		setStatus("Reading ESC...")
	end
end

local function saveSettings()
	if sendMsp(MSP_EEPROM_WRITE) then
		setStatus("Saving...")
	end
end

local function setParameter(param, value)
	if not state.loaded then
		setStatus("Read ESC first")
		markDirty()
		return
	end
	value = tonumber(value) or param.default or 0
	if value < param.min then value = param.min end
	if value > param.max then value = param.max end
	param.value = value
	local image = buildConfigImage()
	if image and sendMsp(MSP_SET_ESC_PARAMETERS, image) then
		setStatus("Writing " .. tostring(param.name))
	else
		markDirty()
	end
end

local function readMspPayload(frame)
	local appId = frame:appId()
	local value = frame:value()
	return {
		appId & 0xFF,
		(appId >> 8) & 0xFF,
		value & 0xFF,
		(value >> 8) & 0xFF,
		(value >> 16) & 0xFF,
		(value >> 24) & 0xFF
	}
end

local function frameKey(frame)
	return string.format("%02x:%02x:%04x:%08x", frame:physId() or 0, frame:primId() or 0, frame:appId() or 0, frame:value() or 0)
end

local function receiveMspPayload(payload)
	local status = payload[1]
	local version = status & 0x60
	local seq = status & MSP_SEQ_MASK
	local start = (status & MSP_START) ~= 0
	local index
	if version ~= MSP_VERSION then return nil end
	if start then
		state.rxBuf = {}
		state.rxSize = payload[2]
		state.rxCmd = payload[3]
		state.rxSeq = seq
		state.rxStarted = true
		state.rxError = (status & MSP_ERROR) ~= 0
		index = 4
	elseif not state.rxStarted then
		return nil
	elseif ((state.rxSeq + 1) & MSP_SEQ_MASK) ~= seq then
		state.rxStarted = false
		return nil
	else
		state.rxSeq = seq
		index = 2
	end
	while index <= SPORT_MSP_PAYLOAD_SIZE and #state.rxBuf < state.rxSize do
		state.rxBuf[#state.rxBuf + 1] = payload[index]
		index = index + 1
	end
	if #state.rxBuf < state.rxSize then
		return nil
	end
	state.rxStarted = false
	return state.rxCmd, state.rxBuf, state.rxError
end

local function handleMspReply(cmd, buf, err)
	local pending = state.pending
	state.pending = nil
	if err then
		setStatus("ESC rejected command")
		return true
	end
	if pending and pending.command ~= cmd then
		setStatus("Unexpected reply")
		return true
	end
	if cmd == MSP_ES32_INFO then
		if buf[1] == 0x45 and buf[2] == 0x53 and buf[3] == 0x33 and buf[4] == 0x32 then
			setStatus("ESC connected")
		else
			setStatus("Unexpected ESC")
		end
		return true
	end
	if cmd == MSP_ESC_PARAMETERS then
		setStatus(applyConfigImage(buf) and "Read complete" or "Bad config image")
		return true
	end
	if cmd == MSP_SET_ESC_PARAMETERS then
		setStatus(applyConfigImage(buf) and "Updated" or "Bad write reply")
		return true
	end
	if cmd == MSP_EEPROM_WRITE then
		setStatus("Saved")
		return true
	end
	setStatus("Reply received")
	return true
end

local function pollReplies()
	local sensor = ensureSensor()
	if not sensor then return end
	processTx()

	while true do
		local frame = sensor:popFrame()
		if not frame then break end
		if frame:primId() == SPORT_REPLY_FRAME_ID then
			local key = frameKey(frame)
			if key ~= state.lastFrame then
				state.lastFrame = key
				local cmd, buf, err = receiveMspPayload(readMspPayload(frame))
				if cmd then
					handleMspReply(cmd, buf, err)
				end
			end
		end
	end

	if state.pending and os.clock() - state.pending.sentAt > 1.5 then
		state.pending = nil
		state.txBuf = nil
		state.rxStarted = false
		setStatus("No reply")
	end
end

-- ── form ─────────────────────────────────────────────────────────────────────

local function addButton(line, text, action)
	if form.addButton then
		return form.addButton(line, nil, {text = text, press = action})
	end
	return form.addTextButton(line, nil, text, action)
end

local function buildForm()
	form.clear()
	state.fields = {}

	local statusLine = form.addLine("Status")
	state.fields.status = form.addStaticText(statusLine, nil, state.status)

	local readLine = form.addLine("Read")
	addButton(readLine, "Read ESC", readAll)

	local saveLine = form.addLine("Save")
	addButton(saveLine, "Save to ESC", saveSettings)

	local pingLine = form.addLine("Connection")
	addButton(pingLine, "Ping", requestPing)

	local panel = form.addExpansionPanel("Settings")
	panel:open(true)

	for i = 1, #parameters do
		local param = parameters[i]
		local line = panel:addLine(param.name)

		if param.choices then
			state.fields[param.id] = form.addChoiceField(line, nil, param.choices, function()
				return param.value ~= nil and param.value or param.default or 0
			end, function(newValue)
				setParameter(param, newValue)
			end)
		elseif param.bool then
			state.fields[param.id] = form.addBooleanField(line, nil, function()
				return (param.value or param.default or 0) ~= 0
			end, function(newValue)
				setParameter(param, newValue and 1 or 0)
			end)
		else
			local field = form.addNumberField(line, nil, param.min, param.max, function()
				return param.value or param.default or 0
			end, function(newValue)
				setParameter(param, newValue)
			end)
			if param.suffix and field.suffix then
				field:suffix(param.suffix)
			end
			state.fields[param.id] = field
		end
	end

	local versionLine = form.addLine("Lua")
	form.addStaticText(versionLine, nil, "Version " .. versionString())
end

-- ── exported callbacks ────────────────────────────────────────────────────────

local ui = {}

function ui.create()
	buildForm()
	requestPing()
end

function ui.wakeup()
	pollReplies()
	if state.dirty then
		state.dirty = false
		form.invalidate()
	end
end

function ui.close()
	state.pending = nil
	state.readIndex = nil
end

return ui
