SID = 0
LID = 0

CHECK_ID = {
	power = 0,
	bright = 0
}

IS_RUN = false
RUN_MODE = ''

Model = {}
Timer = {}



function OnDriverLateInit()
	Model.KillTimer()
	Timer['syncState'] = Model.AddTimer(Timer['syncState'], 2, 'SECONDS', true)

end



function OnDriverDestroyed()
	C4:DestroyServer()
	Model.KillTimer()
end



function OnPropertyChanged (strProperty)
	local value = Properties[strProperty]
	if (strProperty == "Set Power") then
		if(value == "toggle")then
			C4:SetPropertyAttribs("Effect", 1)
			C4:SetPropertyAttribs("Duration", 1)
		else
			C4:SetPropertyAttribs("Effect", 0)
			C4:SetPropertyAttribs("Duration", 0)
		end
	elseif (strProperty == "Effect") then
		if(value == "sudden")then
			C4:SetPropertyAttribs("Duration", 1)
		else
			C4:SetPropertyAttribs("Duration", 0)
		end
	elseif (strProperty == "Send Command") then
		RUN_MODE = 'command'
		Yee()
	end
end



function OnConnectionStatusChanged(idBinding, nPort, strStatus)
  if (idBinding == 6001) then
    if (strStatus == "ONLINE") then
		print('Yee ONLINE')
		if (RUN_MODE == 'command') then
			if(Properties["Set Power"] ~= "toggle")then
				SID = SID + 1
				LID = SID
				C4:SendToNetwork(6001, 55443, '{"id":'..SID..',"method":"set_power","params":["'..Properties["Set Power"]..'", "'..Properties["Effect"]..'", "'..Properties["Duration"]..'"]}\r\n')
			else
				SID = SID + 1
				LID = SID
				C4:SendToNetwork(6001, 55443, '{"id":'..SID..',"method":"set_power","params":["toggle"]}\r\n')
			end
			IS_RUN = true
		elseif (RUN_MODE == 'sync') then
			GetState()
		end
	else
		print('OFFLINE')
	end
  end
end


function ReceivedFromNetwork(idBinding, nPort, strData)
	if (idBinding == 6001) then
		print(strData)

		local state = C4:JsonDecode(strData)
		local id = state['id']
		local result = state['result']
		if(result)then
			result = result[1]
		end
		if(id == CHECK_ID['power'])then
			SetState('power', tostring(result))
			CHECK_ID['power'] = 0
		elseif (id == CHECK_ID['bright']) then
			SetState('bright', tostring(result))
			CHECK_ID['bright'] = 0
		elseif (id == LID and result == "ok") then
			LID = 0
			GetState()
		end

		if(id and id ~= LID and CHECK_ID['power'] == 0 and CHECK_ID['bright'] == 0)then
			C4:NetDisconnect(6001, 55443)
			IS_RUN = false
			RUN_MODE = ''
		end
	end
end



function OnTimerExpired(idTimer)

	if (idTimer == Timer['syncState'] and IS_RUN == false) then
		RUN_MODE = 'sync'
		Yee()
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


function Yee()
	local tPortParams = {
		SUPPRESS_CONNECTION_EVENTS = true,
		AUTO_CONNECT = true,
		MONITOR_CONNECTION = true,
		KEEP_CONNECTION = true,
		KEEP_ALIVE = true,
		DELIMITER = "0d0a"
	} 
	C4:CreateNetworkConnection (6001, '192.168.1.109', "TCP")
	C4:NetPortOptions(6001, 55443, "TCP", tPortParams)
	C4:NetConnect(6001, 55443)
end


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