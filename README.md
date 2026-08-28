# iNFX6725-GSIPM
An GSI Patch Module Exclusively for Infinix Smart 10/Plus|NFC, Made to Optimize the user experience in GSI Builds on the UMS9230 chipset, with all the essential critical/minor patches; such as CPU Core Layout bugs, fixation for drivers (e,g. LED Indicator, OTG), restoring most of misc from stock features, etc etc.. you can explore more features even more through it!

The Requirements;

*. Magisk/KernelSU

*. LSPosed (https://github.com/JingMatrix/Vector/releases#release-v1.11.0)

-.--------------.-

the unresolved ones & with their workarounds:

#. - Unisoc HALs; well it might be weird but has some common sense that has to put in **bold** lines, especially when it controls the *display* compositor, when the display rendering it's frames, it causes high, bi-direction backpressure; if an low delay has caused during the wake up scene by longer than 500ms~, it will trigger desynchronization to send 'int' actions, which the Unisoc HALs **occasionally** skipping it, which causing the display to not be able rendering any inputs to the 'bind' or 'uevent', the only solution to this not usually needed to re-patch or recompile the code, but it might be depending on the user experience and it's tailors, here are most workarounds around this bug;

:- ^ do not set 'Charge Only' when selecting the AOD mode on some ROMs, since this is the *bug* itself, which makes HALs thinks it's at AOD mode, while it's *not*, just set it to 'disabled'/'always-on' will work fine, just pull up your device to trigger the feature itself if you want quick AOD up while charging it or anything *NOTE: flashing the stock "vendor_boot" will fix the 3000ms~ delay bug if you flashed modified one previously, it might also fix the 'Charge Only' bug that can be triggered by users that has this delay bug, also flashing the Ported ROMs such as like HiOS or any build, can actually fix some of those bugs or even more.*

#. - Virtual Display Events; sometimes, the OEM patches some certain configuration on chipset limitations, due to it's low-end budget specifications, it disables features that sometimes the normal AOSP HALs, missing some configurations or LIBs to communicate with other app permissions, since the appops has been poorly consistency on this specific vendor's device, the freedom window crashes occurs, which is why i have made an exclusive hot-fix patch;

:- ^ i have did add an internal patch which fixes the interlate permission onto 'canHostTasks' at 'VIRTUAL_DISPLAY_CAN_HOST_TASKS' flag to make it 'true' instead of 'false', the reason why it was occuring crashes due to the OEM Vendor's specifications, these changes are made to reduce the overhaul to low-end budget devices, so because of that, the patch is already included within the module, otherwise to apply the patch: you should install lsposed firstly to enable it and when you open LSPosed Modules, go inside 'FDWinPatch' and enable 'System Framework' then restart the device to take the full effects, then test freedom window feature and you will see the magic.

#. - Red Blinking Backlight; (Prioximity LED Sensor); yeah whatever, i know it's annoying when you wake up and you realize there's *red flags* everywhere besides your LED indicator but, there's no way to re-mapping this backlight with any modules it patches, the only workaround it is;

:- ^ decompile the blob code from the Vendor Device and map it to standard, known lanes, which GSI Builds mainly leaks at some **points**, and that's one of these glories, *Informations: Historical but Useful, Unisoc has been unoptimized with GSI, sincely when it's not common between the people, as it was only made for low-end platforms, so it wasn't important for developers or builders to fix these chipset's bugs*, and since of now; *it will remains as unsloved under the license of Unisoc HALs*

#----------------------------#

the workarounds & tips for full fixed experience:

#. - Statusbar Paddings Allocation; since then the overlays fixed the *bad compensive notch display with ui elements*, it still didn't optimize the statusbar paddings, so use this workaround to match these values with the localized overlay;

:- ^ go to phh treble -> interface settings -> go to 'Set Statusbar Paddings..' with top '8', start '10', end '10', then restart the 'SystemUI' or just perform an full restart (more effictive).

#. - Screen Recording Fixation; Google has recently introduced at late of 2023; the 'OMX' codecs for such as an fallback software composition, which makes *conflicts* with pipelines upon Unisoc Hardware Media codecs (via StageFright AOSP combination), since of that, you must apply the fallback software composition instead since Unisoc HALs are poorly made;

:- ^ go to phh treble -> misc features -> select 'Force Software Codecs', then restart the device to take the effects. *NOTE: if this method didn't work with you, then go to phh treble -> misc features -> select 'Prefer Hardware Codecs' and disable 'Force Software Codecs', it will use native, CCode from Unisoc HALs if it works even better.*

#. - VoLTE / 4G Connectivity Issues; every chipset vendor has specific IMS communication instead of the international 'CAF' complication that AOSP uses by default, which causes 4G issues and fallback to LTE/CMA radio interfaces since it doesn't have an app that maps these calls to these specialized IMS applications, because of that, you must use these settings inside phh treble;

:- ^ go to phh treble -> ims settings -> enable all settings and firstly install the ims apk via it, then click 'Create APN' to apply the changes, then fully restart the phone to take the changes.

#. - Display Backlight Adjustments; this modules fixes the brightness backlight issues, but it might not be enough, so you can perform this workaround to restore full brightness activity;

:- ^ go to phh treble -> display settings -> enable both of "Force alternative backlight scale" and "Allow setting brightness to the lowest possible", and lock down your display and lock up it again, and you will see the brightness adjust normally.

#. - Optimize Blur Rendering; this module enables blur rendering composition by default, if you want fully lightweight experience, you can disable it entirely via this method;

:- ^ go to phh treble -> display settings -> go to blur rendering and set it to 'disabled', then restart 'SystemUI' to take the effects.

#. - Optimize UI Rendering; the transitions & animations seems not smooth as i see so, even though this module optimizes the UI Rendering as much as possible, sometimes it might not be the best, instead, you can reach with my tweaks with this other phh treble feature for fully smooth experience;

:- ^ go to phh treble -> display settings -> select "Disable HW Overlays"/"Disable SF HWC backpressure" or "Power-mode monitor" to fix more HALs problems that conflicts with SystemUI, then restart the device to take full effects. *NOTE: it might causes more overheating and battery draining since there's no handling through the device HW Overlays, it will uses fully compatible software fallback methods, but it will make the experience even more compatible, only enable this if you see my tweaks aren't enough.*

#. - Optimize Display's Colors; this module has internal patches to correct colors saturation, but none of those works (sadly), so you can manually set color saturations via this app i have included within the module;

:- ^ open 'Sa2ration', then let it grant the root pivileges, set the saturation to '1.30', and exit the app, now your display will look more premium in style! *NOTE: the display color saturation will sometimes restore to the default value after an reboot, so you shall apply the same value everytime sooner.*

#---------...---------#

That's all, Hope you to enjoy with more, fair experience on GSI Builds even fluently, and if you want more essentials/latest news for this device, check my telegram group for module news and incoming updates via "https://t.me/iX6725NEWS", with the mainly group which finds many X6725 users there with helping and essentials via "@smart10mirror", Enjoy! :D
