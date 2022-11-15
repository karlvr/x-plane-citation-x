
-----------------------------------------------------------------------------------
-- THIS SCRIPT IS HERE FOR THE FOLLOWING STANDBY STUFF:
--
-- ARTIFICIAL HORIZON REFERENCE BAR AND KNOB -> CUSTOM DATAREF AND UP/DWN COMMANDS
--
-- ARTIFICIAL HORIZON "PULL TO CAGE" RATIO KNOB -> CUSTOM COMMAND/SPRING
-- (THE STBY ARTIFICIAL HORIZON IS ELECTRIC DRIVEN, AND ENUMS FOR GYROS DATAREFS ARE:
-- [0]ahrs1,[1]ahrs2,[2]elec1,[3]elec2,[4]vac1,[5]vac2 SO OUR ELECTRICAL STANDBY GYRO IS [2])
--
-- STANDBY INSTRUMENTS LIGHT -> CUSTOM DATAREF
-- (STBY INSTRS ARE CONTROLLED BY THE INSTR_BRIGHT_RATIO[0],
-- BUT THEY ALSO LIGHT UP IF THE STBY PWR BATT IS ON)
--
-- STANDBY RADIO -> CUSTOM DATAREFS AND COMMANDS FOR BUTTONS AND KNOBS
-----------------------------------------------------------------------------------



----------------------------------- LOCATE DATAREFS AND COMMANDS -----------------------------------

gyr_cage_ratio = find_dataref("sim/cockpit/gyros/gyr_cage_ratio[2]") --> 0 for fully free, 1 for fully caged
bus_volts_STBY = find_dataref("sim/cockpit2/electrical/bus_volts[0]")
brightness_EL_knob = find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[0]")
brightness_EL_actual = find_dataref("sim/cockpit2/electrical/instrument_brightness_ratio_manual[0]")
stby_battery_on = find_dataref("sim/cockpit2/electrical/battery_on[0]")

cmd_actv_com1_coarse_down = find_command("sim/radios/actv_com1_coarse_down")
cmd_actv_com1_coarse_up = find_command("sim/radios/actv_com1_coarse_up")
cmd_actv_com1_fine_down = find_command("sim/radios/actv_com1_fine_down")
cmd_actv_com1_fine_up = find_command("sim/radios/actv_com1_fine_up")
cmd_actv_nav1_coarse_down = find_command("sim/radios/actv_nav1_coarse_down")
cmd_actv_nav1_coarse_up = find_command("sim/radios/actv_nav1_coarse_up")
cmd_actv_nav1_fine_down = find_command("sim/radios/actv_nav1_fine_down")
cmd_actv_nav1_fine_up = find_command("sim/radios/actv_nav1_fine_up")
cmd_monitor_audio_nav1 = find_command("sim/audio_panel/monitor_audio_nav1")



------------------------------ DATAREFS AND COMMANDS FUNCTIONS -----------------------------

-- REFERENCE BAR DATAREF FUNCTION
function func_horiz_adj_deg()
end


-- REFERENCE BAR UP AND DOWN COMMANDS FUNCTION
function cmd_horiz_adj_deg_up(phase, duration)
	if phase == 0 or phase == 1 then
		CitX_horiz_adj_deg_knob = CitX_horiz_adj_deg_knob + 0.25
		if CitX_horiz_adj_deg_knob < 10 then CitX_horiz_adj_deg = CitX_horiz_adj_deg + 0.25 end
		if CitX_horiz_adj_deg_knob > 10 then CitX_horiz_adj_deg = CitX_horiz_adj_deg - 0.25 end
		if CitX_horiz_adj_deg_knob > 30 then CitX_horiz_adj_deg_knob = CitX_horiz_adj_deg end
	end
end
function cmd_horiz_adj_deg_dwn(phase, duration)
	if phase == 0 or phase == 1 then
		CitX_horiz_adj_deg_knob = CitX_horiz_adj_deg_knob - 0.25
		if CitX_horiz_adj_deg_knob > -10 then CitX_horiz_adj_deg = CitX_horiz_adj_deg - 0.25 end
		if CitX_horiz_adj_deg_knob < -10 then CitX_horiz_adj_deg = CitX_horiz_adj_deg + 0.25 end
		if CitX_horiz_adj_deg_knob < -30 then CitX_horiz_adj_deg_knob = CitX_horiz_adj_deg end
	end
end


-- PULL TO CAGE COMMAND FUNCTION
function cmd_gyr_cage(phase, duration)
	if phase == 1 then
		gyr_now_caged = 1
		if gyr_cage_ratio < 1 then gyr_cage_ratio = gyr_cage_ratio + 0.1 * (100 * SIM_PERIOD) end
	end
	if phase == 2 then
		gyr_now_caged = 0
	end
end


-- RADIO KNOBS FREQUENCY UP / DOWN COMMANDS FUNCTION
function cmd_radio_knob_coarse_up(phase, duration)
	if phase == 0 then
		CitX_radio_knob_freq_coarse = CitX_radio_knob_freq_coarse + 15
		if CitX_radio_select == 0 then
			cmd_actv_com1_coarse_up:once()
		else
			cmd_actv_nav1_coarse_up:once()
		end
	end
end
function cmd_radio_knob_coarse_dwn(phase, duration)
	if phase == 0 then
		CitX_radio_knob_freq_coarse = CitX_radio_knob_freq_coarse - 15
		if CitX_radio_select == 0 then
			cmd_actv_com1_coarse_down:once()
		else
			cmd_actv_nav1_coarse_down:once()
		end
	end
end
function cmd_radio_knob_fine_up(phase, duration)
	if phase == 0 then
		CitX_radio_knob_freq_fine = CitX_radio_knob_freq_fine + 15
		if CitX_radio_select == 0 then
			cmd_actv_com1_fine_up:once()
		else
			cmd_actv_nav1_fine_up:once()
		end
	end
end
function cmd_radio_knob_fine_dwn(phase, duration)
	if phase == 0 then
		CitX_radio_knob_freq_fine = CitX_radio_knob_freq_fine - 15
		if CitX_radio_select == 0 then
			cmd_actv_com1_fine_down:once()
		else
			cmd_actv_nav1_fine_down:once()
		end
	end
end


-- RADIO BUTTON TOGGLE COM/NAV FUNCTION
function cmd_radio_toggle_com_nav(phase, duration)
	if phase == 0 then
		CitX_radio_select = math.abs(CitX_radio_select - 1) --> TOGGLE FROM 0 TO 1
	end
end



----------------------------------- CREATE DATAREFS AND COMMANDS -----------------------------------

CitX_horiz_adj_deg = create_dataref("laminar/CitX/standby/horiz_adj_deg","number",func_horiz_adj_deg)
CitX_horiz_adj_deg_knob = create_dataref("laminar/CitX/standby/horiz_adj_deg_knob","number")
CitX_brightness_STBY = create_dataref("laminar/CitX/lights/stby_instr_brightness_ratio","number")
CitX_radio_select = create_dataref("laminar/CitX/standby/radio_select","number") --> 0=com, 1=nav
CitX_radio_knob_freq_coarse = create_dataref("laminar/CitX/standby/radio_knob_freq_coarse","number")
CitX_radio_knob_freq_fine = create_dataref("laminar/CitX/standby/radio_knob_freq_fine","number")

cmdhorizadjdegup = create_command("laminar/CitX/standby/horiz_adj_deg_up","Artif. horizon reference bar up",cmd_horiz_adj_deg_up)
cmdhorizadjdegdwn = create_command("laminar/CitX/standby/horiz_adj_deg_dwn","Artif. horizon reference bar down",cmd_horiz_adj_deg_dwn)
cmdgyrcage = create_command("laminar/CitX/standby/gyr_cage","Artif. horizon cage the gyro",cmd_gyr_cage)
cmdradioknobcoarseup = create_command("laminar/CitX/standby/radio_knob_coarse_up","Standby radio freq coarse up",cmd_radio_knob_coarse_up)
cmdradioknobcoarsedwn = create_command("laminar/CitX/standby/radio_knob_coarse_dwn","Standby radio freq coarse down",cmd_radio_knob_coarse_dwn)
cmdradioknobfineup = create_command("laminar/CitX/standby/radio_knob_fine_up","Standby radio freq fine up",cmd_radio_knob_fine_up)
cmdradioknobfinedwn = create_command("laminar/CitX/standby/radio_knob_fine_dwn","Standby radio freq fine down",cmd_radio_knob_fine_dwn)
cmdradiotogglecomnav = create_command("laminar/CitX/standby/radio_toggle_com_nav","Standby radio toggle com/nav",cmd_radio_toggle_com_nav)




--------------------------------- DATAREFS INITIALIZATON ---------------------------------

CitX_horiz_adj_deg = 0
gyr_now_caged = 0
CitX_horiz_adj_deg_knob = 0
CitX_radio_select = 0



--------------------------------- REGULAR RUNTIME ---------------------------------
function after_physics()

	-- HORIZON REFERENCE BAR LIMITS
	if CitX_horiz_adj_deg > 10 then CitX_horiz_adj_deg = 10 end
	if CitX_horiz_adj_deg < -10 then CitX_horiz_adj_deg = -10 end

	-- SPRING OF THE CAGE KNOB TO RETURN TO ZERO
	if gyr_now_caged == 0 and gyr_cage_ratio > 0 then gyr_cage_ratio = gyr_cage_ratio - 0.1 * (100 * SIM_PERIOD) end

	-- LIGHTING LOGIC
	--if stby_battery_on == 1 and bus_volts_STBY > 0 then
	if bus_volts_STBY > 0 then
		CitX_brightness_STBY = brightness_EL_knob
	else
		CitX_brightness_STBY = 0
	end

end

