--[[=============================================================================
    Get, Handle and Dispatch message functions

    Copyright 2014 Control4 Corporation. All Rights Reserved.
===============================================================================]]

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.device_messages = "2014.10.16"
end

--[[=============================================================================
    GetMessage()
  
    Description:
    Used to retrieve a message from the communication buffer. Each driver is
    responsible for parsing that communication from the buffer.
  
    Parameters:
    None
  
    Returns:
    A single message from the communication buffer
===============================================================================]]
function GetMessage()
	local message = ""
	
	if ((gReceiveBuffer ~= nil) and (gReceiveBuffer ~= "")) then
		message = gReceiveBuffer
	end

	gReceiveBuffer = ""

	return message
end

--[[=============================================================================
    HandleMessage(message)]

    Description
    This is where we parse the messages returned from the GetMessage()
    function into a command and data. The call to 'DispatchMessage' will use the
    'FromSerCmd' variable as a key to determine which handler routine, function, should
    be called in the DEV_MSG table. The 'FromSerData' variable will then be passed as
    a string parameter to that routine.

    Parameters
    message(string) - Message string containing the function and value to be sent to
                      DispatchMessage

    Returns
    Nothing
===============================================================================]]
function HandleMessage(message)
	LogTrace("HandleMessage. Message is ==>%s<==", message)

	local CmdLen = message:find(" ")
	local FromSerCmd = string.sub(message, 1, CmdLen - 1)
	local FromSerData = string.sub(message, CmdLen + 1)

	DispatchMessage(FromSerCmd, FromSerData)
end

--[[=============================================================================
    DispatchMessage(MsgKey, MsgData)

    Description
    Parse routine that will call the routines to handle the information returned
    by the connected system.

    Parameters
    MsgKey(string)  - The function to be called from within DispatchMessage
    MsgData(string) - The parameters to be passed to the function found in MsgKey

    Returns
    Nothing
===============================================================================]]
function DispatchMessage(MsgKey, MsgData)
  if (DEV_MSG[MsgKey] ~= nil and (type(DEV_MSG[MsgKey]) == "function")) then
  	LogInfo("DEV_MSG." .. tostring(MsgKey) .. ":  " .. tostring(MsgData))
    DEV_MSG[MsgKey](MsgData)
  else
    LogTrace("HandleMessage: Unhandled command = " .. MsgKey)
  end
end

-- TODO: Create DEV_MSG functions for all messages

--  DCC  10/20/14    Where does this routine belong?
function SendCommand(CommandStr)
	LogTrace("Sending Command  ==>" .. CommandStr .. "<==")
	gCon:SendCommand(CommandStr)
end