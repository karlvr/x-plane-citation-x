
----------------------------------------------------------------------
--
-- DEALING WITH ENGINE START, IGNITION, FADEC, GND-IDLE AND ENG-SYNC
--
-- SEE ALSO THROTTLE SCRIPT MANAGING THE MIXTURE VS THE GND-IDLE-SWITCH
-- LO IDLE IS 0.5 MAX MIXTURE, HI IDLE IS 1.0 MAX MIXTURE
----------------------------------------------------------------------




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


----------------------------------- TIMER FUNCTION
function func_timer()
	timer_starter_L, timer_starter_R = 0, 0
	CitX_starter_STOP = 0
end


------------ EMPTY FUNCTION FOR WRITABLE DATAREF
function do_nothing_func()
	--none
end


------------ LH IGNITION SWITCH FUNCTIONS
function cmd_ignition_switch_L_up(phase,duration)
	if phase == 0 and igniter_on_L_value < 1 then
		igniter_on_L_value = igniter_on_L_value + 1
	end
end
function cmd_ignition_switch_L_dwn(phase,duration)
	if phase == 0 and igniter_on_L_value > -1 then
		igniter_on_L_value = igniter_on_L_value - 1
	end
end


------------ RH IGNITION SWITCH FUNCTIONS
function cmd_ignition_switch_R_up(phase,duration)
	if phase == 0 and igniter_on_R_value < 1 then
		igniter_on_R_value = igniter_on_R_value + 1
	end
end
function cmd_ignition_switch_R_dwn(phase,duration)
	if phase == 0 and igniter_on_R_value > -1 then
		igniter_on_R_value = igniter_on_R_value - 1
	end
end


------------ LH FADEC SWITCH FUNCTIONS
function cmd_fadec_switch_L_up(phase,duration)
	if phase == 1 and duration > 0.1 then fadec_on_L_value = 0 end
	if phase == 2 then fadec_on_L_value = 1 end --> the spring back to "normal"
end
function cmd_fadec_switch_L_dwn(phase,duration)
	if phase == 1 and duration > 0.1 then fadec_on_L_value = 2 end
	if phase == 2 then fadec_on_L_value = 1 end --> the spring back to "normal"
end


------------ RH FADEC SWITCH FUNCTIONS
function cmd_fadec_switch_R_up(phase,duration)
	if phase == 1 and duration > 0.1 then fadec_on_R_value = 0 end
	if phase == 2 then fadec_on_R_value = 1 end --> the spring back to "normal"
end
function cmd_fadec_switch_R_dwn(phase,duration)
	if phase == 1 and duration > 0.1 then fadec_on_R_value = 2 end
	if phase == 2 then fadec_on_R_value = 1 end --> the spring back to "normal"
end


------------ LH STARTER PUSH BUTTON FUNCTION
function cmd_starter_L(phase,duration)
	if phase == 1 and duration > 0.1 and igniter_on_L+auto_igniter_on_L > 0 and bus_volts_L > 20 then
		timer_starter_L = 1
		CitX_starter_STOP = 1
		run_after_time(func_timer,30) --> MAX STARTER DURATION IN SECONDS
	end
end


------------ RH STARTER PUSH BUTTON FUNCTION
function cmd_starter_R(phase,duration)
	if phase == 1 and duration > 0.1 and igniter_on_R+auto_igniter_on_R > 0 and bus_volts_R > 20 then
		timer_starter_R = 1
		CitX_starter_STOP = 1
		run_after_time(func_timer,30) --> MAX STARTER DURATION IN SECONDS
	end
end


------------ DISENGAGE STARTERS PUSH BUTTON FUNCTION
function cmd_starter_STOP(phase,duration)
	if phase == 1 and duration > 0.1 and (bus_volts_L + bus_volts_R) > 20 then
		timer_starter_L, timer_starter_R = 0, 0
		--CitX_starter_STOP = 0
	--else
		--CitX_starter_STOP = 0
	end
end


------------ GND IDLE SWITCH FUNCTIONS
function cmd_gnd_idle_toggle(phase,duration)
	if phase == 0 then
		gnd_idle_value = math.abs(gnd_idle_value - 1)
	end
end


------------ ENG SYNC KNOB FUNCTIONS
function cmd_eng_sync_up(phase,duration)
	if phase == 0 and eng_sync_value == 0 then eng_sync_value = 1 end
	if phase == 0 and eng_sync_value == -1 then eng_sync_value = 0 end
end
function cmd_eng_sync_dwn(phase,duration)
	if phase == 0 and eng_sync_value == 0 then eng_sync_value = -1 end
	if phase == 0 and eng_sync_value == 1 then eng_sync_value = 0 end
end







----------------------------------- LOCATE OR CREATE DATAREFS AND COMMANDS -----------------------------------

bus_volts_L = find_dataref("sim/cockpit2/electrical/bus_volts[1]")
bus_volts_R = find_dataref("sim/cockpit2/electrical/bus_volts[2]")
igniter_on_L = find_dataref("sim/cockpit2/engine/actuators/igniter_on[0]")
igniter_on_R = find_dataref("sim/cockpit2/engine/actuators/igniter_on[1]")
auto_igniter_on_L = find_dataref("sim/cockpit2/engine/actuators/auto_ignite_on[0] ")
auto_igniter_on_R = find_dataref("sim/cockpit2/engine/actuators/auto_ignite_on[1] ")
ignition_key_L = find_dataref("sim/cockpit2/engine/actuators/ignition_key[0]") --> 0 off, 1 left, 2 right, 3 both, 4 starting
ignition_key_R = find_dataref("sim/cockpit2/engine/actuators/ignition_key[1]")
starter_hit_L = find_dataref("sim/cockpit2/engine/actuators/starter_hit[0]")
starter_hit_R = find_dataref("sim/cockpit2/engine/actuators/starter_hit[1]")
N2_percent_L = find_dataref("sim/flightmodel2/engines/N2_percent[0]")
N2_percent_R = find_dataref("sim/flightmodel2/engines/N2_percent[1]")
--engine_is_burning_fuel_L = find_dataref("sim/flightmodel2/engines/engine_is_burning_fuel[0]")
--engine_is_burning_fuel_R = find_dataref("sim/flightmodel2/engines/engine_is_burning_fuel[1]")
fadec_on_L = find_dataref("sim/cockpit2/engine/actuators/fadec_on[0]")
fadec_on_R = find_dataref("sim/cockpit2/engine/actuators/fadec_on[1]")
--idle_speed_L = find_dataref("sim/cockpit2/engine/actuators/idle_speed[0]")
--idle_speed_R = find_dataref("sim/cockpit2/engine/actuators/idle_speed[1]")
jet_sync_mode = find_dataref("sim/cockpit2/switches/jet_sync_mode")
nosegear_on_ground = find_dataref("sim/flightmodel2/gear/on_ground[0]")
mixture_ratio_L = find_dataref("sim/cockpit2/engine/actuators/mixture_ratio[0]")
mixture_ratio_R = find_dataref("sim/cockpit2/engine/actuators/mixture_ratio[1]")
--mixture_ratio_ALL = find_dataref("sim/cockpit2/engine/actuators/mixture_ratio_all")

CitX_ign_switch_L = create_dataref("laminar/CitX/engine/ignition_switch_left","number") --> -1 norm, 0 off, 1 on
igniter_on_L_value = create_dataref("laminar/CitX/engine/ignition_switch_left_term","number") --> -1 norm, 0 off, 1 on
CitX_ign_switch_R = create_dataref("laminar/CitX/engine/ignition_switch_right","number")
igniter_on_R_value = create_dataref("laminar/CitX/engine/ignition_switch_right_term","number")
CitX_fadec_switch_L = create_dataref("laminar/CitX/engine/fadec_switch_left","number") --> 2 select, 1 norm, 0 reset
fadec_on_L_value = create_dataref("laminar/CitX/engine/fadec_switch_left_term","number") --> 2 select, 1 norm, 0 reset
CitX_fadec_switch_R = create_dataref("laminar/CitX/engine/fadec_switch_right","number")
fadec_on_R_value = create_dataref("laminar/CitX/engine/fadec_switch_right_term","number")
CitX_starter_L = create_dataref("laminar/CitX/engine/starter_left","number")
CitX_starter_STOP = create_dataref("laminar/CitX/engine/starter_stop","number")
CitX_starter_R = create_dataref("laminar/CitX/engine/starter_right","number")
CitX_gnd_idle = create_dataref("laminar/CitX/engine/gnd_idle","number") --> 0 norm, 1 high
gnd_idle_value = create_dataref("laminar/CitX/engine/gnd_idle_term","number") --> 0 norm, 1 high
CitX_eng_sync = create_dataref("laminar/CitX/engine/eng_sync","number") --> -1 fan, 0 off, 1 turbine
eng_sync_value = create_dataref("laminar/CitX/engine/eng_sync_term","number") --> -1 fan, 0 off, 1 turbine

cmdignitionswitchLup = create_command("laminar/CitX/engine/cmd_ignition_switch_left_up","Engine ignition LH up",cmd_ignition_switch_L_up)
cmdignitionswitchLdwn = create_command("laminar/CitX/engine/cmd_ignition_switch_left_dwn","Engine ignition LH down",cmd_ignition_switch_L_dwn)
cmdignitionswitchRup = create_command("laminar/CitX/engine/cmd_ignition_switch_right_up","Engine ignition RH up",cmd_ignition_switch_R_up)
cmdignitionswitchRdwn = create_command("laminar/CitX/engine/cmd_ignition_switch_right_dwn","Engine ignition RH down",cmd_ignition_switch_R_dwn)
cmdfadecswitchLup = create_command("laminar/CitX/engine/cmd_fadec_switch_left_up","Engine FADEC LH up",cmd_fadec_switch_L_up)
cmdfadecswitchLdwn = create_command("laminar/CitX/engine/cmd_fadec_switch_left_dwn","Engine FADEC LH down",cmd_fadec_switch_L_dwn)
cmdfadecswitchRup = create_command("laminar/CitX/engine/cmd_fadec_switch_right_up","Engine FADEC LH up",cmd_fadec_switch_R_up)
cmdfadecswitchRdwn = create_command("laminar/CitX/engine/cmd_fadec_switch_right_dwn","Engine FADEC LH down",cmd_fadec_switch_R_dwn)
cmdstarterL = create_command("laminar/CitX/engine/cmd_starter_left","Engine starter LH",cmd_starter_L)
cmdstarterSTOP = create_command("laminar/CitX/engine/cmd_starter_stop","Engine starter disengage",cmd_starter_STOP)
cmdstarterR = create_command("laminar/CitX/engine/cmd_starter_right","Engine starter RH",cmd_starter_R)
cmdgndidletog = create_command("laminar/CitX/engine/cmd_gnd_idle_toggle","Engine ground idle toggle",cmd_gnd_idle_toggle)
cmdengsyncup = create_command("laminar/CitX/engine/cmd_eng_sync_up","Engine sync knob up",cmd_eng_sync_up)
cmdengsyncdwn = create_command("laminar/CitX/engine/cmd_eng_sync_dwn","Engine sync knob down",cmd_eng_sync_dwn)

--replace default xplane commands with the citx ones:
cmd_engage_starter_L = replace_command("sim/starters/engage_starter_1",cmd_starter_L)
cmd_engage_starter_R = replace_command("sim/starters/engage_starter_2",cmd_starter_R)
cmd_starters_shut_down = replace_command("sim/starters/shut_down",cmd_starter_STOP)
cmd_idle_hi_lo_toggle = replace_command("sim/engines/idle_hi_lo_toggle",cmd_gnd_idle_toggle)





--------------------------------- RUNTIME ---------------------------------

-- DO THIS EACH FLIGHT START
function flight_start()
	igniter_on_L_value = -1
	igniter_on_R_value = -1
	fadec_on_L_value, fadec_on_L = 1, 1
	fadec_on_R_value, fadec_on_R = 1, 1
	ignition_key_L = 3
	ignition_key_R = 3
	starter_sequence_L, CitX_starter_L = 0, 0
	starter_sequence_R, CitX_starter_R = 0, 0
	CitX_starter_STOP = 0
	timer_starter_L, timer_starter_R = 0, 0
	CitX_gnd_idle, gnd_idle_value = 0, 0
	eng_sync_value = 0
end


-- REGULAR RUNTIME
function after_physics()

	-- ANIMATE THE LH / RH IGNITION SWITCHES
	if CitX_ign_switch_L ~= igniter_on_L_value then
		CitX_ign_switch_L = func_animate_slowly(igniter_on_L_value, CitX_ign_switch_L, 40)
	end
	if CitX_ign_switch_R ~= igniter_on_R_value then
		CitX_ign_switch_R = func_animate_slowly(igniter_on_R_value, CitX_ign_switch_R, 40)
	end
	-- SYSTEM:
	if igniter_on_L_value == 1 then
		igniter_on_L = 1 auto_igniter_on_L = 0 --> ON
	elseif igniter_on_L_value == 0 then
		igniter_on_L = 0 auto_igniter_on_L = 0 --> OFF
	else
		igniter_on_L = 0 auto_igniter_on_L = 1 --> NORM
	end
	if igniter_on_R_value == 1 then
		igniter_on_R = 1 auto_igniter_on_R = 0 --> ON
	elseif igniter_on_R_value == 0 then
		igniter_on_R = 0 auto_igniter_on_R = 0 --> OFF
	else
		igniter_on_R = 0 auto_igniter_on_R = 1 --> NORM
	end
	-----------------------------


	-- ANIMATE THE LH / RH FADEC SWITCHES
	if CitX_fadec_switch_L ~= fadec_on_L_value then
		CitX_fadec_switch_L = func_animate_slowly(fadec_on_L_value, CitX_fadec_switch_L, 40)
	end
	if CitX_fadec_switch_R ~= fadec_on_R_value then
		CitX_fadec_switch_R = func_animate_slowly(fadec_on_R_value, CitX_fadec_switch_R, 40)
	end
	-- SYSTEM:
	if fadec_on_L_value > 0 then fadec_on_L = 1 else fadec_on_L = 0 end
	if fadec_on_R_value > 0 then fadec_on_R = 1 else fadec_on_R = 0 end
	-----------------------------


	-- STARTER SEQUENCE LH
	if N2_percent_L > 40 then timer_starter_L = 0 end --> STOP STARTER AT 40% N2
	CitX_starter_L = timer_starter_L
	ignition_key_L = 4 * timer_starter_L
	-----------------------------


	-- STARTER SEQUENCE RH
	if N2_percent_R > 40 then timer_starter_R = 0 end --> STOP STARTER AT 40% N2
	CitX_starter_R = timer_starter_R
	ignition_key_R = 4 * timer_starter_R
	-----------------------------


	-- STARTER DISENGAGE ON OR OFF
	CitX_starter_STOP = math.max(timer_starter_L, timer_starter_R)
	-----------------------------


	-- ANIMATE THE LOW OR HIGH GND IDLE SWITCH
	if CitX_gnd_idle ~= gnd_idle_value then
		CitX_gnd_idle = func_animate_slowly(gnd_idle_value, CitX_gnd_idle, 40)
		-- UPDATE TO HI, IF IT WAS IN LO:
		if mixture_ratio_L >= 0.5 then mixture_ratio_L = 1 end
		if mixture_ratio_R >= 0.5 then mixture_ratio_R = 1 end
	end
	-- SYSTEM FOR LO GND IDLE:
	if nosegear_on_ground == 1 and gnd_idle_value == 0 then
		if mixture_ratio_L > 0.5 then mixture_ratio_L = 0.5 end
		if mixture_ratio_R > 0.5 then mixture_ratio_R = 0.5 end
	end
	-----------------------------


	-- ANIMATE THE ENGINE SYNC KNOB
	if CitX_eng_sync ~= eng_sync_value then
		CitX_eng_sync = func_animate_slowly(eng_sync_value, CitX_eng_sync, 20)
	end
	-- SYSTEM:
	if eng_sync_value == -1 then
		jet_sync_mode = 0
	elseif eng_sync_value == 0 then
		jet_sync_mode = 1
	elseif eng_sync_value == 1 then
		jet_sync_mode = 2
	end
	-----------------------------

end


