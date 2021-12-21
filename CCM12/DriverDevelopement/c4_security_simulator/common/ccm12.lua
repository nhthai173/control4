-- CCM_DEBUG = tonumber(string.match(Properties['Log Level'], '%d*%d')) or 0
CCM_DEBUG = 5

CCM_DEVICE = {
    CCM12V1 = {
        -- pin = zone_id
        P2 = 1,
        P3 = 2,
        P4 = 3,
        P5 = 4,
        P6 = 5,
        P7 = 6,
        P8 = 7,
        P9 = 8,
        P10 = 9,
        P11 = 10,
        P12 = 11
    }
}

CCM = {}







-- Check if the table is empty
function CCM.IsTableEmpty(d)
	local isEmpty = true
	if(d ~= nil)then
		for k,v in pairs(d) do
			isEmpty = false
			break
		end
	end
    return isEmpty
end




function CCM.PrintTable(tbl, tbtype)
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
		if tbtype == "ARDUINO_COMMAND" then
			result = result..v
        elseif type(v) == "table" then
			if(CCM.IsTableEmpty(v) == false)then
            	result = result..CCM.PrintTable(v)
			else
				result = result.."\"\""
			end
        elseif type(v) == "boolean" then
            result = result..tostring(v)
        elseif type(v) == "function" then
            result = result.."\"function\""
        elseif type(v) == "number" then
            result = result..tostring(v)
        elseif v then
            result = result.."\""..v.."\""
		else
			result = result.."\"\""
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



--[[
Print Debug
	- str: content to print (any type)
	- lv: debug level
]]
function CCM.DBG(str, lv)
    lv = lv or 1 -- default: 1
	if(lv <= tonumber(CCM_DEBUG))then
		if(type(str) == 'table')then
			print(CCM.PrintTable(str))
		else
			print(str)
		end
	end
end




-- Splits the string that received from Serial into the specified form
-- Output: Table of commands
function CCM.SplitString (inputstr, type, sep)
	sep = sep or ','
    --[[
        type
            1: data contained in "<" and ">"
    ]]
    type = type or 1
	local t={}
    if(type == 1)then
	    inputstr = string.match(inputstr, "([^<]+)([>$]+)")
    end
	if (inputstr ~= nil) then
		for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
			table.insert(t, str)
		end
	end
	return t
end




function CCM.SendToSerial(idBinding, data)
    CCM.DBG('Send to Serial ['..idBinding..']: '..data, 3)
    C4:SendToSerial(idBinding, data)
end



function CCM.ReceivedFromSerial(idBinding, sData)
    CCM.DBG('Received From Serial ['..idBinding..']: '..sData, 3)
    local rData = CCM.SplitString(sData)
    if(CCM.IsTableEmpty(rData) == false)then
        if(CCM.IsTableEmpty(CCM_DEVICE[rData[1]]) == false)then
            -- only have 3 part
            if(rData[2] and rData[3] and not rData[4])then
                local zoneID = CCM_DEVICE[rData[1]]['P'..rData[2]]
                if(rData[3] == 'OPEN')then
                    gSimDevice:HW_OpenZone(zoneID)
                elseif(rData[3] == 'CLOSE')then
                    gSimDevice:HW_CloseZone(zoneID)
                end
            end
        end
    elseif (string.find(sData, 'U_PARTITION_STATE') == 1) then
        rData = CCM.SplitString(sData, 0, ' ')
        CCM.DBG('Split Received data:', 4)
        CCM.DBG(rData, 4)
        -- U_PARTITION_STATE 1 ARMED Away 0
        -- U_PARTITION_STATE 1 DISARMED_READY  0
        -- U_PARTITION_STATE 1 DISARMED_NOT_READY  0
        -- U_PARTITION_STATE 1 ENTRY_DELAY  5
        -- U_PARTITION_STATE 1 ALARM Burglary 0
        if(rData[2] == '1')then
            -- partition's ID: 1
            if(string.find(rData[3], 'ARMED') == 1) then
                CCM.SendToSerial(idBinding, '<ARM,TRUE,'..Properties['Entry Delay']..'>')
            elseif (string.find(rData[3], 'DISARMED') == 1) then
                CCM.SendToSerial(idBinding, '<DISARM>')
            elseif (string.find(rData[3], 'ALARM') == 1) then
                CCM.SendToSerial(idBinding, '<ALARM>')
            end
        end
    end

end