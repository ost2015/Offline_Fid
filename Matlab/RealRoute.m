function Route = RealRoute(timing,yaw)
[m,~]=size(timing);
fs = 10; %sample rate
t_prev = 1;
cornerStart = zeros(2,1);
cornerEnd = zeros(2,1);
Route = [];
yaw = table2array(yaw);
for i = 1 : m
    t_cur = find(yaw(:,1) == timing.time(i));
    mean_yaw = mean(yaw(t_prev:t_cur,2));
    xAngle = cos(mean_yaw); yAngle = sin(mean_yaw);
    cornerEnd = cornerEnd + [timing.range(i) * xAngle; timing.range(i) * yAngle];
    NumOfSample = (timing.time(i)-yaw(t_prev,1)) * fs;
    temp(1,:) = linspace(cornerStart(1),cornerEnd(1),NumOfSample);
    temp(2,:) = linspace(cornerStart(2),cornerEnd(2),NumOfSample);
    Route = [Route,temp];
    t_prev = t_cur+1; % for next loop
    cornerStart = cornerEnd; % for next loop
    temp= [];
end
Route = Route * 100; % cm
