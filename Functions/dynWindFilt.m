function F = dynWindFilt(a,x)

% dynamic windowing
nFrames = size(x,1);
windowSize = a;
window = zeros(nFrames,1);
for n = 1:nFrames
    if mod(windowSize,2) % if odd
        if n <= (windowSize-1)/2
            window(n) = n*2 - 1;
        elseif n >= (nFrames - ((windowSize-1)/2))
            window(n) = (nFrames - n)*2 + 1;
        else
            window(n) = windowSize;
        end

    else % if even

        if n <= (windowSize)/2
            window(n) = n*2 - 1;
        elseif n >= (nFrames - ((windowSize)/2))
            window(n) = (nFrames - n)*2 + 1;
        else
            window(n) = windowSize;
        end

    end

end



temp = x(:,1);
temp2 = zeros(nFrames,1);
for n = 1:nFrames


    if mod(window(n),2) % check if window is odd
        if (window(n) == 1)
            lookahead = 0;
            lookback = 0;
        else
            lookahead = (window(n) - 1)/2;
            lookback = (window(n) - 1)/2;
        end
    else % window is even
        lookahead = (window(n)/2);
        lookback = (window(n)/2)-1;
    end
    temp3 = 0;
    for x = n-lookback:n+lookahead
        temp3 = temp3 + temp(x)/window(n);
        temp2(n) = temp3;
    end
    temp2(n) = temp3;


end
F = temp2;