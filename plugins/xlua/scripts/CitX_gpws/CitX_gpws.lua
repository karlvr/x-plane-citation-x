-- *******************************************************************
-- Simple GPWS implementation (according to Honeywell MK VIII)
-- Daniela Rodríguez Careri <dcareri@gmail.com>
-- Laminar Research
-- *******************************************************************

DR_gs_annun = find_dataref("sim/cockpit/warnings/annunciators/glideslope")
DR_pull_up_annun = find_dataref("sim/cockpit2/annunciators/GPWS")
DR_rad_alt = find_dataref("sim/cockpit2/gauges/indicators/radio_altimeter_height_ft_pilot")
DR_vario = find_dataref("sim/cockpit2/gauges/indicators/vvi_fpm_pilot")
DR_dh_annun = find_dataref("sim/cockpit2/gauges/indicators/radio_altimeter_dh_lit_pilot") -- FIXME: not trusty on replay
DR_windshear_annun = find_dataref("sim/cockpit2/annunciators/windshear_warning")
DR_roll_indicator = find_dataref("sim/cockpit2/gauges/indicators/roll_vacuum_deg_pilot")
DR_autopilot_on = find_dataref("sim/cockpit2/autopilot/autopilot_on")
DR_flap_ratio = find_dataref("sim/cockpit2/controls/flap_system_deploy_ratio")
DR_gear_ratio = find_dataref("sim/flightmodel2/gear/deploy_ratio[0]") -- FIXME: should do for now
DR_airspeed = find_dataref("sim/flightmodel/position/indicated_airspeed2")
DR_on_ground = find_dataref("sim/flightmodel/failures/onground_any")
DR_running_time = find_dataref("sim/time/total_running_time_sec")

DR_gpws_message = create_dataref("laminar/gpws/message", "number")
DR_gpws_message_debug = create_dataref("laminar/gpws/message_debug", "string")

-- Be sure to sync the ids with the FMOD event names (and durations)
-- This list establishes message priority as per the Honeywell MK VI & VIII manual
-- FIXME: made local because of https://github.com/X-Plane/XLua/issues/4
local messages
local message_count
local rad_altitudes
local is_mode_6_resetted
local is_minimums_played
local is_bank_angle_played
local is_sinkrate_played
local is_mode4a_2lowgear_played
local is_mode4a_2lowterrain_played
local is_mode4b_2lowflaps_played
local is_mode4b_2lowterrain_played

local is_replay_initialized
local last_time

function initialize()
    messages = {
        [1] = { id = 'pull_up', is_playing = false, wants_play = false, duration = 1800 },
        [2] = { id = 'whoop_pull_up', is_playing = false, wants_play = false, duration = 2000 }, -- TODO
        [3] = { id = 'terrain_x2', is_playing = false, wants_play = false, duration = 2000 }, -- TODO
        [4] = { id = 'terrain_ahead', is_playing = false, wants_play = false, duration = 2000 }, -- TODO
        [5] = { id = 'obstacle_ahead', is_playing = false, wants_play = false, duration = 2000 }, -- TODO
        [6] = { id = 'terrain', is_playing = false, wants_play = false, duration = 2000 }, -- TODO
        [7] = { id = 'minimums', is_playing = false, wants_play = false, duration = 1200 },
        [8] = { id = 'caution_terrain', is_playing = false, wants_play = false, duration = 2000 }, -- TODO
        [9] = { id = 'caution_obstacle', is_playing = false, wants_play = false, duration = 2000 }, -- TODO
        [10] = { id = 'too_low_terrain', is_playing = false, wants_play = false, duration = 1400 },
        [11] = { id = 'windshear', is_playing = false, wants_play = false, duration = 3200 },
        [12] = { id = '10ft', is_playing = false, wants_play = false, duration = 350 },
        [13] = { id = '20ft', is_playing = false, wants_play = false, duration = 440 },
        [14] = { id = '30ft', is_playing = false, wants_play = false, duration = 360 },
        [15] = { id = '40ft', is_playing = false, wants_play = false, duration = 280 },
        [16] = { id = '50ft', is_playing = false, wants_play = false, duration = 400 },
        [17] = { id = '100ft', is_playing = false, wants_play = false, duration = 900 },
        [18] = { id = '200ft', is_playing = false, wants_play = false, duration = 900 },
        [19] = { id = '300ft', is_playing = false, wants_play = false, duration = 900 },
        [20] = { id = '400ft', is_playing = false, wants_play = false, duration = 1000 },
        [21] = { id = '500ft', is_playing = false, wants_play = false, duration = 1000 },
        [22] = { id = '1000ft', is_playing = false, wants_play = false, duration = 900 },
        [23] = { id = 'too_low_flaps', is_playing = false, wants_play = false, duration = 1800 },
        [24] = { id = 'too_low_gear', is_playing = false, wants_play = false, duration = 1800 },
        [25] = { id = 'sinkrate', is_playing = false, wants_play = false, duration = 1800 },
        [26] = { id = 'dont_sink', is_playing = false, wants_play = false, duration = 2000 }, -- TODO
        [27] = { id = 'glideslope', is_playing = false, wants_play = false, duration = 800 },
        [28] = { id = 'bank_angle', is_playing = false, wants_play = false, duration = 1800 },
        [29] = { id = 'bank_angle_x2', is_playing = false, wants_play = false, duration = 2000 }, -- TODO
    }

    rad_altitudes = {
        { alt = 1000, thr = 10, played = false },
        { alt = 500, thr = 10, played = false },
        { alt = 400, thr = 10, played = false },
        { alt = 300, thr = 5, played = false },
        { alt = 200, thr = 5, played = false },
        { alt = 100, thr = 5, played = false },
        { alt = 50, thr = 1, played = false },
        { alt = 40, thr = 1, played = false },
        { alt = 30, thr = 1, played = false },
        { alt = 20, thr = 1, played = false },
        { alt = 10, thr = 1, played = false },
    }

    message_count = #messages
    is_mode_6_resetted = true
    is_minimums_played = false
    is_bank_angle_played = false
    is_sinkrate_played = false
    is_mode4a_2lowgear_played = false
    is_mode4a_2lowterrain_played = false
    is_mode4b_2lowflaps_played = false
    is_mode4b_2lowterrain_played = false
    is_replay_initialized = false
    last_time = 0

    print('[GPWS] Init: Total messages', message_count)
end

function set_gpws_message()

    local highest_playing = message_count + 1
    local clear_rest = false

    for i = 1, message_count do
        local cur_message = messages[i]

        if clear_rest then
            cur_message.is_playing = false
            cur_message.wants_play = false
        end

        if (cur_message.is_playing and i < highest_playing) then
            highest_playing = i
            clear_rest = true
        end

        if (cur_message.wants_play and highest_playing > i) then

            if (not cur_message.is_playing) then
                print('[GPWS] Playing now:', cur_message.id)
                cur_message.is_playing = true

                run_after_time(function()
                    print('[GPWS] Stopping:', cur_message.id)
                    cur_message.is_playing = false
                end, cur_message.duration / 1000)

                cur_message.wants_play = false
                highest_playing = i
                clear_rest = true

            end
        end
    end
    if (messages[highest_playing] ~= nil and messages[highest_playing].is_playing) then
        DR_gpws_message = highest_playing
        DR_gpws_message_debug = messages[highest_playing].id
    else
        DR_gpws_message = 0
        DR_gpws_message_debug = "-"
    end
end

function get_message_by_id(id)
    for i = 1, message_count do
        local cur_message = messages[i]
        if ( cur_message['id'] == id ) then
            return cur_message
        end
    end
    return nil
end

function play_message(id, val)
    local cur_message = get_message_by_id(id)
    if val then
        if (not cur_message.is_playing and not cur_message.wants_play) then
            print('[GPWS] Requesting:', cur_message.id)
            cur_message.wants_play = true
        end
    else
        if cur_message.wants_play or cur_message.is_playing then
            print('[GPWS] Unrequesting:', cur_message.id)
            cur_message.wants_play = false
        end
    end
end

function mode_5_glideslope()
    if DR_gs_annun == 1 then
        play_message('glideslope', true)
    end
end

function mode_1_pull_up()
    if DR_pull_up_annun == 1 and DR_vario < 0 then
        play_message('pull_up', true)
    end
end

function mode_6_altitude()
    local length = #rad_altitudes

    if (DR_rad_alt > 2500 and not is_mode_6_resetted) then
        reset_mode_6()
    end

    for i = 1, length do
        local msg_id = tostring(rad_altitudes[i].alt)..'ft';
        if (
            rad_altitudes[i].played == false and
            DR_rad_alt <= rad_altitudes[i].alt and DR_rad_alt > (rad_altitudes[i].alt - rad_altitudes[i].thr) and
            DR_vario < 0
        ) then
            play_message(msg_id, true)
            rad_altitudes[i].played = true
            is_mode_6_resetted = false
            break
        end
    end
end

function mode_6_minimums()
    if not is_minimums_played then
        if DR_dh_annun == 1 then
            play_message('minimums', true)
            is_minimums_played = true
        end
    end
end

-- TODO: Make it insist at 20% increase & additional 20% increase.
function mode_6_bank_angle()
    local roll_angle = math.abs(DR_roll_indicator)

    if DR_autopilot_on == 0 then

        if DR_rad_alt > 5 and DR_rad_alt < 30 then
            if roll_angle >= 10 then
                if not is_bank_angle_played then
                    play_message('bank_angle', true)
                    is_bank_angle_played = true
                end
            end
        elseif DR_rad_alt >= 30 and DR_rad_alt < 150 then
            local min_alt = 4 * roll_angle - 10;
            if roll_angle >= 10 and roll_angle < 40 and DR_rad_alt < min_alt then
                if not is_bank_angle_played then
                    play_message('bank_angle', true)
                    is_bank_angle_played = true
                end
            end
        elseif DR_rad_alt >= 150 and DR_rad_alt < 2450 then
            local min_alt = 153.333 * roll_angle - 5983.33;
            if roll_angle >= 40 and roll_angle < 55 and DR_rad_alt < min_alt then
                if not is_bank_angle_played then
                    play_message('bank_angle', true)
                    is_bank_angle_played = true
                end
            end
        elseif DR_rad_alt >= 2450 then
            if roll_angle >= 55 then
                if not is_bank_angle_played then
                    play_message('bank_angle', true)
                    is_bank_angle_played = true
                end
            end
        end

    elseif DR_autopilot_on == 1 then

        if DR_rad_alt > 5 and DR_rad_alt < 30 then
            if roll_angle >= 10 then
                if not is_bank_angle_played then
                    play_message('bank_angle', true)
                    is_bank_angle_played = true
                end
            end
        elseif DR_rad_alt >= 30 and DR_rad_alt < 122 then
            local min_alt = 4 * roll_angle - 10;
            if roll_angle >= 10 and roll_angle < 33 and DR_rad_alt < min_alt then
                if not is_bank_angle_played then
                    play_message('bank_angle', true)
                    is_bank_angle_played = true
                end
            end
        elseif DR_rad_alt >= 122 then
            if roll_angle >= 33 then
                if not is_bank_angle_played then
                    play_message('bank_angle', true)
                    is_bank_angle_played = true
                end
            end
        end

    end

    -- Reset if bank angle is recentered
    if is_bank_angle_played and roll_angle < 10 then
        is_bank_angle_played = false
    end
end

-- TODO: Make it insist at 20% additional penetration and see if there's need to implement the second zone for pull_up
function mode_1_sinkrate()
    local min_alt = 0.64473 * math.abs(DR_vario) - 644.73
    if DR_rad_alt < 2450 and DR_vario < 0 and DR_vario > -4800 and DR_rad_alt < min_alt then
       if not is_sinkrate_played then
           play_message('sinkrate', true)
           is_sinkrate_played = true
       end
    else
       -- Reset if out of the zone
       if is_sinkrate_played then
           is_sinkrate_played = false
       end
    end
end

function mode_4_too_low()

    -- Mode 4a
    if DR_gear_ratio < 1 and DR_on_ground == 0 then

        if DR_airspeed < 190 and DR_rad_alt < 500 and DR_vario < -300 then
            if not is_mode4a_2lowgear_played then
                play_message('too_low_gear', true)
                run_after_time(function()
                    -- Only mark played if actually played or else will be always obscured by '500ft'
                    if get_message_by_id('too_low_gear').is_playing then
                        is_mode4a_2lowgear_played = true
                    end
                end, 1)
            end
        else
            -- Reset if out of the zone
            if is_mode4a_2lowgear_played then
                is_mode4a_2lowgear_played = false
            end
        end

        local min_alt = 2.3809 * DR_airspeed + 47.6190
        if DR_airspeed >= 190 and DR_rad_alt < 1000 and DR_rad_alt < min_alt and DR_vario < -300 then
            if not is_mode4a_2lowterrain_played then
                play_message('too_low_terrain', true)
                run_after_time(function()
                    -- Only mark played if actually played or else will be always obscured by '500ft'
                    if  get_message_by_id('too_low_terrain').is_playing then
                        is_mode4a_2lowterrain_played = true
                    end
                end, 1)
            end
        else
            -- Reset if out of the zone
            if is_mode4a_2lowterrain_played then
                is_mode4a_2lowterrain_played = false
            end
        end

    -- Mode 4b
    elseif DR_gear_ratio == 1 and DR_flap_ratio < 0.625 and DR_on_ground == 0 and DR_vario < -300 then

        if DR_airspeed < 150 and DR_rad_alt < 245 then
            if not is_mode4b_2lowflaps_played then
                play_message('too_low_flaps', true)
                is_mode4b_2lowflaps_played = true
            end
        else
            -- Reset if out of the zone
            if is_mode4b_2lowflaps_played then
                is_mode4b_2lowflaps_played = false
            end
        end

        local min_alt = 7.55 * DR_airspeed - 887.5
        if DR_airspeed >= 150 and DR_rad_alt < 1000 and DR_rad_alt < min_alt and DR_vario < -300 then
            if not is_mode4b_2lowterrain_played then
                play_message('too_low_terrain', true)
                is_mode4b_2lowterrain_played = true
            end
        else
            -- Reset if out of the zone
            if is_mode4b_2lowterrain_played then
                is_mode4b_2lowterrain_played = false
            end
        end

    end

end

function pws_windshear()
    if DR_windshear_annun == 1 then
        play_message('windshear', true)
    end
end

function reset_mode_6()
    print('[GPWS] Reset mode 6')
    local length = #rad_altitudes
    for i = 1, length do
        rad_altitudes[i].played = false
    end
    is_mode_6_resetted = true
    is_minimums_played = false
end

function save_current_time()
    last_time = DR_running_time;
end

-- Ensure reset status of GPWS on replay
function update_replay_status()

    if (last_time > DR_running_time) then
        if not is_replay_initialized then
            print('[GPWS] Time went back, reinitialize')
            initialize()
            is_replay_initialized = true
        end
    else
        if is_replay_initialized then
            is_replay_initialized = false
        end
    end

end


-- *******************************************************************
-- Hooks
-- *******************************************************************

function update_datarefs()
    mode_1_pull_up()
    mode_1_sinkrate()
    mode_4_too_low()
    mode_5_glideslope()
    mode_6_altitude()
    mode_6_minimums()
    mode_6_bank_angle()
    set_gpws_message()
    update_replay_status()
    save_current_time() -- must always be last
end

function after_physics()
    update_datarefs()
end

function after_replay()
    update_datarefs()
end

function flight_start()
    initialize()
end