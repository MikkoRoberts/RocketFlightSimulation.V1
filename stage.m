classdef stage
    properties
        mass
        thrust
        burntime
        burnedtime
        massflowrate
    end
    methods
        function obj = stage(mass, thrust, burntime, burnedtime, massflowrate)
            obj.mass = mass;
            obj.thrust = thrust;
            obj.burntime = burntime;
            obj.burnedtime = burnedtime;
            obj.massflowrate = massflowrate;
        end        
        
        function gm = getMass(obj)

            burnedMass = obj.massflowrate * min(obj.burnedtime, obj.burntime);
            gm = obj.mass - burnedMass;

        end

    end
end

