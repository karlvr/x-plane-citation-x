
------------------------------------------------------------------------------------------------
-- BLEED AIR AND ENVIRONMENTAL SYSTEM (HVAC/PAC PANEL AT THE BOTTOM RIGHT OF THE COCKPIT)
-- INTERFACING CUSTOM DATAREFS WITH X-PLANE INTERNAL ONES
--
-- (SEE ALSO PRESSURIZATION SCRIPT SINCE BLEED AIR AFFECT PRESSURIZ., AND APU SCRIPT)
-------------------------------------------------------------------------------------------------




----------------------------------- LOCATE DATAREFS -----------------------------------

startup_running = find_dataref("sim/operation/prefs/startup_running")
bus_volts_L = find_dataref("sim/cockpit2/electrical/bus_volts[1]")
bus_volts_R = find_dataref("sim/cockpit2/electrical/bus_volts[2]")
instr_brgh_right = find_dataref("sim/cockpit2/electrical/instrument_brightness_ratio_auto[2]") --> brightness ratio right panel
--bleed_air_mode = find_dataref("sim/cockpit2/pressurization/actuators/bleed_air_mode") --> DEPRECATED!!! 0=off, 1=left,2=both,3=right,4=apu,5=auto
bleed_gpu = find_dataref("sim/cockpit2/bleedair/actuators/gpu_bleed")
bleed_apu = find_dataref("sim/cockpit2/bleedair/actuators/apu_bleed") --> APU BLEED AIR VALVE 0=close, 1=open
bleed_pack_L = find_dataref("sim/cockpit2/bleedair/actuators/pack_left") --> ACTUATOR PACK L (the ckpt pac knob of the panel)
bleed_pack_R = find_dataref("sim/cockpit2/bleedair/actuators/pack_right") --> ACTUATOR PACK R (the cab pac knob of the panel)
bleed_pack_C = find_dataref("sim/cockpit2/bleedair/actuators/pack_center") --> ACTUATOR PACK CENTER (disabled since CITX has not)
bleed_isol_L = find_dataref("sim/cockpit2/bleedair/actuators/isol_valve_left") --> ISOLATION VALVE L (the unique square knob at the middle of the panel)
bleed_isol_R = find_dataref("sim/cockpit2/bleedair/actuators/isol_valve_right") --> ISOLATION VALVE R (always open, since there is no R valve in the CitX)
bleed_engL_sov = find_dataref("sim/cockpit2/bleedair/actuators/engine_bleed_sov[0]") --> SHUT OFF VALVE ENGINE L (the left eng knob of the panel)
bleed_engR_sov = find_dataref("sim/cockpit2/bleedair/actuators/engine_bleed_sov[1]") --> SHUT OFF VALVE ENGINE R (the right eng knob of the panel)
bleed_available_C = find_dataref("sim/cockpit2/bleedair/indicators/bleed_available_center") --> CITX HAS NOT!
bleed_available_L = find_dataref("sim/cockpit2/bleedair/indicators/bleed_available_left")
bleed_available_R = find_dataref("sim/cockpit2/bleedair/indicators/bleed_available_right")
APU_bleed_air_switch = find_dataref("laminar/CitX/APU/bleed_air_switch") --> from the APU script (0=off, 0.5=on, 1=max)
--APU_N1_percent = find_dataref("sim/cockpit2/electrical/APU_N1_percent")
--engine_L_N1_percent = find_dataref("sim/flightmodel2/engines/N1_percent[0]")
--engine_R_N1_percent = find_dataref("sim/flightmodel2/engines/N1_percent[1]")
outside_air_temp_C = find_dataref("sim/cockpit2/temperature/outside_air_temp_degc")
--outside_air_temp = find_dataref("sim/cockpit2/temperature/outside_air_temp_deg")
OAT_is_metric = find_dataref("sim/cockpit2/temperature/outside_air_temp_is_metric") --> 1 if thermo is metric, 0 if fahrenheit
--bleed_air_off_L = find_dataref("sim/cockpit2/annunciators/bleed_air_off[0]")
--bleed_air_off_R = find_dataref("sim/cockpit2/annunciators/bleed_air_off[1]")
--bleed_air_fail_L = find_dataref("sim/cockpit2/annunciators/bleed_air_fail[0]")
--bleed_air_fail_R = find_dataref("sim/cockpit2/annunciators/bleed_air_fail[1]")
--HVAC_annunc = find_dataref("sim/cockpit2/annunciators/hvac") ----------> not working?
HVAC_failure = find_dataref("sim/operation/failures/rel_HVAC") --> 6=failed
-- Ignition "key" tells us whether the pilot asked for the starter - if so, we open the isolation valve so the APU can start both engines.
ignition_key_L = find_dataref("sim/cockpit2/engine/actuators/ignition_key[0]") --> 0 off, 1 left, 2 right, 3 both, 4 starting
ignition_key_R = find_dataref("sim/cockpit2/engine/actuators/ignition_key[1]")









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


----------------------------------- DISPLAY KNOB
function cmd_temp_display_select_up(phase, duration)
	if phase == 0 and temp_display_select > -3 then
		temp_display_select = temp_display_select - 1
		if temp_display_select == 0 then temp_display_select = -1 end
	end
end
function cmd_temp_display_select_dwn(phase, duration)
	if phase == 0 and temp_display_select < 3 then
		temp_display_select = temp_display_select + 1
		if temp_display_select == 0 then temp_display_select = 1 end
	end
end


----------------------------------- TEMPERATURE COCKPIT KNOB
function cmd_temp_cockpit_sel_up(phase, duration)
	if temp_cockpit_sel < 32 then
		if phase == 0 then temp_cockpit_sel = temp_cockpit_sel + 1 end
		if phase == 1 and duration > 0.5 then temp_cockpit_sel = temp_cockpit_sel + 0.5 end
	end
end
function cmd_temp_cockpit_sel_dwn(phase, duration)
	if temp_cockpit_sel > 12 then
		if phase == 0 then temp_cockpit_sel = temp_cockpit_sel - 1 end
		if phase == 1 and duration > 0.5 then temp_cockpit_sel = temp_cockpit_sel - 0.5 end
	end
end


----------------------------------- TEMPERATURE CABIN KNOB
function cmd_temp_cabin_sel_up(phase, duration)
	if temp_cabin_sel < 32 then
		if phase == 0 then temp_cabin_sel = temp_cabin_sel + 1 end
		if phase == 1 and duration > 0.5 then temp_cabin_sel = temp_cabin_sel + 0.5 end
	end
end
function cmd_temp_cabin_sel_dwn(phase, duration)
	if temp_cabin_sel > 12 then
		if phase == 0 then temp_cabin_sel = temp_cabin_sel - 1 end
		if phase == 1 and duration > 0.5 then temp_cabin_sel = temp_cabin_sel - 0.5 end
	end
end


----------------------------------- AIR COND POWER (PAC) COCKPIT KNOB
function cmd_air_cond_cockpit_up(phase, duration)
	if air_cond_cockpit < 2 then
		if phase == 0 then air_cond_cockpit = air_cond_cockpit + 1 end
	end
end
function cmd_air_cond_cockpit_dwn(phase, duration)
	if air_cond_cockpit > 0 then
		if phase == 0 then air_cond_cockpit = air_cond_cockpit - 1 end
	end
end


----------------------------------- AIR COND POWER (PAC) CABIN KNOB
function cmd_air_cond_cabin_up(phase, duration)
	if air_cond_cabin < 2 then
		if phase == 0 then air_cond_cabin = air_cond_cabin + 1 end
	end
end
function cmd_air_cond_cabin_dwn(phase, duration)
	if air_cond_cabin > 0 then
		if phase == 0 then air_cond_cabin = air_cond_cabin - 1 end
	end
end


----------------------------------- ENGINE BLEED-AIR LEFT KNOB
function cmd_engine_L_up(phase, duration)
	if engine_L < 2 then
		if phase == 0 then engine_L = engine_L + 1 end
	end
end
function cmd_engine_L_dwn(phase, duration)
	if engine_L > 0 then
		if phase == 0 then engine_L = engine_L - 1 end
	end
end


----------------------------------- ENGINE BLEED-AIR RIGHT KNOB
function cmd_engine_R_up(phase, duration)
	if engine_R < 2 then
		if phase == 0 then engine_R = engine_R + 1 end
	end
end
function cmd_engine_R_dwn(phase, duration)
	if engine_R > 0 then
		if phase == 0 then engine_R = engine_R - 1 end
	end
end


----------------------------------- BLEED-AIR ISOLATION VALVE KNOB
function cmd_iso_valve_up(phase, duration)
	if phase == 0 then iso_valve = 1 end
end
function cmd_iso_valve_dwn(phase, duration)
	if phase == 0 then iso_valve = 0 end
end


----------------------------------- EMPTY FUNCTION FOR WRITABLE DATAREF
--function func_do_nothing()
		--nothing
--end










----------------------------------- CREATE DATAREFS AND COMMANDS -----------------------------------

CitX_temp_display = create_dataref("laminar/CitX/bleedair/temp_display","number") --> value in the display
CitX_temp_display_select = create_dataref("laminar/CitX/bleedair/temp_display_select","number") --> (+)=ckpt,(-)=cabin / 1=current,2=selected,3=supply
temp_display_select = create_dataref("laminar/CitX/bleedair/temp_display_select_term","number") --> (+)=ckpt,(-)=cabin / 1=current,2=selected,3=supply
CitX_temp_cockpit_sel = create_dataref("laminar/CitX/bleedair/temp_cockpit_sel","number") --> 12=cold,22=auto,32=hot
temp_cockpit_sel = create_dataref("laminar/CitX/bleedair/temp_cockpit_sel_term","number") --> 12=cold,22=auto,32=hot
CitX_temp_cabin_sel = create_dataref("laminar/CitX/bleedair/temp_cabin_sel","number") --> 12=cold,22=auto,32=hot
temp_cabin_sel = create_dataref("laminar/CitX/bleedair/temp_cabin_sel_term","number") --> 12=cold,22=auto,32=hot
CitX_air_cond_cockpit = create_dataref("laminar/CitX/bleedair/air_cond_cockpit","number") --> 0=off,1=on,2=hi
air_cond_cockpit = create_dataref("laminar/CitX/bleedair/air_cond_cockpit_term","number") --> 0=off,1=on,2=hi
CitX_air_cond_cabin = create_dataref("laminar/CitX/bleedair/air_cond_cabin","number") --> 0=off,1=on,2=hi
air_cond_cabin = create_dataref("laminar/CitX/bleedair/air_cond_cabin_term","number") --> 0=off,1=on,2=hi
CitX_engine_L = create_dataref("laminar/CitX/bleedair/engine_left","number") --> 0=off,1=hp,2=lp
engine_L = create_dataref("laminar/CitX/bleedair/engine_left_term","number") --> 0=off,1=hp,2=lp
CitX_engine_R = create_dataref("laminar/CitX/bleedair/engine_right","number") --> 0=off,1=hp,2=lp
engine_R = create_dataref("laminar/CitX/bleedair/engine_right_term","number") --> 0=off,1=hp,2=lp
CitX_iso_valve = create_dataref("laminar/CitX/bleedair/iso_valve","number") --> 0=closed,1=open
iso_valve = create_dataref("laminar/CitX/bleedair/iso_valve_term","number") --> 0=closed,1=open
CitX_annunc_cab_temp_ctl = create_dataref("laminar/CitX/bleedair/annunc_cab_temp_ctl","number") --> "cabin temp control" annunciator
CitX_annunc_rmt = create_dataref("laminar/CitX/bleedair/annunc_rmt","number") --> "rmt" annunciator
CitX_annunc_nrm = create_dataref("laminar/CitX/bleedair/annunc_nrm","number") --> "nrm" annunciator

cmdtempdisplayselectup = create_command("laminar/CitX/bleedair/cmd_temp_display_select_up","Display select knob up",cmd_temp_display_select_up)
cmdtempdisplayselectdwn = create_command("laminar/CitX/bleedair/cmd_temp_display_select_dwn","Display select knob dwn",cmd_temp_display_select_dwn)
cmdtempcockpitselup = create_command("laminar/CitX/bleedair/cmd_temp_cockpit_sel_up","Temperature cockpit knob up",cmd_temp_cockpit_sel_up)
cmdtempcockpitseldwn = create_command("laminar/CitX/bleedair/cmd_temp_cockpit_sel_dwn","Temperature cockpit knob dwn",cmd_temp_cockpit_sel_dwn)
cmdtempcabinselup = create_command("laminar/CitX/bleedair/cmd_temp_cabin_sel_up","Temperature cabin knob up",cmd_temp_cabin_sel_up)
cmdtempcabinseldwn = create_command("laminar/CitX/bleedair/cmd_temp_cabin_sel_dwn","Temperature cabin knob dwn",cmd_temp_cabin_sel_dwn)
cmdaircondcockpitup = create_command("laminar/CitX/bleedair/cmd_air_cond_cockpit_up","Air cond cockpit knob up",cmd_air_cond_cockpit_up)
cmdaircondcockpitdwn = create_command("laminar/CitX/bleedair/cmd_air_cond_cockpit_dwn","Air cond cockpit knob dwn",cmd_air_cond_cockpit_dwn)
cmdaircondcabinup = create_command("laminar/CitX/bleedair/cmd_air_cond_cabin_up","Air cond cabin knob up",cmd_air_cond_cabin_up)
cmdaircondcabindwn = create_command("laminar/CitX/bleedair/cmd_air_cond_cabin_dwn","Air cond cabin knob dwn",cmd_air_cond_cabin_dwn)
cmdengineleftup = create_command("laminar/CitX/bleedair/cmd_engine_left_up","Bleed air engine left knob up",cmd_engine_L_up)
cmdengineleftdwn = create_command("laminar/CitX/bleedair/cmd_engine_left_dwn","Bleed air engine left knob dwn",cmd_engine_L_dwn)
cmdenginerightup = create_command("laminar/CitX/bleedair/cmd_engine_right_up","Bleed air engine right knob up",cmd_engine_R_up)
cmdenginerightdwn = create_command("laminar/CitX/bleedair/cmd_engine_right_dwn","Bleed air engine right knob dwn",cmd_engine_R_dwn)
cmdisovalveup = create_command("laminar/CitX/bleedair/cmd_iso_valve_up","Bleed air isolation valve up",cmd_iso_valve_up)
cmdisovalvedwn = create_command("laminar/CitX/bleedair/cmd_iso_valve_dwn","Bleed air isolation valve dwn",cmd_iso_valve_dwn)









--------------------------------- DO THIS EACH FLIGHT START ---------------------------------
function flight_start()

	temp_display_select = 1
	temp_cockpit_sel = 22
	temp_cockpit_current = outside_air_temp_C + 2
	temp_cockpit_supply = temp_cockpit_current
	temp_cabin_sel = 22
	temp_cabin_current = outside_air_temp_C + 1
	temp_cabin_supply = temp_cabin_current
	air_cond_cockpit = startup_running
	air_cond_cabin = startup_running
	engine_L,engine_L_actual = startup_running,startup_running
	engine_R,engine_R_actual = startup_running,startup_running
	aircond_pwr_L = 0
	aircond_pwr_R = 0
	aircond_pwr_both = 0
	iso_valve = 0
	bleed_gpu = 0
	bleed_pack_C = 0 --> PERMANENTLY DISABLED SINCE CITX HAS NO CENTRAL PACK
	bleed_isol_R = 1 --> PERMANENTLY OPENED SINCE CITX HAS NO RIGHT ISOLATION VALVE

end








--------------------------------- REGULAR RUNTIME ---------------------------------
function after_physics()


	-- DISPLAY SELECTION KNOB --
	-- SLOWLY ANIMATE:
	if CitX_temp_display_select ~= temp_display_select then
		CitX_temp_display_select = func_animate_slowly(temp_display_select, CitX_temp_display_select, 20)
	end
	---------------------


	-- COCKPIT TEMPERATURE SELECTION KNOB --
	-- SLOWLY ANIMATE:
	if CitX_temp_cockpit_sel ~= temp_cockpit_sel then
		CitX_temp_cockpit_sel = func_animate_slowly(temp_cockpit_sel, CitX_temp_cockpit_sel, 20)
	end
	---------------------


	-- CABIN TEMPERATURE SELECTION KNOB --
	-- SLOWLY ANIMATE:
	if CitX_temp_cabin_sel ~= temp_cabin_sel then
		CitX_temp_cabin_sel = func_animate_slowly(temp_cabin_sel, CitX_temp_cabin_sel, 20)
	end
	---------------------


	-- COCKPIT AIR COND POWER (PAC) KNOB --
	-- SLOWLY ANIMATE:
	if CitX_air_cond_cockpit ~= air_cond_cockpit then
		CitX_air_cond_cockpit = func_animate_slowly(air_cond_cockpit, CitX_air_cond_cockpit, 20)
	end
	---------------------


	-- CABIN AIR COND POWER (PAC) KNOB --
	-- SLOWLY ANIMATE:
	if CitX_air_cond_cabin ~= air_cond_cabin then
		CitX_air_cond_cabin = func_animate_slowly(air_cond_cabin, CitX_air_cond_cabin, 20)
	end
	---------------------


	-- ENGINE LEFT BLEED-AIR KNOB --
	-- SLOWLY ANIMATE:
	if CitX_engine_L ~= engine_L then
		CitX_engine_L = func_animate_slowly(engine_L, CitX_engine_L, 20)
	end
	---------------------


	-- ENGINE RIGHT BLEED-AIR KNOB --
	-- SLOWLY ANIMATE:
	if CitX_engine_R ~= engine_R then
		CitX_engine_R = func_animate_slowly(engine_R, CitX_engine_R, 20)
	end
	---------------------


	-- L/R ISOLATION VALVE KNOB --
	-- SLOWLY ANIMATE:
	if CitX_iso_valve ~= iso_valve then
		CitX_iso_valve = func_animate_slowly(iso_valve, CitX_iso_valve, 20)
	end
	---------------------


	----------------------------
	-- BLEED AIR SOURCE LOGIC --
	----------------------------
	-- BLEED AIR SOURCES ARE: ENG LEFT DUCT, ENG RIGHT DUCT, APU OR GPU
	-- (CENTRAL DUCT IS ALWAYS DISABLED SINCE CITX HAS NOT)
	-- ISO VALVE COULD BE: 0=CLOSE (L/R INDEPND), 1=OPEN (L/R CONNECTED)
	-- ENGINE BLD AIR KNOBS COULD BE: 0=OFF, 1=HI, 2=LO
	--
	-- OPEN OR CLOSE XPLANE'S APU VALVE CONSIDERING THE CITX'S APU SWITCH
	-- (THE APU N1 ABOVE 95% JUST LIT THE ANNUNC: SEE THE APU SCRIPT)
	if APU_bleed_air_switch > 0 then bleed_apu = 1 else bleed_apu = 0 end
	--
	-- OPEN OR CLOSE XPLANE'S ENG VALVES CONSIDERING CITX'S ENG KNOBS
	if engine_L > 0 then bleed_engL_sov = 1 else bleed_engL_sov = 0 end
	if engine_R > 0 then bleed_engR_sov = 1 else bleed_engR_sov = 0 end
	--
	-- OPEN OR CLOSE XPLANE'S LEFT ISOLATION VALVE CONSIDERING CITX'S ISOL KNOB
	if ignition_key_L == 4 or ignition_key_R == 4 then
		bleed_isol_L = 1
	else
		bleed_isol_L = iso_valve
	end
	---------------------


	--------------------------
	-- AIR COND (PAC) LOGIC --
	--------------------------
	-- AIR COND KNOBS COULD BE: 0=OFF, 1=ON, 2=HI
	-- OPEN OR CLOSE XPLANE'S PACKS CONSIDERING CITX'S PACK KNOBS
	if air_cond_cockpit > 0 then bleed_pack_L = 1 else bleed_pack_L = 0 end
	if air_cond_cabin > 0 then bleed_pack_R = 1 else bleed_pack_R = 0 end
	--
	-- THE FOLLOWING CODE IS THERE BASICALLY JUST TO COMPUTE TEMPERATURES
	--
	-- EVALUATE BLEED AIR PWR CONSIDERING KNOBS AND ISO VALVE
	-- "AIR_COND_COCKPIT/CABIN" KNOBS VALUES GOES FROM 0=OFF, TO 1=ON, TO 2=MAX 
	-- "BLEED_AVAILABLE_L/R" VALUES GOES FROM 0=OFF, TO 1 (WITH THE APU ONLY), TO 3 OR MORE (WITH ENGINES RUNNING)
	--
	-- EVALUATE AIR-COND PWR (REQUESTED KNOB PWR * BLEED AVAILABLE):
	air_cond_cockpit_pwr = (air_cond_cockpit*air_cond_cockpit*2) * bleed_available_L
	air_cond_cabin_pwr = (air_cond_cabin*air_cond_cabin*2) * bleed_available_R
	--
	-- EVALUATE DESTINATION TEMP:
	if air_cond_cockpit_pwr > 0 then temp_cockpit_dest = temp_cockpit_sel else temp_cockpit_dest = (outside_air_temp_C + 2) end
	if air_cond_cabin_pwr > 0 then temp_cabin_dest = temp_cabin_sel else temp_cabin_dest = (outside_air_temp_C + 1) end
	--
	-- COMPUTES TEMPERATURES DURING TIME:
	temp_cockpit_current = func_animate_slowly(temp_cockpit_dest, temp_cockpit_current, 0.003+air_cond_cockpit_pwr*0.002)
	temp_cabin_current = func_animate_slowly(temp_cabin_dest, temp_cabin_current, 0.002+air_cond_cabin_pwr*0.001)
	temp_cockpit_supply = func_animate_slowly(temp_cockpit_dest, temp_cockpit_supply, 0.5)
	temp_cabin_supply = func_animate_slowly(temp_cabin_dest, temp_cabin_supply, 0.5)
	--------------------------


	------------------------------------
	-- DISPLAY AND ANNUNCIATORS LOGIC --
	------------------------------------
	-- FORMULA FROM °C TO °F IS: °F = (1.8 * °C) + 32
	if OAT_is_metric == 1 then conv_mult = 1 conv_add = 0 else conv_mult = 1.8 conv_add = 32 end
	--
	if temp_display_select == 1 then
		CitX_temp_display = math.ceil(temp_cockpit_current * conv_mult + conv_add)
	elseif temp_display_select == 2 then
		CitX_temp_display = math.ceil(temp_cockpit_sel * conv_mult + conv_add)
	elseif temp_display_select == 3 then
		CitX_temp_display = math.ceil(temp_cockpit_supply * conv_mult + conv_add)
	elseif temp_display_select == -1 then
		CitX_temp_display = math.ceil(temp_cabin_current * conv_mult + conv_add)
	elseif temp_display_select == -2 then
		CitX_temp_display = math.ceil(temp_cabin_sel * conv_mult + conv_add)
	elseif temp_display_select == -3 then
		CitX_temp_display = math.ceil(temp_cabin_supply * conv_mult + conv_add)
	else
		CitX_temp_display = 999
	end
	------------------- (ANNUNC DIMMED BY RIGHT BRIGH RHEO)
	if bus_volts_L + bus_volts_R > 0 then ann_pwr = 1 else ann_pwr = 0 end
	if aircond_pwr_both > 0 then
		CitX_annunc_cab_temp_ctl = 1 * instr_brgh_right * ann_pwr
		if air_cond_cockpit_pwr + air_cond_cabin_pwr > 0 then
			CitX_annunc_nrm = 1 * instr_brgh_right * ann_pwr
			CitX_annunc_rmt = 0
		else
			CitX_annunc_nrm = 0
			CitX_annunc_rmt = 1 * instr_brgh_right * ann_pwr
		end
	else
		CitX_annunc_cab_temp_ctl = 0
		CitX_annunc_nrm = 0
		CitX_annunc_rmt = 1 * instr_brgh_right * ann_pwr
	end

	if HVAC_failure == 6 then
		CitX_temp_display = 999
		CitX_annunc_rmt = 1 * instr_brgh_right * ann_pwr
		CitX_annunc_cab_temp_ctl = 0
		CitX_annunc_nrm = 0
	end
	-------------------


end

