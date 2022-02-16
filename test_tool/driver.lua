Timer = {}
Model = {}
RepeatTimes = 0

function Model.AddTimer(timer, count, units, recur)
	local newTimer
	if (recur == nil) then recur = false end
	if (timer and timer ~= 0) then Model.KillTimer (timer) end
	newTimer = C4:AddTimer (count, units, recur)
	return newTimer
end

function Model.AddTimerSeconds(timer, count, recur)
	recur = recur or false
	return Model.AddTimer(timer, count, 'SECONDS', recur)
end

function Model.KillTimer (timer)
	if (timer) then
		return (C4:KillTimer (timer))
	else
		return (0)
	end
end

function OnTimerExpired (idTimer)
	if (idTimer == Timer['s2p1']) then
		Send2proxy1()
	end
end

function OnPropertyChanged (strProperty)
	local value = Properties[strProperty]
	if (strProperty == "Send Command") then
		Timer['s2p1'] = Model.AddTimerSeconds(Timer['s2p1'], 2, true)
	end
end





function Send2proxy1()
	if RepeatTimes > 5 then
		RepeatTimes = 0
		Timer['s2p1'] = Model.KillTimer(Timer['s2p1'])
	else
		RepeatTimes = RepeatTimes + 1
		local params = {name = 'nht', fool = 'bar', bar = 0}
		print('sending with params:')
		for k, v in pairs(params) do
			print('['..k..'] = '..v)
		end
		print('\n\n')
		C4:SendToProxy(2, 'NHT_TEST_COMMAND', params, 'NOTIFY')
	end
end