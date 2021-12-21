--[[=============================================================================
    Pgm Relay Proxy Command Functions

    Copyright 2015 Control4 Corporation. All Rights Reserved.
===============================================================================]]
require "common.c4_command"
require "common.c4_utils"
require "panel_proxy.pgm_info"

TEMPLATE_VERSION.securitypanel = "6"

function PRX_CMD.PGM_OPEN(idBinding, tParams)
	if (TheSecurityPanel) then
		TheSecurityPanel:PrxSendPgmCommand(tonumber(tParams.PGM_ID), "Open")
	end
end

function PRX_CMD.PGM_CLOSE(idBinding, tParams)
	if (TheSecurityPanel) then
		TheSecurityPanel:PrxSendPgmCommand(tonumber(tParams.PGM_ID), "Close")
	end
end

function PRX_CMD.PGM_TOGGLE(idBinding, tParams)
	if (TheSecurityPanel) then
		TheSecurityPanel:PrxSendPgmCommand(tonumber(tParams.PGM_ID), "Toggle")
	end
end

function PRX_CMD.PGM_TRIGGER(idBinding, tParams)
	local TargPgm = PgmInfoList[tonumber(tParams.PGM_ID)]
	local TriggerTime = tParams["TIME"]

	if (TheSecurityPanel and TargPgm) then
		--  TODO:  Figure out how to handle this	
		--		TheSecurityPanel:PrxSendPgmCommand(TargPgm._PgmID, "Trigger")
	end
end
