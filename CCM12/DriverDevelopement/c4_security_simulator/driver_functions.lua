--[[=============================================================================
    File for implementing driver specific functions

    Copyright 2015 Control4 Corporation. All Rights Reserved.
===============================================================================]]

require "partition_proxy.securitypartition"

function SecurityPartitionFunctions.Chime(PartitionID, DeviceID, ParmList)
	RecordInfoSecurityEvent("Function", "Chime")
	DisplayPartitionText(PartitionID, "Beeeeeeeep")
end


function SecurityPartitionFunctions.ElectrifyFence(PartitionID, DeviceID, ParmList)
	RecordWarningSecurityEvent("Function", "Electrify Fence")
	DisplayPartitionText(PartitionID, "Prepare to be Shocked!")
end


function SecurityPartitionFunctions.ReleaseKraken(PartitionID, DeviceID, ParmList)
	if(#ParmList <= 1) then
		RequestKeypadInfo(PartitionID, DeviceID, "Release Kraken", "How many Kraken should we release?", {})
	else
		local num = tostring(ParmList[2])
		RecordCriticalSecurityEvent("Function", num .. " Kraken Released")
		DisplayPartitionText(PartitionID, num .. " Kraken Released")
	end
end


function SecurityPartitionFunctions.ToggleZone1(PartitionID, DeviceID, ParmList)
	gSimDevice:HW_ToggleZone(1)
end


function SecurityPartitionFunctions.ToggleZone2(PartitionID, DeviceID, ParmList)
	gSimDevice:HW_ToggleZone(2)
end

function SecurityPartitionFunctions.ToggleZone10Fire(PartitionID, DeviceID, ParmList)
	gSimDevice:HW_ToggleZone(10)
end

