
---------------------------------------------------------------------------
-- DEALING WITH SPEEDBRAKES HANDLE
---------------------------------------------------------------------------



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


------------ SPEEDBRAKES HANDLE FUNCTION
function func_speedbrakes_handle_ratio()
	--none
end




----------------------------------- LOCATE AND CREATE DATAREFS / COMMANDS -----------------------------------

speedbrake_ratio = find_dataref("sim/cockpit2/controls/speedbrake_ratio") --> -0.5 is armed, 0 to 1 is ratio of deflection

CitX_speedbrakes_handle_ratio = create_dataref("laminar/CitX/speedbrakes/handle_ratio","number",func_speedbrakes_handle_ratio) --> driven by manipulator


--------------------------------- RUNTIME ---------------------------------

-- DO THIS EACH FLIGHT START
function flight_start()
	CitX_speedbrakes_handle_ratio = speedbrake_ratio
end


-- REGULAR RUNTIME
function after_physics()

	-- PREVENT THE ARMED POSITION (CitX has not)
	if speedbrake_ratio < 0 then speedbrake_ratio = 0 end

	-- KEEP SPEEDBRAKE HANDLE SYNC WITH THE XPLANE DATAREF BY SLOWLY ANIMATE IT
	if CitX_speedbrakes_handle_ratio ~= speedbrake_ratio then
		CitX_speedbrakes_handle_ratio = func_animate_slowly(speedbrake_ratio, CitX_speedbrakes_handle_ratio, 15)
	end

end


