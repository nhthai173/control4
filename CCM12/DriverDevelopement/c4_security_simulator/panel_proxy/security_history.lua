require "common.c4_history"

--[[=============================================================================
    Records a Critical Security event with the history agent.
===============================================================================]]
function RecordCriticalSecurityEvent(eventType, description)
	RecordHistoricalEvent("Critical", "Security", "Panel", eventType, description)
end

--[[=============================================================================
    Records an Info Security event with the history agent.
===============================================================================]]
function RecordInfoSecurityEvent(eventType, description)
	RecordHistoricalEvent("Info", "Security", "Panel", eventType, description)
end

--[[=============================================================================
    Records a Warning Security event with the history agent.
===============================================================================]]
function RecordWarningSecurityEvent(eventType, description)
	RecordHistoricalEvent("Warning", "Security", "Panel", eventType, description)
end
