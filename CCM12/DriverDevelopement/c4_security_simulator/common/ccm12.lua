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

CCM_DEBUG = tonumber(string.match(Properties['Log Level'], '%d*%d')) or 0

CCM = {}
CCM._defaultID = 1 -- Default idbinding
CCM._DebugProperties = {
    'Send To Serial',
    'Receive From Serial'
}
CCM._DriverVersion = '0.2.3'
CCM._FirmwareVersion = 0
CCM._CheckConnection = 'NOT CHECK' -- `NOT CHECK` or `NOT CONNECTED` or `CONNECTED`





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




-- Table to string
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
	if(lv <= tonumber(CCM_DEBUG) and Properties['Log Mode'] ~= 'Off')then
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




-- update firmware version
function CCM.UpdateFirmwareVersion(v)
    if (v) then
        v = tonumber(v)
        if v > 0 then
            CCM._FirmwareVersion = v
            C4:UpdateProperty('Firmware Version', v)
        end
    end
end




-- update check connection
function CCM.UpdateCheckConnection(v)
    CCM._CheckConnection = v
    C4:UpdateProperty('Check Connection', v)
end




-- show or hide debug properties
function CCM.DebugPropertiesShow()
    for _, v in pairs(CCM._DebugProperties) do
        if(CCM_DEBUG > 0 and Properties['Log Mode'] ~= 'Off')then
            C4:SetPropertyAttribs(v, 0)
        else
            C4:SetPropertyAttribs(v, 1)
        end
    end
end




--[[
    Partition Arm
    - pID: partition ID
    - armType: "Home" or "Away"
]]
function CCM.PartitionArm(pID, armType)
    if(pID == 1)then
        CCM.SendToSerial(CCM._defaultID, '<ARM,TRUE,'..Properties['Entry Delay']..'>')
    end
end




--[[
    Partition Disarm
    - pID: partition ID
]]
function CCM.PartitionDisarm(pID)
    if(pID == 1)then
        CCM.SendToSerial(CCM._defaultID, '<DISARM>')
    end
end




-- Check connection between driver and harware
function CCM.CheckConnection()
    CCM.UpdateCheckConnection('CHECKING')
    CCM.SendToSerial(CCM._defaultID, '<CHECK_CONNECTION>')
    C4:SetTimer(3000, function (timer)
        if CCM._CheckConnection ~= 'CONNECTED' then
            CCM.UpdateCheckConnection('NOT CONNECTED')
        end
    end)
    C4:SetTimer(20000, function (timer)
        CCM.UpdateCheckConnection('NOT CHECK')
    end)
end




-- On Driver init
function CCM.DriverInit()
    C4:UpdateProperty('CCM Version', CCM._DriverVersion)
    CCM.DebugPropertiesShow()
    CCM.UpdateCheckConnection('NOT CHECK')
    CCM.CheckConnection()

    C4:AddVariable("LAST_ZONE_OPEN", "", "STRING")
    C4:AddVariable("LAST_ZONE_CLOSE", "", "STRING")
    C4:AddVariable("ALL_ZONE_OPEN", "", "STRING")
    C4:AddVariable("ALL_ZONE_BYPASSED", "", "STRING")

    -- SecurityPanel:PrxGetPanelSetup()
end




-- Send to serial
function CCM.SendToSerial(idBinding, data)
    CCM.DBG('Send to Serial ['..idBinding..']: '..data, 3)
    C4:SendToSerial(idBinding, data)
end





-- Received from Serial
function CCM.ReceivedFromSerial(idBinding, sData)
    CCM.DBG('Received From Serial ['..idBinding..']: '..sData, 3)
    local rData = CCM.SplitString(sData)
    if(CCM.IsTableEmpty(rData) == false)then
        if (rData[1] == 'CHECK_CONNECTION' and rData[2] == 'CONNECTED') then
            CCM.UpdateFirmwareVersion(rData[3])
            CCM.UpdateCheckConnection('CONNECTED')
        end
        if(CCM.IsTableEmpty(CCM_DEVICE[rData[1]]) == false)then
            -- only have 3 part
            if(rData[2] and rData[3] and not rData[4])then
                local zoneID = CCM_DEVICE[rData[1]]['P'..rData[2]]
                if(rData[3] == 'OPEN')then
                    gSimDevice:HW_OpenZone(zoneID)
                    -- gSimDevice.ZoneInfoList[zoneID]._ZoneName
                elseif(rData[3] == 'CLOSE')then
                    gSimDevice:HW_CloseZone(zoneID)
                end
            end
        end
    elseif (string.find(sData, 'U_DISPLAY_TEXT') == 1) then
        rData = CCM.SplitString(sData, 0, ' ')
        -- partition's ID: 1
        if(rData[2] == '1')then
            if(string.find(rData[3], 'Zone') == 1) then
                local z = CCM.SplitString(rData[3], 0, '_')
                local zi = tonumber(z[2])
                local zname = gSimDevice.ZoneInfoList[zi]._ZoneName
                local zstate = z[4] -- `Closed` or `Open`

                -- last zone open and close
                if (zstate == 'Open') then
                    C4:SetVariable("LAST_ZONE_OPEN", zname)
                elseif zstate == 'Closed' then
                    C4:SetVariable("LAST_ZONE_CLOSE", zname)
                end

                -- all zone open, all zone bypassed
                local openingZone = ''
                local bypassedZone = ''
                for zoneIndex, zone in pairs(gSimDevice.ZoneInfoList) do
                    if(zone._IsOpen == true)then
                        openingZone = openingZone..', '..zone._ZoneName
                    end
                    if (zone._IsBypassed == true) then
                        bypassedZone = bypassedZone..', '..zone._ZoneName
                    end
                end
                if(string.len(openingZone) > 0)then
                    -- remove 2 first character
                    C4:SetVariable("ALL_ZONE_OPEN", string.sub(openingZone, 3))
                end
                if(string.len(bypassedZone) > 0)then
                    -- remove 2 first character
                    C4:SetVariable("ALL_ZONE_BYPASSED", string.sub(bypassedZone, 3))
                end

            end
        end
    end

    --[[
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
    ]]

end




-- Property change
function CCM.OnPropertyChanged(sProperty, pValue)

    if sProperty == 'Send To Serial' then
        if(string.match(pValue, 'CHECK_CONNECTION') == 'CHECK_CONNECTION')then
            CCM.CheckConnection()
        elseif (string.match(pValue, 'print_variable') == 'print_variable') then
            for VariableName, VariableValue in pairs(Variables) do 
                print('['..VariableName..']: '..VariableValue) 
            end
        else
            CCM.SendToSerial(1, pValue)
        end
    elseif sProperty == 'Receive From Serial' then
        ReceivedFromSerial(1, pValue)
    elseif sProperty == 'Log Level' then
        CCM_DEBUG = tonumber(string.match(pValue, '%d*%d'))
    end

    -- show or hide debug properties
    CCM.DebugPropertiesShow()
    
end