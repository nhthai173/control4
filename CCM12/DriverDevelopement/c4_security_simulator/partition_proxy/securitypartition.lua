--[[=============================================================================
    SecurityPartition Class

    Copyright 2015 Control4 Corporation. All Rights Reserved.
===============================================================================]]
require "common.c4_utils"
require "lib.c4_object"
require "lib.c4_log"
require "partition_proxy.securitypartition_functions"
require "partition_proxy.securitypartition_commands"
require "partition_proxy.securitypartition_notifies"
require "panel_proxy.zone_info"

TEMPLATE_VERSION.securitypartition = "9"

SecurityPartitionIndexList = {}
SecurityPartitionBindingList = {}

SecurityPartitionFunctions = {}

--[[=============================================================================
    ARMED STATES
===============================================================================]]
AS_ARMED = "ARMED"
AS_ALARM = "ALARM"
AS_EXIT_DELAY = "EXIT_DELAY"
AS_ENTRY_DELAY = "ENTRY_DELAY"
AS_DISARMED_READY = "DISARMED_READY"
AS_DISARMED_NOT_READY = "DISARMED_NOT_READY"

SecurityPartition = inheritsFrom(nil)

--[[=============================================================================
    Functions that are meant to be private to the class
===============================================================================]]
function SecurityPartition:construct(PartitionNumber, BindingID)

	self._IsEnabled = true
	self._PartitionNumber = PartitionNumber
	self._BindingID = BindingID
	self._CurrentPartitionState = "Unknown"
	self._InitializingStatus = false
	self._MyZoneList = {}

	self._DelayTimeTotal = 0
	self._DelayTimeRemaining = 0
	self._OpenZoneCount = 0

	self._CodeRequiredToArm = false
	self._InAlarm = false
	self._CurrentAlarmType = ""
	self._CurrentArmType = ""

	SecurityPartitionIndexList[PartitionNumber] = self
	SecurityPartitionBindingList[BindingID] = self
end

function SecurityPartition:InitialSetup()
end

function SecurityPartition:ExitDelay(ExitDelayActive, Duration)
	local ExitDelayMessage = "Exit Delay"

	if (ExitDelayActive) then

		-- Delay On
		if (self._DelayTimeRemaining == 0) then
			self._DelayTimeTotal = Duration
		end

		self._DelayTimeRemaining = Duration
	else

		-- Delay Off
		self._DelayTimeTotal = 0
		self._DelayTimeRemaining = 0
		ExitDelayMessage = ExitDelayMessage .. " Off"
	end

	LogTrace(ExitDelayMessage)
end

function SecurityPartition:EntryDelay(EntryDelayActive, Duration)
	local EntryDelayMessage = "Entry Delay"

	if (not EntryDelayActive) then

		-- Entry Delay Stopped
		self._DelayTimeTotal = 0
		self._DelayTimeRemaining = 0
		EntryDelayMessage = EntryDelayMessage .. " Off"
	else

		if (self._DelayTimeRemaining == 0) then
			self._DelayTimeTotal = Duration
		end

		self._DelayTimeRemaining = Duration
		EntryDelayMessage = EntryDelayMessage .. " On"
	end

	LogTrace(EntryDelayMessage)
end

function SecurityPartition:PartitionXML()
	local PartitionXMLInfo = {}

	table.insert(PartitionXMLInfo, MakeXMLNode("id", tostring(self._PartitionNumber)))
	table.insert(PartitionXMLInfo, MakeXMLNode("enabled", tostring(self._IsEnabled)))
	table.insert(PartitionXMLInfo, MakeXMLNode("binding_id", tostring(self._BindingID)))

	if (self._CurrentPartitionState == "AS_ARMED") then
		table.insert(PartitionXMLInfo, MakeXMLAttrNode("state", tostring(self._CurrentPartitionState), "type", tostring(self._CurrentArmType)))
	elseif (self._CurrentPartitionState == "AS_ALARM") then
		table.insert(PartitionXMLInfo, MakeXMLAttrNode("state", tostring(self._CurrentPartitionState), "type", tostring(self._CurrentAlarmType)))
	else
		table.insert(PartitionXMLInfo, MakeXMLNode("state", tostring(self._CurrentPartitionState)))
	end

	return MakeXMLNode("partition", table.concat(PartitionXMLInfo, "\n"))
end

function SecurityPartition:NotifyPartitionState()
	local StateType = self._InAlarm and self._CurrentAlarmType or self._CurrentArmType

	LogTrace("Partition %d set to partition state %s : %s : %s  Alarm is %s", tonumber(self._PartitionNumber), tostring(self._CurrentPartitionState), tostring(self._CurrentArmType), tostring(self._CurrentAlarmType), tostring(self._InAlarm))
	if (self._InitializingStatus) then
		NOTIFY.PARTITION_STATE_INIT(self._CurrentPartitionState, StateType, self._DelayTimeTotal, self._DelayTimeRemaining, self._BindingID)
	else
		NOTIFY.PARTITION_STATE(self._CurrentPartitionState, StateType, self._DelayTimeTotal, self._DelayTimeRemaining, self._BindingID)
	end

	NOTIFY.PANEL_PARTITION_STATE(self._PartitionNumber, self._CurrentPartitionState, StateType, PANEL_PROXY_BINDINGID)
end

function SecurityPartition:ClearDisplayText()
	NOTIFY.DISPLAY_TEXT("", self._BindingID)
end

--[[=============================================================================
    Functions for handling request from the Partition Proxy
===============================================================================]]
function SecurityPartition:PrxGetCurrentState(tParams)
	LogTrace("GetCurrentState for partition %d", tonumber(self._PartitionNumber))
	NOTIFY.PARTITION_STATE_INIT(self._CurrentPartitionState, self._CurrentArmType, self._DelayTimeTotal, self._DelayTimeRemaining, self._BindingID)
end

function SecurityPartition:PrxPartitionArm(tParams)
	local ArmType = tParams["ArmType"]
	local UserCode = tParams["UserCode"]
	-- local Bypass = tParams["Bypass"]
	local Bypass = true

	if(tParams["InterfaceID"] == "DirectorProgramming") then
		LogTrace("PrxPartitionArm %d %s %s %s", tonumber(self._PartitionNumber), tostring(ArmType), tostring(Properties["User Code"]), tostring(Bypass))
		SecCom_SendArmPartition(self._PartitionNumber, ArmType, tostring(Properties["User Code"]), Bypass)
	else
		LogTrace("PrxPartitionArm %d %s %s %s", tonumber(self._PartitionNumber), tostring(ArmType), tostring(UserCode), tostring(Bypass))
		SecCom_SendArmPartition(self._PartitionNumber, ArmType, UserCode, Bypass)
	end

end

function SecurityPartition:PrxPartitionDisarm(tParams)
	local UserCode = tParams["UserCode"]
	LogTrace("PartitionDisarm")

	if(tParams["InterfaceID"] == "DirectorProgramming") then
		SecCom_SendDisarmPartition(self._PartitionNumber, Properties["User Code"])
	else
		SecCom_SendDisarmPartition(self._PartitionNumber, UserCode)
	end
end

function SecurityPartition:PrxExecuteEmergency(tParams)
	local EmergencyType = tParams["EmergencyType"]

	LogTrace("ExecuteEmergency")
	SecCom_SendExecuteEmergency(self._PartitionNumber, EmergencyType)
end

function SecurityPartition:PrxExecuteFunction(tParams)
	local ParmList = {}
	local DeviceID = tParams["DeviceID"]
	local Parameters = tParams["Parameters"]
	local FunctionName = tParams["Function"]
	local trimmedCommand = string.gsub(FunctionName, " ", "")

	if (Parameters ~= nil) then
		ParmList = StringSplit(Parameters)
	end

	LogTrace("Requested Info from(%s)", tostring(FunctionName))
	if (SecurityPartitionFunctions[FunctionName] ~= nil and type(SecurityPartitionFunctions[FunctionName]) == "function") then
		SecurityPartitionFunctions[FunctionName](self._PartitionNumber, DeviceID, ParmList)
	elseif (SecurityPartitionFunctions[trimmedCommand] ~= nil and type(SecurityPartitionFunctions[trimmedCommand]) == "function") then
		SecurityPartitionFunctions[trimmedCommand](self._PartitionNumber, DeviceID, ParmList)
	else
		LogInfo("ID specified is null or not a function name[%s]", tostring(FunctionName))
	end
end

function SecurityPartition:PrxBypassZone(tParams)
	local ZoneID = tonumber(tParams["ZoneID"])
	local DoBypass = tParams["DoBypass"]
	local UserCode = tParams["UserCode"]
	
	LogTrace("BypassZone")
	SecCom_SendBypassZoneCommand(self._PartitionNumber, ZoneID, DoBypass, UserCode)
end

function SecurityPartition:PrxKeyPress(tParams)
	local KeyName = tParams["KeyName"]

	LogTrace("PrxKeyPress")
	SecCom_SendKeyPress(self._PartitionNumber, KeyName)
end

--[[=============================================================================
    Functions that are wrappered and meant to be exposed to the driver
===============================================================================]]
function SecurityPartition:RequestKeypadInfo(DeviceID, FunctionName, Prompt, ParmList)
	NOTIFY.REQUEST_KEYPAD_INFO(DeviceID, FunctionName, Prompt, ParmList, self._BindingID)
end

function SecurityPartition:ArmFailed(Action)
	NOTIFY.ARM_FAILED(Action, self._BindingID)
end

function SecurityPartition:DisarmFailed()
	NOTIFY.DISARM_FAILED(self._BindingID)
end

function SecurityPartition:GetZoneIDs()
	local i = 1
	local s = {}

	for k, _ in pairs(self._MyZoneList) do
		s[i] = k
		i = i + 1
	end

	return s
end

function SecurityPartition:GetZoneCount()
	local i = 0

	for _, _ in pairs(self._MyZoneList) do
		i = i + 1
	end

	return i
end

function SecurityPartition:AddZone(ZoneID)
	local TargZone = ZoneInfoList[tonumber(ZoneID)]

	if (TargZone ~= nil) then
		self._MyZoneList[ZoneID] = TargZone
		NOTIFY.HAS_ZONE(ZoneID, self._BindingID)
	end
end

function SecurityPartition:RemoveZone(ZoneID)
	local TargZone = ZoneInfoList[tonumber(ZoneID)]

	if (TargZone ~= nil) then
		self._MyZoneList[ZoneID] = nil
		NOTIFY.REMOVE_ZONE(ZoneID, self._BindingID)
	end
end

function SecurityPartition:SetEnabled(Enabled)
	if(self._IsEnabled ~= Enabled) then
		self._IsEnabled = Enabled
		NOTIFY.PARTITION_ENABLED(self._IsEnabled, self._BindingID)
	end
end

function SecurityPartition:IsEnabled()
	return self._IsEnabled
end

function SecurityPartition:SetPartitionState(NewState, NewArmType, Duration)

	LogTrace("Partition %d changed state to %s : %s From %s", tonumber(self._PartitionNumber), tostring(NewState), tostring(NewArmType), tostring(self._CurrentPartitionState))
	if (self._CurrentPartitionState ~= NewState) then
		local previousState = self._CurrentPartitionState
	
		self._CurrentPartitionState = NewState
		if (self._CurrentPartitionState == AS_ALARM) then
			self._InAlarm = true
			self._CurrentAlarmType = NewArmType
		else
			self._InAlarm = false
			self._CurrentAlarmType = ""
			self._CurrentArmType = NewArmType
		end

		if (NewState == AS_EXIT_DELAY) then
			self:ExitDelay(true, Duration)
		elseif (NewState == AS_ENTRY_DELAY) then
			self:EntryDelay(true, Duration)
		elseif (previousState == AS_EXIT_DELAY) then
			self:ExitDelay(false, Duration)
		elseif (previousState == AS_ENTRY_DELAY) then
			self:EntryDelay(false, Duration)
		end

		self:ClearDisplayText()
		self:NotifyPartitionState()
	end
end

function SecurityPartition:HaveEmergency(EmergencyType)
	NOTIFY.EMERGENCY_TRIGGERED(EmergencyType, self._BindingID)
end

function SecurityPartition:DisplayText(Message)
	NOTIFY.DISPLAY_TEXT(Message, self._BindingID)
end

function SecurityPartition:SetCodeRequiredToArm(CodeRequired)
	self._CodeRequiredToArm = CodeRequired
	NOTIFY.CODE_REQUIRED(self._CodeRequiredToArm, self._BindingID)
end

function SecurityPartition:GetPartitionState()
	return self._CurrentPartitionState
end

function SecurityPartition:GetPartitionArmType()
	return self._CurrentArmType
end

function SecurityPartition:IsArmed()
	return ((self._CurrentPartitionState == AS_ARMED) or
	        (self._CurrentPartitionState == AS_ENTRY_DELAY) or
	        (self._CurrentPartitionState == AS_ALARM))
end

function SecurityPartition:IsInDelay()
	return ((self._CurrentPartitionState == AS_EXIT_DELAY) or
	        (self._CurrentPartitionState == AS_ENTRY_DELAY))
end
