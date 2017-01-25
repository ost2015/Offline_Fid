ccc;
time = 1; x = 2; y = 3;
NumOfFiles = 2;
ReadDest = 'C:\Users\Nir\Documents\Offline_Fid\Results\';
directories = dir(ReadDest);
for i=1:length(directories)
    dest = [ReadDest,directories(i).name];
    files = dir([dest,'\*.csv']); %search for csv files
    if ~isempty(files)
        logFile = csvread([dest,'\',files(1).name]);
        figure ('name', directories(i).name);
        plot(logFile(1,y),logFile(1,x),'or','linewidth',4);
        hold on;
        plot(logFile(:,y),logFile(:,x),'-b');
        title (['\fontsize{20}',directories(i).name]);
        xlabel('\fontsize{16}y (east) [cm]');
        ylabel('\fontsize{16}x (north) [cm]');
        grid on;
        if size(files,1)==2
            timing = readtable([dest,'\',files(2).name]);
            timing.time(end) = logFile(end,1);
            Route = RealRoute(timing);
            plot(Route(2,:),Route(1,:),'--g');
            Route = [];
            legend('start','Estimate','Real');
        end
        hold off;
%         saveas(gcf,[dest,'\',directories(i).name,'.jpg']);
    end
end