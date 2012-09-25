function [ splinedData ] = nmSpline( spectralData )
%nm_spline makes a cubic spline adaption over 1024 steps because of ol490
lamdaResolution = size( spectralData, 2 ) / 1023;
lamdaVector = 0 : ( size( spectralData, 2 ) - 1 );
splineLamda = 0: lamdaResolution : size( spectralData, 2 );
for k=1 : size( spectralData,1 )
    splinedData( k, : ) = spline( lamdaVector, spectralData( k, : ), splineLamda );
end
end