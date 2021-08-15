-- Start Code --

-- Copyright 2017 Control4 Corporation. All Rights Reserved.

EX_CMD = {}
LUA_ACTION = {}

function OnDriverLateInit ()
	C4:AddVariable("APP_ID", "APP_LAUNCH vn.fimplus.movies", "STRING", true, false)
	C4:AddVariable("APP_NAME", "Galaxy Play", "STRING", true, false)
	
end

function ReceivedFromProxy(idBinding, strCommand, tParams)
  tParams = tParams or {}
  print("RFP[" .. idBinding .. "]: " .. strCommand)

  tParams["COMMAND"] = strCommand
  C4:SendToDevice(gTVDeviceID, "PASSTHROUGH", tParams)
  
end

function ExecuteCommand(sCommand, tParams)
	print("ExecuteCommand(" .. sCommand .. ")")

	-- Remove any spaces (trim the command)
	local trimmedCommand = string.gsub(sCommand, " ", "")
	local status, ret

	-- if function exists then execute (non-stripped)
	if (EX_CMD[sCommand] ~= nil and type(EX_CMD[sCommand]) == "function") then
		status, ret = pcall(EX_CMD[sCommand], tParams)
	-- elseif trimmed function exists then execute
	elseif (EX_CMD[trimmedCommand] ~= nil and type(EX_CMD[trimmedCommand]) == "function") then
		status, ret = pcall(EX_CMD[trimmedCommand], tParams)
	elseif (EX_CMD[sCommand] ~= nil) then
		QueueCommand(EX_CMD[sCommand])
		status = true
	else
		print("ExecuteCommand: Unhandled command = " .. sCommand)
		status = true
	end
	
	if (not status) then
		print("LUA_ERROR: " .. ret)
	end
	
	return ret -- Return whatever the function returns because it might be xml, a return code, and so on
end

function EX_CMD.LUA_ACTION(tParams)
	if (tParams ~= nil) then
		for cmd, cmdv in pairs(tParams) do
			if (cmd == "ACTION" and cmdv ~= nil) then
				local status, err = pcall(LUA_ACTION[cmdv], tParams)
				if (not status) then
					print("LUA_ERROR: " .. err)
				end
				break
			end
		end
	end
end

function EX_CMD.SET_ID(tParams)
	print("EX_CMD.SET_ID()")
	gTVDeviceID = tParams["ID"] or 0
end

print("Driver Loaded.")


