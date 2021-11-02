MAX_CON = 3
NUMBER_COMMAND = 3
COMMAND = {'OPEN', 'CLOSE', 'STOP'}

Model = {}
Current = {}
Timer = {}

Channel = {
	RCM2 = {
		NoC = 2,
		Con1 = {
			MM = {1, 2, 3, 4},
			DM = {1, 2, 3}
		},
		Con2 = {
			MM = {5, 6, 7, 8},
			DM = {5, 6, 7}
		},
	},
	RCM3 = {
		NoC = 3,
		Con1 = {
			MM = {1, 2, 3, 4},
			DM = {1, 2, 3}
		},
		Con2 = {
			MM = {5, 6, 7, 8},
			DM = {5, 6, 7}
		},
		Con3 = {
			MM = {9, 10, 11, 12},
			DM = {9, 10, 11}
		}
	}
}

function table_to_string(tbl)
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


function Model.boardInit(model)
	if (Channel[model] ~= nil) then
		local n = Channel[model]['NoC']
		for i=1,n,1 do
			C4:SetPropertyAttribs('Con'..i, 0)
			C4:SetPropertyAttribs('Con'..i..' Channel', 0)
		end
		if (n ~= MAX_CON) then
			for i=n+1,MAX_CON,1 do
				C4:SetPropertyAttribs('Con'..i, 1)
				C4:SetPropertyAttribs('Con'..i..' Channel', 1)
			end
		end
	end
	Model.change()
end

function Model.change()
	Current = {}
	local model = Properties['Model']
	local n = Channel[model]['NoC']
	Current['Model'] = model
	Current['NoC'] = n
	for i=1, n, 1 do
		local c = 'Con'..i
		local cc = 'Con'..i..' Channel'
		Model[c] = Properties[c]
		for k, v in pairs(Channel[model][c][Model[c]]) do
			Current['C'..v] = model..','..c..','..Model[c]..','
		end
		C4:UpdateProperty (cc, 'Channel '..table.concat(Channel[model][c][Model[c]], ', '))
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
		Model['Con'..i] = Properties['Con'..i]
	end
	Model.boardInit()
	Model.change()

	--  check connection interval
	Timer['CheckConnection'] = Model.AddTimer (Timer['CheckConnection'], 10, 'SECONDS', true)
	Timer['Test'] = Model.AddTimer (Timer['Test'], 10, 'SECONDS', true)

end


function OnPropertyChanged (strProperty)
	local value = Properties [strProperty]

	if (strProperty == "Model") then
		Model.boardInit(value)
	elseif (string.match(strProperty, '^Con?%d+$')) then
        Model.change()
    elseif (strProperty == 'Check Connection') then
		CheckConnection()
		C4:UpdateProperty (strProperty, ' ')
	end
end


function GetState(st)
	for k, v in pairs(COMMAND) do
		if(st == k-1) then
			return v
		end
	end
end


function GetChannel(id)
	local i = 1 -- channel
	local k = 2 -- id binding
	local ch = nil
	local state = nil
	while ch == nil do
		for j = 0, NUMBER_COMMAND-1, 1 do
			if (k+j == id) then
                ch = 'C'..i
				state = GetState(j)
                break
            end
		end
		k = k + NUMBER_COMMAND
        i = i + 1
	end
	return ch..','..state
end




IsConnected = false
function CheckConnection()
	--  send to serial and listen from arduino
	-- C4:SendToSerial(1, str)	
	if(IsConnected == true)then
		IsConnected = false
		C4:UpdateProperty ('Connection', 'Not Connected')
	else 
		IsConnected = true
		C4:UpdateProperty ('Connection', 'Connected')
	end

end







function OnTimerExpired (idTimer)

	if (idTimer == Timer['CheckConnection']) then
		CheckConnection()
	elseif (idTimer == Timer['Test']) then
		C4:SendToProxy(999, 'Hello World', {})
	end

end





















function ReceivedFromSerial(idBinding, strData)
	
	print("Recieved Serial Data: " .. strData)
	if(tonumber(string.sub(strData,3,3)) == 1) then --opened
		C4:SendToProxy(tonumber(string.sub(strData,1,2)),"OPENED",{}, "NOTIFY")
	elseif(tonumber(string.sub(strData,3,3)) == 0) then --close
		C4:SendToProxy(tonumber(string.sub(strData,1,2)),"CLOSED",{}, "NOTIFY")
	end

	-- receive from arduino
	--  function()
	
  --[[[
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
]]--
end



function ReceivedFromProxy (idBinding, strCommand, tParams)
    
    print("Received From Proxy [" .. idBinding .. "]: " .. strCommand)
	if (tParams ~= nil) then
		for ParamName, ParamValue in pairs(tParams) do
			print(ParamName, ParamValue)
		end
	end

	local ch = GetChannel(idBinding)
	if(Current[string.match(ch, '^C%d')] ~= nil and strCommand == 'CLOSE') then
		print('Send to Serial: '..Current[string.match(ch, '^C%d')]..ch)
	end
	
end















































--[[



<actions>
	<action>
	<name>Check Connection</name>
	<command>CheckConnection</command>
	</action>
</actions>






EX_CMD = {}
LUA_ACTION = {}

function ExecuteCommand(sCommand, tParams)
	print(sCommand)

	-- Remove any spaces (trim the command)
	local trimmedCommand = string.gsub(sCommand, " ", "")
	local status, err
	-- if function exists then execute (non-stripped)
	if (EX_CMD[sCommand] ~= nil and type(EX_CMD[sCommand]) == "function") then
		status, err = pcall(EX_CMD[sCommand], tParams)
	-- elseif trimmed function exists then execute
	elseif (EX_CMD[trimmedCommand] ~= nil and type(EX_CMD[trimmedCommand]) == "function") then
		status, err = pcall(EX_CMD[trimmedCommand], tParams)
	elseif (EX_CMD[sCommand] ~= nil) then
		QueueCommand(EX_CMD[sCommand])
		status = true
	else
		status = true
	end

end

function EX_CMD.LUA_ACTION(tParams)

	if (tParams ~= nil) then
		for cmd, cmdv in pairs(tParams) do
			if (cmd == "ACTION" and cmdv ~= nil) then
				local status, err = pcall(LUA_ACTION[cmdv])
			end
		end
	end
end

function LUA_ACTION.CheckConnection()
	CheckConnection()
end


]]--