
-----------------------------------------------------------------
-- DEALING WITH L AND R ENGINE FIRE BUTTONS
-- (NO APU FIRE HERE, SEE APU SCRIPT)
-----------------------------------------------------------------




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




------------------------------- FUNCTIONS FOR WRITABLE DATAREFS -------------------------------

------------ L/R FIRE GUARDS FUNCTIONS
function cmd_LH_eng_fire_guard_func(phase,duration)
	if phase == 0 then
		LH_eng_fire_guard_actual = math.abs(LH_eng_fire_guard_actual - 1) --> just toggle from 0 to 1
	end
end
function cmd_RH_eng_fire_guard_func(phase,duration)
	if phase == 0 then
		RH_eng_fire_guard_actual = math.abs(RH_eng_fire_guard_actual - 1) --> just toggle from 0 to 1
	end
end


------------ RED L/R FIRE PUSH BUTTONS FUNCTIONS
function cmd_LH_eng_fire_push_func(phase,duration)
	if phase == 0 then
		LH_eng_fire_button_actual = math.abs(LH_eng_fire_button_actual - 1) --> just toggle from 0 to 1
		if engine_fires_L == 1 and LH_eng_fire_button_actual == 1 then
			if engine_really_on_fire_L == 6 then
				firewall_closed_L_cmd:once()
				LH_fire_ext_light = 1 * instr_brgh_cntr --> DIMMED BY CENTER RHEO
			end
		elseif LH_eng_fire_button_actual == 0 then
			fire_extinguisher_L = 0
			firewall_open_L_cmd:once()
		end
	end
end
function cmd_RH_eng_fire_push_func(phase,duration)
	if phase == 0 then
		RH_eng_fire_button_actual = math.abs(RH_eng_fire_button_actual - 1) --> just toggle from 0 to 1
		if engine_fires_R == 1 and RH_eng_fire_button_actual == 1 then
			if engine_really_on_fire_R == 6 then
				firewall_closed_R_cmd:once()
				RH_fire_ext_light = 1 * instr_brgh_cntr --> DIMMED BY CENTER RHEO
			end
		elseif RH_eng_fire_button_actual == 0 then
			fire_extinguisher_R = 0
			firewall_open_R_cmd:once()
		end
	end
end


------------ WHITE L/R EXTINGUISHER PUSH BUTTONS FUNCTIONS
function cmd_LH_fire_ext_push_func(phase,duration)
	if phase == 0 and engine_really_on_fire_L == 6 and LH_fire_ext_light > 0 then
		fire_extinguisher_L = 1
		LH_fire_ext_light = 0
	end
end
function cmd_RH_fire_ext_push_func(phase,duration)
	if phase == 0 and engine_really_on_fire_R == 6 and RH_fire_ext_light > 0 then
		fire_extinguisher_R = 1
		RH_fire_ext_light = 0
	end
end

------------ EMPTY FUNCTION FOR WRITABLE DATAREF
function do_nothing_func()
	--none
end




----------------------------------- LOCATE OR CREATE DATAREFS AND COMMANDS -----------------------------------

engine_fires_L = find_dataref("sim/cockpit2/annunciators/engine_fires[0]")
engine_fires_R = find_dataref("sim/cockpit2/annunciators/engine_fires[1]")
engine_really_on_fire_L = find_dataref("sim/operation/failures/rel_engfir0") --> 0off, 6=on fire
engine_really_on_fire_R = find_dataref("sim/operation/failures/rel_engfir1") --> 0off, 6=on fire
fire_extinguisher_L = find_dataref("sim/cockpit2/engine/actuators/fire_extinguisher_on[0]")
fire_extinguisher_R = find_dataref("sim/cockpit2/engine/actuators/fire_extinguisher_on[1]")
instr_brgh_cntr = find_dataref("sim/cockpit2/electrical/instrument_brightness_ratio_auto[3]") --> brightness ratio central panel

LH_eng_fire_guard = create_dataref("laminar/CitX/engine_fire/LH_eng_fire_guard","number") --> transp safeguard L
RH_eng_fire_guard = create_dataref("laminar/CitX/engine_fire/RH_eng_fire_guard","number") --> transp safeguard R
LH_eng_fire_button = create_dataref("laminar/CitX/engine_fire/LH_eng_fire_button","number") --> fire button L
RH_eng_fire_button = create_dataref("laminar/CitX/engine_fire/RH_eng_fire_button","number") --> fire button R
LH_fire_ext_light = create_dataref("laminar/CitX/engine_fire/LH_fire_ext_light","number") --> extinghuisher bottle button light L
RH_fire_ext_light = create_dataref("laminar/CitX/engine_fire/RH_fire_ext_light","number") --> extinghuisher bottle button light R


firewall_closed_L_cmd = find_command("sim/fuel/fuel_firewall_valve_lft_closed")
firewall_closed_R_cmd = find_command("sim/fuel/fuel_firewall_valve_rgt_closed")
firewall_open_L_cmd = find_command("sim/fuel/fuel_firewall_valve_lft_open")
firewall_open_R_cmd = find_command("sim/fuel/fuel_firewall_valve_rgt_open")
--fire_ext_1_on_cmd = find_command("sim/engines/fire_ext_1_on")
--fire_ext_2_on_cmd = find_command("sim/engines/fire_ext_2_on")
--fire_ext_1_off_cmd = find_command("sim/engines/fire_ext_1_off")
--fire_ext_2_off_cmd = find_command("sim/engines/fire_ext_2_off")

cmdLHengfireguard = create_command("laminar/CitX/engine_fire/cmd_LH_eng_fire_guard","Engine fire guard left",cmd_LH_eng_fire_guard_func)
cmdRHengfireguard = create_command("laminar/CitX/engine_fire/cmd_RH_eng_fire_guard","Engine fire guard right",cmd_RH_eng_fire_guard_func)
cmdLHengfirepush = create_command("laminar/CitX/engine_fire/cmd_LH_eng_fire_push","Engine fire button left",cmd_LH_eng_fire_push_func)
cmdRHengfirepush = create_command("laminar/CitX/engine_fire/cmd_RH_eng_fire_push","Engine fire button right",cmd_RH_eng_fire_push_func)
cmdLHfireextpushfunc = create_command("laminar/CitX/engine_fire/cmd_LH_fire_ext_push","Engine fire extinguisher left",cmd_LH_fire_ext_push_func)
cmdRHfireextpushfunc = create_command("laminar/CitX/engine_fire/cmd_RH_fire_ext_push","Engine fire extinguisher right",cmd_RH_fire_ext_push_func)




--------------------------------- RUNTIME ---------------------------------

-- DO THIS EACH FLIGHT START
function flight_start()
	LH_eng_fire_guard, LH_eng_fire_guard_actual = 0, 0
	RH_eng_fire_guard, RH_eng_fire_guard_actual = 0, 0
	LH_eng_fire_button, LH_eng_fire_button_actual = 0, 0
	RH_eng_fire_button, RH_eng_fire_button_actual = 0, 0
	LH_fire_ext_light = 0
	RH_fire_ext_light = 0
end


-- REGULAR RUNTIME
function after_physics()

	-- ANIMATE THE L/R GUARDS
	if LH_eng_fire_guard ~= LH_eng_fire_guard_actual then
		LH_eng_fire_guard = func_animate_slowly(LH_eng_fire_guard_actual, LH_eng_fire_guard, 20)
	end
	if RH_eng_fire_guard ~= RH_eng_fire_guard_actual then
		RH_eng_fire_guard = func_animate_slowly(RH_eng_fire_guard_actual, RH_eng_fire_guard, 20)
	end
	
	-- ANIMATE THE L/R FIRE BUTTONS
	if LH_eng_fire_button ~= LH_eng_fire_button_actual then
		LH_eng_fire_button = func_animate_slowly(LH_eng_fire_button_actual, LH_eng_fire_button, 20)
	end
	if RH_eng_fire_button ~= RH_eng_fire_button_actual then
		RH_eng_fire_button = func_animate_slowly(RH_eng_fire_button_actual, RH_eng_fire_button, 20)
	end

	-- WHITE FIRE EXT LIGHTS STAY OFF UNTIL IN REAL FIRE
	if engine_really_on_fire_L < 6 then LH_fire_ext_light = 0 end
	if engine_really_on_fire_R < 6 then RH_fire_ext_light = 0 end

end


-- DO THIS EACH ACF UNLOAD
function aircraft_unload()
	-- IN CASE THE USER FORGET TO CLOSE FIRE BUTTONS GUARD AFTER AN ENGINE FIRE,
	-- TO AVOID FUEL VALVES STAY CLOSED:
	firewall_open_L_cmd:once()
	firewall_open_R_cmd:once()
end


