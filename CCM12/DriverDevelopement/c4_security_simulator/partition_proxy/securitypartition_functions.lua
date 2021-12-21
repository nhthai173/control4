--[[=============================================================================
    Functions dealing with the management of partitions and their states

    Copyright 2015 Control4 Corporation. All Rights Reserved.
===============================================================================]]
TEMPLATE_VERSION.securitypartition = "9"

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
function ArmPartitionFailed(PartitionID, Action)
	if (SecurityPartitionIndexList[tonumber(PartitionID)] ~= nil) then
		SecurityPartitionIndexList[tonumber(PartitionID)]:ArmFailed(Action)
	end
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
function DisarmPartitionFailed(PartitionID)
	if (SecurityPartitionIndexList[tonumber(PartitionID)] ~= nil) then
		SecurityPartitionIndexList[tonumber(PartitionID)]:DisarmFailed()
	end
end

--[[=============================================================================
    RequestInfo(PartitionID, DeviceID, FunctionName, Prompt, ParmList)

    Description: 
    Notify the interface that initiated a call to display keypad and prompt for
    a particular input

    Parameters:
    PartitionID(int)     - The index of the partition we are getting the list from
    DeviceID(int)        - The device id of the navigator who made the initial request
    FunctionName(string) - The name of the function that the interface will send
                           the gathered information back to.
    Prompt(string)       - The text that will be displayed on the keypad when 
                           requesting more input.
    ParmList(table)      - A table of values from iterative requests to this 
                           method

    Returns:
    None
===============================================================================]]
function RequestKeypadInfo(PartitionID, DeviceID, FunctionName, Prompt, ParmList)
	if (SecurityPartitionIndexList[tonumber(PartitionID)] ~= nil) then
		SecurityPartitionIndexList[tonumber(PartitionID)]:RequestKeypadInfo(DeviceID, FunctionName, Prompt, ParmList)
	end
end

--[[=============================================================================
    GetPartitionZoneIDs(PartitionID)

    Description: 
    Get the list of zone IDs that are associated with the specified partition

    Parameters:
    PartitionID(int) - The index of the partition we are getting the list from

    Returns:
    A table containing a list of the zone numbers for the specified partition
===============================================================================]]
function GetPartitionZoneIDs(PartitionID)
	if (SecurityPartitionIndexList[tonumber(PartitionID)] ~= nil) then
		return SecurityPartitionIndexList[tonumber(PartitionID)]:GetZoneIDs()
	else
		return nil
	end
end

--[[=============================================================================
    GetPartitionZoneCount(PartitionID)

    Description: 
    Get the count of the zones that are associated with the zone

    Parameters:
    PartitionID(int) - The index of the partition we are getting the count from

    Returns:
    The zone count for the associated partition
===============================================================================]]
function GetPartitionZoneCount(PartitionID)
	if (SecurityPartitionIndexList[tonumber(PartitionID)] ~= nil) then
		return SecurityPartitionIndexList[tonumber(PartitionID)]:GetZoneCount()
	else
		return 0
	end
end

--[[=============================================================================
    AddZoneToPartition(PartitionID, ZoneID)

    Description: 
    Adds the given zone to the specified partition
    Note: SetZoneInfo must be called before this function in order for the call
          to succeed

    Parameters:
    PartitionID(int) - The index of the partition we are adding the zone to
    ZoneID(int)      - The zone id that is being added to the partition

    Returns:
    None
===============================================================================]]
function AddZoneToPartition(PartitionID, ZoneID)
	if (SecurityPartitionIndexList[tonumber(PartitionID)] ~= nil) then

		if (ZoneInfoList[tonumber(ZoneID)] == nil) then
			ZoneInformation:new(tonumber(ZoneID))
		end

		SecurityPartitionIndexList[tonumber(PartitionID)]:AddZone(tonumber(ZoneID))
		ZoneInfoList[tonumber(ZoneID)]:AddToPartition(tonumber(PartitionID))
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
function RemoveZoneFromPartition(PartitionID, ZoneID)
	if (SecurityPartitionIndexList[tonumber(PartitionID)] ~= nil) then
		SecurityPartitionIndexList[tonumber(PartitionID)]:RemoveZone(tonumber(ZoneID))

		if (ZoneInfoList[tonumber(ZoneID)] ~= nil) then
			ZoneInfoList[tonumber(ZoneID)]:RemoveFromPartition(tonumber(PartitionID))
		end
	end
end

--[[=============================================================================
    SetPartitionEnabled(PartitionID, Enabled)

    Description: 
    Marks the specified partition as enabled within the system. If set to false
    the partition will not be visible to the UI.

    Parameters:
    PartitionID(int) - The index of the partition we are enabling or disabling
    Enabled(bool)    - The state of the partition

    Returns:
    None
===============================================================================]]
function SetPartitionEnabled(PartitionID, Enabled)
	if (SecurityPartitionIndexList[tonumber(PartitionID)] ~= nil) then
		SecurityPartitionIndexList[tonumber(PartitionID)]:SetEnabled(Enabled)
	end
end

--[[=============================================================================
    IsPartitionEnabled(PartitionID)

    Description: 
    Identifies whether or not the specified partition is enabled

    Parameters:
    PartitionID(int) - The index of the partition we are checking

    Returns:
    True if the partition is enabled
===============================================================================]]
function IsPartitionEnabled(PartitionID)
	if (SecurityPartitionIndexList[tonumber(PartitionID)] ~= nil) then
		return SecurityPartitionIndexList[tonumber(PartitionID)]:IsEnabled()
	else
		return false
	end
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
function SetPartitionState(PartitionID, State, ArmType, Duration)
	if (SecurityPartitionIndexList[tonumber(PartitionID)] ~= nil) then
		ArmType = ArmType or ""
		Duration = tonumber(Duration) or 0

		SecurityPartitionIndexList[tonumber(PartitionID)]:SetPartitionState(State, ArmType, Duration)
	end
end

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
function GetPartitionState(PartitionID)
	if (SecurityPartitionIndexList[tonumber(PartitionID)] ~= nil) then
		return SecurityPartitionIndexList[tonumber(PartitionID)]:GetPartitionState()
	else
		return "DISARMED_NOT_READY"
	end
end

--[[=============================================================================
    GetPartitionArmType(PartitionID)

    Description: 
    Get the arm type of the partition that was specified by the given PartitionID

    Parameters:
    PartitionID(int) - The index of the partition we are getting the arm type from

    Returns:
    The description of the state for the partition specified by the PartitionID
===============================================================================]]
function GetPartitionArmType(PartitionID)
	if (SecurityPartitionIndexList[tonumber(PartitionID)] ~= nil) then
		return SecurityPartitionIndexList[tonumber(PartitionID)]:GetPartitionArmType()
	else
		return "UNKNOWN"
	end
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
function SetCodeRequiredToArm(PartitionID, CodeRequired)
	if (SecurityPartitionIndexList[tonumber(PartitionID)] ~= nil) then
		SecurityPartitionIndexList[tonumber(PartitionID)]:SetCodeRequiredToArm(CodeRequired)
	end
end

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
function IsPartitionArmed(PartitionID)
	if (SecurityPartitionIndexList[tonumber(PartitionID)] ~= nil) then
		return SecurityPartitionIndexList[tonumber(PartitionID)]:IsArmed()
	else
		return false
	end
end

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
function IsPartitionInDelay(PartitionID)
	if (SecurityPartitionIndexList[tonumber(PartitionID)] ~= nil) then
		return SecurityPartitionIndexList[tonumber(PartitionID)]:IsInDelay()
	else
		return false
	end
end

--[[=============================================================================
    DisplayPartitionText(PartitionID, Message)

    Description: 
    Writes the given message to the specified partition

    Parameters:
    PartitionID(int) - The index of the partition we are writing the message to
    Message(string)  - The message to be written to the UI

    Returns:
    Writes the given message to the display field of the UI
===============================================================================]]
function DisplayPartitionText(PartitionID, Message)

	if (SecurityPartitionIndexList[tonumber(PartitionID)] ~= nil) then
		SecurityPartitionIndexList[tonumber(PartitionID)]:DisplayText(Message)
	end
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
function HaveEmergency(EmergencyName)

	for _, v in pairs(SecurityPartitionIndexList) do
		v:HaveEmergency(EmergencyName)
	end
end