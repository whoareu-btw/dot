#!/bin/sh

foot --app-id="nmtui" --window-size-chars=65x28 -e sh -c '
    bw_palette="
        root=black,black
        window=white,black
        border=white,black
        title=white,black
        textbox=white,black
        label=white,black
        button=black,white
        actbutton=white,black
        listbox=white,black
        actlistbox=white,black
        entry=white,black
        compactbutton=white,black
        checkbox=white,black
        actcheckbox=black,white
    "
    sleep 0.5 && tput clear
    env NEWT_COLORS="$bw_palette" nmtui
'
