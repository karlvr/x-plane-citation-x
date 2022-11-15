-- *******************************************************************
-- Helper datarefs for use on the sound system
-- Daniela Rodríguez Careri <dcareri@gmail.com>
-- Laminar Research
-- *******************************************************************

dr_battery = find_dataref("sim/cockpit2/electrical/battery_on[0]")
dr_n2 = find_dataref("sim/flightmodel2/engines/N2_percent[0]")
dr_burning_fuel = find_dataref("sim/flightmodel2/engines/engine_is_burning_fuel[0]")
dr_on_ground = find_dataref("sim/flightmodel/failures/onground_any")

dr_wing_def_deg = find_dataref("sim/flightmodel2/wing/wing_tip_deflection_deg[0]")
last_wing_def_deg = 0;
wing_def_speed = create_dataref("laminar/CitX/sound/wing_def_speed", "number")

function wing_def_timer()
    wing_def_speed = math.abs(dr_wing_def_deg - last_wing_def_deg) * 100
    last_wing_def_deg = dr_wing_def_deg
end

function citx_set_wing_def_timer()
    if is_timer_scheduled(wing_def_timer) == false then
        run_at_interval(wing_def_timer, 0.1)
    end
end

-- *******************************************************************
-- Hooks
-- *******************************************************************

function update_datarefs()
    citx_set_wing_def_timer()
end

function after_physics()
    update_datarefs()
end

function after_replay()
    update_datarefs()
end
