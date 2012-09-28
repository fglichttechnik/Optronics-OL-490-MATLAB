function [ splinedData ] = percentSpline( spectralData, resolution)
%percentSpline makes a cubic spline for the percent rows
switch size(spectralData,1)
    case 11
        percentVector = 0:10:100;
    case 21
        percentVector = 0:5:100;
    case 41
        percentVector = 0:2.5:100;
    case 101
        percentVector = 0:100;
    otherwise
        error('Falscher Input!')
end

for k=1:size(spectralData,2)
    splinedData(:,k) = spline(percentVector,spectralData(:,k),resolution);
end
end