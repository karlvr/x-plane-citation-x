
-------------------------------------------------------------------------------------
-- THIS SCRIPT IS HERE FOR THE ELECTRICAL DC, AVIONICS AND STANDBY POWER SYSTEM
--
-- BUS 0: STBYPWR BUS --> BATTERY [0]
-- BUS 1: MAIN DC LEFT/RIGHT SIDES --> APU / EXTERNALPWR / GENERATORS [0 / 1]
-- BUS 2: ESSENTIAL DC LEFT/RIGHT SIDES --> BATTERIES [1 / 2]
--
-- -----------   -----------             -----------  
-- | BUS[0]  |   | BUS[1]  |             | BUS[2]  |   
-- | STBY    |   | MAIN    |             | ESSENT  |   
-- -----------   -----------             -----------   
--      |             |                       |        
--      |             |       LOAD SHED       |        
--      |             |           |           |        
--      |-----/*/-----|----------/*/----------|
--      |             |      (cross-tie)      |        
--      |             |                       |        
--    BAT[0]        GEN[0]                  BAT[1]     
-- 					  |                       |
--                  GEN[1]                  BAT[2] 
-- 					  |
--   		   APU and EXT-PWR
--
-- /*/Cross-tie: manually set by the LOAD SHED SWITCH or automatic, see bottom of this script
-- Inverters: not used
-------------------------------------------------------------------------------------




----------------------------------- LOCATE DATAREFS -----------------------------------

startup_running = find_dataref("sim/operation/prefs/startup_running")
bus_volts_STBY = find_dataref("sim/cockpit2/electrical/bus_volts[0]")
bus_volts_MAIN = find_dataref("sim/cockpit2/electrical/bus_volts[1]")
bus_volts_ESSNTL = find_dataref("sim/cockpit2/electrical/bus_volts[2]")
--bus_volts_EMER = find_dataref("sim/cockpit2/electrical/bus_volts[3]")
--inverter_on_L = find_dataref("sim/cockpit2/electrical/inverter_on[0]")
--inverter_on_R = find_dataref("sim/cockpit2/electrical/inverter_on[1]")
battery_on_STBY = find_dataref("sim/cockpit2/electrical/battery_on[0]")
battery_on_L = find_dataref("sim/cockpit2/electrical/battery_on[1]")
battery_on_R = find_dataref("sim/cockpit2/electrical/battery_on[2]")
batt_volts_STBY = find_dataref("sim/cockpit2/electrical/battery_voltage_actual_volts[0]")
batt_volts_L = find_dataref("sim/cockpit2/electrical/battery_voltage_actual_volts[1]")
batt_volts_R = find_dataref("sim/cockpit2/electrical/battery_voltage_actual_volts[2]")
batt_amps_STBY = find_dataref("sim/cockpit2/electrical/battery_amps[0]")
--batt_amps_MAIN = find_dataref("sim/cockpit2/electrical/battery_amps[1]")
--batt_amps_ESSNTL = find_dataref("sim/cockpit2/electrical/battery_amps[2]")
generator_on_L = find_dataref("sim/cockpit2/electrical/generator_on[0]")
generator_on_R = find_dataref("sim/cockpit2/electrical/generator_on[1]")
avionics_power = find_dataref("sim/cockpit2/switches/avionics_power_on")
avionics_eicas = find_dataref("sim/cockpit2/switches/gnd_com_power_on") --> new dataref from Philipp: it's a ground avionics bypass switch to conserve battery power
generator_amps_L = find_dataref("sim/cockpit2/electrical/generator_amps[0]")
generator_amps_R = find_dataref("sim/cockpit2/electrical/generator_amps[1]")
generator_on_APU = find_dataref("sim/cockpit2/electrical/APU_generator_on")
generator_amps_APU = find_dataref("sim/cockpit2/electrical/APU_generator_amps")
generator_on_GPU = find_dataref("sim/cockpit/electrical/gpu_on")
generator_amps_GPU = find_dataref("sim/cockpit/electrical/gpu_amps")
cross_tie = find_dataref("sim/cockpit2/electrical/cross_tie")
gear_on_ground = find_dataref("sim/flightmodel2/gear/on_ground[0]") --> nose gear on ground
tire_rotation_speed = find_dataref("sim/flightmodel2/gear/tire_rotation_speed_rad_sec[0]") --> nose gear tire rotation




------------------------------ DATAREFS AND COMMANDS FUNCTIONS -----------------------------

----------------------------------- STANDBY FACTOR
function evaluate_stby_factor()
	-- EVALUATE THE STBY FACTOR TO SHUTOFF ALL INSTR LIGHTS EXCEPT STBY ONES IF NO PWR BUT STBY IS ON
	-- (SEE LIGHTS_COCKPIT SCRIPT)
	if bus_volts_STBY > 0 and bus_volts_MAIN + bus_volts_ESSNTL == 0 then
		STBY_lights_factor = 0 --> all instr light except stby ones will be 0 = off
	elseif bus_volts_STBY == 0 and bus_volts_MAIN + bus_volts_ESSNTL == 0 then
		STBY_lights_factor = 0 --> all instr light except stby ones will be 0 = off
	else
		STBY_lights_factor = 1 --> all instr light will be 1 = on
	end
end

----------------------------------- LOAD SHED SWITCH UP/DWN
function cmd_load_shed_up(phase, duration)
	if phase == 0 and load_shed_value <= 0 then load_shed_value = load_shed_value + 1 end
	--if phase == 1 and duration > 0.1 then load_shed_value = 1 end
	--if phase == 2 then load_shed_value = 0 end --> the spring back to "normal"
	--evaluate_stby_factor()
end
function cmd_load_shed_dwn(phase, duration)
	if phase == 0 and load_shed_value >= 0 then load_shed_value = load_shed_value - 1 end
	--if phase == 1 and duration > 0.1 then load_shed_value = -1 end
	--if phase == 2 then load_shed_value = 0 end --> the spring back to "normal"
	--evaluate_stby_factor()
end

----------------------------------- LEFT GENERATOR SWITCH UP/DWN
function cmd_generator_left_up(phase, duration)
	if phase == 0 and generator_left_value == 0 then generator_left_value = 1 end
	--evaluate_stby_factor()
end
function cmd_generator_left_dwn(phase, duration)
	if phase == 0 then generator_left_value = math.max(-1, generator_left_value - 1) end
	if phase == 2 and generator_left_value == -1 then generator_left_value = 0 end --> the spring back to "off"
	--evaluate_stby_factor()
end

----------------------------------- RIGHT GENERATOR SWITCH UP/DWN
function cmd_generator_right_up(phase, duration)
	if phase == 0 and generator_right_value == 0 then generator_right_value = 1 end
	--evaluate_stby_factor()
end
function cmd_generator_right_dwn(phase, duration)
	if phase == 0 then generator_right_value = math.max(-1, generator_right_value - 1) end
	if phase == 2 and generator_right_value == -1 then generator_right_value = 0 end --> the spring back to "off"
	--evaluate_stby_factor()
end

----------------------------------- LEFT BATTERY SWITCH UP/DWN
function cmd_battery_left_toggle(phase, duration)
	if phase == 0 then
		battery_left_value = math.abs(battery_left_value - 1)
		--evaluate_stby_factor()
	end
end

function cmd_battery_left_on(phase, duration)
	if phase == 0 then
		battery_left_value = 1
	end
end

function cmd_battery_left_off(phase, duration)
	if phase == 0 then
		battery_left_value = 0
	end
end

----------------------------------- RIGHT BATTERY SWITCH UP/DWN
function cmd_battery_right_toggle(phase, duration)
	if phase == 0 then
		battery_right_value = math.abs(battery_right_value - 1)
		--evaluate_stby_factor()
	end
end

function cmd_battery_right_on(phase, duration)
	if phase == 0 then
		battery_right_value = 1
	end
end

function cmd_battery_right_off(phase, duration)
	if phase == 0 then
		battery_right_value = 0
	end
end

----------------------------------- EXTERNAL PWR (GPU) SWITCH UP/DWN
function cmd_ext_pwr_toggle(phase, duration)
	if phase == 0 then
		ext_pwr_value = math.abs(ext_pwr_value - 1)
		--evaluate_stby_factor()
	end
end

----------------------------------- AVIONICS SWITCH UP/DWN
function cmd_avionics_toggle(phase, duration)
	if phase == 0 then
		avionics_value = math.abs(avionics_value - 1)
	end
end

function cmd_avionics_on(phase, duration)
	if phase == 0 then
		avionics_value = 1
	end
end

function cmd_avionics_off(phase, duration)
	if phase == 0 then
		avionics_value = 0
	end
end

----------------------------------- AVIONICS EICAS SWITCH UP/DWN
function cmd_avionics_eicas_toggle(phase, duration)
	if phase == 0 then
		avionics_eicas_value = math.abs(avionics_eicas_value - 1)
	end
end

function cmd_avionics_eicas_on(phase, duration)
	if phase == 0 then
		avionics_eicas_value = 1
	end
end

function cmd_avionics_eicas_off(phase, duration)
	if phase == 0 then
		avionics_eicas_value = 0
	end
end

----------------------------------- STANDBY POWER SWITCH UP/DWN
function cmd_stby_pwr_up(phase, duration)
	if phase == 0 and stby_pwr_value == 0 then stby_pwr_value = 1 end
	--evaluate_stby_factor()
end
function cmd_stby_pwr_dwn(phase, duration)
	if phase == 0 then stby_pwr_value = math.max(-1, stby_pwr_value - 1) end
	if phase == 2 and stby_pwr_value == -1 then stby_pwr_value = 0 end --> the spring back to "off"
	--evaluate_stby_factor()
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
function func_cross_tie_timer()
	cross_tie = 0
end

----------------------------------- EMPTY FUNCTION FOR WRITABLE DATAREF
function func_do_nothing()
		--nothing
end





----------------------------------- CREATE DATAREFS AND COMMANDS -----------------------------------

CitX_load_shed = create_dataref("laminar/CitX/electrical/load_shed","number") --> -1 emer, 0 norm, 1 o'ride
load_shed_value = create_dataref("laminar/CitX/electrical/load_shed_term","number") --> -1 emer, 0 norm, 1 o'ride
CitX_generator_left = create_dataref("laminar/CitX/electrical/generator_left","number") --> -1 reset, 0 off, 1 on
generator_left_value = create_dataref("laminar/CitX/electrical/generator_left_term","number") --> -1 reset, 0 off, 1 on
CitX_generator_right = create_dataref("laminar/CitX/electrical/generator_right","number") --> -1 reset, 0 off, 1 on
generator_right_value = create_dataref("laminar/CitX/electrical/generator_right_term","number") --> -1 reset, 0 off, 1 on
CitX_battery_left = create_dataref("laminar/CitX/electrical/battery_left","number")
battery_left_value = create_dataref("laminar/CitX/electrical/battery_left_term","number")
CitX_battery_right = create_dataref("laminar/CitX/electrical/battery_right","number")
battery_right_value = create_dataref("laminar/CitX/electrical/battery_right_term","number")
CitX_battery_stby_pwr = create_dataref("laminar/CitX/electrical/battery_stby_pwr","number") --> -1 test, 0 off, 1 on
stby_pwr_value = create_dataref("laminar/CitX/electrical/battery_stby_pwr_term","number") --> -1 test, 0 off, 1 on
CitX_battery_stby_test_led = create_dataref("laminar/CitX/electrical/battery_stby_test_led","number")
CitX_battery_stby_pwr_led = create_dataref("laminar/CitX/electrical/battery_stby_pwr_led","number")
CitX_avionics = create_dataref("laminar/CitX/electrical/avionics","number")
avionics_value = create_dataref("laminar/CitX/electrical/avionics_term","number")
CitX_avionics_eicas = create_dataref("laminar/CitX/electrical/avionics_eicas","number")
avionics_eicas_value = create_dataref("laminar/CitX/electrical/avionics_eicas_term","number")
CitX_ext_pwr = create_dataref("laminar/CitX/electrical/ext_pwr","number")
ext_pwr_value = create_dataref("laminar/CitX/electrical/ext_pwr_term","number")
STBY_lights_factor = create_dataref("laminar/CitX/electrical/STBY_lights_factor","number") --> USED FOR STANDBY LIGHTS IN LIGHTS_COCKPIT SCRIPT <--

cmdloadshedup = create_command("laminar/CitX/electrical/cmd_load_shed_up","Load shed switch up",cmd_load_shed_up)
cmdloadsheddwn = create_command("laminar/CitX/electrical/cmd_load_shed_dwn","Load shed switch down",cmd_load_shed_dwn)
cmdgenerLup = create_command("laminar/CitX/electrical/cmd_generator_left_up","Generator L switch up",cmd_generator_left_up)
cmdgenerLdwn = create_command("laminar/CitX/electrical/cmd_generator_left_dwn","Generator L switch down",cmd_generator_left_dwn)
cmdgenerRup = create_command("laminar/CitX/electrical/cmd_generator_right_up","Generator R switch up",cmd_generator_right_up)
cmdgenerRdwn = create_command("laminar/CitX/electrical/cmd_generator_right_dwn","Generator R switch down",cmd_generator_right_dwn)
cmdbatteryLtog = create_command("laminar/CitX/electrical/cmd_battery_left_toggle","Battery L switch toggle",cmd_battery_left_toggle)
cmdbatteryRtog = create_command("laminar/CitX/electrical/cmd_battery_right_toggle","Battery R switch toggle",cmd_battery_right_toggle)
cmdextpwrtog = create_command("laminar/CitX/electrical/cmd_ext_pwr_toggle","External Power switch toggle",cmd_ext_pwr_toggle)
cmdstbypwrup = create_command("laminar/CitX/electrical/cmd_stby_pwr_up","Standby power switch up",cmd_stby_pwr_up)
cmdstbypwrdwn = create_command("laminar/CitX/electrical/cmd_stby_pwr_dwn","Standby power switch down",cmd_stby_pwr_dwn)
cmdavionicstog = create_command("laminar/CitX/electrical/cmd_avionics_toggle","Avionics switch toggle",cmd_avionics_toggle)
create_command("laminar/CitX/electrical/cmd_avionics_on","Avionics switch on",cmd_avionics_on)
create_command("laminar/CitX/electrical/cmd_avionics_off","Avionics switch off",cmd_avionics_off)
replace_command("sim/systems/avionics_on",cmd_avionics_on)
replace_command("sim/systems/avionics_off",cmd_avionics_off)
cmdavionicseicastog = create_command("laminar/CitX/electrical/cmd_avionics_eicas_toggle","Avionics EICAS switch toggle",cmd_avionics_eicas_toggle)
create_command("laminar/CitX/electrical/cmd_avionics_eicas_on","Avionics EICAS switch on",cmd_avionics_eicas_on)
create_command("laminar/CitX/electrical/cmd_avionics_eicas_off","Avionics EICAS switch off",cmd_avionics_eicas_off)
replace_command("sim/systems/gnd_com_power_on",cmd_avionics_eicas_on)
replace_command("sim/systems/gnd_com_power_off",cmd_avionics_eicas_off)


-- Extra commands for simpits (XPD-13818), not used here.
create_command("laminar/CitX/electrical/cmd_battery_left_on","Battery L switch on", cmd_battery_left_on)
create_command("laminar/CitX/electrical/cmd_battery_left_off","Battery L switch off", cmd_battery_left_off)
create_command("laminar/CitX/electrical/cmd_battery_right_on","Battery R switch on", cmd_battery_right_on)
create_command("laminar/CitX/electrical/cmd_battery_right_off","Battery R switch off", cmd_battery_right_off)

replace_command("sim/electrical/battery_1_on",cmd_battery_left_on)
replace_command("sim/electrical/battery_1_off",cmd_battery_left_off)
replace_command("sim/electrical/battery_2_on",cmd_battery_right_on)
replace_command("sim/electrical/battery_2_off",cmd_battery_right_off)

--------------------------------- DO THIS EACH FLIGHT START ---------------------------------
function flight_start()

	--inverter_on_L = 1
	--inverter_on_R = 1
	cross_tie = 0
	load_shed_value = 0
	load_shed_on = 0
	generator_left_value = generator_on_L
	generator_right_value = generator_on_R
	battery_left_value = battery_on_L
	battery_right_value = battery_on_R
	stby_pwr_value = startup_running
	battery_on_STBY = 0
	avionics_value = avionics_power * startup_running
	avionics_eicas_value = avionics_value
	avionics_eicas = avionics_value
	ext_pwr_value = generator_on_GPU
	STBY_lights_factor = 0

end




--------------------------------- REGULAR RUNTIME ---------------------------------
function after_physics()

	-- LOAD SHED -- (it set cross-tie at the bottom of this script)
	-- SLOWLY ANIMATE SWITCH
	if CitX_load_shed ~= load_shed_value then
		CitX_load_shed = func_animate_slowly(load_shed_value, CitX_load_shed, 40)
	end
	-----------------


	-- GENERATOR LEFT --
	-- SLOWLY ANIMATE SWITCH:
	if CitX_generator_left ~= generator_left_value then
		CitX_generator_left = func_animate_slowly(generator_left_value, CitX_generator_left, 40)
	end
	-- SYSTEM LOGIC:
	if generator_left_value == 1 then generator_on_L = 1 else generator_on_L = 0 end
	if generator_left_value == -1 then generator_on_L = 0 end
	-----------------


	-- GENERATOR RIGHT --
	-- SLOWLY ANIMATE SWITCH:
	if CitX_generator_right ~= generator_right_value then
		CitX_generator_right = func_animate_slowly(generator_right_value, CitX_generator_right, 40)
	end
	-- SYSTEM LOGIC:
	if generator_right_value == 1 then generator_on_R = 1 else generator_on_R = 0 end
	if generator_right_value == -1 then generator_on_R = 0 end
	-----------------


	-- BATTERY LEFT --
	-- SLOWLY ANIMATE SWITCH:
	if CitX_battery_left ~= battery_left_value then
		CitX_battery_left = func_animate_slowly(battery_left_value, CitX_battery_left, 40)
	end
	-- SYSTEM LOGIC:
	if battery_left_value == 1 then battery_on_L = 1 else battery_on_L = 0 end
	-----------------


	-- BATTERY RIGHT --
	-- SLOWLY ANIMATE SWITCH:
	if CitX_battery_right ~= battery_right_value then
		CitX_battery_right = func_animate_slowly(battery_right_value, CitX_battery_right, 40)
	end
	-- SYSTEM LOGIC:
	if battery_right_value == 1 then battery_on_R = 1 else battery_on_R = 0 end
	-----------------


	-- EXTERNAL PWR (GPU) --
	-- SLOWLY ANIMATE SWITCH:
	if CitX_ext_pwr ~= ext_pwr_value then
		CitX_ext_pwr = func_animate_slowly(ext_pwr_value, CitX_ext_pwr, 40)
	end
	-- SYSTEM LOGIC:
	if ext_pwr_value == 1 then
		if gear_on_ground == 1 and tire_rotation_speed < 0.1 then generator_on_GPU = 1 else generator_on_GPU = 0 end
	else
		generator_on_GPU = 0
	end
	-----------------


	-- AVIONICS --
	-- SLOWLY ANIMATE SWITCH:
	if CitX_avionics ~= avionics_value then
		CitX_avionics = func_animate_slowly(avionics_value, CitX_avionics, 40)
	end
	-- SYSTEM LOGIC:
	if avionics_value == 1 then avionics_power = 1 else avionics_power = 0 end
	-----------------


	-- AVIONICS EICAS --
	-- SLOWLY ANIMATE SWITCH:
	if CitX_avionics_eicas ~= avionics_eicas_value then
		CitX_avionics_eicas = func_animate_slowly(avionics_eicas_value, CitX_avionics_eicas, 40)
	end
	-- SYSTEM LOGIC:
	if avionics_eicas_value == 1 then avionics_eicas = 1 else avionics_eicas = 0 end
	-----------------


	-- BATTERY STANDBY --
	-- SLOWLY ANIMATE SWITCH:
	if CitX_battery_stby_pwr ~= stby_pwr_value then
		CitX_battery_stby_pwr = func_animate_slowly(stby_pwr_value, CitX_battery_stby_pwr, 40)
	end
	-- SYSTEM LOGIC:
	if stby_pwr_value == 1 then battery_on_STBY = 1 else battery_on_STBY = 0 end
	-- LED LOGIC:
	if stby_pwr_value == 1 and bus_volts_STBY > 0 and batt_amps_STBY < -3 then CitX_battery_stby_pwr_led = 1 else CitX_battery_stby_pwr_led = 0 end
	if stby_pwr_value == -1 and batt_volts_STBY > 20 then CitX_battery_stby_test_led = 1 else CitX_battery_stby_test_led = 0 end
	-----------------


	-- ****** CROSS-TIE LOGIC ****** --
	-- ALWAYS ON WHEN LOAD SHED IS SET TO "O'RIDE"
	-- ALWAYS OFF WHEN LOAD SHED IS SET TO "EMER"
	-- ON OR OFF AUTOMATICALLY WHEN LOAD SHED SWITCH IS SET TO "NORM" AS FOLLOWS:
	---> NORMALLY OFF UNTIL SOME ENGINE GENERATOR, APU OR GPU SEND PWR TO THE MAIN BUS (bus1)
	---> IF IN THE AIR, A 70 SEC TIMER START BEFORE TURN IT OFF IF NO PWR ON THE SAME MAIN BUS
	--
	-- EVALUATE THE LOAD SHED CROSS-TIE ON OR OFF (O'RIDE/NORM/EMER):
	if load_shed_value == 1 then -- O'RIDE
		cross_tie = 1
	elseif load_shed_value == 0 then -- NORMAL
		if generator_amps_L+generator_amps_R+generator_amps_APU+generator_amps_GPU < 1 then
			if gear_on_ground == 1 then -- if on ground cross_tie off immediately
				cross_tie = 0
			else -- if in the air cross_tie off after 70 sec
				if cross_tie == 1 and is_timer_scheduled(func_cross_tie_timer) == false then
					run_after_time(func_cross_tie_timer,70)
				end
			end
		else
			cross_tie = 1
		end
	elseif load_shed_value == -1 then  -- EMER
		cross_tie = 0
	else
		--none
	end
	-----------------


	-- EVALUATE THE STBY FACTOR TO SHUTOFF ALL INSTR LIGHTS EXCEPT STBY ONES IF NO PWR BUT STBY IS ON
	-- (SEE LIGHTS_COCKPIT SCRIPT)
	evaluate_stby_factor()

end

