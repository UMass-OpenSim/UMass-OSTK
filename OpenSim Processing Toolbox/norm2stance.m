function newData = norm2stance(data)

P = 101;
Q = size(data,1);
newData = resample(data,P,Q);

