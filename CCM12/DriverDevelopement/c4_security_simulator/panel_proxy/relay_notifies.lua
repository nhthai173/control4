--[[=============================================================================
    Notifications for the Relays (Pgms) on a security panel

    Copyright 2015 Control4 Corporation. All Rights Reserved.
===============================================================================]]
require "common.c4_notify"

TEMPLATE_VERSION.securitypanel = "6"

function NOTIFY.INITIAL_RELAY_STATE(IsOpen, BindingID)
	LogTrace("Sending Initial Relay State on Binding %d : %s", tonumber(BindingID), tostring((IsOpen and "Open" or "Closed")))
	SendSimpleNotify(IsOpen and "STATE_OPENED" or "STATE_CLOSED", BindingID)
end

function NOTIFY.RELAY_STATE(IsOpen, BindingID)
	LogTrace("Sending Relay State on Binding %d : %s", tonumber(BindingID), tostring((IsOpen and "Open" or "Closed")))
	SendSimpleNotify(IsOpen and "OPENED" or "CLOSED", BindingID)
end
