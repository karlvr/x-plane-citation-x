
----------------------------------------------------------------------------------------------------
-- OXYGEN SYSTEM
-- INTERFACING CUSTOM DATAREFS WITH X-PLANE INTERNAL ONES
--
-- NOTE THAT PILOT AND COPILOT OXYGEN ARE ACTIVATED TOGETHER WITH THE PASSENGERS (VIA THE KNOB)
-- MORE OR LESS OXY PLUGGED COMES FROM PAYLOAD WEIGHT, ASSUMING MORE PAYLOAD = MORE PEOPLE ONBOARD
----------------------------------------------------------------------------------------------------




----------------------------------- LOCATE DATAREFS -----------------------------------

startup_running = find_dataref("sim/operation/prefs/startup_running")
payload_weight = find_dataref("sim/flightmodel/weight/m_fixed") --> payload weight kg (from 0 to 3800, 1018 default)
rel_pass_o2_on = find_dataref("sim/operation/failures/rel_pass_o2_on") --> 6=pass need oxy on!
o2_valve_on = find_dataref("sim/cockpit2/oxygen/actuators/o2_valve_on")
demand_flow_setting = find_dataref("sim/cockpit2/oxygen/actuators/demand_flow_setting") --> 0=off,1=unreg,2=nownight,3/4=delay,5/6/7/8=facemask
num_plugged_in_o2 = find_dataref("sim/cockpit2/oxygen/actuators/num_plugged_in_o2")
cabin_altitude_ft = find_dataref("sim/cockpit2/pressurization/actuators/cabin_altitude_ft")




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


----------------------------------- PASS OXY KNOB
function cmd_pass_oxy_up(phase, duration)
	if phase == 0 and pass_oxy_value < 2 then
		pass_oxy_value = pass_oxy_value + 1
	end
end
function cmd_pass_oxy_dwn(phase, duration)
	if phase == 0 and pass_oxy_value > 0 then
		pass_oxy_value = pass_oxy_value - 1
	end
end










----------------------------------- CREATE DATAREFS AND COMMANDS -----------------------------------

CitX_oxygen_pass_oxy = create_dataref("laminar/CitX/oxygen/pass_oxy","number") --> 0 off, 1 auto, 2 on
pass_oxy_value = create_dataref("laminar/CitX/oxygen/pass_oxy_term","number") --> 0 off, 1 auto, 2 on


cmdpassoxyup = create_command("laminar/CitX/oxygen/cmd_pass_oxy_up","Oxygen knob up",cmd_pass_oxy_up)
cmdpassoxydwn = create_command("laminar/CitX/oxygen/cmd_pass_oxy_dwn","Oxygen knob dwn",cmd_pass_oxy_dwn)











--------------------------------- DO THIS EACH FLIGHT START ---------------------------------
function flight_start()

	pass_oxy_value = startup_running

end








--------------------------------- REGULAR RUNTIME ---------------------------------
function after_physics()


	-- PASS OXY KNOB --
	-- SLOWLY ANIMATE:
	if CitX_oxygen_pass_oxy ~= pass_oxy_value then
		CitX_oxygen_pass_oxy = func_animate_slowly(pass_oxy_value, CitX_oxygen_pass_oxy, 20)
	end


	-- ASSUME THE NUMBERS OF PEOPLE ONBOARD FROM PAYLOAD WEIGHT (MIN 1, MAX 10)
	num_plugged_in_o2 = math.ceil(payload_weight/400)
	if num_plugged_in_o2 < 1 then num_plugged_in_o2 = 1 end
	if num_plugged_in_o2 > 10 then num_plugged_in_o2 = 10 end


	-- OXY SYSTEM LOGIC --
	-- OFF
	if pass_oxy_value == 0 then
		o2_valve_on = 0
		demand_flow_setting = 0
	-- AUTO
	elseif pass_oxy_value == 1 then
		if rel_pass_o2_on == 6 then
			o2_valve_on = 1
			demand_flow_setting = 5
		else
			o2_valve_on = 0
			demand_flow_setting = 0
		end
	-- ON
	elseif pass_oxy_value == 2 then
		o2_valve_on = 1
		demand_flow_setting = 5
	end
	---------------------

end

