--[[=============================================================================
    Template for Security Panel/Security Partition Driver

    Copyright 2014 Control4 Corporation. All Rights Reserved.
===============================================================================]]
require "common.c4_driver_declarations"
require "common.c4_common"
require "common.c4_init"
require "common.c4_property"
require "common.c4_command"
require "common.c4_diagnostics"
require "common.c4_notify"
require "common.c4_utils"

require "panel_proxy.securitypanel"
require "panel_proxy.security_history"
require "partition_proxy.securitypartition"

require "actions"
require "driver_functions"
require "properties"
require "c4securitysim_communicator"	
require "c4securitysim"


DRIVER_NAME = "C4SecuritySystemSimulator"

TEMPLATE_VERSION.security_system_template_version = "2014.11.24"

-- NOTE:
-- The following properties should not have to be changed, but can be if the author feels it
-- is necessary. Great care should be taken when modifying these values though, since the
-- values correspond to other values contained from within other files in the project.
PANEL_PROXY_BINDINGID = DEFAULT_PROXY_BINDINGID
BASE_PARTITION_PROXY_BINDINGID = DEFAULT_PROXY_BINDINGID + 1
SERIAL_PORT_BINDINGID = 1

-- TODO:
-- Set the number of partitions and zones supported by this driver.
PARTITION_ID_MAX = 1


--[[==========================================================================================
	Initialization Code
============================================================================================]]
function ON_DRIVER_EARLY_INIT.MainDriver()
end

function ON_DRIVER_INIT.MainDriver()
	Initialize_SecuritySystem()
end


function ON_DRIVER_LATEINIT.MainDriver()

	-- Since this driver doesn't have any real hardware associated with it, this will 
	-- emulate a security panel's hardware
	gSimDevice = C4SecuritySimDevice.Create()

	-- Since this driver doesn't have a real serial binding to connect up.  Fake out the 
	-- connection initialization here.
	gCon = C4SecuritySim:new(BindingID)
	gCon:Initialize()
	
	-- Force the initialization call that would normally be made when the serial port is connected
	OnSerialConnectionChanged(SERIAL_PORT_BINDINGID, "SERIAL", true)
end

function Initialize_SecuritySystem()
	TheSecurityPanel = SecurityPanel:new(PANEL_PROXY_BINDINGID)    

	for PartitionIndex = 1, PARTITION_ID_MAX do
		SecurityPartition:new(PartitionIndex, BASE_PARTITION_PROXY_BINDINGID + (PartitionIndex - 1))
	end

	TheSecurityPanel:Initialize()

end

