ccc;
filename = '..\Raw_Data\Exper-noise\20170322_111144.csv';
Temp = readtable(filename);
T = Temp(10:end-10,:);
N = size(T,1); % number of samples for each sensor
%% noise est for gyro
figure('name','roll');
for ii = 1:4
    subplot(2,2,ii)
    n = round(N/ii);
    hist(T.Roll(1:n),100);
    str = sprintf('n = %d',n);
    std_str = sprintf('sigma = %f',std(T.Roll(1:n)));
    title({['\fontsize{20}',str],['\fontsize{18}',std_str]});
end
figure('name','pitch');
for ii = 1:4
    subplot(2,2,ii)
    n = round(N/ii);
    hist(T.Pitch(1:n),100);
    str = sprintf('n = %d',n);
    std_str = sprintf('sigma = %f',std(T.Pitch(1:n)));
    title({['\fontsize{20}',str],['\fontsize{18}',std_str]});
end
T.Yaw = deg2rad(T.Heading);
figure('name','yaw');
for ii = 1:4
    subplot(2,2,ii)
    n = round(N/ii);
    hist(T.Yaw(1:n),100);
    str = sprintf('n = %d',n);
    std_str = sprintf('sigma = %f',std(T.Yaw(1:n)));
    title({['\fontsize{20}',str],['\fontsize{18}',std_str]});
end
%% noise est for acc
figure('name','acc_x');
for ii = 1:4
    subplot(2,2,ii)
    n = round(N/ii);
    hist(T.AccX(1:n),100);
    str = sprintf('n = %d',n);
    std_str = sprintf('sigma = %f',std(T.AccX(1:n)));
    title({['\fontsize{20}',str],['\fontsize{18}',std_str]});
end
figure('name','acc_y');
for ii = 1:4
    subplot(2,2,ii)
    n = round(N/ii);
    hist(T.AccY(1:n),100);
    str = sprintf('n = %d',n);
    std_str = sprintf('sigma = %f',std(T.AccY(1:n)));
    title({['\fontsize{20}',str],['\fontsize{18}',std_str]});
end
figure('name','acc_z');
for ii = 1:4
    subplot(2,2,ii)
    n = round(N/ii);
    hist(T.AccZ(1:n),100);
    str = sprintf('n = %d',n);
    std_str = sprintf('sigma = %f',std(T.AccZ(1:n)));
    title({['\fontsize{20}',str],['\fontsize{18}',std_str]});
end
%% noise est for location (x,y)
filename = '..\Results\expr-noise2\OF_log.csv';
Temp = readtable(filename);
T2 = Temp(10:end-10,:);
N2 = size(T2,1); % number of samples for each sensor

figure('name','x');
for ii = 1:4
    subplot(2,2,ii)
    n = round(N2/ii);
    hist(T2.x_7_56841(1:n),100);
    str = sprintf('n = %d',n);
    std_str = sprintf('sigma = %f',std(T2.x_7_56841(1:n)));
    title({['\fontsize{20}',str],['\fontsize{18}',std_str]});
end
figure('name','y');
for ii = 1:4
    subplot(2,2,ii)
    n = round(N2/ii);
    hist(T2.x3_52985(1:n),100);
    str = sprintf('n = %d',n);
    std_str = sprintf('sigma = %f',std(T2.x3_52985(1:n)));
    title({['\fontsize{20}',str],['\fontsize{18}',std_str]});
end
