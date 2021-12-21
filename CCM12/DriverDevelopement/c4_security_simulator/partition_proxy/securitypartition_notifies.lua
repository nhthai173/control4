--[[=============================================================================
    Notifications for the SecurityPartition Proxy

    Copyright 2015 Control4 Corporation. All Rights Reserved.
===============================================================================]]
require "common.c4_notify"

TEMPLATE_VERSION.securitypartition = "9"

function NOTIFY.DISPLAY_TEXT(DispText, BindingID)
	local DisplayTextParams = {}

	LogTrace("Sending Display Text on Binding %s: %s", tostring(BindingID), tostring(DispText))
	C4:SendToProxy(BindingID, "DISPLAY_TEXT", DispText)
end

function NOTIFY.PARTITION_STATE(NewPartitionState, StateType, DelayTotal, DelayRemaining, BindingID)
	local StateParams = {}

	LogTrace("NOTIFY.PARTITION_STATE  %s  >>%s<<  %d %d %d", tostring(NewPartitionState), tostring(StateType), tonumber(DelayTotal), tonumber(DelayRemaining), tonumber(BindingID))
	StateParams["STATE"] = NewPartitionState
	StateParams["TYPE"] = StateType
	StateParams["DELAY_TIME_TOTAL"] = DelayTotal
	StateParams["DELAY_TIME_REMAINING"] = DelayRemaining

	SendNotify("PARTITION_STATE", StateParams, BindingID)
end

function NOTIFY.PARTITION_STATE_INIT(NewPartitionState, StateType, DelayTotal, DelayRemaining, BindingID)
	local StateParams = {}

	LogTrace("NOTIFY.PARTITION_STATE_INIT: %s %s %d %d %d", tostring(NewPartitionState), tostring(StateType), tonumber(DelayTotal), tonumber(DelayRemaining), tonumber(BindingID))
	StateParams["STATE"] = NewPartitionState
	StateParams["TYPE"] = StateType
	StateParams["DELAY_TIME_TOTAL"] = DelayTotal
	StateParams["DELAY_TIME_REMAINING"] = DelayRemaining

	SendNotify("PARTITION_STATE_INIT", StateParams, BindingID)
end

function NOTIFY.PARTITION_ENABLED(IsEnabled, BindingID)
	local EnabledParams = {}

	LogTrace("NOTIFY.PARTITION_ENABLED: %s %d", tostring(IsEnabled), tonumber(BindingID))
	EnabledParams["ENABLED"] = tostring(IsEnabled)

	SendNotify("PARTITION_ENABLED", EnabledParams, BindingID)
end

function NOTIFY.ZONE_STATE(ZoneID, IsOpen, IsBypassed, BindingID)
	local StateParams = {}

	LogTrace("NOTIFY.ZONE_STATE: %d %s %s %d", tonumber(ZoneID), tostring(IsOpen), tostring(IsBypassed), tonumber(BindingID))
	StateParams["ZONE_ID"] = tostring(ZoneID)
	StateParams["ZONE_OPEN"] = tostring(IsOpen)
	StateParams["ZONE_BYPASSED"] = tostring(IsBypassed)

	SendNotify("ZONE_STATE", StateParams, BindingID)
end

function NOTIFY.EMERGENCY_TRIGGERED(EmergencyType, BindingID)
	local TriggerParams = {}

	LogTrace("Sending EMERGENCY_TRIGGERED: >>%s<< on binding: %d", tostring(EmergencyType), tonumber(BindingID))
	TriggerParams["TYPE"] = EmergencyType

	SendNotify("EMERGENCY_TRIGGERED", TriggerParams, BindingID)
end

function NOTIFY.DISARM_FAILED(BindingID)
	LogTrace("NOTIFY.DISARM_FAILED: %d", tonumber(BindingID))

	SendNotify("DISARM_FAILED", {}, BindingID)
end

function NOTIFY.ARM_FAILED(Action, BindingID)
	local ArmFailedParams = { ACTION=Action }

	LogTrace("NOTIFY.ARM_FAILED: %s %d", tostring(Action), tonumber(BindingID))
	SendNotify("ARM_FAILED", ArmFailedParams, BindingID)
end

function NOTIFY.REQUEST_KEYPAD_INFO(DeviceID, FunctionName, Prompt, Parms, BindingID)
	local ParmList = {}

	LogTrace("NOTIFY.REQUEST_KEYPAD_INFO: %s %s %s %d", tostring(DeviceID), tostring(FunctionName), tostring(Prompt), tonumber(BindingID))
	ParmList["PROMPT"] = Prompt
	ParmList["DEVICE_ID"] = DeviceID
	ParmList["PARAMETERS"] = table.concat(Parms, " ")
	ParmList["FUNCTION_NAME"] = FunctionName

	SendNotify("REQUEST_KEYPAD_INFO", ParmList, BindingID)
end

function NOTIFY.HAS_ZONE(ZoneID, BindingID)
	local ZoneParams = {}

	LogTrace("NOTIFY.HAS_ZONE: %d %d", tonumber(ZoneID), tonumber(BindingID))
	ZoneParams["ZONE_ID"] = tostring(ZoneID)

	SendNotify("HAS_ZONE", ZoneParams, BindingID)
end

function NOTIFY.REMOVE_ZONE(ZoneID, BindingID)
	local ZoneParams = {}

	LogTrace("NOTIFY.REMOVE_ZONE: %d %d", tonumber(ZoneID), tonumber(BindingID))
	ZoneParams["ZONE_ID"] = tostring(ZoneID)

	SendNotify("REMOVE_ZONE", ZoneParams, BindingID)
end

function NOTIFY.CLEAR_ZONE_LIST(BindingID)
	LogTrace("NOTIFY.CLEAR_ZONE_LIST: %d", tonumber(BindingID))

	SendNotify("CLEAR_ZONE_LIST", "", BindingID)
end

function NOTIFY.CODE_REQUIRED(CodeRequiredToArm, BindingID)
	local NotifyParams = {}

	LogTrace("Sending CODE_REQUIRED: >>%s<< on binding: %d", tostring(CodeRequiredToArm), tonumber(BindingID))
	NotifyParams["CODE_REQUIRED_TO_ARM"] = tostring(CodeRequiredToArm)

	C4:SendToProxy(BindingID, "CODE_REQUIRED", NotifyParams)
end

function NOTIFY.PARTITION_INFO(xml, BindingID)
	LogTrace("NOTIFY.PARTITION_INFO: %s %d", tostring(xml), tonumber(BindingID))

	C4:SendToProxy(BindingID, "PARTITION_INFO", xml)
end
