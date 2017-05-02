function K = KF_func(K,ii)
K.K = K.P_est_m(:,:,ii)*K.H'*(K.H*K.P_est_m(:,:,ii)*K.H'+K.R)^-1;
K.x_est_p(:,ii) = K.x_est_m(:,ii) + K.K*(K.z-K.H*K.x_est_m(:,ii));
K.P_est_p(:,:,ii) = (eye(6)-K.K*K.H)*K.P_est_m(:,:,ii);
K.x_est_m(:,ii+1) = K.A*K.x_est_p(:,ii);
K.P_est_m(:,:,ii+1) = K.A*K.P_est_p(:,:,ii)*K.A'+K.Q;