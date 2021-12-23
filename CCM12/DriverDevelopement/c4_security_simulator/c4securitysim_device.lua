-----------------------------------------------------------
-- a mythical hardware serial device
-----------------------------------------------------------

require "lib.c4_log"
require "lib.c4_timer"
require "common.ccm12"

C4_SECURITY_SIM_DUMMY_SERIAL_BINDING_ID = 1

C4_SECURITY_SIM_PARTITION_COUNT = 6
-- C4_SECURITY_SIM_ZONE_COUNT = 16
-- C4_SECURITY_SIM_PGM_COUNT = 4

-- By-directional map of zone types
C4_SECURITY_SIM_ZONE_TYPES = {
	"DOOR",
	"WINDOW",
	"BURGLARY",
	"MOTION",
	"FIRE",
	"WATER",
	"SMOKE",
	"INTERIOR",
	
	DOOR=1,
	WINDOW=2,
	BURGLARY=3,
	MOTION=4,
	FIRE=5,
	WATER=6,
	SMOKE=7,
	INTERIOR=8,
}
C4_SECURITY_SIM_ZONE_TYPE_DEFAULT = C4_SECURITY_SIM_ZONE_TYPES.BURGLARY

function uglom(instring)
	instring = instring or ""
	return instring:gsub(" ", "_")
end


function ufix(instring)
	return instring:gsub("_", " ")
end

-- split a string into the first word (command) and the rest
function CommandSplit(str)
	local index = str:find(" ")
	if index then
		local cmd = string.sub(str, 1, index - 1)
		local rest = string.sub(str, index + 1)
		return cmd, rest
	else
		return str
	end
end

function MessageFromDevice(MessageStr)
	LogTrace("Sending message from Device: " .. MessageStr)
	if(gCon) then
		ReceivedFromSerial(C4_SECURITY_SIM_DUMMY_SERIAL_BINDING_ID, MessageStr)
	else
		LogTrace("gCon not defined")
	end
end

ZoneToPartitionAssignments =
{
	{ 1, 2, 3, 4, 5, 9, 10, 11, 12, 13, 14, 15, 16, 23, 24, 25, 26 },
	{ 6, 9, 10 },
	{ 7, 9, 10 },
	{ 8, 9, 10 },
	{ 9, 10, 11, 12, 17, 18, 19, 25, 26, 27, 28 },
	{ 9, 10, 13, 14, 20, 21, 22, 29, 30, 31, 32 },
}





C4SecuritySimDevice = {}
function C4SecuritySimDevice.Create()

	local ud = {}

	ud.CMDS = {}
	ud.ZoneInfoList = {}
	ud.PgmInfoList = {}
	ud.PartitionInfoList = {}

	for PartitionIndex = 1, C4_SECURITY_SIM_PARTITION_COUNT do
		ud.PartitionInfoList[PartitionIndex] = UPartition.Create(PartitionIndex)
	end
	

	
	function ud:Reset()
		print("Resetting c4securitysim_device...")
		
		self:HW_AdjustZoneCount(Properties['Number of Zones'])
		self:HW_AdjustPgmCount(Properties['Number of Pgms'])
	
		local time = os.date("*t")	-- This starts with the system date/time, but does not increment with time passage
		self._MyTime = {}
		self._MyTime.Year = time.year
		self._MyTime.Month = time.month
		self._MyTime.Day = time.day
		self._MyTime.Hour = time.hour
		self._MyTime.Minute = time.min
		self._MyTime.Second = time.sec

		self._CurrentTrouble = ""
		Properties.Trouble = self._CurrentTrouble

		for ZoneIndex = 1,#self.ZoneInfoList do
			self.ZoneInfoList[ZoneIndex]:Reset()
		end

		for PgmIndex = 1,#self.PgmInfoList do
			self.PgmInfoList[PgmIndex]:Reset()
		end
		
		for PartitionIndex = 1,C4_SECURITY_SIM_PARTITION_COUNT do
			local part = self.PartitionInfoList[PartitionIndex]
			part:Reset()
		end

		-- designate partition 1 as unable to be disabled
		self.PartitionInfoList[1]._AlwaysEnabled = true
		
		if((#self.PgmInfoList >= 2) and (#self.ZoneInfoList >= 2)) then
			-- attach zone 2 to pgm 2 so we can see zone controls working
			self.ZoneInfoList[2]._AttachedPgm = self.PgmInfoList[2]
			self.PgmInfoList[2]._AttachedZone = self.ZoneInfoList[2]
		end

		-- -- assign zones to partitions 
		-- for PartitionIndex, TargPartition in pairs(self.PartitionInfoList) do
			-- local CurAssignmentList = ZoneToPartitionAssignments[PartitionIndex]
			
			-- for k,v in pairs(CurAssignmentList) do
				-- if(self.ZoneInfoList[v] ~= nil) then
					-- TargPartition:AddZoneToList(self.ZoneInfoList[v])
				-- end
			-- end
		-- end
		
	end
	

	function ud:ComSendToSerial(sCommand)
		local SerCmd, SerData = CommandSplit(sCommand)
		Go(self.CMDS[SerCmd], "ComSendToSerial: Unhandled command = " .. SerCmd, SerData)
	end


	function ud:ReportTrouble()
		Properties.Trouble = self._CurrentTrouble
		MessageFromDevice(string.format("U_TROUBLE %s", uglom(self._CurrentTrouble)))
	end


	function ud:SendDisplayTextMessage(WhichPartition, TextMessage, LineNumber)
		MessageFromDevice(string.format("U_DISPLAY_TEXT %d %s %d", WhichPartition._pID, uglom(TextMessage), LineNumber))
	end

	
	function ud:ClearDisplayTextMessage(WhichPartition)
		MessageFromDevice(string.format("U_CLEAR_DISPLAY_TEXT %d", WhichPartition._pID))
	end
	
	----------------------------------------------------------------------------
	-- commands sent from the communicator

	function ud.CMDS.UC_DATE_TIME(CmdData)
		local time = ud.MyTime
		local ParamTab = StringSplit(CmdData)
		time.Year = tonumber(ParamTab[1])
		time.Month = tonumber(ParamTab[2])
		time.Day = tonumber(ParamTab[3])
		time.Hour = tonumber(ParamTab[4])
		time.Minute = tonumber(ParamTab[5])
		time.Second = tonumber(ParamTab[6])

		LogTrace("Device time was set to %d/%d/%d	%d:%d:%d", time.Month, time.Day, time.Year, time.Hour, time.Minute, time.Second)

	end


	function ud.CMDS.UC_GET_INITIAL_SETUP(CmdData)
		LogTrace("=== Initial Setup ===")

		for k,v in pairs(ud.ZoneInfoList) do
			v:ReportZoneSetup()
		end

		for k,v in pairs(ud.PgmInfoList) do
			v:ReportPgmState()
		end

		for k,v in pairs(ud.PartitionInfoList) do
			v:SetInitialState()
		end

	end

	
	function ud.CMDS.UC_SET_PARTITION_ENABLED(CmdData)
		local ParamTab = StringSplit(CmdData)
		local PartitionID = tonumber(ParamTab[1])
		local EnableIt = toboolean(ParamTab[2])
		
		ud.PartitionInfoList[PartitionID]:SetEnabledFlag(EnableIt)
	end
	

	function ud.CMDS.UC_SET_ZONE_INFO(CmdData)
		local ParamTab = StringSplit(CmdData)
		local ZoneID = tonumber(ParamTab[1])
		local ZoneName = ufix(ParamTab[2])
		local ZoneTypeID = tonumber(ParamTab[3])

		ud.ZoneInfoList[ZoneID]:AdjustAttributes(ZoneName, ZoneTypeID)
	end


	function ud.CMDS.UC_ARM_PARTITION(CmdData)
		local ParamTab = StringSplit(CmdData)
		local PartitionID = tonumber(ParamTab[1])
		local ArmType = ufix(ParamTab[2])
		local UserCode = ufix(ParamTab[3])
		local DoBypass = toboolean(ParamTab[4])

		ud.PartitionInfoList[PartitionID]:AttemptToArm(ArmType, UserCode, DoBypass)
	end


	function ud.CMDS.UC_DISARM_PARTITION(CmdData)
		local ParamTab = StringSplit(CmdData)
		local PartitionID = tonumber(ParamTab[1])
		local UserCode = ufix(ParamTab[2])

		ud.PartitionInfoList[PartitionID]:AttemptToDisarm(UserCode)
	end


	function ud.CMDS.UC_RAW_USER_CODE(CmdData)
		local ParamTab = StringSplit(CmdData)
		local PartitionID = tonumber(ParamTab[1])
		local UserCode = ufix(ParamTab[2])

		ud.PartitionInfoList[PartitionID]:HandleUserCode(UserCode)
	end


	function ud.CMDS.UC_EMERGENCY(CmdData)
		local ParamTab = StringSplit(CmdData)
		local PartitionID = tonumber(ParamTab[1])
		local EmergencyType = ufix(ParamTab[2])

		LogTrace("Handling Emergency: %s", EmergencyType)
		ud.PartitionInfoList[PartitionID]:HandleEmergency(EmergencyType)
		MessageFromDevice(string.format("U_EMERGENCY %s", uglom(EmergencyType)))
	end


	function ud.CMDS.UC_REPORT()
		local lines = {}
		table.insert(lines, "#### Partitions ####\n")
		for PartitionIndex, part in pairs(ud.PartitionInfoList) do
			table.insert(lines, PartitionIndex..": "..part._CurrentState.." "..part._ArmType.."\n")
		end
		
		table.insert(lines, "#### Zones ####".."\n")
		table.insert(lines,"   ")
		for PartitionIndex = 1, C4_SECURITY_SIM_PARTITION_COUNT do
			table.insert(lines, string.format(" P%s", PartitionIndex))
		end
		table.insert(lines, string.format("	%16s [%10s] %s\n", "Zone Name", "Type", "Status"))
		for ZoneIndex,zone in pairs(ud.ZoneInfoList) do
			--table.insert(lines, "-")
			table.insert(lines, string.format("%3s", ZoneIndex))
			for k,part in pairs(ud.PartitionInfoList) do
				local found = false
				for k,p in pairs(zone._PartitionList) do
					if p == part then
						found = true
						break
					end
				end
				table.insert(lines, string.format("%3s", (found and "x" or " ")))
			end
			table.insert(lines, string.format("  %16s [%d] %s %s\n", zone._ZoneName, zone._ZoneTypeID,
					(zone._IsOpen and "Open" or "Closed"), (zone._IsBypassed and "Bypassed" or "")))
		end
		
		table.insert(lines, "#### Pgms ####".."\n")
		table.insert(lines, string.format("	%16s [%10s] %s\n", "Pgm Name", "Type", "Status"))
		for PgmIndex,pgm in pairs(ud.PgmInfoList) do
			table.insert(lines, string.format("%2s %16s [%10s] %s\n", PgmIndex, pgm._PgmName, pgm._PgmType,
					(pgm._IsOpen and "Open" or "Closed")))
		end
		print(table.concat(lines))
	end


	function ud.CMDS.UC_RESET()
		ud.Reset()
	end
 
 
	function ud.CMDS.UC_ZONE_BYPASS(CmdData)
		local ParamTab = StringSplit(CmdData)
		local PartitionID = tonumber(ParamTab[1])
		local ZoneID = tonumber(ParamTab[2])
		local BypassIt = toboolean(ParamTab[3])

		local TargZone = ud.ZoneInfoList[ZoneID]
		if BypassIt then
			TargZone:Bypass()
		else
			TargZone:Unbypass()
		end
	end
 
 	function ud.CMDS.UC_CONTROL_PGM(CmdData)
		local ParamTab = StringSplit(CmdData)
		local PgmID = tonumber(ParamTab[1])
		local PgmCommand = ParamTab[2]

		if(PgmCommand == "Open") then
			ud.PgmInfoList[PgmID]:Open()
		elseif(PgmCommand == "Close") then
			ud.PgmInfoList[PgmID]:Close()
		elseif(PgmCommand == "Toggle") then
			ud.PgmInfoList[PgmID]:Toggle()
		end
	end
	

	function ud.CMDS.UC_KEY_PRESS(CmdData)
		local ParamTab = StringSplit(CmdData)
		local PartitionID = tonumber(ParamTab[1])
		local KeyName = ParamTab[2]

		ud.PartitionInfoList[PartitionID]:HandleRawKeyPress(KeyName)
	end


	----------------------------------------------------------------------------
	--	Commands to simulate hardware actions
	----------------------------------------------------------------------------

	function ud:HW_AdjustZoneCount(NewZoneCount)
print("NewZoneCount is: " .. tostring(NewZoneCount))
		local OldZoneCount = #self.ZoneInfoList
		local nNewZoneCount = tonumber(NewZoneCount)
		if(OldZoneCount ~= nNewZoneCount) then
			if(OldZoneCount > nNewZoneCount) then
				-- losing zones
				for ZoneIndex = (nNewZoneCount + 1), OldZoneCount do
					self.ZoneInfoList[ZoneIndex]:ReportRemoveZone()
					self.ZoneInfoList[ZoneIndex] = nil
				end
			else
				-- adding zones
				for ZoneIndex = (OldZoneCount + 1), nNewZoneCount do
					local NewZone = UZoneInfo.Create(ZoneIndex)
					self.ZoneInfoList[ZoneIndex] = NewZone
					
					-- assign this zone to any partitions it may be part of
					for PartitionIndex, TargPartition in pairs(self.PartitionInfoList) do
						local CurAssignmentList = ZoneToPartitionAssignments[PartitionIndex]
				
						--[[
						for k,v in pairs(CurAssignmentList) do
							if(ZoneIndex == v) then
								TargPartition:AddZoneToList(NewZone)
							end
						end
						]] --

						--  assign all zone
						for i = 1, Properties['Number of Zones'], 1 do
							if(ZoneIndex == i) then
								TargPartition:AddZoneToList(NewZone)
							end
						end

					end
					
					NewZone:ReportZoneSetup()
				end
			end
		end
	end
	
	
	function ud:HW_AdjustPgmCount(NewPgmCount)
		local OldPgmCount = #self.PgmInfoList
		local nNewPgmCount = tonumber(NewPgmCount)
		if(OldPgmCount ~= nNewPgmCount) then
			if(OldPgmCount > nNewPgmCount) then
				-- losing pgms
				for PgmIndex = (nNewPgmCount + 1), OldPgmCount do
					self.PgmInfoList[PgmIndex]:ReportRemovePgm()
					self.PgmInfoList[PgmIndex] = nil
				end
			else
				-- adding pgms
				for PgmIndex = (OldPgmCount + 1), nNewPgmCount do
					local NewPgm = UPgmInfo.Create(PgmIndex)
					self.PgmInfoList[PgmIndex] = NewPgm
					NewPgm:ReportPgmState()
				end
			end
		end
	end
	
	
	function ud:HW_OpenPgm(PgmID)
		self.PgmInfoList[PgmID]:Open()
	end


	function ud:HW_ClosePgm(PgmID)
		self.PgmInfoList[PgmID]:Close()
	end


	function ud:HW_TogglePgm(PgmID)
		self.PgmInfoList[PgmID]:Toggle()
	end


	function ud:HW_OpenZone(ZoneID)
		self.ZoneInfoList[ZoneID]:Open()
	end


	function ud:HW_CloseZone(ZoneID)
		self.ZoneInfoList[ZoneID]:Close()
	end


	function ud:HW_ToggleZone(ZoneID)
		self.ZoneInfoList[ZoneID]:Toggle()
	end


	function ud:HW_HaveTrouble(TroubleDescription)
		self._CurrentTrouble = TroubleDescription
		self:ReportTrouble()
	end


	function ud:HW_TroubleEnd()
		self._CurrentTrouble = ""
		self:ReportTrouble()
	end


	function ud:HW_DisplayText1(ShowText)
		self:SendDisplayTextMessage(ud.PartitionInfoList[1], ShowText, 1)
	end

	
	function ud:HW_DisplayText2(ShowText)
		self:SendDisplayTextMessage(ud.PartitionInfoList[1], ShowText, 2)
	end
	
	function ud:HW_ClearDisplayText()
		self:SendDisplayTextMessage(ud.PartitionInfoList[1], "", 1)
		self:SendDisplayTextMessage(ud.PartitionInfoList[1], "", 2)
	end
	
	-------------------------------------------------------------------

	ud.Reset(ud)

	return ud

end



UPS_DISARMED_READY = "DISARMED_READY"
UPS_DISARMED_NOT_READY = "DISARMED_NOT_READY"
UPS_ARMED = "ARMED"
UPS_EXIT_DELAY = "EXIT_DELAY"
UPS_ENTRY_DELAY = "ENTRY_DELAY"
UPS_ALARM = "ALARM"

UAllPartitionsList = {}

UPartition = {}
function UPartition.Create(PartitionID)

	local upar =
	{
		_pID = PartitionID,
		_CurrentState = "",
		_IsEnabled = true,
		_AlwaysEnabled = false,
		_ZoneList = {},
		_DelayTime = 0,
		_ValidUserCode = Properties['User Code'],
		_CodeRequiredToArm = false
	}

 
	function upar:SetInitialState()
		LogTrace("Initializing Partition %d", self._pID)
		self:SetPartitionState(self:AllZonesReady() and UPS_DISARMED_READY or UPS_DISARMED_NOT_READY, "", 0, true)
	end

	
	function upar:SetEnabledFlag(Enabled)
		if((self._IsEnabled ~= Enabled) and (not self._AlwaysEnabled)) then
			self._IsEnabled = Enabled
			
			MessageFromDevice(string.format("U_PARTITION_ENABLED %d %s", self._pID,	tostring(self._IsEnabled)))
		end
	end

	function upar:AddZoneToList(NewZone)
		self._ZoneList[NewZone._zID] = NewZone
		NewZone:AddToPartition(self)
	end


	function upar:RemoveZone(ZoneInfo)
		self._ZoneList[ZoneInfo._zID] = nil
	end


	function upar:AllZonesReady(DoBypass)
		local RetVal = true

		for k,Zone in pairs(self._ZoneList) do
			if Zone:IsOpen() then
				if DoBypass then
					Zone:Bypass()
				elseif not Zone:IsBypassed() then
					-- if a zone is open, but not bypassed then the partition isn't ready
					RetVal = false
					break
				end
			end
		end

		return RetVal
	end


	function upar:AllZonesReady1()
		local RetVal = true
		for k,Zone in pairs(self._ZoneList) do
			if Zone:IsOpen() then
				RetVal = false
				break
			end
		end
		return RetVal
	end


	function upar:HomeZonesReady(DoBypass)
		local RetVal = true

		for k,Zone in pairs(self._ZoneList) do
			if Zone:IsHome() and Zone:IsOpen() then
				if DoBypass then
					Zone:Bypass()
				elseif not Zone:IsBypassed() then
					-- if a zone is open, but not bypassed then the partition isn't ready
					RetVal = false
					break
				end
			end
		end

		return RetVal
	end


	function upar:ClearBypass()
		for k,v in pairs(self._ZoneList) do
			if v:IsBypassed() then
				v:Unbypass()
			end
		end
	end

	function upar:ClearBypass1()
		for k,v in pairs(self._ZoneList) do
			if (v:IsBypassed() and not v:IsOpen()) then
				v:Unbypass()
			end
		end
	end


	function upar:IsArmed()
		return self._CurrentState == UPS_ARMED or self._CurrentState == UPS_EXIT_DELAY or self._CurrentState == UPS_ENTRY_DELAY
	end


	function upar:InAlarm()
		return self._CurrentState == UPS_ALARM
	end

	function upar:SetCodeRequiredToArmFlag(FlagVal)
		if(self._CodeRequiredToArm ~= FlagVal) then
			self._CodeRequiredToArm = FlagVal
			
			MessageFromDevice(string.format("U_CODE_REQUIRED_FLAG %d %s", self._pID, tostring(self._CodeRequiredToArm)))
		end
	end

	function upar:AttemptToArm(TargArmType, UserCode, DoBypass)

		self._ValidUserCode = Properties['User Code']
		self._CodeRequiredToArm = Properties['Code Required to Arm']
		LogTrace("Attempting to arm partition %d  User Code is %s   Target Type is %s  Bypass flag is %s", self._pID, UserCode, TargArmType, tostring(DoBypass))
		if (not toboolean(self._CodeRequiredToArm) or (UserCode == self._ValidUserCode)) then
			if TargArmType == "Away" then
				if self:AllZonesReady(DoBypass) then
					self:SetPartitionState(UPS_EXIT_DELAY, TargArmType, tonumber(Properties['Exit Delay']))
				 	self._DelayTimer = c4_timer:new("Exit Delay", self._DelayTime, "SECONDS", self.OnExitExpired, false, self)
					self._DelayTimer:StartTimer()
				else
					self:SendArmFailMessage("Partition Not Ready", "B")
				end
			elseif TargArmType == "Home" then
				if self:HomeZonesReady(DoBypass) then
					self:SetPartitionState(UPS_ARMED, TargArmType)
					CCM.PartitionArm(self._pID, 'Home')
				else
					self:SendArmFailMessage("Partition Not Ready", "B")
				end
			else
				self:SendArmFailMessage("Invalid Arm Type: " .. TargArmType)
			end
		else
			self:SendArmFailMessage("Invalid Code", "K")
		end
	end


	function upar:AttemptToDisarm(UserCode)
	
		LogTrace("Attempting to disarm partition %d  User Code is %s   Current state is %s", self._pID, UserCode, tostring(self._CurrentState))

		if self:IsArmed() or self:InAlarm() then
			if UserCode == self._ValidUserCode then
				self:ClearBypass()
				CCM.PartitionDisarm(self._pID)
				if self:AllZonesReady() then
					self:SetPartitionState(UPS_DISARMED_READY, "")
				else
					self:SetPartitionState(UPS_DISARMED_NOT_READY, "")
				end
			else
				self:SendDisarmFailMessage("Invalid Code")
			end
		end
	end


	function upar:HandleEmergency(EmergencyType)
		if EmergencyType == "Panic" then
			self:SetPartitionState(UPS_ALARM, "Panic")
		elseif EmergencyType == "Fire" then
			self:SetPartitionState(UPS_ALARM, "Fire")
		else
			LogTrace("Ignored  %s Emergency", EmergencyType)
		end
	end


	function upar:HandleUserCode(UserCode)
		if UserCode == self._ValidUserCode then
			if self:IsArmed() or self:InAlarm() then
				self:AttemptToDisarm(UserCode)
			else
				self:AttemptToArm("Away", UserCode)
			end
		else
			LogTrace("Code Not Valid, Do Nothing...")
		end
	end


	function upar:OnEntryExpired()
		self:StartAlarm("Burglary")
	end


	function upar:OnExitExpired()
		self:SetPartitionState(UPS_ARMED, self._ArmType)
		CCM.PartitionArm(self._pID, 'Away')
	end


	function upar:KillTimer()
		local timer = self._DelayTimer
		self._DelayTimer = nil
		if timer then
			timer:KillTimer()
		end
	end


	function upar:SendArmFailMessage(Reason, Next)
		Next = Next or "N"
		MessageFromDevice(string.format("U_ARM_FAILED %d %s %s", self._pID, uglom(Reason), uglom(Next)))
		self:SendDisplayText1(string.format("Arm Failed: %s", Reason))
	end


	function upar:SendDisarmFailMessage(Reason)
		MessageFromDevice(string.format("U_DISARM_FAILED %d %s", self._pID, uglom(Reason)))
		self:SendDisplayText1(string.format("Disarm Failed: %s", Reason))
	end


	function upar:SetPartitionState(NewState, TypeInfo, Duration, ForceReport)
		local TypeInfoUse = TypeInfo or ""
		local SomethingChanged = false
		LogTrace("SetPartitionState  Old state is %s  New State is %s  Info is %s", self._CurrentState, NewState, TypeInfoUse)
		if NewState ~= self._CurrentState or self._ArmType ~= TypeInfoUse then
			self:KillTimer()
			self._CurrentState = NewState
			self._ArmType = TypeInfoUse
			self._DelayTime = Duration or 0
			if (TypeInfoUse ~= "") then
				self.PreArmType = TypeInfoUse
			end
			SomethingChanged = true
		end

		if(SomethingChanged or ForceReport) then
			MessageFromDevice(string.format("U_PARTITION_STATE %d %s %s %d",
											self._pID,
											uglom(self._CurrentState),
											uglom(self._ArmType),
											self._DelayTime
											))
			self:SendDisplayText1(string.format("State is now: %s (%s)", self._CurrentState, self._ArmType))
		end
	end


	function upar:StartAlarm(AlarmType)
		self:SetPartitionState(UPS_ALARM, AlarmType)
	end


	function upar:ZoneChanged(WhichZone)
		LogTrace("Partition %d Zone %d changed to %s", self._pID, WhichZone._zID, WhichZone._IsOpen and "Open" or "Closed")

		if WhichZone:IsAlwaysArmed() then
			if WhichZone._IsOpen then
				self:StartAlarm(C4_SECURITY_SIM_ZONE_TYPES[WhichZone._ZoneTypeID])
			end
		else
			if self._CurrentState == UPS_ARMED then
				if (self._ArmType == "Away" and not self:AllZonesReady())  or
					 (self._ArmType == "Home" and not self:HomeZonesReady()) then
					self:SetPartitionState(UPS_ENTRY_DELAY, nil, tonumber(Properties['Entry Delay']))
				 	self._DelayTimer = c4_timer:new("Entry Delay", self._DelayTime, "SECONDS", self.OnEntryExpired, false, self)
					self._DelayTimer:StartTimer()
				else
					self:ClearBypass1()
				end
			elseif self._CurrentState == UPS_EXIT_DELAY then
				-- exit delay short cut when all zones close
				if self:AllZonesReady1() then
					self:SetPartitionState(UPS_ARMED, self._ArmType)
				end
			elseif self._CurrentState == UPS_ENTRY_DELAY then
				-- UPS_DISARMED_NOT_READY
				--[[
				if (self.PreArmType == "Away" and self:AllZonesReady())  or
					(self.PreArmType == "Home" and self:HomeZonesReady()) then
					self:KillTimer()
					self:SetPartitionState(UPS_ARMED, self.PreArmType)
				end
				]]--
			elseif self._CurrentState == UPS_ALARM then
				-- ignore zone changes here
			else -- disarmed
				self:SetPartitionState(self:AllZonesReady() and UPS_DISARMED_READY or UPS_DISARMED_NOT_READY)
			end
		end
		
		self:SendDisplayText2(string.format("Zone %d is %s", WhichZone._zID, WhichZone:IsOpen() and "Open" or "Closed"))
	end

	
	function upar:HandleRawKeyPress(KeyName)
		LogTrace("Key pressed: %s", KeyName)
		self:SendDisplayText1(string.format("Key was pressed: %s", KeyName))
	end
	
	
	
	function upar:SendDisplayText1(DispText)
		MessageFromDevice(string.format("U_DISPLAY_TEXT %d %s 1", self._pID, uglom(DispText)))
	end

	
	function upar:SendDisplayText2(DispText)
		MessageFromDevice(string.format("U_DISPLAY_TEXT %d %s 2", self._pID, uglom(DispText)))
	end


	function upar:Reset()
		self._ArmType = ""
		self._PreArmType = ""
		self._InAlarm = false
		
		self:SetInitialState()
	end


	upar:Reset()
	UAllPartitionsList[PartitionID] = upar

	return upar

end	-- UPartition.Create()


-- Set some different zone types
-- C4_SECURITY_SIM_ZONE_TYPES.DOOR=1,
-- C4_SECURITY_SIM_ZONE_TYPES.WINDOW=2,
-- C4_SECURITY_SIM_ZONE_TYPES.BURGLARY=3,
-- C4_SECURITY_SIM_ZONE_TYPES.MOTION=4,
-- C4_SECURITY_SIM_ZONE_TYPES.FIRE=5,
-- C4_SECURITY_SIM_ZONE_TYPES.WATER=6,
-- C4_SECURITY_SIM_ZONE_TYPES.SMOKE=7,
-- C4_SECURITY_SIM_ZONE_TYPES.INTERIOR=8,
ZoneTypeDesignations = 
{
	C4_SECURITY_SIM_ZONE_TYPES.BURGLARY,	-- Zone 1
	C4_SECURITY_SIM_ZONE_TYPES.DOOR,		-- Zone 2
	C4_SECURITY_SIM_ZONE_TYPES.MOTION,		-- Zone 3 
	C4_SECURITY_SIM_ZONE_TYPES.WINDOW,		-- Zone 4
	C4_SECURITY_SIM_ZONE_TYPES.WINDOW,		-- Zone 5
	C4_SECURITY_SIM_ZONE_TYPES.INTERIOR,	-- Zone 6
	C4_SECURITY_SIM_ZONE_TYPES.WINDOW,		-- Zone 7
	C4_SECURITY_SIM_ZONE_TYPES.DOOR,		-- Zone 8
	C4_SECURITY_SIM_ZONE_TYPES.BURGLARY,	-- Zone 9
	C4_SECURITY_SIM_ZONE_TYPES.SMOKE,		-- Zone 10
	C4_SECURITY_SIM_ZONE_TYPES.FIRE,		-- Zone 11
	C4_SECURITY_SIM_ZONE_TYPES.MOTION,		-- Zone 12
	C4_SECURITY_SIM_ZONE_TYPES.INTERIOR,	-- Zone 13
	C4_SECURITY_SIM_ZONE_TYPES.INTERIOR,	-- Zone 14
	C4_SECURITY_SIM_ZONE_TYPES.MOTION,		-- Zone 15
	C4_SECURITY_SIM_ZONE_TYPES.BURGLARY,	-- Zone 16
}


UZoneInfo = {}
function UZoneInfo.Create(ZoneID)

	local zi = {}
	zi._zID = ZoneID
	zi._PartitionList = {}
	zi._AttachedPgm = nil
	zi._ZoneTypeID = C4_SECURITY_SIM_ZONE_TYPE_DEFAULT

	function zi:AddToPartition(WhichPartition)
		self._PartitionList[WhichPartition._pID] = WhichPartition
		LogTrace("Zone %d is now a member of Partition %d *******", self._zID, WhichPartition._pID)
	end


	function zi:AssignPartitions(Partitions)
		for PartitionId, Partition in pairs(UAllPartitionsList) do
			Partition:RemoveZone(self)
		end
 
		self._PartitionList = {}
		local index = 1, PartitionID
		while true do
			local comma, nextIndex = Partitions:find(",", index)
			if comma == nil then break end
			PartitionID = PartitionNumber(Partitions, index, comma)
			UAllPartitionsList[PartitionID]:AddZoneToList(self)
			index = nextIndex + 1
		end
		PartitionID = PartitionNumber(Partitions, index, comma)
		UAllPartitionsList[PartitionID]:AddZoneToList(self)
	end


	function zi:ListPartitions()
		local Result = {}
		for PartitionID, Partition in pairs(self._PartitionList) do
			table.insert(Result, PartitionID)
		end
		return (#Result > 0) and table.concat(Result, ",") or "0"
	end


	function zi:IsBypassed()
		return self._IsBypassed
	end


	function zi:IsHome()
		return self._ZoneTypeID == C4_SECURITY_SIM_ZONE_TYPES.DOOR or self._ZoneTypeID == C4_SECURITY_SIM_ZONE_TYPES.WINDOW or self._ZoneTypeID == C4_SECURITY_SIM_ZONE_TYPES.BURGLARY --TODO include correct zone types
	end


	function zi:IsOpen()
		return self._IsOpen
	end


	function zi:Open()
		if(not self._IsOpen) then
			self._IsOpen = true
			self:MyStateChanged()
		end
	end


	function zi:Close()
		if(self._IsOpen) then
			self._IsOpen = false
			self:MyStateChanged()
		end
	end


	function zi:Toggle()
		self._IsOpen = (not self._IsOpen)
		self:MyStateChanged()
	end


	function zi:Bypass()
		if(not self._IsBypassed) then
			self._IsBypassed = true
			self:MyStateChanged()
		end
	end


	function zi:Unbypass()
		if(self._IsBypassed) then
			self._IsBypassed = false
			self:MyStateChanged()
		end
	end


	function zi:MyStateChanged()
		LogTrace("Zone %d State changed: %s   %s", self._zID, self:IsOpen() and "Open" or "Closed", self:IsBypassed() and "Bypassed" or "Not Bypassed")
		self:ReportZoneState()

		for k,v in pairs(self._PartitionList) do
			v:ZoneChanged(self)
		end
		
		if(self._AttachedPgm) then
			if(self._IsOpen) then
				self._AttachedPgm:Open()
			else
				self._AttachedPgm:Close()
			end
		end
	end


	function zi:DoControlOpen()
		self:Open()
	end


	function zi:DoControlClose()
		self:Close()
	end


	function zi:DoControlToggle()
		self:Toggle()
	end


	function zi:IsAlwaysArmed()
		return	(
				(self._ZoneTypeID == C4_SECURITY_SIM_ZONE_TYPES.FIRE)
			or	(self._ZoneTypeID == C4_SECURITY_SIM_ZONE_TYPES.WATER)
			or	(self._ZoneTypeID == C4_SECURITY_SIM_ZONE_TYPES.SMOKE)
			)
	end


	function zi:AdjustAttributes(ZoneName, ZoneTypeID, Partitions)
		self._ZoneName = ZoneName
		self._ZoneTypeID = ZoneTypeID
		if Partitions then self:AssignPartitions(Partitions) end
		LogTrace("Adjusted Zone %d: Name = %s, TypeID = %d, Partitions = %s", self._zID, self._ZoneName, self._ZoneTypeID, Partitions)
		self:ReportZoneSetup()
	end

	
	function zi:ReportZoneSetup()
		MessageFromDevice(string.format("U_ZONE_SETUP %d %s %d %s %s %s",
										self._zID,
										uglom(self._ZoneName),
										self._ZoneTypeID,
										uglom(self:ListPartitions()),
										self._IsOpen and "Open" or "Closed",
										self._IsBypassed and "Bypassed" or "Unbypassed"
										))
	end
	
	
	function zi:ReportZoneState()
		MessageFromDevice(string.format("U_ZONE_STATE %d %s %s",
										self._zID,
										self._IsOpen and "Open" or "Closed",
										self._IsBypassed and "Bypassed" or "Unbypassed"
										))
	end

	
	function zi:ReportRemoveZone()
		MessageFromDevice(string.format("U_REMOVE_ZONE %d", self._zID))
	end
	
	
	function zi:Reset()
		self._ZoneName = "Zone " .. tostring(self._zID)
		self._IsOpen = false
		self._IsBypassed = false
		self._ZoneTypeID = ZoneTypeDesignations[(self._zID <= #ZoneTypeDesignations) and self._zID or ((self._zID % 4) + 1)]
	end

	zi:Reset()
	zi:ReportZoneSetup()
 
	return zi

end	-- UZoneInfo.Create()



UPgmInfo = {}
function UPgmInfo.Create(PgmID)

	local pi = {}
	pi._pID = PgmID
	pi._IsOpen = false
	pi._AttachedZone = nil
	
	function pi:IsOpen()
		return self._IsOpen
	end


	function pi:Open()
		if(not self._IsOpen) then
			self._IsOpen = true
			self:ReportPgmState()
		end
	end


	function pi:Close()
		if(self._IsOpen) then
			self._IsOpen = false
			self:ReportPgmState()
		end
	end


	function pi:Toggle()
		self._IsOpen = (not self._IsOpen)
		self:ReportPgmState()
	end


	function pi:ReportPgmState()
		MessageFromDevice(string.format("U_PGM_STATE %d %s", self._pID,	self._IsOpen and "Open" or "Closed"))
		
		if(self._AttachedZone) then
			if(self._IsOpen) then
				self._AttachedZone:Open()
			else
				self._AttachedZone:Close()
			end
		end

	end


	function pi:DoControlOpen()
		self:Open()
	end


	function pi:DoControlClose()
		self:Close()
	end


	function pi:DoControlToggle()
		self:Toggle()
	end


	function pi:Reset()
		self._IsOpen = false
	end

	
	function pi:ReportPgmSetup()
		MessageFromDevice(string.format("U_PGM_SETUP %d", self._pID))
	end
	
	
	function pi:ReportRemovePgm()
		MessageFromDevice(string.format("U_REMOVE_PGM %d", self._pID))
	end
	
	pi:Reset()
	pi:ReportPgmSetup()
 
	return pi

end -- UPgmInfo.Create()
