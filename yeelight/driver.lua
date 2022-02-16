YEELIGHT = {
	address = '192.168.1.106' or Properties['Local IP'],
	effect = 'smooth' or Properties['Effect'],
	duration = 500 or tonumber(Properties['Duration']),
	id = 0,
	last_send = {},
	commands = {},
	_state = '',
	_isRun = false,
	_runMode = ''
}

EX_CMDS = {}
ACTIONS = {}

Model = {}
Timer = {}


function YEELIGHT.connect()
	local tPortParams = {
		SUPPRESS_CONNECTION_EVENTS = true,
		AUTO_CONNECT = true,
		MONITOR_CONNECTION = true,
		KEEP_CONNECTION = true,
		KEEP_ALIVE = true,
		DELIMITER = "0d0a"
	} 
	C4:CreateNetworkConnection (6001, YEELIGHT.address, "TCP")
	C4:NetPortOptions(6001, 55443, "TCP", tPortParams)
	C4:NetConnect(6001, 55443)
	Timer['disconnect'] = 0
	Timer['disconnect'] = Model.AddTimer(Timer['disconnect'], 20, 'SECONDS', false)
end



function YEELIGHT.disconnect()
	C4:NetDisconnect(6001, 55443)
	YEELIGHT._isRun = false
	YEELIGHT._runMode = ''
end


function YEELIGHT.keepAlive()
	Timer['disconnect'] = Model.KillTimer(Timer['disconnect'])
	Timer['disconnect'] = Model.AddTimer(Timer['disconnect'], 20, 'SECONDS', false)
end




function YEELIGHT.send(method, param, prop)
	YEELIGHT.id = YEELIGHT.id + 1
	prop['id'] = YEELIGHT.id
	table.insert(YEELIGHT.last_send, prop)
	local strsend = '{"id":'..YEELIGHT.id..',"method":"'..method..'","params":['
	for k, v in pairs(param) do
		if type(v) == "string" then
			strsend = strsend..'"'..v..'",'
		elseif type(v) == 'number' then
			strsend = strsend..v..','
		end
	end
	strsend = string.sub(strsend, 1, string.len(strsend)-1)
	strsend = strsend..']}\r\n'
	
	print('Sending: '..strsend)
	C4:SendToNetwork(6001, 55443, strsend)
end



function YEELIGHT.syncProp(prop, value)
	if(prop == 'power')then
		C4:UpdateProperty("State", tostring(value))
	elseif prop == 'bright' then
		C4:UpdateProperty("Bright", tostring(value))
	elseif prop == 'hue' then
		C4:UpdateProperty("Hue", tostring(value))
	end
end



function YEELIGHT.getProp(prop)
	if(YEELIGHT._state == 'ONLINE')then
		local method = 'get_prop'
		local params = {}
		local props = {}
		if prop == 'all' then
			params = {"power", "bright", "hue"}
		elseif prop == 'power' then
			params = {"power"}
		elseif prop == 'bright' then
			params = {"bright"}
		elseif prop == 'hue' then
			params = {"hue"}
		end
		props = {prop = params}
		YEELIGHT.send(method, params, props)
	else
		print('State: offline -> connect to '..YEELIGHT.address)
		YEELIGHT.connect()
	end
end



function YEELIGHT.set(state)
	if(state)then
		table.insert(YEELIGHT.commands, state)
	end
	if(YEELIGHT._state == 'ONLINE')then
		if (YEELIGHT._runMode == 'command' and YEELIGHT['commands'][1]) then
			local command = YEELIGHT['commands'][1]
			table.remove(YEELIGHT.commands, 1)
			local tParam = {
				mode = YEELIGHT._runMode,
				command = command
			}
			local sendingData = {method = "", params = {}}
			if(command == 'on')then
				sendingData['method'] = "set_power"
				sendingData['params'] = {"on", YEELIGHT.effect, YEELIGHT.duration}
			elseif(command == 'off')then
				sendingData['method'] = "set_power"
				sendingData['params'] = {"off", YEELIGHT.effect, YEELIGHT.duration}
			elseif(command == 'Random Color')then
				local hval = math.floor(math.random()*359)
				sendingData['method'] = 'set_hsv'
				sendingData['params'] = {hval, 100, YEELIGHT.effect, YEELIGHT.duration}
			end
			if(sendingData['method'] ~= '')then
				YEELIGHT.send(sendingData.method, sendingData.params, tParam)
			end

			YEELIGHT._isRun = true
			YEELIGHT.keepAlive()
		end
	else
		print('State: offline -> connect to '..YEELIGHT.address)
		YEELIGHT.connect()
		Timer['waitOnline'] = 0
		Timer['waitOnline'] = Model.AddTimer(Timer['waitOnline'], 2, 'SECONDS', false)
	end
end



function EX_CMDS.setPower(params)
	if(params['state'])then
		local state = params['state']
		if state == 'on' then
			YEELIGHT._runMode = 'command'
			YEELIGHT.set('on')
		elseif state == 'off' then
			YEELIGHT._runMode = 'command'
			YEELIGHT.set('off')
		end
	end
end



function ExecuteCommand (strCommand, tParams)
    print("ExecuteCommand function called with : " .. strCommand)

    if EX_CMDS and type(EX_CMDS[strCommand]) == "function" then
            EX_CMDS[strCommand](tParams)
    elseif strCommand == "LUA_ACTION" then
        if tParams ~= nil then
            for cmd, cmdv in pairs(tParams) do
                print (cmd,cmdv)
                if cmd == "ACTION" then
                    if ACTIONS and type(ACTIONS[cmdv]) == "function" then
                        ACTIONS[cmdv](tParams)
                    else
                        print("From ExecuteCommand Function - Undefined Action")
                        print("Key: " .. cmd .. " Value: " .. cmdv)
                    end
                else
                    print("From ExecuteCommand Function - Undefined ACTION")
                    print("Key: " .. cmd .. " Value: " .. cmdv)
                end
            end
        end
    end
end




function OnDriverLateInit()
	Model.KillTimer()
	Timer['syncState'] = Model.AddTimer(Timer['syncState'], 5, 'SECONDS', true)
	YEELIGHT.address = Properties['Local IP'] or '192.168.1.106'
	YEELIGHT.effect = Properties['Effect'] or 'smooth'
	YEELIGHT.duration = tonumber(Properties['Duration']) or 500
end





function OnDriverDestroyed()
	C4:DestroyServer()
	Model.KillTimer()
end



function OnPropertyChanged (strProperty)
	local value = Properties[strProperty]
	if (strProperty == "Send Command") then
		YEELIGHT._runMode = 'command'
		if(value == 'Light On')then
			YEELIGHT.set('on')
		elseif value == 'Light Off'then
			YEELIGHT.set('off')
		else
			YEELIGHT.set(value)
		end
	elseif strProperty == 'Local IP' then
		YEELIGHT.address = value
	elseif strProperty == 'Effect' then
		YEELIGHT.effect = value
	elseif strProperty == 'Duration' then
		YEELIGHT.duration = tonumber(value)
	end
end



function OnConnectionStatusChanged(idBinding, nPort, strStatus)
	YEELIGHT._state = strStatus
	if (idBinding == 6001) then
    	if (strStatus == "ONLINE") then
			print('Yee ONLINE')
			YEELIGHT.set()
		else
			print('OFFLINE')
		end
  	end
end


-- received Data: {"method":"props","params":{"power":"on"}}
function ReceivedFromNetwork(idBinding, nPort, strData)
	if (idBinding == 6001) then
		print('received Data: '..strData)

		local state = C4:JsonDecode(strData)
		local id = state['id']
		local method = state['method']
		local result = state['result']
		if(result)then	
			for k, v in pairs(YEELIGHT.last_send) do
				if(YEELIGHT['last_send'][k]['id'] == id)then
					if result[1] == 'ok' then
						if(YEELIGHT['last_send'][k]['command'])then
							local cmd = YEELIGHT['last_send'][k]['command']
							if(cmd == 'on' or cmd == 'off')then
								YEELIGHT.syncProp('power', YEELIGHT['last_send'][k]['command'])
							end
						end
					end
					if(YEELIGHT['last_send'][k]['prop'])then
						for k1, v1 in pairs(YEELIGHT['last_send'][k]['prop']) do
							YEELIGHT.syncProp(YEELIGHT['last_send'][k]['prop'][k1], result[k1])
						end
					end
					table.remove(YEELIGHT['last_send'], k)
					break
				end
			end
		end
		if method and method == 'props' and state['params'] then
			if state['params']['power'] then
				YEELIGHT.syncProp('power', state['params']['power'])
			end
			if state['params']['bright'] then
				YEELIGHT.syncProp('bright', state['params']['bright'])
			end
			if state['params']['hue'] then
				YEELIGHT.syncProp('hue', state['params']['hue'])
			end
		end
		YEELIGHT.keepAlive()
	end
end



function OnTimerExpired(idTimer)

	if (idTimer == Timer['syncState'] and YEELIGHT._isRun == false) then
		RUN_MODE = 'sync'
		YEELIGHT.getProp('all')
	elseif idTimer == Timer['disconnect'] then
		Model.KillTimer(Timer['disconnect'])
		YEELIGHT.disconnect()
	elseif idTimer == 'waitOnline' then
		Model.KillTimer(Timer['waitOnline'])
		YEELIGHT.set()
	end

end



function Model.AddTimer(timer, count, units, recur)
	local newTimer
	if (recur == nil) then recur = false end
	if (timer and timer ~= 0) then Model.KillTimer(timer) end
	newTimer = C4:AddTimer (count, units, recur)
	return newTimer
end


function Model.KillTimer (timer)
	if (timer and type (timer) == 'number') then
		return (C4:KillTimer (timer))
	else
		return (0)
	end
end




--[[
function GetState()
	SID = SID + 1
	CHECK_ID['power'] = SID
	C4:SendToNetwork(6001, 55443, '{"id":'..SID..',"method":"get_prop","params":["power"]}\r\n')
	SID = SID + 1
	CHECK_ID['bright'] = SID
	C4:SendToNetwork(6001, 55443, '{"id":'..SID..',"method":"get_prop","params":["bright"]}\r\n')
end

function SetState(pr, stt)
	if(pr == "power")then
		C4:UpdateProperty("State", stt)
		if(stt == "off")then
			C4:SetPropertyAttribs('Bright', 1)
		else
			C4:SetPropertyAttribs('Bright', 0)
		end
	elseif (pr == "bright") then
		C4:UpdateProperty("Bright", stt)
	end
end
]]