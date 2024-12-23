//
// This is a proof of concept plugin for Dualsense trigger haptics on macOS (and probably iOS, tvOS and visionOS)
// Build the .bundle, and pop it into a Unity project - and you can then setup some extern bindings to call into this
// This plugin currently does not take into account multiple controllers; if you need that, you probably need a more robust solution than something I cooked up while watching The Matrix!
//
//  Plugin.mm
//  DualsenseSupport
//
//  Created by Val Knight on 23/12/2024.
//

#include <GameController/GCController.h>
#include <GameController/GCDualSenseGamepad.h>

/*
 Status codes:
 
 0 => OK (e.g. operation successful)
 
 1 => No gamepad connected
 2 => Current gamepad is not DualSense
 3 => Invalid trigger index
 */

#define OK 0
#define NO_GAMEPAD 1
#define NOT_DUALSENSE 2
#define INVALID_TRIGGER_IDX 3

extern "C" uint8_t Val_Dualsense_Plugin_ModeWeaponWithStartPosition(uint8_t triggerIdx, float startPosition, float endPosition, float resistiveStrength)
{
    if (triggerIdx > 1)
    {
        return INVALID_TRIGGER_IDX;
    }
    GCController* gc = GCController.current;
    GCDualSenseAdaptiveTrigger* trigger;
    if (gc != nil)
    {
        if (gc.extendedGamepad.class == GCDualSenseGamepad.class)
        {
            GCDualSenseGamepad* gamepad = (GCDualSenseGamepad*) gc.extendedGamepad;
            if (triggerIdx == 0)
            {
                trigger = gamepad.leftTrigger;
            }
            else
            {
                trigger = gamepad.rightTrigger;
            }
            [trigger setModeWeaponWithStartPosition:startPosition endPosition:endPosition resistiveStrength:resistiveStrength];
            return OK;
        }
        return NOT_DUALSENSE;
    }
    return NO_GAMEPAD;
}

extern "C" uint8_t Val_Dualsense_Plugin_ModeVibrationWithStartPosition(uint8_t triggerIdx, float startPosition, float amplitude, float frequency)
{
    if (triggerIdx > 1)
    {
        return INVALID_TRIGGER_IDX;
    }
    GCController* gc = GCController.current;
    GCDualSenseAdaptiveTrigger* trigger;
    if (gc != nil)
    {
        if (gc.extendedGamepad.class == GCDualSenseGamepad.class)
        {
            GCDualSenseGamepad* gamepad = (GCDualSenseGamepad*) gc.extendedGamepad;
            if (triggerIdx == 0)
            {
                trigger = gamepad.leftTrigger;
            }
            else
            {
                trigger = gamepad.rightTrigger;
            }
            [trigger setModeVibrationWithStartPosition:startPosition amplitude:amplitude frequency:frequency];
            return OK;
        }
        return NOT_DUALSENSE;
    }
    return NO_GAMEPAD;
}

extern "C" uint8_t Val_Dualsense_Plugin_ModeOff(uint8_t triggerIdx)
{
    if (triggerIdx > 1)
        return INVALID_TRIGGER_IDX;
    GCController* gc = GCController.current;
    if (gc == nil)
        return NO_GAMEPAD;
    if (gc.extendedGamepad.class != GCDualSenseGamepad.class)
        return NOT_DUALSENSE;
    GCDualSenseGamepad* gcds = (GCDualSenseGamepad*) gc;
    if (triggerIdx == 0)
    {
        [gcds.leftTrigger setModeOff];
    }
    else
    {
        [gcds.rightTrigger setModeOff];
    }
    return OK;
}

// Returns 0 if not valid
extern "C" float Val_Dualsense_Plugin_Value(uint8_t triggerIdx)
{
    if (triggerIdx > 1)
    {
        return 0.0f;
    }
    
    GCController* gc = GCController.current;
    GCDualSenseAdaptiveTrigger* trigger;
    if (gc != nil)
    {
        if (gc.extendedGamepad.class == GCDualSenseGamepad.class)
        {
            GCDualSenseGamepad* gamepad = (GCDualSenseGamepad*) gc.extendedGamepad;
            if (triggerIdx == 0)
            {
                trigger = gamepad.leftTrigger;
            }
            else {
                trigger = gamepad.rightTrigger;
            }
            return trigger.value;
        }
        return 0;
    }
    return 0;
}


extern "C" bool IsCurrentControllerDualsense()
{
    GCController* gc = GCController.current;
    
    if (gc == nil)
        return false;
    
    return (gc.extendedGamepad.class == GCDualSenseGamepad.class);
}
