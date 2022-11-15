
------------------------------------------------------------------------------------------------
-- PRESSURIZATION SYSTEM
-- INTERFACING CUSTOM DATAREFS WITH X-PLANE INTERNAL ONES
--
-- SEE ALSO BLEED AIR AND APU SCRIPTS (PRESSURIZ WORKS ONLY IF THERE IS SOME BLEED AIR)
-------------------------------------------------------------------------------------------------




----------------------------------- LOCATE DATAREFS -----------------------------------

startup_running = find_dataref("sim/operation/prefs/startup_running")
bus_volts_L = find_dataref("sim/cockpit2/electrical/bus_volts[1]")
bus_volts_R = find_dataref("sim/cockpit2/electrical/bus_volts[2]")
bleed_air_mode = find_dataref("sim/cockpit2/pressurization/actuators/bleed_air_mode") --> 0=off, 1=left,2=both,3=right,4=apu,5=auto
bleed_available_C = find_dataref("sim/cockpit2/bleedair/indicators/bleed_available_center")
bleed_available_L = find_dataref("sim/cockpit2/bleedair/indicators/bleed_available_left")
bleed_available_R = find_dataref("sim/cockpit2/bleedair/indicators/bleed_available_right")
--APU_bleed_air_switch = find_dataref("laminar/CitX/APU/bleed_air_switch") --> from the APU script
--APU_N1_percent = find_dataref("sim/cockpit2/electrical/APU_N1_percent")
dump_all_on = find_dataref("sim/cockpit2/pressurization/actuators/dump_all_on")
dump_to_altitude_on = find_dataref("sim/cockpit2/pressurization/actuators/dump_to_altitude_on")
cabin_altitude_ft = find_dataref("sim/cockpit2/pressurization/actuators/cabin_altitude_ft")
cabin_vvi_fpm = find_dataref("sim/cockpit2/pressurization/actuators/cabin_vvi_fpm")
max_allowable_altitude_ft = find_dataref("sim/cockpit2/pressurization/actuators/max_allowable_altitude_ft")
cabin_alt_ft_ind = find_dataref("sim/cockpit2/pressurization/indicators/cabin_altitude_ft")
cabin_vvi_fpm_ind = find_dataref("sim/cockpit2/pressurization/indicators/cabin_vvi_fpm")
press_diff_psi_ind = find_dataref("sim/cockpit2/pressurization/indicators/pressure_diffential_psi")
press_outflow_ratio = find_dataref("sim/flightmodel2/misc/pressure_outflow_ratio") --> from 0 closed, to 1 open
--bleed_air_off_L = find_dataref("sim/cockpit2/annunciators/bleed_air_off[0]") --> per engine
--bleed_air_off_R = find_dataref("sim/cockpit2/annunciators/bleed_air_off[1]") --> per engine
--bleed_air_fail_L = find_dataref("sim/cockpit2/annunciators/bleed_air_fail[0]") --> per engine
--bleed_air_fail_R = find_dataref("sim/cockpit2/annunciators/bleed_air_fail[1]") --> per engine
--rel_pass_o2_on = find_dataref("sim/operation/failures/rel_pass_o2_on") --> 6=pass need oxy on!









------------------------------ DATAREFS AND COMMANDS FUNCTIONS -----------------------------


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
	timer_safeguard_1, timer_safeguard_2, timer_led = 0, 0, 0
	-- THEN USE THIS IN THE ITEM FUNCTION TO START TIMER:
	-- timer_safeguard_1 = 1 run_after_time(func_timer,10) --> DURATION IN SECONDS
end


----------------------------------- SAFEGUARD CABIN DUMP
function cmd_safeguard_cabin_dump_toggle(phase, duration)
	if phase == 0 then
		safeguard_cabin_dump_value = math.abs(safeguard_cabin_dump_value - 1)
		--NO MORE TIMER-- if safeguard_cabin_dump_value == 1 then timer_safeguard_1 = 1 run_after_time(func_timer,5) end
	end
end


----------------------------------- SAFEGUARD ISOLATION VALVE
function cmd_safeguard_iso_vlv_toggle(phase, duration)
	if phase == 0 then
		safeguard_iso_vlv_value = math.abs(safeguard_iso_vlv_value - 1)
		--NO MORE TIMER-- if safeguard_iso_vlv_value == 1 then timer_safeguard_2 = 1 run_after_time(func_timer,5) end
	end
end


----------------------------------- CABIN DUMP SWITCH
function cmd_cabin_dump_toggle(phase, duration)
	if phase == 0 then cabin_dump_value = math.abs(cabin_dump_value - 1) end
end


----------------------------------- ISOLATION VALVE SWITCH
function cmd_iso_vlv_toggle(phase, duration)
	if phase == 0 then iso_vlv_value = math.abs(iso_vlv_value - 1) end
end


----------------------------------- ALTIT SELECT SWITCH
function cmd_alt_sel_toggle(phase, duration)
	if phase == 0 then alt_sel_value = math.abs(alt_sel_value - 1) end
end


----------------------------------- MANUAL SWITCH
function cmd_manual_toggle(phase, duration)
	if phase == 0 then
		manual_value = math.abs(manual_value - 1)
		if manual_value == 0 then
			timer_led = 1 run_after_time(func_timer,5) --> FAULT LED TIMER
		end
	end
end


----------------------------------- PAC BLEED SELECT HP/LP/NRM SWITCH
function cmd_pac_bleed_up(phase, duration)
	if phase == 0 and pac_bleed_value < 1 then pac_bleed_value = pac_bleed_value + 0.5 end
end
function cmd_pac_bleed_dwn(phase, duration)
	if phase == 0 and pac_bleed_value > 0 then pac_bleed_value = pac_bleed_value - 0.5 end
end


----------------------------------- WEMAC BOOST SWITCH
function cmd_wemac_boost_toggle(phase, duration)
	if phase == 0 then wemac_boost_value = math.abs(wemac_boost_value - 1) end
end


----------------------------------- ALTITUDE PRESELECTED "A" KNOB --> from -1000 to +14000 ft
function cmd_altitude_up(phase, duration)
	if altitude_value < 14000 then
		if phase == 0 then altitude_value = altitude_value + 250 end
		if phase == 1 and duration > 0.5 then altitude_value = altitude_value + 50 end
		CitX_altitude_knob = altitude_value
	end
end
function cmd_altitude_dwn(phase, duration)
	if altitude_value > -1000 then
		if phase == 0 then altitude_value = altitude_value - 250 end
		if phase == 1 and duration > 0.5 then altitude_value = altitude_value - 50 end
		CitX_altitude_knob = altitude_value
	end
end


----------------------------------- ALTITUDE MANUAL "UP/DWN" TOGGLE --> +1=up, -1=dwn
function cmd_alt_manual_up(phase, duration)
	if phase == 1 and duration > 0.1 then alt_manual_value = 1 end
	if phase == 2 then alt_manual_value = 0 end --> the spring back to center
end
function cmd_alt_manual_dwn(phase, duration)
	if phase == 1 and duration > 0.1 then alt_manual_value = -1 end
	if phase == 2 then alt_manual_value = 0 end --> the spring back to center
end


----------------------------------- RATE PRESELECTED "R PIP" KNOB --> from 500 to 2000 ft/min
function cmd_rate_up(phase, duration)
	if rate_value < 2000 then
		if phase == 0 then rate_value = rate_value + 100 end
		if phase == 1 and duration > 0.5 then rate_value = rate_value + 10 end
		CitX_rate = rate_value
	end
end
function cmd_rate_dwn(phase, duration)
	if rate_value > 500 then
		if phase == 0 then rate_value = rate_value - 100 end
		if phase == 1 and duration > 0.5 then rate_value = rate_value - 10 end
		CitX_rate = rate_value
	end
end


----------------------------------- RATE MANUAL "MAX/NORM/MIN" KNOB --> 100=min, 500=norm, 1000=max
function cmd_rate_manual_up(phase, duration)
	if rate_manual_value < 1000 then
		if phase == 0 then rate_manual_value = rate_manual_value + 50 end
		if phase == 1 and duration > 0.5 then rate_manual_value = rate_manual_value + 10 end
		--CitX_rate_manual = rate_manual_value
	end
end
function cmd_rate_manual_dwn(phase, duration)
	if rate_manual_value > 100 then
		if phase == 0 then rate_manual_value = rate_manual_value - 50 end
		if phase == 1 and duration > 0.5 then rate_manual_value = rate_manual_value - 10 end
		--CitX_rate_manual = rate_manual_value
	end
end


----------------------------------- CHECK PWR FUNCTION
function func_check_power()
	-- FAULT LED TIMER START WHEN POWER IS REMOVED AND THEN RESTABILISHED:
	if bus_volts_L + bus_volts_R > 10 and had_no_power == 1 then
		timer_led = 1 run_after_time(func_timer,5) --> FAULT LED TIMER
		had_no_power = 0
	end
end


----------------------------------- EMPTY FUNCTION FOR WRITABLE DATAREF
--function func_do_nothing()
		--nothing
--end













----------------------------------- CREATE DATAREFS AND COMMANDS -----------------------------------

CitX_safeguard_cabin_dump = create_dataref("laminar/CitX/pressurization/safeguard_cabin_dump","number")
safeguard_cabin_dump_value  = create_dataref("laminar/CitX/pressurization/safeguard_cabin_dump_term","number")
CitX_safeguard_iso_vlv = create_dataref("laminar/CitX/pressurization/safeguard_iso_vlv","number")
safeguard_iso_vlv_value = create_dataref("laminar/CitX/pressurization/safeguard_iso_vlv_term","number")
CitX_cabin_dump = create_dataref("laminar/CitX/pressurization/cabin_dump","number")
CitX_iso_vlv = create_dataref("laminar/CitX/pressurization/iso_vlv","number")
iso_vlv_value  = create_dataref("laminar/CitX/pressurization/iso_vlv_term","number")
CitX_alt_sel = create_dataref("laminar/CitX/pressurization/alt_sel","number")
alt_sel_value = create_dataref("laminar/CitX/pressurization/alt_sel_term","number")
CitX_manual = create_dataref("laminar/CitX/pressurization/manual","number")
manual_value = create_dataref("laminar/CitX/pressurization/manual_term","number")
CitX_pac_bleed = create_dataref("laminar/CitX/pressurization/pac_bleed","number") --> 0=norm, 0.5=LP, 1=HP
pac_bleed_value = create_dataref("laminar/CitX/pressurization/pac_bleed_term","number") --> 0=norm, 0.5=LP, 1=HP
CitX_wemac_boost = create_dataref("laminar/CitX/pressurization/wemac_boost","number")
wemac_boost_value  = create_dataref("laminar/CitX/pressurization/wemac_boost_term","number")
CitX_altitude = create_dataref("laminar/CitX/pressurization/altitude","number") --> from -1000 to +14000
CitX_altitude_knob = create_dataref("laminar/CitX/pressurization/altitude_knob","number")
altitude_value = create_dataref("laminar/CitX/pressurization/altitude_knob_term","number")
CitX_alt_manual = create_dataref("laminar/CitX/pressurization/alt_manual","number") --> +1=up, -1=dwn
alt_manual_value = create_dataref("laminar/CitX/pressurization/alt_manual_term","number") --> +1=up, -1=dwn
CitX_rate = create_dataref("laminar/CitX/pressurization/rate","number") --> from 500 to 2000
rate_value = create_dataref("laminar/CitX/pressurization/rate_term","number") --> from 500 to 2000
CitX_rate_manual = create_dataref("laminar/CitX/pressurization/rate_manual","number") --> 100=min, 500=norm, 2000=max
rate_manual_value = create_dataref("laminar/CitX/pressurization/rate_manual_term","number") --> 100=min, 500=norm, 2000=max
CitX_fault = create_dataref("laminar/CitX/pressurization/annunciator_fault","number") --> red led annunciator

cmdsafeguarddumptog = create_command("laminar/CitX/pressurization/cmd_safeguard_cabin_dump_toggle","Safeguard press dump toggle",cmd_safeguard_cabin_dump_toggle)
cmdsafeguardisovlvtog = create_command("laminar/CitX/pressurization/cmd_safeguard_iso_vlv_toggle","Safeguard iso vlv toggle",cmd_safeguard_iso_vlv_toggle)
cmdcabindumptog = create_command("laminar/CitX/pressurization/cmd_cabin_dump_toggle","Cabin press dump toggle",cmd_cabin_dump_toggle)
cmdisovlvtog = create_command("laminar/CitX/pressurization/cmd_iso_vlv_toggle","Isolation valve toggle",cmd_iso_vlv_toggle)
cmdaltseltog = create_command("laminar/CitX/pressurization/cmd_alt_sel_toggle","Altitude mode toggle",cmd_alt_sel_toggle)
cmdmanualtog = create_command("laminar/CitX/pressurization/cmd_manual_toggle","Manual mode toggle",cmd_manual_toggle)
cmdpacbleedup = create_command("laminar/CitX/pressurization/cmd_pac_bleed_up","PAC bleed air switch up",cmd_pac_bleed_up)
cmdpacbleeddwn = create_command("laminar/CitX/pressurization/cmd_pac_bleed_dwn","PAC bleed air switch dwn",cmd_pac_bleed_dwn)
cmdwemacboosttog = create_command("laminar/CitX/pressurization/cmd_wemac_boost_toggle","Wemac boost toggle",cmd_wemac_boost_toggle)
cmdaltitudeup = create_command("laminar/CitX/pressurization/cmd_altitude_up","Altitude preselect up",cmd_altitude_up)
cmdaltitudedwn = create_command("laminar/CitX/pressurization/cmd_altitude_dwn","Altitude preselect dwn",cmd_altitude_dwn)
cmdalt_manualup = create_command("laminar/CitX/pressurization/cmd_alt_manual_up","Altitude manual preselect up",cmd_alt_manual_up)
cmdalt_manualdwn = create_command("laminar/CitX/pressurization/cmd_alt_manual_dwn","Altitude manual preselect dwn",cmd_alt_manual_dwn)
cmdrateup = create_command("laminar/CitX/pressurization/cmd_rate_up","Rate preselect up",cmd_rate_up)
cmdratedwn = create_command("laminar/CitX/pressurization/cmd_rate_dwn","Rate preselect dwn",cmd_rate_dwn)
cmdratemanualup = create_command("laminar/CitX/pressurization/cmd_rate_manual_up","Rate manual preselect up",cmd_rate_manual_up)
cmdratemanualdwn = create_command("laminar/CitX/pressurization/cmd_rate_manual_dwn","Rate manual preselect dwn",cmd_rate_manual_dwn)









--------------------------------- DO THIS EACH FLIGHT START ---------------------------------
function flight_start()

	timer_safeguard_1, timer_safeguard_2, timer_led = 0, 0, 0
	safeguard_cabin_dump_value = 0
	safeguard_iso_vlv_value = 0
	cabin_dump_value = 0
	iso_vlv_value = 0
	alt_sel_value = 0
	manual_value = 0
	pac_bleed_value = 0
	wemac_boost_value = 0

	altitude_value = cabin_altitude_ft
	alt_manual_value = 0
	rate_value = cabin_vvi_fpm
	rate_manual_value = 500
	max_allowable_altitude_ft = 55000
	had_no_power = 0

end









--------------------------------- REGULAR RUNTIME ---------------------------------
function after_physics()

	-- SAFEGUARD CABIN DUMP --
	-- SLOWLY ANIMATE:
	if CitX_safeguard_cabin_dump ~= safeguard_cabin_dump_value then
		CitX_safeguard_cabin_dump = func_animate_slowly(safeguard_cabin_dump_value, CitX_safeguard_cabin_dump, 20)
	end
	-- TIMER AUTO CLOSE:
	--NO MORE TIMER-- safeguard_cabin_dump_value = safeguard_cabin_dump_value * timer_safeguard_1
	-----------------


	-- SAFEGUARD ISOLATION VALVE --
	-- SLOWLY ANIMATE:
	if CitX_safeguard_iso_vlv ~= safeguard_iso_vlv_value then
		CitX_safeguard_iso_vlv = func_animate_slowly(safeguard_iso_vlv_value, CitX_safeguard_iso_vlv, 20)
	end
	-- TIMER AUTO CLOSE:
	--NO MORE TIMER-- safeguard_iso_vlv_value = safeguard_iso_vlv_value * timer_safeguard_2
	-----------------


	-- CABIN DUMP SWITCH --
	-- SLOWLY ANIMATE:
	if CitX_cabin_dump ~= cabin_dump_value then
		CitX_cabin_dump = func_animate_slowly(cabin_dump_value, CitX_cabin_dump, 40)
	end
	-- SYSTEM LOGIC:
	if cabin_dump_value == 1 then dump_all_on = 1 else dump_all_on = 0 end
	-----------------


	-- ISOLATION VALVE SWITCH --
	-- SLOWLY ANIMATE:
	if CitX_iso_vlv ~= iso_vlv_value then
		CitX_iso_vlv = func_animate_slowly(iso_vlv_value, CitX_iso_vlv, 40)
	end
	-- SYSTEM LOGIC:
	-- NONE (DO NOTHING RIGHT NOW)
	-----------------


	-- ALT SEL SWITCH --
	-- SLOWLY ANIMATE:
	if CitX_alt_sel ~= alt_sel_value then
		CitX_alt_sel = func_animate_slowly(alt_sel_value, CitX_alt_sel, 40)
	end
	-- SYSTEM LOGIC:
	-- NONE HERE (IT INFLUENCE ALT/RATE LOGIC BELOW)
	-----------------


	-- MANUAL SWITCH --
	-- SLOWLY ANIMATE:
	if CitX_manual ~= manual_value then
		CitX_manual = func_animate_slowly(manual_value, CitX_manual, 40)
	end
	-- SYSTEM LOGIC:
	-- NONE HERE (IT INFLUENCE ALT/RATE AND FAULT LED LOGIC BELOW)
	-----------------


	-- PAC BLEED SELECT HP/LP/NORM SWITCH --
	-- SLOWLY ANIMATE:
	if CitX_pac_bleed ~= pac_bleed_value then
		CitX_pac_bleed = func_animate_slowly(pac_bleed_value, CitX_pac_bleed, 40)
	end
	-- NONE (DO NOTHING RIGHT NOW)
	-----------------


	-- WEMAC BOOST SWITCH --
	-- SLOWLY ANIMATE:
	if CitX_wemac_boost ~= wemac_boost_value then
		CitX_wemac_boost = func_animate_slowly(wemac_boost_value, CitX_wemac_boost, 40)
	end
	-- SYSTEM LOGIC:
	-- NONE (DO NOTHING RIGHT NOW)
	-----------------


	-- ALTITUDE AND RATE KNOBS/TOGGLE/NEEDLE --
	-- SLOWLY ANIMATE:
	-- NEEDLE
	if CitX_altitude ~= altitude_value then
		CitX_altitude = func_animate_slowly(altitude_value, CitX_altitude, 5)
	end
	-- TOGGLE UP/DWN
	if CitX_alt_manual ~= alt_manual_value then
		CitX_alt_manual = func_animate_slowly(alt_manual_value, CitX_alt_manual, 5)
	end
	-- MANUAL BIG KNOB
	if CitX_rate_manual ~= rate_manual_value then
		CitX_rate_manual = func_animate_slowly(rate_manual_value, CitX_rate_manual, 5)
	end


	-----------------------------
	-- ALTITUDE AND RATE LOGIC --
	-----------------------------
	-- IN ALT-SEL MODE:
	if alt_sel_value == 1 and manual_value == 0 then
		cabin_altitude_ft = altitude_value
		cabin_vvi_fpm = rate_value
	end
	-- IN MANUAL MODE:
	if manual_value == 1 then
		-- TARGET CABIN ALTITUDE IS THE ACTUAL ONE PLUS THE UP/DWN MANUAL TOGGLE
		cabin_altitude_ft = cabin_alt_ft_ind + alt_manual_value * 500
		altitude_value = cabin_altitude_ft
		-- RATE OF CHANGE IS THE MANUAL RATE BIG KNOB
		cabin_vvi_fpm = rate_manual_value
	end
	-- IN AUTOMATIC MODE:
	if alt_sel_value == 0 and manual_value == 0 then
		-- SET 7500 FT AS TARGET CABIN ALTITUDE AND LET X-PLANE DO THE JOB
		cabin_altitude_ft = 7500
		-- RATE OF CHANGE IS THE "R" KNOB
		cabin_vvi_fpm = rate_value
	end
	--------------------------


	---------------------------------
	-- FAULT ANNUNCIATOR LED LOGIC --
	---------------------------------
	if bus_volts_L + bus_volts_R > 10 then power = 1 else power = 0 end
	if bleed_available_C < 0.2 then bleedair_apu_off = 1 else bleedair_apu_off = 0 end
	if bleed_available_L + bleed_available_R < 0.2 then bleed_air_off_both = 1 else bleed_air_off_both = 0 end
	--
	-- LED TIMER START WHEN POWER IS REMOVED AND THEN RESTABILISHED 
	if power == 0 then had_no_power = 1 end
	func_check_power()
	--
	-- LED LIGHTS UP CONDITIONS:
	if bleed_air_off_both * bleedair_apu_off + timer_led > 0 then
		CitX_fault = 1 * power
	else
		CitX_fault = 0
	end
	---------------------------------

end

