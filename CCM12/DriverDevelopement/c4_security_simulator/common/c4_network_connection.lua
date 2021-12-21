--[[=============================================================================
    Base for a network connection driver

    Copyright 2014 Control4 Corporation. All Rights Reserved.
===============================================================================]]
require "common.c4_device_connection_base"
require "lib.c4_log"

-- Set template version for this file
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.c4_network_connection = "2014.10.31"
end

DEFAULT_POLLING_INTERVAL_SECONDS = 30

gNetworkKeepAliveInterval = DEFAULT_POLLING_INTERVAL_SECONDS

NetworkConnectionBase = inheritsFrom(DeviceConnectionBase)

function NetworkConnectionBase:construct(BindingID, Port)
	self.superClass():construct()

	self._BindingID = BindingID
	self._Port = Port
	self._LastCheckin = 0
	self._IsOnline = false
	self._KeepAliveTimer = nil
end

function NetworkConnectionBase:Initialize(ExpectAck, DelayInterval, WaitInterval)
	print("NetConBase:Initialize")
	gControlMethod = "Network"
	self:superClass():Initialize(ExpectAck, DelayInterval, WaitInterval, self)
	self._KeepAliveTimer = c4_timer:new("PollingTimer", gNetworkKeepAliveInterval, "SECONDS", NetworkConnectionBase.OnKeepAliveTimerExpired, false, self)
end

function NetworkConnectionBase:ControlMethod()
	return "Network"
end

function NetworkConnectionBase:SendCommand(sCommand, ...)
	if(self._IsConnected) then
		if(self._IsOnline) then
			local command_delay = select(1, ...)
			local delay_units = select(2, ...)
			local command_name = select(3, ...)

			C4:SendToNetwork(self._BindingID, self._Port, sCommand)
			self:StartCommandTimer(command_delay, delay_units, command_name)
		else
			self:CheckNetworkConnectionStatus()
		end
	else
		LogWarn("Not connected to network. Command not sent.")
	end
end

function NetworkConnectionBase:ReceivedFromNetwork(idBinding, nPort, sData)
	self._LastCheckin = 0
	self:ReceivedFromCom(sData)
end

function NetworkConnectionBase:CheckNetworkConnectionStatus()
	if (self._IsConnected and (not self._IsOnline)) then
		LogWarn("Network status is OFFLINE. Trying to reconnect to the device's Control port...")
		C4:NetDisconnect(self._BindingID, self._Port)
		C4:NetConnect(self._BindingID, self._Port)
	end
end

function NetworkConnectionBase.OnKeepAliveTimerExpired(Instance)
	Instance._LastCheckin = Instance._LastCheckin + 1

	if(Instance._LastCheckin > 2) then
		if(not Instance._IsOnline) then
			C4:NetDisconnect(Instance._BindingID, Instance._Port)
			C4:NetConnect(Instance._BindingID, Instance._Port)
		else
			C4:NetDisconnect(Instance._BindingID, Instance._Port)
			LogWarn("Failed to receive poll responses... Disconnecting...")
		end
	end

	if (SendKeepAlivePollingCommand ~= nil and type(SendKeepAlivePollingCommand) == "function") then
		SendKeepAlivePollingCommand()
	end

	Instance._KeepAliveTimer:StartTimer(gNetworkKeepAliveInterval)
end

function NetworkConnectionBase:SetOnlineStatus(IsOnline)
	self._IsOnline = IsOnline

	if(IsOnline) then
		self._KeepAliveTimer:StartTimer()
		self._LastCheckin = 0
		if (UpdateProperty ~= nil and type(UpdateProperty) == "function") then
			UpdateProperty("Connected To Network", "true")
		end

		self:SendNextCommand()
	else
		self._KeepAliveTimer:KillTimer()
		if (UpdateProperty ~= nil and type(UpdateProperty) == "function") then
			UpdateProperty("Connected To Network", "false")
		end
	end
end