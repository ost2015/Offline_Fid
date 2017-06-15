% function Data = buildData(rawData,altitude,alpha)
% inputs:   rawData - raw Data from sensors in a table
%           altitude - height [m]
%           alpha - alpha for MA on roll and pitch
% outputs:  Data - final data table

function  Data = buildData(rawData,altitude,alpha)
Long = rawData.Longitude;
Lat = rawData.Latitude;
Alt = ones(size(rawData,1),1)*altitude;
AccX = rawData.AccX;
AccY = rawData.AccY;
AccZ = rawData.AccZ;
RawRoll = deg2rad(rawData.Pitch);
RawPitch = deg2rad(rawData.Roll);
[Roll,Pitch] = FindAngle(rawData,alpha);
Yaw = deg2rad(rawData.Heading);
gyro_x = rawData.gyro_x;
gyro_y = rawData.gyro_y;
gyro_z = rawData.gyro_z;
dt = 1/10;
Time = 0:dt:(length(rawData.AccX)-1)*dt;
Data = [Time',Long,Lat,Alt,AccX,AccY,AccZ,Roll,Pitch,Yaw,RawRoll,RawPitch...
    gyro_x,gyro_y,gyro_z];