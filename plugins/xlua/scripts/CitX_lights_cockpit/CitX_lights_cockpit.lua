
---------------------------------------------------------------------------------
-- THIS SCRIPT IS HERE FOR THE COCKPIT LIGHTING SYSTEM
--
-- FLOOD KNOB: PANEL[0]
-- MAP L KNOB: PANEL[1]
-- MAP R KNOB: PANEL[2]
-- EL KNOB: INSTR[0] (as STBY instr) and INSTR[20] (as all other instr, affected also by dim switch)
-- LH KNOB: INSTR[1] (affected also by dim switch)
-- RH KNOB: INSTR[2] (affected also by dim switch)
-- CTR KNOB: INSTR[3] (affected also by dim switch)
-- OVERHEAD MONITOR: INSTR[4]
-- YOKE PILOT L: INSTR[5]
-- YOKE COPILOT R: INSTR[6]
--
-- PRIMUS PFD1 KNOB: INSTR[7] ---|
-- PRIMUS MFD1 KNOB: INSTR[8]    |
-- PRIMUS EICAS KNOB: INSTR[9]   |
-- PRIMUS MFD2 KNOB: INSTR[10]   |
-- PRIMUS PFD2 KNOB: INSTR[11]   |---> NOT HERE: SEE PRIMUS SCRIPT
-- CDU1: INSTR[12]               |
-- CDU2: INSTR[13]               |
-- PRIMUS RMU1: INSTR[14]        |
-- PRIMUS RMU2: INSTR[15] -------|
--
-- AUX KNOB: EMERGENCY LIGHTS USE CUSTOM DATAREF
--
-- PASSENGERS CABIN LIGHTS: INSTR[31] (see LIGHTS script)
--
-- (PS: FOR STBY INSTR LIGHTING SEE ALSO STANDBY_INSTR SCRIPT)
---------------------------------------------------------------------------------



----------------------------------- LOCATE DATAREFS -----------------------------------

startup_running = find_dataref("sim/operation/prefs/startup_running")
bus_volts_STBY = find_dataref("sim/cockpit2/electrical/bus_volts[0]")
bus_volts_L = find_dataref("sim/cockpit2/electrical/bus_volts[1]")
bus_volts_R = find_dataref("sim/cockpit2/electrical/bus_volts[2]")
brightness_FLOOD = find_dataref("sim/cockpit2/switches/panel_brightness_ratio[0]")
brightness_EL_STBY = find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[0]")
brightness_EL = find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[20]")
brightness_LH = find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[1]")
brightness_RH = find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[2]")
brightness_CTR = find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[3]")
brightness_MAP_L = find_dataref("sim/cockpit2/switches/panel_brightness_ratio[1]")
brightness_MAP_R = find_dataref("sim/cockpit2/switches/panel_brightness_ratio[2]")
brightness_MONITOR = find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[4]")
brightness_YOKE_L = find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[5]")
brightness_YOKE_R = find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[6]")
--avionics_power = find_dataref("sim/cockpit2/switches/avionics_power_on")
local_time_h = find_dataref("sim/cockpit2/clock_timer/local_time_hours")
g_axil = find_dataref("sim/flightmodel/forces/g_axil")

STBY_lights_factor = find_dataref("laminar/CitX/electrical/STBY_lights_factor") -- from the electrical script



------------------------------ DATAREFS AND COMMANDS FUNCTIONS -----------------------------

----------------------------------- FLOOD KNOB UP/DWN
function cmd_flood_knob_up(phase, duration)
	if flood_knob < 1 then
		if phase == 0 then flood_knob = flood_knob + 0.05 end
		if phase == 1 and duration > 0.5 then flood_knob = flood_knob + 0.01 end
		brightness_FLOOD = flood_knob
	end
end
function cmd_flood_knob_dwn(phase, duration)
	if flood_knob > 0 then
		if phase == 0 then flood_knob = flood_knob - 0.05 end
		if phase == 1 and duration > 0.5 then flood_knob = flood_knob - 0.01 end
		brightness_FLOOD = flood_knob
	end
end

----------------------------------- ELECTRIC KNOB UP/DWN
function cmd_elec_knob_up(phase, duration)
	if elec_knob < 1 then
		if phase == 0 then elec_knob = elec_knob + 0.05 end
		if phase == 1 and duration > 0.5 then elec_knob = elec_knob + 0.01 end
		brightness_EL_STBY = elec_knob
		brightness_EL = elec_knob
	end
end
function cmd_elec_knob_dwn(phase, duration)
	if elec_knob > 0 then
		if phase == 0 then elec_knob = elec_knob - 0.05 end
		if phase == 1 and duration > 0.5 then elec_knob = elec_knob - 0.01 end
		brightness_EL_STBY = elec_knob
		brightness_EL = elec_knob
	end
end

----------------------------------- LEFT KNOB UP/DWN
function cmd_left_knob_up(phase, duration)
	if left_knob < 1 then
		if phase == 0 then left_knob = left_knob + 0.05 end
		if phase == 1 and duration > 0.5 then left_knob = left_knob + 0.01 end
		brightness_LH = left_knob
	end
end
function cmd_left_knob_dwn(phase, duration)
	if left_knob > 0 then
		if phase == 0 then left_knob = left_knob - 0.05 end
		if phase == 1 and duration > 0.5 then left_knob = left_knob - 0.01 end
		brightness_LH = left_knob
	end
end

----------------------------------- RIGHT KNOB UP/DWN
function cmd_right_knob_up(phase, duration)
	if right_knob < 1 then
		if phase == 0 then right_knob = right_knob + 0.05 end
		if phase == 1 and duration > 0.5 then right_knob = right_knob + 0.01 end
		brightness_RH = right_knob
	end
end
function cmd_right_knob_dwn(phase, duration)
	if right_knob > 0 then
		if phase == 0 then right_knob = right_knob - 0.05 end
		if phase == 1 and duration > 0.5 then right_knob = right_knob - 0.01 end
		brightness_RH = right_knob
	end
end

----------------------------------- CTR KNOB UP/DWN
function cmd_ctr_knob_up(phase, duration)
	if ctr_knob < 1 then
		if phase == 0 then ctr_knob = ctr_knob + 0.05 end
		if phase == 1 and duration > 0.5 then ctr_knob = ctr_knob + 0.01 end
		brightness_CTR = ctr_knob
	end
end
function cmd_ctr_knob_dwn(phase, duration)
	if ctr_knob > 0 then
		if phase == 0 then ctr_knob = ctr_knob - 0.05 end
		if phase == 1 and duration > 0.5 then ctr_knob = ctr_knob - 0.01 end
		brightness_CTR = ctr_knob
	end
end

----------------------------------- MAP LEFT KNOB UP/DWN
function cmd_map_left_knob_up(phase, duration)
	if map_left_knob < 1 then
		if phase == 0 then map_left_knob = map_left_knob + 0.05 end
		if phase == 1 and duration > 0.5 then map_left_knob = map_left_knob + 0.01 end
		brightness_MAP_L = map_left_knob
	end
end
function cmd_map_left_knob_dwn(phase, duration)
	if map_left_knob > 0 then
		if phase == 0 then map_left_knob = map_left_knob - 0.05 end
		if phase == 1 and duration > 0.5 then map_left_knob = map_left_knob - 0.01 end
		brightness_MAP_L = map_left_knob
	end
end

----------------------------------- MAP RIGHT KNOB UP/DWN
function cmd_map_right_knob_up(phase, duration)
	if map_right_knob < 1 then
		if phase == 0 then map_right_knob = map_right_knob + 0.05 end
		if phase == 1 and duration > 0.5 then map_right_knob = map_right_knob + 0.01 end
		brightness_MAP_R = map_right_knob
	end
end
function cmd_map_right_knob_dwn(phase, duration)
	if map_right_knob > 0 then
		if phase == 0 then map_right_knob = map_right_knob - 0.05 end
		if phase == 1 and duration > 0.5 then map_right_knob = map_right_knob - 0.01 end
		brightness_MAP_R = map_right_knob
	end
end

----------------------------------- OVERHEAD MONITOR BUTTON TOGGLE
function cmd_monitor_button_toggle(phase, duration)
	if phase == 0 then
		monitor_button = math.abs(monitor_button - 1) -- toggle from 0 to 1
	end
end

----------------------------------- AUX KNOB UP/DWN
function cmd_aux_knob_up(phase, duration)
	if aux_knob < 1 then
		if phase == 0 then aux_knob = aux_knob + 0.05 end
		if phase == 1 and duration > 0.5 then aux_knob = aux_knob + 0.01 end
	end
end
function cmd_aux_knob_dwn(phase, duration)
	if aux_knob > 0 then
		if phase == 0 then aux_knob = aux_knob - 0.05 end
		if phase == 1 and duration > 0.5 then aux_knob = aux_knob - 0.01 end
	end
end

----------------------------------- AUX EMERGENCY SWITCH UP/DWN
function cmd_emerg_light_switch_up(phase, duration)
	if phase == 0 and emerg_currently < 2 then
		emerg_currently = emerg_currently + 1
	end
end
function cmd_emerg_light_switch_dwn(phase, duration)
	if phase == 0 and emerg_currently > 0 then
		emerg_currently = emerg_currently - 1
	end
end

----------------------------------- DIMMING SWITCH UP/DWN
function cmd_dimming_switch_toggle(phase, duration)
	if phase == 0 then
		dimming_currently = math.abs(dimming_currently - 1)
	end
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

----------------------------------- EMPTY FUNCTION FOR WRITABLE DATAREF
function func_do_nothing()
		--nothing
end



----------------------------------- CREATE DATAREFS AND COMMANDS -----------------------------------

flood_knob = create_dataref("laminar/CitX/lights/flood_knob","number",func_do_nothing)
elec_knob = create_dataref("laminar/CitX/lights/elec_knob","number",func_do_nothing)
left_knob = create_dataref("laminar/CitX/lights/left_knob","number",func_do_nothing)
right_knob = create_dataref("laminar/CitX/lights/right_knob","number",func_do_nothing)
ctr_knob = create_dataref("laminar/CitX/lights/ctr_knob","number",func_do_nothing)
map_left_knob = create_dataref("laminar/CitX/lights/map_left_knob","number",func_do_nothing)
map_right_knob = create_dataref("laminar/CitX/lights/map_right_knob","number",func_do_nothing)
map_left_bulb_x = create_dataref("laminar/CitX/lights/map_left_bulb_x","number",func_do_nothing)
map_left_bulb_z = create_dataref("laminar/CitX/lights/map_left_bulb_z","number",func_do_nothing)
map_right_bulb_x = create_dataref("laminar/CitX/lights/map_right_bulb_x","number",func_do_nothing)
map_right_bulb_z = create_dataref("laminar/CitX/lights/map_right_bulb_z","number",func_do_nothing)
monitor_button = create_dataref("laminar/CitX/lights/monitor_button","number")
aux_knob = create_dataref("laminar/CitX/lights/aux_knob","number",func_do_nothing)
emerg_light_switch = create_dataref("laminar/CitX/lights/emerg_light_switch","number") --> 0=off,1=on,2=armed
emerg_currently = create_dataref("laminar/CitX/lights/emerg_light_switch_term","number") --> 0=off,1=on,2=armed
emerg_light_led = create_dataref("laminar/CitX/lights/emerg_light_led","number")
emerg_AUX_light_on = create_dataref("laminar/CitX/lights/aux_lights_on","number") --> AUX emergency exit lights (actually brightness)
dim_lights_switch = create_dataref("laminar/CitX/lights/dim_lights_switch","number")
dimming_currently = create_dataref("laminar/CitX/lights/dim_lights_switch_term","number")


cmdfloodknobup = create_command("laminar/CitX/lights/flood_knob_up","Flood lights knob up",cmd_flood_knob_up)
cmdfloodknobdwn = create_command("laminar/CitX/lights/flood_knob_dwn","Flood lights knob down",cmd_flood_knob_dwn)

cmdelecknobup = create_command("laminar/CitX/lights/elec_knob_up","EL lights knob up",cmd_elec_knob_up)
cmdelecknobdwn = create_command("laminar/CitX/lights/elec_knob_dwn","EL lights knob down",cmd_elec_knob_dwn)

cmdleftknobup = create_command("laminar/CitX/lights/left_knob_up","Left lights knob up",cmd_left_knob_up)
cmdleftknobdwn = create_command("laminar/CitX/lights/left_knob_dwn","Left lights knob down",cmd_left_knob_dwn)

cmdrightknobup = create_command("laminar/CitX/lights/right_knob_up","Right lights knob up",cmd_right_knob_up)
cmdrightknobdwn = create_command("laminar/CitX/lights/right_knob_dwn","Right lights knob down",cmd_right_knob_dwn)

cmdctrknobup = create_command("laminar/CitX/lights/ctr_knob_up","Center lights knob up",cmd_ctr_knob_up)
cmdctrknobdwn = create_command("laminar/CitX/lights/ctr_knob_dwn","Center lights knob down",cmd_ctr_knob_dwn)

cmdmapleftknobup = create_command("laminar/CitX/lights/map_left_knob_up","Map light left knob up",cmd_map_left_knob_up)
cmdmapleftknobdwn = create_command("laminar/CitX/lights/map_left_knob_dwn","Map light left knob down",cmd_map_left_knob_dwn)

cmdmaprightknobup = create_command("laminar/CitX/lights/map_right_knob_up","Map light right knob up",cmd_map_right_knob_up)
cmdmaprightknobdwn = create_command("laminar/CitX/lights/map_right_knob_dwn","Map light right knob down",cmd_map_right_knob_dwn)

cmdmonitorbuttontoggle = create_command("laminar/CitX/lights/monitor_button_toggle","Toggle overhead monitor on/off",cmd_monitor_button_toggle)

cmdauxknobup = create_command("laminar/CitX/lights/aux_knob_up","Auxiliary lights knob up",cmd_aux_knob_up)
cmdauxknobdwn = create_command("laminar/CitX/lights/aux_knob_dwn","Auxiliary lights knob down",cmd_aux_knob_dwn)

cmdemerglightswitchup = create_command("laminar/CitX/lights/emerg_light_switch_up","Emergency lights switch up",cmd_emerg_light_switch_up)
cmdemerglightswitchdwn = create_command("laminar/CitX/lights/emerg_light_switch_dwn","Emergency lights switch down",cmd_emerg_light_switch_dwn)

cmddimmingswitchtog = create_command("laminar/CitX/lights/dimming_switch_toggle","Dimming lights switch toggle",cmd_dimming_switch_toggle)






--------------------------------- DO THIS EACH FLIGHT START ---------------------------------
function flight_start()

	flood_knob, brightness_FLOOD = 0.75, 0.75
	elec_knob, brightness_EL_STBY = 0.75, 0.75
	left_knob, brightness_LH = 0.75, 0.75
	right_knob, brightness_RH = 0.75, 0.75
	ctr_knob, brightness_CTR = 0.75, 0.75
	map_left_knob, brightness_MAP_L = 0, 0
	map_right_knob, brightness_MAP_R = 0, 0
	map_left_bulb_x = 0.0
	map_left_bulb_z = -0.7
	map_right_bulb_x = 0.0
	map_right_bulb_z = -0.7
	monitor_button = 0
	brightness_MONITOR = 0
	aux_knob = 0.75
	emerg_light_switch = 2 * startup_running
	emerg_currently = 2 * startup_running
	emergency_on = 0
	we_crashed = 0
	dim_lights_switch = 0
	dimming_currently = 0
	dimming_value = 0.50

end




--------------------------------- REGULAR RUNTIME ---------------------------------
function after_physics()

	-- SHUTOFF ALL INSTR LIGHTS EXCEPT STBY ONES IF POWER FAIL BUT STBY PWR IS ON 
	-- ("STBY_lights_factor" is from the ELECTRICAL SCRIPT)
	brightness_EL = brightness_EL * STBY_lights_factor
	brightness_LH = brightness_LH * STBY_lights_factor
	brightness_RH = brightness_RH * STBY_lights_factor
	brightness_CTR = brightness_CTR * STBY_lights_factor
	brightness_MONITOR = brightness_MONITOR * STBY_lights_factor
	brightness_YOKE_L = brightness_YOKE_L * STBY_lights_factor
	brightness_YOKE_R = brightness_YOKE_R * STBY_lights_factor
	

	--SLOWLY LIGHT UP OR DOWN THE OVERHEAD MONITOR
	if brightness_MONITOR ~= monitor_button then
		brightness_MONITOR = func_animate_slowly(monitor_button, brightness_MONITOR * STBY_lights_factor, 5)
	end


	--SLOWLY ANIMATE DIMMING SWITCH AND LIGHTS
	if dimming_currently ~= dim_lights_switch then
		dim_lights_switch = func_animate_slowly(dimming_currently, dim_lights_switch, 40)
	end
	if dimming_currently == 1 then
		if brightness_EL_STBY > dimming_value then brightness_EL_STBY = func_animate_slowly(dimming_value, brightness_EL_STBY, 5) end
		if brightness_EL > dimming_value then brightness_EL = func_animate_slowly(dimming_value, brightness_EL, 5) * STBY_lights_factor end
		if brightness_LH > dimming_value then brightness_LH = func_animate_slowly(dimming_value, brightness_LH, 5) * STBY_lights_factor end
		if brightness_RH > dimming_value then brightness_RH = func_animate_slowly(dimming_value, brightness_RH, 5) * STBY_lights_factor end
		if brightness_CTR > dimming_value then brightness_CTR = func_animate_slowly(dimming_value, brightness_CTR, 5) * STBY_lights_factor end
	end
	if dimming_currently == 0 then
		if brightness_EL_STBY < elec_knob then brightness_EL_STBY = func_animate_slowly(elec_knob, brightness_EL_STBY, 5) end
		if brightness_EL < elec_knob then brightness_EL = func_animate_slowly(elec_knob, brightness_EL, 5) * STBY_lights_factor end
		if brightness_LH < left_knob then brightness_LH = func_animate_slowly(left_knob, brightness_LH, 5) * STBY_lights_factor end
		if brightness_RH < right_knob then brightness_RH = func_animate_slowly(right_knob, brightness_RH, 5) * STBY_lights_factor end
		if brightness_CTR < ctr_knob then brightness_CTR = func_animate_slowly(ctr_knob, brightness_CTR, 5) * STBY_lights_factor end
	end


	--SLOWLY ANIMATE EMERGENCY SWITCH
	if emerg_currently ~= emerg_light_switch then
		emerg_light_switch = func_animate_slowly(emerg_currently, emerg_light_switch, 40)
	end
	--if emerg_currently > 0 then ***AUX LIGHTS ON*** else ***AUX LIGHTS OFF*** end --> NO NEED, SEE LOGIC BELOW
	--
	--ACTIVATE EMERGENCY LIGHTS LOGIC:
	--(IN ARM POSITION WILL ILLUMINATE EMERG LIGHTS IF LOW POWER OR MORE THAN -5G DECELERATION CRASH)
	if g_axil < -5 then we_crashed = 1 end
	if bus_volts_L+bus_volts_R < 10 or we_crashed == 1 then emergency_on = 1 else emergency_on = 0 end
	if emerg_currently == 2 and emergency_on == 1 then
		emerg_AUX_light_on = aux_knob / math.abs(((local_time_h-12)*2)/6) --> KNOB VALUE BUT AUTO DIMMED
	elseif emerg_currently == 1 then
		emerg_AUX_light_on = aux_knob / math.abs(((local_time_h-12)*2)/6) --> KNOB VALUE BUT AUTO DIMMED
	else
		emerg_AUX_light_on = 0
	end


	--EMERGENCY LIGHTS LED (LIGHT-UP ONLY IF THE SWITCH IS IN THE ON POSITION OR IN EMERGENCY MODE)
	--THAT CUSTOM SYSTEM IS ALWAYS POWERED SINCE IT SIMULATE AN ALWAYS CHARGED DEDICATED BATTERY
	if emerg_light_switch == 1 or emerg_currently+emergency_on > 2 then emerg_light_led = 1 else emerg_light_led = 0 end
	

end

