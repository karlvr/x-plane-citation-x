
----------------------------------------------------------------------------------------------------------
-- ANTI-ICE SYSTEMS
-- INTERFACING CUSTOM ANTI-ICE SWITCHES DATAREFS WITH X-PLANE INTERNAL ONES
--
-- REAL PLANE BASICALLY HAS THE FOLLOWING SYSTEMS:
-- HOT BLEED-AIR: ENGINES INLET, HORIZ STABS, WING ROOTS, SLATS AND WINDSHIELD (AIR RAIN REMOVAL)
-- ELECTRICAL HEATING: PITOT/AOA/TEMP/STATIC PROBES AND WINDSHIELD
--
-- PS: IN REAL PLANE THE WING ROOT PORTION IS DEICED BY ENGINE SWITCH, BUT WE NOT DIFFERENTIATE, SINCE SLATS ARE DEICING ALL WINGS
--
-- IT SET CUSTOM TEMPERATURE DATAREF USED IN ALPHA.OBJ FOR DEICING THERMAL EFFECT
--
-- IT ALSO CONTROL THE GENERIC_1 WING INSPECTION LIGHTS ON THE FUSELAGE (GENERIC_0 IS FOR TAIL LOGO LIGHT)
-----------------------------------------------------------------------------------------------------------




----------------------------------- LOCATE DATAREFS -----------------------------------

--startup_running = find_dataref("sim/operation/prefs/startup_running")
--ice_detect_on = find_dataref("sim/cockpit2/ice/ice_detect_on")
engineL_running = find_dataref("sim/flightmodel2/engines/engine_is_burning_fuel[0]")
engineR_running = find_dataref("sim/flightmodel2/engines/engine_is_burning_fuel[1]")
ice_tailplane_man = find_dataref("sim/cockpit2/ice/ice_tailplane_man") --> OLD LEGACY PLANES DEICE BOTH WINGS AND TAIL, SETTING THIS TO 1 SEPARATE THEM

anti_ice_all_wings = find_dataref("sim/cockpit2/ice/ice_surface_hot_bleed_air_on") --> THE ALL WINGS LEADING-EDGE DEICE IS USED FOR SLATS
--anti_ice_wing_left = find_dataref("sim/cockpit2/ice/ice_surface_hot_bleed_air_left_on") --> NO NEED SINCE SLAT IS DEICING BOTH
--anti_ice_wing_right = find_dataref("sim/cockpit2/ice/ice_surface_hot_bleed_air_right_on") --> NO NEED SINCE SLAT IS DEICING BOTH
anti_ice_wing_xover = find_dataref("sim/cockpit2/ice/ice_wing_hot_bleed_air_crossover_valve")
anti_ice_stab_left = find_dataref("sim/cockpit2/ice/ice_tail_hot_bleed_air_left_on")
anti_ice_stab_right = find_dataref("sim/cockpit2/ice/ice_tail_hot_bleed_air_right_on")
anti_ice_engine_left = find_dataref("sim/cockpit2/ice/cowling_thermal_anti_ice_per_engine[0]")
anti_ice_engine_right = find_dataref("sim/cockpit2/ice/cowling_thermal_anti_ice_per_engine[1]")

anti_ice_pitot_pilot = find_dataref("sim/cockpit2/ice/ice_pitot_heat_on_pilot")
anti_ice_pitot_copilot = find_dataref("sim/cockpit2/ice/ice_pitot_heat_on_copilot")
anti_ice_AOA_pilot = find_dataref("sim/cockpit2/ice/ice_AOA_heat_on")
anti_ice_AOA_copilot = find_dataref("sim/cockpit2/ice/ice_AOA_heat_on_copilot")
anti_ice_static_pilot = find_dataref("sim/cockpit2/ice/ice_static_heat_on_pilot")
anti_ice_static_copilot = find_dataref("sim/cockpit2/ice/ice_static_heat_on_copilot")
--anti_ice_windows = find_dataref("sim/cockpit2/ice/ice_window_heat_on") --> old legacy dataref, heating only pilot windshield
anti_ice_window_pilot = find_dataref("sim/cockpit2/ice/ice_window_heat_on_window[0]") --> pilot windshield heat 
anti_ice_window_copilot = find_dataref("sim/cockpit2/ice/ice_window_heat_on_window[1]") --> copilot windshield heat 
--anti_ice_window_pilot_side = find_dataref("sim/cockpit2/ice/ice_window_heat_on_window[2]") --> pilot side windshield heat *** NO NEED ***
--anti_ice_window_copilot_side = find_dataref("sim/cockpit2/ice/ice_window_heat_on_window[3]") --> copilot side windshield heat *** NO NEED ***
rain_repellent = find_dataref("sim/cockpit2/switches/rain_repellent_switch[0]") --> pilot and copilot rain repellent blower (we have just one switch for both)
--rain_repellent_copilot = find_dataref("sim/cockpit2/switches/rain_repellent_switch[1]") --> copilot rain repellent blower *** NO NEED ***
--rain_repellent_ratio = find_dataref("sim/flightmodel2/misc/rain_repellent_ratio[0]") -- *** NO NEED ***

generic_lights_switch_1 = find_dataref("sim/cockpit2/switches/generic_lights_switch[1]") --> wing inspection lights on fuselage sides





------------------------------ DATAREFS AND COMMANDS FUNCTIONS -----------------------------


----------------------------------- PITOT / STATIC LH SWITCH
function cmd_pitot_static_L_toggle(phase, duration)
	if phase == 0 then pitot_static_L_value = math.abs(pitot_static_L_value - 1) end
end


----------------------------------- PITOT / STATIC RH SWITCH
function cmd_pitot_static_R_toggle(phase, duration)
	if phase == 0 then pitot_static_R_value = math.abs(pitot_static_R_value - 1) end
end


----------------------------------- WING LIGHT SWITCH
function cmd_wing_light_toggle(phase, duration)
	if phase == 0 then wing_light_value = math.abs(wing_light_value - 1) end
end


----------------------------------- WINDSHIELD LH SWITCH (WITH O'RIDE SPRING)
function cmd_windshield_L_up(phase, duration)
	if phase == 0 then windshield_L_value = math.min(2, windshield_L_value + 1) end
	if phase == 2 and windshield_L_value == 2 then windshield_L_value = 1 end --> the spring back to "on"
end
function cmd_windshield_L_dwn(phase, duration)
	if phase == 0 and windshield_L_value == 1 then windshield_L_value = 0 end
end


----------------------------------- WINDSHIELD RH SWITCH (WITH O'RIDE SPRING)
function cmd_windshield_R_up(phase, duration)
	if phase == 0 then windshield_R_value = math.min(2, windshield_R_value + 1) end
	if phase == 2 and windshield_R_value == 2 then windshield_R_value = 1 end --> the spring back to "on"
end
function cmd_windshield_R_dwn(phase, duration)
	if phase == 0 and windshield_R_value == 1 then windshield_R_value = 0 end
end


----------------------------------- WINDSHIELD AIR SWITCH (BLOWER)
function cmd_windshield_air_toggle(phase, duration)
	if phase == 0 then windshield_air_value = math.abs(windshield_air_value - 1) end
end


----------------------------------- WING CROSSOVER SWITCH
function cmd_wing_crossover_toggle(phase, duration)
	if phase == 0 then wing_crossover_value = math.abs(wing_crossover_value - 1) end
end


----------------------------------- ENGINE LH SWITCH
function cmd_engine_L_toggle(phase, duration)
	if phase == 0 then engine_L_value = math.abs(engine_L_value - 1) end
end


----------------------------------- ENGINE RH SWITCH
function cmd_engine_R_toggle(phase, duration)
	if phase == 0 then engine_R_value = math.abs(engine_R_value - 1) end
end


----------------------------------- STABILIZER LH SWITCH
function cmd_stabilizer_L_toggle(phase, duration)
	if phase == 0 then stabilizer_L_value = math.abs(stabilizer_L_value - 1) end
end


----------------------------------- STABILIZER RH SWITCH
function cmd_stabilizer_R_toggle(phase, duration)
	if phase == 0 then stabilizer_R_value = math.abs(stabilizer_R_value - 1) end
end


----------------------------------- SLAT SWITCH
function cmd_slat_toggle(phase, duration)
	if phase == 0 then slat_value = math.abs(slat_value - 1) end
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
--function func_do_nothing()
		--nothing
--end










----------------------------------- CREATE DATAREFS AND COMMANDS -----------------------------------

CitX_pitot_static_L = create_dataref("laminar/CitX/ice/pitot_static_left","number")
pitot_static_L_value = create_dataref("laminar/CitX/ice/pitot_static_left_term","number")
CitX_pitot_static_R = create_dataref("laminar/CitX/ice/pitot_static_right","number")
pitot_static_R_value = create_dataref("laminar/CitX/ice/pitot_static_right_term","number")
CitX_wing_light = create_dataref("laminar/CitX/ice/wing_light","number")
CitX_windshield_L = create_dataref("laminar/CitX/ice/windshield_left","number") --> 0 off, 1 on, 2 o'ride
windshield_L_value = create_dataref("laminar/CitX/ice/windshield_left_term","number") --> 0 off, 1 on, 2 o'ride
CitX_windshield_R = create_dataref("laminar/CitX/ice/windshield_right","number") --> 0 off, 1 on, 2 o'ride
windshield_R_value = create_dataref("laminar/CitX/ice/windshield_right_term","number") --> 0 off, 1 on, 2 o'ride
CitX_windshield_L_temp = create_dataref("laminar/CitX/ice/windshield_left_temp","number") --> pilot windows temperature °C
CitX_windshield_R_temp = create_dataref("laminar/CitX/ice/windshield_right_temp","number") --> copilot windows temperature °C
CitX_windshield_air = create_dataref("laminar/CitX/ice/windshield_air","number")
CitX_wing_crossover = create_dataref("laminar/CitX/ice/wing_crossover","number")
wing_crossover_value = create_dataref("laminar/CitX/ice/wing_crossover_term","number")
CitX_engine_L = create_dataref("laminar/CitX/ice/engine_left","number")
CitX_engine_R = create_dataref("laminar/CitX/ice/engine_right","number")
CitX_stabilizer_L = create_dataref("laminar/CitX/ice/stabilizer_left","number")
stabilizer_L_value = create_dataref("laminar/CitX/ice/stabilizer_left_term","number")
CitX_stabilizer_R = create_dataref("laminar/CitX/ice/stabilizer_right","number")
stabilizer_R_value = create_dataref("laminar/CitX/ice/stabilizer_right_term","number")
CitX_slat = create_dataref("laminar/CitX/ice/slat","number")
slat_value  = create_dataref("laminar/CitX/ice/slat_term","number")

cmdpitotstaticLtog = create_command("laminar/CitX/ice/cmd_pitot_static_left_toggle","Anti ice pitot static left toggle",cmd_pitot_static_L_toggle)
cmdpitotstaticRtog = create_command("laminar/CitX/ice/cmd_pitot_static_right_toggle","Anti ice pitot static right toggle",cmd_pitot_static_R_toggle)
cmdwinglighttog = create_command("laminar/CitX/ice/cmd_wing_light_toggle","Anti ice inspection light toggle",cmd_wing_light_toggle)
cmdwindshieldLup = create_command("laminar/CitX/ice/cmd_windshield_left_up","Anti ice windshield left up",cmd_windshield_L_up)
cmdwindshieldLdwn = create_command("laminar/CitX/ice/cmd_windshield_left_dwn","Anti ice windshield left dwn",cmd_windshield_L_dwn)
cmdwindshieldRup = create_command("laminar/CitX/ice/cmd_windshield_right_up","Anti ice windshield right up",cmd_windshield_R_up)
cmdwindshieldRdwn = create_command("laminar/CitX/ice/cmd_windshield_right_dwn","Anti ice windshield right dwn",cmd_windshield_R_dwn)
cmdwindshieldairtog = create_command("laminar/CitX/ice/cmd_windshield_air_toggle","Anti ice windshield air toggle",cmd_windshield_air_toggle)
cmdwingcrossovertog = create_command("laminar/CitX/ice/cmd_wing_crossover_toggle","Anti ice wing crossover toggle",cmd_wing_crossover_toggle)
cmdengineLtog = create_command("laminar/CitX/ice/cmd_engine_left_toggle","Anti ice engine left toggle",cmd_engine_L_toggle)
cmdengineRtog = create_command("laminar/CitX/ice/cmd_engine_right_toggle","Anti ice engine right toggle",cmd_engine_R_toggle)
cmdstabilizerLtog = create_command("laminar/CitX/ice/cmd_stabilizer_left_toggle","Anti ice stabilizer left toggle",cmd_stabilizer_L_toggle)
cmdstabilizerRtog = create_command("laminar/CitX/ice/cmd_stabilizer_right_toggle","Anti ice stabilizer right toggle",cmd_stabilizer_R_toggle)
cmdslattog = create_command("laminar/CitX/ice/cmd_slat_toggle","Anti ice slat toggle",cmd_slat_toggle)





--------------------------------- DO THIS EACH FLIGHT START ---------------------------------
function flight_start()

	ice_tailplane_man = 1 --> THIS IS TO USE NEW SEPARATE WING/TAIL DATAREFS
	pitot_static_L_value = anti_ice_pitot_pilot
	pitot_static_R_value = anti_ice_pitot_copilot
	wing_light_value = generic_lights_switch_1
	windshield_L_value = anti_ice_window_pilot
	windshield_R_value = anti_ice_window_copilot
	windshield_air_value = rain_repellent
	wing_crossover_value = anti_ice_wing_xover
	engine_L_value = anti_ice_engine_left
	engine_R_value = anti_ice_engine_right
	stabilizer_L_value = anti_ice_stab_left
	stabilizer_R_value = anti_ice_stab_right
	slat_value = anti_ice_all_wings

end





--------------------------------- REGULAR RUNTIME ---------------------------------
function after_physics()

	-- PITOT/STATIC LH/RH SWITCHES --
	-- SLOWLY ANIMATE:
	if CitX_pitot_static_L ~= pitot_static_L_value then
		CitX_pitot_static_L = func_animate_slowly(pitot_static_L_value, CitX_pitot_static_L, 40)
	end
	if CitX_pitot_static_R ~= pitot_static_R_value then
		CitX_pitot_static_R = func_animate_slowly(pitot_static_R_value, CitX_pitot_static_R, 40)
	end
	-- SYSTEM LOGIC:
	if pitot_static_L_value == 1 then
		anti_ice_pitot_pilot = 1 anti_ice_static_pilot = 1 anti_ice_AOA_pilot = 1
	else
		anti_ice_pitot_pilot = 0 anti_ice_static_pilot = 0 anti_ice_AOA_pilot = 0
	end
	if pitot_static_R_value == 1 then
		anti_ice_pitot_copilot = 1 anti_ice_static_copilot = 1 anti_ice_AOA_copilot = 1
	else
		anti_ice_pitot_copilot = 0 anti_ice_static_copilot = 0 anti_ice_AOA_copilot = 0
	end
	-----------------


	-- WING INSPECTION LIGHT SWITCH --
	-- IT CONTROL THE GENERIC_1 LIGHTS ON THE FUSELAGE (GENERIC_0 IS FOR TAIL LOGO LIGHT) --
	-- SLOWLY ANIMATE:
	if CitX_wing_light ~= wing_light_value then
		CitX_wing_light = func_animate_slowly(wing_light_value, CitX_wing_light, 40)
	end
	-- SYSTEM LOGIC:
	if wing_light_value == 1 then
		generic_lights_switch_1 = 1
	else
		generic_lights_switch_1 = 0
	end
	-----------------


	-- WINDSHIELD ANTI-RAIN AIR SWITCH (BLOWERS) --
	-- SLOWLY ANIMATE:
	if CitX_windshield_air ~= windshield_air_value then
		CitX_windshield_air = func_animate_slowly(windshield_air_value, CitX_windshield_air, 40)
	end
	-- SYSTEM LOGIC:
	if windshield_air_value == 1 then
		rain_repellent = 1
	else
		rain_repellent = 0
	end
	-----------------


	-- WINDSHIELD LH/RH ELECTRIC-AC SWITCHES --
	-- SLOWLY ANIMATE:
	if CitX_windshield_L ~= windshield_L_value then
		CitX_windshield_L = func_animate_slowly(windshield_L_value, CitX_windshield_L, 40)
	end
	if CitX_windshield_R ~= windshield_R_value then
		CitX_windshield_R = func_animate_slowly(windshield_R_value, CitX_windshield_R, 40)
	end
	-- SYSTEM LOGIC (EVALUATING ALSO IF ENGINES ARE RUNNING SINCE HEATING PWR CAMES FROM THEM ONLY):
	if (windshield_L_value * engineL_running) > 0 then
		anti_ice_window_pilot = 1
		--anti_ice_window_pilot_side = 1 ***NO NEED***
	else
		anti_ice_window_pilot = 0
		--anti_ice_window_pilot_side = 0 ***NO NEED***
	end
	if (windshield_R_value * engineR_running) > 0 then
		anti_ice_window_copilot = 1
		--anti_ice_window_copilot_side = 1 ***NO NEED***
	else
		anti_ice_window_copilot = 0
		--anti_ice_window_copilot_side = 0 ***NO NEED***
	end
	-- SET THE TEMPERATURE OF DEICING WINDOWS SYSTEM (normally 15°, but the o'ride position (value =2) double the temp to 30 making deice faster)
	CitX_windshield_L_temp = anti_ice_window_pilot * 15 * windshield_L_value
	CitX_windshield_R_temp = anti_ice_window_copilot * 15 * windshield_R_value
	-----------------


	-- WING/ENGINE CROSSOVER SWITCH --
	-- SLOWLY ANIMATE:
	if CitX_wing_crossover ~= wing_crossover_value then
		CitX_wing_crossover = func_animate_slowly(wing_crossover_value, CitX_wing_crossover, 40)
	end
	-- SYSTEM LOGIC:
	anti_ice_wing_xover = wing_crossover_value
	-----------------


	-- ENGINE LH/RH SWITCHES --
	-- SLOWLY ANIMATE:
	if CitX_engine_L ~= engine_L_value then
		CitX_engine_L = func_animate_slowly(engine_L_value, CitX_engine_L, 40)
	end
	if CitX_engine_R ~= engine_R_value then
		CitX_engine_R = func_animate_slowly(engine_R_value, CitX_engine_R, 40)
	end
	-- SYSTEM LOGIC:
	anti_ice_engine_left = engine_L_value
	anti_ice_engine_right = engine_R_value
	-----------------


	-- STABILIZER LH/RH SWITCHES --
	-- SLOWLY ANIMATE:
	if CitX_stabilizer_L ~= stabilizer_L_value then
		CitX_stabilizer_L = func_animate_slowly(stabilizer_L_value, CitX_stabilizer_L, 40)
	end
	if CitX_stabilizer_R ~= stabilizer_R_value then
		CitX_stabilizer_R = func_animate_slowly(stabilizer_R_value, CitX_stabilizer_R, 40)
	end
	-- SYSTEM LOGIC:
	anti_ice_stab_left = stabilizer_L_value
	anti_ice_stab_right = stabilizer_R_value
	-----------------


	-- SLATS (AND WING ROOTS BY CONSEQUENCE) SWITCH --
	-- SLOWLY ANIMATE:
	if CitX_slat ~= slat_value then
		CitX_slat = func_animate_slowly(slat_value, CitX_slat, 40)
	end
	-- SYSTEM LOGIC:
	anti_ice_all_wings = slat_value
	-----------------


end

