--[[=============================================================================
    SecurityPanel Class

    Copyright 2015 Control4 Corporation. All Rights Reserved.
===============================================================================]]
require "lib.c4_object"
require "panel_proxy.zone_info"
require "panel_proxy.pgm_info"
require "panel_proxy.securitypanel_commands"
require "panel_proxy.securitypanel_notifies"
require "panel_proxy.securitypanel_functions"
require "panel_proxy.relay_commands"

TEMPLATE_VERSION.securitypanel = "6"

TheSecurityPanel = nil
SecurityPanel = inheritsFrom(nil)

--[[=============================================================================
    Functions that are meant to be private to the class
===============================================================================]]
function SecurityPanel:construct(BindingID)
	self._BindingID = BindingID
end

function SecurityPanel:Initialize()
	self:InitializeVariables()
end

function SecurityPanel:InitializeVariables()
	self._NextTroubleIndex = 0
	self._TroubleTable = {}
end

function SecurityPanel:GetNextTroubleID()
	self._NextTroubleIndex = self._NextTroubleIndex + 1
	return self._NextTroubleIndex
end

--[[=============================================================================
    Functions for handling request from the Panel Proxy
===============================================================================]]
function SecurityPanel:PrxGetPanelSetup()
	self:PrxGetAllPartitionsInfo()
	self:PrxGetAllZonesInfo()
	self:PrxGetAllPgmsInfo()
end

function SecurityPanel:PrxGetAllPartitionsInfo()
	local AllPartitionsInfos = {}

	LogTrace("SecurityPanel.GetAllPartitionsInfo")
	for k,v in pairs(SecurityPartitionIndexList) do
		table.insert(AllPartitionsInfos, v:PartitionXML())
	end

	NOTIFY.ALL_PARTITIONS_INFO(MakeXMLNode("partitions", table.concat(AllPartitionsInfos, "\n")), self._BindingID)
end

function SecurityPanel:PrxGetAllZonesInfo()
	local AllZoneInfos = {}

	LogTrace("SecurityPanel.GetAllZonesInfo")
	for k,v in pairs(ZoneInfoList) do
		table.insert(AllZoneInfos, v:ZonePanelXML())
	end

	NOTIFY.ALL_ZONES_INFO(MakeXMLNode("zones", table.concat(AllZoneInfos, "\n")), self._BindingID)
end

function SecurityPanel:PrxGetAllPgmsInfo()
	local AllPgmInfos = {}

	LogTrace("SecurityPanel.GetAllPgmsInfo")
	for k,v in pairs(PgmInfoList) do
		table.insert(AllPgmInfos, v:PgmXML())
	end

	NOTIFY.ALL_PGMS_INFO(MakeXMLNode("pgms", table.concat(AllPgmInfos, "\n")), self._BindingID)
end

function SecurityPanel:PrxSetTimeDate(TargYear, TargMonth, TargDay, TargHour, TargMinute, TargSecond)
	LogTrace("SecurityPanel.SetTimeDate  Date is: %02d/%02d/%d  Time is: %02d:%02d:%02d", tonumber(TargMonth), tonumber(TargDay), tonumber(TargYear), tonumber(TargHour), tonumber(TargMinute), tonumber(TargSecond))
	SecCom_SendDateAndTime(TargYear, TargMonth, TargDay, TargHour, TargMinute, TargSecond)
end

function SecurityPanel:PrxSetPartitionEnabled(PartitionID, Enabled)
	SecCom_SendPartitionEnabled(PartitionID, Enabled)
end

function SecurityPanel:PrxSendPgmCommand(PgmID, Command)
	if (Command == "Open") then
		SecCom_SendPgmControlOpen(PgmID)
	elseif (Command == "Close") then
		SecCom_SendPgmControlClose(PgmID)
	elseif (Command == "Toggle") then
		SecCom_SendPgmControlToggle(PgmID)
	end
end

function SecurityPanel:PrxSetZoneInfo(ZoneID, ZoneName, ZoneTypeID)
	LogTrace("SecurityPanel.PrxSetZoneInfo  Params are %d %s %s", tonumber(ZoneID), tostring(ZoneName), tostring(ZoneTypeID))
	SecCom_SendSetZoneInfo(ZoneID, ZoneName, ZoneTypeID)
end

function SecurityPanel:PrxGetZoneInfo(TargZoneID)
	LogTrace("SecurityPanel.PrxGetZoneInfo ZoneID[%d]", tonumber(TargZoneID))
	return ZoneInfoList[TargZoneID]:ZonePanelXML()
end

function SecurityPanel:PrxGetPgmState(TargPgmID)
	return PgmInfoList[TargPgmID]:PgmXML()
end

function SecurityPanel:PrxGetAllPgmStates()
	local AllPgmInfos = {}

	LogTrace("SecurityPanel.GetAllPgmStates")
	for k,v in pairs(PgmInfoList) do
		table.insert(AllPgmInfos, v:PgmXML())
	end

	NOTIFY.ALL_PGMS_INFO(MakeXMLNode("pgms", table.concat(AllPgmInfos, "\n")), self._BindingID)
end

--[[=============================================================================
    Functions that are wrappered and meant to be exposed to the driver
===============================================================================]]
function SecurityPanel:TroubleStart(TroubleStr)
	local TroubleID = self:GetNextTroubleID()

	self._TroubleTable[TroubleID] = TroubleStr
	LogTrace("SecurityPanel: TroubleStart String is: %s %d", tostring(TroubleStr), tonumber(TroubleID))
	NOTIFY.TROUBLE_START(TroubleStr, TroubleID, self._BindingID)

	return TroubleID
end

function SecurityPanel:TroubleClear(Identifier)
	self._TroubleTable[Identifier] = nil
	NOTIFY.TROUBLE_CLEAR(Identifier, self._BindingID)
end

function SecurityPanel:RemoveZone(ZoneID)
	local nZoneID = tonumber(ZoneID)

	LogTrace("SecurityPanel.RemovePanel %d", tonumber(nZoneID))
	for k,v in pairs(SecurityPartitionIndexList) do
		v:RemoveZone(ZoneID)
	end

	if (ZoneInfoList[nZoneID] ~= nil) then
		ZoneInfoList[nZoneID]:destruct()
	end
	
	NOTIFY.PANEL_REMOVE_ZONE(ZoneID, self._BindingID)
end

function SecurityPanel:AddPgm(PgmID)
	local nPgmID = tonumber(PgmID)
	
	LogTrace("SecurityPanel.AddPgm %d", nPgmID)
	if (PgmInfoList[nPgmID] == nil) then
		PgmInformation:new(PgmID)
	end

	NOTIFY.PANEL_ADD_PGM(PgmID, self._BindingID)
end

function SecurityPanel:RemovePgm(PgmID)
	local nPgmID = tonumber(PgmID)
	
	LogTrace("SecurityPanel.RemovePgm %d", nPgmID)
	if (PgmInfoList[nPgmID] ~= nil) then
		PgmInfoList[nPgmID]:destruct()
	end
	
	NOTIFY.PANEL_REMOVE_PGM(PgmID, self._BindingID)
end
