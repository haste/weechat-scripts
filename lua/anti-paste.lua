-- meh
local gettime = require'socket'.gettime

weechat.register('anti-paste', 'haste', '1.0', 'GPL3', 'Block single-line pastes.', '', '')

-- Constants as functions :(
local WEECHAT_RC_OK = weechat.WEECHAT_RC_OK()
local WEECHAT_RC_OK_EAT = weechat.WEECHAT_RC_OK_EAT()

local inputTime
function hook_command_run(src)
	if(src == 'anti-paste') then
		if(inputTime and inputTime < .005) then
			inputTime = nil
			return WEECHAT_RC_OK_EAT
		end
	end

	return WEECHAT_RC_OK
end

local inputStart
function signal(src, event, key)
	-- Reset the timer when we switch buffers.
	if(event == 'buffer_switch') then
		inputStart = nil
	elseif(key == '^M' and inputStart) then
		inputTime = gettime() - inputStart
		inputStart = nil
	elseif(key:sub(1,1) ~= '^' and not inputStart) then
		inputTime = nil
		inputStart = gettime()
	end

	return WEECHAT_RC_OK
end

function reset(src, buffer, event)
	if(src == 'anti-paste') then
		inputStart = nil
	end

	return WEECHAT_RC_OK
end

weechat.hook_signal('key_pressed', 'signal', '')
weechat.hook_signal('buffer_switch', 'signal', '')
weechat.hook_command_run('/input return', 'hook_command_run', 'anti-paste')

weechat.hook_command_run('/input history_next', 'reset', 'anti-paste')
weechat.hook_command_run('/input history_previous', 'reset', 'anti-paste')
weechat.hook_command_run('/input move_next_char', 'reset', 'anti-paste')
weechat.hook_command_run('/input move_previous_char', 'reset', 'anti-paste')
