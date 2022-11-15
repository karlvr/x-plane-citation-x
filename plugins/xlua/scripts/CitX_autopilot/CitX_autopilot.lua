
------------------------------------------------------------------------------------------------
-- AUTOPILOT BUTTONS AND NOSE UP/DWN WHEEL
-- INTERFACING CUSTOM DATAREFS WITH X-PLANE INTERNAL ONES
-------------------------------------------------------------------------------------------------



-------------------------------------------------------------------------
------------------------------- FUNCTIONS -------------------------------
-------------------------------------------------------------------------

-- EMPTY FUNCTION FOR WRITABLE DATAREF
function func_do_nothing()
	--nothing
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


----------------------------------- AUTOPILOT MODE FUNCTIONS ##################### ALL AP FUNCTIONS HERE ##################
-- HEADING BUTTON
function cmd_heading_toggle(phase, duration)
	if phase == 2 and pwr_on == 1 then
		--hdg_mode = math.abs((hdg_mode + 1) - 2) --> TOGGLE FROM 0 TO 1
		cmd_heading:once()
	end
end
-- NAV BUTTON
function cmd_nav_toggle(phase, duration)
	if phase == 2 and pwr_on == 1 then
		--nav_mode = math.abs((nav_mode + 1) - 2) --> TOGGLE FROM 0 TO 1
		cmd_NAV:once()
	end
end
-- APPROACH BUTTON
function cmd_app_toggle(phase, duration)
	if phase == 2 and pwr_on == 1 then
		--app_mode = math.abs((app_mode + 1) - 2) --> TOGGLE FROM 0 TO 1
		cmd_approach:once()
	end
end
-- BACK COURSE BUTTON
function cmd_bc_toggle(phase, duration)
	if phase == 2 and pwr_on == 1 then
		--bc_mode = math.abs((bc_mode + 1) - 2) --> TOGGLE FROM 0 TO 1
		cmd_back_course:once()
	end
end
-- ALTITUDE HOLD BUTTON
function cmd_alt_toggle(phase, duration)
	if phase == 2 and pwr_on == 1 then
		--alt_mode = math.abs((alt_mode + 1) - 2) --> TOGGLE FROM 0 TO 1
		cmd_altitude_hold:once()
	end
end
-- VNAV BUTTON
function cmd_vnav_toggle(phase, duration)
	if phase == 2 and pwr_on == 1 then
		--vnav_mode = math.abs((vnav_mode + 1) - 2) --> TOGGLE FROM 0 TO 1
		cmd_vnav:once()
	end
end
-- BANK BUTTON
function cmd_bank_toggle(phase, duration)
	if phase == 2 and pwr_on == 1 then
		--bank_mode = math.abs((bank_mode + 1) - 2) --> TOGGLE FROM 0 TO 1
		cmd_bank_limit_toggle:once()
	end
end
-- STANDBY BUTTON
function cmd_stby_toggle(phase, duration)
	if phase == 2 and pwr_on == 1 then
		--stby_mode = math.abs((stby_mode + 1) - 2) --> TOGGLE FROM 0 TO 1
		cmd_attitude:once()
	end
end
-- FLIGHT LEVEL CHANGE BUTTON
function cmd_flc_toggle(phase, duration)
	if phase == 2 and pwr_on == 1 then
		--flc_mode = math.abs((flc_mode + 1) - 2) --> TOGGLE FROM 0 TO 1
		cmd_level_change:once()
	end
end
-- CHANGEOVER (IAS/MACH) BUTTON
function cmd_cngovr_toggle(phase, duration)
	if phase == 2 and pwr_on == 1 then
		--cngovr_mode = math.abs((cngovr_mode + 1) - 2) --> TOGGLE FROM 0 TO 1
		cmd_knots_mach_toggle:once()
	end
end
-- VERTICAL SPEED BUTTON
function cmd_vs_toggle(phase, duration)
	if phase == 2 and pwr_on == 1 then
		--vs_mode = math.abs((vs_mode + 1) - 2) --> TOGGLE FROM 0 TO 1
		cmd_vertical_speed:once()
	end
end
--
-- AUTOPILOT SERVOS AP BUTTON
function cmd_ap_toggle(phase, duration)
	if phase == 2 and pwr_on == 1 then
		if fd_mode ~= 2 then --> TOGGLE FD FROM 0 TO 2 (on with servos)
			fd_mode = 2
			yaw_damper_on = 1 --> ENGAGE ALSO YD
		elseif fd_mode == 2 or fd2_mode == 2 then
			fd_mode = 0
			fd2_mode = 0
		else
			fd_mode = 2
		end
	end
end
-- AUTOPILOT YAW DAMPER BUTTON
function cmd_yd_toggle(phase, duration)
	if phase == 2 and pwr_on == 1 then
		yaw_damper_on = math.abs((yaw_damper_on + 1) - 2) --> TOGGLE FROM 0 TO 1
	end
end
-- AUTOPILOT MACH TRIM BUTTON
function cmd_mtrim_toggle(phase, duration)
	if phase == 2 and pwr_on == 1 then
		mtrim_on = math.abs((mtrim_on + 1) - 2) --> TOGGLE FROM 0 TO 1
		-- HERE THE RIGHT FUNCTION -- CURRENTLY DOES NOTHING
	end
end
-- AUTOPILOT SOURCE PFD SEL BUTTON
function cmd_pfdsel_toggle(phase, duration)
	if phase == 2 and pwr_on == 1 then
		autopilot_source = math.abs((autopilot_source + 1) - 2) --> TOGGLE FROM 0 TO 1
	end
end


----------------------------------- FUNCTION ###################### PLACEHOLDER #####################
function cmd_placeholder_funct(phase, duration)
	if phase == 0 and pwr_on == 1 then
		--nothing
	end
end


----------------------------------- AUTOPILOT NOSE UP/DWN WHEEL 1 FUNCTION
function cmd_wheel1_up(phase, duration)
	if phase == 0 then
		wheel1_value = wheel1_value + 10
		cmd_nose_up:once()
	end
end
function cmd_wheel1_dwn(phase, duration)
	if phase == 0 then
		wheel1_value = wheel1_value - 10
		cmd_nose_down:once()
	end
end


----------------------------------- AUTOPILOT NOSE UP/DWN WHEEL 2 FUNCTION
function cmd_wheel2_up(phase, duration)
	if phase == 0 then
		wheel2_value = wheel2_value + 10
		cmd_nose_up:once()
	end
end
function cmd_wheel2_dwn(phase, duration)
	if phase == 0 then
		wheel2_value = wheel2_value - 10
		cmd_nose_down:once()
	end
end





--------------------------------------------------------------------------------
----------------------------------- DATAREFS -----------------------------------
--------------------------------------------------------------------------------

-- LOCATE --
startup_running = find_dataref("sim/operation/prefs/startup_running")
bus_volts_0 = find_dataref("sim/cockpit2/electrical/bus_volts[0]") --> apu/ext/stby bus
bus_volts_1 = find_dataref("sim/cockpit2/electrical/bus_volts[1]") --> L bus
bus_volts_2 = find_dataref("sim/cockpit2/electrical/bus_volts[2]") --> R bus
CitX_test_annunc_all = find_dataref("laminar/CitX/test/annunc_all") --> annunc test from the test script
instr_brgh_cntr = find_dataref("sim/cockpit2/electrical/instrument_brightness_ratio_auto[3]") --> brightness ratio central panel
autopilot_source = find_dataref("sim/cockpit2/autopilot/autopilot_source") --> pilots(0) or copilots(1) for PFD SEL
fd_mode = find_dataref("sim/cockpit2/autopilot/flight_director_mode") --> 0 off, 1 on, 2 on with servos
fd2_mode = find_dataref("sim/cockpit2/autopilot/flight_director2_mode") --> 0 off, 1 on, 2 on with servos
yaw_damper_on = find_dataref("sim/cockpit2/switches/yaw_damper_on")
heading_status = find_dataref("sim/cockpit2/autopilot/heading_status") --> 0=off,1=armed,2=captured
altitude_hold_status = find_dataref("sim/cockpit2/autopilot/altitude_hold_status")
speed_status = find_dataref("sim/cockpit2/autopilot/speed_status")
nav_status = find_dataref("sim/cockpit2/autopilot/nav_status")
airspeed_is_mach = find_dataref("sim/cockpit2/autopilot/airspeed_is_mach")
vnav_status = find_dataref("sim/cockpit2/autopilot/fms_vnav")
approach_status = find_dataref("sim/cockpit2/autopilot/approach_status")
autopilot_bank_limit = find_dataref("sim/cockpit/warnings/annunciators/autopilot_bank_limit") --> 1 = keep bank below 12.5°
bank_angle_mode = find_dataref("sim/cockpit2/autopilot/bank_angle_mode") --> 0=auto, 1=5°, 2=10°, 6=30°
vvi_status = find_dataref("sim/cockpit2/autopilot/vvi_status")
backcourse_status = find_dataref("sim/cockpit2/autopilot/backcourse_status")
attitude_status = find_dataref("sim/cockpit2/autopilot/attitude_status")


-- CREATE --
CitX_hdg_mode_on = create_dataref("laminar/CitX/autopilot/hdg_mode_on","number")
CitX_alt_mode_on = create_dataref("laminar/CitX/autopilot/alt_mode_on","number")
CitX_flc_mode_on = create_dataref("laminar/CitX/autopilot/flc_mode_on","number")
CitX_nav_mode_on = create_dataref("laminar/CitX/autopilot/nav_mode_on","number")
CitX_vnav_mode_on = create_dataref("laminar/CitX/autopilot/vnav_mode_on","number")
CitX_cngovr_mode_on = create_dataref("laminar/CitX/autopilot/cngovr_mode_on","number") --> changeover ias or mach
CitX_app_mode_on = create_dataref("laminar/CitX/autopilot/app_mode_on","number")
CitX_bank_mode_on = create_dataref("laminar/CitX/autopilot/bank_mode_on","number")
CitX_vs_mode_on = create_dataref("laminar/CitX/autopilot/vs_mode_on","number")
CitX_bc_mode_on = create_dataref("laminar/CitX/autopilot/bc_mode_on","number")
CitX_stby_mode_on = create_dataref("laminar/CitX/autopilot/stby_mode_on","number")

CitX_wheel1 = create_dataref("laminar/CitX/autopilot/wheel1","number")
CitX_wheel2 = create_dataref("laminar/CitX/autopilot/wheel2","number")

CitX_left_ap = create_dataref("laminar/CitX/autopilot/left_ap","number")
CitX_left_yd = create_dataref("laminar/CitX/autopilot/left_yd","number")
CitX_left_mtrim = create_dataref("laminar/CitX/autopilot/left_mtrim","number")
CitX_left_pfdsel = create_dataref("laminar/CitX/autopilot/left_pfdsel","number")
CitX_right_ap = create_dataref("laminar/CitX/autopilot/right_ap","number")
CitX_right_yd = create_dataref("laminar/CitX/autopilot/right_yd","number")
CitX_right_mtrim = create_dataref("laminar/CitX/autopilot/right_mtrim","number")
CitX_right_pfdsel = create_dataref("laminar/CitX/autopilot/right_pfdsel","number")






--------------------------------------------------------------------------------
----------------------------------- COMMANDS -----------------------------------
--------------------------------------------------------------------------------

cmd_test_ap_annunciators = find_command("sim/autopilot/test_auto_annunciators")
cmd_heading = find_command("sim/autopilot/heading")
cmd_altitude_hold = find_command("sim/autopilot/altitude_hold")
cmd_level_change = find_command("sim/autopilot/level_change")
cmd_NAV = find_command("sim/autopilot/NAV")
cmd_vnav = find_command("sim/autopilot/FMS")
cmd_knots_mach_toggle = find_command("sim/autopilot/knots_mach_toggle")
cmd_approach = find_command("sim/autopilot/approach")
cmd_bank_limit_toggle = find_command("sim/autopilot/bank_limit_toggle")
cmd_vertical_speed = find_command("sim/autopilot/vertical_speed")
cmd_back_course = find_command("sim/autopilot/back_course")
cmd_attitude = find_command("sim/autopilot/attitude")
cmd_nose_down = find_command("sim/autopilot/nose_down")
cmd_nose_up = find_command("sim/autopilot/nose_up")
cmd_servos_toggle = find_command("sim/autopilot/servos_toggle")
cmd_yaw_damper_toggle = find_command("sim/systems/yaw_damper_toggle")
cmd_source_01 = find_command("sim/autopilot/source_01")

cmdhdgmode = create_command("laminar/CitX/autopilot/cmd_hdg_mode","Autopilot heading hold mode",cmd_heading_toggle)
cmdaltmode = create_command("laminar/CitX/autopilot/cmd_alt_mode","Autopilot altitude hold mode",cmd_alt_toggle)
cmdflcmode = create_command("laminar/CitX/autopilot/cmd_flc_mode","Autopilot flight level change mode",cmd_flc_toggle)
cmdnavmode = create_command("laminar/CitX/autopilot/cmd_nav_mode","Autopilot nav mode",cmd_nav_toggle)
cmdvnavmode = create_command("laminar/CitX/autopilot/cmd_vnav_mode","Autopilot vnav mode",cmd_vnav_toggle)
cmdcngovrmode = create_command("laminar/CitX/autopilot/cmd_cngovr_mode","Autopilot changeover (IAS mach) mode",cmd_cngovr_toggle)
cmdappmode = create_command("laminar/CitX/autopilot/cmd_app_mode","Autopilot approach (ILS) mode",cmd_app_toggle)
cmdbankmode = create_command("laminar/CitX/autopilot/cmd_bank_mode","Autopilot full or reduced bank mode",cmd_bank_toggle)
cmdvsmode = create_command("laminar/CitX/autopilot/cmd_vs_mode","Autopilot vertical speed mode",cmd_vs_toggle)
cmdbcmode = create_command("laminar/CitX/autopilot/cmd_bc_mode","Autopilot back course mode",cmd_bc_toggle)
cmdstbymode = create_command("laminar/CitX/autopilot/cmd_stby_mode","Autopilot standby (basic pitch/roll hold) mode",cmd_stby_toggle)

cmdwheel1up = create_command("laminar/CitX/autopilot/cmd_wheel1_up","Autopilot wheel 1 up",cmd_wheel1_up)
cmdwheel1dwn = create_command("laminar/CitX/autopilot/cmd_wheel1_dwn","Autopilot wheel 1 down",cmd_wheel1_dwn)
cmdwheel2up = create_command("laminar/CitX/autopilot/cmd_wheel2_up","Autopilot wheel 2 up",cmd_wheel2_up)
cmdwheel2dwn = create_command("laminar/CitX/autopilot/cmd_wheel2_dwn","Autopilot wheel 2 down",cmd_wheel2_dwn)

cmdaptoggle = create_command("laminar/CitX/autopilot/cmd_ap_toggle","Autopilot toggle",cmd_ap_toggle)
cmdydtoggle = create_command("laminar/CitX/autopilot/cmd_yd_toggle","Autopilot yaw damper toggle",cmd_yd_toggle)
cmdmtrimtoggle = create_command("laminar/CitX/autopilot/cmd_mtrim_toggle","Autopilot mach trim toggle",cmd_mtrim_toggle)
cmdpfdseltoggle = create_command("laminar/CitX/autopilot/cmd_pfdsel_toggle","Autopilot PFD source toggle",cmd_pfdsel_toggle)







----------------------------------------------------------------------------------
--------------------------------- INITIALIZATION ---------------------------------
----------------------------------------------------------------------------------

-- DO THIS EACH FLIGHT START
function flight_start()

	pwr_on = startup_running
	CitX_hdg_mode_on, hdg_mode = 0, 0
	CitX_alt_mode_on, alt_mode = 0, 0
	CitX_flc_mode_on, flc_mode = 0, 0
	CitX_nav_mode_on, nav_mode = 0, 0
	CitX_vnav_mode_on, vnav_mode = 0, 0
	CitX_cngovr_mode_on, cngovr_mode = 0, 0
	CitX_app_mode_on, app_mode = 0, 0
	CitX_bank_mode_on, bank_mode = 0, 0
	CitX_vs_mode_on, vs_mode = 0, 0
	CitX_bc_mode_on, bc_mode = 0, 0
	CitX_stby_mode_on, stby_mode = 0, 0
	CitX_wheel1, CitX_wheel2, wheel1_value, wheel2_value = 0, 0, 0, 0
	CitX_left_ap = 0
	CitX_left_yd = 0
	CitX_left_mtrim, mtrim_on = 0, 0
	CitX_left_pfdsel = 0
	CitX_right_ap = 0
	CitX_right_yd = 0
	CitX_right_mtrim = 0
	CitX_right_pfdsel = 0

	bank_angle_mode = 6
	
end






---------------------------------------------------------------------------
--------------------------------- RUNTIME ---------------------------------
---------------------------------------------------------------------------

function after_physics()

	-- WILL LIT ANNUNCIATORS ONLY IF POWER ON BUSES
	--if bus_volts_0 + bus_volts_1 + bus_volts_2 > 0.1 then pwr_on = 1 else pwr_on = 0 end -- NO BUS 0 SINCE IT IS JUST FOR STBY INSTR
	if bus_volts_1 + bus_volts_2 > 0.1 then pwr_on = 1 else pwr_on = 0 end
	

	-- NOSE UP/DWN WHEELS --
	-- SLOWLY ANIMATE 1:
	if CitX_wheel1 ~= wheel1_value then
		CitX_wheel1 = func_animate_slowly(wheel1_value, CitX_wheel1, 20)
	end
	-- SLOWLY ANIMATE 2:
	if CitX_wheel2 ~= wheel2_value then
		CitX_wheel2 = func_animate_slowly(wheel2_value, CitX_wheel2, 20)
	end
	---------------------


	-- EVALUATE STATUS/MODE --
	if heading_status == 2 then hdg_mode = 1 else hdg_mode = 0 end
	if altitude_hold_status == 2 then alt_mode = 1 else alt_mode = 0 end
	if speed_status == 2 then flc_mode = 1 else flc_mode = 0 end
	if nav_status > 0 then nav_mode = 1 else nav_mode = 0 end
	if vnav_status > 0 then vnav_mode = 1 else vnav_mode = 0 end
	if airspeed_is_mach == 1 then cngovr_mode = 1 else cngovr_mode = 0 end
	if approach_status > 0 then app_mode = 1 else app_mode = 0 end
	if autopilot_bank_limit == 1 then bank_mode = 1 else bank_mode = 0 end
	if vvi_status == 2 then vs_mode = 1 else vs_mode = 0 end
	if backcourse_status > 0 then bc_mode = 1 else bc_mode = 0 end
	if attitude_status == 2 then stby_mode = 1 else stby_mode = 0 end
	---------------------


	-- LIT ANNUNCIATORS (DIMMED BY THE CENTER BRIGHTNES RHEO) --
	CitX_hdg_mode_on = hdg_mode * instr_brgh_cntr * pwr_on
	CitX_alt_mode_on = alt_mode * instr_brgh_cntr * pwr_on
	CitX_flc_mode_on = flc_mode * instr_brgh_cntr * pwr_on
	CitX_nav_mode_on = nav_mode * instr_brgh_cntr * pwr_on
	CitX_vnav_mode_on = vnav_mode * instr_brgh_cntr * pwr_on
	CitX_cngovr_mode_on = cngovr_mode * instr_brgh_cntr * pwr_on
	CitX_app_mode_on = app_mode * instr_brgh_cntr * pwr_on
	CitX_bank_mode_on = bank_mode * instr_brgh_cntr * pwr_on
	CitX_vs_mode_on = vs_mode * instr_brgh_cntr * pwr_on
	CitX_bc_mode_on = bc_mode * instr_brgh_cntr * pwr_on
	CitX_stby_mode_on = stby_mode * instr_brgh_cntr * pwr_on
	CitX_left_ap = math.floor(fd_mode/2) * instr_brgh_cntr * pwr_on --> =1 only if on with servos
	CitX_right_ap = math.floor(fd2_mode/2) * instr_brgh_cntr * pwr_on --> =1 only if on with servos
	CitX_left_yd = (CitX_left_ap * yaw_damper_on + yaw_damper_on) * instr_brgh_cntr * pwr_on --> =1 if YD or YD+APleft
	CitX_right_yd = (CitX_right_ap * yaw_damper_on) * instr_brgh_cntr * pwr_on --> =1 only if YD+APright
	CitX_left_mtrim = (CitX_left_ap * mtrim_on + mtrim_on) * instr_brgh_cntr * pwr_on
	CitX_right_mtrim = (CitX_right_ap * mtrim_on) * instr_brgh_cntr * pwr_on
	CitX_left_pfdsel = math.abs((autopilot_source + 1) - 2) * instr_brgh_cntr * pwr_on -- ON(1) when ap source is 0, OFF(0) when 1
	CitX_right_pfdsel = autopilot_source * instr_brgh_cntr * pwr_on -- ON(1) when ap source is 1, OFF(0) when 0
	--
	-- TEST MODE:
	if CitX_test_annunc_all == 1 and pwr_on == 1 then
		CitX_hdg_mode_on = 1 * instr_brgh_cntr
		CitX_alt_mode_on = 1 * instr_brgh_cntr
		CitX_flc_mode_on = 1 * instr_brgh_cntr
		CitX_nav_mode_on = 1 * instr_brgh_cntr
		CitX_vnav_mode_on = 1 * instr_brgh_cntr
		CitX_cngovr_mode_on = 1 * instr_brgh_cntr
		CitX_app_mode_on = 1 * instr_brgh_cntr
		CitX_bank_mode_on = 1 * instr_brgh_cntr
		CitX_vs_mode_on = 1 * instr_brgh_cntr
		CitX_bc_mode_on = 1 * instr_brgh_cntr
		CitX_stby_mode_on = 1 * instr_brgh_cntr
		CitX_left_ap = 1 * instr_brgh_cntr
		CitX_left_yd = 1 * instr_brgh_cntr
		CitX_left_mtrim = 1 * instr_brgh_cntr
		CitX_left_pfdsel = 1 * instr_brgh_cntr
		CitX_right_ap = 1 * instr_brgh_cntr
		CitX_right_yd = 1 * instr_brgh_cntr
		CitX_right_mtrim = 1 * instr_brgh_cntr
		CitX_right_pfdsel = 1 * instr_brgh_cntr
	end
	---------------------

end


