DRIVER_VERSION = '3.0 Beta 1'
FIRMWARE_VERSION = 'NOT FOUND'

MAX_CON = 3 -- Maximum number of physical connector
START_ID = 2 -- Dynamic Binding id start from
IS_CONNECTED = false -- Is C4 and Arduino working well

-- COMMAND_DELAY = Properties['Command Delay Time'] or 100
COMMAND_DELAY = 100 -- group delay
SEND_COMMAND_DELAY = 500 -- Time delay between sending commands
DEBUG_MODE = Properties['Debug Mode'] or 'OFF' -- Debug mode: ON and OFF

Model = {} -- Contains functions and board type of each CON\

Current = {} -- Contains data for current setting
Current.ID = {} -- List of IDs used
Current['RM_BOARD'] = {}

Timer = {} -- Contains all timer
SEND_COMMAND = {} -- Contains commands waiting to be sent

Channel = {
	RCM64V1 = {
		INPUT = {
			USE = {"ZONE1", "ZONE2", "ZONE3", "ZONE4", "ZONE5", "ZONE6", "ZONE7", "ZONE8", "ZONE9", "ZONE10", "ZONE11", "ZONE12"}
		},
		CON1 = {
			MM = {
				CHANNEL = {1, 2, 3, 4, 5, 6, 7, 8},
				NUMBER_COMMAND = 2,
				COMMAND = {'OPEN', 'CLOSE'},
				COMMAND_LABEL = {'- UP', '- DOWN'}
			},
			DM = {
				CHANNEL = {1, 2, 3, 4, 5, 6, 7, 8},
				NUMBER_COMMAND = 3,
				COMMAND = {'OPEN', 'CLOSE', 'STOP'},
				COMMAND_LABEL = {'- UP', '- DOWN', '- STOP'}
			},
			RM = {
				CHANNEL = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16},
				NUMBER_COMMAND = 1,
				COMMAND = {'TRIGGER'},
				COMMAND_LABEL = {''}
			}
		},
		CON2 = {
			MM = {
				CHANNEL = {1, 2, 3, 4, 5, 6, 7, 8},
				NUMBER_COMMAND = 2,
				COMMAND = {'OPEN', 'CLOSE'},
				COMMAND_LABEL = {'- UP', '- DOWN'}
			},
			DM = {
				CHANNEL = {1, 2, 3, 4, 5, 6, 7, 8},
				NUMBER_COMMAND = 3,
				COMMAND = {'OPEN', 'CLOSE', 'STOP'},
				COMMAND_LABEL = {'- UP', '- DOWN', '- STOP'}
			},
			RM = {
				CHANNEL = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16},
				NUMBER_COMMAND = 1,
				COMMAND = {'TRIGGER'},
				COMMAND_LABEL = {''}
			}
		},
		CON3 = {
			MM = {
				CHANNEL = {1, 2, 3, 4, 5, 6, 7, 8},
				NUMBER_COMMAND = 2,
				COMMAND = {'OPEN', 'CLOSE'},
				COMMAND_LABEL = {'- UP', '- DOWN'}
			},
			DM = {
				CHANNEL = {1, 2, 3, 4, 5, 6, 7, 8},
				NUMBER_COMMAND = 3,
				COMMAND = {'OPEN', 'CLOSE', 'STOP'},
				COMMAND_LABEL = {'- UP', '- DOWN', '- STOP'}
			},
			RM = {
				CHANNEL = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16},
				NUMBER_COMMAND = 1,
				COMMAND = {'TRIGGER'},
				COMMAND_LABEL = {''}
			}
		}
	}
}





HARDWARE = {
	RCM64V1 = {
		INPUT = {
			I58 = "ZONE1",
            I59 = "ZONE2",
            I60 = "ZONE3",
            I61 = "ZONE4",
            I62 = "ZONE5",
            I63 = "ZONE6",
            I64 = "ZONE7",
            I65 = "ZONE8",
            I66 = "ZONE9",
            I67 = "ZONE10",
            I68 = "ZONE11",
            I69 = "ZONE12"
		},
		DM = {
            STATE = {
                CLOSE = {0, 0},
                STOP = {0, 1},
                OPEN = {1, 0},
                NONE = {1, 1}
            },
            RULE = {
                OPEN = {1, 2},
                CLOSE = {1, 2},
                STOP = {1, 2},
                NONE = {1, 2}
            },
            CON1 = {
                C1 = {31, 29},
                C2 = {33, 27},
                C3 = {35, 25},
                C4 = {37, 23},
                C5 = {39, 47},
                C6 = {41, 49},
                C7 = {43, 51},
                C8 = {45, 53}
            },
            CON3 = {
                C1 = {52, 22},
                C2 = {50, 24},
                C3 = {48, 26},
                C4 = {46, 28},
                C5 = {44, 30},
                C6 = {42, 32},
                C7 = {40, 34},
                C8 = {38, 36}
            },
            CON2 = {
                C1 = {5, 6},
                C2 = {4, 7},
                C3 = {3, 8},
                C4 = {2, 9},
                C5 = {54, 10},
                C6 = {55, 11},
                C7 = {56, 12},
                C8 = {57, 13}
            }
        },
		MM = {
            STATE = {
                OPEN = {0, 0},
                CLOSE = {1, 0},
                STOP = {1, 1},
                NONE = {1, 1}
            },
            RULE = {
                OPEN = {1, "DLY100", 2},
                CLOSE = {2, "DLY100", 1},
                STOP = {2, "DLY100", 1},
                NONE = {2, "DLY100", 1}
            },
            CON1 = {
                C1 = {31, 29},
                C2 = {33, 27},
                C3 = {35, 25},
                C4 = {37, 23},
                C5 = {39, 47},
                C6 = {41, 49},
                C7 = {43, 51},
                C8 = {45, 53}
            },
            CON3 = {
                C1 = {52, 22},
                C2 = {50, 24},
                C3 = {48, 26},
                C4 = {46, 28},
                C5 = {44, 30},
                C6 = {42, 32},
                C7 = {40, 34},
                C8 = {38, 36}
            },
            CON2 = {
                C1 = {5, 6},
                C2 = {4, 7},
                C3 = {3, 8},
                C4 = {2, 9},
                C5 = {54, 10},
                C6 = {55, 11},
                C7 = {56, 12},
                C8 = {57, 13}
            }
        },
		RM = {
            STATE = {
                TRIGGER = {0}
            },
            RULE = {
                TRIGGER = {1}
            },
            CON1 = {
                C1 = {31},
                C2 = {33},
                C3 = {35},
                C4 = {37},
                C5 = {39},
                C6 = {41},
                C7 = {43},
                C8 = {45},
				C9 = {29},
				C10 = {27},
				C11 = {25},
				C12 = {23},
				C13 = {47},
				C14 = {49},
				C15 = {51},
				C16 = {53}
            },
            CON3 = {
				C1 = {52},
                C2 = {50},
                C3 = {48},
                C4 = {46},
                C5 = {44},
                C6 = {42},
                C7 = {40},
                C8 = {38},
				C9 = {22},
				C10 = {24},
				C11 = {26},
				C12 = {28},
				C13 = {30},
				C14 = {32},
				C15 = {34},
				C16 = {36}
            },
            CON2 = {
				C1 = {5},
                C2 = {4},
                C3 = {3},
                C4 = {2},
                C5 = {54},
                C6 = {55},
                C7 = {56},
                C8 = {57},
				C9 = {6},
				C10 = {7},
				C11 = {8},
				C12 = {9},
				C13 = {10},
				C14 = {11},
				C15 = {12},
				C16 = {13}
            }
        }
	}
}





function PrintTable(tbl, tbtype)
    local result = ""
    local kc = 0
    local isArray = false
    
    for k, v in pairs(tbl) do
        kc = kc + 1
        if (type(k) == "string") then
            if kc == 1 then
                result = "{"..result    
            end
            result = result.."\""..k.."\""..":"
        elseif kc == 1 then
            result = "["..result
            isArray = true
        end
        if type(v) == "table" then
            result = result..PrintTable(v)
        elseif type(v) == "boolean" then
            result = result..tostring(v)
        elseif type(v) == "function" then
            result = result.."\"function\""
        elseif type(v) == "number" then
            result = result..tostring(v)
        elseif tbtype == "ARDUINO_COMMAND" then
            result = result..v
		else
			result = result.."\""..v.."\""
        end
        result = result..","
    end
    
    if result ~= "" then
        result = result:sub(1, result:len()-1)
        if isArray == false then
            result = result.."}"
        else
            result = result.."]"
        end
    end
    
    return result
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
		if(IsTableEmpty(Current['ID']['B'..startID]) == false)then
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
	if(type == 'OUTPUT')then
		Current['ID']['B'..idnum] = {
			ID = id,
			STATE_ID = stid,
			TYPE = type
		}
	elseif (type == 'INPUT') then
		Current['ID']['B'..idnum] = {
			ID = id,
			TYPE = type
		}
	end
end

function Current.ID.removeID(idnum)
	Current['ID']['B'..idnum] = {}
end






-- Send commands to Serial and delay COMMAND_DELAY milliseconds of each command
function SendCommand(cmdstr)
	table.insert(SEND_COMMAND, cmdstr)
	if(Timer['SendCommand'] == nil or Timer['SendCommand'] == 0)then
		Timer['SendCommand'] = Model.AddTimer(Timer['SendCommand'], COMMAND_DELAY, 'MILLISECONDS', true)
	end
end

-- After the COMMAND_DELAY period since SendCommand was run,
-- commands that have the same state (e.g. OPEN / CLOSE / STOP) from different channels from one or more different CONs will be grouped.
-- Note: commands are grouped only when they have the same model, type and state
function SendCommandGroup()

	if (FIRMWARE_VERSION ~= 'NOT FOUND') then
		if (tonumber(FIRMWARE_VERSION) >= 2) then
			
			if(SEND_COMMAND[1] ~= nil)then
				local tg = SplitString(SEND_COMMAND[1])
				local st = tg[5] -- state
				local model = tg[1]
				local type = tg[2] -- MM/DM/RM
				local o1c = true -- if those commands have the same model, state, type
				
				local gpin = {} -- group pins
				local gcom = {} -- group commands

				for k, v in pairs(SEND_COMMAND) do
					local tgg = SplitString(v)
					if(st ~= tgg[5] or model ~= tgg[1] or type ~= tgg[2])then
						o1c = false
						break
					end
				end

				if (o1c == true and SEND_COMMAND[2] ~= nil) then
					for k, v in pairs(HARDWARE[model][type]['RULE'][st]) do
						if (string.match(v, "DLY") == "DLY") then
							table.insert(gcom, v)
						else
							table.insert(gcom, HARDWARE[model][type]['STATE'][st][v])
						end
					end
					for k, v in pairs(SEND_COMMAND) do
						local tgg = SplitString(v)
    					table.insert(gpin, HARDWARE[tgg[1]][tgg[2]][tgg[3]][tgg[4]])
						DBG("Data to send: "..v)
					end
					SEND_COMMAND = {}
					SendCMD('<'..model..','..PrintTable(gpin)..','..PrintTable(gcom, "ARDUINO_COMMAND")..'>')
				elseif (model ~= nil and type ~= nil and st ~= nil) then
					-- not found group
					for k, v in pairs(HARDWARE[model][type]['RULE'][st]) do
						if (string.match(v, "DLY") == "DLY") then
							table.insert(gcom, v)
						else
							table.insert(gcom, HARDWARE[model][type]['STATE'][st][v])
						end
					end
					-- tg[3] : CON1,CON2,...
					-- tg[4] : C1,C2,...
					table.insert(gpin, HARDWARE[model][type][tg[3]][tg[4]])
					DBG("Data to send: "..SEND_COMMAND[1])
					SEND_COMMAND[1] = '<'..model..','..PrintTable(gpin)..','..PrintTable(gcom, "ARDUINO_COMMAND")..'>'
					SendCMD(SEND_COMMAND[1])
					table.remove(SEND_COMMAND, 1)
				end
			else
				Timer['SendCommand'] = Model.KillTimer(Timer['SendCommand'])
			end
			
		end
	else

		if(SEND_COMMAND[1] ~= nil)then
			local tg = SplitString(SEND_COMMAND[1])
			local st = tg[5]
			local model = tg[1]
			local type = tg[2]
			local o1c = true
			local gcom = {
				PORT = {}
			}
			for k, v in pairs(SEND_COMMAND) do
				local tgg = SplitString(v)
				if(st ~= tgg[5] or model ~= tgg[1] or type ~= tgg[2])then
					o1c = false
					break
				end
			end
			if (o1c == true and SEND_COMMAND[2] ~= nil) then
				for k, v in pairs(SEND_COMMAND) do
					local tgg = SplitString(v)
					local ccon = tgg[3]
					local cch = tgg[4]
					if (gcom[ccon])then
						table.insert(gcom[ccon], cch)
					else
						gcom[ccon] = {cch}
					end
				end
				for k, v in pairs(gcom) do
					if(k ~= 'PORT')then
						table.insert(gcom['PORT'], k)
					end
				end
				SEND_COMMAND = {}
				-- SendCommand('<'..model..','..type..','..C4:JsonEncode(gcom)..','..st..'>')
				SendCMD('<'..model..','..type..','..PrintTable(gcom)..','..st..'>')
			else -- not found group
				SendCMD(SEND_COMMAND[1])
				table.remove(SEND_COMMAND, 1)
			end
		else
			Timer['SendCommand'] = Model.KillTimer(Timer['SendCommand'])
		end

	end

end


-- currently not use
function SendCommandNGroup()
	if(SEND_COMMAND[1] ~= nil)then
		DBG('Send to Serial: '..SEND_COMMAND[1])
		C4:SendToSerial(1,SEND_COMMAND[1]..'\n')
		table.remove(SEND_COMMAND, 1)
	else
		Timer['SendCommandNoGroup'] = Model.KillTimer(Timer['SendCommandNoGroup'])
	end
end




function SendCMD(cmd)
	DBG('Send to Serial: '..cmd)
	C4:SendToSerial(1,cmd..'\n')
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
	local model = Properties['Model']
	for k, v in pairs(Channel[model]) do
		Model[k] = Properties[k]

		if(k == 'INPUT')then
			if(Model[k] == 'NOT USE')then
				Current['INPUT'] = Model[k]
				for k1, v1 in pairs(Current['ID']) do
					if(type(Current['ID'][k1]) == "table" and Current['ID'][k1]['TYPE'] == 'INPUT')then
						-- remove first letter "B"
						local idbd = tonumber(string.sub(k1, 2))
						C4:RemoveDynamicBinding(idbd)
						Current.ID.removeID(idbd)
					end
				end
			else
				for k1, v1 in pairs(Channel[model][k]) do
					if(v1 and (Current['INPUT'] == nil or Model[k] ~= Current['INPUT']) and k1 == Model[k])then
						Current['INPUT'] = Model[k]
						for k2, v2 in pairs(Current['ID']) do
							if(type(Current['ID'][k2]) == "table" and Current['ID'][k2]['TYPE'] == 'INPUT')then
								-- remove first letter "B"
								local idbd = tonumber(string.sub(k2, 2))
								C4:RemoveDynamicBinding(idbd)
								Current.ID.removeID(idbd)
							end
						end
						for k2, v2 in pairs(Channel[model][k][k1]) do
							local idbd = Current.ID.genID('INPUT', v2)
							C4:AddDynamicBinding(idbd, "CONTROL", true, v2, "CONTACT_SENSOR", false, false)
						end
						break
					end
				end
			end
		else
			if(Model[k] == 'NOT USE')then
				-- remove connections
				for k1,v1 in pairs(Current) do
					if (Current[k1]['ID'] and string.match(k1, '^'..k..',C%d*%d')) then
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
							C4:AddDynamicBinding(start_id, "CONTROL", true, k..' - Channel '..v1..' '..Channel[model][k][Model[k]]['COMMAND_LABEL'][i], "RELAY", false, false)
							table.insert(Current[cID]['ID'], start_id)
							table.insert(Current[cID]['STATE'], 'C'..v1..','..Channel[model][k][Model[k]]['COMMAND'][i])
						end
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

	local model = Properties['Model']
	for k, v in pairs(Channel[model]) do
		if(v)then
			local pList = ''
			for k1, v1 in pairs(Channel[model][k]) do
				if(type(k1) == 'string')then
					pList = pList..k1..','
				end
			end
			pList = pList..'NOT USE'
			C4:UpdatePropertyList(k, pList)
		end
	end

	CheckConnection()

end






function OnDriverLateInit ()
	Model.KillTimer()
	for i=1,MAX_CON,1 do
		Model['CON'..i] = Properties['CON'..i]
	end
	Model.boardInit(Properties['Model'])

	Timer['SendCommand'] = Model.AddTimer(Timer['SendCommand'], COMMAND_DELAY, 'MILLISECONDS', true)

	if (FIRMWARE_VERSION ~= Properties['Firmware Version']) then
		if (Properties['Firmware Version'] ~= "NOT FOUND") then
			FIRMWARE_VERSION = Properties['Firmware Version']
		else
			C4:UpdateProperty ('Firmware Version', FIRMWARE_VERSION)
		end
	end
end


function OnPropertyChanged (strProperty)
	local value = Properties[strProperty]

	if (strProperty == "Model") then
		Model.boardInit(value)
    elseif (strProperty == 'Check Connection') then
		CheckConnection()
	elseif (strProperty == 'Send Command') then
		if (value and value ~= "") then
			SendCommand(value)
		end
	elseif (strProperty == 'Received Command') then
		if (value and value ~= "") then
			ReceivedFromSerial(1, value)
		end
	elseif (strProperty == 'Command Delay Time') then
		COMMAND_DELAY = value
	elseif (strProperty == 'Debug Mode') then
		DEBUG_MODE = value
		if(DEBUG_MODE == 'ON')then
			C4:SetPropertyAttribs('Send Command', 0)
			C4:SetPropertyAttribs('Received Command', 0)
		else
			C4:SetPropertyAttribs('Send Command', 1)
			C4:SetPropertyAttribs('Received Command', 1)
		end
	end

	for k, v in pairs(Channel[Properties['Model']]) do
		if(strProperty == k)then
			Model.change()
		end
	end

	if (strProperty ~= 'Received Command' and strProperty ~= 'Send Command' and strProperty ~= 'Check Connection') then
		CheckConnection()
	end
end






function CheckConnection()
	if(SEND_COMMAND[1] == nil)then
		Timer['CheckConnectionFail'] = Model.KillTimer(Timer['CheckConnectionFail'])
		Timer['CheckConnection'] = Model.KillTimer(Timer['CheckConnection'])
		IS_CONNECTED = false
		C4:UpdateProperty ('Connection', 'CHECKING')
		SendCommand('<CHECK_CONNECTION>')
		Timer['CheckConnection'] = Model.AddTimer (Timer['CheckConnection'], 30, 'SECONDS')
		Timer['CheckConnectionFail'] = Model.AddTimer (Timer['CheckConnectionFail'], 3, 'SECONDS')
	end
end









function ResetChannel(id, time)
	Timer['ResetChannel'..id] = Model.AddTimer(Timer['ResetChannel'..id], time, 'MILLISECONDS')
end






function OnTimerExpired (idTimer)

	if (idTimer == Timer['CheckConnection']) then
		C4:UpdateProperty ('Connection', 'NOT CHECK')
		Timer['CheckConnection'] = Model.KillTimer(Timer['CheckConnection'])
	elseif (idTimer == Timer['CheckConnectionFail']) then
		Timer['CheckConnectionFail'] = Model.KillTimer(Timer['CheckConnectionFail'])
		if(IS_CONNECTED == false)then
			C4:UpdateProperty ('Connection', 'NOT CONNECTED')
			FIRMWARE_VERSION = 'NOT FOUND'
			C4:UpdateProperty ('Firmware Version', FIRMWARE_VERSION)
		end
	elseif (idTimer == Timer['SendCommand']) then
		SendCommandGroup()
	else
		for k, v in pairs(Timer) do
			if(idTimer == v)then
				ReceivedFromProxy(tonumber(string.match(k, '%d*%d')), 'OPEN', nil)
				Timer[k] = Model.KillTimer(Timer[k])
				break
			end
		end
	end
end




function ReceivedFromSerial(idBinding, strData)
	DBG("Received Serial Data [" .. idBinding .. "]: " .. strData)

	local serialData = SplitString(strData)
	if(serialData[1] == 'CHECK_CONNECTION' and serialData[2] == 'CONNECTED')then
		C4:UpdateProperty ('Connection', 'CONNECTED')
		IS_CONNECTED = true
		Timer['CheckConnection'] = Model.AddTimer (Timer['CheckConnection'], 30, 'SECONDS')
		if (serialData[3] ~= nil) then
			FIRMWARE_VERSION = serialData[3]
			C4:UpdateProperty ('Firmware Version', FIRMWARE_VERSION)
		else
			FIRMWARE_VERSION = 'NOT FOUND'
			C4:UpdateProperty ('Firmware Version', FIRMWARE_VERSION)
		end
	elseif (serialData[1] == Properties['Model'] and serialData[2] ~= nil and serialData[3] ~= nil) then
		for k, v in pairs(Current['ID']) do
			if(type(Current['ID'][k]) == 'table' and Current['ID'][k]['TYPE'] == 'INPUT' and Current['ID'][k]['ID'] == serialData[2])then
				local idbd = tonumber(string.sub(k, 2))
				if(serialData[3] == 'OPEN')then
					C4:SendToProxy(idbd,"OPENED",{}, "NOTIFY")
				elseif (serialData[3] == 'CLOSE') then
					C4:SendToProxy(idbd,"CLOSED",{}, "NOTIFY")
				end
				break
			end
		end
	end
end





function ReceivedFromProxy (idBinding, strCommand, tParams)
    
    DBG("Received From Proxy [" .. idBinding .. "]: " .. strCommand)
	if (tParams ~= nil) then
		DBG(tParams)
	end

	if(idBinding > 1)then
		
		if(IsTableEmpty(Current['ID']['B'..idBinding]) == false)then
			local cID = Current['ID']['B'..idBinding]['ID']
			local stid = Current['ID']['B'..idBinding]['STATE_ID']
			local state = Current[cID]['STATE'][stid]
			local data = Current[cID]['DATA']

			if(state ~= nil and data ~= nil and strCommand ~= Current[cID]['LAST_SEND'])then
				if(strCommand == "OPEN")then
					Current[cID]['LAST_SEND'] = "OPEN"
					local c = string.match(state, '^C%d*%d')
					local data2send = '<'..data..c..',NONE'..'>'
					SendCommand(data2send)
				elseif (strCommand == "CLOSE") then
					Current[cID]['LAST_SEND'] = "CLOSE"
					local data2send = '<'..data..state..'>'
					SendCommand(data2send)
				elseif (string.match(data, 'RM') == 'RM' and (strCommand=='TRIGGER' or strCommand=='OPEN' or strCommand=='CLOSE' or strCommand=='TOGGLE')) then
					if (tParams and tParams['TIME']) then
						ResetChannel(idBinding, tParams['TIME'])
					else
						-- always pulse 2000ms
						ResetChannel(idBinding, 2000)
					end
					Current[cID]['LAST_SEND'] = "CLOSE"
					local data2send = '<'..data..state..'>'
					SendCommand(data2send)
				end
			end
		else
			CheckConnection()
		end
		

	end
	
end