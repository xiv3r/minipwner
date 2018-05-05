#!/bin/sh
# Name:     setup.sh
# Purpose:  Install the MiniPwner overlay to OpenWrt
# By:       Michael Vieau
# By:       Nicholas Adamou
# Date:     12.12.14
# Modified  5.5.18
# Rev Level 0.1
# -----------------------------------------------

declare BASH_UTILS_URL="https://raw.githubusercontent.com/nicholasadamou/bash-utils/master/utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

declare skipQuestions=false

trap "exit 1" TERM
export TOP_PID=$$

# ----------------------------------------------------------------------
# | Helper Functions                                                   |
# ----------------------------------------------------------------------

is_connected_to_internet() {
    # The IP for the server you wish to ping (8.8.8.8 is a public Google DNS server)
    SERVER=8.8.8.8 # Google DNS

    # Only send two pings, sending output to /dev/null
    ping -c2 ${SERVER} > /dev/null

    # If the return code from ping ($?) is not 0 (meaning there was an error)
    if [ $? != 0 ]; then
        return 1
    else
        return 0
    fi
}

restart() {
    ask_for_confirmation "Do you want to restart?"
    
    if answer_is_yes; then
        sudo shutdown -r now &> /dev/null
    fi
}

setup_minipwner() {
    cat bin/banner

    # Setup MiniPwner Dir
    tar -xf minipwner.tar -C /

    # Setup minimodes
    mv -f bin/minimodes /etc/init.d/minimodes
    chmod +x /etc/init.d/minimodes
    ln -s /etc/init.d/minimodes /etc/rc.d/S99minimodes
    chmod +x /etc/rc.d/S99minimodes

    # Move files as needed
    mv -f bin/minimodes.html /www/minimodes.html
    chmod +x /www/minimodes.html
    mv -f bin/firewall /etc/config/firewall
    chmod 644 /etc/config/firewall
    mv -f bin/banner /etc/banner
    chmod 644 /etc/banner

    # Clean up
    rm -f bin
    rm -f setup.sh

    echo "The MiniPwner Overlay 2.0.0 has been applied."
    echo "Reboot your device for everything to take effect."
    echo "---------------------------------------------------"
}

# ----------------------------------------------------------------------
# | Main                                                               |
# ----------------------------------------------------------------------

main() {
    # Ensure that there is a working internet connection
    if is_connected_to_internet; then
        # Ensure that the following actions
        # are made relative to this file's path.

        cd "$(dirname "${BASH_SOURCE[0]}")" \
            && source <(curl -s "$BASH_UTILS_URL") \
            || exit 1

        # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        skip_questions "$@" \
            && skipQuestions=true

        # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        ask_for_sudo

        # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        setup_minipwner

        # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        
        if ! $skipQuestions; then
            restart
        fi
    fi
}

main "$@"