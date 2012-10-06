AUTHOR: Jan Winter, TU Berlin, FG Lichttechnik,
		j.winter@tu-berlin.de, www.li.tu-berlin.de
LICENSE: free to use at your own risk. Kudos appreciated.

function [ ol490Spectrum ] = cs2000Spectrum_2_OL490Spectrum( cs2000Measurement )
% function [ ol490Spectrum ] = cs2000Spectrum_2_OL490Spectrum( cs2000Measurement )
% converts the spectrum of a cs2000Measurement into a suitable
% ol490Spectrum for spectrumAdaption.m

OL490MAX = 49152;
spectralData = cs2000Measurement.spectralData;

lamdaResolution = size( spectralData, 2 ) / 1023;
lamdaVector = 0 : ( size( spectralData, 2 ) - 1 );
splineLamda = 0 : lamdaResolution : size( spectralData, 2 );
splinedData = spline( lamdaVector, spectralData, splineLamda );
ol490Spectrum = splinedData / max( splinedData ) * OL490MAX;
ol490Spectrum = ol490Spectrum';




