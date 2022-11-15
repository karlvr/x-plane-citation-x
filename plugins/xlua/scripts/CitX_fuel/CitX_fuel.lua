
-------------------------------------------------------------------------------------
-- THIS SCRIPT IS HERE TO DEAL WITH FUEL SYSTEM
-- AND BASICALLY JUST LINK CUSTOM SMOOTHED ANIMATED DATAREFS WITH DEFAULT XPLANE ONES
--
-- THIS PLANE HAS A CENTRAL[0], LEFT WING[1] AND RIGHT WING[2] FUEL TANKS
-- (CTR = 5910 lbs, LH and RH = 3560 lbs each -- TOT = 13031 lbs)
-- CENTRAL IS SET AS "AUX" IN PLANEMAKER AND LH AND RH ARE "FEEDERS" TO RESPECTIVE ENGINE
--
-- TRANSFER IS AVAILABLE FROM CENTRAL TO WING TANKS
-- OR A "GRAVITY" TRANSFER FROM WING TO WING TANKS
--
-- CROSSFEED IS OFF (L and R wing tanks feed respective engine, while central keeps them full until empty)
-- OR L/R CROSSED (L tank feed R engine and viceversa)
--
-- LH and RH ENGINE BOOST PUMPS ARE ALSO HERE
-- (tanks pumps are always on)
-------------------------------------------------------------------------------------




----------------------------------- LOCATE DATAREFS -----------------------------------

startup_running = find_dataref("sim/operation/prefs/startup_running")
fuel_tank_for_engine_L = find_dataref("sim/cockpit2/fuel/fuel_tank_selector_left") --> 0=none,1=left,2=center,3=right,4=all
fuel_tank_for_engine_R = find_dataref("sim/cockpit2/fuel/fuel_tank_selector_right")
fuel_crossfeed_selector = find_dataref("sim/cockpit2/fuel/fuel_crossfeed_selector") --> ****** 0=none,1=from left tank,3=from right tank ******
fuel_tank_transfer_to = find_dataref("sim/cockpit2/fuel/fuel_tank_transfer_to") --> 0=none/all,1=left,2=center,3=right
fuel_tank_transfer_from = find_dataref("sim/cockpit2/fuel/fuel_tank_transfer_from")
fuel_transfer_pump_left = find_dataref("sim/cockpit2/fuel/transfer_pump_left") --> ****** 0=off,1=norm,2=on ******
fuel_transfer_pump_right = find_dataref("sim/cockpit2/fuel/transfer_pump_right") --> ****** 0=off,1=norm,2=on ******
fuel_tank_pump_on_C = find_dataref("sim/cockpit2/fuel/fuel_tank_pump_on[0]")
fuel_tank_pump_on_L = find_dataref("sim/cockpit2/fuel/fuel_tank_pump_on[1]")
fuel_tank_pump_on_R = find_dataref("sim/cockpit2/fuel/fuel_tank_pump_on[2]")
fuel_engine_pump_on_L = find_dataref("sim/cockpit2/engine/actuators/fuel_pump_on[0]") --> ****** 0=Off, 1=On, 2=Norm ******
fuel_engine_pump_on_R = find_dataref("sim/cockpit2/engine/actuators/fuel_pump_on[1]")
fuel_quantity_C = find_dataref("sim/cockpit2/fuel/fuel_quantity[0]") --> kgs 2700 max
fuel_quantity_L = find_dataref("sim/cockpit2/fuel/fuel_quantity[1]") --> kgs 1650 max
fuel_quantity_R = find_dataref("sim/cockpit2/fuel/fuel_quantity[2]") --> kgs 1650 max
fuel_gravity_crossflow = find_dataref("sim/cockpit2/fuel/fuel_gravity_crossflow") --> ****** 0=closed, 1=open ******



------------------------------ DATAREFS AND COMMANDS FUNCTIONS -----------------------------

----------------------------------- CROSSFEED KNOB FUNCTION
function cmd_crossfeed_left(phase, duration)
	if phase == 0 then
		if crossfeed_value >= 0 then crossfeed_value = crossfeed_value -1 end
	end
end
function cmd_crossfeed_right(phase, duration)
	if phase == 0 then
		if crossfeed_value <= 0 then crossfeed_value = crossfeed_value +1 end
	end
end


----------------------------------- L/R WING GRAVITY FLOW SWITCH FUNCTION
function cmd_gravity_flow_toggle(phase, duration)
	if phase == 0 then
		gravity_flow_value = math.abs(gravity_flow_value - 1)
	end
end


----------------------------------- CTR TO LH TRANSFER SWITCH FUNCTION
function cmd_transfer_L_up(phase, duration)
	if phase == 0 then
		if transfer_L_value >= 1 then transfer_L_value = transfer_L_value -1 end
	end
end
function cmd_transfer_L_dwn(phase, duration)
	if phase == 0 then
		if transfer_L_value <= 1 then transfer_L_value = transfer_L_value +1 end
	end
end


----------------------------------- CTR TO RH TRANSFER SWITCH FUNCTION
function cmd_transfer_R_up(phase, duration)
	if phase == 0 then
		if transfer_R_value >= 1 then transfer_R_value = transfer_R_value -1 end
	end
end
function cmd_transfer_R_dwn(phase, duration)
	if phase == 0 then
		if transfer_R_value <= 1 then transfer_R_value = transfer_R_value +1 end
	end
end


----------------------------------- LH BOOST SWITCH FUNCTION
function cmd_boost_L_up(phase, duration)
	if phase == 0 then
		if boost_L_value <= 0 then boost_L_value = boost_L_value +1 end
	end
end
function cmd_boost_L_dwn(phase, duration)
	if phase == 0 then
		if boost_L_value >= 0 then boost_L_value = boost_L_value -1 end
	end
end


----------------------------------- RH BOOST SWITCH FUNCTION
function cmd_boost_R_up(phase, duration)
	if phase == 0 then
		if boost_R_value <= 0 then boost_R_value = boost_R_value +1 end
	end
end
function cmd_boost_R_dwn(phase, duration)
	if phase == 0 then
		if boost_R_value >= 0 then boost_R_value = boost_R_value -1 end
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
--function func_do_nothing()
		--nothing
--end







----------------------------------- CREATE DATAREFS AND COMMANDS -----------------------------------

CitX_crossfeed = create_dataref("laminar/CitX/fuel/crossfeed","number") --> -1 tankL/engR, 0 norm, 1 tankR/engL
crossfeed_value = create_dataref("laminar/CitX/fuel/crossfeed_term","number") --> -1 tankL/engR, 0 norm, 1 tankR/engL
CitX_gravity_flow = create_dataref("laminar/CitX/fuel/gravity_flow","number") --> 0 off, 1 on
CitX_transfer_L = create_dataref("laminar/CitX/fuel/transfer_left","number") --> 0 off, 1 on, 2 norm
CitX_transfer_R = create_dataref("laminar/CitX/fuel/transfer_right","number")
transfer_L_value = create_dataref("laminar/CitX/fuel/transfer_left_term","number") --> 0 off, 1 on, 2 norm
transfer_R_value = create_dataref("laminar/CitX/fuel/transfer_right_term","number")
CitX_boost_L = create_dataref("laminar/CitX/fuel/boost_left","number") --> -1 norm, 0 off, 1 on
boost_L_value = create_dataref("laminar/CitX/fuel/boost_left_term","number") --> -1 norm, 0 off, 1 on
CitX_boost_R = create_dataref("laminar/CitX/fuel/boost_right","number")
boost_R_value = create_dataref("laminar/CitX/fuel/boost_right_term","number")

cmdcrossfeedleft = create_command("laminar/CitX/fuel/cmd_crossfeed_left","Fuel crossfeed knob left",cmd_crossfeed_left)
cmdcrossfeedright = create_command("laminar/CitX/fuel/cmd_crossfeed_right","Fuel crossfeed knob right",cmd_crossfeed_right)
cmdgravityflowtog = create_command("laminar/CitX/fuel/cmd_gravity_flow_toggle","Fuel gravity flow switch toggle",cmd_gravity_flow_toggle)
cmdtransferLup = create_command("laminar/CitX/fuel/cmd_transfer_left_up","Fuel transfer LH switch up",cmd_transfer_L_up)
cmdtransferLdwn = create_command("laminar/CitX/fuel/cmd_transfer_left_dwn","Fuel transfer LH switch dwn",cmd_transfer_L_dwn)
cmdtransferRup = create_command("laminar/CitX/fuel/cmd_transfer_right_up","Fuel transfer RH switch up",cmd_transfer_R_up)
cmdtransferRdwn = create_command("laminar/CitX/fuel/cmd_transfer_right_dwn","Fuel transfer RH switch dwn",cmd_transfer_R_dwn)
cmdboostLup = create_command("laminar/CitX/fuel/cmd_boost_left_up","Fuel boost LH switch up",cmd_boost_L_up)
cmdboostLdwn = create_command("laminar/CitX/fuel/cmd_boost_left_dwn","Fuel boost LH switch dwn",cmd_boost_L_dwn)
cmdboostRup = create_command("laminar/CitX/fuel/cmd_boost_right_up","Fuel boost RH switch up",cmd_boost_R_up)
cmdboostRdwn = create_command("laminar/CitX/fuel/cmd_boost_right_dwn","Fuel boost RH switch dwn",cmd_boost_R_dwn)





--------------------------------- DO THIS EACH FLIGHT START ---------------------------------
function flight_start()

	fuel_tank_pump_on_C = 1
	fuel_tank_pump_on_L = 1
	fuel_tank_pump_on_R = 1

	crossfeed_value = 0
	gravity_flow_value = 0
	transfer_L_value = 0 + startup_running*2
	transfer_R_value = 0 + startup_running*2
	boost_L_value = 0 - startup_running
	boost_R_value = 0 - startup_running

end




--------------------------------- REGULAR RUNTIME ---------------------------------
function after_physics()

	-- CROSSFEED KNOB --
	-- SLOWLY ANIMATE:
	if CitX_crossfeed ~= crossfeed_value then
		CitX_crossfeed = func_animate_slowly(crossfeed_value, CitX_crossfeed, 20)
	end
	-- SYSTEM LOGIC (****** tank 0=none,1=left,2=center,3=right,4=all ******):
	if crossfeed_value == 0 then fuel_crossfeed_selector = 0 end
	if crossfeed_value == -1 then fuel_crossfeed_selector = 1 end
	if crossfeed_value == 1 then fuel_crossfeed_selector = 3 end
	-----------------


	-- GRAVITY SWITCH --
	-- SLOWLY ANIMATE:
	if CitX_gravity_flow ~= gravity_flow_value then
		CitX_gravity_flow = func_animate_slowly(gravity_flow_value, CitX_gravity_flow, 40)
	end
	-- SYSTEM LOGIC:
	if gravity_flow_value == 1 then fuel_gravity_crossflow = 1 else fuel_gravity_crossflow = 0 end
	-----------------


	-- CENTRAL TANK NORMAL USAGE LOGIC --
	-- ****** NO MORE SINCE IT IS BUILT INTO XPLANE ******
	-----------------


	-- CTR TO LEFT OR RIGHT TRANSFER SWITCHES --
	-- SLOWLY ANIMATE:
	if CitX_transfer_L ~= transfer_L_value then
		CitX_transfer_L = func_animate_slowly(transfer_L_value, CitX_transfer_L, 40)
	end
	if CitX_transfer_R ~= transfer_R_value then
		CitX_transfer_R = func_animate_slowly(transfer_R_value, CitX_transfer_R, 40)
	end
	-- SYSTEM LOGIC (****** pump 0=off,1=norm,2=on ******):
	if transfer_L_value == 0 then
		fuel_transfer_pump_left = 0
	elseif transfer_L_value == 1 then
		fuel_transfer_pump_left = 2
	else
		fuel_transfer_pump_left = 1
	end
	if transfer_R_value == 0 then
		fuel_transfer_pump_right = 0
	elseif transfer_R_value == 1 then
		fuel_transfer_pump_right = 2
	else
		fuel_transfer_pump_right = 1
	end
	-----------------


	-- LEFT AMD RIGHT BOOST PUMPS SWITCHES --
	-- SLOWLY ANIMATE:
	if CitX_boost_L ~= boost_L_value then
		CitX_boost_L = func_animate_slowly(boost_L_value, CitX_boost_L, 40)
	end
	if CitX_boost_R ~= boost_R_value then
		CitX_boost_R = func_animate_slowly(boost_R_value, CitX_boost_R, 40)
	end
	-- SYSTEMS LOGIC (pump 0=Off,1=On,2=Norm):
	if boost_L_value == 0 then fuel_engine_pump_on_L = 0 end
	if boost_L_value == 1 then fuel_engine_pump_on_L = 1 end
	if boost_L_value == -1 then fuel_engine_pump_on_L = 2 end
	if boost_R_value == 0 then fuel_engine_pump_on_R = 0 end
	if boost_R_value == 1 then fuel_engine_pump_on_R = 1 end
	if boost_R_value == -1 then fuel_engine_pump_on_R = 2 end
	-----------------

end

