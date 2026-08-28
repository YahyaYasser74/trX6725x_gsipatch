#! /system/bin/sh

# Adjusting Swappiness
echo '125' > /proc/sys/vm/swappiness;

# Fixation to Bypass Broken Unisoc's HWC Pipelines
setprop debug.sf.enable_hwc_vds 1
setprop ro.surface_flinger.max_frame_latency 1

# Optimized Background Process Control
setprop ro.config.fha_enable false
setprop persist.sys.fha_enable false

# Optimized AOSP Memory Aging & App Management
setprop ro.sys.fw.bg_apps_limit 32
setprop ro.sys.fw.empty_apps_limit 24
setprop ro.MAX_HIDDEN_APPS 16

# Adjusts The General System Parameters
setprop ro.HOME_APP_ADJ 0
setprop video.accelerate.hw 1

# Google Service Reduce Drain Tweaks Set Config
sleep '0.001'
su -c 'pm enable com.google.android.gms'
sleep '0.001'
su -c 'pm enable com.google.android.gsf'
sleep '0.001'
su -c 'pm enable com.google.android.gms/.update.SystemUpdateActivity'
sleep '0.001'
su -c 'pm enable com.google.android.gms/.update.SystemUpdateService'
sleep '0.001'
su -c 'pm enable com.google.android.gms/.update.SystemUpdateServiceActiveReceiver'
sleep '0.001'
su -c 'pm enable com.google.android.gms/.update.SystemUpdateServiceReceiver'
sleep '0.001'
su -c 'pm enable com.google.android.gms/.update.SystemUpdateServiceSecretCodeReceiver'
sleep '0.001'
su -c 'pm enable com.google.android.gsf/.update.SystemUpdateActivity'
sleep '0.001'
su -c 'pm enable com.google.android.gsf/.update.SystemUpdatePanoActivity'
sleep '0.001'
su -c 'pm enable com.google.android.gsf/.update.SystemUpdateService'
sleep '0.001'
su -c 'pm enable com.google.android.gsf/.update.SystemUpdateServiceReceiver'
sleep '0.001'
su -c 'pm enable com.google.android.gsf/.update.SystemUpdateServiceSecretCodeReceiver'

# Optimizting Display Backlight
if getprop ro.vendor.build.fingerprint | grep -iq -e infinix/x6725; then
  setprop ro.vendor.transsion.backlight_hal.optimization 1
fi

if getprop ro.vendor.build.fingerprint | grep -iq -e infinix/x6725c; then
  setprop ro.vendor.transsion.backlight_hal.optimization 1
fi

if getprop ro.vendor.build.fingerprint | grep -iq -e infinix/x6725b; then
  setprop ro.vendor.transsion.backlight_hal.optimization 1
fi

# Fix for non-AMOLED Transsion devices where brightness would be dimmer than usual
if [ -n "$(getprop ro.vendor.transsion.backlight_12bit)" ];then
    setprop ro.vendor.transsion.backlight_hal.optimization $(getprop ro.vendor.transsion.backlight_12bit)
fi
