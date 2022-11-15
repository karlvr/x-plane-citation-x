
------------------------------------------------------------------------------------------------
-- CUSTOM PRIMUS AVIONICS BUTTONS AND KNOBS
-- INTERFACING CUSTOM CMD/DATAREFS WITH X-PLANE INTERNAL ONES
--
-- PRIMUS PFD1 KNOB: INSTR[7] ---|
-- PRIMUS MFD1 KNOB: INSTR[8]    |
-- PRIMUS EICAS KNOB: INSTR[9]   |
-- PRIMUS MFD2 KNOB: INSTR[10]   |
-- PRIMUS PFD2 KNOB: INSTR[11]   |---> LIT REHOSTATS ASSIGNED IN THE "cockpit_primus_screens.obj"
-- CDU1: INSTR[12]               |
-- CDU2: INSTR[13]               |
-- PRIMUS RMU1: INSTR[14]        |
-- PRIMUS RMU2: INSTR[15] -------|
--
-------------------------------------------------------------------------------------------------



-------------------------------------------------------------------------
------------------------------- FUNCTIONS -------------------------------
-------------------------------------------------------------------------

-- EMPTY PLACEHOLDER FUNCTION
function func_do_nothing()
	--nothing
end


----------------------------------- SLOWLY ANIMATE FUNCTION
--function func_animate_slowly(reference_value, animated_VALUE, anim_speed)
--	SPD_PERIOD = anim_speed * SIM_PERIOD
--	if SPD_PERIOD > 1 then SPD_PERIOD = 1 end
--	animated_VALUE = animated_VALUE + ((reference_value - animated_VALUE) * SPD_PERIOD)
--	delta = math.abs(animated_VALUE - reference_value)
--	if delta < 0.05 then animated_VALUE = reference_value end
--	return animated_VALUE
--end


----------------------------------- BUTTON FUNCTIONS
-- BUTTON PLACEHOLDER
function cmd_placeholder_funct(phase, duration)
	if phase == 0 and pwr_on == 1 then
		--valuexxx = math.abs((valuexxx + 1) - 2) --> TOGGLE FROM 0 TO 1
		--> HERE THE FUNCTION
	end
end

----------------------------------- UP/DWN KNOB FUNCTIONS
-- KNOBS EFIS SOURCES PILOT
function cmd_source1_pilot_up_funct(phase, duration)
	if phase == 0 then
		if EFIS_1_selection_pilot == 0 then
			EFIS_1_selection_pilot = 3
		elseif EFIS_1_selection_pilot == 1 then
			EFIS_1_selection_pilot = 2
		elseif EFIS_1_selection_pilot == 2 then
			EFIS_1_selection_pilot = 0
		end
	end
end
function cmd_source1_pilot_dwn_funct(phase, duration)
	if phase == 0 then
		if EFIS_1_selection_pilot == 3 then
			EFIS_1_selection_pilot = 0
		elseif EFIS_1_selection_pilot == 2 then
			EFIS_1_selection_pilot = 1
		elseif EFIS_1_selection_pilot == 0 then
			EFIS_1_selection_pilot = 2
		end
	end
end
function cmd_source2_pilot_up_funct(phase, duration)
	if phase == 0 then
		if EFIS_2_selection_pilot == 0 then
			EFIS_2_selection_pilot = 3
		elseif EFIS_2_selection_pilot == 1 then
			EFIS_2_selection_pilot = 2
		elseif EFIS_2_selection_pilot == 2 then
			EFIS_2_selection_pilot = 0
		end
	end
end
function cmd_source2_pilot_dwn_funct(phase, duration)
	if phase == 0 then
		if EFIS_2_selection_pilot == 3 then
			EFIS_2_selection_pilot = 0
		elseif EFIS_2_selection_pilot == 2 then
			EFIS_2_selection_pilot = 1
		elseif EFIS_2_selection_pilot == 0 then
			EFIS_2_selection_pilot = 2
		end
	end
end

-- KNOBS EFIS SOURCES COPILOT
function cmd_source1_copilot_up_funct(phase, duration)
	if phase == 0 then
		if EFIS_1_selection_copilot == 0 then
			EFIS_1_selection_copilot = 3
		elseif EFIS_1_selection_copilot == 1 then
			EFIS_1_selection_copilot = 2
		elseif EFIS_1_selection_copilot == 2 then
			EFIS_1_selection_copilot = 0
		end
	end
end
function cmd_source1_copilot_dwn_funct(phase, duration)
	if phase == 0 then
		if EFIS_1_selection_copilot == 3 then
			EFIS_1_selection_copilot = 0
		elseif EFIS_1_selection_copilot == 2 then
			EFIS_1_selection_copilot = 1
		elseif EFIS_1_selection_copilot == 0 then
			EFIS_1_selection_copilot = 2
		end
	end
end
function cmd_source2_copilot_up_funct(phase, duration)
	if phase == 0 then
		if EFIS_2_selection_copilot == 0 then
			EFIS_2_selection_copilot = 3
		elseif EFIS_2_selection_copilot == 1 then
			EFIS_2_selection_copilot = 2
		elseif EFIS_2_selection_copilot == 2 then
			EFIS_2_selection_copilot = 0
		end
	end
end
function cmd_source2_copilot_dwn_funct(phase, duration)
	if phase == 0 then
		if EFIS_2_selection_copilot == 3 then
			EFIS_2_selection_copilot = 0
		elseif EFIS_2_selection_copilot == 2 then
			EFIS_2_selection_copilot = 1
		elseif EFIS_2_selection_copilot == 0 then
			EFIS_2_selection_copilot = 2
		end
	end
end

-- JUST ROTATE THE RMU RADIO KNOBS
function cmd_rmu1_fine_up_funct(phase, duration)
	if phase == 0 then CitX_rmu1_fine_knob = CitX_rmu1_fine_knob + 5 end
end
function cmd_rmu1_fine_dwn_funct(phase, duration)
	if phase == 0 then CitX_rmu1_fine_knob = CitX_rmu1_fine_knob - 5 end
end
function cmd_rmu1_coarse_up_funct(phase, duration)
	if phase == 0 then CitX_rmu1_coarse_knob = CitX_rmu1_coarse_knob + 5 end
end
function cmd_rmu1_coarse_dwn_funct(phase, duration)
	if phase == 0 then CitX_rmu1_coarse_knob = CitX_rmu1_coarse_knob - 5 end
end
function cmd_rmu2_fine_up_funct(phase, duration)
	if phase == 0 then CitX_rmu2_fine_knob = CitX_rmu2_fine_knob + 5 end
end
function cmd_rmu2_fine_dwn_funct(phase, duration)
	if phase == 0 then CitX_rmu2_fine_knob = CitX_rmu2_fine_knob - 5 end
end
function cmd_rmu2_coarse_up_funct(phase, duration)
	if phase == 0 then CitX_rmu2_coarse_knob = CitX_rmu2_coarse_knob + 5 end
end
function cmd_rmu2_coarse_dwn_funct(phase, duration)
	if phase == 0 then CitX_rmu2_coarse_knob = CitX_rmu2_coarse_knob - 5 end
end

-- LIGHT REHOSTATS PFD/MFD/EICAS PILOT AND COPILOT
function cmd_pfd_dim_pilot_up_funct(phase, duration)
	if PFD1_lit_ratio < 1 then
		if phase == 0 then PFD1_lit_ratio = PFD1_lit_ratio + 0.05 end
		if phase == 1 and duration > 0.5 then PFD1_lit_ratio = PFD1_lit_ratio + 0.01 end
	end
end
function cmd_pfd_dim_pilot_dwn_funct(phase, duration)
	if PFD1_lit_ratio > 0 then
		if phase == 0 then PFD1_lit_ratio = PFD1_lit_ratio - 0.05 end
		if phase == 1 and duration > 0.5 then PFD1_lit_ratio = PFD1_lit_ratio - 0.01 end
	end
end
function cmd_mfd_dim_pilot_up_funct(phase, duration)
	if MFD1_lit_ratio < 1 then
		if phase == 0 then MFD1_lit_ratio = MFD1_lit_ratio + 0.05 end
		if phase == 1 and duration > 0.5 then MFD1_lit_ratio = MFD1_lit_ratio + 0.01 end
	end
end
function cmd_mfd_dim_pilot_dwn_funct(phase, duration)
	if MFD1_lit_ratio > 0 then
		if phase == 0 then MFD1_lit_ratio = MFD1_lit_ratio - 0.05 end
		if phase == 1 and duration > 0.5 then MFD1_lit_ratio = MFD1_lit_ratio - 0.01 end
	end
end
function cmd_eicas_dim_up_funct(phase, duration)
	if EICAS_lit_ratio < 1 then
		if phase == 0 then EICAS_lit_ratio = EICAS_lit_ratio + 0.05 end
		if phase == 1 and duration > 0.5 then EICAS_lit_ratio = EICAS_lit_ratio + 0.01 end
	end
end
function cmd_eicas_dim_dwn_funct(phase, duration)
	if EICAS_lit_ratio > 0 then
		if phase == 0 then EICAS_lit_ratio = EICAS_lit_ratio - 0.05 end
		if phase == 1 and duration > 0.5 then EICAS_lit_ratio = EICAS_lit_ratio - 0.01 end
	end
end
function cmd_mfd_dim_copilot_up_funct(phase, duration)
	if MFD2_lit_ratio < 1 then
		if phase == 0 then MFD2_lit_ratio = MFD2_lit_ratio + 0.05 end
		if phase == 1 and duration > 0.5 then MFD2_lit_ratio = MFD2_lit_ratio + 0.01 end
	end
end
function cmd_mfd_dim_copilot_dwn_funct(phase, duration)
	if MFD2_lit_ratio > 0 then
		if phase == 0 then MFD2_lit_ratio = MFD2_lit_ratio - 0.05 end
		if phase == 1 and duration > 0.5 then MFD2_lit_ratio = MFD2_lit_ratio - 0.01 end
	end
end
function cmd_pfd_dim_copilot_up_funct(phase, duration)
	if PFD2_lit_ratio < 1 then
		if phase == 0 then PFD2_lit_ratio = PFD2_lit_ratio + 0.05 end
		if phase == 1 and duration > 0.5 then PFD2_lit_ratio = PFD2_lit_ratio + 0.01 end
	end
end
function cmd_pfd_dim_copilot_dwn_funct(phase, duration)
	if PFD2_lit_ratio > 0 then
		if phase == 0 then PFD2_lit_ratio = PFD2_lit_ratio - 0.05 end
		if phase == 1 and duration > 0.5 then PFD2_lit_ratio = PFD2_lit_ratio - 0.01 end
	end
end

-- LIGHT REHOSTATS CDU PILOT AND COPILOT
function cmd_cdu_dim_pilot_up_funct(phase, duration)
	if CDU1_lit_ratio < 1 then
		if phase == 0 then CDU1_lit_ratio = CDU1_lit_ratio + 0.05 end
		if phase == 1 and duration > 0.5 then CDU1_lit_ratio = CDU1_lit_ratio + 0.01 end
	end
end
function cmd_cdu_dim_pilot_dwn_funct(phase, duration)
	if CDU1_lit_ratio > 0 then
		if phase == 0 then CDU1_lit_ratio = CDU1_lit_ratio - 0.05 end
		if phase == 1 and duration > 0.5 then CDU1_lit_ratio = CDU1_lit_ratio - 0.01 end
	end
end
function cmd_cdu_dim_copilot_up_funct(phase, duration)
	if CDU2_lit_ratio < 1 then
		if phase == 0 then CDU2_lit_ratio = CDU2_lit_ratio + 0.05 end
		if phase == 1 and duration > 0.5 then CDU2_lit_ratio = CDU2_lit_ratio + 0.01 end
	end
end
function cmd_cdu_dim_copilot_dwn_funct(phase, duration)
	if CDU2_lit_ratio > 0 then
		if phase == 0 then CDU2_lit_ratio = CDU2_lit_ratio - 0.05 end
		if phase == 1 and duration > 0.5 then CDU2_lit_ratio = CDU2_lit_ratio - 0.01 end
	end
end








--------------------------------------------------------------------------------
----------------------------------- DATAREFS -----------------------------------
--------------------------------------------------------------------------------

-- LOCATE --
startup_running = find_dataref("sim/operation/prefs/startup_running")
bus_volts_0 = find_dataref("sim/cockpit2/electrical/bus_volts[0]") --> apu/ext/stby bus
bus_volts_1 = find_dataref("sim/cockpit2/electrical/bus_volts[1]") --> L bus
bus_volts_2 = find_dataref("sim/cockpit2/electrical/bus_volts[2]") --> R bus
EFIS_1_selection_pilot = find_dataref("sim/cockpit2/EFIS/EFIS_1_selection_pilot") --> 0 = ADF, 1= OFF, 2=VOR and 3=FMS
EFIS_2_selection_pilot = find_dataref("sim/cockpit2/EFIS/EFIS_2_selection_pilot")
EFIS_1_selection_copilot = find_dataref("sim/cockpit2/EFIS/EFIS_1_selection_copilot")
EFIS_2_selection_copilot = find_dataref("sim/cockpit2/EFIS/EFIS_2_selection_copilot")
EL_lit_ratio = find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[0]") --> EL instruments knob
PFD1_lit_ratio = find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[7]") --> PFD pilot knob
MFD1_lit_ratio = find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[8]") --> MFD pilot knob
EICAS_lit_ratio = find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[9]") --> EICAS knob
MFD2_lit_ratio = find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[10]") --> MFD copilot knob
PFD2_lit_ratio = find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[11]") --> PFD copilot knob
CDU1_lit_ratio = find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[12]") --> CDU1 pilot knob
CDU2_lit_ratio = find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[13]") --> CDU2 copilot knob
RMU1_lit_ratio = find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[14]") --> RMU1 pilot knob
RMU2_lit_ratio = find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[15]") --> RMU2 copilot knob

-- CREATE --
CitX_rmu1_fine_knob = create_dataref("laminar/CitX/radios/rmu1_fine_knob","number") --> for knob animation only
CitX_rmu1_coarse_knob = create_dataref("laminar/CitX/radios/rmu1_coarse_knob","number")
CitX_rmu2_fine_knob = create_dataref("laminar/CitX/radios/rmu2_fine_knob","number")
CitX_rmu2_coarse_knob = create_dataref("laminar/CitX/radios/rmu2_coarse_knob","number")







--------------------------------------------------------------------------------
----------------------------------- COMMANDS -----------------------------------
--------------------------------------------------------------------------------

-- LOCATE --
cmd_rmu1_fine_up = wrap_command("sim/radios/rmu1/fine_up",func_do_nothing,cmd_rmu1_fine_up_funct)
cmd_rmu1_fine_dwn = wrap_command("sim/radios/rmu1/fine_down",func_do_nothing,cmd_rmu1_fine_dwn_funct)
cmd_rmu1_coarse_up = wrap_command("sim/radios/rmu1/coarse_up",func_do_nothing,cmd_rmu1_coarse_up_funct)
cmd_rmu1_coarse_dwn = wrap_command("sim/radios/rmu1/coarse_down",func_do_nothing,cmd_rmu1_coarse_dwn_funct)
cmd_rmu2_fine_up = wrap_command("sim/radios/rmu2/fine_up",func_do_nothing,cmd_rmu2_fine_up_funct)
cmd_rmu2_fine_dwn = wrap_command("sim/radios/rmu2/fine_down",func_do_nothing,cmd_rmu2_fine_dwn_funct)
cmd_rmu2_coarse_up = wrap_command("sim/radios/rmu2/coarse_up",func_do_nothing,cmd_rmu2_coarse_up_funct)
cmd_rmu2_coarse_dwn = wrap_command("sim/radios/rmu2/coarse_down",func_do_nothing,cmd_rmu2_coarse_dwn_funct)

-- CREATE --
cmd_source1_pilot_up = create_command("laminar/CitX/primus/cmd_source1_pilot_up","Primus EFIS1 source pilot up",cmd_source1_pilot_up_funct)
cmd_source1_pilot_dwn = create_command("laminar/CitX/primus/cmd_source1_pilot_dwn","Primus EFIS1 source pilot down",cmd_source1_pilot_dwn_funct)
cmd_source2_pilot_up = create_command("laminar/CitX/primus/cmd_source2_pilot_up","Primus EFIS2 source pilot up",cmd_source2_pilot_up_funct)
cmd_source2_pilot_dwn = create_command("laminar/CitX/primus/cmd_source2_pilot_dwn","Primus EFIS2 source pilot down",cmd_source2_pilot_dwn_funct)
cmd_source1_copilot_up = create_command("laminar/CitX/primus/cmd_source1_copilot_up","Primus EFIS1 source copilot up",cmd_source1_copilot_up_funct)
cmd_source1_copilot_dwn = create_command("laminar/CitX/primus/cmd_source1_copilot_dwn","Primus EFIS1 source copilot down",cmd_source1_copilot_dwn_funct)
cmd_source2_copilot_up = create_command("laminar/CitX/primus/cmd_source2_copilot_up","Primus EFIS2 source copilot up",cmd_source2_copilot_up_funct)
cmd_source2_copilot_dwn = create_command("laminar/CitX/primus/cmd_source2_copilot_dwn","Primus EFIS2 source copilot down",cmd_source2_copilot_dwn_funct)
cmd_pfd_dim_pilot_up = create_command("laminar/CitX/primus/cmd_pfd_dim_pilot_up","Primus PFD bright pilot up",cmd_pfd_dim_pilot_up_funct)
cmd_pfd_dim_pilot_dwn = create_command("laminar/CitX/primus/cmd_pfd_dim_pilot_dwn","Primus PFD bright pilot down",cmd_pfd_dim_pilot_dwn_funct)
cmd_mfd_dim_pilot_up = create_command("laminar/CitX/primus/cmd_mfd_dim_pilot_up","Primus MFD bright pilot up",cmd_mfd_dim_pilot_up_funct)
cmd_mfd_dim_pilot_dwn = create_command("laminar/CitX/primus/cmd_mfd_dim_pilot_dwn","Primus MFD bright pilot down",cmd_mfd_dim_pilot_dwn_funct)
cmd_eicas_dim_up = create_command("laminar/CitX/primus/cmd_eicas_dim_up","Primus EICAS bright up",cmd_eicas_dim_up_funct)
cmd_eicas_dim_dwn = create_command("laminar/CitX/primus/cmd_eicas_dim_dwn","Primus EICAS bright down",cmd_eicas_dim_dwn_funct)
cmd_pfd_dim_copilot_up = create_command("laminar/CitX/primus/cmd_pfd_dim_copilot_up","Primus PFD bright copilot up",cmd_pfd_dim_copilot_up_funct)
cmd_pfd_dim_copilot_dwn = create_command("laminar/CitX/primus/cmd_pfd_dim_copilot_dwn","Primus PFD bright copilot down",cmd_pfd_dim_copilot_dwn_funct)
cmd_mfd_dim_copilot_up = create_command("laminar/CitX/primus/cmd_mfd_dim_copilot_up","Primus MFD bright copilot up",cmd_mfd_dim_copilot_up_funct)
cmd_mfd_dim_copilot_dwn = create_command("laminar/CitX/primus/cmd_mfd_dim_copilot_dwn","Primus MFD bright copilot down",cmd_mfd_dim_copilot_dwn_funct)
cmd_cdu_dim_pilot_up = create_command("laminar/CitX/FMS1/cmd_bright_up","CDU bright pilot up",cmd_cdu_dim_pilot_up_funct)
cmd_cdu_dim_pilot_dwn = create_command("laminar/CitX/FMS1/cmd_bright_dwn","CDU bright pilot down",cmd_cdu_dim_pilot_dwn_funct)
cmd_cdu_dim_copilot_up = create_command("laminar/CitX/FMS2/cmd_bright_up","CDU bright copilot up",cmd_cdu_dim_copilot_up_funct)
cmd_cdu_dim_copilot_dwn = create_command("laminar/CitX/FMS2/cmd_bright_dwn","CDU bright copilot down",cmd_cdu_dim_copilot_dwn_funct)






----------------------------------------------------------------------------------
--------------------------------- INITIALIZATION ---------------------------------
----------------------------------------------------------------------------------

-- DO THIS EACH FLIGHT START
function flight_start()

	pwr_on = startup_running

end






---------------------------------------------------------------------------
--------------------------------- RUNTIME ---------------------------------
---------------------------------------------------------------------------

function after_physics()

	-- EVALUATE IF POWER ON BUSES (BUS 0 IS JUST STBY PWR)
	if bus_volts_1 + bus_volts_2 > 1 then pwr_on = 1 else pwr_on = 0 end
	
	-- KEEP RMU (RADIOS) BRIGHTNESS KNOB SYNCH WITH THE GENERAL EL INSTRUMENTS ONE
	-- SINCE WE DO NOT SIMULATE THE DIM FUNCTION ON THE RMU UNITS (WHICH ENABLE BRIGHTNESS CONTROL THROUGH FREQ KNOB)
	RMU1_lit_ratio = EL_lit_ratio
	RMU2_lit_ratio = EL_lit_ratio
	
end


