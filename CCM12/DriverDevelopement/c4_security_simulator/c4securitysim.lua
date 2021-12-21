require "common.c4_serial_connection"

C4_SECURITY_SIM_USE_ACK = true
C4_SECURITY_SIM_COMMAND_DELAY_MILLISECONDS = 150
C4_SECURITY_SIM_COMMAND_RESPONSE_TIMEOUT_SECONDS = 4

C4SecuritySim = inheritsFrom(SerialConnectionBase)


function C4SecuritySim:construct(BindingID)
	self.superClass():construct(BindingID)
end

function C4SecuritySim:Initialize()
	gControlMethod = "Serial"
	self:superClass():Initialize(C4_SECURITY_SIM_USE_ACK, C4_SECURITY_SIM_COMMAND_DELAY_MILLISECONDS, C4_SECURITY_SIM_COMMAND_RESPONSE_TIMEOUT_SECONDS)
	
	
end

function C4SecuritySim:SendCommand(CommandStr)
print("C4SecuritySim:SendCommand  SendCommand: " .. CommandStr)
	gSimDevice:ComSendToSerial(CommandStr)
end

