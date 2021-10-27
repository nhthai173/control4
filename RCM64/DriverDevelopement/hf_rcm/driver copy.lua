MAX_CON = 3 -- Maximum number of physical connector
NUMBER_COMMAND = 3
COMMAND = {'OPEN', 'CLOSE', 'STOP'}
COMMAND_LABEL = {'UP', 'DOWN', 'STOP'}
START_ID = 2
IS_CONNECTED = false
COMMAND_DELAY = Properties['Command Delay Time'] or 100

Model = {}
Current = {}
Timer = {}
SEND_COMMAND = {}

Channel = {
	RCM64V1 = {
		CON1 = {
			MM = {1, 2, 3, 4, 5, 6, 7, 8},
			DM = {1, 2, 3, 4, 5, 6, 7, 8}
		},
		CON2 = {
			MM = {1, 2, 3, 4, 5, 6, 7, 8},
			DM = {1, 2, 3, 4, 5, 6, 7, 8}
		},
		CON3 = {
			MM = {1, 2, 3, 4, 5, 6, 7, 8},
			DM = {1, 2, 3, 4, 5, 6, 7, 8}
		}
	}
}





-- print table (for debug mode)
function PrintTable(tbl)
    local result = "{"
    for k, v in pairs(tbl) do
        -- Check the key type (ignore any numerical keys - assume its an array)
        if type(k) == "string" then
            result = result.."[\""..k.."\"]".."="
        end

        -- Check the value type
        if type(v) == "table" then
            result = result..table_to_string(v)
        elseif type(v) == "boolean" then
            result = result..tostring(v)
        else
            result = result.."\""..v.."\""
        end
        result = result..","
    end
    -- Remove leading commas from the result
    if result ~= "" then
        result = result:sub(1, result:len()-1)
    end
    return result.."}"
end






function SplitString (inputstr, sep)
	if sep == nil then
		sep = ","
	end
	local t={}
	inputstr = string.match(inputstr, "([^<]+)([>$]+)")
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end






function SendCommand(cmdstr)
	table.insert(SEND_COMMAND, cmdstr)
	if(Timer['SendCommand'] == nil or Timer['SendCommand'] == 0)then
		Timer['SendCommand'] = Model.AddTimer(Timer['SendCommand'], 100, 'MILLISECONDS', true)
	end
end






-- Show the model CON and hide the rest
function Model.boardInit(model)
	if (Channel[model] ~= nil) then
		local n  = 0
		for k, v in pairs(Channel[model]) do
			C4:SetPropertyAttribs(k, 0)
			n = n+1
		end
		if (n ~= MAX_CON) then
			for i=n+1,MAX_CON,1 do
				C4:SetPropertyAttribs('CON'..i, 1)
			end
		end
	end
	Model.change()
end



-- On Property Changed
function Model.change()
	for k,v in pairs(Current) do
		if (v) then
			for i=1, NUMBER_COMMAND, 1 do
				C4:RemoveDynamicBinding(Current[k]['ID'][i])
			end
		end
	end
	Current = {}
	local start_id = START_ID
	local model = Properties['Model']
	for k, v in pairs(Channel[model]) do
		Model[k] = Properties[k]
		if(Model[k] ~= "NOT USE")then
			for k1, v1 in pairs(Channel[model][k][Model[k]]) do
				Current[k..',C'..v1] = {
					DATA =  model..','..Model[k]..','..k..',',
					LAST_SEND = "OPEN",
					STATE = {},
					ID = {}
				}
				for i=1, NUMBER_COMMAND, 1 do
					C4:AddDynamicBinding(start_id, "CONTROL", true, k..' - Channel '..v1..' - '..COMMAND_LABEL[i], "RELAY", false, false)
					table.insert(Current[k..',C'..v1]['ID'], start_id)
					table.insert(Current[k..',C'..v1]['STATE'], 'C'..v1..','..COMMAND[i])
					start_id = start_id + 1
				end
			end
		end
	end
end



function Model.AddTimer(timer, count, units, recur)
	local newTimer
	if (recur == nil) then recur = false end
	if (timer and timer ~= 0) then Model.KillTimer (timer) end
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


function OnDriverDestroyed ()
	C4:DestroyServer ()
	Model.KillTimer()
end


function OnDriverLateInit ()
	Model.KillTimer()
	for i=1,MAX_CON,1 do
		Model['CON'..i] = Properties['CON'..i]
	end
	Model.boardInit(Properties['Model'])

	--  check connection interval
	Timer['CheckConnection'] = Model.AddTimer (Timer['CheckConnection'], 10, 'SECONDS', true)
	Timer['SendCommand'] = Model.AddTimer(Timer['SendCommand'], 100, 'MILLISECONDS', true)
end


function OnPropertyChanged (strProperty)
	local value = Properties [strProperty]

	if (strProperty == "Model") then
		Model.boardInit(value)
	elseif (string.match(strProperty, '^CON?%d+$')) then
        Model.change()
    elseif (strProperty == 'Check Connection') then
		CheckConnection()
		C4:UpdateProperty (strProperty, ' ')
	elseif (strProperty == 'Send Command') then
		SendCommand(value)
	elseif (strProperty == 'Command Delay Time') then
		COMMAND_DELAY = value
		PrintTable(SEND_COMMAND)
	end
end






function CheckConnection()
	IS_CONNECTED = false
	SendCommand('<CHECK_CONNECTION>')
end




function OnTimerExpired (idTimer)

	if (idTimer == Timer['CheckConnection']) then
		if(IS_CONNECTED == false)then
			C4:UpdateProperty ('Connection', 'NOT CONNECTED')
		end
		CheckConnection()
	elseif (idTimer == Timer['SendCommand']) then
		if(SEND_COMMAND[1] ~= nil)then
			print('Send to Serial: '..SEND_COMMAND[1])
			C4:SendToSerial(1,SEND_COMMAND[1])
			table.remove(SEND_COMMAND, 1)
		else
			Timer['SendCommand'] = Model.KillTimer(Timer['SendCommand'])
		end
	end
end




function ReceivedFromSerial(idBinding, strData)
	print("Recieved Serial Data: " .. idBinding .. ", " .. strData)

	local serialData = SplitString(strData)
	if(serialData[1] == 'CHECK_CONNECTION' and serialData[2] ~= nil)then
		C4:UpdateProperty ('Connection', 'CONNECTED')
		IS_CONNECTED = true
	end

end


--[[
function ReceivedFromSerial(idBinding, strData)
	
	print("Recieved Serial Data: " .. strData)
	if(tonumber(string.sub(strData,3,3)) == 1) then --opened
		C4:SendToProxy(tonumber(string.sub(strData,1,2)),"OPENED",{}, "NOTIFY")
	elseif(tonumber(string.sub(strData,3,3)) == 0) then --close
		C4:SendToProxy(tonumber(string.sub(strData,1,2)),"CLOSED",{}, "NOTIFY")
	end

	-- receive from arduino
	--  function()
	
  print(" Data received is: " .. strData)
  
  print("Type is:")
  print(type(strData))
  	if(tonumber(string.sub(strData,1,1)) == 1) then
		if (tonumber(string.sub(strData,2,2) == 1)) then
				State1 = "ON"
        print (State1)
		elseif (tonumber(string.sub(strData,2,2) == 0)) then
				State1 = "OFF"
		end
	elseif (tonumber(string.sub(strData,1,1)) == 2) then
		if (tonumber(string.sub(strData,2,2) == 1)) then
				State2 = "ON"
        print (State2)
		elseif (tonumber(string.sub(strData,2,2) == 0)) then
				State2 = "OFF"
		end
	end
end
]]--





function ReceivedFromProxy (idBinding, strCommand, tParams)
    
    print("Received From Proxy [" .. idBinding .. "]: " .. strCommand)
	if (tParams ~= nil) then
		for ParamName, ParamValue in pairs(tParams) do
			print(ParamName, ParamValue)
		end
	end

	if(idBinding > 1)then
		
		for k, v in pairs(Current) do
			local state = nil
			for k1, v1 in pairs(Current[k]['ID']) do
				if (idBinding == v1)then
					state = Current[k]['STATE'][k1]
					break
				end
			end
			if(state ~= nil and Current[k]['DATA'] ~= nil and strCommand ~= Current[k]['LAST_SEND'])then
				if(strCommand == "OPEN")then
					Current[k]['LAST_SEND'] = "OPEN"
					local c = string.match(state, '^C%d')
					local data2send = '<'..Current[k]['DATA']..c..',NONE'..'>'
					SendCommand(data2send)
				elseif (strCommand == "CLOSE") then
					Current[k]['LAST_SEND'] = "CLOSE"
					local data2send = '<'..Current[k]['DATA']..state..'>'
					SendCommand(data2send)
				end
			end
		end

	end
	
end