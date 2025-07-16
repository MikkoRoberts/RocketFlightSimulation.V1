clc;
clear;
close all;


%% TIME PARAMETERS
dt = 0.1; % time step
time = 0:dt:700;


%% STAGE 1 PARAMETERS
s1Mass = 100;
s1Thrust = 220000;
s1BurnTime = 0.6;
s1BurnedTime = 0;
s1MassFlowRate = 100;

stage1 = stage(s1Mass,s1Thrust,s1BurnTime,s1BurnedTime,s1MassFlowRate);

%% STAGE 2 PARAMETERS

s2Mass = 100;
s2Thrust = 6700;
s2BurnTime = 47;
s2BurnedTime = 0;
s2MassFlowRate = 1.38;

stage2 = stage(s2Mass,s2Thrust,s2BurnTime,s2BurnedTime,s2MassFlowRate);

%% PAYLOAD PARAMETERS

payloadMass = 11; % kg

%% ROCKET PARAMETERS

rocketPosition = 0;
rocketVelocity = 0;
rocketDragCoeff = 0.02;

rocket = rocket(stage1, stage2, payloadMass, rocketPosition, rocketVelocity, rocketDragCoeff);

%% Simulation

positions = zeros(1, length(time));
velocities = zeros(1, length(time));
netForces = zeros(1, length(time));
stage1masses = zeros(1, length(time));
stage2masses = zeros(1, length(time));
stage3masses = zeros(1, length(time));
rocketmasses = zeros(1,length(time));
stage1SepIdx = NaN;
stage2SepIdx = NaN;

for i = 1:length(time)

[rocket, nf] = rocket.advance(dt);
positions(i) = rocket.position;
velocities(i) = rocket.velocity;
netForces(i) = nf;
stage1masses(i) = rocket.stage1.getMass;
stage2masses(i) = rocket.stage2.getMass;
stage3masses(i) = rocket.payload;
rocketmasses(i) = rocket.mass;

fprintf('Time: %.1f s, Stage: %d\n', rocket.timeElapsed, rocket.currentStage);

% Save the index where stage 1 ends
if isnan(stage1SepIdx) && rocket.currentStage == 2
        stage1SepIdx = i;
end

    % Save the index where stage 2 ends
if isnan(stage2SepIdx) && rocket.currentStage == 3
        stage2SepIdx = i;
end

if positions(i) <= 0 && i > 1
    positions = positions(1:i);
    velocities = velocities(1:i);
    netForces = netForces(1:i);
    stage1masses = stage1masses(1:i);
    stage2masses = stage2masses(1:i);
    stage3masses = stage3masses(1:i);
    rocketmasses = rocketmasses(1:i);
    time = time(1:i);

    break
end

end



[apoapse, idxApoapse] = max(positions);
timeApoapse = time(idxApoapse);


figure;
plot(time,positions)
xlabel('Time (s)');
ylabel('Alt (m)');
title('Rocket Altitude Over Time');
hold on;
txt1 = 'Stage 1 Seperation \rightarrow';
txt2 = 'Stage 2 Seperation \rightarrow';
txt3 = sprintf('Apoapse at %.1f Kilometeres', apoapse/1000);
txt4 = '\leftarrow Ignition';

plot(time(stage1SepIdx),positions(stage1SepIdx),'ro',MarkerFaceColor= 'r',MarkerEdgeColor='k')
plot(time(stage2SepIdx),positions(stage2SepIdx),'ro',MarkerFaceColor= 'r',MarkerEdgeColor='k')
plot(time(idxApoapse),apoapse,'ro',MarkerFaceColor= 'r',MarkerEdgeColor='k')
plot(0,0,'ro',MarkerFaceColor= 'y',MarkerEdgeColor='k')

text(time(stage1SepIdx),positions(stage1SepIdx),txt1, HorizontalAlignment="right",FontSize=14);
text(time(stage2SepIdx),positions(stage2SepIdx),txt2, HorizontalAlignment="right",FontSize=14);
text(timeApoapse, apoapse+apoapse*0.05, txt3, 'HorizontalAlignment', "center", 'FontSize', 14);
text(0, 0, txt4, 'HorizontalAlignment', "left", 'FontSize', 14);

grid on;
hold off;

figure;
plot(time,velocities)
xlabel('Time (s)');
ylabel('Velocity (m/s)');
title('Rocket Velocity Over Time');
grid on;

figure;
tiledlayout(2,2);
sgtitle('Rocket Mass Overview')

nexttile;
plot(time,rocketmasses)
xlabel('Time (s)');
ylabel('Rocket Mass (Kg)');
title('Rocket Mass Over Time');
grid on;

nexttile;
plot(time,stage2masses)
xlabel('Time (s)');
ylabel('Stage 2 Mass (Kg)');
title('Stage 2 Mass Over Time');
grid on;

nexttile;
plot(time,stage3masses)
xlabel('Time (s)');
ylabel('Stage 3 Mass (Kg)');
title('Stage 3 Mass Over Time');
grid on;

nexttile;
plot(time,stage1masses)
xlabel('Time (s)');
ylabel('Stage 1 Mass (Kg)');
title('Stage 1 Mass Over Time');
grid on;