function [Roll,Pitch] = FindAngle(rawData,j)

rawGyroX = rawData.gyro_x; rawGyroY = rawData.gyro_y;
rawAccX = rawData.gravity_x; rawAccY = rawData.gravity_y; rawAccZ = rawData.gravity_z;

dt = 1/10;
N = length(rawGyroX);
global alpha;
rollAcc = -atan2(rawData.gravity_y(1), rawData.gravity_z(1));
pitchAcc = atan2(rawData.gravity_x(1), rawData.gravity_z(1));
Roll(1) = rollAcc;
Pitch(1) = pitchAcc;
for i = 1:N-1
    Roll(i+1) = Roll(i) - rawGyroY(i+1)*dt; % check if plus or minus
    Pitch(i+1) = Pitch(i) + rawGyroX(i+1)*dt;
    rollAcc = -atan2(rawAccY(i+1), rawAccZ(i+1));
    pitchAcc = atan2(rawAccX(i+1), rawAccZ(i+1));
    Roll(i+1) = alpha(j)*Roll(i+1) + (1-alpha(j))*rollAcc;
    Pitch(i+1) = alpha(j)*Pitch(i+1) + (1-alpha(j))*pitchAcc;
end
Roll=Roll';
Pitch=Pitch';