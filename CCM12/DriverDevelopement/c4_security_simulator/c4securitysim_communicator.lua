--[[=============================================================================
    Template code for a Security Panel/Partition serial driver

    Copyright 2014 Control4 Corporation. All Rights Reserved.
===============================================================================]]

require "device_messages"
require "connections"
require "c4securitysim_device"

C4_SECURITY_SIM_MAPPINGS = {
	[C4_SECURITY_SIM_ZONE_TYPES.DOOR] = ZoneTypes.EXTERIOR_DOOR,
	[C4_SECURITY_SIM_ZONE_TYPES.WINDOW] = ZoneTypes.EXTERIOR_WINDOW,
	[C4_SECURITY_SIM_ZONE_TYPES.BURGLARY] = ZoneTypes.CONTACT_SENSOR,
	[C4_SECURITY_SIM_ZONE_TYPES.MOTION] = ZoneTypes.MOTION_SENSOR,
	[C4_SECURITY_SIM_ZONE_TYPES.FIRE] = ZoneTypes.FIRE,
	[C4_SECURITY_SIM_ZONE_TYPES.WATER] = ZoneTypes.WATER,
	[C4_SECURITY_SIM_ZONE_TYPES.SMOKE] = ZoneTypes.SMOKE,
	[C4_SECURITY_SIM_ZONE_TYPES.INTERIOR] = ZoneTypes.INTERIOR_DOOR,
}


--[[=============================================================================
    Interface routines required by the SecurityPanel code
===============================================================================]]
--[[=============================================================================
    Convert the given date/time parameters into the format required by the security panel
===============================================================================]]
function SecCom_SendDateAndTime(TargYear, TargMonth, TargDay, TargHour, TargMinute, TargSecond)
	local SerCmdStr = string.format("UC_DATE_TIME %d %d %d %d %d %d", TargYear, TargMonth, TargDay, TargHour, TargMinute, TargSecond)
	SendCommand(SerCmdStr)
end

--[[=============================================================================
    Convert the given zone parameters into the format required by the panel
===============================================================================]]
function SecCom_SendSetZoneInfo(ZoneID, ZoneName, ZoneType)

	function ConvertToC4SecuritySimTypeID(C4TypeID)
		local RetVal = C4_SECURITY_SIM_ZONE_TYPE_DEFAULT
		
		for k,v in pairs(C4_SECURITY_SIM_MAPPINGS) do
			if(v == ZoneType) then
				RetVal = k
			end
		end
		
		return RetVal
	end

	local C4SecuritySimZoneTypeID = ConvertToC4SecuritySimTypeID(ZoneTypeID)
	
	local SerCmdStr = string.format("UC_SET_ZONE_INFO %d %s %d", ZoneID, uglom(ZoneName), C4SecuritySimZoneTypeID)
	SendCommand(SerCmdStr)
end

--[[=============================================================================
    Tell the panel to activate or de-activate a specific partition
	
	Note:  Not all panels will allow this
===============================================================================]]
function SecCom_SendPartitionEnabled(PartitionIndex, IsEnabled)
	local SerCmdStr = string.format("UC_SET_PARTITION_ENABLED %d %s", PartitionIndex, tostring(IsEnabled))
	SendCommand(SerCmdStr)
end

--[[=============================================================================
    Interface routines required by the SecurityParition code
===============================================================================]]
--[[=============================================================================
    Convert the given arm parameters into the format required by the panel
===============================================================================]]
function SecCom_SendArmPartition(PartitionIndex, ArmType, UserCode, Bypass)
	local SerCmdStr = string.format("UC_ARM_PARTITION %d %s %s %s", PartitionIndex, uglom(ArmType), uglom(UserCode), tostring(Bypass))
	SendCommand(SerCmdStr)
end

--[[=============================================================================
    Convert the given disarm parameters into the format required by the panel
===============================================================================]]
function SecCom_SendDisarmPartition(PartitionIndex, UserCode)
	local SerCmdStr = string.format("UC_DISARM_PARTITION %d %s", PartitionIndex, uglom(UserCode))
	SendCommand(SerCmdStr)
end


--[[=============================================================================
    Convert the given emergency parameters into the format required by the panel
===============================================================================]]
function SecCom_SendExecuteEmergency(PartitionIndex, EmergencyType)
	local SerCmdStr = string.format("UC_EMERGENCY %d %s", PartitionIndex, uglom(EmergencyType))
	SendCommand(SerCmdStr)
end

--[[=============================================================================
    Convert the given bypass/unbypass parameters into the format required by the
    panel for the specified partition
===============================================================================]]
function SecCom_SendBypassZoneCommand(PartitionIndex, ZoneID, DoBypass, UserCode)
	local SerCmdStr = string.format("UC_ZONE_BYPASS %d %d %s", PartitionIndex, ZoneID, tostring(DoBypass))
	SendCommand(SerCmdStr)
end

--[[=============================================================================
    Send a single key press from the UI keypad to the hardware
===============================================================================]]
function SecCom_SendKeyPress(PartitionIndex, KeyValue)
	local SerCmdStr = string.format("UC_KEY_PRESS %d %s", PartitionIndex, KeyValue)
	SendCommand(SerCmdStr)
end


--[[=============================================================================
    The following functions are called from the PgmInfo code 
===============================================================================]]
--[[=============================================================================
	Send the open control command to the specified zone
===============================================================================]]
function SecCom_SendPgmControlOpen(PgmID)
	local SerCmdStr = string.format("UC_CONTROL_PGM %d Open", PgmID)
	SendCommand(SerCmdStr)
end

--[[=============================================================================
    Send the closed control command to the specified pgm
===============================================================================]]
function SecCom_SendPgmControlClose(PgmID)
	local SerCmdStr = string.format("UC_CONTROL_PGM %d Close", PgmID)
	SendCommand(SerCmdStr)
end

--[[=============================================================================
    Send the control command to toggle the current state of the specified pgm
===============================================================================]]
function SecCom_SendPgmControlToggle(PgmID)
	local SerCmdStr = string.format("UC_CONTROL_PGM %d Toggle", PgmID)
	SendCommand(SerCmdStr)
end


--[[=============================================================================
=================================================================================
===============================================================================]]




--[[=============================================================================
    AddZoneToPartition(PartitionID, ZoneID)

    Description: 
    Adds the given zone to the specified partition

    Parameters:
    PartitionID(int) - The index of the partition we are adding the zone to
    ZoneID(int)      - The zone id that is being added to the partition

    Returns:
    None
===============================================================================]]

--[[=============================================================================
    RemoveZoneFromPartition(PartitionID, ZoneID)

    Description: 
    Removes the given zone from the specified partition

    Parameters:
    PartitionID(int) - The index of the partition we are adding the zone to
    ZoneID(int)      - The zone id that is being added to the partition

    Returns:
    None
===============================================================================]]

--[[=============================================================================
    SetPartitionEnabled(PartitionID, Enabled)

    Description: 
    Marks the specified partition as enabled within the system. If set to false
    the partition will not be visible to the UI.

    Parameters:
    PartitionID(int) - The index of the partition we are adding the zone to
    Enabled(bool)    - The state of the partition

    Returns:
    None
===============================================================================]]

--[[=============================================================================
    SetCodeRequiredToArm(PartitionID, CodeRequired)

    Description: 
    Tells the system that the given partition requires a code to arm.

    Parameters:
    PartitionID(int)   - The index of the partition we are specifiying the status
    CodeRequired(bool) - True if a code is required to arm the partition, and
                         false otherwise.

    Returns:
    None
===============================================================================]]

--[[=============================================================================
    DisplayPartitionText(PartitionID, Message, LineNumber)

    Description: 
    Writes the given message to the specified partition

    Parameters:
    PartitionID(int) - The index of the partition we are writing the message to
    Message(string)  - The message to be written to the UI

    Returns:
    Writes the given message to the display field of the UI
===============================================================================]]

--[[=============================================================================
=================================================================================
===============================================================================]]

--[[=============================================================================
    IsPgmOpen(PgmID)

    Description: 
    Identifies whether or not the specified zone is open

    Parameters:
    PgmID(int) - The number for the pgm whose open state is in question

    Returns:
    A boolean indicating the open state of the given pgm
===============================================================================]]

--[[=============================================================================
    IsZoneBypassed(ZoneID)

    Description: 
    Identifies whether or not the specified zone id has been bypassed

    Parameters:
    ZoneID(int) - The number for the zone whose bypass state is in question

    Returns:
    A boolean indicating the bypass state of the given zone
===============================================================================]]

--[[=============================================================================
    IsZoneOpen(ZoneID)

    Description: 
    Identifies whether or not the specified zone is open

    Parameters:
    ZoneID(int) - The number for the zone whose open state is in question

    Returns:
    A boolean indicating the open state of the given zone
===============================================================================]]

--[[=============================================================================
    GetZoneType(ZoneID)

    Description: 
    Identifies the type of the zone specified

    Parameters:
    ZoneID(int) - The number for the zone whose type is in question

    Returns:
    The panels zone type
===============================================================================]]

--[[=============================================================================
    GetPartitionZoneCount(PartitionID)

    Description: 
    Get the count of the zones that are associated with the zone

    Parameters:
    PartitionID(int) - The index of the partition we are getting the count from

    Returns:
    The zone count for the associated partition
===============================================================================]]

--[[=============================================================================
    GetPartitionZoneIDs(PartitionID)

    Description: 
    Get the list of zone IDs that are associated with the specified partition

    Parameters:
    PartitionID(int) - The index of the partition we are getting the list from

    Returns:
    A table containing a list of the zone numbers for the specified partition
===============================================================================]]

--[[=============================================================================
    GetPartitionState(PartitionID)

    Description:
    Get the state of the partition that was specified by the given PartitionID

    Parameters:
    PartitionID(int) - The index of the partition we are getting the state from

    Returns:
    The state of the partition specified by the PartitionID
    Following are a list of states that should be returned (ARMED, ALARM, 
    DISARMED_NOT_READY, DISARMED_READY, EXIT_DELAY, and ENTRY_DELAY)
===============================================================================]]

--[[=============================================================================
    GetPartitionArmType(PartitionID)

    Description: 
    Get the arm type of the partition that was specified by the given PartitionID

    Parameters:
    PartitionID(int) - The index of the partition we are getting the arm type from

    Returns:
    The description of the state for the partition specified by the PartitionID
===============================================================================]]

--[[=============================================================================
    IsPartitionArmed(PartitionID)

    Description: 
    Returns the armed state of the partition indicated by PartitionID

    Parameters:
    PartitionID(int) - The index of the partition we are getting the armed
                       status for

    Returns:
    The armed state of the partition specified
===============================================================================]]

--[[=============================================================================
    IsPartitionInDelay(PartitionID)

    Description: 
    Returns the delay information for the partition indicated by PartitionID

    Parameters:
    PartitionID(int) - The index of the partition we are getting delay
                       information for

    Returns:
    True if the Partition is currently in a delay state, false otherwise
===============================================================================]]

--[[=============================================================================
    IsPartitionEnabled(PartitionID)

    Description: 
    Identifies whether or not the specified partition is enabled

    Parameters:
    PartitionID(int) - The index of the partition we are checking

    Returns:
	True if the partition is enabled
===============================================================================]]

---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------
-- Routines to handle messages from the serial port
----------------------------------------------------------------------------------------------


--[[=============================================================================
    ArmPartitionFailed(PartitionID, Action)

    Description: 
    Notifies the system that an arm partition has failed, and tells the UI what
    action if any needs to be taken in order to proceed.

    Parameters:
    PartitionID(int) - The index of the partition we are arming
    Action(string)   - Indicates the action that the UI should take to help 
                       rectify. Following is a list of actions that can be
                       taken keypad(if a keycode is needed), bypass, or
                       NA(general failure)

    Returns:
    None
===============================================================================]]
function DEV_MSG.U_ARM_FAILED(MsgData)
	local Parms = StringSplit(MsgData)
	local PartitionID = tonumber(Parms[1])
	local FailReason = ufix(Parms[2])
	local Next = ufix(Parms[3])
	local Action = "NA"
	if (Next == "K") then Action = "KEYPAD" end
	if (Next == "B") then Action = "BYPASS" end

    ArmPartitionFailed(PartitionID, Action)
end


--[[=============================================================================
    DisarmPartitionFailed(PartitionID)

    Description: 
    Notifies the system that a disarm partition has failed.

    Parameters:
    PartitionID(int) - The index of the partition we are disarming

    Returns:
    None
===============================================================================]]

function DEV_MSG.U_DISARM_FAILED(MsgData)
	local Parms = StringSplit(MsgData)
	local PartitionID = tonumber(Parms[1])
	local FailReason = ufix(Parms[2])

    DisarmPartitionFailed(PartitionID)
end


--[[=============================================================================
    SetZoneInfo(ZoneID, ZoneName, ZoneTypeID, C4ZoneTypeID)

    Description: 
    Set the details for the specified zones

    Parameters:
    ZoneID(int)       - The number for the zone whose state is being set
    ZoneName(string)  - The identifying label of the zone
    ZoneTypeID(int)   - The zone type from the perspective of the vendor
    C4ZoneTypeID(int) - The control4 zone type that maps the vendor specific 
                        type with the control4 sensor types.

    Control4 Zone Types
    ==========================
    Unknown         = 0
    Contact Sensor  = 1
    Exterior Door   = 2
    Exterior Window = 3
    Interior Door   = 4
    Motion Sensor   = 5
    Fire            = 6
    Gas             = 7
    Carbon Monoxide = 8
    Heat            = 9
    Water           = 10
    Smoke           = 11
    Pressure        = 12
    Glass Break     = 13
    Gate            = 14
    Garage Door     = 15
===============================================================================]]

--[[=============================================================================
    SetZoneState(ZoneID, IsOpen, Initializing)

    Description: 
    Sets the specified zones state with the system

    Parameters:
    ZoneID(int)        - The number for the zone whose state is being set
    IsOpen(bool)       - Indicates the state of the specified zone
    Initializing(bool) - Indicates whether this is the initialization of the
                         zone. If true then the programming events within the 
                         system will not be fired.
===============================================================================]]

--[[=============================================================================
    SetZoneBypassState(ZoneID, IsBypassed, Initializing)

    Description: 
    Sets the specified zones bypass state with the system

    Parameters:
    ZoneID(int)        - The number for the zone whose state is being set
    IsBypassed(bool)   - Indicates whether the zone has been bypassed for the
                         specified zone
    Initializing(bool) - Indicates whether this is the initialization of the
                         zone. If true then the programming events within the 
                         system will not be fired.
===============================================================================]]

function DEV_MSG.U_ZONE_SETUP(MsgData)
	local Parms = StringSplit(MsgData)
	local ZoneID = tonumber(Parms[1])
	local ZoneName = ufix(Parms[2])
	local C4SecuritySimZoneTypeID = tonumber(Parms[3])
	local Partitions = ufix(Parms[4])
	local ZoneState = Parms[5]
	local BypassState = Parms[6]

    SetZoneInfo(ZoneID, ZoneName, C4SecuritySimZoneTypeID, C4_SECURITY_SIM_MAPPINGS[C4SecuritySimZoneTypeID])
	SetZoneState(ZoneID, ZoneState == "Open", true)
    SetZoneBypassState(ZoneID, BypassState == "Bypassed", true)

	if(Partitions ~= "0") then
		local PartitionTable = {}
		for match in (Partitions..","):gmatch("(.-)"..",") do
			table.insert(PartitionTable, match)
		end

		for k, PartitionIndex in pairs(PartitionTable) do
			AddZoneToPartition(tonumber(PartitionIndex), ZoneID)	
		end
	end
		
end

--[[=============================================================================
    RemoveZoneFromPartition(PartitionID, ZoneID)

    Description: 
    Removes the given zone from the specified partition

    Parameters:
    PartitionID(int) - The index of the partition we are adding the zone to
    ZoneID(int)      - The zone id that is being added to the partition

    Returns:
    None
===============================================================================]]
function DEV_MSG.U_REMOVE_ZONE(MsgData)
	local Parms = StringSplit(MsgData)
	local ZoneID = tonumber(Parms[1])

	RemoveZone(ZoneID)
end


--[[=============================================================================
    SetZoneState(ZoneID, IsOpen, Initializing)

    Description: 
    Sets the specified zones state with the system

    Parameters:
    ZoneID(int)        - The number for the zone whose state is being set
    IsOpen(bool)       - Indicates the state of the specified zone
    Initializing(bool) - Indicates whether this is the initialization of the
                         zone. If true then the programming events within the 
                         system will not be fired.
===============================================================================]]

function DEV_MSG.U_ZONE_STATE(MsgData)
	local Parms = StringSplit(MsgData)
	local ZoneID = tonumber(Parms[1])
	local ZoneState = Parms[2]
	local BypassState = Parms[3]

	SetZoneState(ZoneID, ZoneState == "Open", false)
    SetZoneBypassState(ZoneID, BypassState == "Bypassed", false)
end


--[[=============================================================================
    SetPgmState(PgmID, IsOpen, Initializing)

    Description: 
    Sets the state of the specified pgm

    Parameters:
    PgmID(int)         - The number for the pgm whose state is being set
    IsOpen(bool)       - Indicates the state of the specified pgm
    Initializing(bool) - Indicates whether this is the initialization of the
                         pgm. If true then the programming events within the 
                         system will not be fired.

    Returns:
    None
===============================================================================]]
function DEV_MSG.U_PGM_STATE(MsgData)
	local Parms = StringSplit(MsgData)
	local PgmID = tonumber(Parms[1])
	local PgmState = Parms[2]

    SetPgmState(PgmID, PgmState == "Open", false)
end


function DEV_MSG.U_PGM_SETUP(MsgData)
	local Parms = StringSplit(MsgData)
	local PgmID = tonumber(Parms[1])

    AddPgm(PgmID)
end


function DEV_MSG.U_REMOVE_PGM(MsgData)
	local Parms = StringSplit(MsgData)
	local PgmID = tonumber(Parms[1])

    RemovePgm(PgmID)
end


--[[=============================================================================
    SetPartitionState(PartitionID, State, ArmType, Duration)

    Description: 
    Sets the specified partitions state with the system

    Parameters:
    PartitionID(int) - The number for the partition whose state is being set
    State(string)    - The state of the partition indicated by PartitionID
                       Following are a list of valid states(ARMED, ALARM, 
                       DISARMED_NOT_READY, DISARMED_READY, EXIT_DELAY,
                       and ENTRY_DELAY)
    ArmType(string)  - Some description to further clarify the partition state.
                       If the state is ARMED, the state type might be "Home"
                       or "Away".  If the state is ALARM, the state type might
                       be "FIRE" or "BURGLARY". This may also be an empty
                       string for other states.
    Duration(int)    - An optional parameter that is to be used when the state
                       being specified is either (ENTRY_DELAY or EXIT_DELAY)

    Returns:
    None
===============================================================================]]

function DEV_MSG.U_PARTITION_STATE(MsgData)
	local UniStateMap = {
		[UPS_DISARMED_READY]=AS_DISARMED_READY,
		[UPS_DISARMED_NOT_READY]=AS_DISARMED_NOT_READY,
		[UPS_ARMED]=AS_ARMED,
		[UPS_EXIT_DELAY]=AS_EXIT_DELAY,
		[UPS_ENTRY_DELAY]=AS_ENTRY_DELAY,
		[UPS_ALARM]=AS_ALARM,
	}
	
	local Parms = StringSplit(MsgData)
	local PartitionID = tonumber(Parms[1])
	local TargState = UniStateMap[Parms[2]] or AS_DISARMED_NOT_READY
	local StateType = ufix(Parms[3])
	local Duration = ufix(Parms[4])

    SetPartitionState(PartitionID, TargState, StateType, Duration)
end



function DEV_MSG.U_PARTITION_ENABLED(MsgData)
	local Parms = StringSplit(MsgData)
	local PartitionID = tonumber(Parms[1])
	local IsEnabled = toboolean(Parms[2])

    SetPartitionEnabled(PartitionID, IsEnabled)
end


--[[=============================================================================
    HaveEmergency(EmergencyName)

    Description: 
    Notifies all partitions that an emergency has been triggered.

    Parameters:
    EmergencyName(string) - The type of emergency that is being triggered.
                            Current Emergency Types: 
                            Fire, Medical, Police, and Panic.
                            However other strings could be sent if desired. The
                            UI just may not have icons for them

    Returns:
    None
===============================================================================]]

function DEV_MSG.U_EMERGENCY(MsgData)
	local EmergencyName = ufix(MsgData)
	LogTrace("U_EMERGENCY: %s", EmergencyName)
    HaveEmergency(EmergencyName)
end


--[[=============================================================================
    StartTroubleCondition(TroubleMessage)

    Description: 
    Sets the given string as a trouble condition with the panel

    Parameters:
    TroubleMessage(string) - The trouble condition to set for the panel
	
	Returns:
    An identifier to uniquely identify this trouble condition with the panel.
===============================================================================]]
--[[=============================================================================
    ClearTroubleCondition(Identifier)

    Description: 
    Clears the trouble condition with the panel

    Parameters:
    Identifier(string) - An identifier to uniquely identify this trouble
                         condition with the panel.
===============================================================================]]


gLastTroubleID = 0

function DEV_MSG.U_TROUBLE(MsgData)
	local TroubleText = ufix(MsgData)

	LogTrace("U_TROUBLE: %s", TroubleText)

	if(TroubleText ~= "") then
		gLastTroubleID = StartTroubleCondition(TroubleText)
	else
		ClearTroubleCondition(gLastTroubleID)
	end
end


--[[=============================================================================
    DisplayPartitionText(PartitionID, Message, LineNumber)

    Description: 
    Writes the given message to the specified partition

    Parameters:
    PartitionID(int) - The index of the partition we are writing the message to
    Message(string)  - The message to be written to the UI

    Returns:
    Writes the given message to the display field of the UI
===============================================================================]]

gC4SecuritySimDisplayText1 = ""
gC4SecuritySimDisplayText2 = ""

function DEV_MSG.U_DISPLAY_TEXT(MsgData)
	local Parms = StringSplit(MsgData)
	local PartitionID = tonumber(Parms[1])
	local DispText = ufix(Parms[2])
	local LineNumber = tonumber(Parms[3]) or 1
	
	if(LineNumber == 1) then
		gC4SecuritySimDisplayText1 = DispText
	else
		gC4SecuritySimDisplayText2 = DispText
	end

    DisplayPartitionText(PartitionID, gC4SecuritySimDisplayText1 .. '\n' .. gC4SecuritySimDisplayText2)
end

function DEV_MSG.U_CLEAR_DISPLAY_TEXT(MsgData)
	local Parms = StringSplit(MsgData)
	local PartitionID = tonumber(Parms[1])
	
	gC4SecuritySimDisplayText1 = ""
	gC4SecuritySimDisplayText2 = ""

    DisplayPartitionText(PartitionID, "")
end


--[[=============================================================================
    SetCodeRequiredToArm(PartitionID, CodeRequired)

    Description: 
    Tells the system that the given partition requires a code to arm.

    Parameters:
    PartitionID(int)   - The index of the partition we are specifiying the status
    CodeRequired(bool) - True if a code is required to arm the partition, and
                         false otherwise.

    Returns:
    None
===============================================================================]]

function DEV_MSG.U_CODE_REQUIRED_FLAG(MsgData)
	local Parms = StringSplit(MsgData)
	local PartitionID = tonumber(Parms[1])
	local CodeRequiredToArm = toboolean(Parms[2])
	
	SetCodeRequiredToArm(PartitionID, CodeRequiredToArm)
end

