
------------------------------------------------------------------------------------------------
-- AHRS PILOT AND COPILOT SYSTEM
-- GYRO DATAREF ENUMS ARE: [0]AHRS1,[1]AHRS2,[2]ELEC1,[3]ELEC2,[4]VAC1,[5]VAC2
--
-- INTERFACING CUSTOM DATAREFS WITH X-PLANE INTERNAL ONES
-------------------------------------------------------------------------------------------------




----------------------------------- LOCATE DATAREFS -----------------------------------

--startup_running = find_dataref("sim/operation/prefs/startup_running")
gyr_free_slaved_pilot = find_dataref("sim/cockpit/gyros/gyr_free_slaved[0]") --> AHRS1, free=0 or slaved=1 to magnetometer
gyr_free_slaved_copilot = find_dataref("sim/cockpit/gyros/gyr_free_slaved[1]") --> AHRS1, free=0 or slaved=1 to magnetometer
dg_drift_ahars_deg_pilot = find_dataref("sim/cockpit/gyros/dg_drift_ahars_deg") --> delta between plane heading and the DG
dg_drift_ahars_deg_copilot = find_dataref("sim/cockpit/gyros/dg_drift_ahars2_deg") --> delta between plane heading and the DG







---------------------------------------- FUNCTIONS ----------------------------------------


----------------------------------- SLOWLY ANIMATE FUNCTION
function func_animate_slowly(reference_value, animated_VALUE, anim_speed)
	SPD_PERIOD = anim_speed * SIM_PERIOD
	if SPD_PERIOD > 1 then SPD_PERIOD = 1 end
	animated_VALUE = animated_VALUE + ((reference_value - animated_VALUE) * SPD_PERIOD)
	delta = math.abs(animated_VALUE - reference_value)
	if delta < 0.05 then animated_VALUE = reference_value end
	return animated_VALUE
end


----------------------------------- PILOT MODE SWITCH (-1)TEST/(0)SLV/(1)DG
function cmd_mode_pilot_up(phase, duration)
	if phase == 0 and mode_pilot_value == 0 then mode_pilot_value = 1 end
end
function cmd_mode_pilot_dwn(phase, duration)
	if phase == 0 then mode_pilot_value = math.max(-1, mode_pilot_value - 1) end
	if phase == 2 and mode_pilot_value == -1 then mode_pilot_value = 0 end --> the spring back to 0
end


----------------------------------- COPILOT MODE SWITCH (-1)TEST/(0)SLV/(1)DG
function cmd_mode_copilot_up(phase, duration)
	if phase == 0 and mode_copilot_value == 0 then mode_copilot_value = 1 end
end
function cmd_mode_copilot_dwn(phase, duration)
	if phase == 0 then mode_copilot_value = math.max(-1, mode_copilot_value - 1) end
	if phase == 2 and mode_copilot_value == -1 then mode_copilot_value = 0 end --> the spring back to 0
end


----------------------------------- PILOT DG ADJUST SWITCH (-1)LH/(0)NONE/(1)RH
function cmd_adjust_pilot_up(phase, duration)
	if phase == 1 and duration > 0.1 and adjust_pilot_value == 0 then adjust_pilot_value = -1 end
	if phase == 2 and adjust_pilot_value == -1 then adjust_pilot_value = 0 end --> the spring back to 0
end
function cmd_adjust_pilot_dwn(phase, duration)
	if phase == 1 and duration > 0.1 and adjust_pilot_value == 0 then adjust_pilot_value = 1 end
	if phase == 2 and adjust_pilot_value == 1 then adjust_pilot_value = 0 end --> the spring back to 0
end


----------------------------------- COPILOT DG ADJUST SWITCH (-1)LH/(0)NONE/(1)RH
function cmd_adjust_copilot_up(phase, duration)
	if phase == 1 and duration > 0.1 and adjust_copilot_value == 0 then adjust_copilot_value = -1 end
	if phase == 2 and adjust_copilot_value == -1 then adjust_copilot_value = 0 end --> the spring back to 0
end
function cmd_adjust_copilot_dwn(phase, duration)
	if phase == 1 and duration > 0.1 and adjust_copilot_value == 0 then adjust_copilot_value = 1 end
	if phase == 2 and adjust_copilot_value == 1 then adjust_copilot_value = 0 end --> the spring back to 0
end









----------------------------------- CREATE DATAREFS AND COMMANDS -----------------------------------

CitX_ahrs_mode_pilot = create_dataref("laminar/CitX/ahrs/mode_pilot","number") --> -1 test, 0 slaved, 1 dg
mode_pilot_value = create_dataref("laminar/CitX/ahrs/mode_pilot_term","number") --> -1 test, 0 slaved, 1 dg
CitX_ahrs_mode_copilot = create_dataref("laminar/CitX/ahrs/mode_copilot","number")
CitX_ahrs_adjust_pilot = create_dataref("laminar/CitX/ahrs/adjust_pilot","number") --> -1 dg left, 0 none, 1 dg right
adjust_pilot_value = create_dataref("laminar/CitX/ahrs/adjust_pilot_term","number") --> -1 dg left, 0 none, 1 dg right
CitX_ahrs_adjust_copilot = create_dataref("laminar/CitX/ahrs/adjust_copilot","number")

cmdmodepilotup = create_command("laminar/CitX/ahrs/cmd_mode_pilot_up","AHRS mode pilot switch up",cmd_mode_pilot_up)
cmdmodepilotdn = create_command("laminar/CitX/ahrs/cmd_mode_pilot_dwn","AHRS mode pilot switch dwn",cmd_mode_pilot_dwn)
cmdmodecopilotup = create_command("laminar/CitX/ahrs/cmd_mode_copilot_up","AHRS mode copilot switch up",cmd_mode_copilot_up)
cmdmodecopilotdn = create_command("laminar/CitX/ahrs/cmd_mode_copilot_dwn","AHRS mode copilot switch dwn",cmd_mode_copilot_dwn)
cmdadjustpilotup = create_command("laminar/CitX/ahrs/cmd_adjust_pilot_up","AHRS DG adjust pilot switch up",cmd_adjust_pilot_up)
cmdadjustpilotdn = create_command("laminar/CitX/ahrs/cmd_adjust_pilot_dwn","AHRS DG adjust pilot switch dwn",cmd_adjust_pilot_dwn)
cmdadjustcopilotup = create_command("laminar/CitX/ahrs/cmd_adjust_copilot_up","AHRS DG adjust copilot switch up",cmd_adjust_copilot_up)
cmdadjustcopilotdn = create_command("laminar/CitX/ahrs/cmd_adjust_copilot_dwn","AHRS DG adjust copilot switch dwn",cmd_adjust_copilot_dwn)











--------------------------------- DO THIS EACH FLIGHT START ---------------------------------
function flight_start()

	mode_pilot_value = 0
	mode_copilot_value = 0
	adjust_pilot_value = 0
	adjust_copilot_value = 0

end








--------------------------------- REGULAR RUNTIME ---------------------------------
function after_physics()


	-- AHRS PILOT MODE SWITCH --
	-- SLOWLY ANIMATE:
	if CitX_ahrs_mode_pilot ~= mode_pilot_value then
		CitX_ahrs_mode_pilot = func_animate_slowly(mode_pilot_value, CitX_ahrs_mode_pilot, 40)
	end
	-- UPDATE SYSTEM:
	if mode_pilot_value == 0 then gyr_free_slaved_pilot = 1 else gyr_free_slaved_pilot = 0 end
	-- TEST MODE:
	if mode_pilot_value == -1 then dg_drift_ahars_deg_pilot = dg_drift_ahars_deg_pilot + 0.1 end
	---------------------


	-- AHRS COPILOT MODE SWITCH --
	-- SLOWLY ANIMATE:
	if CitX_ahrs_mode_copilot ~= mode_copilot_value then
		CitX_ahrs_mode_copilot = func_animate_slowly(mode_copilot_value, CitX_ahrs_mode_copilot, 40)
	end
	-- UPDATE SYSTEM:
	if mode_copilot_value == 0 then gyr_free_slaved_copilot = 1 else gyr_free_slaved_copilot = 0 end
	-- TEST MODE:
	if mode_copilot_value == -1 then dg_drift_ahars_deg_copilot = dg_drift_ahars_deg_copilot + 0.1 end
	---------------------


	-- AHRS PILOT DG HEADING ADJUST LH/RH SWITCH --
	-- SLOWLY ANIMATE:
	if CitX_ahrs_adjust_pilot ~= adjust_pilot_value then
		CitX_ahrs_adjust_pilot = func_animate_slowly(adjust_pilot_value, CitX_ahrs_adjust_pilot, 40)
	end
	-- UPDATE SYSTEM:
	if gyr_free_slaved_pilot == 0 then
			dg_drift_ahars_deg_pilot = dg_drift_ahars_deg_pilot + adjust_pilot_value * 0.1
	end
	---------------------


	-- AHRS COPILOT DG HEADING ADJUST LH/RH SWITCH --
	-- SLOWLY ANIMATE:
	if CitX_ahrs_adjust_copilot ~= adjust_copilot_value then
		CitX_ahrs_adjust_copilot = func_animate_slowly(adjust_copilot_value, CitX_ahrs_adjust_copilot, 40)
	end
	-- UPDATE SYSTEM:
	if gyr_free_slaved_copilot == 0 then
			dg_drift_ahars_deg_copilot = dg_drift_ahars_deg_copilot + adjust_copilot_value * 0.1
	end
	---------------------


end

