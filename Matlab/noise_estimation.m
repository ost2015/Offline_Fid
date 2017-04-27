ccc;

filename = dir('*.csv');
Temp = readtable(filename.name);
T = Temp(10:end-10,:);
N = size(T,1); % number of samples for each sensor
%% noise est for gyro
figure('name','gyro_x');
for ii = 1:4
    subplot(2,2,ii)
    n = round(N/ii);
    histogram(T.gyro_x(1:n),100);
    str = sprintf('n = %d',n);
    std_str = sprintf('sigma = %f',std(T.gyro_x(1:n)));
    title({['\fontsize{20}',str],['\fontsize{18}',std_str]});
end
figure('name','gyro_y');
for ii = 1:4
    subplot(2,2,ii)
    n = round(N/ii);
    histogram(T.gyro_y(1:n),100);
    str = sprintf('n = %d',n);
    std_str = sprintf('sigma = %f',std(T.gyro_y(1:n)));
    title({['\fontsize{20}',str],['\fontsize{18}',std_str]});
end
figure('name','gyro_z');
for ii = 1:4
    subplot(2,2,ii)
    n = round(N/ii);
    histogram(T.gyro_z(1:n),100);
    str = sprintf('n = %d',n);
    std_str = sprintf('sigma = %f',std(T.gyro_z(1:n)));
    title({['\fontsize{20}',str],['\fontsize{18}',std_str]});
end
%% noise est for acc
figure('name','acc_x');
for ii = 1:4
    subplot(2,2,ii)
    n = round(N/ii);
    histogram(T.AccX(1:n),100);
    str = sprintf('n = %d',n);
    std_str = sprintf('sigma = %f',std(T.AccX(1:n)));
    title({['\fontsize{20}',str],['\fontsize{18}',std_str]});
end
figure('name','acc_y');
for ii = 1:4
    subplot(2,2,ii)
    n = round(N/ii);
    histogram(T.AccY(1:n),100);
    str = sprintf('n = %d',n);
    std_str = sprintf('sigma = %f',std(T.AccY(1:n)));
    title({['\fontsize{20}',str],['\fontsize{18}',std_str]});
end
figure('name','acc_z');
for ii = 1:4
    subplot(2,2,ii)
    n = round(N/ii);
    histogram(T.AccZ(1:n),100);
    str = sprintf('n = %d',n);
    std_str = sprintf('sigma = %f',std(T.AccZ(1:n)));
    title({['\fontsize{20}',str],['\fontsize{18}',std_str]});
end
%% noise est for location (x,y)
