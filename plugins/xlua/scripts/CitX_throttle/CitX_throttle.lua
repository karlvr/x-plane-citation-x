
---------------------------------------------------------------------------
--
-- DEALING WITH THROTTLE, MIXTURE RATIO AND REVERSE POWER
--
-- SEE ALSO ENGINE SCRIPT FOR MAX IDLE MIXTURE (IF 0.5 OR 1.0) DUE TO THE GND-IDLE-SWITCH
-- LO IDLE IS 0.5 MAX MIXTURE, HI IDLE IS 1.0 MAX MIXTURE
---------------------------------------------------------------------------



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


------------ LEFT THROTTLE FUNCTION
function func_ratio_L()
	if CitX_throttle_ratio_L >= 0 then
		-- THROTTLE MODE ABOVE IDLE
		throttle_jet_rev_ratio_L = CitX_throttle_ratio_L
	else
		-- MIXTURE MODE BELOW IDLE
		mixture_ratio_L = (1 - CitX_throttle_ratio_L * -1) * manipulator_scale
	end
end


------------ RIGHT THROTTLE FUNCTION
function func_ratio_R()
	if CitX_throttle_ratio_R >= 0 then
		-- THROTTLE MODE ABOVE IDLE
		throttle_jet_rev_ratio_R = CitX_throttle_ratio_R
	else
		-- MIXTURE MODE BELOW IDLE
		mixture_ratio_R = (1 - CitX_throttle_ratio_R * -1) * manipulator_scale
	end
end


------------ BOTH THROTTLE FUNCTION
function func_ratio_ALL()
	if CitX_throttle_ratio_ALL >= 0 then
		-- THROTTLE MODE ABOVE IDLE
		throttle_jet_rev_ratio_ALL = CitX_throttle_ratio_ALL
	else
		-- MIXTURE MODE BELOW IDLE
		mixture_ratio_ALL = (1 - CitX_throttle_ratio_ALL * -1) * manipulator_scale
	end
end


------------ LEFT REVERSE FUNCTION
function func_reverse_ratio_L()
	if throttle_jet_rev_ratio_L <= 0.075 then
		throttle_jet_rev_ratio_L = CitX_reverse_ratio_L
	else
		CitX_reverse_ratio_L = 0
	end
end


------------ RIGHT REVERSE FUNCTION
function func_reverse_ratio_R()
	if throttle_jet_rev_ratio_R <= 0.075 then
		throttle_jet_rev_ratio_R = CitX_reverse_ratio_R
	else
		CitX_reverse_ratio_R = 0
	end
end


------------ BOTH REVERSE FUNCTION
function func_reverse_ratio_ALL()
	if throttle_jet_rev_ratio_ALL <= 0.075 then
		throttle_jet_rev_ratio_ALL = CitX_reverse_ratio_ALL
	else
		CitX_reverse_ratio_ALL = 0
	end
end


------------ BOTH MIXTURE DETENT FUNCTION
function func_mixture_detent_ALL()
	CitX_mixture_detent_L = CitX_mixture_detent_ALL
	CitX_mixture_detent_R = CitX_mixture_detent_ALL
end


------------ EMERGENCY STOW LEFT FUNCTION
function cmd_stow_emer_L_toggle(phase,duration)
	if phase == 0 then
		stow_switch_L = math.abs(stow_switch_L - 1)
	end
end


------------ EMERGENCY STOW RIGHT FUNCTION
function cmd_stow_emer_R_toggle(phase,duration)
	if phase == 0 then
		stow_switch_R = math.abs(stow_switch_R - 1)
	end
end


------------ EMPTY FUNCTION FOR WRITABLE DATAREF
function func_do_nothing()

end

function cmd_engine_cutoff_left(phase, duration)
	if phase == 0 then
		CitX_throttle_ratio_L = -1
	elseif phase == 2 then
		CitX_throttle_ratio_L = 0
	end
end

function cmd_engine_cutoff_right(phase, duration)
	if phase == 0 then
		CitX_throttle_ratio_R = -1
	elseif phase == 2 then
		CitX_throttle_ratio_R = 0
	end
end



----------------------------------- LOCATE AND CREATE DATAREFS / COMMANDS -----------------------------------

bus_volts_0 = find_dataref("sim/cockpit2/electrical/bus_volts[0]")
bus_volts_1 = find_dataref("sim/cockpit2/electrical/bus_volts[1]")
bus_volts_2 = find_dataref("sim/cockpit2/electrical/bus_volts[2]")
instr_brgh_cntr = find_dataref("sim/cockpit2/electrical/instrument_brightness_ratio_auto[3]") --> brightness ratio central panel
throttle_jet_rev_ratio_L = find_dataref("sim/cockpit2/engine/actuators/throttle_jet_rev_ratio[0]") --> -1 is full reverse, + 1 is full throttle
throttle_jet_rev_ratio_R = find_dataref("sim/cockpit2/engine/actuators/throttle_jet_rev_ratio[1]")
throttle_jet_rev_ratio_ALL = find_dataref("sim/cockpit2/engine/actuators/throttle_jet_rev_ratio_all")
throttle_beta_rev_ratio_L = find_dataref("sim/cockpit2/engine/actuators/throttle_beta_rev_ratio[0]") --> -1 is just reverse armed, -2 is full reverse
throttle_beta_rev_ratio_R = find_dataref("sim/cockpit2/engine/actuators/throttle_beta_rev_ratio[1]")
throttle_beta_rev_ratio_ALL = find_dataref("sim/cockpit2/engine/actuators/throttle_beta_rev_ratio_all")
prop_mode_L = find_dataref("sim/cockpit2/engine/actuators/prop_mode[0]") --> 0 feat, 1 norm, 2 beta, 3 reverse
prop_mode_R = find_dataref("sim/cockpit2/engine/actuators/prop_mode[1]")
thrust_reverser_deploy_ratio_L = find_dataref("sim/flightmodel2/engines/thrust_reverser_deploy_ratio[0]") --> engine doors deploy ratio
thrust_reverser_deploy_ratio_R = find_dataref("sim/flightmodel2/engines/thrust_reverser_deploy_ratio[1]")
mixture_ratio_L = find_dataref("sim/cockpit2/engine/actuators/mixture_ratio[0]")
mixture_ratio_R = find_dataref("sim/cockpit2/engine/actuators/mixture_ratio[1]")
mixture_ratio_ALL = find_dataref("sim/cockpit2/engine/actuators/mixture_ratio_all")
--idle_speed_L = find_dataref("sim/cockpit2/engine/actuators/idle_speed_ratio[0]")
--idle_speed_R = find_dataref("sim/cockpit2/engine/actuators/idle_speed_ratio[1]")
CitX_gnd_idle = find_dataref("laminar/CitX/engine/gnd_idle") --> THE GND IDLE SWITCH: 0 norm, 1 high


CitX_throttle_ratio_L = create_dataref("laminar/CitX/throttle/ratio_L","number",func_ratio_L) --> driven by manipulator
CitX_throttle_ratio_R = create_dataref("laminar/CitX/throttle/ratio_R","number",func_ratio_R) --> driven by manipulator
CitX_throttle_ratio_ALL = create_dataref("laminar/CitX/throttle/ratio_ALL","number",func_ratio_ALL) --> driven by manipulator

CitX_mixture_detent_L = create_dataref("laminar/CitX/throttle/mixture_detent_L","number",func_do_nothing) --> driven by manipulator
CitX_mixture_detent_R = create_dataref("laminar/CitX/throttle/mixture_detent_R","number",func_do_nothing) --> driven by manipulator
CitX_mixture_detent_ALL = create_dataref("laminar/CitX/throttle/mixture_detent_ALL","number",func_mixture_detent_ALL) --> driven by manipulator

CitX_reverse_ratio_L = create_dataref("laminar/CitX/throttle/reverse_ratio_L","number",func_reverse_ratio_L) --> driven by manipulator
CitX_reverse_ratio_R = create_dataref("laminar/CitX/throttle/reverse_ratio_R","number",func_reverse_ratio_R) --> driven by manipulator
CitX_reverse_ratio_ALL = create_dataref("laminar/CitX/throttle/reverse_ratio_ALL","number",func_reverse_ratio_ALL) --> driven by manipulator

CitX_annunc_arm_L = create_dataref("laminar/CitX/throttle/annunc_arm_L","number")
CitX_annunc_arm_R = create_dataref("laminar/CitX/throttle/annunc_arm_R","number")
CitX_annunc_unlock_L = create_dataref("laminar/CitX/throttle/annunc_unlock_L","number")
CitX_annunc_unlock_R = create_dataref("laminar/CitX/throttle/annunc_unlock_R","number")
CitX_annunc_deploy_L = create_dataref("laminar/CitX/throttle/annunc_deploy_L","number")
CitX_annunc_deploy_R = create_dataref("laminar/CitX/throttle/annunc_deploy_R","number")

CitX_stow_emer_L = create_dataref("laminar/CitX/throttle/stow_emer_L","number") --> emergency switch
CitX_stow_emer_R = create_dataref("laminar/CitX/throttle/stow_emer_R","number")
stow_switch_L = create_dataref("laminar/CitX/throttle/stow_emer_L_term","number") --> emergency switch
stow_switch_R = create_dataref("laminar/CitX/throttle/stow_emer_R_term","number")


cmdstowemerLtog = create_command("laminar/CitX/throttle/stow_emer_L_toggle","Emergency stow reverse left toggle",cmd_stow_emer_L_toggle)
cmdstowemerRtog = create_command("laminar/CitX/throttle/stow_emer_R_toggle","Emergency stow reverse right toggle",cmd_stow_emer_R_toggle)

create_command("laminar/CitX/engine/cmd_mixture_left_min", "Engine cut-off left", cmd_engine_cutoff_left)
create_command("laminar/CitX/engine/cmd_mixture_right_min", "Engine cut-off right", cmd_engine_cutoff_right)

--------------------------------- RUNTIME ---------------------------------

-- DO THIS EACH FLIGHT START
function flight_start()
	CitX_throttle_ratio_L = throttle_jet_rev_ratio_L
	CitX_throttle_ratio_R = throttle_jet_rev_ratio_R
	CitX_throttle_ratio_ALL = throttle_jet_rev_ratio_ALL
	CitX_reverse_ratio_L = 0
	CitX_reverse_ratio_R = 0
	CitX_reverse_ratio_ALL = 0
	stow_switch_L = 0
	stow_switch_R = 0
end


-- REGULAR RUNTIME
function after_physics()

	-- UPDATE ANNUNCIATORS (DIMMED BY THE CENTRAL PANEL RHEO)
	if bus_volts_1+bus_volts_2 > 0 then power_on = 1 else power_on = 0 end
	if throttle_beta_rev_ratio_L < 0 or thrust_reverser_deploy_ratio_L > 0.01 then CitX_annunc_arm_L = 1 * instr_brgh_cntr * power_on else CitX_annunc_arm_L = 0 end
	if throttle_beta_rev_ratio_R < 0 or thrust_reverser_deploy_ratio_R > 0.01 then CitX_annunc_arm_R = 1 * instr_brgh_cntr * power_on else CitX_annunc_arm_R = 0 end
	if thrust_reverser_deploy_ratio_L > 0.15 then CitX_annunc_unlock_L = 1 * instr_brgh_cntr * power_on else CitX_annunc_unlock_L = 0 end
	if thrust_reverser_deploy_ratio_R > 0.15 then CitX_annunc_unlock_R = 1 * instr_brgh_cntr * power_on else CitX_annunc_unlock_R = 0 end
	if thrust_reverser_deploy_ratio_L > 0.99 then CitX_annunc_deploy_L = 1 * instr_brgh_cntr * power_on else CitX_annunc_deploy_L = 0 end
	if thrust_reverser_deploy_ratio_R > 0.99 then CitX_annunc_deploy_R = 1 * instr_brgh_cntr * power_on else CitX_annunc_deploy_R = 0 end
	-------------------------


	-- EMERG STOW SWITCHES: KEEP DOORS CLOSED BUT ARMED
	if stow_switch_L == 1 then
		CitX_annunc_arm_L = 1 * instr_brgh_cntr * power_on
		if throttle_beta_rev_ratio_L < 0 then throttle_beta_rev_ratio_L = 0 end
	end
	if stow_switch_R == 1 then
		CitX_annunc_arm_R = 1 * instr_brgh_cntr * power_on
		if throttle_beta_rev_ratio_R < 0 then throttle_beta_rev_ratio_R = 0 end
	end
	-- SLOWLY ANIMATE EMERG STOW SWITCHES
	if stow_switch_L ~= CitX_stow_emer_L then CitX_stow_emer_L = func_animate_slowly(stow_switch_L, CitX_stow_emer_L, 40) end
	if stow_switch_R ~= CitX_stow_emer_R then CitX_stow_emer_R = func_animate_slowly(stow_switch_R, CitX_stow_emer_R, 40) end
	-------------------------


	-- EVALUATE HIGH OR LOW MIXTURE IDLE FROM THE GND-IDLE-SWITCH
	if CitX_gnd_idle == 1 then
		idle_max_value = 1
		mixture_scale = 1
		manipulator_scale = 1
	else
		idle_max_value = 0.5
		mixture_scale = 2
		manipulator_scale = 0.5
	end


	-- AVOID MIXTURE LEAN IF THE THROTTLE IS MORE THAN IDLE
	if throttle_jet_rev_ratio_L > 0 then mixture_ratio_L = math.max(0.5, mixture_ratio_L) end
	if throttle_jet_rev_ratio_R > 0 then mixture_ratio_R = math.max(0.5, mixture_ratio_R) end
	--
	-- AVOID REVERSE IF THE THROTTLE MANIPULATOR IS MORE THAN IDLE OR DURING MIXTURE LEAN
	if CitX_throttle_ratio_L > 0.05 or mixture_ratio_L < idle_max_value then prop_mode_L = 1 end
	if CitX_throttle_ratio_R > 0.05 or mixture_ratio_R < idle_max_value then prop_mode_R = 1 end
	--
	-- AVOID THROTTLE IF REVERSE MANIPULATOR IS MORE THAN IDLE
	--------> (NO MORE TO AVOID CONFLICT WITH THE NEXT XPLANE REVERSE SYNC PART: SO BY MOVING THROTTLE REVERSE DISENGAGE)
	-- if CitX_reverse_ratio_L < -0.05 then prop_mode_L = 3 end
	-- if CitX_reverse_ratio_R < -0.05 then prop_mode_R = 3 end
	-------------------------


	-- KEEP THROTTLE MIXTURE SYNC WITH THE XPLANE ONES:
	if mixture_ratio_L < idle_max_value then CitX_throttle_ratio_L = ((1 - mixture_ratio_L * mixture_scale) * -1) end
	if mixture_ratio_R < idle_max_value then CitX_throttle_ratio_R = ((1 - mixture_ratio_R * mixture_scale) * -1) end
	if mixture_ratio_ALL < idle_max_value then CitX_throttle_ratio_ALL = ((1 - mixture_ratio_ALL * mixture_scale) * -1) end
	--
	-- KEEP THROTTLE HANDLES SYNC WITH THE XPLANE ONES
	if throttle_jet_rev_ratio_L > 0 then CitX_throttle_ratio_L = throttle_jet_rev_ratio_L CitX_reverse_ratio_L = 0 end
	if throttle_jet_rev_ratio_R > 0 then CitX_throttle_ratio_R = throttle_jet_rev_ratio_R CitX_reverse_ratio_R = 0 end
	if throttle_jet_rev_ratio_ALL > 0 then CitX_throttle_ratio_ALL = throttle_jet_rev_ratio_ALL CitX_reverse_ratio_ALL = 0 end
	--
	-- KEEP REVERSE HANDLES SYNC WITH THE XPLANE ONES
	if throttle_jet_rev_ratio_L <= 0 then CitX_reverse_ratio_L = throttle_jet_rev_ratio_L end
	if throttle_jet_rev_ratio_R <= 0 then CitX_reverse_ratio_R = throttle_jet_rev_ratio_R end
	if throttle_jet_rev_ratio_ALL <= 0 then CitX_reverse_ratio_ALL = throttle_jet_rev_ratio_ALL end
	-------------------------


end


