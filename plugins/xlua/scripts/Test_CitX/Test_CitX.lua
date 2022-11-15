
-------------------------------------------------------------------------------------------------------------------------
-- TEST SYSTEMS
-- ACTIVATING SPECIFIC TEST SEQUENCE FROM THE DEDICATED KNOB ON THE PEDESTAL
-- (THIS SCRIPT HAS THIS NAME CAUSE IT SHOULD BE THE LAST ONE, TO BE ABLE TO LIT ANNUNC DESPITE OTHER SCRIPTS)
--
-- KNOB TEST VALUES ARE:
-- 0=OFF, 1=SMOKE, 2=LAND GEAR, 3=FIRE WARN, 4=THRUST REV, 5=FLAP, 6=WINDSHIELD HEAT/TEMP, 7=OVERSPEED, 8=AOA, 9=ANNUNC)
-------------------------------------------------------------------------------------------------------------------------




----------------------------------- LOCATE DATAREFS AND COMMANDS -----------------------------------

-- FROM XPLANE:
startup_running = find_dataref("sim/operation/prefs/startup_running")
bus_volts_L = find_dataref("sim/cockpit2/electrical/bus_volts[1]")
bus_volts_R = find_dataref("sim/cockpit2/electrical/bus_volts[2]")
instr_brgh_cntr = find_dataref("sim/cockpit2/electrical/instrument_brightness_ratio_auto[3]") --> brightness ratio central panel
slat1_deploy_ratio = find_dataref("sim/flightmodel2/controls/slat1_deploy_ratio")
ping_pong = find_dataref("sim/graphics/animation/ping_pong_2")

cmd_test_fire_1_annun = find_command("sim/annunciator/test_fire_1_annun")
cmd_test_fire_2_annun = find_command("sim/annunciator/test_fire_2_annun")
cmd_test_stall = find_command("sim/annunciator/test_stall")
cmd_test_all_annunciators = find_command("sim/annunciator/test_all_annunciators")
cmd_test_ap_annunciators = find_command("sim/autopilot/test_auto_annunciators")

-- FROM OTHER CITX SCRIPTS:
master_caution = find_dataref("laminar/CitX/annunciators/master_caution")
master_warning = find_dataref("laminar/CitX/annunciators/master_warning")
annunc_none = find_dataref("laminar/CitX/annunciators/none")
annunc_gpws_flap_norm = find_dataref("laminar/CitX/annunciators/gpws_flap_norm")
annunc_gpws_flap_oride = find_dataref("laminar/CitX/annunciators/gpws_flap_oride")
annunc_upper_rudder = find_dataref("laminar/CitX/annunciators/upper_rudder")
annunc_upper_rudder_A = find_dataref("laminar/CitX/annunciators/upper_rudder_A")
annunc_upper_rudder_B = find_dataref("laminar/CitX/annunciators/upper_rudder_B")
annunc_below_gs = find_dataref("laminar/CitX/annunciators/below_gs")
apu_annunc_relay_engaged = find_dataref("laminar/CitX/APU/annunc_relay_engaged")
apu_annunc_fail = find_dataref("laminar/CitX/APU/annunc_fail")
--apu_annunc_fire = find_dataref("laminar/CitX/APU/annunc_fire") --> NOT USED cause they are tested via apu panel
--apu_annunc_ready_load = find_dataref("laminar/CitX/APU/annunc_ready_load") --> NOT USED cause they are tested via apu panel
--apu_annunc_bleed_val_open = find_dataref("laminar/CitX/APU/annunc_bleed_val_open") --> NOT USED cause they are tested via apu panel
annunc_cab_temp_ctl = find_dataref("laminar/CitX/bleedair/annunc_cab_temp_ctl")
annunc_rmt = find_dataref("laminar/CitX/bleedair/annunc_rmt")
annunc_nrm = find_dataref("laminar/CitX/bleedair/annunc_nrm")
lnd_gear_annunc_unsafe = find_dataref("laminar/CitX/landing_gear/annunc_unsafe")
lnd_gear_annunc_nose = find_dataref("laminar/CitX/landing_gear/annunc_nose")
lnd_gear_annunc_left = find_dataref("laminar/CitX/landing_gear/annunc_left")
lnd_gear_annunc_right = find_dataref("laminar/CitX/landing_gear/annunc_right")
rev_annunc_arm_L = find_dataref("laminar/CitX/throttle/annunc_arm_L")
rev_annunc_arm_R = find_dataref("laminar/CitX/throttle/annunc_arm_R")
rev_annunc_unlock_L = find_dataref("laminar/CitX/throttle/annunc_unlock_L")
rev_annunc_unlock_R = find_dataref("laminar/CitX/throttle/annunc_unlock_R")
rev_annunc_deploy_L = find_dataref("laminar/CitX/throttle/annunc_deploy_L")
rev_annunc_deploy_R = find_dataref("laminar/CitX/throttle/annunc_deploy_R")
LH_fire_ext_light = find_dataref("laminar/CitX/engine_fire/LH_fire_ext_light")
RH_fire_ext_light = find_dataref("laminar/CitX/engine_fire/RH_fire_ext_light")
flap_reset_annunc = find_dataref("laminar/CitX/flaps_slats/flap_reset_annunc")
AoA_angle_ratio = find_dataref("laminar/CitX/AoA/angle_ratio")
AoA_system_working = find_dataref("laminar/CitX/AoA/system_working")
AoA_too_slow = find_dataref("laminar/CitX/AoA/too_slow")
AoA_on_track = find_dataref("laminar/CitX/AoA/on_track")
AoA_too_fast = find_dataref("laminar/CitX/AoA/too_fast")


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


----------------------------------- END TIMERS FUNCTION
function func_end_timer()
	timer_flap = 0
	-- USE THIS IN THE ITEM FUNCTION TO START TIMER:
	-- timer_N = 1 run_after_time(func_end_timer,5) --> DURATION IN SECONDS
end


----------------------------------- TEST MODE KNOB
function cmd_test_mode_up(phase, duration)
	if phase == 0 then
		if mode_value < 9 then mode_value = mode_value + 1 else mode_value = 0 end
		-- START TIMER IN FLAP MODE (FLAP TEST DURATION IS 5 SEC):
		if mode_value == 5 then timer_flap = 1 run_after_time(func_end_timer,5) end
	end
end
function cmd_test_mode_dwn(phase, duration)
	if phase == 0 then
		if mode_value > 0 then mode_value = mode_value - 1 else mode_value = 9 end
		-- START TIMER IN FLAP MODE (FLAP TEST DURATION IS 5 SEC):
		if mode_value == 5 then timer_flap = 1 run_after_time(func_end_timer,5) end
	end
end










----------------------------------- CREATE DATAREFS AND COMMANDS -----------------------------------

CitX_test_mode = create_dataref("laminar/CitX/test/mode","number") --> THE KNOB/MODE
mode_value = create_dataref("laminar/CitX/test/mode_term","number") --> THE KNOB/MODE
CitX_test_light_on = create_dataref("laminar/CitX/test/light_on","number") --> THE LED LIGHT
CitX_test_smoke = create_dataref("laminar/CitX/test/smoke","number")
CitX_test_landgear = create_dataref("laminar/CitX/test/land_gear","number")
CitX_test_firewarn = create_dataref("laminar/CitX/test/fire_warn","number")
CitX_test_thrustrev = create_dataref("laminar/CitX/test/thrust_rev","number")
CitX_test_flap = create_dataref("laminar/CitX/test/flap","number")
CitX_test_windshield = create_dataref("laminar/CitX/test/windshield","number")
CitX_test_overspeed = create_dataref("laminar/CitX/test/overspeed","number")
CitX_test_AoA = create_dataref("laminar/CitX/test/AoA","number")
CitX_test_annunc_all = create_dataref("laminar/CitX/test/annunc_all","number")

cmdtestmodeup = create_command("laminar/CitX/test/cmd_test_mode_up","Test mode knob up",cmd_test_mode_up)
cmdtestmodedwn = create_command("laminar/CitX/test/cmd_test_mode_dwn","Test mode knob dwn",cmd_test_mode_dwn)











--------------------------------- DO THIS EACH FLIGHT START ---------------------------------
function flight_start()

	mode_value = 0
	pwr_knob = 0

end








--------------------------------- REGULAR RUNTIME ---------------------------------
function after_physics()


	-- TEST MODE KNOB --
	if CitX_test_mode ~= mode_value then
		-- SLOWLY ANIMATE
		if CitX_test_mode > 8.9 and mode_value == 0 then
			CitX_test_mode = -1
		elseif CitX_test_mode < 0.1 and mode_value == 9 then
			CitX_test_mode = 10
		end
		CitX_test_mode = func_animate_slowly(mode_value, CitX_test_mode, 20)
		--
		-- LITTLE PWR OFF FROM A MODE TO ANOTHER OF THE KNOB
		if math.abs(CitX_test_mode - mode_value) > 0.01 then pwr_knob = 0 else pwr_knob = 1 end
	end
	----------------------


	-- LOOK FOR POWER ON BUSES --
	if bus_volts_L > 0.1 or bus_volts_R > 0.1 then pwr_on = 1 * pwr_knob else pwr_on = 0 end
	----------------------


	----------------------
	-- TEST MODE LOGICS --
	----------------------
	if mode_value == 0 then ---------------- 0 --> OFF
		-- NONE
	--
	elseif mode_value == 1 then ------------ 1 --> SMOKE
		CitX_test_smoke = pwr_on
		master_warning = pwr_on * instr_brgh_cntr
		-->>>>>>>>>>>>>>>>>>>>>>>>
		-->>>>>>>>>>>>>>>>>>>>>>>> AURAL DOUBLE CHIME --> MUST BE DONE USING FMOD!
		-->>>>>>>>>>>>>>>>>>>>>>>>
	--
	elseif mode_value == 2 then ------------ 2 --> LDG GEAR
		CitX_test_landgear = pwr_on
		lnd_gear_annunc_unsafe = pwr_on * instr_brgh_cntr
		lnd_gear_annunc_nose = pwr_on * instr_brgh_cntr
		lnd_gear_annunc_left = pwr_on * instr_brgh_cntr
		lnd_gear_annunc_right = pwr_on * instr_brgh_cntr
		-->>>>>>>>>>>>>>>>>>>>>>>>
		-->>>>>>>>>>>>>>>>>>>>>>>> GEAR UNSAFE WARNING HORN --> MUST BE DONE USING FMOD!
		-->>>>>>>>>>>>>>>>>>>>>>>>
	--
	elseif mode_value == 3 then ------------ 3 --> FIRE WARN
		CitX_test_firewarn = pwr_on
		master_warning = pwr_on * instr_brgh_cntr
		LH_fire_ext_light = pwr_on * instr_brgh_cntr
		RH_fire_ext_light = pwr_on * instr_brgh_cntr
		cmd_test_fire_1_annun:once()
		cmd_test_fire_2_annun:once()
		-- CITX HAS NOT (OR SHOULDN'T HAVE) FIRE BELL SOUND...?
	--
	elseif mode_value == 4 then ------------ 4 --> THRUST REV
		CitX_test_thrustrev = pwr_on
		master_warning = pwr_on * instr_brgh_cntr
		rev_annunc_arm_L = pwr_on * instr_brgh_cntr
		rev_annunc_arm_R = pwr_on * instr_brgh_cntr
		rev_annunc_unlock_L = pwr_on * instr_brgh_cntr
		rev_annunc_unlock_R = pwr_on * instr_brgh_cntr
		rev_annunc_deploy_L = pwr_on * instr_brgh_cntr
		rev_annunc_deploy_R = pwr_on * instr_brgh_cntr
	--
	elseif mode_value == 5 then ------------ 5 --> FLAP
		CitX_test_flap = pwr_on
		master_caution = timer_flap * pwr_on * instr_brgh_cntr
		annunc_gpws_flap_norm = timer_flap * pwr_on * instr_brgh_cntr
		annunc_gpws_flap_oride = timer_flap * pwr_on * instr_brgh_cntr
		flap_reset_annunc = timer_flap * pwr_on * instr_brgh_cntr
	--
	elseif mode_value == 6 then ------------ 6 --> WINDSHIELD HEAT
		CitX_test_windshield = pwr_on
		master_caution = pwr_on * instr_brgh_cntr
		-->>>>>>>>>>>>>>>>>>>>>>>>
		-->>>>>>>>>>>>>>>>>>>>>>>> AURAL SINGLE CHIME? --> DONE USING FMOD!
		-->>>>>>>>>>>>>>>>>>>>>>>>
	--
	elseif mode_value == 7 then ------------ 7 --> OVERSPEED
		CitX_test_overspeed = pwr_on
		-->>>>>>>>>>>>>>>>>>>>>>>>
		-->>>>>>>>>>>>>>>>>>>>>>>> AURAL OVERSPEED HORN --> DONE USING FMOD!
		-->>>>>>>>>>>>>>>>>>>>>>>>
	--
	elseif mode_value == 8 then ------------ 8 --> AOA/STALL
		CitX_test_AoA = pwr_on
		if slat1_deploy_ratio < 1 then slat1_deploy_ratio = slat1_deploy_ratio + 0.005 end
		AoA_angle_ratio = func_animate_slowly(2, AoA_angle_ratio, 1.5)
		if AoA_angle_ratio >= 0.95 then cmd_test_stall:once() end
		AoA_too_slow = pwr_on
		AoA_on_track = pwr_on
		AoA_too_fast = pwr_on
		-->>>>>>>>>>>>>>>>>>>>>>>>
		-->>>>>>>>>>>>>>>>>>>>>>>> STALL SHAKER, SOUND DONE USING FMOD!
		-->>>>>>>>>>>>>>>>>>>>>>>>
	--
	elseif mode_value == 9 then ------------ 9 --> ANNUNCIATORS (DIMMED BY CENTR BRIGHT RHEO)
		CitX_test_annunc_all = pwr_on
		--cmd_test_all_annunciators:once()
		cmd_test_ap_annunciators:once()
		annunc_none = pwr_on * instr_brgh_cntr
		master_caution = pwr_on * instr_brgh_cntr
		master_warning = pwr_on * instr_brgh_cntr
		--LH_fire_ext_light = pwr_on * instr_brgh_cntr
		--RH_fire_ext_light = pwr_on * instr_brgh_cntr
		--rev_annunc_arm_L = pwr_on * instr_brgh_cntr
		--rev_annunc_arm_R = pwr_on * instr_brgh_cntr
		--rev_annunc_unlock_L = pwr_on * instr_brgh_cntr
		--rev_annunc_unlock_R = pwr_on * instr_brgh_cntr
		--rev_annunc_deploy_L = pwr_on * instr_brgh_cntr
		--rev_annunc_deploy_R = pwr_on * instr_brgh_cntr
		annunc_upper_rudder = pwr_on * instr_brgh_cntr
		annunc_upper_rudder_A = pwr_on * instr_brgh_cntr
		annunc_upper_rudder_B = pwr_on * instr_brgh_cntr
		annunc_gpws_flap_norm = pwr_on * instr_brgh_cntr
		annunc_gpws_flap_oride = pwr_on * instr_brgh_cntr
		annunc_below_gs = pwr_on * instr_brgh_cntr
		--apu_annunc_fire = pwr_on * instr_brgh_cntr
		apu_annunc_relay_engaged = pwr_on * instr_brgh_cntr
		apu_annunc_fail = pwr_on * instr_brgh_cntr
		annunc_cab_temp_ctl = pwr_on * instr_brgh_cntr
		annunc_rmt = pwr_on * instr_brgh_cntr
		annunc_nrm = pwr_on * instr_brgh_cntr
		--flap_reset_annunc = pwr_on * instr_brgh_cntr
		-->>>>>>>>>>>>>>>>>>>>>>>>
		-->>>>>>>>>>>>>>>>>>>>>>>> AURAL GLIDESLOPE, PULLUP, TCAS, WINDSHEAR, TERRAIN --> DONE USING FMOD!
		-->>>>>>>>>>>>>>>>>>>>>>>>
	else
		-- NONE (ALL ANNUNC ARE NATURALLY RETURNED TO THEIR OWN VALUES BY THEIR OWN SCRIPTS OR BY XPLANE)
	end
	---------------------


	-- RESET INDIVIDUAL TEST DATAREFS --
	if mode_value ~= 1 or pwr_on == 0 then CitX_test_smoke = 0 end
	if mode_value ~= 2 or pwr_on == 0 then CitX_test_landgear = 0 end
	if mode_value ~= 3 or pwr_on == 0 then CitX_test_firewarn = 0 end
	if mode_value ~= 4 or pwr_on == 0 then CitX_test_thrustrev = 0 end
	if mode_value ~= 5 or pwr_on == 0 then CitX_test_flap = 0 end
	if mode_value ~= 6 or pwr_on == 0 then CitX_test_windshield = 0 end
	if mode_value ~= 7 or pwr_on == 0 then CitX_test_overspeed = 0 end
	if mode_value ~= 8 or pwr_on == 0 then CitX_test_AoA = 0 end
	if mode_value ~= 9 or pwr_on == 0 then CitX_test_annunc_all = 0 end
	---------------------


	-- LED LIGHT LOGIC --
	if mode_value * pwr_on > 0 then CitX_test_light_on = 1 else CitX_test_light_on = 0 end
	---------------------


	-- MASTER WARNING FLASHING --
	master_warning = master_warning * (math.abs(ping_pong)*2) --> FLASHING
	---------------------
		

end

