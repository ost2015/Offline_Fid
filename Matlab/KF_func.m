function K = KF_func(K,ii,M,turn)
% % calculate R and Q manually
% if isfield(K,'v')
%     n = size(K.v,2);
%     if n == M
%         K.v = circshift(K.v,[0,-1]);
%         K.v(:,M) = K.z-K.H*K.x_est_m(:,ii);
%         C = K.v * K.v.' / M;
% %         K.R = C - K.H*K.P_est_m(:,:,ii)*K.H';
%         if turn >=0.2
%             p=100;
%         else
%             p=1;
%         end
%         K.Q = p*K.K*C*K.K.';
%     else
%         K.v(:,n+1) = K.z-K.H*K.x_est_m(:,ii);
%     end
% else
%     K.v(:,1) = K.z-K.H*K.x_est_m(:,ii);
% end
K.K = K.P_est_m(:,:,ii)*K.H'*(K.H*K.P_est_m(:,:,ii)*K.H'+K.R)^-1;
K.x_est_p(:,ii) = K.x_est_m(:,ii) + K.K*(K.z-K.H*K.x_est_m(:,ii));
K.P_est_p(:,:,ii) = (eye(6)-K.K*K.H)*K.P_est_m(:,:,ii);
K.x_est_m(:,ii+1) = K.A*K.x_est_p(:,ii);
K.P_est_m(:,:,ii+1) = K.A*K.P_est_p(:,:,ii)*K.A'+K.Q;