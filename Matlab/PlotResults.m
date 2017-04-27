ccc;
time = 1; x = 2; y = 3;
NumOfFiles = 2;
load('Routelength.mat');
TestNames = {'angle_correction','angle_correction'};%{'max_with_yaw_detection','mean_method'};
ReadDest = ['C:\Users\Nir\Documents\Offline_Fid\Results\'];
for jj = 1:length(TestNames)
    directories = dir([ReadDest,TestNames{jj},'\']);
    for ii=1:length(directories)
        dest = [ReadDest,TestNames{jj},'\',directories(ii).name];
        files = dir([dest,'\*.csv']); %search for csv files
        if ~isempty(files)
            logFile.(TestNames{jj}).(sprintf('Exper%d',ii-2)) = csvread([dest,'\',files(1).name]);
%             figure ('name', directories(ii).name);
%             plot(logFile(1,y),logFile(1,x),'or','linewidth',4);
%             hold on;
%             plot(logFile(:,y),logFile(:,x),'-b');
%             title (['\fontsize{20}',directories(ii).name]);
%             xlabel('\fontsize{16}y (east) [cm]');
%             ylabel('\fontsize{16}x (north) [cm]');
%             grid on;
%             if exist ([ReadDest,'Timing\timing_',directories(ii).name,'.csv'])
%                 timing = readtable([ReadDest,'Timing\timing_',directories(ii).name,'.csv']);
%                 timing.time(end) = logFile(end,1);
%                 Route = RealRoute(timing);
%                 plot(Route(2,:),Route(1,:),'--g');
%                 Route = [];
%                 legend('start','Estimate','Real');
%             end
%     %         saveas(gcf,[dest,'\',directories(i).name,'.jpg']);
        end
    end
end
for ii = 3:14
    figure;
    plot(logFile.(TestNames{1}).(sprintf('Exper%d',ii-2))(1,y),logFile.(TestNames{1}).(sprintf('Exper%d',ii-2))(1,x),'or','linewidth',4);
    hold on;
    plot(logFile.(TestNames{1}).(sprintf('Exper%d',ii-2))(1:end-10,y),logFile.(TestNames{1}).(sprintf('Exper%d',ii-2))(1:end-10,x),'-b');
    plot(logFile.(TestNames{2}).(sprintf('Exper%d',ii-2))(1:end-10,y),logFile.(TestNames{2}).(sprintf('Exper%d',ii-2))(1:end-10,x),'-m');
    dist(1)=sqrt( logFile.(TestNames{1}).(sprintf('Exper%d',ii-2))(end,y)^2 + logFile.(TestNames{1}).(sprintf('Exper%d',ii-2))(end,x)^2)/100;
    dist(2)=sqrt( logFile.(TestNames{2}).(sprintf('Exper%d',ii-2))(end,y)^2 + logFile.(TestNames{2}).(sprintf('Exper%d',ii-2))(end,x)^2)/100;
    if Routelength(ii-2)
        title ({['\fontsize{28}',directories(ii).name];...
            ['\fontsize{20}',sprintf('Distance error: 2016=%1.4f , Our=%1.4f',dist(2)/Routelength(ii-2),dist(1)/Routelength(ii-2))]});
    else
        title (['\fontsize{28}',directories(ii).name]);
    end
    xlabel('\fontsize{20}y (east) [cm]');
    ylabel('\fontsize{20}x (north) [cm]');
    grid on;
    axis square;
    if exist ([ReadDest,'Timing\timing_',directories(ii).name,'.csv'])
        timing = readtable([ReadDest,'Timing\timing_',directories(ii).name,'.csv']);
        timing.time(end) = logFile.(TestNames{1}).(sprintf('Exper%d',ii-2))(end,1);
        Route = RealRoute(timing);
        plot(Route(2,:),Route(1,:),'--g');
        Route = [];
        legend('start','our estimate','2016 estimate','Real');
    else
        legend('start','our estimate','2016 estimate');
    end
end

%% turn detection
figure;
plot(logFile.max_method.Exper3(1,y),logFile.max_method.Exper3(1,x),'or','linewidth',4);
hold on;
plot(logFile.max_method.Exper3(1:end-10,y),logFile.max_method.Exper3(1:end-10,x),'-b');
title ('\fontsize{28}Turning problem');
xlabel('\fontsize{20}y (east) [cm]');
ylabel('\fontsize{20}x (north) [cm]');
grid on;
axis square;
if exist ([ReadDest,'Timing\timing_',directories(5).name,'.csv'])
    timing = readtable([ReadDest,'Timing\timing_',directories(5).name,'.csv']);
    timing.time(end) = logFile.(TestNames{1}).Exper3(end,1);
    Route = RealRoute(timing);
    plot(Route(2,:),Route(1,:),'--g','linewidth',2);
    Route = [];
    legend('Start','Estimate','Real');
end
%
path = 'C:\Users\Nir\Documents\Offline_Fid\Raw_Data\Exper-3-3\';
filename ='20170122_123402.csv';
temp1 = readtable([path,filename]);
path = 'C:\Users\Nir\Documents\Offline_Fid\Test_vector\Exper-3-3\';
filename ='IMU.csv';
temp2 = readtable([path,filename]);
Yaw = temp2.Var10;
RawGyroZ = temp1.gyro_z(1:11:end);
MAGyroZ = MovingAverege(RawGyroZ,10);

figure;
yyaxis left
plot(temp2.Var1,MAGyroZ,'linewidth',1.5);
hold on; 
plot(temp2.Var1,0.2*ones(length(temp2.Var1)),'--k','linewidth',1);
plot(temp2.Var1,-0.2*ones(length(temp2.Var1)),'--k','linewidth',1);
grid on;
ylabel('\fontsize{20}Gyro_z[rad/sec]');
yyaxis right
plot(temp2.Var1,Yaw,'linewidth',1.5);
grid on; grid minor;
xlabel('\fontsize{20}t[sec]');
ylabel('\fontsize{20}Yaw[rad]');
title ('\fontsize{28}Turning detection');
