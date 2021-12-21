--[[=============================================================================
    PgmInformation Class

    Copyright 2015 Control4 Corporation. All Rights Reserved.
===============================================================================]]
require "lib.c4_object"
require "panel_proxy.relay_notifies"

TEMPLATE_VERSION.securitypanel = "6"

PgmInfoList = {}
PgmInformation = inheritsFrom(nil)

--[[=============================================================================
    Functions that are meant to be private to the class
===============================================================================]]
function PgmInformation:construct(PgmID)

	self._PgmID = PgmID
	self._IsOpen = false
	self._NeedToSendInitialInfo = true

	PgmInfoList[PgmID] = self
end

function PgmInformation:destruct()
	PgmInfoList[self._PgmID] = nil
end

function PgmInformation:PgmXML()
	local PgmXMLInfo = {}

	table.insert(PgmXMLInfo, MakeXMLNode("id", tostring(self._PgmID)))
	table.insert(PgmXMLInfo, MakeXMLNode("is_open", tostring(self:GetPgmState())))

	return MakeXMLNode("pgm", table.concat(PgmXMLInfo, "\n"))
end

--[[=============================================================================
    Functions that are wrappered and meant to be exposed to the driver
===============================================================================]]
function PgmInformation:SetPgmState(IsOpen, Initializing)
	local JustInitializing = Initializing or false

	if ((self._IsOpen ~= IsOpen) or self._NeedToSendInitialInfo) then

		self._IsOpen = IsOpen
		if (not JustInitializing) then
			LogTrace("!!!!!!   Pgm %d %s  !!!!!!", tonumber(self._PgmID), tostring(self:GetPgmState()))
			NOTIFY.PANEL_PGM_STATE(self._PgmID, self._IsOpen, TheSecurityPanel._BindingID)
			self._NeedToSendInitialInfo = false
		end
	end
end

function PgmInformation:GetPgmState()
	return self._IsOpen
end