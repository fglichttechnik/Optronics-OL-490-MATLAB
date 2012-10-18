% AUTHOR:	Marian Leifert, Jan Winter, Sandy Buschmann, TU Berlin, FG Lichttechnik,
% 			j.winter@tu-berlin.de, www.li.tu-berlin.de
% LICENSE: 	free to use at your own risk. Kudos appreciated.



function [ ol490TargetSpectrum ] = generateOL490Spectrum( targetSpectrum, interpolatedSpectralDataCalibrationMatrix, inputOutputCalibrationMatrix, maxValueOfAllSpectra, dimFactor )
%function [ ol490TargetSpectrum ] = generateOL490Spectrum( targetSpectrum, interpolatedSpectralDataCalibrationMatrix, inputOutputCalibrationMatrix, maxValueOfAllSpectra, dimFactor )
% generateOL490Spectrum
%   targetSpectrum - requested spectrum, vector with 1024 columns
%   interpolatedSpectralDataCalibrationMatrix - matrix generated with OL490-class
%   inputOutputCalibrationMatrix       - matrix generated with OL490-class
%   dimFactor     - number between 0 and 1 [p.e. 0.543], default is 1
%   ol490Spectrum    - adapted vector with ol490-values, from 0 till 49152
%   interpolatedMaxValuesForDimLevelSpectra     - values to recalculate real value of percentual value (needed for Lv)

OL490MAX = 49152;

%userSpectrum preparation
%list with smallest value differences between
%interpolatedSpectralDataCalibrationMatrix and targetSpectrum
%between 400nm - 680 nm values are necessary for adaption, the other values
%will influence the final adaption negatively too much (51 equals 20nm and 256 equals 100nm)
targetSpectrumRelative = targetSpectrum ./ OL490MAX;
numberOfSpectralLines = size( targetSpectrum, 1 );
numberOfDimLevels = size( interpolatedSpectralDataCalibrationMatrix, 1 );
indexFromSpectralLine = 51;%51;     % 400nm
indexToSpectralLine = ( numberOfSpectralLines - 256);%256 );      %  680nm
numberOfInterestingSpectralLines = length( indexFromSpectralLine : indexToSpectralLine );
smallestDifferencesBetweenTargetAndCalibrationSpectrum = zeros( numberOfInterestingSpectralLines, 1 );

%buffer = zeros( size( interpolatedSpectralDataCalibrationMatrix ) );
%find minimum between targetSpectrum and dimLevelCalibration
for spectralLineIndex = indexFromSpectralLine : indexToSpectralLine
    currentDimLevels = interpolatedSpectralDataCalibrationMatrix( :, spectralLineIndex );
    currentTargetSpectralLine = targetSpectrumRelative( spectralLineIndex );
    diffTargetSpectralLine2CalibrationDimValue = abs( currentDimLevels - currentTargetSpectralLine );
    smallestDifference = min( diffTargetSpectralLine2CalibrationDimValue );
    smallestDifferencesBetweenTargetAndCalibrationSpectrum( spectralLineIndex - indexFromSpectralLine + 1 ) = smallestDifference;
    %buffer( :, spectralLineIndex ) = diffTargetSpectralLine2CalibrationDimValue;
end

 %smallestDifferencesBetweenTargetAndCalibrationSpectrum = min( buffer );
%smallestDifferencesBetweenTargetAndCalibrationSpectrum( spectralLineIndex - indexFromSpectralLine + 1 ) = smallestDifference;
    
%smallestDifference = min( abs( interpolatedSpectralDataCalibrationMatrix( indexFromSpectralLine : indexToSpectralLine, : ) - targetSpectrumRelative ) );
%smallestDifferencesBetweenTargetAndCalibrationSpectrum( indexFromSpectralLine : end - indexToSpectralLine ) = smallestDifference;

maxDifference = max( smallestDifferencesBetweenTargetAndCalibrationSpectrum );
correctionFactor = ( 1 - maxDifference);
disp( sprintf( 'maximum level factor for spectrum: %3.3f', correctionFactor ) );
targetSpectrumRelative = ( correctionFactor * dimFactor ) .* targetSpectrumRelative ;

% targetSpectrum adaption
%searches the smallest differences between the user value and the real
%spectral values from the 0L490 and consider the Input/Output-function
%from the OL490

spectralRadianceData = zeros( size( targetSpectrumRelative, 1 ), 1 ); % we save the radiance values for the OL490 dim value
ol490DimValueSpectrumCorrected = zeros( size( targetSpectrumRelative, 1 ), 1 );
for spectralLineIndex = 1 : numberOfSpectralLines
    
    %find best dimValue for current spectral line
    currentDimLevels = interpolatedSpectralDataCalibrationMatrix( :, spectralLineIndex );
    currentTargetSpectralLine = targetSpectrumRelative( spectralLineIndex );
    diffTargetSpectralLine2CalibrationDimValue = abs( currentDimLevels - currentTargetSpectralLine );
    [smallestDifference, indexOfSmallestSpectralDataDifference] = min( diffTargetSpectralLine2CalibrationDimValue );
    
    % get percentual dimValue for this spectralLine
    ol490DimValueForSpectralLine = ( indexOfSmallestSpectralDataDifference - 1 ) / 1000;
    
    currentInputOutputCalibrationDimValues = inputOutputCalibrationMatrix( :, spectralLineIndex );
    diffTargetSpectralLine2InputOutputCalibrationDimValue = abs( ol490DimValueForSpectralLine - currentInputOutputCalibrationDimValues );
    [smallestDifference, indexOfSmallestInputOutputDifference] = min( diffTargetSpectralLine2InputOutputCalibrationDimValue );
    %end
    
    ol490DimValueForSpectralLineCorrected = ( indexOfSmallestInputOutputDifference - 1 ) / 1000 * OL490MAX;
    ol490DimValueSpectrumCorrected( spectralLineIndex ) = round( ol490DimValueForSpectralLineCorrected );
    
    %get spectral radiance of dimValue
    radianceOfCurrentSpectralLineRelative = interpolatedSpectralDataCalibrationMatrix( indexOfSmallestInputOutputDifference, spectralLineIndex );
    radianceOfCurrentSpectralLine = radianceOfCurrentSpectralLineRelative * maxValueOfAllSpectra;
    spectralRadianceData( spectralLineIndex ) = radianceOfCurrentSpectralLine;
end
disp('');

%calc luminance for current spectrum
Lv = calcPhotopicLuminanceFromSpectrum( spectralRadianceData' );
disp( sprintf( 'luminance of spectrum %3.3f cd/m^2', Lv ) );

ol490TargetSpectrum = OL490TargetSpectrum( ol490DimValueSpectrumCorrected', dimFactor, Lv );



end