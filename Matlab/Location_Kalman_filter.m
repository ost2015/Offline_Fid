ccc;
%% load sensors
x=1;y=2;v_x=3;v_y=4;acc_x=5;acc_y=6;acc_z=7;theta=8;phi=9;psi=10;
z(x,:)       = [];
z(y,:)       = [];
z(v_x,:)     = [];
z(v_y,:)     = [];
z(acc_x,:)   = [];
z(acc_y,:)   = [];
z(acc_z,:)   = [];
z(theta,:)   = [];
z(phi,:)     = [];
z(psi,:)     = [];

%% Kalman parameters
dt =  0.1;
R_c = [] ; % matrix for the sensors noise
K.R = R_c / dt;
K.Q = []; % matrix for process noise
K.A = [1    dt  0.5*dt^2    0   0   0; ...
       0    1   dt          0   0   0; ...
       0    0   1           0   0   0; ...
       0    0   0           1   dt  0.5*dt^2; ...
       0    0   0           0   1   dt; ...
       0    0   0           0   0   1];
K.y_est_m = [];
K.P_est_m = [];
%% KF
for ii = 1:size(z,2) % number of samples
    K.z = z(ii,:);
    c_theta = cos(z(ii,theta)); s_theta = sin(z(ii,theta));
    c_phi = cos(z(ii,phi));     s_phi = sin(z(ii,phi));
    c_psi = cos(z(ii,psi));                 s_psi = sin(z(ii,psi));
    a1 = c_theta*c_phi;                     a2 = c_theta*c_psi;
    b1 = s_theta*s_phi*c_psi - s_psi*c_phi; b2 = s_psi*s_theta*s_phi + c_psi*c_theta;
    c1 = s_theta*s_phi*c_psi + s_psi*s_phi; c2 = s_psi*s_theta*c_phi - c_psi*s_theta;
    K.H = [1    0   0   0   0   0; ...
           0    0   1   0   0   0; ...
           0    1   0   0   0   0; ...   
           0    0   0   1   0   0; ... 
           0    0   0   0   a1  a2; ...
           0    0   0   0   b1  b2; ...
           0    0   0   0   c1  c2; ...
           0    0   0   0   0   0; ...
           0    0   0   0   0   0; ...
           0    0   0   0   0   0];
    K = KF_func(K,ii);
end
%% plot results
k = 0:size(z,2) - 1; % discrete time