
---------------------------------------------------------------------------------------
--
-- THIS SCRIPT DRIVE THE ANGLE OF ATTACK SYSTEM (INDICATORS, LIGHTS AND STICK SHAKER)
--
---------------------------------------------------------------------------------------



----------------------------------- LOCATE DATAREFS -----------------------------------

bus_volts0 = find_dataref("sim/cockpit2/electrical/bus_volts[0]")
bus_volts1 = find_dataref("sim/cockpit2/electrical/bus_volts[1]")
bus_volts2 = find_dataref("sim/cockpit2/electrical/bus_volts[2]")
AoA_angle_degrees = find_dataref("sim/flightmodel2/misc/AoA_angle_degrees") -- AoA angle degrees (OLD and flickering on ground)
AoA_pilot = find_dataref("sim/cockpit2/gauges/indicators/AoA_pilot") -- AoA angle degrees NEW v12
AoA_copilot = find_dataref("sim/cockpit2/gauges/indicators/AoA_copilot") -- AoA angle degrees NEW v12
AoA_failure = find_dataref("sim/operation/failures/rel_AOA")
stall_warning = find_dataref("sim/cockpit2/annunciators/stall_warning")
--yoke_pitch_ratio = find_dataref("sim/cockpit2/controls/yoke_pitch_ratio")
--yoke_pitch_ratio_copilot = find_dataref("sim/cockpit2/controls/yoke_pitch_ratio_copilot")
--total_pitch_ratio = find_dataref("sim/cockpit2/controls/total_pitch_ratio")
--total_pitch_ratio_copilot = find_dataref("sim/cockpit2/controls/total_pitch_ratio_copilot")
CitX_controls_total_pitch_yoke_pilot = find_dataref("laminar/CitX/controls/total_pitch_yoke_pilot") -- custom yoke pitch from controls script
CitX_controls_total_pitch_yoke_copilot = find_dataref("laminar/CitX/controls/total_pitch_yoke_copilot") -- custom yoke pitch from controls script




----------------------------------- CREATE DATAREFS -----------------------------------

CitX_AoA_angle_ratio = create_dataref("laminar/CitX/AoA/angle_ratio","number") -- AoA ratio 0 to 1
CitX_AoA_system_working = create_dataref("laminar/CitX/AoA/system_working","number")

CitX_AoA_too_slow = create_dataref("laminar/CitX/AoA/too_slow","number")
CitX_AoA_on_track = create_dataref("laminar/CitX/AoA/on_track","number")
CitX_AoA_too_fast = create_dataref("laminar/CitX/AoA/too_fast","number")




----------------------------------- SLOWLY ANIMATE FUNCTION
function func_animate_slowly(reference_value, animated_VALUE, anim_speed)
	animated_VALUE = animated_VALUE + ((reference_value - animated_VALUE) * (anim_speed * SIM_PERIOD))
	return animated_VALUE
end


----------------------------------- YOKE SHAKER FUNCTION
function func_inv_shaker()
	shaker = shaker - shaker * 2 --> INVERT VALUE
end






--------------------------------- DATAREFS INITIALIZATON ---------------------------------

CitX_AoA_angle_ratio = 0
CitX_AoA_system_working = 0
CitX_AoA_too_slow = 0
CitX_AoA_on_track = 0
CitX_AoA_too_fast = 0
shaker = 0.02





--------------------------------- REGULAR RUNTIME ---------------------------------
function after_physics()

	-- EVALUATES IF THE SYSTEM IS WORKING
	pwr = bus_volts1 -- main bus
	if pwr > 0 and AoA_failure == 0 then

		CitX_AoA_system_working = 1

		-- COMPUTES AND NORMALIZES THE AOA RATIO BASING ON THE XPLANE AOA DEGREES
		-- AoA_deg = AoA_angle_degrees / 10 --> NO MORE (OLD DATAREF)
		AoA_deg = AoA_pilot / 10 --> *** REAL POH SAYS: ONLY THE LEFT COMPUTER INFORMATION IS DISPLAYED ON THE AOA INDICATOR AND INDEXER ***
		-- SLOWLY ANIMATE AoA:
		if CitX_AoA_angle_ratio ~= AoA_deg then
			CitX_AoA_angle_ratio = func_animate_slowly(AoA_deg, CitX_AoA_angle_ratio, 1.5)
		end
		-- NORMALIZE:
		if CitX_AoA_angle_ratio < 0 then CitX_AoA_angle_ratio = 0 end
		if CitX_AoA_angle_ratio > 1 then CitX_AoA_angle_ratio = 1 end


		-- EVALUATES INDEXER LIGHT RED
		if CitX_AoA_angle_ratio > 0.65 and CitX_AoA_angle_ratio <= 1 then
			CitX_AoA_too_slow = 1
		else
			CitX_AoA_too_slow = 0
		end

		-- EVALUATES INDEXER LIGHT GREEN
		if CitX_AoA_angle_ratio > 0.5 and CitX_AoA_angle_ratio < 0.7 then
			CitX_AoA_on_track = 1
		else
			CitX_AoA_on_track = 0
		end

		-- EVALUATES INDEXER LIGHT YELLOW
		if CitX_AoA_angle_ratio >= 0 and CitX_AoA_angle_ratio < 0.55 then
			CitX_AoA_too_fast = 1
		else
			CitX_AoA_too_fast = 0
		end

		-- STALL: STICK SHAKER!
		if stall_warning == 1 then
			CitX_controls_total_pitch_yoke_pilot = CitX_controls_total_pitch_yoke_pilot + shaker
			CitX_controls_total_pitch_yoke_copilot = CitX_controls_total_pitch_yoke_copilot + shaker
			if is_timer_scheduled(func_inv_shaker) == false then
				run_at_interval(func_inv_shaker, 0.05) --> DURATION IN SECONDS
			end
		end

	-- IF THE SYSTEM IS NOT WORKING
	else

		CitX_AoA_system_working = 0
		CitX_AoA_angle_ratio = 0
		CitX_AoA_too_slow = 0
		CitX_AoA_on_track = 0
		CitX_AoA_too_fast = 0

	end


end
