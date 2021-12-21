--[[=============================================================================
    Notifies for the SecurityPanel Proxy

    Copyright 2015 Control4 Corporation. All Rights Reserved.
===============================================================================]]
require "common.c4_notify"

TEMPLATE_VERSION.securitypanel = "6"

function NOTIFY.PANEL_ZONE_STATE(ZoneID, IsOpen, BindingID)
	local ZoneParams = {}

	LogTrace("NOTIFY.PANEL_ZONE_STATE: %d %s %d", tonumber(ZoneID), tostring(IsOpen), tonumber(BindingID))
	ZoneParams["ZONE_ID"] = ZoneID
	ZoneParams["ZONE_OPEN"] = IsOpen

	SendNotify("PANEL_ZONE_STATE", ZoneParams, BindingID)
end

function NOTIFY.PANEL_PGM_STATE(PgmID, IsOpen, BindingID)
	local PgmParams = {}

	LogTrace("NOTIFY.PANEL_PGM_STATE: %d %s %d", tonumber(PgmID), tostring(IsOpen), tonumber(BindingID))
	PgmParams["PGM_ID"] = PgmID
	PgmParams["PGM_OPEN"] = IsOpen

	SendNotify("PANEL_PGM_STATE", PgmParams, BindingID)
end

function NOTIFY.PANEL_ADD_PGM(PgmID, BindingID)
	local AddPgmParams = {}

	LogTrace("NOTIFY.PANEL_ADD_PGM: %d %d", tonumber(PgmID), tonumber(BindingID))
	AddPgmParams["ID"] = PgmID

	SendNotify("PANEL_ADD_PGM", AddPgmParams, BindingID)
end

function NOTIFY.PANEL_REMOVE_PGM(PgmID, BindingID)
	local RemovePgmParams = {}
	
	LogTrace("NOTIFY.PANEL_REMOVE_PGM: %d %d", tonumber(PgmID), tonumber(BindingID))
	RemovePgmParams["ID"] = PgmID
	
	SendNotify("PANEL_REMOVE_PGM", RemovePgmParams, BindingID)
end

function NOTIFY.PANEL_PARTITION_STATE(PartitionID, PartitionState, StateType, BindingID)
	local PartitionParams = {}

	LogTrace("NOTIFY.PANEL_PARTITION_STATE: %d %s %s %d", tonumber(PartitionID), tostring(PartitionState), tostring(StateType), tonumber(BindingID))
	PartitionParams["PARTITION_ID"] = PartitionID
	PartitionParams["STATE"] = PartitionState
	PartitionParams["TYPE"] = StateType

	SendNotify("PANEL_PARTITION_STATE", PartitionParams, BindingID)
end

function NOTIFY.PANEL_ZONE_INFO(ZoneID, ZoneName, ZoneTypeID, Partitions, IsOpen, BindingID)
	local ZoneInfoParams = {}

	LogTrace("NOTIFY.PANEL_ZONE_INFO: %d %s %d %d", tonumber(ZoneID), tostring(ZoneName), tonumber(ZoneTypeID), tonumber(BindingID))
	ZoneInfoParams["ID"] = ZoneID
	ZoneInfoParams["NAME"] = ZoneName
	ZoneInfoParams["TYPE_ID"] = ZoneTypeID
	ZoneInfoParams["PARTITIONS"] = Partitions
	ZoneInfoParams["IS_OPEN"] = tostring(IsOpen)

	SendNotify("PANEL_ZONE_INFO", ZoneInfoParams, BindingID)
end

function NOTIFY.PANEL_REMOVE_ZONE(ZoneID, BindingID)
	local RemoveZoneParams = {}
	
	LogTrace("NOTIFY.PANEL_REMOVE_ZONE: %d %d", tonumber(ZoneID), tonumber(BindingID))
	RemoveZoneParams["ID"] = ZoneID
	
	SendNotify("PANEL_REMOVE_ZONE", RemoveZoneParams, BindingID)
end

function NOTIFY.TROUBLE_START(TroubleText, Identifier, BindingID)
	local TroubleParams = {}

	LogTrace("NOTIFY.TROUBLE_START: %s %s %d", tostring(TroubleText), tostring(Identifier), tonumber(BindingID))
	TroubleParams["TROUBLE_TEXT"] = TroubleText
	TroubleParams["IDENTIFIER"] = Identifier

	SendNotify("TROUBLE_START", TroubleParams, BindingID)
end

function NOTIFY.TROUBLE_CLEAR(Identifier, BindingID)
	local TroubleParams = {}

	LogTrace("NOTIFY.TROUBLE_CLEAR: %s %d", tostring(Identifier), tonumber(BindingID))
	TroubleParams["IDENTIFIER"] = Identifier

	SendNotify("TROUBLE_CLEAR", TroubleParams, BindingID)
end

function NOTIFY.ALL_PARTITIONS_INFO(InfoStr, BindingID)
	LogTrace(InfoStr)
	SendNotify("ALL_PARTITIONS_INFO", InfoStr, BindingID)
end

function NOTIFY.ALL_ZONES_INFO(InfoStr, BindingID)
	LogTrace(InfoStr)
	SendNotify("ALL_ZONES_INFO", InfoStr, BindingID)
end

function NOTIFY.ALL_PGMS_INFO(InfoStr, BindingID)
	LogTrace(InfoStr)
	SendNotify("ALL_PGMS_INFO", InfoStr, BindingID)
end
