classdef rocket
    properties
        stage1
        stage2
        payload
        position
        velocity
        timeElapsed
        dragCoeff
        currentStage
        mass
    end

    methods 
        function obj = rocket(stage1, stage2, payload, position, velocity, dragCoeff)
            obj.payload = payload;
            obj.stage1 = stage1;
            obj.stage2 = stage2;
            obj.position = position;
            obj.velocity = velocity;
            obj.timeElapsed = 0;
            obj.dragCoeff = dragCoeff;
            obj.currentStage = 1;
            obj.mass = stage1.getMass() + stage2.getMass() + payload;  % initial total mass
        end

        function [obj, netForce] = advance(obj, dt)
            % Determine which stage is burning and update burned time + mass
            if obj.stage1.burnedtime < obj.stage1.burntime
                
                thrust = obj.stage1.thrust;
                obj.stage1.burnedtime = obj.stage1.burnedtime + dt;
                obj.currentStage = 1;

                % Rocket Mass through stage 1 flight
                obj.mass = obj.stage1.getMass() + obj.stage2.getMass() + obj.payload;

            elseif obj.stage2.burnedtime < obj.stage2.burntime

                thrust = obj.stage2.thrust;
                obj.currentStage = 2;
                obj.stage2.burnedtime = obj.stage2.burnedtime + dt;

                % Drop Stage 1
                obj.mass = obj.stage2.getMass() + obj.payload;

            else

                thrust = 0;
                obj.currentStage = 3;

                % Drop Stage 2
                obj.mass = obj.payload;

            end

            % Calculate forces
            rho = 1.225;
            Cd = 0.2;
            r = 0.05;
            A = pi * r^2;
            g = 9.81;

            dragForce = 0.5 * rho * Cd * A * obj.velocity^2 * sign(obj.velocity);
            netForce = thrust - dragForce - g * obj.mass;
            a = netForce / obj.mass;

            % Update kinematics
            obj.position = obj.position + obj.velocity * dt;
            obj.velocity = obj.velocity + a * dt;

            % Update time
            obj.timeElapsed = obj.timeElapsed + dt;
        end
    end
end
