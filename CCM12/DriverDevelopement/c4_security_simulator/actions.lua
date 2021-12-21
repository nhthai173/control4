--[[=============================================================================
    Lua Action Code

    Copyright 2014 Control4 Corporation. All Rights Reserved.
===============================================================================]]

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.actions = "2014.10.16"
end

-- TODO: Create a function for each action defined in the driver

function LUA_ACTION.TemplateVersion()
	TemplateVersion()
end

function LUA_ACTION.Zone1Toggle()
	gSimDevice:HW_ToggleZone(1)
end

function LUA_ACTION.Zone2Toggle()
	gSimDevice:HW_ToggleZone(2)
end

function LUA_ACTION.Zone3Toggle()
	gSimDevice:HW_ToggleZone(3)
end

function LUA_ACTION.Zone4Toggle()
	gSimDevice:HW_ToggleZone(4)
end

function LUA_ACTION.Zone5Toggle()
	gSimDevice:HW_ToggleZone(5)
end

function LUA_ACTION.Zone6Toggle()
	gSimDevice:HW_ToggleZone(6)
end

function LUA_ACTION.Zone7Toggle()
	gSimDevice:HW_ToggleZone(7)
end

function LUA_ACTION.Zone8Toggle()
	gSimDevice:HW_ToggleZone(8)
end

function LUA_ACTION.Zone9Toggle()
	gSimDevice:HW_ToggleZone(9)
end

function LUA_ACTION.Zone10Toggle()
	gSimDevice:HW_ToggleZone(10)
end

function LUA_ACTION.Zone11Toggle()
	gSimDevice:HW_ToggleZone(11)
end

function LUA_ACTION.Zone12Toggle()
	gSimDevice:HW_ToggleZone(12)
end

function LUA_ACTION.Zone13Toggle()
	gSimDevice:HW_ToggleZone(13)
end

function LUA_ACTION.Zone14Toggle()
	gSimDevice:HW_ToggleZone(14)
end

function LUA_ACTION.Zone15Toggle()
	gSimDevice:HW_ToggleZone(15)
end

function LUA_ACTION.Zone16Toggle()
	gSimDevice:HW_ToggleZone(16)
end

function LUA_ACTION.Pgm1Toggle()
	gSimDevice:HW_TogglePgm(1)
end

function LUA_ACTION.Pgm2Toggle()
	gSimDevice:HW_TogglePgm(2)
end

function LUA_ACTION.Pgm3Toggle()
	gSimDevice:HW_TogglePgm(3)
end

function LUA_ACTION.Pgm4Toggle()
	gSimDevice:HW_TogglePgm(4)
end

function LUA_ACTION.TroubleStart()
	gSimDevice:HW_HaveTrouble("Suspicious Hooligans")
end

function LUA_ACTION.TroubleClear()
	gSimDevice:HW_TroubleEnd()
end

function LUA_ACTION.DisplayTextLine1()
	gSimDevice:HW_DisplayText1("Should be on line 1")
end

function LUA_ACTION.DisplayTextLine2()
	gSimDevice:HW_DisplayText2("Should be on line 2")
end

function LUA_ACTION.ClearDisplayText()
	gSimDevice:HW_ClearDisplayText()
end

function LUA_ACTION.DisplayGlobals()

end

