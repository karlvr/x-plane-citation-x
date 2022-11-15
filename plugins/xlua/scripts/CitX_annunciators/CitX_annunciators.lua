
-----------------------------------------------------------------
--
-- DEALING WITH VARIOUS ANNUNCIATORS NOT COVERED BY A SPECIFIC SYSTEM
-- PLUS THE MASTER WARNING / CAUTION
--
-----------------------------------------------------------------




------------------------------- FUNCTIONS -------------------------------

----------------------------------- EMPTY FUNCTION FOR WRITABLE DATAREF
function func_do_nothing()
	--nothing
end





----------------------------------- LOCATE AND CREATE DATAREFS -----------------------------------

-- LOCATE
bus_volts_0 = find_dataref("sim/cockpit2/electrical/bus_volts[0]") --> stby
bus_volts_1 = find_dataref("sim/cockpit2/electrical/bus_volts[1]") --> main
bus_volts_2 = find_dataref("sim/cockpit2/electrical/bus_volts[2]") --> essential
instr_brgh_cntr = find_dataref("sim/cockpit2/electrical/instrument_brightness_ratio_auto[3]") --> brightness ratio central panel
master_caution = find_dataref("sim/cockpit2/annunciators/master_caution")
master_warning = find_dataref("sim/cockpit2/annunciators/master_warning")
--rudder2_deg = find_dataref("sim/flightmodel2/wing/rudder2_deg[11]") --> upper rudder degree -- NOT USED
fail_servo_rudd = find_dataref("sim/operation/failures/rel_servo_rudd") --> YD FAIL, autopilot servos failed - rudder/yaw damper
annunc_yaw_damper = find_dataref("sim/cockpit2/annunciators/yaw_damper") --> YD, the yaw damper deal with the electrical upper rudder A/B systems
--yaw_damper_on = find_dataref("sim/cockpit2/switches/yaw_damper_on") --> YD SWITCH
A_fd_mode = find_dataref("sim/cockpit2/autopilot/flight_director_mode") --> 0 off, 1 on, 2 on with servos
B_fd_mode = find_dataref("sim/cockpit2/autopilot/flight_director2_mode") --> 0 off, 1 on, 2 on with servos
annunc_GPWS = find_dataref("sim/cockpit2/annunciators/GPWS")
flap_deploy_ratio = find_dataref("sim/cockpit2/controls/flap_handle_deploy_ratio")
hsi_vdef_dots_pilot = find_dataref("sim/cockpit2/radios/indicators/hsi_vdef_dots_pilot")
hsi_vdef_dots_copilot = find_dataref("sim/cockpit2/radios/indicators/hsi_vdef_dots_copilot")

audio_com_selection = find_dataref("sim/cockpit2/radios/actuators/audio_com_selection") --> 6 com1, 7 com2
audio_selection_nav1 = find_dataref("sim/cockpit2/radios/actuators/audio_selection_nav1")
audio_selection_nav2 = find_dataref("sim/cockpit2/radios/actuators/audio_selection_nav2")
audio_selection_com1 = find_dataref("sim/cockpit2/radios/actuators/audio_selection_com1")
audio_selection_com2 = find_dataref("sim/cockpit2/radios/actuators/audio_selection_com2")
audio_selection_adf1 = find_dataref("sim/cockpit2/radios/actuators/audio_selection_adf1")
audio_selection_adf2 = find_dataref("sim/cockpit2/radios/actuators/audio_selection_adf2")
audio_dme_enabled = find_dataref("sim/cockpit2/radios/actuators/audio_dme_enabled")
audio_marker_enabled = find_dataref("sim/cockpit2/radios/actuators/audio_marker_enabled")


-- CREATE
CitX_master_caution = create_dataref("laminar/CitX/annunciators/master_caution","number")
CitX_master_warning = create_dataref("laminar/CitX/annunciators/master_warning","number")

CitX_annunc_upper_rudder = create_dataref("laminar/CitX/annunciators/upper_rudder","number")
CitX_annunc_upper_rudder_A = create_dataref("laminar/CitX/annunciators/upper_rudder_A","number")
CitX_annunc_upper_rudder_B = create_dataref("laminar/CitX/annunciators/upper_rudder_B","number")
CitX_annunc_gpws_flap_norm = create_dataref("laminar/CitX/annunciators/gpws_flap_norm","number")
CitX_annunc_gpws_flap_oride = create_dataref("laminar/CitX/annunciators/gpws_flap_oride","number")
CitX_annunc_below_gs = create_dataref("laminar/CitX/annunciators/below_gs","number")

CitX_annunc_audio_active_com1 = create_dataref("laminar/CitX/annunciators/audio_active_com1","number")
CitX_annunc_audio_active_com2 = create_dataref("laminar/CitX/annunciators/audio_active_com2","number")
CitX_annunc_audio_nav1 = create_dataref("laminar/CitX/annunciators/audio_nav1","number")
CitX_annunc_audio_nav2 = create_dataref("laminar/CitX/annunciators/audio_nav2","number")
CitX_annunc_audio_com1 = create_dataref("laminar/CitX/annunciators/audio_com1","number")
CitX_annunc_audio_com2 = create_dataref("laminar/CitX/annunciators/audio_com2","number")
CitX_annunc_audio_adf1 = create_dataref("laminar/CitX/annunciators/audio_adf1","number")
CitX_annunc_audio_adf2 = create_dataref("laminar/CitX/annunciators/audio_adf2","number")
CitX_annunc_audio_dme = create_dataref("laminar/CitX/annunciators/audio_dme","number")
CitX_annunc_audio_mkr = create_dataref("laminar/CitX/annunciators/audio_mkr","number")
CitX_annunc_audio_nd = create_dataref("laminar/CitX/annunciators/audio_nd","number") --> for those not defined

CitX_annunc_none = create_dataref("laminar/CitX/annunciators/none","number",func_do_nothing) --> for those not defined






--------------------------------- INITIALIZATION ---------------------------------


-- DO THIS EACH FLIGHT START
function flight_start()

	CitX_annunc_none = 0

	CitX_master_caution = 0
	CitX_master_warning = 0

	CitX_annunc_upper_rudder = 0
	CitX_annunc_upper_rudder_A = 0
	CitX_annunc_upper_rudder_B = 0
	CitX_annunc_gpws_flap_norm = 0
	CitX_annunc_gpws_flap_oride = 0
	CitX_annunc_below_gs = 0

	CitX_annunc_audio_active_com = audio_com_selection
	CitX_annunc_audio_nav1 = audio_selection_nav1
	CitX_annunc_audio_nav2 = audio_selection_nav2
	CitX_annunc_audio_com1 = audio_selection_com1
	CitX_annunc_audio_com2 = audio_selection_com2
	CitX_annunc_audio_adf1 = audio_selection_adf1
	CitX_annunc_audio_adf2 = audio_selection_adf2
	CitX_annunc_audio_dme = audio_dme_enabled
	CitX_annunc_audio_mkr = audio_marker_enabled
	CitX_annunc_audio_nd = 0

end







--------------------------------- RUNTIME ---------------------------------

function after_physics()

	-- WILL LIT ANNUNCIATORS ONLY IF POWER ON BUSES
	-- (NO BUS 0 SINCE IT IS JUST FOR STBY INSTR)
	if bus_volts_1 + bus_volts_2 > 1 then pwr_on = 1 else pwr_on = 0 end
	if bus_volts_2 > 1 then pwr_essent = 1 else pwr_essent = 0 end
	

	-- MASTER CAUTION / WARNING
	-- (DIMMED BY THE CENTRAL BRIGHTNESS RHEO/PHOTOCELL)
	CitX_master_caution = master_caution * instr_brgh_cntr * pwr_on
	CitX_master_warning = master_warning * instr_brgh_cntr * pwr_on --> (FLASHING IS DONE IN THE LAST TEST SCRIPT)


	-- UPPER RUDDER ANNUNCIATOR (OCCUR IF YD FAIL - SYS A OR B ARE THE INACTIVE FLIGHT DIRECTORS)
	-- (DIMMED BY THE CENTRAL BRIGHTNESS RHEO/PHOTOCELL)
	if fail_servo_rudd > 0 or annunc_yaw_damper == 0 then
		CitX_annunc_upper_rudder = 1 * instr_brgh_cntr * pwr_essent
		if A_fd_mode == 0 then CitX_annunc_upper_rudder_A = 1 * instr_brgh_cntr * pwr_essent else CitX_annunc_upper_rudder_A = 0 end
		if B_fd_mode == 0 then CitX_annunc_upper_rudder_B = 1 * instr_brgh_cntr * pwr_essent else CitX_annunc_upper_rudder_B = 0 end
	else
		CitX_annunc_upper_rudder = 0
		CitX_annunc_upper_rudder_A = 0
		CitX_annunc_upper_rudder_B = 0
	end


	-- GPWS ANNUNCIATOR (IT LIGHTS UP FLAP NORM IF FLAPS DEPLOYED - FLAP O'RIDE IF NO FLAP)
	-- (DIMMED BY THE CENTRAL BRIGHTNESS RHEO/PHOTOCELL)
	if annunc_GPWS == 1 then
		if flap_deploy_ratio > 0.25 then
			CitX_annunc_gpws_flap_norm = 1 * instr_brgh_cntr * pwr_on
			CitX_annunc_gpws_flap_oride = 0
		else
			CitX_annunc_gpws_flap_norm = 0
			CitX_annunc_gpws_flap_oride = 1 * instr_brgh_cntr * pwr_on
		end
	else
		CitX_annunc_gpws_flap_norm = 0
		CitX_annunc_gpws_flap_oride = 0
	end


	-- BELOW GLIDE SLOPE ANNUNCIATOR
	-- (DIMMED BY THE CENTRAL BRIGHTNESS RHEO/PHOTOCELL)
	if hsi_vdef_dots_pilot < -0.5 or hsi_vdef_dots_copilot < -0.5 then
		CitX_annunc_below_gs = 1 * instr_brgh_cntr * pwr_on
	else
		CitX_annunc_below_gs = 0
	end


	-- AUDIO PANEL LIGHTS
	if audio_com_selection == 6 then CitX_annunc_audio_active_com1 = 1 * pwr_on else CitX_annunc_audio_active_com1 = 0 end
	if audio_com_selection == 7 then CitX_annunc_audio_active_com2 = 1 * pwr_on else CitX_annunc_audio_active_com2 = 0 end
	CitX_annunc_audio_nav1 = audio_selection_nav1 * pwr_on
	CitX_annunc_audio_nav2 = audio_selection_nav2 * pwr_on
	CitX_annunc_audio_com1 = audio_selection_com1 * pwr_on
	CitX_annunc_audio_com2 = audio_selection_com2 * pwr_on
	CitX_annunc_audio_adf1 = audio_selection_adf1 * pwr_on
	CitX_annunc_audio_adf2 = audio_selection_adf2 * pwr_on
	CitX_annunc_audio_dme = audio_dme_enabled * pwr_on
	CitX_annunc_audio_mkr = audio_marker_enabled * pwr_on


	-- NOT ASSIGNED ANNUNC STAY OFF
	CitX_annunc_none = 0


end


