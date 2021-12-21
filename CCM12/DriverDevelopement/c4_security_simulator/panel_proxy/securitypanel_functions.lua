--[[=============================================================================
    Functions dealing with the management of panel information, zones and their
    states, as well as pgms and their states

    Copyright 2015 Control4 Corporation. All Rights Reserved.
===============================================================================]]
TEMPLATE_VERSION.securitypanel = "6"

--[[=============================================================================
    IsPgmValid(PgmID)

    Description: 
    Identifies whether or not the given PgmID has been added to the system

    Parameters:
    PgmID(int) - The number for the pgm in question

    Returns:
    A boolean indicating the validity of the specified pgm
===============================================================================]]
function IsPgmValid(PgmID)
	if (PgmInfoList[tonumber(PgmID)] == nil) then
		return false
	else
		return true
	end
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
function SetPgmState(PgmID, IsOpen, Initializing)
	if (PgmInfoList[PgmID] == nil) then
		AddPgm(PgmID)
	end

	PgmInfoList[PgmID]:SetPgmState(IsOpen, Initializing)
end

--[[=============================================================================
    IsPgmOpen(PgmID)

    Description: 
    Identifies whether or not the specified zone is open

    Parameters:
    PgmID(int) - The number for the pgm whose open state is in question

    Returns:
    A boolean indicating the open state of the given pgm
===============================================================================]]
function IsPgmOpen(PgmID)
	if (PgmInfoList[PgmID] == nil) then
		return false
	end
	
	return PgmInfoList[PgmID]:GetPgmState()
end

--[[=============================================================================
    AddPgm(PgmID)

    Description: 
    Adds the specified Pgm to the managed list

    Parameters:
    PgmID(int) - The number of the pgm that is being added
===============================================================================]]
function AddPgm(PgmID)
	TheSecurityPanel:AddPgm(PgmID)
end

--[[=============================================================================
    RemovePgm(PgmID)

    Description: 
    Removes the specified Pgm from the managed list

    Parameters:
    PgmID(int) - The number of the pgm that is being removed
===============================================================================]]
function RemovePgm(PgmID)
	TheSecurityPanel:RemovePgm(PgmID)
end

--[[=============================================================================
    IsZoneValid(ZoneID)

    Description: 
    Identifies whether or not the given ZoneID has been added to the system

    Parameters:
    ZoneID(int) - The number for the zone in question

    Returns:
    A boolean indicating the validity of the specified zone
===============================================================================]]
function IsZoneValid(ZoneID)
	if (ZoneInfoList[tonumber(ZoneID)] == nil) then
		return false
	else
		return true
	end
end

--[[=============================================================================
    IsZoneBypassed(ZoneID)

    Description: 
    Identifies whether or not the specified zone id has been bypassed

    Parameters:
    ZoneID(int) - The number for the zone whose bypass state is in question

    Returns:
    A boolean indicating the bypass state of the given zone
===============================================================================]]
function IsZoneBypassed(ZoneID)
	return ZoneInfoList[tonumber(ZoneID)]:IsBypassed()
end

--[[=============================================================================
    IsZoneOpen(ZoneID)

    Description: 
    Identifies whether or not the specified zone is open

    Parameters:
    ZoneID(int) - The number for the zone whose open state is in question

    Returns:
    A boolean indicating the open state of the given zone
===============================================================================]]
function IsZoneOpen(ZoneID)
	return ZoneInfoList[tonumber(ZoneID)]:IsOpen()
end

--[[=============================================================================
    GetZoneType(ZoneID)

    Description: 
    Identifies the type of the zone specified

    Parameters:
    ZoneID(int) - The number for the zone whose type is in question

    Returns:
    The panels zone type
===============================================================================]]
function GetZoneType(ZoneID)
	return ZoneInfoList[tonumber(ZoneID)]:GetZoneType()
end

--[[=============================================================================
    SetZoneInfo(ZoneID, ZoneName, ZoneTypeID, ZoneTypeID_C4)

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
function SetZoneInfo(ZoneID, ZoneName, ZoneTypeID, ZoneTypeID_C4)
	local nZoneID = tonumber(ZoneID)

	if (ZoneInfoList[nZoneID] == nil) then
		ZoneInformation:new(nZoneID)
	end

	return ZoneInfoList[nZoneID]:SetZoneInfo(ZoneName, ZoneTypeID, ZoneTypeID_C4)
end

--[[=============================================================================
    RemoveZone(ZoneID)

    Description:
    Removes the specified zone number from the list of managed/monitored zones

    Parameters:
    ZoneID(int) - The number for the zone that is being removed
===============================================================================]]
function RemoveZone(ZoneID)
	TheSecurityPanel:RemoveZone(ZoneID)
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
function SetZoneState(ZoneID, IsOpen, Initializing)
	if (ZoneInfoList[tonumber(ZoneID)] ~= nil) then
		ZoneInfoList[tonumber(ZoneID)]:SetZoneState(IsOpen, Initializing)
	end
end

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
function SetZoneBypassState(ZoneID, IsBypassed, Initializing)
	if (ZoneInfoList[tonumber(ZoneID)] ~= nil) then
		ZoneInfoList[tonumber(ZoneID)]:SetBypassState(IsBypassed, Initializing)
	end
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
function StartTroubleCondition(TroubleMessage)
	return TheSecurityPanel:TroubleStart(TroubleMessage)
end

--[[=============================================================================
    ClearTroubleCondition(Identifier)

    Description: 
    Clears the trouble condition with the panel

    Parameters:
    Identifier(string) - An identifier to uniquely identify this trouble
                         condition with the panel.
===============================================================================]]
function ClearTroubleCondition(Identifier)
	TheSecurityPanel:TroubleClear(Identifier)
end