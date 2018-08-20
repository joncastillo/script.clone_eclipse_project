#!/usr/bin/bash
#clone eclipse project v1 - author: jonathan castillo

export DEFAULT_SOURCE_PROJECT="adc-ausnz-engage"

pushd .
echo "--------------------------------"
echo "Creating eclipse project..."

if [ -z "${1}" ]; then
    echo "needs a destination merc#. example ./clone_eclipse_project.sh 1234"
    echo "exiting..."
    exit
else
    export DESTINATION=${1}
fi

if [ -z "${2}" ]; then
    echo "source folder not specified.. using default value: ${DEFAULT_SOURCE_PROJECT}"
    export SOURCE_PROJECT=${DEFAULT_SOURCE_PROJECT}
else    
    export SOURCE_PROJECT=${2}
fi

if [ ! -d "${SOURCE_PROJECT}" ]; then
    echo "source folder does not exist. check ${PWD}/${SOURCE_PROJECT}"
    exit
fi

echo "--------------------------------"
echo "source project: ${SOURCE_PROJECT}"
echo "destination: ${DESTINATION}"
echo "--------------------------------"

echo "Updating git source with latest..."
cd ${SOURCE_PROJECT}
git pull
cd ..

if [ -d "adc-ausnz-engage_MERC-${DESTINATION}" ]; then
    echo "Destination folder exists! copying to adc-ausnz-engage_MERC-${DESTINATION}.bak..."
    if [ -d "adc-ausnz-engage_MERC-${DESTINATION}.bak" ]; then
        echo "Backup folder exists! deleting adc-ausnz-engage_MERC-${DESTINATION}.bak..."
        rm -rf adc-ausnz-engage_MERC-${DESTINATION}.bak
    fi

    if [ -f "/usr/bin/rsync" ]; then
        rsync --info=progress2 -ahr adc-ausnz-engage_MERC-${DESTINATION} adc-ausnz-engage_MERC-${DESTINATION}.bak
    else
        cp -r ${SOURCE_PROJECT} adc-ausnz-engage_MERC-$DESTINATION
    fi    
fi
        
echo "Copying git source to adc-ausnz-engage_MERC-${DESTINATION}..."

if [ -f "/usr/bin/rsync" ]; then
    rsync --info=progress2 -ahr ${SOURCE_PROJECT} adc-ausnz-engage_MERC-$DESTINATION
else
    cp -r ${SOURCE_PROJECT} adc-ausnz-engage_MERC-$DESTINATION
fi

cd C:\/VFI\/ide\/EclipseWorkspaces\/

echo "Copying IDE source to ${PWD}/MERC-${DESTINATION}..."
if [ -d "MERC-${DESTINATION}" ]; then
    rm -rf MERC-${DESTINATION}
fi

if [ -f "/usr/bin/rsync" ]; then
    rsync --info=progress2 -ahr ENGAGE_MAIN MERC-${DESTINATION}
else
    cp -r ENGAGE_MAIN MERC-${DESTINATION}
fi

cd MERC-${DESTINATION}/Engage

echo "Changing old config ${SOURCE_PROJECT} to use adc-ausnz-engage_MERC-${DESTINATION}..."
export SUBSTITUTE_FROM=`echo ${SOURCE_PROJECT}`
export SUBSTITUTE_TO=`echo adc-ausnz-engage_MERC-${DESTINATION}`
export SUBSTITUTE_EXPRESSION=`echo "s:${SUBSTITUTE_FROM}:${SUBSTITUTE_TO}:g"`
echo ${SUBSTITUTE_EXPRESSION}
sed -i -r ${SUBSTITUTE_EXPRESSION} .project

echo "Resetting UI..."
if [ -d "./.metadata/.plugins/org.eclipse.core.runtime" ]; then
    echo "UI reset!"
    rm -rf ./.metadata/.plugins/org.eclipse.core.runtime/.settings/com.genuitec.eclipse.theming.ui.prefs
    rm -rf ./.metadata/.plugins/org.eclipse.core.runtime/.settings/com.github.eclipsecolortheme.prefs

fi

echo "Done! Don't forget to switch to MERC-${DESTINATION} branch."
echo "--------------------------------"
popd