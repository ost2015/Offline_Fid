ccc;
%% define variables
Time=1;Long=2; Lat=3;Alt=4;AccX=5;AccY=6;AccZ=7;Roll=8;Pitch=9;Yaw=10;
RawRoll=11;RawPitch=12;gyro_x=13;gyro_y=14;gyro_z=15;
ReadDest = '..\Raw_Data\';
SaveDest = '..\Test_vector\';
alpha = 0.3; %roll & pitch filter coefficient
f_desire = 10; % desired system frequency [Hz]
f_real = 10; % real system frequency [Hz]
n = f_real/f_desire;
jump_in_freq = 0;
%% prompt for height
% prompt = 'What is the altitude value (in meter)? ';
% altitude = input(prompt); % in meter
altitude = 2; % in meter
%% main code for csv
directories = dir(ReadDest);
for m = 16%(length(directories))
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
%     figure('name',name);
%     h1=subplot(3,1,1);
%     plot(Data(:,Time),Data(:,Roll));
%     title ('Roll');
%     grid on;
%     hold on;
%     h2=subplot(3,1,2);
%     plot(Data(:,Time),Data(:,Pitch));
%     title('Pitch');
%     grid on;
%     hold on;
%     % raw data from imu
%     plot(h1,Data(:,Time),Data(:,RawRoll),'--r','lineWidth',2);
%     plot(h2,Data(:,Time),Data(:,RawPitch),'--r','lineWidth',2);
%     h3 = subplot(3,1,3);
%     
% %     plot(Data(:,Time),Data(:,Yaw));
%     t = Data(:,Time);
%     plotyy(t, Data(:,Yaw),t, MovingAverege(rawData.gyro_z,10))
%     legend('yaw','gyro_z');
%     grid on;
%     title('Yaw');
%     
%% filter raw roll and pitch
%     for order = [3,4,5]; % order of MA
%         filt_roll = MovingAverege(Data(:,RawRoll),order);
%         filt_pitch = MovingAverege(Data(:,RawPitch),order);
%         plot(h1,Data(:,Time),filt_roll);
%         plot(h2,Data(:,Time),filt_pitch);
%     end
%     legend(h1,'Comp','Raw','MA 3','MA 4','MA 5');
%     legend(h2,'Comp','Raw','MA 3','MA 4','MA 5');
%     linkaxes([h1,h2,h3],'x');
%% KF
%     Data_kalman{i} = buildData_kalman(rawData{i},altitude);
%% save csv
    temp = isdir([SaveDest,name]);
    if ~temp
        mkdir([SaveDest,name])
    end
    csvwrite([SaveDest,name,'\IMU.csv'],Data); 
%     save([SaveDest,name,'\',name,'.txt']);
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