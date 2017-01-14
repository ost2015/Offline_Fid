ccc;
Time=1;Long=2; Lat=3;Alt=4;AccX=5;AccY=6;AccZ=7;Roll=8;Pitch=9;Yaw=10;
dest = 'C:\Users\Nir\Documents\MATLAB\Final Project\Raw\';
files = dir([dest,'*.csv']);
altitude = 2; % in meter
global alpha
alpha =[0.3];
for i =1: length(files)
    rawData{i} = readtable([dest,files(i).name]);
    for j=1%:4 %j is for different alpha in FindAngle
        Data{i} = buildData(rawData{i},altitude,j);
        h1=subplot(3,1,1);
        plot(Data{i}(:,Time),Data{i}(:,Roll));
        title ('Roll');
        hold on;
        h2=subplot(3,1,2);
        plot(Data{i}(:,Time),Data{i}(:,Pitch));
        title('Pitch');
        hold on;

    end
    RawRoll = -atan2(rawData{i}.gravity_y,rawData{i}.gravity_z);
    plot(h1,Data{i}(:,Time),RawRoll,'--r');
    legend(h1,'Comp','Raw');
    RawPitch = atan2(rawData{1}.gravity_x,rawData{1}.gravity_z);
    plot(h2,Data{i}(:,Time),RawPitch,'--r');
    legend(h2,'Comp','Raw');
    subplot(3,1,3)
    plot(Data{i}(:,Time),Data{i}(:,Yaw));
    title('Yaw');
%     Data_kalman{i} = buildData_kalman(rawData{i},altitude);
    [~,name,~] = fileparts(files(i).name);
    temp = isdir(name);
    if ~temp
        mkdir(name)
    end
    csvwrite([name,'\IMU.csv'],Data{i}); 
%     writetable(Data{i},files(i).name);
end
videoFiles = dir([dest,'*.mp4']);
for i =1: length(videoFiles)
    vid = VideoReader([dest,videoFiles(i).name]);
    dt = 1/vid.FrameRate;
    time = 0:dt:vid.Duration-dt;
    T = [dt;time'];
    [~,name,~] = fileparts(videoFiles(i).name);
    temp = isdir(name);
    if ~temp
        mkdir(name)
    end
    csvwrite([name,'\VID_timestamp.csv'],T);
end