
------------------------------------------------------------------------------------------
-- DEALING WITH THE FLAPS/SLATS HANDLE, RUDDER TRIM KNOB AND PILOT-COPILOT PITCH/ROLL RECONNECTION
--
-- ACCORDING TO PLANEMAKER SETTINGS, THERE ARE 5 DETENTS:
-- UP(NONE); FULL SLATS BUT NOT JET FLAPS; THEN 5°, 15° AND 35°(FULL) FLAPS
-- SO THE DETENTS RATIOS ARE: 0 --> 0.25 --> 0.5 --> 0.75 --> 1
------------------------------------------------------------------------------------------




------------------------------- FUNCTIONS -------------------------------

----------------------------------- SLOWLY ANIMATE FUNCTION
function func_animate_slowly(reference_value, animated_VALUE, anim_speed)
	SPD_PERIOD = anim_speed * SIM_PERIOD
	if SPD_PERIOD > 1 then SPD_PERIOD = 1 end
	animated_VALUE = animated_VALUE + ((reference_value - animated_VALUE) * SPD_PERIOD)
	delta = math.abs(animated_VALUE - reference_value)
	if delta < 0.05 then animated_VALUE = reference_value end
	return animated_VALUE
end


----------------------------------- RUDDER TRIM KNOB FUNCTIONS
function trim_L_before_func(phase,duration)
	if phase <= 1 then
		rudder_trim_knob = -1
	end
end
function trim_L_after_func(phase,duration)
	--if phase == 2 then
		--rudder_trim_knob = 0
	--end
end
function trim_R_before_func(phase,duration)
	if phase <= 1 then
		rudder_trim_knob = 1
	end
end
function trim_R_after_func(phase,duration)
	--if phase == 2 then
		--rudder_trim_knob = 0
	--end
end


----------------------------------- AILERONS LATCH AND CONTROLS SPLIT FUNCTIONS
function cmd_aileron_latch_func(phase,duration)
	if phase == 2 then
		controls_locked = math.abs(controls_locked - 6) --> toggle from 0 to 6
	end
end
function cmd_controls_split_func(phase,duration)
	if phase == 2 then
		if split_roll == 0 and split_pitch == 0 then
			--split_roll = 1 split_pitch = 1
			cmdsplitall:once()
		elseif split_roll == 1 and split_pitch == 1 then
			--split_roll = 0 split_pitch = 1
			cmdreconnectroll:once()
		elseif split_roll == 0 and split_pitch == 1 then
			--split_roll = 1 split_pitch = 0
			cmdreconnectpitch:once()
			cmdsplitroll:once()
		elseif split_roll == 1 and split_pitch == 0 then
			--split_roll = 0 split_pitch = 0
			cmdreconnectall:once()
		end
	end
end


------------------------------- FUNCTIONS FOR WRITABLE DATAREFS

function flaps_slats_handle_func()
	-- JUMP TO DETENTS
	if CitX_flaps_slats_handle_ratio >= 0 and CitX_flaps_slats_handle_ratio < 0.12 then flap_ratio = 0 end
	if CitX_flaps_slats_handle_ratio > 0.12 and CitX_flaps_slats_handle_ratio < 0.37 then flap_ratio = 0.25 end
	if CitX_flaps_slats_handle_ratio > 0.37 and CitX_flaps_slats_handle_ratio < 0.62 then flap_ratio = 0.50 end
	if CitX_flaps_slats_handle_ratio > 0.62 and CitX_flaps_slats_handle_ratio < 0.87 then flap_ratio = 0.75 end
	if CitX_flaps_slats_handle_ratio > 0.87 and CitX_flaps_slats_handle_ratio <= 1.00 then flap_ratio = 1.00 end
end




----------------------------------- LOCATE OR CREATE DATAREFS AND COMMANDS -----------------------------------

flap_ratio = find_dataref("sim/cockpit2/controls/flap_handle_request_ratio")
rel_flap_act = find_dataref("sim/operation/failures/rel_flap_act") --> 6=FLAP FAILURE
split_roll = find_dataref("sim/cockpit2/controls/torque_tube_split_roll") --> split/reconnect pilot/copilot yoke roll
split_pitch = find_dataref("sim/cockpit2/controls/torque_tube_split_pitch") --> split/reconnect pilot/copilot yoke pitch
controls_locked = find_dataref("sim/operation/failures/rel_conlock") --> 0=norm, 6=controls locked
total_pitch_ratio = find_dataref("sim/cockpit2/controls/total_pitch_ratio")
total_pitch_ratio_copilot = find_dataref("sim/cockpit2/controls/total_pitch_ratio_copilot")

CitX_flaps_slats_handle_ratio = create_dataref("laminar/CitX/flaps_slats/handle_ratio","number",flaps_slats_handle_func) --> driven by manipulator
CitX_flap_reset_annunc = create_dataref("laminar/CitX/flaps_slats/flap_reset_annunc","number")
CitX_rudder_trim_knob = create_dataref("laminar/CitX/trim/rudder_trim_knob","number") --> -1 left, 1 right
CitX_ailerons_latch_pull = create_dataref("laminar/CitX/controls/ailerons_latch_pull","number") --> travel of the handle 0=norm, 1=latch
CitX_controls_split_pull = create_dataref("laminar/CitX/controls/split_pull","number") --> travel of the handle 0=norm, 1=split both roll/pitch
CitX_controls_split_roll = create_dataref("laminar/CitX/controls/split_roll","number") --> rotation of the handle -1=pitch reconnect, 0=norm, 1=roll reconnect
CitX_controls_total_pitch_yoke_pilot = create_dataref("laminar/CitX/controls/total_pitch_yoke_pilot","number") --> created for the stall shaker (see AoA script)
CitX_controls_total_pitch_yoke_copilot = create_dataref("laminar/CitX/controls/total_pitch_yoke_copilot","number") --> created for the stall shaker (see AoA script)

cmdsplitroll = find_command("sim/flight_controls/split_roll")
cmdsplitpitch = find_command("sim/flight_controls/split_pitch")
cmdsplitall = find_command("sim/flight_controls/split_all")
cmdreconnectroll = find_command("sim/flight_controls/reconnect_roll")
cmdreconnectpitch = find_command("sim/flight_controls/reconnect_pitch")
cmdreconnectall = find_command("sim/flight_controls/reconnect_all")
cmdruddertrimL = wrap_command("sim/flight_controls/rudder_trim_left",trim_L_before_func,trim_L_after_func)
cmdruddertrimR = wrap_command("sim/flight_controls/rudder_trim_right",trim_R_before_func,trim_R_after_func)
cmdaileronlatch = create_command("laminar/CitX/controls/cmd_ailerons_latch","Ailerons latch toggle",cmd_aileron_latch_func)
cmdcontrolssplit = create_command("laminar/CitX/controls/cmd_controls_split","Cycle roll/pitch split and reconnect",cmd_controls_split_func)




--------------------------------- RUNTIME ---------------------------------

-- DO THIS EACH FLIGHT START
function flight_start()
	landing_gear_handle = gear_handle_down
	rudder_trim_knob = 0
	delay = 0
	--split_pitch, split_roll = 0, 0
end


-- REGULAR RUNTIME
function after_physics()
	
	-- KEEP CUSTOM PITCH YOKES SYNC WITH THE XPLANE ONES (THEY ARE CUSTOM TO BE ABLE TO SHAKE IN THE AOA SCRIPT)
	CitX_controls_total_pitch_yoke_pilot = total_pitch_ratio
	CitX_controls_total_pitch_yoke_copilot = total_pitch_ratio_copilot


	-- KEEP FLAPS/SLATS HANDLE SMOOTHLY SYNC WITH THE XPLANE DATAREF
	if CitX_flaps_slats_handle_ratio ~= flap_ratio then
		CitX_flaps_slats_handle_ratio = func_animate_slowly(flap_ratio, CitX_flaps_slats_handle_ratio, 15)
	end

	-- THE FLAP RESET ANNUNC/BUTTON JUST STAY OFF UNTIL FLAP FAILURE
	if rel_flap_act == 6 then CitX_flap_reset_annunc = 1 else CitX_flap_reset_annunc = 0 end


	-- KEEP RUDDER TRIM KNOB SMOOTHLY SYNC WITH THE XPLANE L/R COMMANDS
	if CitX_rudder_trim_knob ~= rudder_trim_knob then
		CitX_rudder_trim_knob = func_animate_slowly(rudder_trim_knob, CitX_rudder_trim_knob, 10) -- move L -1 or R +1
	else
		rudder_trim_knob = 0 -- spring back to 0 center
	end


	-- KEEP CONTROLS LOCKED (AILERONS LATCH) SMOOTHLY SYNC WITH THE XPLANE DATAREF
	if CitX_ailerons_latch_pull ~= controls_locked then
		CitX_ailerons_latch_pull = func_animate_slowly(controls_locked/6, CitX_ailerons_latch_pull, 10)
	end


	-- KEEP SPLIT CONTROLS SMOOTHLY SYNC WITH THE XPLANE DATAREFS
	split_rollorpitch = math.ceil((split_roll+split_pitch)/2)
	split_handle_rot = (split_roll*-1)+split_pitch
	if CitX_controls_split_pull ~= split_rollorpitch or CitX_controls_split_roll ~= split_handle_rot then
		CitX_controls_split_pull = func_animate_slowly(split_rollorpitch, CitX_controls_split_pull, 10)
		CitX_controls_split_roll = func_animate_slowly(split_handle_rot, CitX_controls_split_roll, 10)
	end

end


