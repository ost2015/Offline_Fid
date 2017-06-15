% function [Roll,Pitch] = FindAngle(rawData,alpha)
% inputs:   rawData - raw Data from sensors in a table
%           alpha - alpha for MA on roll and pitch
% outputs:  Roll  
%           Pitch 

function [Roll,Pitch] = FindAngle(rawData,alpha)

rawGyroX = rawData.gyro_x; rawGyroY = rawData.gyro_y;
rawAccX = rawData.gravity_x; rawAccY = rawData.gravity_y; rawAccZ = rawData.gravity_z;

dt = 1/10;
N = length(rawGyroX);
rollAcc = -atan2(rawData.gravity_y(1), rawData.gravity_z(1));
pitchAcc = atan2(rawData.gravity_x(1), rawData.gravity_z(1));
Roll(1) = rollAcc;
Pitch(1) = pitchAcc;
for i = 1:N-1
    Roll(i+1) = Roll(i) - rawGyroY(i+1)*dt; % check if plus or minus
    Pitch(i+1) = Pitch(i) + rawGyroX(i+1)*dt;
    rollAcc = -atan2(rawAccY(i+1), rawAccZ(i+1));
    pitchAcc = atan2(rawAccX(i+1), rawAccZ(i+1));
    Roll(i+1) = alpha*Roll(i+1) + (1-alpha)*rollAcc;
    Pitch(i+1) = alpha*Pitch(i+1) + (1-alpha)*pitchAcc;
end
Roll=Roll';
Pitch=Pitch';