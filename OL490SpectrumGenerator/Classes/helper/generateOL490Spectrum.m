function [ ol490Spectrum ] = generateOL490Spectrum( targetSpectrum, interpolatedSpectralDataCalibrationMatrix, inputOutputCalibrationMatrix, interpolatedMaxValuesForDimLevelSpectra, dimFactor )
% generateOL490Spectrum
%   targetSpectrum - requested spectrum, vector with 1024 columns
%   interpolatedSpectralDataCalibrationMatrix - matrix generated with OL490-class
%   inputOutputCalibrationMatrix       - matrix generated with OL490-class
%   dimFactor     - number between 0 and 1 [p.e. 0.543], default is 1
%   ol490Spectrum    - adapted vector with ol490-values, from 0 till 49152
%   interpolatedMaxValuesForDimLevelSpectra     - values to recalculate real value of percentual value (needed for Lv)

OL490MAX = 49152;
if nargin < 5
    dimFactor = 1;
else
    if dimFactor > 1
        dimFactor = 1;
    end
end

%userSpectrum preparation
%list with smallest value differences between spectraPercent and userSpectrum
%between 400nm - 680 nm values are necessary for adaption, the rest values 
%will degreded the final adaption to much (51 equals 20nm and 256 equals 100nm) 
userPercent = userSpectrum ./ OL490MAX;
for nmPointer = 51 : ( size( userSpectrum ) - 256 )
    valueOne = abs( userPercent( nmPointer ) - spectralPercent( 1, nmPointer ) );
    for percentPointer = 2 : size( spectralPercent, 1 )
        valueTwo = abs( userPercent( nmPointer ) - spectralPercent( percentPointer , nmPointer) );
        if (valueTwo < valueOne)
            valueOne = valueTwo;          
        end
    end
    valueDifferences( nmPointer ) = valueOne;
end
maxDifference = max( valueDifferences );
userPercent = (( 1 - maxDifference) * dimFactor ) .* userPercent ;

% userSpectrum adaption
%searches the smallest differences between the user value and the real
%spectral values from the 0L490 and considers the Input/Output-function
%from the OL490

spectralRadianceData = zeros( size( userPercent ), 1 ); % we save the radiance values for the OL490 dim value
for nmPointer = 1 : size( userPercent )
    valueOne = abs( spectralPercent( 1, nmPointer ) - userPercent( nmPointer ) );
    valuePointerOne = 1;
    for percentPointer = 2 : size( spectralPercent, 1 )
        valueTwo = abs( spectralPercent( percentPointer , nmPointer) - userPercent( nmPointer ) );
        if (valueTwo < valueOne)
            valueOne = valueTwo;
            valuePointerOne = percentPointer;
        end
    end
    helper = ( valuePointerOne - 1) / 1000;
    valueOne = abs( helper - ioReal(1,nmPointer));
    valuePointerTwo = 1;
    for percentPointer = 2 : size(ioReal,1)
        valueTwo = abs(helper - ioReal( percentPointer, nmPointer));
        if (valueTwo < valueOne)
            valueOne = valueTwo;
            valuePointerTwo = percentPointer;
        end
    end
    helper = ( ( valuePointerTwo - 1) / 1000) * OL490MAX;
    spectralRadianceData( nmPointer ) = spectralPercent( valuePointerOne, nmPointer ) * maxValues( valuePointerOne );
    realValues( nmPointer ) = str2double( sprintf( '%0.0f', helper) );
end
%ol490Spectrum = realValues';

%calc luminance for current spectrum
Lv = calcPhotopicLuminanceFromSpectrum( spectralRadianceData' );
disp( sprintf( 'luminance of spectrum %3.3f cd/m^2', Lv ) );

ol490Spectrum = OL490Spectrum( realValues', dimFactor, Lv );



