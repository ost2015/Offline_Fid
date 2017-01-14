function [Roll,Pitch] = FindAngleKalman(rawGyroX,rawGyroY,Yaw,rawAccX,rawAccY,rawAccZ)
N = length(rawGyroX);
fs = 10; %Hz
dt = 1/fs;
%% calculate pitch and roll based only on acceleration
pitch = atan2(rawAccX, rawAccZ);
roll = -atan2(rawAccY, rawAccZ);

%% initiate kalman data
RollSpeed = 0; PitchSpeed = 0;
RollBias = 0; PitchBias = 0;
x = (roll; pitch; RollSpeed; PitchSpeed; RollBias; PitchBias);
P = x*x.';
A = [eye(2),dt*eye(2),-dt*eye(2);zeros(4,2),eye(4)];
Q = eye(6); Q(1:2,:) = Q(1:2,:)*dt^2; Q(3:4,:) = Q(3:4,:)*0.01*dt; Q(5:6,:) = Q(5:6,:)*0.03*dt;
R = 
for i = 1 : N
    yaw = Yaw(i)
    H = [RollSpeed+RollBias; PitchSpeed+PitchBias; -sin(-yaw)*cos(-roll); cos(-yaw)*cos(-roll);
    J1 = [sin(-yaw)*sin(-roll), 0; -cos(-yaw)*sin(-roll), 0];
    J = [zeros(2),eye(2),eye(2);J1,zeros(2,4)];  
    z = [rawGyroX;rawGyroY;rawAccX;rawAccY];
    % prediction
    x = A*x;
    P = A*P*A.' + Q;
    %update
    y = z - J*x;
    S = J*P*J.'+ R;
    K = P*J.'/S;
    x = x + K*y;
    P = (eye(6) - K*J)*P;
end
%% initiate kalman data
q1 = dt^2; q2 = 0.01*dt; q3 = 0.03*dt;
r1 = 1000; r2 = 1000;
p1 = 1000; p2 = 1000; p3 = 1000;
pitch = struct;
pitch.Q = diag([q1,q2,q3]);
pitch.R = diag([r1,r2]);
pitch.P = diag([p1,p2,p3]);
pitch.x = [0;0;0];
pitch.F = [1 dt -dt; 0 1 0; 0 0 1];
pitch.H = [1 0 0 ; 0 1 0];
roll = pitch;
%% kalman innovate
for i=1:length(acc_roll)
    Roll(i) = kalman_innovate(roll,acc_roll(i),rawGyroY(i));
    Pitch(i) = kalman_innovate(pitch,acc_pitch(i),rawGyroX(i));
end
Roll = Roll';
Pitch = Pitch';
