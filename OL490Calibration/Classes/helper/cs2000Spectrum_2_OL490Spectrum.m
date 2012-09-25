function [ ol490Spectrum ] = cs2000Spectrum_2_OL490Spectrum( cs2000Measurement )
% converts the spectrum of a cs2000Measurement into a suitable
% ol490Spectrum for spectrumAdaption.m

spectralData = cs2000Measurement.spectralData;

lamdaResolution = size( spectralData, 2 ) / 1023;
lamdaVector = 0 : ( size( spectralData, 2 ) - 1 );
splineLamda = 0 : lamdaResolution : size( spectralData, 2 );
splinedData = spline( lamdaVector, spectralData, splineLamda );
ol490Spectrum = splinedData;




