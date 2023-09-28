#!/bin/bash
# A tiny program to print Apple logo and System Information
# Author: Jeffrey Hann (https://obihann.github.io/archey-osx/)
# Modified by Quang Nguyen on Jul 08, 2023

# Print program help
if [[ $1 == "-h" ]]; then
    echo -e "

    Print Apple logo and System Information
    Add a -c option to enable classic color logo

    Copyright (c) 2023 Quang Nguyen. All rights reserved.

    "
    exit;
fi

# Variables

## User name
user=$(whoami)

## Host name
hostname=$(hostname | sed 's/.local//g')

## IP address
ipaddress=$(ipconfig getifaddr en1) # Global: ipaddress=$(curl -sS eth0.me)
if [ -z ${ipaddress} ]; then
    ipaddress=$(ipconfig getifaddr en0)
    if [ -z ${ipaddress} ]; then
        ipaddress="Network not connected"
    fi
fi

## OS version
ProductName=$(sw_vers -productName)
ProductVersion=$(sw_vers -productVersion)
BuildVersion=$(sw_vers -buildVersion)
VersionMajor=$(echo ${ProductVersion} | cut -d'.' -f1)
VersionMinor=$(echo ${ProductVersion} | cut -d'.' -f2)
if [ ${VersionMajor} -gt 10 ]; then
    case ${VersionMajor} in
		14)
			VersionString="Sonoma";;
        13)
            VersionString="Ventura";;
        12)
            VersionString="Monterey";;
        11)
            VersionString="Big Sur";;
    esac
else
    case ${VersionMinor} in
        15)
            VersionString="Catalina";;
        14)
            VersionString="Mojave";;
        13)
            VersionString="High Sierra";;
        12)
            VersionString="Sierra";;
        11)
            VersionString="El Capitan";;
        10)
            VersionString="Yosemite";;
        9)
            VersionString="Mavericks";;
        8)
            VersionString="Mountain Lion";;
        7)
            VersionString="Lion";;
        6)
            VersionString="Snow Leopard";;
        5)
            VersionString="Leopard";;
        4)
            VersionString="Tiger";;
        3)
            VersionString="Panther";;
        2)
            VersionString="Jaguar";;
        1)
            VersionString="Puma";;
        0)
            VersionString="Cheetah";;
    esac
fi
if [ ${VersionMajor} -gt 12 ]; then
	ProductVersionExtra=$(sw_vers -productVersionExtra)
fi
if ! [ -z ${ProductVersionExtra} ]; then
	version="${ProductName} ${VersionString} ${ProductVersion} ${ProductVersionExtra}"
else
	version="${ProductName} ${VersionString} ${ProductVersion} (${BuildVersion})"
fi

## OS kernel
kernel=$(uname -rs)

## Uptime
uptime=$(uptime | sed 's/.*up \([^,]*\), .*/\1/')

## CPU info
cpu=$(sysctl -n machdep.cpu.brand_string)
brand=$(echo ${cpu} | awk '{print $1}')
ncpu_core=$(sysctl -n machdep.cpu.core_count)
if [[ ${brand} == "Apple" ]]; then
	ngpu_core=$(ioreg -l | grep 'gpu-core-count' | awk '{print $NF}')
	cpuinfo="${cpu} (${ncpu_core} CPU cores | ${ngpu_core} GPU cores)" 
else
	cpuinfo="${cpu} (${ncpu_core} cores)"
fi

## Memory amount
ram=$(($(sysctl -n hw.memsize)/1024**3))
if [[ ${brand} == "Apple" ]]; then
	ram="${ram} GB (Unified)"
else
	ram="${ram} GB (Separated)"
fi

## Disk usage
disk=$(df | head -10 | tail -1 | awk '{print $5}')

## Battery left
capacity=$(ioreg -c AppleSmartBattery -r | awk '$1~/Capacity/{c[$1]=$3} END{max=c["\"MaxCapacity\""]; if (max>0) {printf "%.2f%%", 100*c["\"CurrentCapacity\""]/max}}')
state=$(ioreg -c AppleSmartBattery -r | grep "IsCharging" | awk '{print $3}')
if [ -z ${capacity} ]; then
    battery="Battery not found"
else
    if [[ ${state} == "Yes" ]]; then
        battery="${capacity} (charging)"
    else
        battery="${capacity} (not charging)"
    fi
fi

## Terminal
terminal="${TERM_PROGRAM//_/ } ($TERM)"

## Login shell
shell="$SHELL"

## Number of packages installed via Homebrew
if ! type "brew" &> /dev/null; then
    hbpkgs="0 (Homebrew not installed)"
else
    hbpkgs="`brew list -l | wc -l | awk '{print $1}'`"
fi

## Number of packages installed via MacPorts
if ! type "port" &> /dev/null; then
    mppkgs="0 (MacPorts not installed)"
else
    mppkgs="`port installed | wc -l | awk '{print $1}'`"
fi

# Add a -c option to enable classic color logo
if [[ $1 == "-c" ]]; then # Try to match the original colors
    GREEN='\033[38;5;070m'  # original value: #5EBD3E
    YELLOW='\033[38;5;220m' # original value: #FFB900
    ORANGE='\033[38;5;208m' # original value: #F78200
    RED='\033[38;5;196m'    # original value: #E23838
    VIOLET='\033[38;5;127m' # original value: #973999
    BLUE='\033[38;5;032m'   # original value: #009CDF
    normal=$(tput sgr0 2>/dev/null)
    color=$(tput setaf 6 2>/dev/null)
fi

# Output
echo -e "

${GREEN}                     ##           ${normal}SYSTEM INFORMATION:${normal}
${GREEN}                  ####
${GREEN}                 ####             ${normal}User Name: ${color}$user${color}
${GREEN}                ##                ${normal}Computer Name: ${color}$hostname${color}
${GREEN}      ########     ########       ${normal}Local IP Address: ${color}$ipaddress${color}
${GREEN}    #########################     ${normal}System Version: ${color}$version${color}
${YELLOW}   ########################       ${normal}Kernel Version: ${color}$kernel${color}
${YELLOW}  ########################        ${normal}Time Since Boot: ${color}$uptime${color}
${ORANGE}  ########################        ${normal}CPU: ${color}$cpuinfo${color}
${ORANGE}  ########################        ${normal}Memory: ${color}$ram${color}
${RED}  #########################       ${normal}Disk Used: ${color}$disk${color}
${RED}   ###########################    ${normal}Battery Remaining: ${color}$battery${color}
${VIOLET}    #########################     ${normal}Terminal: ${color}$terminal${color}
${VIOLET}     #######################      ${normal}Login Shell: ${color}$shell${color}
${BLUE}      #####################       ${normal}Homebrew Packages: ${color}$hbpkgs${color}
${BLUE}        ######     ######         ${normal}MacPorts Packages: ${color}$mppkgs${color}

"
tput sgr0
