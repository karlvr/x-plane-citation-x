
-----------------------------------------------------------------
-- DEALING WITH THE LANDING GEAR HANDLE AND ANNUNCIATORS
-----------------------------------------------------------------




------------------------------- FUNCTIONS -------------------------------

-- ANIMATION OF THE GEAR HANDLE
function update_gear_handle()
	landing_gear_handle = landing_gear_handle + ((gear_handle_down - landing_gear_handle) * (10 * SIM_PERIOD))
end
function update_gear_detents()
	landing_gear_detents = landing_gear_detents + ((0 - landing_gear_detents) * (10 * SIM_PERIOD))
end




-- FUNCTIONS FOR WRITABLE DATAREFS --

function landing_gear_handle_func()
	if landing_gear_handle > 0 and landing_gear_handle < 0.5 then
		gear_handle_down = 0
	elseif landing_gear_handle > 0.5 and landing_gear_handle < 1 then
		gear_handle_down = 1
	end
end

function landing_gear_detents_func()
	--none
end






----------------------------------- LOCATE AND CREATE DATAREFS / COMMANDS -----------------------------------

bus_volts_0 = find_dataref("sim/cockpit2/electrical/bus_volts[0]")
bus_volts_1 = find_dataref("sim/cockpit2/electrical/bus_volts[1]")
bus_volts_2 = find_dataref("sim/cockpit2/electrical/bus_volts[2]")
instr_brgh_cntr = find_dataref("sim/cockpit2/electrical/instrument_brightness_ratio_auto[3]") --> brightness ratio central panel
gear_handle_down = find_dataref("sim/cockpit2/controls/gear_handle_down") --> landing gear request: 0 up, 1 down
gear_unsafe = find_dataref("sim/cockpit2/annunciators/gear_unsafe")
gear_deploy_ratio_N = find_dataref("sim/flightmodel2/gear/deploy_ratio[0]")
gear_deploy_ratio_L = find_dataref("sim/flightmodel2/gear/deploy_ratio[1]")
gear_deploy_ratio_R = find_dataref("sim/flightmodel2/gear/deploy_ratio[2]")
CitX_test_landgear = find_dataref("laminar/CitX/test/land_gear") --> test mode from the test script

landing_gear_handle = create_dataref("laminar/CitX/landing_gear/handle","number",landing_gear_handle_func) --> the handle used by the cockpit manipulator
landing_gear_detents = create_dataref("laminar/CitX/landing_gear/handle_detents","number",landing_gear_detents_func) --> the handle detents (lift)
landing_gear_annunc_unsafe = create_dataref("laminar/CitX/landing_gear/annunc_unsafe","number")
landing_gear_annunc_nose = create_dataref("laminar/CitX/landing_gear/annunc_nose","number")
landing_gear_annunc_left = create_dataref("laminar/CitX/landing_gear/annunc_left","number")
landing_gear_annunc_right = create_dataref("laminar/CitX/landing_gear/annunc_right","number")




--------------------------------- RUNTIME ---------------------------------

-- DO THIS EACH FLIGHT START
function flight_start()
	landing_gear_handle = gear_handle_down
end


-- REGULAR RUNTIME
function after_physics()

	-- KEEP THE CUSTOM LAND GEAR POSITION SYNC WITH THE ACTUAL XPLANE ONE
	if landing_gear_handle ~= gear_handle_down then update_gear_handle() end
	if landing_gear_detents > 0 then update_gear_detents() end

	-- ANNUNCIATORS (WILL LIT ANNUNCIATORS ONLY IF POWER ON BUSES AND TEST IS NOT RUNNING - DIMMED BY THE CNTR BRIGH RHEO)
	if bus_volts_1+bus_volts_2 > 0.1 then lit_on = 1 else lit_on = 0 end -- NO BUS 0 SINCE IT IS JUST FOR STBY INSTR
	if CitX_test_landgear == 0 then --> if test is not running
		if gear_unsafe == 1 then landing_gear_annunc_unsafe = 1 * lit_on * instr_brgh_cntr else landing_gear_annunc_unsafe = 0 end
		if gear_deploy_ratio_N > 0.7 then landing_gear_annunc_nose = 1 * lit_on * instr_brgh_cntr else landing_gear_annunc_nose = 0 end
		if gear_deploy_ratio_L > 0.7 then landing_gear_annunc_left = 1 * lit_on * instr_brgh_cntr else landing_gear_annunc_left = 0 end
		if gear_deploy_ratio_R > 0.7 then landing_gear_annunc_right = 1 * lit_on * instr_brgh_cntr else landing_gear_annunc_right = 0 end
	end

end


