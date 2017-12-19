#!/bin/bash
function vpn-connect {
/usr/bin/env osascript <<-EOF
set vpn_name to "'Rackspace'"
set user_name to "urs_ord_2"
set otp_token to "$1"
tell application "System Events"
        set rc to do shell script "scutil --nc status " & vpn_name
        if rc starts with "Connected" then
            do shell script "scutil --nc stop " & vpn_name
        else
            do shell script "scutil --nc start " & vpn_name
            delay 2
            keystroke otp_token
            keystroke return
        end if
end tell
EOF
}

function vpn-disconnect {
/usr/bin/env osascript <<-EOF
set vpn_name to "'Rackspace'"
set user_name to "urs_ord_2"
tell application "System Events"
        set rc to do shell script "scutil --nc status " & vpn_name
        if rc starts with "Connected" then
            do shell script "scutil --nc stop " & vpn_name
        end if
end tell
return
EOF
}

function vpn() {
	vault_read "vpn2" "password" | tr -d '\n' | pbcopy
}