clear all; close all; clc;

%% define variables
Time=1;Long=2; Lat=3;Alt=4;AccX=5;AccY=6;AccZ=7;Roll=8;Pitch=9;Yaw=10;
RawRoll=11;RawPitch=12;gyro_x=13;gyro_y=14;gyro_z=15;
ReadDest = '..\Raw_Data\';
SaveDest = '..\Test_vector\';
alpha = 0.3; %roll & pitch filter coefficient
f_desire = 10; % desired system frequency [Hz] - if you record more then once the freq changes!!!!
f_real = 10; % real system frequency [Hz]
n = f_real/f_desire;
jump_in_freq = 0;

%% prompt for height
% prompt = 'What is the altitude value (in meter)? ';
% altitude = input(prompt); % in meter
altitude = 2; % in meter

%% main code for csv
directories = dir(ReadDest);
directories(1:2,:) = [];
for m = 1:(length(directories))
    if (~directories(m).isdir)
        break;
    end
    temp = [];
    name = directories(m).name;
    newdest = [ReadDest,directories(m).name,'\'];
    files = dir([newdest,'*.csv']); %search for csv files
    temp = readtable([newdest,files.name]);
    rawData = temp(1:n:end,:); % delete the doubled rows
    n = n+jump_in_freq; % jump_in_freq is represent if all the real system freq are the same
    Data = buildData(rawData,altitude,alpha);
    
%% save csv
    temp = isdir([SaveDest,name]);
    if ~temp
        mkdir([SaveDest,name])
    end
    csvwrite([SaveDest,name,'\IMU.csv'],Data); 
%% main code for mp4
    videoFiles = dir([newdest,'*.mp4']); %find mp4 file
    vid = VideoReader([newdest,videoFiles.name]);
    dt = 1/vid.FrameRate;
    time = 0:dt:vid.Duration-dt;
    T = [dt;time'];
% save video
    temp = isdir([SaveDest,name]);
    if ~temp
        mkdir([SaveDest,name])
    end
    csvwrite([SaveDest,name,'\VID_timestamp.csv'],T);
    copyfile([newdest,videoFiles.name],[SaveDest,name,'\VIDEO.mp4']);
end