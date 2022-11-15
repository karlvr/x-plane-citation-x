
---------------------------------------------------------------------------
-- DEALING WITH PARK BRAKE AND THE EMERGENCY SYSTEM
-- JUST APPLYING FULL PARK BRAKE RATIO IF THE EMERGENCY HANDLE IS PULLED
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


------------ EMPTY FUNCTION FOR WRITABLE DATAREF
--function func_do_nothing()
		--nothing
--end


------------ NORMAL PARK BRAKE FUNCTION
function func_park_handle()
	if brakes_emergency_handle < 0.2 then
		parking_brake_ratio = brakes_park_handle
	end
end


------------ EMERGENCY BRAKE FUNCTION
function func_emergency_handle()
	if brakes_emergency_handle > 0.2 then
		parking_brake_ratio = brakes_emergency_handle
	else
		parking_brake_ratio = 0
	end
end



----------------------------------- LOCATE OR CREATE DATAREFS AND COMMANDS -----------------------------------

parking_brake_ratio = find_dataref("sim/cockpit2/controls/parking_brake_ratio")

brakes_park_handle = create_dataref("laminar/CitX/brakes/park_handle","number",func_park_handle) --> driven by the cockpit manipulator
brakes_emergency_handle = create_dataref("laminar/CitX/brakes/emergency_handle","number",func_emergency_handle) --> driven by the cockpit manipulator



--------------------------------- RUNTIME ---------------------------------

-- DO THIS EACH FLIGHT START
function flight_start()
	brakes_park_handle = parking_brake_ratio
	brakes_emergency_handle = 0
end


-- REGULAR RUNTIME
function after_physics()

	-- KEEP PARK HANDLE POSITION SYNC WITH THE XPLANE PARK DATAREF
	if brakes_emergency_handle < 0.2 then
		if brakes_park_handle ~= parking_brake_ratio then
			brakes_park_handle = func_animate_slowly(parking_brake_ratio,brakes_park_handle,5)
		end
	end

	-- KEEP EMERGENCY HANDLE POSITION SYNC WITH THE XPLANE PARK DATAREF
	if brakes_emergency_handle > 0.2 then
		if brakes_emergency_handle ~= parking_brake_ratio then
			brakes_emergency_handle = func_animate_slowly(parking_brake_ratio,brakes_emergency_handle,5)
		end
	end

end


