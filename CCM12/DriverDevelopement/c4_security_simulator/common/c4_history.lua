--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
-- History Recording Code.
-- These methods should be used to record historically significant events which happen infrequently.
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
--[[
	RecordCriticalHistoricalEvent
		Record a critical event with the History agent.
	Parameters
    category:    Should be one of the following(Security, Watch, Listen, ...)
    subcategory: Optional, for the purposes of this driver it will be(Panel, Partition, Zone, or Light)
    eventType:   Can be anything
    description: Optional, should be detailed information describing the event
	Remarks
		If the History agent is not added to the project, the historical event is ignored.
--]]
function RecordCriticalHistoricalEvent(category, subcategory, eventType, description)
	RecordHistoricalEvent("Critical", category, subcategory, eventType, description)
end

--[[
	RecordWarningHistoricalEvent
		Record a warning event with the History agent.
	Parameters
    category:    Should be one of the following(Security, Watch, Listen, ...)
    subcategory: Optional, for the purposes of this driver it will be(Panel, Partition, Zone, or Light)
    eventType:   Can be anything
    description: Optional, should be detailed information describing the event
	Remarks
			If the History agent is not added to the project, the historical event is ignored.
--]]
function RecordWarningHistoricalEvent(category, subcategory, eventType, description)
	RecordHistoricalEvent("Warning", category, subcategory, eventType, description)
end

--[[
	RecordInfoHistoricalEvent
		Record an info event with the History agent.
	Parameters
    category:    Should be one of the following(Security, Watch, Listen, ...)
    subcategory: Optional, for the purposes of this driver it will be(Panel, Partition, Zone, or Light)
    eventType:   Can be anything
    description: Optional, should be detailed information describing the event
	Remarks
		If the History agent is not added to the project, the historical event is ignored.
--]]
function RecordInfoHistoricalEvent(category, subcategory, eventType, description)
	RecordHistoricalEvent("Info", category, subcategory, eventType, description)
end

--[[=============================================================================
	RecordHistoricalEvent
    All purpose function to record an event with the history agent.
	Parameters
    severity:    Should be one of the following(Critical, Warning, Info)
    category:    Should be one of the following(Security, Watch, Listen, ...)
    subcategory: Optional, for the purposes of this driver it will be(Panel, Partition, Zone, or Light)
    eventType:   Can be anything
    description: Optional, should be detailed information describing the event
	Remarks
		Because of the number of parameters, this is NOT the preferred method to use.
		If the History agent is not added to the project, the historical event is ignored.
===============================================================================]]
function RecordHistoricalEvent(severity, category, subcategory, eventType, description)
	LogTrace("RecordHistoricalEvent(" .. severity .. ", " .. category .. ", " .. subcategory .. ", " .. eventType .. ", " .. description .. ")")
	if severity ~= "Critical" and severity ~= "Warning" and severity ~= "Info" then
		severity = "Info"	-- This is the default if severity is not one of the allowed values
	end

	local history_agent_id = get_history_agent_id()
	if history_agent_id > 0 then
		local event_params = {
			SEVERITY = severity,
			DEVICE_ID = C4:GetDeviceID(),
			CATEGORY = category or "Unknown",
			TYPE = eventType or "Unknown"
			}
		if subcategory ~= nil then
			event_params.SUBCATEGORY = subcategory
		end
		if description ~= nil then
			event_params.DESCRIPTION = description
		end

		C4:SendToDevice(history_agent_id, "RECORD_HISTORICAL_EVENT", event_params)
	end
end

--[[=============================================================================
    Internal function to look up the history agent ID.
===============================================================================]]
function get_history_agent_id()
	local history_agent_id = 0
	local devices = C4:GetDevicesByC4iName("History.c4i")
	if (devices ~= nil) then
		for k,v in pairs(devices) do 
			print(k,v) 
			history_agent_id = k
			break
		end
	end
	
	return history_agent_id
end
