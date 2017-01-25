function filt = MovingAverege(Data,order)
n = length(Data);
for i=1:n
    if i<=order
        filt(i) = mean(Data(1:i));
    else
        filt(i) = mean(Data(i-order:i));
    end
end