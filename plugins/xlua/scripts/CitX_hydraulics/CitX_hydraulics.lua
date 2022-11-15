
------------------------------------------------------------------------------------------------
-- HYDRAULICS SYSTEMS
-- JUST INTERFACING CUSTOM DATAREFS WITH X-PLANE INTERNAL ONES
--
-- PS: ANTISKID IS PART OF BRAKES CODE AND CONSIDERED ALWAYS ON IN X-PLANE
-------------------------------------------------------------------------------------------------




----------------------------------- LOCATE DATAREFS -----------------------------------

startup_running = find_dataref("sim/operation/prefs/startup_running")
electric_hydraulic_pump_on = find_dataref("sim/cockpit2/switches/electric_hydraulic_pump_on")
--electric_hydraulic_pump_on = find_dataref("sim/cockpit2/hydraulics/actuators/electric_hydraulic_pump_on") -- *** NEW FROM PHILIPP BUT DO THE SAME ***
--hydraulic_fluid_ratio_1 = find_dataref("sim/cockpit2/hydraulics/indicators/hydraulic_fluid_ratio_1") --> ratio, read only
--hydraulic_fluid_ratio_2 = find_dataref("sim/cockpit2/hydraulics/indicators/hydraulic_fluid_ratio_2") --> ratio, read only
--hydraulic_quantity_1 = find_dataref("sim/cockpit/misc/hydraulic_quantity") --> ratio, writable
--hydraulic_quantity_2 = find_dataref("sim/cockpit/misc/hydraulic_quantity2") --> ratio, writable
engine_pump_A = find_dataref("sim/cockpit2/hydraulics/actuators/engine_pump[0]") -- FOR UNLOAD SWITCHES
engine_pump_B = find_dataref("sim/cockpit2/hydraulics/actuators/engine_pump[1]") -- NORM is on=1 and UNLOAD is Off=0



------------------------------ DATAREFS AND COMMANDS FUNCTIONS -----------------------------


----------------------------------- HYDRAULICS AUX PUMP SWITCH
function cmd_aux_pump_toggle(phase, duration)
	if phase == 0 then aux_pump_value = math.abs(aux_pump_value - 1) end
end


----------------------------------- UNLOAD HYDRAULICS PUMP A SWITCH
function cmd_unload_pump_A_toggle(phase, duration)
	if phase == 0 then unload_pump_A_value = math.abs(unload_pump_A_value - 1) end
end


----------------------------------- UNLOAD HYDRAULICS PUMP B SWITCH
function cmd_unload_pump_B_toggle(phase, duration)
	if phase == 0 then unload_pump_B_value = math.abs(unload_pump_B_value - 1) end
end


----------------------------------- ANTI SKID SWITCH
function cmd_antiskid_toggle(phase, duration)
	if phase == 0 then antiskid_value = math.abs(antiskid_value - 1) end
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

CitX_aux_pump = create_dataref("laminar/CitX/hydraulics/aux_pump","number")
CitX_unload_pump_A = create_dataref("laminar/CitX/hydraulics/unload_pump_A","number")
CitX_unload_pump_B = create_dataref("laminar/CitX/hydraulics/unload_pump_B","number")
CitX_antiskid = create_dataref("laminar/CitX/hydraulics/antiskid","number") --> 0 = norm, 1 = off (always norm)
antiskid_value = create_dataref("laminar/CitX/hydraulics/antiskid_term","number") --> 0 = norm, 1 = off (always norm)


cmdauxpumptog = create_command("laminar/CitX/hydraulics/cmd_aux_pump_toggle","Hydraulics aux pump toggle",cmd_aux_pump_toggle)

cmdunloadpumpAtog = create_command("laminar/CitX/hydraulics/cmd_unload_pump_A_toggle","Unload hydraulics pump A toggle",cmd_unload_pump_A_toggle)
cmdunloadpumpBtog = create_command("laminar/CitX/hydraulics/cmd_unload_pump_B_toggle","Unload hydraulics pump B toggle",cmd_unload_pump_B_toggle)
cmdantiskidtog = create_command("laminar/CitX/hydraulics/cmd_antiskid_toggle","Anti skid toggle",cmd_antiskid_toggle)




--------------------------------- DO THIS EACH FLIGHT START ---------------------------------
function flight_start()

	aux_pump_value = startup_running
	unload_pump_A_value = 0
	unload_pump_B_value = 0
	antiskid_value = 0

end





--------------------------------- REGULAR RUNTIME ---------------------------------
function after_physics()

	-- AUX PUMP SWITCH --
	-- SLOWLY ANIMATE:
	if CitX_aux_pump ~= aux_pump_value then
		CitX_aux_pump = func_animate_slowly(aux_pump_value, CitX_aux_pump, 40)
	end
	-- SYSTEM LOGIC:
	if aux_pump_value == 1 then
		electric_hydraulic_pump_on = 1
	else
		electric_hydraulic_pump_on = 0
	end
	-----------------


	-- UNLOAD PUMP A SWITCH --
	-- SLOWLY ANIMATE:
	if CitX_unload_pump_A ~= unload_pump_A_value then
		CitX_unload_pump_A = func_animate_slowly(unload_pump_A_value, CitX_unload_pump_A, 40)
	end
	-- SYSTEM LOGIC (*** NORM is on=1 and UNLOAD is Off=0 ***):
	if unload_pump_A_value == 1 then
		engine_pump_A = 0
	else
		engine_pump_A = 1
	end
	-----------------


	-- UNLOAD PUMP B SWITCH --
	-- SLOWLY ANIMATE:
	if CitX_unload_pump_B ~= unload_pump_B_value then
		CitX_unload_pump_B = func_animate_slowly(unload_pump_B_value, CitX_unload_pump_B, 40)
	end
	-- SYSTEM LOGIC (*** NORM is on=1 and UNLOAD is Off=0 ***):
	if unload_pump_B_value == 1 then
		engine_pump_B = 0
	else
		engine_pump_B = 1
	end
	-----------------


	-- ANTI SKID SWITCH --
	-- SLOWLY ANIMATE:
	if CitX_antiskid ~= antiskid_value then
		CitX_antiskid = func_animate_slowly(antiskid_value, CitX_antiskid, 40)
	end
	-- SYSTEM LOGIC:
	-- NOT USED YET CAUSE ANTISKID IS PART OF BRAKES CODE AND CONSIDERED ALWAYS ON IN X-PLANE --
	-- if antiskid_value == 1 then
		-- ???
	-- else
		-- ???
	-- end
	-----------------

end

