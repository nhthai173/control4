DRIVER_VERSION = '3.0.3.1'
FIRMWARE_VERSION = 'NOT FOUND'

MAX_CON = 3 -- Maximum number of physical connector
START_ID = 10 -- Dynamic Binding id start from
IS_CONNECTED = false -- Is C4 and Arduino working well

-- Connections ID List
CONIL = {
	serial = 1,
	proxy = 2
}

-- COMMAND_DELAY = Properties['Command Delay Time'] or 100
COMMAND_DELAY = 100 -- group delay
SEND_COMMAND_DELAY = 500 -- Time delay between sending commands
RECEIVED_COMMAND_DELAY = 500 -- Time delay to merge
RECEIVED_COMMAND_TIMEOUT = 3000
DEBUG_MODE = Properties['Debug Mode'] or 'OFF' -- Debug mode: ON and OFF
DEBUG_LEVEL = tonumber(string.match(Properties['Debug Level'], '%d*%d')) or 1 -- Debug level: 1 - 5

Model = {} -- Contains functions and board type of each CON
M_CMD = {}

Current = {} -- Contains data for current setting
Current.ID = {} -- List of IDs used
Current.INPUT = Properties['INPUT'] or 'NOT USE'
Current.INPUT_TYPE = {} -- List of Input type
CURRENT_INPUT_STATE = {} -- currently not use
INPUT_TYPE_LIST = {
	DIGITAL = 0
}

Timer = {} -- Contains all timer
SEND_COMMAND = {} -- Contains commands waiting to be sent
RECEIVED_COMMAND = {}

STR = {}

Channel = {
	RCM64V1 = {
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
			DMV2 = {
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
			DMV2 = {
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
			DMV2 = {
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
		INPUT = {
			USE = {"ZONE1", "ZONE2", "ZONE3", "ZONE4", "ZONE5", "ZONE6", "ZONE7", "ZONE8", "ZONE9", "ZONE10", "ZONE11", "ZONE12"}
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
            I69 = "ZONE12",
			ZONE1 = 58,
            ZONE2 = 59,
            ZONE3 = 60,
            ZONE4 = 61,
            ZONE5 = 62,
            ZONE6 = 63,
            ZONE7 = 64,
            ZONE8 = 65,
            ZONE9 = 66,
            ZONE10 = 67,
            ZONE11 = 68,
            ZONE12 = 69,
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
		DMV2 = {
            STATE = {
				OPEN = {0, 0},
				CLOSE = {0, 1},
				STOP = {1, 0},
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
                TRIGGER = {0},
				OPEN = {1},
				CLOSE = {0},
				NONE = {1}
            },
            RULE = {
                TRIGGER = {1},
				OPEN = {1},
				CLOSE = {1},
				NONE = {1}
            },
            CON1 = {
				C1 = {29},
				C2 = {31},
				C3 = {27},
				C4 = {33},
				C5 = {25},
				C6 = {35},
				C7 = {23},
				C8 = {37},
				C9 = {47},
				C10 = {39},
				C11 = {49},
				C12 = {41},
				C13 = {51},
				C14 = {43},
				C15 = {53},
				C16 = {45},
			},
			CON2 = {
				C1 = {6},
				C2 = {5},
				C3 = {7},
				C4 = {4},
				C5 = {8},
				C6 = {3},
				C7 = {9},
				C8 = {2},
				C9 = {10},
				C10 = {54},
				C11 = {11},
				C12 = {55},
				C13 = {12},
				C14 = {56},
				C15 = {13},
				C16 = {57},
			},
			CON3 = {
				C1 = {22},
				C2 = {52},
				C3 = {24},
				C4 = {50},
				C5 = {26},
				C6 = {48},
				C7 = {28},
				C8 = {46},
				C9 = {30},
				C10 = {44},
				C11 = {32},
				C12 = {42},
				C13 = {34},
				C14 = {40},
				C15 = {36},
				C16 = {38},
			}
        }
	}
}







function INPUT_TYPE_LIST.ANALOG(v)
	return v
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




--[[
	return `number` length of table
]]
function TableLength(tbl)
    local len = 0
    if(IsTableEmpty(tbl) == false)then
        for k, v in pairs(tbl) do
            len = len + 1
        end
    end
    return len
end




--[[
Turn Lua table -> string
	
	tbl: table input
	tbtype: "ARDUINO_COMMAND" | ""
	prettyPrint: bool
	childCount: number
]]
function PrintTable(tbl, tbtype, prettyPrint, childCount)
    prettyPrint = prettyPrint or false
    childCount = childCount or 0
    local result = ""
    local kc = 0
    local isArray = false
    
    for k, v in pairs(tbl) do
        
        kc = kc + 1
        local subRes = ''

        -- define array or object
        if (type(k) == "string") then
            if kc == 1 then
                childCount = childCount + 1
                result = result.."{"
            end
            subRes = subRes..'"'..k..'"'..": "
        elseif kc == 1 then
            childCount = childCount + 1
            result = result.."["
            isArray = true
        end
        
		if tbtype == "ARDUINO_COMMAND" then
			subRes = subRes..v
        elseif type(v) == "table" then
			if(IsTableEmpty(v) == false)then
            	subRes = subRes..PrintTable(v, '', prettyPrint, childCount)
			else
				subRes = subRes.."{}"
			end
        elseif type(v) == "boolean" or type(v) == "number" then
            subRes = subRes..tostring(v)
        elseif type(v) == "function" then
            subRes = subRes..'"function"'
        elseif v then
            subRes = subRes..'"'..v..'"'
		else
			subRes = subRes..'""'
        end
        subRes = subRes..","

        if prettyPrint == true then
            result = result..'\n'
            for i=1, childCount do
                result = result..'\t'
            end
        else
            subRes = STR.trim(subRes)
        end
        result = result..subRes

    end
    
    if result ~= "" then
        result = result:sub(1, result:len()-1)
        if prettyPrint == true then
            result = result.."\n"
            for i=1, childCount-1 do
                result = result.."\t"
            end
        end
        if isArray == false then
            result = result.."}"
        else
            result = result.."]"
        end
    end
    
    return result
end



--[[
Print Debug

	str: content to print
	lv: debug level
]]
function DBG(str, lv)
	lv = lv or 2
	if(DEBUG_MODE == 'ON' and lv <= tonumber(DEBUG_LEVEL))then
		if(type(str) == 'table')then
			print(PrintTable(str, '', true))
		else
			print(str)
		end
	end
end



--[[
Splits the string by `sep`. Output: Table of string

	inputstr: string
	type: 1 | any - 1 for serial command split
	sep: separator - default is `,`
]]
function STR.split (inputstr, type, sep)
	-- type 1: data contained in "<" and ">"
	type = type or 1
	sep = sep or ','
	local strOut = {}
	if(type == 1)then
	    -- local regex = '^([^<]*)<(%/?)([^>]-)(%/?)>'
	    local st = inputstr:find('<')
	    if(st)then
    	    local en = inputstr:find('>', st+1)
            while(st and en)do
                local nst = inputstr:find('<', st+1)
                if nst and st < nst and nst < en then
                    table.insert(strOut, inputstr:sub(nst+1, en-1))
                    inputstr = STR.remove(inputstr, nst, en)
                else
                    table.insert(strOut, inputstr:sub(st+1, en-1))
                    inputstr = STR.remove(inputstr, st, en)
                end
                st = inputstr:find('<')
                if(st)then
                    en = inputstr:find('>', st+1)
                end
            end
            for k, v in pairs(strOut) do
                strOut[k] = {}
                for str in string.gmatch(v, "([^"..sep.."]+)") do
        			table.insert(strOut[k], str)
        		end
            end
        end
	elseif (inputstr ~= nil) then
		for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
			table.insert(strOut, str)
		end
	end
    if(TableLength(strOut) == 1)then
        for k, v in pairs(strOut) do
            strOut = strOut[k]
        end
    end
	return strOut, inputstr
end




--[[
Join string with `sep`

	Input: table
	Output: string
]]
function STR.join (tbl, sep)
	sep = sep or ''
	local output = ''
	if(IsTableEmpty(tbl) == false)then
		for k, v in pairs(tbl) do
			output = output..sep..v
		end
        local ss = sep:len()
        if ss > 0 then
            output = string.sub(output, ss+1)
        end
	end
	return output
end




--[[
Replace spaces with `s` spaces

	s: number of spaces - default is 0
]]
function STR.trim (str, s)
	s = s or 0
	if s == 0 then
	    return str:gsub('%s*%s', '')
	else
	    return str:gsub('%s*%s', ' ')
	end
end




--[[
Remove string from position `st` to `en` of `str`

	str: string
	st: number
	en: number

]]
function STR.remove(str, st, en)
    if(str and st)then
        if(en and st > 0)then
            if(st == 1)then
                return str:sub(en+1, str:len())
            else
                return str:sub(1, st-1)..str:sub(en+1, str:len()) 
            end
        elseif(st >= 0)then
            return str:sub(st+1)
        elseif(st < 0)then
            st = -st
            return str:sub(1, st)
        end
    end
end




-- ID generator function
-- type: type of connection,
-- id: channel id,
-- stid: state id,
function GenID(type, id, stid)
	local validID = false
	local startID = START_ID
	while validID == false do
		if(IsTableEmpty(Current['ID']['B'..startID]) == false)then
			startID = startID + 1
		else
			validID = true
			AddID(type, startID, id, stid)
			return startID
		end
		-- Fail safe
		if startID > 900 then
			validID = true
			AddID(type, 999, id, stid)
			return 999
		end
	end
end

-- init idbinding
function AddID(type, idnum, id, stid)
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

-- remove idbinding
function RemoveID(idnum)
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
				local tg = STR.split(SEND_COMMAND[1])
				local st = tg[5] -- state
				local model = tg[1]
				local type = tg[2] -- MM/DM/RM
				local o1c = true -- if those commands have the same model, state, type
				
				local gpin = {} -- group pins
				local gcom = {} -- group commands

				-- checking group
				for k, v in pairs(SEND_COMMAND) do
					local tgg = STR.split(v)
					if(st ~= tgg[5] or model ~= tgg[1] or type ~= tgg[2])then
						o1c = false
						break
					end
				end

				-- if group
				if (o1c == true and SEND_COMMAND[2] ~= nil) then
					for k, v in pairs(HARDWARE[model][type]['RULE'][st]) do
						if (string.match(v, "DLY") == "DLY") then
							table.insert(gcom, v)
						else
							table.insert(gcom, HARDWARE[model][type]['STATE'][st][v])
						end
					end
					for k, v in pairs(SEND_COMMAND) do
						-- tgg[3] : CON1,CON2,...
						-- tgg[4] : C1,C2,...
						local tgg = STR.split(v)
						local pins = {}
						for k1, v1 in pairs(HARDWARE[model][type]['RULE'][st]) do
							if (string.match(v1, "DLY") ~= "DLY") then
								table.insert(pins, HARDWARE[tgg[1]][tgg[2]][tgg[3]][tgg[4]][v1])
							end
						end
    					table.insert(gpin, pins)
						DBG("Data to send: "..v, 1)
					end
					SEND_COMMAND = {}
					SendCMD('<'..model..','..PrintTable(gpin)..','..PrintTable(gcom, "ARDUINO_COMMAND")..'>')

				-- not found group
				elseif (model ~= nil and type ~= nil and st ~= nil) then
					-- tg[3] : CON1,CON2,...
					-- tg[4] : C1,C2,...
					local pins = {}
					for k, v in pairs(HARDWARE[model][type]['RULE'][st]) do
						if (string.match(v, "DLY") == "DLY") then
							table.insert(gcom, v)
						else
							table.insert(gcom, HARDWARE[model][type]['STATE'][st][v])
							table.insert(pins, HARDWARE[model][type][tg[3]][tg[4]][v])
						end
					end
					table.insert(gpin, pins)
					DBG("Data to send: "..SEND_COMMAND[1], 1)
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
			local tg = STR.split(SEND_COMMAND[1])
			local st = tg[5]
			local model = tg[1]
			local type = tg[2]
			local o1c = true
			local gcom = {
				PORT = {}
			}
			for k, v in pairs(SEND_COMMAND) do
				local tgg = STR.split(v)
				if(st ~= tgg[5] or model ~= tgg[1] or type ~= tgg[2])then
					o1c = false
					break
				end
			end
			if (o1c == true and SEND_COMMAND[2] ~= nil) then
				for k, v in pairs(SEND_COMMAND) do
					local tgg = STR.split(v)
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
		DBG('Send to Serial: '..SEND_COMMAND[1], 1)
		C4:SendToSerial(CONIL.serial,SEND_COMMAND[1]..'\n')
		table.remove(SEND_COMMAND, 1)
	else
		Timer['SendCommandNoGroup'] = Model.KillTimer(Timer['SendCommandNoGroup'])
	end
end



-- send to serial
function SendCMD(cmd)
	DBG('Send to Serial: '..cmd, 1)
	C4:SendToSerial(CONIL.serial,cmd..'\n')
end



-- Show the CONs that belong to this model and hide the rest
function Model.boardInit(model)
	-- Show and hide CON
	--[[if (Channel[model] ~= nil) then
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
	end]]

	Model.DebugProperty()
	Model.GetCurrent()

	-- Init connection from `current`
	if(IsTableEmpty(Current['ID']) == false)then
		for k, v in pairs(Current['ID']) do

			-- input
			if(Current['ID'][k]['TYPE'] == 'INPUT')then
				-- remove first letter "B"
				local idbd = tonumber(string.sub(k, 2))
				C4:AddDynamicBinding(idbd, "CONTROL", true, Current['ID'][k]['ID'], "CONTACT_SENSOR", false, false)
			end

			-- output
			if(Current['ID'][k]['TYPE'] == 'OUTPUT')then
				if(IsTableEmpty(Current[Current['ID'][k]['ID']]) == false)then
					-- s0: "RCM64V1,MM,CON1,"
					local s0 = STR.split(Current[Current['ID'][k]['ID']]['DATA'], 0)
					local s1 = tonumber(Current['ID'][k]['STATE_ID'])
					-- Channel[RCM64V1][CON1][MM][COMMAND_LABEL]
					local s2 = Channel[s0[1]][s0[3]][s0[2]]['COMMAND_LABEL'][s1]
					-- s3: CON1,C6
					local s3 = STR.split(Current['ID'][k]['ID'], 0)
					local s4 = string.match(s3[2], '%d*%d')
					-- remove first letter "B"
					local idbd = tonumber(string.sub(k, 2))
					local idname = s0[3]..' - Channel '..s4..' '..s2
					C4:AddDynamicBinding(idbd, "CONTROL", true, idname, "RELAY", false, false)
				end
			end

		end
	end

	Model.change()
end



-- On Property Changed
function Model.change()

	-- get current from properties
	Model.GetCurrent()

	DBG('before change "Current":', 2)
	DBG(Current, 2)

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
						RemoveID(idbd)
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
								RemoveID(idbd)
							end
						end
						for k2, v2 in pairs(Channel[model][k][k1]) do
							local idbd = GenID('INPUT', v2)
							C4:AddDynamicBinding(idbd, "CONTROL", true, v2, "CONTACT_SENSOR", false, false)
						end
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
							RemoveID(v2)
						end
						Current[k1] = {}
					end
				end
			else
				-- remove all id binding of the CONs (CON1, CON2, CON3,...) had changed
				for k1, v1 in pairs(Current) do
					if (string.match(k1, '^CON%d*%d') == k) then
						if(Current[k1]['MODEL'] and Current[k1]['MODEL'] ~= Model[k])then
							DBG('being removed '..k1, 2)
							if (Current[k1]['ID']) then
								for k2, v2 in pairs(Current[k1]['ID']) do
									C4:RemoveDynamicBinding(v2)
									RemoveID(v2)
									DBG('removed binding id: '..v2, 2)
								end
							end
							Current[k1] = {}
						end
					end
				end

				for k1, v1 in pairs(Channel[model][k][Model[k]]['CHANNEL']) do
					local cID = k..',C'..v1
					if(not Current[cID] or IsTableEmpty(Current[cID]) == true)then
						Current[cID] = {}
						Current[cID] = {
							MODEL = Model[k],
							DATA =  model..','..Model[k]..','..k..',',
							LAST_SEND = "",
							STATE = {},
							ID = {}
						}
						for i=1, Channel[model][k][Model[k]]['NUMBER_COMMAND'], 1 do
							local start_id = GenID('OUTPUT', cID, i)
							C4:AddDynamicBinding(start_id, "CONTROL", true, k..' - Channel '..v1..' '..Channel[model][k][Model[k]]['COMMAND_LABEL'][i], "RELAY", false, false)
							table.insert(Current[cID]['ID'], start_id)
							table.insert(Current[cID]['STATE'], 'C'..v1..','..Channel[model][k][Model[k]]['COMMAND'][i])
						end
					end
				end
			end
		end
	end
	
	DBG('after change "Current":', 2)
	DBG(Current, 2)
	
	Model.PushCurrent()

end





function Model.AddTimer(timer, count, units, recur)
	local newTimer
	if (recur == nil) then recur = false end
	if (timer and timer ~= 0) then Model.KillTimer (timer) end
	newTimer = C4:AddTimer (count, units, recur)
	return newTimer
end




function Model.KillTimer (timer)
	if (timer) then
		return (C4:KillTimer (timer))
	else
		return (0)
	end
end




-- sync `Current`
function Model.GetCurrent()
	if(Properties['Current'] and Properties['Current'] ~= 'NONE' and Properties['Current'] ~= '')then
		Current = C4:JsonDecode(Properties['Current'])
	end
end	

function Model.PushCurrent()
	C4:UpdateProperty('Current', PrintTable(Current))
end




-- show debug property when debug_mode = on
function Model.DebugProperty()
	if(DEBUG_MODE == 'ON')then
		C4:SetPropertyAttribs('Send Command', 0)
		C4:SetPropertyAttribs('Received Command', 0)
		C4:SetPropertyAttribs('Current', 0)
		C4:SetPropertyAttribs('Debug Level', 0)
		DEBUG_LEVEL = tonumber(string.match(Properties['Debug Level'], '%d*%d')) or 1
	else
		C4:SetPropertyAttribs('Send Command', 1)
		C4:SetPropertyAttribs('Received Command', 1)
		C4:SetPropertyAttribs('Current', 1)
		C4:SetPropertyAttribs('Debug Level', 1)
	end
end




--
function Model.setInputTypeSelect(input)
	if(tonumber(FIRMWARE_VERSION) ~= nil and tonumber(FIRMWARE_VERSION) >= 4)then
		if(input == 'USE')then
			local list = {}
			for _, v in pairs(Channel[Properties['Model']]['INPUT']['USE']) do
				table.insert(list, v)
			end
			C4:UpdatePropertyList('Select Input Name', table.concat(list, ','))
			Model.getInputType(Properties['Select Input Name'])
			
			C4:SetPropertyAttribs('Input Setting', 0)
			C4:SetPropertyAttribs('Select Input Name', 0)
			C4:SetPropertyAttribs('Current Input Type', 0)
			C4:SetPropertyAttribs('Change Input Type To', 0)
		else
			C4:SetPropertyAttribs('Input Setting', 1)
			C4:SetPropertyAttribs('Select Input Name', 1)
			C4:SetPropertyAttribs('Current Input Type', 1)
			C4:SetPropertyAttribs('Change Input Type To', 1)
		end
	else
		Current.INPUT_TYPE = {}
		C4:SetPropertyAttribs('Input Setting', 1)
		C4:SetPropertyAttribs('Select Input Name', 1)
		C4:SetPropertyAttribs('Current Input Type', 1)
		C4:SetPropertyAttribs('Change Input Type To', 1)
	end
	Model.PushCurrent()
end




--
function Model.changeInputType(zID, type, sendAfterChange)
	for k, v in pairs(Channel[Properties['Model']]['INPUT']['USE']) do
		if zID == v then
			if(Current['INPUT_TYPE'][zID] ~= type)then
				Current['INPUT_TYPE'][zID] = type
				if(sendAfterChange == true)then
					SendCommand('<SET_PIN,'..HARDWARE[Properties['Model']]['INPUT'][zID]..','..type..'>')
				end
			end
			Model.getInputType(zID)
		end
	end
	Model.PushCurrent()
end




--
function Model.getInputType(zID)
	if(tonumber(FIRMWARE_VERSION) ~= nil and tonumber(FIRMWARE_VERSION) >= 4)then
		for k, v in pairs(Channel[Properties['Model']]['INPUT']['USE']) do
			if zID == v then
				if(Current['INPUT_TYPE'][zID] == nil)then
					Current['INPUT_TYPE'][zID] = 'DIGITAL'
				end
				local list = {}
				table.insert(list, Current['INPUT_TYPE'][zID])
				for k1, v1 in pairs(INPUT_TYPE_LIST) do
					if(k1 ~= Current['INPUT_TYPE'][zID])then
						table.insert(list, k1)
					end
				end
				C4:UpdateProperty('Current Input Type', Current['INPUT_TYPE'][zID])
				C4:UpdatePropertyList('Change Input Type To', table.concat(list, ','))
				return Current['INPUT_TYPE'][zID]
			end
		end
	end
	Model.PushCurrent()
end




function OnDriverDestroyed ()
	DBG("============================", 2)
	DBG("      Driver Destroyed", 2)
	DBG("============================", 2)
	DBG('Model :', 2)
	DBG(Model, 2)
	-- C4:DestroyServer ()
	for k, v in pairs(Timer) do
		Model.KillTimer(v)
	end
end




function OnDriverInit()
	DBG("=======================", 2)
	DBG("      Driver init", 2)
	DBG("=======================", 2)

	-- update driver version
	C4:UpdateProperty ('Driver Version', DRIVER_VERSION)

	-- init dropdown menu
	--[[
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
	]]

	CheckConnection()

end






function OnDriverLateInit ()
	DBG("============================", 2)
	DBG("      Driver late init", 2)
	DBG("============================", 2)

	DEBUG_MODE = Properties['Debug Mode'] or 'OFF'
	DEBUG_LEVEL = tonumber(string.match(Properties['Debug Level'], '%d*%d')) or 1
	Current.INPUT = Properties['INPUT'] or 'NOT USE'
	if (FIRMWARE_VERSION ~= Properties['Firmware Version']) then
		if (Properties['Firmware Version'] ~= "NOT FOUND") then
			FIRMWARE_VERSION = Properties['Firmware Version']
		else
			C4:UpdateProperty ('Firmware Version', FIRMWARE_VERSION)
		end
	end
	Model.setInputTypeSelect(Properties['INPUT'])

	Model.boardInit(Properties['Model'])

	Timer['SendCommand'] = Model.AddTimer(Timer['SendCommand'], COMMAND_DELAY, 'MILLISECONDS', true)
	Timer['ReceivedCommand'] = Model.AddTimer(Timer['ReceivedCommand'], RECEIVED_COMMAND_DELAY, 'MILLISECONDS', true)

	DBG('Model :', 2)
	DBG(Model, 2)
end


function OnPropertyChanged (strProperty)
	local value = Properties[strProperty]

	if (strProperty == "Model") then
		CheckConnection()
		Model.boardInit(value)
	elseif (strProperty == 'Send Command') then
		if (value and value ~= "") then
			DBG('Send to Serial: '..value, 1)
			C4:SendToSerial(CONIL.serial, value..'\n')
		end
	elseif (strProperty == 'Received Command') then
		if value == 'json_parse' then
			DBG("JSON Parse:", 2)
			DBG("========================", 2)
			DBG("Current-Properties:", 2)
			DBG(C4:JsonDecode(Properties['Current']), 2)
			DBG("========================", 2)
		elseif (value and value ~= "") then
			ReceivedFromSerial(CONIL.serial, value)
		end
	elseif (strProperty == 'Command Delay Time') then
		COMMAND_DELAY = value
	elseif (strProperty == 'Debug Mode') then
		DEBUG_MODE = value
	elseif (strProperty == 'Select Input Name') then
		Model.getInputType(value)
	elseif (strProperty == 'Change Input Type To') then
		Model.changeInputType(Properties['Select Input Name'], value, true)
	end

	if strProperty == 'INPUT' then
		Model.setInputTypeSelect(value)
	end

	Model.DebugProperty()

	for k, v in pairs(Channel[Properties['Model']]) do
		if(strProperty == k)then
			CheckConnection()
			Model.change()
			break
		end
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
	elseif (idTimer == Timer['ReceivedCommand']) then
		MergeCommandReceived()
	elseif (idTimer == Timer['ReceivedCommandTimeout']) then
		Model.KillTimer(Timer['ReceivedCommand'])
		Model.KillTimer(Timer['ReceivedCommandTimeout'])
		if(TableLength(RECEIVED_COMMAND) <= 1) then
			RECEIVED_COMMAND = {}
		else
			Timer['ReceivedCommandTimeout'] = Model.AddTimer(Timer['ReceivedCommandTimeout'], RECEIVED_COMMAND_TIMEOUT, 'MILLISECONDS')
			MergeCommandReceived()
		end
	elseif(IsTableEmpty(Timer) == false) then
		-- RM pulse time. ex: ResetChannel57
		for k, v in pairs(Timer) do
			if(string.match(k, 'ResetChannel') == 'ResetChannel' and idTimer == v)then
				ReceivedFromProxy(tonumber(string.match(k, '%d*%d')), 'NONE', nil)
				Timer[k] = Model.KillTimer(Timer[k])
				break
			end
		end
	end
end




function MergeCommandReceived()
	local reStr = STR.join(RECEIVED_COMMAND)
	reStr = reStr:gsub('%G', '')
	local cmds, r = STR.split(reStr)
	Model.KillTimer(Timer['ReceivedCommand'])
	if(IsTableEmpty(cmds) == false)then
		RECEIVED_COMMAND = {}
		if(r ~= '')then
			table.insert(RECEIVED_COMMAND, r)
			Timer['ReceivedCommand'] = Model.AddTimer(Timer['ReceivedCommand'], RECEIVED_COMMAND_DELAY, 'MILLISECONDS', true)
		end
		Model.ReceivedFromSerial(cmds)
		DBG("=============================", 2)
		DBG("      Merge Serial Data", 2)
		DBG("=============================", 2)
		DBG(cmds, 2)
	end
end




function Model.ReceivedFromSerial(cmdTbl)
	if (IsTableEmpty(cmdTbl) == false) then
		local sData = {}
		local isSingle = false
		local isValidCommand = false

		for k, v in pairs(cmdTbl) do
			if type(cmdTbl[k]) ~= "table" then
				isSingle = true
				break
			end
		end
		if isSingle == true then
			sData = {cmdTbl}
		end

		for i, _ in pairs(sData) do
			local serialData = sData[i]

			if(serialData[1] == 'CHECK_CONNECTION' and serialData[2] == 'CONNECTED')then
				C4:UpdateProperty ('Connection', 'CONNECTED')
				IS_CONNECTED = true
				Timer['CheckConnection'] = Model.AddTimer (Timer['CheckConnection'], 30, 'SECONDS')
				if (serialData[3] ~= nil) then
					FIRMWARE_VERSION = serialData[3]
				else
					FIRMWARE_VERSION = 'NOT FOUND'
				end
				C4:UpdateProperty ('Firmware Version', FIRMWARE_VERSION)
				Model.setInputTypeSelect(Properties['INPUT'])
				isValidCommand = true
			elseif (serialData[1] == Properties['Model'] and serialData[2] ~= nil and serialData[3] ~= nil) then
				for k, v in pairs(Current['ID']) do
					if(type(Current['ID'][k]) == 'table' and Current['ID'][k]['TYPE'] == 'INPUT')then
						local zID = Current['ID'][k]['ID']
						local s_zID = HARDWARE[serialData[1]]['INPUT']['I'..serialData[2]]

						-- condition for old firmware
						local ocon = zID == serialData[2]
						-- condition for new firmware (>= 2)
						local v2con = FIRMWARE_VERSION ~= 'NOT FOUND' and tonumber(FIRMWARE_VERSION) >= 2 and zID == s_zID
						if (ocon == true or v2con == true) then
							-- remove first letter `I`
							CURRENT_INPUT_STATE[zID] = serialData[3]
							local idbd = tonumber(string.sub(k, 2))
							if (serialData[3] == 'OPEN') then
								DBG('==> '..zID..' -> '..serialData[3]..' <==', 1)
								C4:SendToProxy(idbd,"OPENED",{}, "NOTIFY")
								C4:SendToProxy(CONIL.proxy, 'ZONE_CHANGED', {zone = zID, state = serialData[3]}, 'NOTIFY')
							elseif (serialData[3] == 'CLOSE') then
								DBG('==> '..zID..' -> '..serialData[3]..' <==', 1)
								C4:SendToProxy(idbd,"CLOSED",{}, "NOTIFY")
								C4:SendToProxy(CONIL.proxy, 'ZONE_CHANGED', {zone = zID, state = serialData[3]}, 'NOTIFY')
							end
							if(tonumber(serialData[3]) ~= nil and tonumber(serialData[3]) >= 0)then
								if(tonumber(FIRMWARE_VERSION) >= 4)then
									-- just for testing
									if(Current['INPUT_TYPE'][zID] == nil or Current['INPUT_TYPE'][zID] == "DIGITAL")then
										Model.changeInputType(zID, 'ANALOG', false)
									end
									for k1, _ in pairs(INPUT_TYPE_LIST) do
										if(k1 == Current['INPUT_TYPE'][zID])then
											local aVal = INPUT_TYPE_LIST[k1](serialData[3])
											DBG('Received Analog value ==> '..zID..' -> '..aVal..' <==', 1)
											break
										end
									end
									-- send analog value to proxy
								else
									DBG("Analog value only available from firmware 4.0", 1)
								end
							else
								Model.changeInputType(zID, 'DIGITAL', false)
							end
							isValidCommand = true
							break
						end
					end
				end
			end
		end

		if isSingle == true then
			return isValidCommand
		else
			return true
		end

	else
		return false
	end
end




function ReceivedFromSerial(idBinding, strData)
	DBG("Received Serial Data [" .. idBinding .. "]: " .. strData, 1)

	if Model.ReceivedFromSerial(STR.split(strData)) == false then
		-- Merge command
		table.insert(RECEIVED_COMMAND, strData)
		Model.KillTimer(Timer['ReceivedCommand'])
		Model.KillTimer(Timer['ReceivedCommandTimeout'])
		Timer['ReceivedCommand'] = Model.AddTimer(Timer['ReceivedCommand'], RECEIVED_COMMAND_DELAY, 'MILLISECONDS', true)
		Timer['ReceivedCommandTimeout'] = Model.AddTimer(Timer['ReceivedCommandTimeout'], RECEIVED_COMMAND_TIMEOUT, 'MILLISECONDS')
	end
	
end





function ReceivedFromProxy (idBinding, strCommand, tParams)
    
    DBG("Received From Proxy [" .. idBinding .. "]: " .. strCommand, 1)
	if (tParams ~= nil) then
		DBG(tParams, 1)
	end

	if(idBinding > 1)then

		local bid = 'B'..idBinding
		if(IsTableEmpty(Current['ID'][bid]) == false and Current['ID'][bid]['TYPE'] == 'OUTPUT')then
			local cID = Current['ID'][bid]['ID']
			local stid = Current['ID'][bid]['STATE_ID']
			local state = Current[cID]['STATE'][stid]
			local data = Current[cID]['DATA']
			local c = string.match(state, '^C%d*%d')

			if(state ~= nil and data ~= nil and strCommand ~= Current[cID]['LAST_SEND'])then
				if (string.match(data, 'RM') == 'RM') then
					if (strCommand=='TRIGGER') then
						if (tParams and tParams['TIME']) then
							ResetChannel(idBinding, tParams['TIME'])
						else
							-- always pulse 2000ms
							ResetChannel(idBinding, 2000)
						end
						Current[cID]['LAST_SEND'] = 'TRIGGER'
						SendCommand('<'..data..state..'>')
					elseif strCommand == 'NONE' then
						Current[cID]['LAST_SEND'] = "NONE"
						SendCommand('<'..data..c..',NONE'..'>')
					elseif strCommand=='OPEN' or strCommand=='CLOSE' then
						Current[cID]['LAST_SEND'] = strCommand
						SendCommand('<'..data..c..','..strCommand..'>')
					elseif strCommand=='TOGGLE' then
						if (Current[cID]['LAST_SEND'] == 'OPEN') then
							Current[cID]['LAST_SEND'] = 'CLOSE'
						elseif Current[cID]['LAST_SEND'] == 'CLOSE' then
							Current[cID]['LAST_SEND'] = 'OPEN'
						end
						SendCommand('<'..data..c..','..Current[cID]['LAST_SEND']..'>')
					end
				elseif (string.match(data, 'DM') == 'DM' or string.match(data, 'MM') == 'MM') then
					if(strCommand == "OPEN")then
						Current[cID]['LAST_SEND'] = "OPEN"
						SendCommand('<'..data..c..',NONE'..'>')
					elseif (strCommand == "CLOSE") then
						Current[cID]['LAST_SEND'] = "CLOSE"
						SendCommand('<'..data..state..'>')
					elseif strCommand == 'TRIGGER' then
						if (tParams and tParams['TIME']) then
							ResetChannel(idBinding, tParams['TIME'])
						else
							-- always pulse 2000ms
							ResetChannel(idBinding, 2000)
						end
						Current[cID]['LAST_SEND'] = "TRIGGER"
						SendCommand('<'..data..state..'>')
					elseif strCommand == 'NONE' then
						Current[cID]['LAST_SEND'] = "NONE"
						SendCommand('<'..data..c..',NONE'..'>')
					end
				end
			end
		else
			CheckConnection()
		end
		

	end
	
end




function M_CMD.checkConnection(params)
	CheckConnection()
end


function ExecuteCommand(strCommand, tParams)
	if tParams == nil then
		tParams = {}
	end
	local cmd = ''
	if strCommand == 'LUA_ACTION' then
		cmd = tParams["ACTION"]	
	else
		cmd = strCommand
	end	
	
	if M_CMD[cmd] and type(M_CMD[cmd]) == "function" then
		DBG('EXECUTE FUNCTION ==> '..cmd..'() <== with params:', 2)
		DBG(tParams, 2)
		pcall(M_CMD[cmd], tParams)
	else
		DBG('INVALID FUNCTION ==> '..cmd..'() <==', 2)
	end
end