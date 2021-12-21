--[[=============================================================================
    Commands for the SecurityPartition Proxy

    Copyright 2015 Control4 Corporation. All Rights Reserved.
===============================================================================]]
require "lib.c4_log"

TEMPLATE_VERSION.securitypartition = "9"

function PRX_CMD.KEY_PRESS(idBinding, tParams)
	LogTrace("PRX_CMD.KEY_PRESS")
	if (SecurityPartitionBindingList[idBinding]) then
		SecurityPartitionBindingList[idBinding]:PrxKeyPress(tParams)
	end
end

function PRX_CMD.PARTITION_ARM(idBinding, tParams)
	LogTrace("PRX_CMD.PARTITION_ARM")
	if (SecurityPartitionBindingList[idBinding]) then
		SecurityPartitionBindingList[idBinding]:PrxPartitionArm(tParams)
	end
end

function PRX_CMD.PARTITION_DISARM(idBinding, tParams)
	LogTrace("PRX_CMD.PARTITION_DISARM")
	if (SecurityPartitionBindingList[idBinding]) then
		SecurityPartitionBindingList[idBinding]:PrxPartitionDisarm(tParams)
	end
end

function PRX_CMD.EXECUTE_EMERGENCY(idBinding, tParams)
	LogTrace("PRX_CMD.EXECUTE_EMERGENCY")
	if (SecurityPartitionBindingList[idBinding]) then
		SecurityPartitionBindingList[idBinding]:PrxExecuteEmergency(tParams)
	end
end

function PRX_CMD.EXECUTE_FUNCTION(idBinding, tParams)
	LogTrace("PRX_CMD.EXECUTE_FUNCTION")
	if (SecurityPartitionBindingList[idBinding]) then
		SecurityPartitionBindingList[idBinding]:PrxExecuteFunction(tParams)
	end
end

function PRX_CMD.BYPASS_ZONE(idBinding, tParams)
	LogTrace("PRX_CMD.BYPASS_ZONE")
	if (SecurityPartitionBindingList[idBinding]) then
		SecurityPartitionBindingList[idBinding]:PrxBypassZone(tParams)
	end
end

function PRX_CMD.GET_CURRENT_STATE(idBinding, tParams)
	LogTrace("PRX_CMD.GET_CURRENT_STATE")
	if (SecurityPartitionBindingList[idBinding]) then
		SecurityPartitionBindingList[idBinding]:PrxGetCurrentState(tParams)
	end
end
