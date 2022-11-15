
--------------------------------------------------------------------------------------------
-- EXTERNAL AND PASSENGERS CABIN LIGHTS
-- INTERFACING CUSTOM DATAREFS WITH X-PLANE INTERNAL ONES
--
-- GENERIC[0] LIGHT IS FOR THE TAIL LOGO LIGHTS
-- GENERIC[1] LIGHT IS FOR THE WING INSPECTION LOGO LIGHTS (SEE ICE SCRIPT)
-- 
-- PASSENGERS CABIN HAS HIS CUSTOM DATAREF FOR THE LIT TEXTURE, SLOWLY GO ON OR OFF DEPENDING FROM MASTER AND TIME OF DAY
-- CABIN IS ALSO ON THE INSTR[31] DATAREF TO DRIVE SPILL LIGHTS
-- AND USE ALSO A CUSTOM DATAREF FOR AUX LIGHTS (emergency exit lights, see LIGHTS_COCKPIT script)
--
-- CABIN MASTER ADD ALSO AMPS LOAD ON THE LEFT BUS[1]:
-- MORE OR LESS AMPS COMES FROM PAYLOAD WEIGHT, ASSUMING MORE PAYLOAD = MORE PEOPLE ONBOARD
--------------------------------------------------------------------------------------------



----------------------------------- LOCATE DATAREFS -----------------------------------

startup_running = find_dataref("sim/operation/prefs/startup_running")
bus_volts_L = find_dataref("sim/cockpit2/electrical/bus_volts[1]")
bus_load_L = find_dataref("sim/cockpit2/electrical/plugin_bus_load_amps[1]") --> cabin master amps load
payload_weight = find_dataref("sim/flightmodel/weight/m_fixed") --> payload weight kg (from 0 to 3800, 1018 default)
draw_light_level = find_dataref("sim/graphics/animation/draw_light_level") --> the default _LIT light level
navigation_lights = find_dataref("sim/cockpit2/switches/navigation_lights_on")
beacon_lights = find_dataref("sim/cockpit2/switches/beacon_on")
strobe_lights = find_dataref("sim/cockpit2/switches/strobe_lights_on")
landing_light_L = find_dataref("sim/cockpit2/switches/landing_lights_switch[0]")
landing_light_R = find_dataref("sim/cockpit2/switches/landing_lights_switch[1]")
taxi_lights = find_dataref("sim/cockpit2/switches/taxi_light_on")
tail_logo_lights = find_dataref("sim/cockpit2/switches/generic_lights_switch[0]")
no_smoking = find_dataref("sim/cockpit2/switches/no_smoking")
fasten_seat_belts = find_dataref("sim/cockpit2/switches/fasten_seat_belts")
local_time_h = find_dataref("sim/cockpit2/clock_timer/local_time_hours")
CitX_cabin_lights = find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[31]") --> the x-plane cabin light rheo


------------------------------ DATAREFS AND COMMANDS FUNCTIONS -----------------------------

----------------------------------- GND REC (BEACONS) - ANTI COLL SWITCH UP/DWN
function cmd_gnd_rec_anti_coll_up(phase, duration)
	if phase == 0 and gnd_rec_anti_coll_value < 2 then
		gnd_rec_anti_coll_value = gnd_rec_anti_coll_value + 1
	end
end
function cmd_gnd_rec_anti_coll_dwn(phase, duration)
	if phase == 0 and gnd_rec_anti_coll_value > 0 then
		gnd_rec_anti_coll_value = gnd_rec_anti_coll_value - 1
	end
end

----------------------------------- SEAT BELT - PASS SAFETY SWITCH UP/DWN
function cmd_seat_belt_pass_safety_up(phase, duration)
	if phase == 0 and seat_belt_pass_safety_value > -1 then
		seat_belt_pass_safety_value = seat_belt_pass_safety_value - 1
	end
end
function cmd_seat_belt_pass_safety_dwn(phase, duration)
	if phase == 0 and seat_belt_pass_safety_value < 1 then
		seat_belt_pass_safety_value = seat_belt_pass_safety_value + 1
	end
end

----------------------------------- RECOGNITION (DIMMED LAND LIGHTS) SWITCH UP/DWN
function cmd_recognition_toggle(phase, duration)
	if phase == 0 then
		recognition_value = math.abs(recognition_value - 1)
	end
end


----------------------------------- NAVIGATION SWITCH UP/DWN
function cmd_navigation_toggle(phase, duration)
	if phase == 0 then
		navigation_value = math.abs(navigation_value - 1)
	end
end


----------------------------------- TAIL "LOGO" FLOOD SWITCH UP/DWN
function cmd_tail_flood_toggle(phase, duration)
	if phase == 0 then
		tail_flood_value = math.abs(tail_flood_value - 1)
	end
end


----------------------------------- TAXI LIGHTS SWITCH UP/DWN
function cmd_taxi_toggle(phase, duration)
	if phase == 0 then
		taxi_value = math.abs(taxi_value - 1)
	end
end


----------------------------------- LANDING LIGHTS LH SWITCH UP/DWN
function cmd_landing_L_toggle(phase, duration)
	if phase == 0 then
		landing_L_value = math.abs(landing_L_value - 1)
	end
end


----------------------------------- LANDING LIGHTS RH SWITCH UP/DWN
function cmd_landing_R_toggle(phase, duration)
	if phase == 0 then
		landing_R_value = math.abs(landing_R_value - 1)
	end
end


----------------------------------- CABIN MASTER SAFEGUARD TOGGLE
function cmd_cabin_safeguard_toggle(phase, duration)
	if phase == 0 then
		cabin_safeguard_value = math.abs(cabin_safeguard_value - 1) --> TOGGLE FROM 0 TO 1
	end
end

----------------------------------- CABIN MASTER SWITCH TOGGLE
function cmd_cabin_master_toggle(phase, duration)
	if phase == 0 then
		cabin_master_value = math.abs(cabin_master_value - 1) --> TOGGLE FROM 0 TO 1
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

CitX_gnd_rec_anti_coll = create_dataref("laminar/CitX/lights/gnd_rec_anti_coll","number") --> 0 off, 1 gnd-rec, 2 gnd-rec + anti-coll
gnd_rec_anti_coll_value = create_dataref("laminar/CitX/lights/gnd_rec_anti_coll_term","number") --> 0 off, 1 gnd-rec, 2 gnd-rec + anti-coll
CitX_seat_belt_pass_safety = create_dataref("laminar/CitX/lights/seat_belt_pass_safety","number") --> -1 seat-belt, 0 off, 1 pass-safety
seat_belt_pass_safety_value = create_dataref("laminar/CitX/lights/seat_belt_pass_safety_term","number") --> -1 seat-belt, 0 off, 1 pass-safety
CitX_cabin_master = create_dataref("laminar/CitX/lights/cabin_master","number")
cabin_master_value = create_dataref("laminar/CitX/lights/cabin_master_term","number")
CitX_cabin_master_safeguard = create_dataref("laminar/CitX/lights/cabin_master_safeguard","number")
cabin_safeguard_value = create_dataref("laminar/CitX/lights/cabin_master_safeguard_term","number")
CitX_cabin_lights_on = create_dataref("laminar/CitX/lights/cabin_lights_on","number") --> the lights of the whole passengers cabin
CitX_recognition = create_dataref("laminar/CitX/lights/recognition","number")
recognition_value = create_dataref("laminar/CitX/lights/recognition_term","number")
CitX_navigation = create_dataref("laminar/CitX/lights/navigation","number")
CitX_tail_flood = create_dataref("laminar/CitX/lights/tail_flood","number")
CitX_taxi = create_dataref("laminar/CitX/lights/taxi","number")
CitX_landing_left = create_dataref("laminar/CitX/lights/landing_left","number")
CitX_landing_right = create_dataref("laminar/CitX/lights/landing_right","number")


cmdgndrecanticollup = create_command("laminar/CitX/lights/cmd_gnd_rec_anti_coll_up","Anti collision switch up",cmd_gnd_rec_anti_coll_up)
cmdgndrecanticolldwn = create_command("laminar/CitX/lights/cmd_gnd_rec_anti_coll_dwn","Anti collision switch down",cmd_gnd_rec_anti_coll_dwn)

cmdseatbeltpasafetyup = create_command("laminar/CitX/lights/cmd_seat_belt_pass_safety_up","Seat belt switch up",cmd_seat_belt_pass_safety_up)
cmdseatbeltpasafetydwn = create_command("laminar/CitX/lights/cmd_seat_belt_pass_safety_dwn","Seat belt switch down",cmd_seat_belt_pass_safety_dwn)

cmdrecognitiontog = create_command("laminar/CitX/lights/cmd_recognition_toggle","Recognition lights switch toggle",cmd_recognition_toggle)
cmdnavigationtog = create_command("laminar/CitX/lights/cmd_navigation_toggle","Navigation lights switch toggle",cmd_navigation_toggle)
cmdtailfloodtog = create_command("laminar/CitX/lights/cmd_tail_flood_toggle","Tail flood lights switch toggle",cmd_tail_flood_toggle)

cmdtaxitog = create_command("laminar/CitX/lights/cmd_taxi_toggle","Taxi lights switch toggle",cmd_taxi_toggle)
cmdlandingLtog = create_command("laminar/CitX/lights/cmd_landing_left_toggle","Landing lights left toggle",cmd_landing_L_toggle)
cmdlandingRtog = create_command("laminar/CitX/lights/cmd_landing_right_toggle","Landing lights right toggle",cmd_landing_R_toggle)

cmdcabinsafeguardtoggle = create_command("laminar/CitX/lights/cmd_cabin_safeguard_toggle","Cabin master safeguard",cmd_cabin_safeguard_toggle)
cmdcabinmastertoggle = create_command("laminar/CitX/lights/cmd_cabin_master_toggle","Cabin master toggle",cmd_cabin_master_toggle)






--------------------------------- DO THIS EACH FLIGHT START ---------------------------------
function flight_start()

	gnd_rec_anti_coll_value = startup_running*2
	seat_belt_pass_safety_value = 0
	recognition_value = 0 -->(DIMMED LND LGTS)
	navigation_value = startup_running
	taxi_value = startup_running
	if local_time_h < 6 or local_time_h > 18 then need_lights = 1 else need_lights = 0 end
	landing_L_value = need_lights * startup_running
	landing_R_value = need_lights * startup_running
	tail_flood_value = need_lights * startup_running
	cabin_safeguard_value = 0
	cabin_master_value = startup_running

end




--------------------------------- REGULAR RUNTIME ---------------------------------
function after_physics()

	-- GND REC (BEACONS) - ANTI COLLISION SWITCH --
	-- SLOWLY ANIMATE:
	if CitX_gnd_rec_anti_coll ~= gnd_rec_anti_coll_value then
		CitX_gnd_rec_anti_coll = func_animate_slowly(gnd_rec_anti_coll_value, CitX_gnd_rec_anti_coll, 40)
	end
	-- SYSTEM LOGIC:
	if gnd_rec_anti_coll_value == 1 then
		beacon_lights = 1 strobe_lights = 0
	elseif gnd_rec_anti_coll_value == 2 then
		beacon_lights = 1 strobe_lights = 1
	else
		beacon_lights = 0 strobe_lights = 0
	end
	-----------------


	-- SEAT BELT AND PASS SAFE SWITCH --
	-- SLOWLY ANIMATE:
	if CitX_seat_belt_pass_safety ~= seat_belt_pass_safety_value then
		CitX_seat_belt_pass_safety = func_animate_slowly(seat_belt_pass_safety_value, CitX_seat_belt_pass_safety, 40)
	end
	-- SYSTEM LOGIC:
	if seat_belt_pass_safety_value == -1 then
		no_smoking = 0 fasten_seat_belts = 1
	elseif seat_belt_pass_safety_value == 1 then
		no_smoking = 1 fasten_seat_belts = 1
	else
		no_smoking = 0 fasten_seat_belts = 0
	end
	-----------------


	-- RECOGNITION (DIMMED LANDING LIGHTS) LIGHTS SWITCH --
	-- SLOWLY ANIMATE:
	if CitX_recognition ~= recognition_value then
		CitX_recognition = func_animate_slowly(recognition_value, CitX_recognition, 40)
	end
	-- SYSTEM LOGIC:
	-- NONE (SEE LANDING LIGHTS LOGIC)
	-----------------


	-- NAVIGATION LIGHTS SWITCH --
	-- SLOWLY ANIMATE:
	if CitX_navigation ~= navigation_value then
		CitX_navigation = func_animate_slowly(navigation_value, CitX_navigation, 40)
	end
	-- SYSTEM LOGIC:
	if navigation_value == 1 then
		navigation_lights = 1
	else
		navigation_lights = 0
	end
	-----------------


	-- TAIL FLOOD "LOGO" LIGHTS SWITCH --
	-- SLOWLY ANIMATE:
	if CitX_tail_flood ~= tail_flood_value then
		CitX_tail_flood = func_animate_slowly(tail_flood_value, CitX_tail_flood, 40)
	end
	-- SYSTEM LOGIC:
	if tail_flood_value == 1 then
		tail_logo_lights = 1
	else
		tail_logo_lights = 0
	end
	-----------------


	-- TAXI LIGHTS SWITCH --
	-- SLOWLY ANIMATE:
	if CitX_taxi ~= taxi_value then
		CitX_taxi = func_animate_slowly(taxi_value, CitX_taxi, 40)
	end
	-- SYSTEM LOGIC:
	if taxi_value == 1 then
		taxi_lights = 1
	else
		taxi_lights = 0
	end
	-----------------


	-- LANDING LIGHTS LH/RH SWITCHES --
	-- SLOWLY ANIMATE:
	if CitX_landing_left ~= landing_L_value then
		CitX_landing_left = func_animate_slowly(landing_L_value, CitX_landing_left, 40)
	end
	if CitX_landing_right ~= landing_R_value then
		CitX_landing_right = func_animate_slowly(landing_R_value, CitX_landing_right, 40)
	end
	-- SYSTEM LOGIC (ALSO DIM THE LIGHTS IF RECON SWITCH IS ON):
	if landing_L_value == 1 then landing_light_L = 1 - (recognition_value * 0.95) else landing_light_L = 0 end
	if landing_R_value == 1 then landing_light_R = 1 - (recognition_value * 0.95) else landing_light_R = 0 end
	-----------------


	-- CABIN MASTER SAFEGUARD AND SWITCH --
	-- SLOWLY ANIMATE:
	if CitX_cabin_master_safeguard ~= cabin_safeguard_value then
		CitX_cabin_master_safeguard = func_animate_slowly(cabin_safeguard_value, CitX_cabin_master_safeguard, 20)
	end
	if CitX_cabin_master ~= cabin_master_value then
		CitX_cabin_master = func_animate_slowly(cabin_master_value, CitX_cabin_master, 40)
	end
	-- ASSUME THE NUMBERS OF PEOPLE ONBOARD FROM PAYLOAD WEIGHT (MIN 1, MAX 10)
	num_people = math.ceil(payload_weight/400)
	if num_people < 1 then num_people = 1 end
	if num_people > 10 then num_people = 10 end
	-- SYSTEM LOGIC (PASSENGERS CABIN AMPS CONSUMPTION):
	if cabin_master_value == 1 then bus_load_L = num_people * 5 else bus_load_L = 0 end
	-----------------

	-- CABIN LIGHTS LOGIC --
	-- SLOWLY TURNS ON CABIN LIGHTS AT DUSK IF WE HAVE POWER:
	if draw_light_level > 0.1 and cabin_master_value == 1 and bus_volts_L > 0.1 then
		CitX_cabin_lights_on = func_animate_slowly(1, CitX_cabin_lights_on, 5)
		CitX_cabin_lights = CitX_cabin_lights_on
	else
		CitX_cabin_lights_on = func_animate_slowly(0, CitX_cabin_lights_on, 5)
		CitX_cabin_lights = CitX_cabin_lights_on
	end

end

