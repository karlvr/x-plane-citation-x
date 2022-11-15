
--------------------------------------------------------------------------------------
-- THIS SCRIPT DEAL WITH THE APU PANEL AND SYSTEMS
--
-- APU FEED THE MAIN BUS[1] (see electrical script)
-- ONCE APU IS RUNNING AND GENERATOR IS ON, THE ELECTRICAL SCRIPT OPEN THE CROSS-TIE
-- APU FEED ALSO BLEED AIR
-- (APU FIRE FAILURE IS HERE AND THE EXTINGUISHER JUST RESET THE FAILURE)
--------------------------------------------------------------------------------------




----------------------------------- LOCATE DATAREFS OR COMMANDS -----------------------------------

startup_running = find_dataref("sim/operation/prefs/startup_running") --> 0=no, 1=yes
--bus_volts_0 = find_dataref("sim/cockpit2/electrical/bus_volts[0]")
bus_volts_1 = find_dataref("sim/cockpit2/electrical/bus_volts[1]")
bus_volts_2 = find_dataref("sim/cockpit2/electrical/bus_volts[2]")
batt_2_ind_volts = find_dataref("sim/cockpit2/electrical/battery_voltage_indicated_volts[2]")
cross_tie = find_dataref("sim/cockpit2/electrical/cross_tie")
instr_brgh_right = find_dataref("sim/cockpit2/electrical/instrument_brightness_ratio_auto[2]") --> brightness ratio right side
--bleed_air_mode = find_dataref("sim/cockpit2/pressurization/actuators/bleed_air_mode") --> DEPRECATED!!! 0=off,1=left,2=both,3=right,4=APU,5=auto
bleed_air_valve = find_dataref("sim/cockpit2/bleedair/actuators/apu_bleed") --> BLEED AIR VALVE 0=close, 1=open
APU_generator_on = find_dataref("sim/cockpit2/electrical/APU_generator_on")
APU_generator_amps = find_dataref("sim/cockpit2/electrical/APU_generator_amps")
APU_starter_switch = find_dataref("sim/cockpit2/electrical/APU_starter_switch") --> 0 is off, 1 is on, 2 is start-er-up
APU_running = find_dataref("sim/cockpit2/electrical/APU_running")
APU_N1_percent = find_dataref("sim/cockpit2/electrical/APU_N1_percent")
--APU_EGT_c = find_dataref("sim/cockpit2/electrical/APU_EGT_c")
fail_APU = find_dataref("sim/operation/failures/rel_apu") --> 6 = APU failure to start or run
fail_APU_press = find_dataref("sim/operation/failures/rel_APU_press") --> 6 = APU is not providing bleed air for engine start or pressurization
fail_APU_fire = find_dataref("sim/operation/failures/rel_apu_fire") --> 6 = APU catastrophic failure with fire
cmd_APU_fire_shutoff = find_command("sim/electrical/APU_fire_shutoff")



------------------------------ DATAREFS AND COMMANDS FUNCTIONS -----------------------------

----------------------------------- APU MASTER SWITCH - ON/OFF
function cmd_master_switch_toggle(phase, duration)
	if phase == 0 then
		master_switch_status = math.abs(master_switch_status - 1)
	end
end

----------------------------------- APU BLEED AIR SWITCH - MAX/ON/OFF
function cmd_bleed_switch_up(phase, duration)
	if phase == 0 and bleed_air_switch_status < 1 then
		bleed_air_switch_status = bleed_air_switch_status + 0.5
	end
end
function cmd_bleed_switch_dwn(phase, duration)
	if phase == 0 and bleed_air_switch_status > 0 then
		bleed_air_switch_status = bleed_air_switch_status - 0.5
	end
end

----------------------------------- APU GENERATOR SWITCH - ON/OFF/RESET
function cmd_gen_switch_up(phase, duration)
	if phase == 0 then gen_switch_status = math.min(1, gen_switch_status + 1) end
end
function cmd_gen_switch_dwn(phase, duration)
	if phase == 0 then gen_switch_status = math.max(-1, gen_switch_status - 1) end
	if phase == 2 and gen_switch_status == -1 then gen_switch_status = 0 end --> the spring back to 0
end

----------------------------------- APU STARTER SWITCH - START/NORM/STOP
function cmd_starter_switch_up(phase, duration)
	if phase == 0 then starter_switch_status = 2 end
	if phase == 1 and duration > 1.0 then APU_starter_switch = starter_switch_status * APU_panel_powered end
	if phase == 2 then APU_starter_switch, starter_switch_status = APU_panel_powered, 1 end --> the spring who send the switch back to normal
end
function cmd_starter_switch_dwn(phase, duration)
	if phase == 1 and duration > 0.1 then APU_starter_switch, starter_switch_status = 0, 0 end
	if phase == 2 then APU_starter_switch, starter_switch_status = 0, 1 end --> the spring who send the switch back to normal
end

----------------------------------- PUSH BUTTON TEST
function cmd_test_button(phase, duration)
	if phase == 1 then test_button = 1 else test_button = 0 end
end

----------------------------------- APU FIRE SAFE GUARD
function cmd_fire_guard(phase, duration)
	-- JUST TOGGLE 0/1 THE SAFE GUARD
	if phase == 0 then fire_guard_status = math.abs(fire_guard_status - 1) end
end

----------------------------------- APU FIRE EXTINGUISHER (RESET FAILURE) BUTTON
function cmd_reset_fire(phase, duration)
	-- if phase == 0 and fail_APU_fire == 6 then fail_APU_fire = 0 end
	if phase == 0 and fail_APU_fire == 6 then cmd_APU_fire_shutoff:once() end
end

----------------------------------- SLOWLY ANIMATE FUNCTION
function func_animate_slowly(reference_value, animated_VALUE, anim_speed)
	SPD_PERIOD = anim_speed * SIM_PERIOD
	if SPD_PERIOD > 1 then SPD_PERIOD = 1 end
	animated_VALUE = animated_VALUE + ((reference_value - animated_VALUE) * SPD_PERIOD)
	delta = math.abs(animated_VALUE - reference_value)
	if delta < 0.05 then animated_VALUE = reference_value end
	return animated_VALUE
end

----------------------------------- TIMER FUNCTION
function func_timer()
	timer = 0
end

----------------------------------- EMPTY FUNCTION FOR WRITABLE DATAREF
function func_do_nothing()
	--nothing
end






----------------------------------- CREATE DATAREFS AND COMMANDS -----------------------------------

CitX_APU_fire_guard = create_dataref("laminar/CitX/APU/fire_guard","number")
CitX_APU_annunc_fire = create_dataref("laminar/CitX/APU/annunc_fire","number") --> FIRE FAILURE IS HERE BUT NOT YET THE EXTINGUISHER
CitX_APU_annunc_relay_engaged = create_dataref("laminar/CitX/APU/annunc_relay_engaged","number")
CitX_APU_annunc_fail = create_dataref("laminar/CitX/APU/annunc_fail","number")
CitX_APU_annunc_ready_load = create_dataref("laminar/CitX/APU/annunc_ready_load","number")
CitX_APU_annunc_bleed_val_open = create_dataref("laminar/CitX/APU/annunc_bleed_val_open","number")
CitX_APU_bleed_air_switch = create_dataref("laminar/CitX/APU/bleed_air_switch","number") --> 0=off, 0.5=on, 1=max
bleed_air_switch_status = create_dataref("laminar/CitX/APU/bleed_air_switch_term","number")
CitX_APU_gen_switch = create_dataref("laminar/CitX/APU/gen_switch","number")
gen_switch_status = create_dataref("laminar/CitX/APU/gen_switch_term","number")
CitX_APU_master_switch = create_dataref("laminar/CitX/APU/master_switch","number")
master_switch_status = create_dataref("laminar/CitX/APU/master_switch_term","number")
CitX_APU_starter_switch = create_dataref("laminar/CitX/APU/starter_switch","number") --> 0 is off, 1 is on, 2 is start-er-up
CitX_APU_test_button = create_dataref("laminar/CitX/APU/test_button","number")
CitX_APU_DC_volts = create_dataref("laminar/CitX/APU/DC_volts","number")

cmdbleedswitchup = create_command("laminar/CitX/APU/bleed_switch_up","APU bleed air switch up",cmd_bleed_switch_up)
cmdbleedswitchdwn = create_command("laminar/CitX/APU/bleed_switch_dwn","APU bleed air switch dwn",cmd_bleed_switch_dwn)
cmdgenswitchup = create_command("laminar/CitX/APU/gen_switch_up","APU generator switch up",cmd_gen_switch_up)
cmdgenswitchdwn = create_command("laminar/CitX/APU/gen_switch_dwn","APU generator switch dwn",cmd_gen_switch_dwn)
cmdmasterswitchtog = create_command("laminar/CitX/APU/master_switch_toggle","APU master switch toggle",cmd_master_switch_toggle)
cmdstarterswitchup = create_command("laminar/CitX/APU/starter_switch_up","APU starter switch up",cmd_starter_switch_up)
cmdstarterswitchdwn = create_command("laminar/CitX/APU/starter_switch_dwn","APU starter switch dwn",cmd_starter_switch_dwn)
cmdtestbutton = create_command("laminar/CitX/APU/test_button","APU test button",cmd_test_button)
cmdfireguard = create_command("laminar/CitX/APU/fire_guard","APU fire guard",cmd_fire_guard)
cmdresetfire = create_command("laminar/CitX/APU/reset_fire","APU fire extinguisher",cmd_reset_fire)





--------------------------------- DO THIS EACH FLIGHT START ---------------------------------
function flight_start()
	
	bleed_air_valve = startup_running
	bleed_air_switch_status = bleed_air_valve
	gen_switch_status = APU_generator_on
	master_switch_status = APU_generator_on
	starter_switch_status, CitX_APU_starter_switch, APU_starter_switch = 1,1,0
	timer = 0
	CitX_APU_fire_guard, fire_guard_status = 0, 0

end




--------------------------------- REGULAR RUNTIME ---------------------------------
function after_physics()

	if bus_volts_1 + bus_volts_2 > 1 then pwr_on = 1 else pwr_on = 0 end --> SOME PWR FROM BUSES

	------ MASTER SWITCH SYSTEM ------
	-- SLOWLY ANIMATE THE SWITCH
	if master_switch_status ~= CitX_APU_master_switch then
		CitX_APU_master_switch = func_animate_slowly(master_switch_status, CitX_APU_master_switch, 40)
	end
	-- SET THE SYSTEM
	if master_switch_status * pwr_on == 1 then
		APU_panel_powered = 1
	else
		APU_panel_powered = 0
	end
	-----------------------------


	------ BLEED AIR SWITCH SYSTEM ------
	-- SLOWLY ANIMATE THE SWITCH
	if bleed_air_switch_status ~= CitX_APU_bleed_air_switch then
		CitX_APU_bleed_air_switch = func_animate_slowly(bleed_air_switch_status, CitX_APU_bleed_air_switch, 40)
	end
	-- SET THE SYSTEM
	-- NO MORE HERE! SEE THE BLEED AIR LOGIC IN BLEED AIR SCRIPT!
	--if bleed_air_switch_status == 0 then bleed_air_mode = 0 end --> bleed air off
	--if bleed_air_switch_status > 0 then bleed_air_mode = 4 end --> bleed air from apu
	-----------------------------


	------ GENERATOR SWITCH SYSTEM ------
	-- SLOWLY ANIMATE THE SWITCH
	if gen_switch_status ~= CitX_APU_gen_switch then
		CitX_APU_gen_switch = func_animate_slowly(gen_switch_status, CitX_APU_gen_switch, 40)
	end
	-- SET THE SYSTEM
	if gen_switch_status == -1 then APU_generator_on = 0 end --> gen reset
	if gen_switch_status == 0 then APU_generator_on = 0 end --> gen off
	if gen_switch_status == 1 then APU_generator_on = 1 end --> gen on
	-----------------------------


	------ STARTER SWITCH SYSTEM ------
	-- SLOWLY ANIMATE THE SWITCH
	if starter_switch_status ~= CitX_APU_starter_switch then
		CitX_APU_starter_switch = func_animate_slowly(starter_switch_status, CitX_APU_starter_switch, 40)
	end
	-- SYSTEM
	if starter_switch_status == 2 then timer = 1 run_after_time(func_timer,5) end
	if starter_switch_status == 1 and APU_running == 0 then timer = 0 end
	-----------------------------
	
	
	------ FIRE GUARD ------
	-- SLOWLY ANIMATE THE GUARD
	if fire_guard_status ~= CitX_APU_fire_guard then
		CitX_APU_fire_guard = func_animate_slowly(fire_guard_status, CitX_APU_fire_guard, 20)
	end


	------ UPDATE NUMERIC DISPLAYS ------
	-- DC VOLTS: FROM BATT IF APU OFF, FROM BUS_0 IF APU GEN RUNNING
	if APU_generator_on == 1 and APU_generator_amps > 0.1 and cross_tie == 1 then
		CitX_APU_DC_volts = bus_volts_2
	else
		CitX_APU_DC_volts = batt_2_ind_volts
	end
	-----------------------------


	------ UPDATE ANNUNCIATORS (DIMMED BY RIGHT SIDE RHEO) ------
	if APU_panel_powered == 1 then lit_on = 1 else lit_on = 0 end --> APU PANEL POWERED
	--
	if bleed_air_valve == 1 and APU_N1_percent >= 99 then CitX_APU_annunc_bleed_val_open = lit_on * instr_brgh_right else CitX_APU_annunc_bleed_val_open = 0 end
	if APU_N1_percent >= 99 then CitX_APU_annunc_ready_load = lit_on * instr_brgh_right else CitX_APU_annunc_ready_load = 0 end
	CitX_APU_annunc_relay_engaged = timer * instr_brgh_right * lit_on
	if fail_APU == 6 or fail_APU_press == 6 then CitX_APU_annunc_fail = pwr_on * instr_brgh_right else CitX_APU_annunc_fail = 0 end
	if fail_APU_fire == 6 then CitX_APU_annunc_fire = pwr_on * instr_brgh_right else CitX_APU_annunc_fire = 0 end
	-----------------------------


	------ TEST BUTTON SYSTEM (DIMMED BY RIGHT SIDE RHEO) ------
	if test_button == 1 and APU_panel_powered == 1 then
		CitX_APU_test_button = 1
		CitX_APU_annunc_bleed_val_open = 1 * instr_brgh_right
		CitX_APU_annunc_ready_load = 1 * instr_brgh_right
		CitX_APU_annunc_fire = 1 * instr_brgh_right
		CitX_APU_annunc_relay_engaged = 1 * instr_brgh_right
		CitX_APU_annunc_fail = 1 * instr_brgh_right
	else
		CitX_APU_test_button = 0
	end
	-----------------------------

end

