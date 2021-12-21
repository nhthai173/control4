--[[=============================================================================
    Commands for the SecurityPanel Proxy

    Copyright 2015 Control4 Corporation. All Rights Reserved.
===============================================================================]]
require "common.c4_command"
require "common.c4_utils"

TEMPLATE_VERSION.securitypanel = "6"

function PRX_CMD.GET_PANEL_SETUP(idBinding, tParams)
	if (TheSecurityPanel) then
		TheSecurityPanel:PrxGetPanelSetup()
	end
end

function PRX_CMD.GET_ALL_PARTITION_INFO(idBinding, tParams)
	if (TheSecurityPanel) then
		TheSecurityPanel:PrxGetAllPartitionsInfo()
	end
end

function PRX_CMD.GET_ALL_ZONE_INFO(idBinding, tParams)
	if (TheSecurityPanel) then
		TheSecurityPanel:PrxGetAllZonesInfo()
	end
end

function PRX_CMD.GET_ALL_PGM_INFO(idBinding, tParams)
	if (TheSecurityPanel) then
		TheSecurityPanel:PrxGetAllPgmsInfo()
	end
end

function PRX_CMD.SET_PANEL_TIME_DATE(idBinding, tParams)
	local CurYear = tonumber(tParams.YEAR)
	local CurMonth = tonumber(tParams.MONTH)
	local CurDay = tonumber(tParams.DAY)
	local CurHour = tonumber(tParams.HOUR)
	local CurMinute = tonumber(tParams.MINUTE)
	local CurSecond = tonumber(tParams.SECOND)

	if (TheSecurityPanel) then
		TheSecurityPanel:PrxSetTimeDate(CurYear, CurMonth, CurDay, CurHour, CurMinute, CurSecond)
	end
end

function PRX_CMD.SET_PARTITION_ENABLED(idBinding, tParams)
	local PartitionID = tonumber(tParams.PARTITION_ID)
	local PartitionEnabled = tParams.ENABLED

	if (TheSecurityPanel) then
		TheSecurityPanel:PrxSetPartitionEnabled(PartitionID, PartitionEnabled)
	end
end

function PRX_CMD.SEND_PGM_COMMAND(idBinding, tParams)
	local PgmID = tonumber(tParams.PGM_ID)
	local PgmCommand = tParams.COMMAND

	if (TheSecurityPanel) then
		TheSecurityPanel:PrxSendPgmCommand(PgmID, PgmCommand)
	end
end

function PRX_CMD.SET_ZONE_INFO(idBinding, tParams)
	local ZoneID = tonumber(tParams.ZONE_ID)
	local ZoneName = tParams.NAME
	local ZoneTypeID = tonumber(tParams.TYPE_ID)

	if (TheSecurityPanel) then
		TheSecurityPanel:PrxSetZoneInfo(ZoneID, ZoneName, ZoneTypeID)
	end
end
