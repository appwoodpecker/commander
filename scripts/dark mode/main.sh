osascript -e '
tell application "System Events"
	tell appearance preferences
		if dark mode is true then
			set dark mode to false
		else
			set dark mode to true
		end if
	end tell
end tell'