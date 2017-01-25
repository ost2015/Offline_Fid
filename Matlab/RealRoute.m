function Route = RealRoute(timing)
[m,~]=size(timing);
fs = 10; %sample rate
t = 0;
cornerStart = zeros(2,1);
cornerEnd = zeros(2,1);
Route = [];
for i = 1 : m
    xAngle = cos(timing.yaw(i)); yAngle = sin(timing.yaw(i));
    cornerEnd = cornerEnd + [timing.range(i) * xAngle; timing.range(i) * yAngle];
    NumOfSample = (timing.time(i)-t) * fs;
    temp(1,:) = linspace(cornerStart(1),cornerEnd(1),NumOfSample);
    temp(2,:) = linspace(cornerStart(2),cornerEnd(2),NumOfSample);
    Route = [Route,temp];
    t = timing.time(i); % for next loop
    cornerStart = cornerEnd; % for next loop
    temp= [];
end
Route = Route * 100; % cm
