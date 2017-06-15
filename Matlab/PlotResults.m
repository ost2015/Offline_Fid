clear all; close all; clc;
time = 1; x = 2; y = 3;
NumOfFiles = 2;
load('Routelength.mat');
TestNames = {'No_perspective','With_perspective'};%{'max_with_yaw_detection','mean_method'};
ReadDest = '..\Results\';
ReadTiming = '..\Test_vector\';

% load tests
% ----------
for jj = 1:length(TestNames)
    directories = dir([ReadDest,TestNames{jj},'\']);
    for ii=1:length(directories)
        dest = [ReadDest,TestNames{jj},'\',directories(ii).name];
        files = dir([dest,'\*.csv']); %search for csv files
        if ~isempty(files)
            logFile.(TestNames{jj}).(sprintf('Exper%d',ii-2)) = csvread([dest,'\',files(1).name]);
        end
    end
end

% starting point bias from [0,0]
% ------------------------------
bias = zeros(length(directories),2);
bias(12,:) = [148,76];
bias(13,:) = [120,12];
bias(15,:) = [-60,16];
bias(16,:) = [-130,-20];

% plot data
% ---------
directories(1:2,:) = [];
for ii = 1:length(directories)
    figure;
    strt_x = -logFile.(TestNames{1}).(sprintf('Exper%d',ii))(5,x);
    strt_y = logFile.(TestNames{1}).(sprintf('Exper%d',ii))(5,y);
    plot(strt_x,strt_y,'or','linewidth',4);
    hold on;
    plot(-logFile.(TestNames{1}).(sprintf('Exper%d',ii))(1:end-10,x),logFile.(TestNames{1}).(sprintf('Exper%d',ii))(1:end-10,y),'-b');
    plot(-logFile.(TestNames{2}).(sprintf('Exper%d',ii))(1:end-10,x),logFile.(TestNames{2}).(sprintf('Exper%d',ii))(1:end-10,y),'-r');
    dx_1 = logFile.(TestNames{1}).(sprintf('Exper%d',ii))(end,x) - strt_x;
    dy_1 = logFile.(TestNames{1}).(sprintf('Exper%d',ii))(end,y) - strt_y;
    dx_2 = logFile.(TestNames{2}).(sprintf('Exper%d',ii))(end,x) - strt_x;
    dy_2 = logFile.(TestNames{2}).(sprintf('Exper%d',ii))(end,y) - strt_y;    
    dist(1)=sqrt( dy_1^2 + dx_1^2)/100;
    dist(2)=sqrt( dy_2^2 + dx_2^2)/100;
    if Routelength(ii)
        title ({['\fontsize{28}',directories(ii).name];...
            ['\fontsize{20}',sprintf('Distance error: w.o KF=%1.4f , w KF=%1.4f',dist(2)/Routelength(ii),dist(1)/Routelength(ii))]});
    else
        title ({['\fontsize{28}',directories(ii).name];...
            ['\fontsize{20}',sprintf('Distance error: w.o KF=%1.4f [m] , w KF=%1.4f [m]',dist(2),dist(1))]});
    end
    xlabel('\fontsize{20}y (east) [cm]');
    ylabel('\fontsize{20}x (north) [cm]');
    grid on;
    axis square;
    if exist ([ReadDest,'Timing\timing_',directories(ii).name,'.csv'])
        IMUtable = readtable([ReadTiming,directories(ii).name,'\IMU.csv']);
        timing =readtable([ReadDest,'Timing\timing_',directories(ii).name,'.csv']);
        timing.time(end) = logFile.(TestNames{1}).(sprintf('Exper%d',ii))(end,1);
        Route = RealRoute(timing,bias(ii,:)');
        plot(Route(2,:),Route(1,:),'--k');
        Route = [];
        legend('start','w. KF','w.o KF','Real');
    else
        legend('start','w. KF','w.o KF');
    end
end