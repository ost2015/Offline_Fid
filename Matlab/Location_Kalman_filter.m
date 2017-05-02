ccc;
%% load sensors
% location table
filename = '..\Results\';
experiment = 'angle_correction\';
folder = 'Exper-3-1\';
temp = readtable([filename,experiment,folder,'OF_log.csv']);
[~,ia,~] = unique(temp(:,1));
location_table = table2array(temp(ia,:));
% IMU table
filename = '..\Test_vector\';
imu_table = table2array(readtable([filename,folder,'IMU.csv']));
% 
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
%% noise from sampling
n_x = [10];
n_y = [10];
n_ax = [9e-06*100];
n_ay = [9e-06*100];
n_az = [1.6e-05*100]; 
n_theta = [0.005];
n_phi = [4e-04];
n_psi = [4e-06];
%% Kalman parameters
M = 1;
dt =  0.1;
R_c = diag([n_x,n_y,n_ax,n_ay,n_az,n_theta,n_phi,n_psi]) ; % matrix for the sensors noise
K.R = R_c / dt;
b1 = 10*ones(1,2); % location
b2 = 10*ones(1,2); % velocity
b3 = 1000*ones(1,2); % acc
K.Q = diag([b1,b2,b3]); % matrix for process noise
K.A = [1    dt  0.5*dt^2    0   0   0; ...
       0    1   dt          0   0   0; ...
       0    0   1           0   0   0; ...
       0    0   0           1   dt  0.5*dt^2; ...
       0    0   0           0   1   dt; ...
       0    0   0           0   0   1];
K.x_est_m = zeros(6,1);
K.P_est_m = eye(6)*10000;
%% KF
for ii = 1:N % number of samples
    K.z = z(:,ii);
    c_theta = cos(z(theta,ii)); s_theta = sin(z(theta,ii));
    c_phi = cos(z(phi,ii));     s_phi = sin(z(phi,ii));
    c_psi = cos(z(psi,ii));                 s_psi = sin(z(psi,ii));
    a1 = c_theta*c_phi;                     a2 = c_theta*c_psi;
    b1 = s_theta*s_phi*c_psi - s_psi*c_phi; b2 = s_psi*s_theta*s_phi + c_psi*c_theta;
    c1 = s_theta*s_phi*c_psi + s_psi*s_phi; c2 = s_psi*s_theta*c_phi - c_psi*s_theta;
    K.H = [1    0   0   0   0   0; ...
           0    0   1   0   0   0; ...
           0    0   0   0   a1  a2; ...
           0    0   0   0   b1  b2; ...
           0    0   0   0   c1  c2; ...
           0    0   0   0   0   0; ...
           0    0   0   0   0   0; ...
           0    0   0   0   0   0];
    K = KF_func(K,ii,M);
end
%% plot results
figure;
hold on;
plot(z(x,:),z(y,:),'r');
plot(K.x_est_m(x,:),K.x_est_m(y,:),'b');
plot(K.x_est_p(x,:),K.x_est_p(y,:),'g');
legend('x_{OF}','x_{est}^-','x_{est}^+');