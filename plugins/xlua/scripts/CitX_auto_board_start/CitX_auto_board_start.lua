
--
-- THIS SCRIPT OVERRIDE THE X-PLANE DEFAULT COMMANDS FOR
-- AUTOBOARD ("Prep electrical system for boarding" menu)
-- AND AUTOSTART ("Start engines to running" menu)
--
-- IT TAKE ALL THE NECESSARY DATAREFS AND COMMANDS TO START THE AIRCRAFT
-- SETTING/INVOKING THEM IN THE RIGHT SEQUENCE
-- 




----------------------------------- DATAREFS AND COMMANDS -----------------------------------

autoboard_in_progress = find_dataref("sim/flightmodel2/misc/auto_board_in_progress")
autostart_in_progress = find_dataref("sim/flightmodel2/misc/auto_start_in_progress")
tot_run_time_sec = find_dataref("sim/time/total_running_time_sec")

parking_brake_ratio = find_dataref("sim/cockpit2/controls/parking_brake_ratio")
clear_master_warningCMD = find_command("sim/annunciator/clear_master_warning")
clear_master_cautionCMD = find_command("sim/annunciator/clear_master_caution")
APU_N1_percent = find_dataref("sim/cockpit2/electrical/APU_N1_percent")
local_time_hours = find_dataref("sim/cockpit2/clock_timer/local_time_hours")
throttle_L = find_dataref("sim/cockpit2/engine/actuators/throttle_ratio[0]")
throttle_R = find_dataref("sim/cockpit2/engine/actuators/throttle_ratio[1]")
mixture_L = find_dataref("sim/cockpit2/engine/actuators/mixture_ratio[0]")
mixture_R = find_dataref("sim/cockpit2/engine/actuators/mixture_ratio[1]")
N2_percent_L = find_dataref("sim/cockpit2/engine/indicators/N2_percent[0]")
N2_percent_R = find_dataref("sim/cockpit2/engine/indicators/N2_percent[1]")
engage_starter_L_CMD = find_command("laminar/CitX/engine/cmd_starter_left") --sim/starters/engage_starter_1")
engage_starter_R_CMD = find_command("laminar/CitX/engine/cmd_starter_right") --sim/starters/engage_starter_2")

emerg_lt = find_dataref("laminar/CitX/lights/emerg_light_switch")
emerg_ltCMD = find_command("laminar/CitX/lights/emerg_light_switch_up")
xfer_left = find_dataref("laminar/CitX/fuel/transfer_left")
xfer_leftCMD = find_command("laminar/CitX/fuel/cmd_transfer_left_dwn")
xfer_right = find_dataref("laminar/CitX/fuel/transfer_right")
xfer_rightCMD = find_command("laminar/CitX/fuel/cmd_transfer_right_dwn")
boost_left = find_dataref("laminar/CitX/fuel/boost_left")
boost_leftCMDup = find_command("laminar/CitX/fuel/cmd_boost_left_up")
boost_leftCMDdwn = find_command("laminar/CitX/fuel/cmd_boost_left_dwn")
boost_right = find_dataref("laminar/CitX/fuel/boost_right")
boost_rightCMDup = find_command("laminar/CitX/fuel/cmd_boost_right_up")
boost_rightCMDdwn = find_command("laminar/CitX/fuel/cmd_boost_right_dwn")
ign_left = find_dataref("laminar/CitX/engine/ignition_switch_left")
ign_leftCMDup = find_command("laminar/CitX/engine/cmd_ignition_switch_left_up")
ign_leftCMDdwn = find_command("laminar/CitX/engine/cmd_ignition_switch_left_dwn")
ign_right = find_dataref("laminar/CitX/engine/ignition_switch_right")
ign_rightCMDup = find_command("laminar/CitX/engine/cmd_ignition_switch_right_up")
ign_rightCMDdwn = find_command("laminar/CitX/engine/cmd_ignition_switch_right_dwn")
batt_stby = find_dataref("laminar/CitX/electrical/battery_stby_pwr")
batt_stbyCMD = find_command("laminar/CitX/electrical/cmd_stby_pwr_up")
batt_left = find_dataref("laminar/CitX/electrical/battery_left")
batt_leftCMD = find_command("laminar/CitX/electrical/cmd_battery_left_toggle")
batt_right = find_dataref("laminar/CitX/electrical/battery_right")
batt_rightCMD = find_command("laminar/CitX/electrical/cmd_battery_right_toggle")
avionics = find_dataref("laminar/CitX/electrical/avionics")
avionicsCMD = find_command("laminar/CitX/electrical/cmd_avionics_toggle")
eicas = find_dataref("laminar/CitX/electrical/avionics_eicas")
eicasCMD = find_command("laminar/CitX/electrical/cmd_avionics_eicas_toggle")
apu_master = find_dataref("laminar/CitX/APU/master_switch")
apu_masterCMD = find_command("laminar/CitX/APU/master_switch_toggle")
apu_starter = find_dataref("laminar/CitX/APU/starter_switch")
apu_starterCMDup = find_command("laminar/CitX/APU/starter_switch_up")
apu_starterCMDdwn = find_command("laminar/CitX/APU/starter_switch_dwn")
apu_gen = find_dataref("laminar/CitX/APU/gen_switch")
apu_genCMD = find_command("laminar/CitX/APU/gen_switch_up")
apu_genCMDdwn = find_command("laminar/CitX/APU/gen_switch_dwn")
apu_bleed = find_dataref("laminar/CitX/APU/bleed_air_switch")
apu_bleedCMD = find_command("laminar/CitX/APU/bleed_switch_up")
apu_bleedCMDdwn = find_command("laminar/CitX/APU/bleed_switch_dwn")
anti_coll = find_dataref("laminar/CitX/lights/gnd_rec_anti_coll")
anti_collCMD = find_command("laminar/CitX/lights/cmd_gnd_rec_anti_coll_up")
ice_pitot_L = find_dataref("laminar/CitX/ice/pitot_static_left")
ice_pitot_R = find_dataref("laminar/CitX/ice/pitot_static_right")
ice_pitot_LCMD = find_command("laminar/CitX/ice/cmd_pitot_static_left_toggle")
ice_pitot_RCMD = find_command("laminar/CitX/ice/cmd_pitot_static_right_toggle")
nav = find_dataref("laminar/CitX/lights/navigation")
navCMD = find_command("laminar/CitX/lights/cmd_navigation_toggle")
tail_flood = find_dataref("laminar/CitX/lights/tail_flood")
tail_floodCMD = find_command("laminar/CitX/lights/cmd_tail_flood_toggle")
taxi = find_dataref("laminar/CitX/lights/taxi")
taxiCMD = find_command("laminar/CitX/lights/cmd_taxi_toggle")
landingL = find_dataref("laminar/CitX/lights/landing_left")
landingLCMD = find_command("laminar/CitX/lights/cmd_landing_left_toggle")
landingR = find_dataref("laminar/CitX/lights/landing_right")
landingRCMD = find_command("laminar/CitX/lights/cmd_landing_right_toggle")
aux_pump = find_dataref("laminar/CitX/hydraulics/aux_pump")
aux_pumpCMD = find_command("laminar/CitX/hydraulics/cmd_aux_pump_toggle")
gnd_idle = find_dataref("laminar/CitX/engine/gnd_idle") --> 0= max mixture 0.5 / 1= max mixture 1
gen_L = find_dataref("laminar/CitX/electrical/generator_left")
gen_LCMD = find_command("laminar/CitX/electrical/cmd_generator_left_up")
gen_R = find_dataref("laminar/CitX/electrical/generator_right")
gen_RCMD = find_command("laminar/CitX/electrical/cmd_generator_right_up")
cabinmaster = find_dataref("laminar/CitX/lights/cabin_lights_on")
cabinmaster_CMD = find_command("laminar/CitX/lights/cmd_cabin_master_toggle")

autostart_step = create_dataref("laminar/CitX/autostart_step","number") -- TO CHECK STEPS DURING RUNTIME
autoboard_step = create_dataref("laminar/CitX/autoboard_step","number") -- TO CHECK STEPS DURING RUNTIME
elapsed_time = create_dataref("laminar/CitX/autobs_elapsed_time","number") -- TO CHECK STEPS DURING RUNTIME


------------------------------- FUNCTIONS AND COMMANDS CALLBACK -------------------------------

-- ANIMATION FUNCTION
function update_slowly(position,positionNEW,speed)
	position = position + ((positionNEW - position) * (speed * SIM_PERIOD))
	return position
end


-- DELAY FUNCTION
function reset_delay()
	delay = 0
	return delay
end


-- COMMANDS CALLBACK:

function sim_autoboard_CMDhandler(phase, duration)
    if phase == 0 then
        --AUTOBOARD COMMAND INVOKED
        if autoboard_in_progress == 0 and autostart_in_progress == 0 then
			autoboard_step = 1
			autoboard_in_progress = 1
			elapsed_time = 0 				-- reset timer
			check_time = tot_run_time_sec	-- start timer
		end
    end
end

function sim_autostart_CMDhandler(phase, duration)
    if phase == 0 then
	--AUTOSTART COMMAND INVOKED
        if autoboard_in_progress == 0 and autostart_in_progress == 0 then
			autostart_step = 1
			autostart_in_progress = 1
			elapsed_time = 0 				-- reset timer
			check_time = tot_run_time_sec	-- start timer
        end
    end
end


CMD_autoboard = replace_command("sim/operation/auto_board", sim_autoboard_CMDhandler)
CMD_autostart = replace_command("sim/operation/auto_start", sim_autostart_CMDhandler)






----------------------------------- RUNTIME CODE -----------------------------------


-- DO THIS EACH FLIGHT START
function flight_start()
	autoboard_step = 0
	autostart_step = 0
	autoboard_in_progress = 0
	autostart_in_progress = 0
	delay = 0
	check_time = 0
	elapsed_time = 0
end




-- REGULAR RUNTIME
function after_physics()

	------------------------
	-- AUTOBOARD SEQUENCE --
	------------------------
	if (autoboard_step == 1) and (delay == 0) then
		parking_brake_ratio = 1						-- apply full park brake
		delay = 1 run_after_time(reset_delay,0.5)			-- delay
		autoboard_step = 2						-- go to next step

	elseif (autoboard_step == 2) and (delay == 0) then
		if emerg_lt == 0 then
			emerg_ltCMD:once() emerg_ltCMD:once()			-- arm emergency lights
			delay = 1 run_after_time(reset_delay,1.5)
		end
		autoboard_step = 3

	elseif (autoboard_step == 3) and (delay == 0) then
		if xfer_left == 0 then
			xfer_leftCMD:once() xfer_leftCMD:once()			-- fuel transfer left to normal
			delay = 1 run_after_time(reset_delay,0.5)
		end
		autoboard_step = 4

	elseif (autoboard_step == 4) and (delay == 0) then
		if xfer_right == 0 then
			xfer_rightCMD:once() xfer_rightCMD:once()		-- fuel transfer right to normal
			delay = 1 run_after_time(reset_delay,0.5)
		end
		autoboard_step = 5

	elseif (autoboard_step == 5) and (delay == 0) then
		if boost_left > -1 then
			boost_leftCMDdwn:once() boost_leftCMDdwn:once()		-- fuel boost left to normal
			delay = 1 run_after_time(reset_delay,0.5)
		end
		autoboard_step = 6

	elseif (autoboard_step == 6) and (delay == 0) then
		if boost_right > -1 then
			boost_rightCMDdwn:once() boost_rightCMDdwn:once()	-- fuel boost right to normal
			delay = 1 run_after_time(reset_delay,1.5)
		end
		autoboard_step = 7

	elseif (autoboard_step == 7) and (delay == 0) then
		if ign_left > -1 then
			ign_leftCMDdwn:once() ign_leftCMDdwn:once()		-- ignition left to normal
			delay = 1 run_after_time(reset_delay,0.5)
		end
		autoboard_step = 8

	elseif (autoboard_step == 8) and (delay == 0) then
		if ign_right > -1 then
			ign_rightCMDdwn:once() ign_rightCMDdwn:once()		-- ignition right to normal
			delay = 1 run_after_time(reset_delay,1.5)
		end
		autoboard_step = 9

	elseif (autoboard_step == 9) and (delay == 0) then
		if batt_stby == 0 then
			batt_stbyCMD:once() 					-- standby power battery to on
			delay = 1 run_after_time(reset_delay,0.5)
		end
		autoboard_step = 10

	elseif (autoboard_step == 10) and (delay == 0) then
		if batt_left == 0 then
			batt_leftCMD:once() 					-- main battery 1 left to on
			delay = 1 run_after_time(reset_delay,0.5)
		end
		autoboard_step = 11

	elseif (autoboard_step == 11) and (delay == 0) then
		if batt_right == 0 then
			batt_rightCMD:once() 					-- main battery 2 right to on
			delay = 1 run_after_time(reset_delay,1.5)
		end
		autoboard_step = 12

	elseif (autoboard_step == 12) and (delay == 0) then
		if avionics == 0 then
			avionicsCMD:once() 					-- avionics to on
			delay = 1 run_after_time(reset_delay,1)
		end
		autoboard_step = 13

	elseif (autoboard_step == 13) and (delay == 0) then
		if eicas == 0 then
			eicasCMD:once() 					-- avionic eicas to on
			delay = 1 run_after_time(reset_delay,1.5)
		end
		autoboard_step = 14

	elseif (autoboard_step == 14) and (delay == 0) then
		if anti_coll == 0 then
			anti_collCMD:once() 					-- anti collision lights to gnd-rec
			delay = 1 run_after_time(reset_delay,1.5)
		end
		autoboard_step = 15

	elseif (autoboard_step == 15) and (delay == 0) then
		if apu_master == 0 then
			apu_masterCMD:once() 					-- APU master on
			delay = 1 run_after_time(reset_delay,0.5)
		end
		autoboard_step = 16

	elseif (autoboard_step == 16) and (APU_N1_percent < 10) and (delay == 0) then
		if apu_starter < 2 then apu_starterCMDup:start() end		-- APU starter on, keeping it pressed
		autoboard_step = 17

	elseif (autoboard_step == 17) and (APU_N1_percent > 10) or (autoboard_step == 17) and (elapsed_time > 30) then		-- wait until the APU N1 reach 10% or timeover
		apu_starterCMDup:stop()						-- APU starter release
		autoboard_step = 18

	elseif (autoboard_step == 18) and (APU_N1_percent > 99) then		-- wait until the APU N1 reach 99%
		if apu_gen == 0 then
			apu_genCMD:once() 					-- APU generator on
			delay = 1 run_after_time(reset_delay,0.5)
		end
		autoboard_step = 19

	elseif (autoboard_step == 19) and (delay == 0) then
		if apu_bleed == 0 then
			apu_bleedCMD:once() apu_bleedCMD:once()			-- APU bleed air to max
			delay = 1 run_after_time(reset_delay,1.5)
		end
		autoboard_step = 20

	elseif (autoboard_step == 20) and (delay == 0) then
		if ice_pitot_L == 0 then
			ice_pitot_LCMD:once() 					-- anti ice pitot left on
			delay = 1 run_after_time(reset_delay,0.5)
		end
		autoboard_step = 21

	elseif (autoboard_step == 21) and (delay == 0) then
		if ice_pitot_R == 0 then
			ice_pitot_RCMD:once() 					-- anti ice pitot left on
			delay = 1 run_after_time(reset_delay,1.5)
		end
		autoboard_step = 22

	elseif (autoboard_step == 22) and (delay == 0) then
		if anti_coll == 1 then
			anti_collCMD:once() 					-- anti collision lights to both gnd-rec/anti-coll
			delay = 1 run_after_time(reset_delay,0.5)
		end
		autoboard_step = 23

	elseif (autoboard_step == 23) and (delay == 0) then
		if nav == 0 then
			navCMD:once() 						-- navigation lights to on
			delay = 1 run_after_time(reset_delay,0.5)
		end
		autoboard_step = 24

	elseif (autoboard_step == 24) and (delay == 0) then
		if local_time_hours < 6 or local_time_hours > 18 then n = 1 else n = 0 end	-- evaluate if at night or not
		if n == 1 and tail_flood == 0 then
			tail_floodCMD:once()					-- turn on tail logo lights
			delay = 1 run_after_time(reset_delay,1.5)
		end
		autoboard_step = 25

	elseif (autoboard_step == 25) and (delay == 0) then
		if n == 1 and taxi == 0 then
			taxiCMD:once()						-- turn on taxi lights
			delay = 1 run_after_time(reset_delay,0.5)
		end
		autoboard_step = 26

	elseif (autoboard_step == 26) and (delay == 0) then
		if n == 1 and landingL == 0 then
			landingLCMD:once()					-- turn on L landing light
			delay = 1 run_after_time(reset_delay,0.5)
		end
		autoboard_step = 27

	elseif (autoboard_step == 27) and (delay == 0) then
		if n == 1 and landingR == 0 then
			landingRCMD:once()					-- turn on R landing light
			delay = 1 run_after_time(reset_delay,1.5)
		end
		autoboard_step = 28

	elseif (autoboard_step == 28) and (delay == 0) then
		if aux_pump == 0 then
			aux_pumpCMD:once() 					-- turn on auxiliary hydraulic pump
			delay = 1 run_after_time(reset_delay,1.5)
		end
		autoboard_step = 29
		
	elseif (autoboard_step == 29) and (delay == 0) then
		if cabinmaster == 0 then
			cabinmaster_CMD:once() 					-- turn on power to passengers cabin
			delay = 1 run_after_time(reset_delay,1.5)
		end
		autoboard_step = 30

	elseif (autoboard_step == 30) and (delay == 0) then
		-------------------------------------------------
		-- SLOWLY TURN OFF L ENGINE IF ALREADY RUNNING --
		-------------------------------------------------
		if N2_percent_L > 10 or mixture_L > 0 then
			throttle_L = update_slowly(throttle_L,0,2.5)
			mixture_L = update_slowly(mixture_L,0,1.5)
			if mixture_L < 0.1 then
				throttle_L = 0
				mixture_L = 0
			end
		else
			autoboard_step = 31					-- go to the next step
		end

	elseif (autoboard_step == 31) and (delay == 0) then
		-------------------------------------------------
		-- SLOWLY TURN OFF R ENGINE IF ALREADY RUNNING --
		-------------------------------------------------
		if N2_percent_R > 10 or mixture_R > 0 then
			throttle_R = update_slowly(throttle_R,0,2.5)
			mixture_R = update_slowly(mixture_R,0,1.5)
			if mixture_R < 0.1 then
				throttle_R = 0
				mixture_R = 0
			end
		else
			autoboard_step = 32					-- go to the next step
		end

	elseif (autoboard_step == 32) and (delay == 0) then
		clear_master_warningCMD:once()					-- turn off the master warning
		clear_master_cautionCMD:once()					-- turn off the master caution
		autoboard_in_progress = 0					-- autoboard sequence done
		autoboard_step = 999
		check_time = 0								-- stop timer
		
	else
		--nothing
	end



	------------------------
	-- AUTOSTART SEQUENCE --
	------------------------
	if (autostart_step == 1) and (autoboard_step == 0) then			-- run autoboard if it is not already done
		autoboard_step = 1
	end

	if (autostart_step == 1) and (autoboard_step == 999) then		-- only go ahead if autoboard already over
		check_time = (tot_run_time_sec - elapsed_time)				-- resume timer
		------------------------
		-- RIGHT ENGINE START --
		------------------------
		if throttle_R > 0 or mixture_R > 0 then
			throttle_R = update_slowly(throttle_R,0,2.5)
			mixture_R = update_slowly(mixture_R,0,1.5)
			if mixture_R < 0.1 then
				throttle_R = 0
				mixture_R = 0
			end
		else
			autostart_step = 1.5					-- go to the next step
		end

	elseif (autostart_step == 1.5) and (delay == 0) then
		if boost_right <= 0 then
			boost_rightCMDup:once() boost_rightCMDup:once()		-- fuel boost right to on
			delay = 1 run_after_time(reset_delay,0.5)
		end
		autostart_step = 2

	elseif (autostart_step == 2) and (delay == 0) then
		if ign_right <= 0 then
			ign_rightCMDup:once() ign_rightCMDup:once()		-- set the right ignition to on
			delay = 1 run_after_time(reset_delay,1)
		end
		autostart_step = 3

	elseif (autostart_step == 3) and (delay == 0) then
		engage_starter_R_CMD:start()					-- right starter on, keeping it engaged
		autostart_step = 4

	elseif (autostart_step == 4) and (N2_percent_R > 30) then		-- wait until the N2 raise the 30%
		engage_starter_R_CMD:stop()					-- right starter released
		autostart_step = 5

	elseif (autostart_step == 5) and (delay == 0) then
		max_mixture = (gnd_idle + 1)
		mixture_R = update_slowly(mixture_R,1,1.5)			-- slowly open the fuel for the right engine
		if mixture_R > 0.45 * max_mixture then
			mixture_R = 0.5 * max_mixture				-- mixture fully rich
			autostart_step = 6
		end

	elseif (autostart_step == 6) and (delay == 0) then
		if N2_percent_R > 50 then 					-- wait until N2 reach 50%
			autostart_step = 7
		else
			autostart_step = 5					-- back to mixture step if N2 is still low
		end

	elseif (autostart_step == 7) and (delay == 0) then
		if gen_R == 0 then
			gen_RCMD:once()						-- turn on the generator for this engine
			delay = 1 run_after_time(reset_delay,0.5)
		end
		autostart_step = 8

	elseif (autostart_step == 8) and (delay == 0) then
		if boost_right > -1 then
			boost_rightCMDdwn:once() boost_rightCMDdwn:once()	-- set the right fuel boost to norm
			delay = 1 run_after_time(reset_delay,0.5)
		end
		autostart_step = 9

	elseif (autostart_step == 9) and (delay == 0) then
		if ign_right > -1 then
			ign_rightCMDdwn:once() ign_rightCMDdwn:once()		-- set the right ignition to norm
			delay = 1 run_after_time(reset_delay,1.5)
		end
		autostart_step = 10
									
	elseif (autostart_step == 10) and (delay == 0) then
		------------------------
		-- LEFT ENGINE START --
		------------------------
		if throttle_L > 0 or mixture_L > 0 then
			throttle_L = update_slowly(throttle_L,0,2.5)
			mixture_L = update_slowly(mixture_L,0,1.5)
			if mixture_L < 0.1 then
				throttle_L = 0
				mixture_L = 0
			end
		else
			autostart_step = 10.5					-- go to the next step
		end
		
	elseif (autostart_step == 10.5) and (delay == 0) then
		if boost_left <= 0 then
			boost_leftCMDup:once() boost_leftCMDup:once()		-- fuel boost left to on
			delay = 1 run_after_time(reset_delay,0.5)
		end
		autostart_step = 11

	elseif (autostart_step == 11) and (delay == 0) then
		if ign_left <= 0 then
			ign_leftCMDup:once() ign_leftCMDup:once()		-- set the left ignition to on
			delay = 1 run_after_time(reset_delay,1)
		end
		autostart_step = 12

	elseif (autostart_step == 12) and (delay == 0) then
		engage_starter_L_CMD:start()					-- left starter on, keeping it engaged
		autostart_step = 13

	elseif (autostart_step == 13) and (N2_percent_L > 30) then		-- wait until the N2 raise the 30%
		engage_starter_L_CMD:stop()					-- left starter released
		autostart_step = 14

	elseif (autostart_step == 14) and (delay == 0) then
		max_mixture = (gnd_idle + 1)
		mixture_L = update_slowly(mixture_L,1,1.5)			-- slowly open the fuel for the left engine
		if mixture_L > 0.45 * max_mixture then
			mixture_L = 0.5 * max_mixture				-- mixture fully rich
			autostart_step = 15
		end

	elseif (autostart_step == 15) and (delay == 0) then
		if N2_percent_L > 50 then 					-- wait until N2 reach 50%
			autostart_step = 16
		else
			autostart_step = 14					-- back to mixture step if N2 is still low
		end

	elseif (autostart_step == 16) and (delay == 0) then
		if gen_L == 0 then
			gen_LCMD:once()						-- turn on the generator for this engine
			delay = 1 run_after_time(reset_delay,0.5)
		end
		autostart_step = 17

	elseif (autostart_step == 17) and (delay == 0) then
		if boost_left > -1 then
			boost_leftCMDdwn:once() boost_leftCMDdwn:once()		-- set the left fuel boost to norm
			delay = 1 run_after_time(reset_delay,0.5)
		end
		autostart_step = 18

	elseif (autostart_step == 18) and (delay == 0) then
		if ign_left > -1 then
			ign_leftCMDdwn:once() ign_leftCMDdwn:once()		-- set the left ignition to norm
			delay = 1 run_after_time(reset_delay,1.5)
		end
		autostart_step = 19

	elseif (autostart_step == 19) and (delay == 0) then
		------------------------
		--- TURN OFF THE APU ---
		------------------------
		if apu_bleed > 0 then
			apu_bleedCMDdwn:once() apu_bleedCMDdwn:once()		-- APU bleed air to off
			delay = 1 run_after_time(reset_delay,0.5)
		end
		autostart_step = 20

	elseif (autostart_step == 20) and (delay == 0) then
		if apu_gen == 1 then
			apu_genCMDdwn:once() 					-- APU generator off
			delay = 1 run_after_time(reset_delay,0.5)
		end
		autostart_step = 21

	elseif (autostart_step == 21) and (delay == 0) then
		if apu_starter > 0 then
			apu_starterCMDdwn:start()				-- APU starter to stop, keeping it pressed
			delay = 1 run_after_time(reset_delay,1.5)
		end
		autostart_step = 22

	elseif (autostart_step == 22) and (delay == 0) then
		apu_starterCMDdwn:stop()					-- APU stop release
		autostart_step = 23

	elseif (autostart_step == 23) and (APU_N1_percent < 99) then		-- wait until the APU N1 goes below 99%
		if apu_master == 1 then
			--apu_masterCMD:once() 					-- APU master off *** NAH: KEEP IT ON ***
			delay = 1 run_after_time(reset_delay,1)
		end
		autostart_step = 24

	elseif (autostart_step == 24) and (delay == 0) then
		clear_master_warningCMD:once()					-- turn off the master warning
		clear_master_cautionCMD:once()					-- turn off the master caution
		autostart_in_progress = 0					-- autostart sequence done
		autostart_step = 999
		check_time = 0								-- stop timer

	else
		--nothing
	end



	------------------------
	---- RESETTING STEPS ---
	------------------------
	if (autoboard_step == 999) and (autostart_step == 999) then	-- reset both to 0 if both are accomplished
		autoboard_step = 0
		autostart_step = 0
		check_time = 0								-- stop timer
	end



	--------------------------------
	------ TIMER CHECK / RESET -----
	--------------------------------
	if check_time > 0 then
	elapsed_time = (tot_run_time_sec - check_time)
		if elapsed_time > 120 then -- check if autoboard or autostart it's taking more than two minutes then reset anyway
			autoboard_in_progress = 0
			autostart_in_progress = 0
		end
	end
	

end


