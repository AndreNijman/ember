aqs(1)

# NAME

aqs - command-line interface for the ember Quickshell desktop shell

# SYNOPSIS

*aqs* ipc _target_ _action_ [_args_...]++
*aqs* version++
*aqs* pam authenticate

# DESCRIPTION

*aqs* is the command-line companion for ember, a Quickshell + Go desktop
shell for Hyprland. The shell itself is a long-running QML process; the
*aqs* CLI translates short commands into IPC calls that target QML
*IpcHandler*s registered in the running shell.

A separate binary, *aqs-greeter*(1), provides the greetd greeter UI.

# IPC TARGETS

Each target accepts one or more actions. Most actions take no arguments;
where they do, the argument type is shown.

*shell*::
	*status* — JSON snapshot of shell state++
	*version* — current version (set at build time)++
	*restart* — `Quickshell.reload(true)`, hot-reload++
	*keybinds* — pointer to docs

*launcher*::
	*toggle* | *show* | *hide*

*control*::
	*toggle* | *show* | *hide*

*notifications*::
	*toggle* | *clearAll*++
	*setDnd* _true_|_false_

*lock*::
	*engage* | *lock*

*osd*::
	*volume* _real_++
	*brightness* _real_

*workspace*::
	*focus* _id_

*wallpaper*::
	*toggle* | *show* | *hide*++
	*setForWorkspace* _ws_ _path_++
	*setAll* _path_

*audio*::
	*mute* | *micmute*++
	*increment* _n_ | *decrement* _n_ — percent points

*brightness*::
	*increment* _n_ | *decrement* _n_

*keybinds*::
	*toggle* | *show* | *hide*

*singbox*::
	*toggle* | *show* | *hide* | *connect*

*clipboard*::
	*toggle* | *show* | *hide*

*overview*::
	*toggle* | *show* | *hide*

*powermenu*::
	*toggle* | *show* | *hide*

*settings*::
	*toggle* | *show* | *hide* | *open*++
	*set* _key_ _value_ — write settings.json key

# CONFIGURATION

*~/.config/aqs/settings.json*
	Persistent settings. Written by the Settings panel, hand-editable.

*~/.config/hypr/aqs/binds.conf*
	Keybind file parsed at runtime to render the cheat sheet
	(*aqs ipc keybinds toggle*). Path overridable with *AQS_BINDS_FILE*.

*/usr/share/aqs/qml/*
	Installed QML tree. Pointed at by *aqs.service*.

*/etc/greetd/config.toml*
	Configured by *install-greeter.sh* to launch *aqs-greeter*.

# ENVIRONMENT

*AQS_BINDS_FILE*
	Override path used by the cheat-sheet parser.

*AQS_SETTINGS_PATH*
	Override path used by SettingsService for reads/writes.

# FILES

*/usr/local/bin/aqs*
	The CLI itself.

*/usr/local/bin/aqs-greeter*
	The greetd greeter binary.

*/usr/local/lib/systemd/user/aqs.service*
	Systemd user unit that starts the shell at graphical-session.target.

*/usr/local/share/aqs/contrib/*
	Hyprland and greetd starter configs.

# SEE ALSO

*aqs-greeter*(1), *quickshell*(1), *Hyprland*(1), *greetd*(5)

# AUTHORS

Andre Nijman.
