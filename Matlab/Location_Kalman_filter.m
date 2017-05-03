ccc;
%% load data after yaw
% location table
filename_result = '..\Results\';
experiment = 'angle_correction\';
folder = dir([filename_result,experiment]);
folder(1:2) = [];
for jj = 1:size(folder,1)
    temp = readtable([filename_result,experiment,folder(jj).name,'\OF_log.csv']);
    [~,ia,~] = unique(temp(:,1));
    location_table = table2array(temp(ia,:));
    % IMU table
    filename_test = '..\Test_vector\';
    imu_table = table2array(readtable([filename_test,folder(jj).name,'\IMU.csv']));

    %% measurments 
    % after yaw
    N = min(size(location_table,1),size(imu_table,1));
    x=1;y=2;acc_x=3;acc_y=4;acc_z=5;theta=6;phi=7;psi=8;
    z(x,:)       = location_table(1:N,2); %[cm]
    z(y,:)       = location_table(1:N,3);
    z(acc_x,:)   = imu_table(1:N,5)*100; %[cm/s^2]
    z(acc_y,:)   = imu_table(1:N,6)*100;
    z(acc_z,:)   = imu_table(1:N,7)*100;
    z(phi,:)     = imu_table(1:N,8);
    z(theta,:)   = imu_table(1:N,9);
    z(psi,:)     = imu_table(1:N,10);
    gyro_z       = imu_table(1:N,15);

    %% noise from sampling
    n_x = 500;
    n_y = 500;
    n_ax = [9e-06];
    n_ay = [9e-06];
    n_az = [1.6e-05]; 
    n_theta = [0.005];
    n_phi = [4e-04];
    n_psi = [4e-06];
    %% Kalman parameters
    M = 15;
    dt =  0.1;
    R_c = diag([n_x,n_y,n_ax,n_ay,n_az,n_theta,n_phi,n_psi]) ; % matrix for the sensors noise
    K.R = R_c / dt;
    K.A = [1    dt  0.5*dt^2    0   0   0; ...
           0    1   dt          0   0   0; ...
           0    0   1           0   0   0; ...
           0    0   0           1   dt  0.5*dt^2; ...
           0    0   0           0   1   dt; ...
           0    0   0           0   0   1];
    K.x_est_m = zeros(6,1);
    K.P_est_m = eye(6)*10000;
    MA_size = 10;
    filt_gyro = zeros(MA_size,1);
    thr = 0.2;turn = 0;
    %% KF after
    for ii = 1:N % number of samples
        % turn detection
        if ii<=MA_size
            filt_gyro(ii) = gyro_z(ii);
        else
            filt_gyro = circshift(filt_gyro,-1);
            filt_gyro(MA_size) = gyro_z(ii);
            turn = sum(filt_gyro)/MA_size;
        end
        if turn >= thr
            b1 = 10; % location
            b2 = 10; % velocity
            b3 = 1000; % acc    
        else
            b1 = 1; % location
            b2 = 1; % velocity
            b3 = 100; % acc
        end
        K.Q = diag([b1,b2,b3,b1,b2,b3]); % matrix for process noise

        K.z = z(:,ii);
        c_theta = cos(z(theta,ii)); s_theta = sin(z(theta,ii));
        c_phi = cos(z(phi,ii));     s_phi = sin(z(phi,ii));
        c_psi = cos(z(psi,ii));     s_psi = sin(z(psi,ii));
        a1 = c_theta*c_psi;                     a2 = c_theta*s_psi;
        b1 = s_theta*s_phi*c_psi - s_psi*c_phi; b2 = s_psi*s_theta*s_phi + c_psi*c_phi;
        c1 = s_theta*c_phi*c_psi + s_psi*s_phi; c2 = s_psi*s_theta*c_phi - c_psi*s_phi;
        K.H = [1    0   0   0   0   0; ...
               0    0   0   1   0   0; ...
               0    0   a1  0   0   a2; ...
               0    0   b1  0   0   b2; ...
               0    0   c1  0   0   c2; ...
               0    0   0   0   0   0; ...
               0    0   0   0   0   0; ...
               0    0   0   0   0   0];
        K = KF_func(K,ii,M,turn);
    end

    %% plot results
    figure;
    hold on;
        % Timing table
    if exist ([filename_result,'Timing\timing_',folder(jj).name,'.csv'])
        timing =readtable([filename_result,'Timing\timing_',folder(jj).name,'.csv']);
        Route = RealRoute(timing);
    else
        Route = zeros(2,length(z(x,:)));
    end
    plot(Route(2,:),Route(1,:),'k');
    plot(-z(x,:),z(y,:),'r');
    plot(-K.x_est_m(1,:),K.x_est_m(4,:),'b');
    plot(-K.x_est_p(1,:),K.x_est_p(4,:),'g');
    grid on;
    legend('x','x_{OF}','x_{est}^-','x_{est}^+');
    title(folder(jj).name)
    axis square
    clearvars  K z gyro_z Rpute
end
