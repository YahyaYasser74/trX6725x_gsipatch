#! /system/bin/sh

### Wait until the device properties system is fully initialized

until [ "$(getprop sys.boot_completed)" = "1" ]; do
sleep 3
done

# Ensure the framework has stabilized before altering core configurations
sleep 5

### --------------------------------------------------------------------

### Live Hard-Reset of Core Restrictions

### --------------------------------------------------------------------

resetprop -n ro.config.low_ram false
resetprop -n sys.config.low_ram false
resetprop -n vendor.config.low_ram false
resetprop -n ro.hardware.LowRam false
resetprop -n ro.vendor.ramconfig full

cmd overlay fabric-override android bool config_freeformWindowManagement true
cmd overlay fabric-override android bool config_supportsMultiWindow true
cmd overlay fabric-override android bool config_supportsSplitScreenMultiWindow true
cmd overlay fabric-override android bool config_supportsPictureInPicture true
cmd overlay fabric-override android bool config_avoidGfxAcceleratedWindow false
cmd overlay fabric-override android bool config_enableWallpaperService true
cmd overlay fabric-override android bool config_enableNetworkLocationOverlay true
cmd overlay fabric-override android bool config_useNewLocationProvider true
cmd overlay fabric-override android bool config_enableGeofences true

### --------------------------------------------------------------------

### Asymmetric 6x2 Core Task Tuning

### --------------------------------------------------------------------

if [ -d /dev/cpuset ]; then
echo "0-7" > /dev/cpuset/top-app/cpus
echo "6-7" > /dev/cpuset/foreground/boost/cpus
echo "0-5" > /dev/cpuset/background/cpus
echo "0-5" > /dev/cpuset/system-background/cpus
fi

if [ -d /dev/cpuctl/top-app ]; then
    echo 50 > /dev/cpuctl/top-app/cpu.uclamp.min
    echo 1 > /dev/cpuctl/top-app/cpu.uclamp.latency_sensitive
fi

if [ -d /dev/cpuctl/surfaceflinger ]; then
    echo 40 > /dev/cpuctl/surfaceflinger/cpu.uclamp.min
    echo 1 > /dev/cpuctl/surfaceflinger/cpu.uclamp.latency_sensitive
fi

### --------------------------------------------------------------------

### Stablize The Missing AOSP Features

### --------------------------------------------------------------------

cmd package add-system-feature android.software.freeform_window_management
cmd package add-system-feature android.software.picture_in_picture
cmd package add-system-feature android.software.activities_on_secondary_displays
cmd package add-system-feature android.hardware.sensor.ambient_temperature
cmd package add-system-feature android.software.ambient_display

# Optimized Display Deep Colors
settings put secure display_color_mode 2
settings put secure accessibility_display_daltonizer_enabled 0
cmd color_display set-saturation-level 85

# Adjusted Status Bar Paddings
resetprop -n persist.sys.phh.status_bar_top_padding=8
resetprop -n persist.sys.phh.status_bar_start_padding=10
resetprop -n persist.sys.phh.status_bar_end_padding=10

### --------------------------------------------------------------------

### Live Secure Settings Overlays

### --------------------------------------------------------------------

settings put secure doze_enabled 1
settings put secure doze_pulse_on_pick_up 1
settings put secure doze_pulse_on_double_tap 1
settings put secure doze_always_on 0

# Inject unrestricted overlay and task stack clearances globally
appops set uid 1000 SYSTEM_ALERT_WINDOW allow 2>/dev/null
appops set uid 1000 GET_USAGE_STATS allow 2>/dev/null

### --------------------------------------------------------------------

### Force Enable Unisoc Overlays from Stock Firmware

### --------------------------------------------------------------------

# --- 1. Core System Overlay ---
cmd overlay enable --user 0 android.unisoc.core.overlay
cmd overlay set-priority android.unisoc.core.overlay highest
cmd overlay enable --user 0 com.android.phone.auto_generated_rro_product__
cmd overlay set-priority com.android.phone.auto_generated_rro_product__ highest
cmd overlay enable --user 0 com.unisoc.auto_generated_rro_product__
cmd overlay set-priority com.unisoc.auto_generated_rro_product__ highest
cmd overlay enable --user 0 android.unisoc.power_qogirl6.overlay
cmd overlay set-priority android.unisoc.power_qogirl6.overlay highest

# --- 2. Standard Phone Overlay ---
cmd overlay enable --user 0 com.android.unisoc.phone.overlay
cmd overlay set-priority com.android.unisoc.phone.overlay highest
cmd overlay enable --user 0 com.android.unisoc.phone_core.overlay
cmd overlay set-priority com.android.unisoc.phone_core.overlay highest
cmd overlay enable --user 0 com.trassion.camera.auto_generated_rro_product__
cmd overlay set-priority com.trassion.camera.auto_generated_rro_product__ highest

# --- 3. Phone Audio/HAC Overlay ---
cmd overlay enable --user 0 com.android.unisoc.phone_hac.overlay
cmd overlay set-priority com.android.unisoc.phone_hac.overlay highest

# --- 4. Fix Connectivity & Tracking Sesnors ---
cmd overlay enable --user 0 com.unisoc.connectivity.resources.overlay.gsi
cmd overlay set-priority com.unisoc.connectivity.resources.overlay.gsi highest

# --- 5. Fix Display Composition ---
cmd overlay enable --user 0 android.unisoc.color_display.overlay
cmd overlay set-priority android.unisoc.color_display.overlay highest
cmd overlay enable --user 0 android.unisoc.display_doze.overlay
cmd overlay set-priority android.unisoc.display_doze.overlay highest
cmd overlay enable --user 0 android.unisoc.display_vrr.overlay
cmd overlay set-priority android.unisoc.display_vrr.overlay highest

### --------------------------------------------------------------------

### Fix & Re-generate the socket directory Unisoc's gpsd expects

### --------------------------------------------------------------------

mkdir -p /dev/socket/gps
chmod 775 /dev/socket/gps
chown system:system /dev/socket/gps

chmod 777 /data/vendor/gnss 2>/dev/null
chmod 777 /data/vendor/gps 2>/dev/null
chmod 666 /dev/ttyG_GNSS* 2>/dev/null
chmod 666 /dev/ttyS* 2>/dev/null

chmod 644 /system/etc/gps.conf 2>/dev/null
chown root:root /system/etc/gps.conf 2>/dev/null

GNSS_SERVICE=$(getprop | grep -E "init.svc.android.hardware.gnss" | cut -d. -f4 | cut -d] -f1)
if [ ! -z "$GNSS_SERVICE" ]; then
    setprop ctl.restart "$GNSS_SERVICE"
fi

# Re-mapping Unisoc GNSS Sensors' Hooks into GSI
sleep 3
setprop ctl.restart gpsd
setprop ctl.restart vendor.gpsd
setprop ctl.restart vendor.glp
cmd location providers set-enabled gps true

# Configures the global database to look for standardized high-accuracy providers
settings put secure location_providers_allowed "+gps,+network"
settings put secure location_mode 3
settings put global assisted_gps_enabled 1

# Whitelist Google Play Services from low-RAM background killing
dumpsys deviceidle whitelist +com.google.android.gms
dumpsys deviceidle whitelist +com.google.android.gms.policy_sidecar

### --------------------------------------------------------------------

### Fix Unisoc Drivers & Device Configurations

### --------------------------------------------------------------------
sleep 10

echo battery-charging > /sys/class/leds/sc27xx:blue/trigger
echo 1 > /sys/devices/platform/tran_charger/OTG_CTL
echo 900 > /sys/class/backlight/sprd_backlight/brightness

### --------------------------------------------------------------------

### Fix Frame Drop Delay While Screen Recording

### --------------------------------------------------------------------

# Allocate a larger frame pool size for screen capture recording surfaces
setprop debug.stagefright.ccodec 4
setprop media.settings.xml /vendor/etc/media_profiles_V1_0.xml

# Tell the media server encoder to skip frame drop validation checks
resetprop -n persist.sys.phh.omx.disable_sw 0
resetprop -n persist.sys.phh.media.hw_accel 1

# Prevents the initial 4 seconds from getting cut out during sync
setprop vendor.media.vsp.dropframe.enable 0
setprop debug.media.vsp.dropframe 0

# Fallback Adjustments
setprop media.stagefright.less-memory true
setprop media.stagefright.enable-player true
setprop media.stagefright.enable-http true
setprop media.stagefright.enable-aac true
setprop media.stagefright.enable-qcp true
setprop media.stagefright.enable-scan true

# Re-fresh the Media Codecs
setprop ctl.stop mediaserver
setprop ctl.stop audioserver
sleep 1
setprop ctl.start audioserver
setprop ctl.start mediaserver

### --------------------------------------------------------------------

### Fix VoLTE & IMS Initalization

### --------------------------------------------------------------------

# Bypass Android framework block and force Interface Media Services
setprop persist.vendor.sys.volte 1
setprop persist.vendor.sys.vowifi 1
setprop vendor.radio.ims_registered 1

### --------------------------------------------------------------------

### Fix Broken Display Power Controller HALs

### --------------------------------------------------------------------

# Keep a background loop active to catch wake-up dropouts
while true; do
    # Check if the device is transitioning out of screen-off state
    SCREEN_STATE=$(dumpsys power | grep "mRoutingDisplayPowerState" | awk -F= '{print $2}')

    # If the system reports it is trying to turn ON but remains unresponsive,
    # force a lightweight frame refresh poke to trigger the panel backlights
    if [ "$SCREEN_STATE" = "On" ] || [ "$SCREEN_STATE" = "ON" ]; then
        # Send a tiny graphic state change request to wake the HWC panel thread
        service call surfaceflinger 1008 i32 1 > /dev/null 2>&1
    fi

    # Check every 1.5 seconds to minimize battery overhead
    sleep 1.5
done &

### --------------------------------------------------------------------

### Adding Missing Optimizations from Stock

### --------------------------------------------------------------------

setprop ro.tran_appm.support=1
setprop ro.smartcaller.support=1
setprop ro.transsion.tne.support=1

### --------------------------------------------------------------------

### High-Efficiency Window Manager Refresh

### --------------------------------------------------------------------

setprop persist.sys.phh.dpi 320
prop ctl.restart surfaceflinger
