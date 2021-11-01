DRIVER_VERSION = '1.0.2.19'

MAX_CON = 3 -- Maximum number of physical connector
START_ID = 2 -- Dynamic Binding id start from
IS_CONNECTED = false -- Is C4 and Arduino working well

COMMAND_DELAY = Properties['Command Delay Time'] or 100 -- Time delay between sending commands
DEBUG_MODE = Properties['Debug Mode'] or 'OFF' -- Debug mode: ON and OFF

Model = {} -- Contains functions and board type of each CON\

Current = {} -- Contains data for current setting
Current.ID = {} -- List of IDs used

Timer = {} -- Contains all timer
SEND_COMMAND = {} -- Contains commands waiting to be sent

Channel = {
	RCM64V1 = {
		CON1 = {
			MM = {
				CHANNEL = {1, 2, 3, 4, 5, 6, 7, 8},
				NUMBER_COMMAND = 2,
				COMMAND = {'OPEN', 'CLOSE'},
				COMMAND_LABEL = {'UP', 'DOWN'}
			},
			DM = {
				CHANNEL = {1, 2, 3, 4, 5, 6, 7, 8},
				NUMBER_COMMAND = 3,
				COMMAND = {'OPEN', 'CLOSE', 'STOP'},
				COMMAND_LABEL = {'UP', 'DOWN', 'STOP'}
			}
		},
		CON2 = {
			MM = {
				CHANNEL = {1, 2, 3, 4, 5, 6, 7, 8},
				NUMBER_COMMAND = 2,
				COMMAND = {'OPEN', 'CLOSE'},
				COMMAND_LABEL = {'UP', 'DOWN'}
			},
			DM = {
				CHANNEL = {1, 2, 3, 4, 5, 6, 7, 8},
				NUMBER_COMMAND = 3,
				COMMAND = {'OPEN', 'CLOSE', 'STOP'},
				COMMAND_LABEL = {'UP', 'DOWN', 'STOP'}
			}
		},
		CON3 = {
			MM = {
				CHANNEL = {1, 2, 3, 4, 5, 6, 7, 8},
				NUMBER_COMMAND = 2,
				COMMAND = {'OPEN', 'CLOSE'},
				COMMAND_LABEL = {'UP', 'DOWN'}
			},
			DM = {
				CHANNEL = {1, 2, 3, 4, 5, 6, 7, 8},
				NUMBER_COMMAND = 3,
				COMMAND = {'OPEN', 'CLOSE', 'STOP'},
				COMMAND_LABEL = {'UP', 'DOWN', 'STOP'}
			}
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
            result = result..PrintTable(v)
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




-- Print Debug
function DBG(str)
	if(DEBUG_MODE == 'ON')then
		if(type(str) == 'table')then
			print(PrintTable(str))
		else
			print(str)
		end
	end
end




-- Splits the string that received from Serial into the specified form
-- Output: Table of commands
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







-- Check if the table is empty
function IsTableEmpty(d)
	local isEmpty = true
	if(d ~= nil)then
		for k,v in pairs(d) do
			isEmpty = false
			break
		end
	end
    return isEmpty
end







-- ID generator function
-- type: type of connection,
-- id: channel id,
-- stid: state id,
function Current.ID.genID(type, id, stid)
	local validID = false
	local startID = START_ID
	while validID == false do
		if(IsTableEmpty(Current['ID'][startID]) == false)then
			startID = startID + 1
		else
			validID = true
			Current.ID.addID(type, startID, id, stid)
			return startID
		end
		-- Fail safe
		if startID > 900 then
			validID = true
			Current.ID.addID(type, 999, id, stid)
			return 999
		end
	end
end

function Current.ID.addID(type, idnum, id, stid)
	Current['ID'][idnum] = {
		ID = id,
		STATE_ID = stid,
		TYPE = type
	}
end

function Current.ID.removeID(idnum)
	Current['ID'][idnum] = {}
end






-- Send commands to Serial and delay COMMAND_DELAY milliseconds of each command
function SendCommand(cmdstr)
	table.insert(SEND_COMMAND, cmdstr)
	if(Timer['SendCommand'] == nil or Timer['SendCommand'] == 0)then
		Timer['SendCommand'] = Model.AddTimer(Timer['SendCommand'], COMMAND_DELAY, 'MILLISECONDS', true)
	end
end






-- Show the CONs that belong to this model and hide the rest
function Model.boardInit(model)
	if (Channel[model] ~= nil) then
		local n  = 0
		-- show
		for k, v in pairs(Channel[model]) do
			C4:SetPropertyAttribs(k, 0)
			n = n+1
		end
		-- hide
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

	-- Remove all connections
	--[[
	for k,v in pairs(Current) do
		if (v) then
			for k1, v1 in pairs(Current[k]['ID']) do
				C4:RemoveDynamicBinding(v1)
			end
		end
	end
	]]--

	-- Current = {}
	local model = Properties['Model']
	for k, v in pairs(Channel[model]) do
		Model[k] = Properties[k]
		if(Model[k] == 'NOT USE')then
			-- remove connections
			for k1,v1 in pairs(Current) do
				if (Current[k1]['ID'] and string.match(k1, '^'..k..',C?%d+$')) then
					for k2, v2 in pairs(Current[k1]['ID']) do
						C4:RemoveDynamicBinding(v2)
						Current.ID.removeID(v2)
					end
					Current[k1] = {}
				end
			end
		else	
			for k1, v1 in pairs(Channel[model][k][Model[k]]['CHANNEL']) do
				local cID = k..',C'..v1
				if(Current[cID])then
					if(Current[cID]['MODEL'] and Current[cID]['MODEL'] ~= Model[k])then
						-- Remove connections
						if (Current[cID]['ID']) then
							for k2, v2 in pairs(Current[cID]['ID']) do
								C4:RemoveDynamicBinding(v2)
								Current.ID.removeID(v2)
							end
						end
						Current[cID] = {}
					end
				end
				if(not Current[cID] or IsTableEmpty(Current[cID]) == true)then
					Current[cID] = {}
					Current[cID] = {
						MODEL = Model[k],
						DATA =  model..','..Model[k]..','..k..',',
						LAST_SEND = "OPEN",
						STATE = {},
						ID = {}
					}
					for i=1, Channel[model][k][Model[k]]['NUMBER_COMMAND'], 1 do
						local start_id = Current.ID.genID('OUTPUT', cID, i)
						C4:AddDynamicBinding(start_id, "CONTROL", true, k..' - Channel '..v1..' - '..Channel[model][k][Model[k]]['COMMAND_LABEL'][i], "RELAY", false, false)
						table.insert(Current[cID]['ID'], start_id)
						table.insert(Current[cID]['STATE'], 'C'..v1..','..Channel[model][k][Model[k]]['COMMAND'][i])
					end
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




function OnDriverInit()
	C4:UpdateProperty ('Driver Version', DRIVER_VERSION)
end






function OnDriverLateInit ()
	Model.KillTimer()
	for i=1,MAX_CON,1 do
		Model['CON'..i] = Properties['CON'..i]
	end
	Model.boardInit(Properties['Model'])

	--  check connection interval
	-- Timer['CheckConnection'] = Model.AddTimer (Timer['CheckConnection'], 45, 'SECONDS', true)
	Timer['SendCommand'] = Model.AddTimer(Timer['SendCommand'], COMMAND_DELAY, 'MILLISECONDS', true)
end


function OnPropertyChanged (strProperty)
	local value = Properties[strProperty]

	if (strProperty == "Model") then
		Model.boardInit(value)
	elseif (string.match(strProperty, '^CON?%d+$')) then
        Model.change()
    elseif (strProperty == 'Check Connection') then
		CheckConnection()
	elseif (strProperty == 'Send Command') then
		SendCommand(value)
	elseif (strProperty == 'Command Delay Time') then
		COMMAND_DELAY = value
	elseif (strProperty == 'Debug Mode') then
		DEBUG_MODE = value
	end
end






function CheckConnection()
	if(SEND_COMMAND[1] == nil)then
		IS_CONNECTED = false
		C4:UpdateProperty ('Connection', 'CHECKING')
		SendCommand('<CHECK_CONNECTION>')
		Timer['CheckConnection'] = Model.AddTimer (Timer['CheckConnection'], 30, 'SECONDS')
		Timer['CheckConnectionFail'] = Model.AddTimer (Timer['CheckConnectionFail'], 3, 'SECONDS')
	end
end






function OnTimerExpired (idTimer)

	if (idTimer == Timer['CheckConnection']) then
		C4:UpdateProperty ('Connection', 'NOT CHECK')
		--[[if(IS_CONNECTED == false)then
			C4:UpdateProperty ('Connection', 'NOT CHECK')
		end]]--
		-- CheckConnection()
	elseif (idTimer == Timer['SendCommand']) then
		if(SEND_COMMAND[1] ~= nil)then
			DBG('Send to Serial: '..SEND_COMMAND[1])
			C4:SendToSerial(1,SEND_COMMAND[1]..'\n')
			table.remove(SEND_COMMAND, 1)
		else
			Timer['SendCommand'] = Model.KillTimer(Timer['SendCommand'])
		end
	elseif (idTimer == Timer['CheckConnectionFail']) then
		if(IS_CONNECTED == false)then
			C4:UpdateProperty ('Connection', 'NOT CONNECTED')
		end
	end
end




function ReceivedFromSerial(idBinding, strData)
	DBG("Recieved Serial Data: " .. idBinding .. ", " .. strData)

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
    
    DBG("Received From Proxy [" .. idBinding .. "]: " .. strCommand)
	if (tParams ~= nil) then
		for ParamName, ParamValue in pairs(tParams) do
			DBG(ParamName..': '..ParamValue)
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
				break
			end
		end
		

		--[[
		if(IsTableEmpty(Current['ID'][idBinding]) == false)then
			local cID = Current['ID'][idBinding]['ID']
			local stid = Current['ID'][idBinding]['STATE_ID']
			local state = Current[cID]['STATE'][stid]
			local data = Current[cID]['DATA']

			if(state ~= nil and data ~= nil and strCommand ~= Current[cID]['LAST_SEND'])then
				if(strCommand == "OPEN")then
					Current[cID]['LAST_SEND'] = "OPEN"
					local c = string.match(state, '^C%d')
					local data2send = '<'..data..c..',NONE'..'>'
					SendCommand(data2send)
				elseif (strCommand == "CLOSE") then
					Current[cID]['LAST_SEND'] = "CLOSE"
					local data2send = '<'..data..state..'>'
					SendCommand(data2send)
				end
			end

		end
		]]--

	end
	
end