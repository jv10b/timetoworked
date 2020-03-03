#! /bin/bash

MYWORKLOG="$HOME/.timetoworked/timetoworked.$( date "+%Y" ).log"
MONDAY=1
TUESDAY=2
WEDNESDAY=3
THURSDAY=4
FRIDAY=5
SATURDAY=6
SUNDAY=7

declare -A HOURSBYWEEKDAY
HOURSBYWEEKDAY[$MONDAY]=7
HOURSBYWEEKDAY[$TUESDAY]=7
HOURSBYWEEKDAY[$WEDNESDAY]=7
HOURSBYWEEKDAY[$THURSDAY]=7
HOURSBYWEEKDAY[$FRIDAY]=7
HOURSBYWEEKDAY[$SATURDAY]=0
HOURSBYWEEKDAY[$SUNDAY]=0

declare -A MINUTESBYWEEKDAY
MINUTESBYWEEKDAY[$MONDAY]=420
MINUTESBYWEEKDAY[$TUESDAY]=420
MINUTESBYWEEKDAY[$WEDNESDAY]=420
MINUTESBYWEEKDAY[$THURSDAY]=420
MINUTESBYWEEKDAY[$FRIDAY]=420
MINUTESBYWEEKDAY[$SATURDAY]=0
MINUTESBYWEEKDAY[$SUNDAY]=0

weekday=$(date +%u)
workinghours=$HOURSBYWEEKDAY[weekday]
workingminutes=$HOURSBYWEEKDAY[weekday]

function printHelp {
    echo ""
    echo "Uso:"
    echo " timetoworked [opciones]"
    echo ""
    echo "Opciones:"
    echo " -a     Imprime todo el historico"
    echo " -h     Imprime esta ayuda"
    echo " -i     Imprime el historico de entradas y salidas"
    echo " -r     Resetea la hora de entrada del día actual"
    echo ""
}

function departureTime {
    if [[ -f "$MYWORKLOG" ]]; then
        readFile
        lastdate=${lines[-1]:0:10}
    else
        lastdate="nothing"
    fi
    currentdate=$( date "+%Y/%m/%d" )
    if [[ "$currentdate" != "$lastdate" ]]; then
        startDay
        readFile
    fi
    departureTime=${lines[-1]:19:5}
    echo "Hora de salida para hoy las $departureTime"
}

function printPartialHistoryLog {
    echo "Historico de horas de entrada y salida"
    tail "$MYWORKLOG"     
}

function printAllHistoryLog {
    echo "Historico de horas de entrada y salida"    
    readFile
    printf '%s' "${lines[@]}"
}

function resetEntryTime {
    echo "Introduce la nueva hora de entrada (hh:mm)"
    read newtime

    deleteLastLine

    ymd=$( date "+%Y/%m/%d" )
    newdate=$( date "+%Y/%m/%d %R" -d "$ymd $newtime" )

    departureDate=$( date "+%R" -d "$newdate today + $workingminutes minutes")

    writeFile "$newdate - $departureDate - $workinghours h"
}

function startDay {
    datenow=$( date "+%Y/%m/%d %R" )
    
    departureTime=$( date "+%R" -d "$workingminutes minutes" )

    writeFile "$datenow - $departureTime - $workinghours h"
}

function readFile {
    readarray lines < "$MYWORKLOG"
}

function writeFile {
    echo $1 >> "$MYWORKLOG"
}

function deleteLastLine {
    sed -i "$ d" "$MYWORKLOG"
}

function errorParam {
    echo ""
    echo "La opción '$1' no se encuentra disponible"
    printHelp
}

#  no params, show departure time
if [[ $# -eq 0 ]] ; then
    departureTime
    exit 0
fi

while (( $# ))
do
    case $1 in
        -h )
            printHelp
            ;;
        -i )
            printPartialHistoryLog
            ;;
        -a )
            printAllHistoryLog
            ;;
        -r )
            resetEntryTime
            ;;
        -s )
            startDay
            ;;
        * )
            errorParam $1
            ;;
    esac

    shift
done


