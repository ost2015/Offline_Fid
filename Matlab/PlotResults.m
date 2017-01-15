ccc;
time = 1; x = 2; y = 3;
ReadDest = 'C:\Users\Nir\Documents\Offline_Fid\Results\';
directories = dir(ReadDest);
for i=1:length(directories)
    dest = [ReadDest,directories(i).name];
    files = dir([dest,'\*.csv']); %search for csv files
    if ~isempty(files)
        log = csvread([dest,'\',files.name]);
        figure ('name', directories(i).name);
%         plot3(log(1,x),log(1,y),log(1,time),'*r','linewidth',8);
        plot(log(1,x),log(1,y),'*r','linewidth',8);
        hold on;
%         plot3(log(:,x),log(:,y),log(:,time),'b');
        plot(log(:,x),log(:,y),'-b');
%         legend('start','x-y-t', 'x-y');
        title (directories(i).name);
        xlabel('x [cm]');
        ylabel('y [cm]');
        zlabel('t [sec]');
        grid on;
    end
end
%% filter log
% alpha = 0.75;
% filt = log(1,x:y);
% for i = 2:length(log(:,time))
%    filt(i,:) = alpha * filt(i-1,:) + (1-alpha) * log(i,x:y);
% end