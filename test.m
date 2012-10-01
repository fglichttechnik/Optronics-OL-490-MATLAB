
%load 'C:\Dokumente und Einstellungen\jaw\Desktop\spektren\kaarst_47_direkt.mat'
load 'C:\Dokumente und Einstellungen\jaw\Desktop\spektren\neuss_HPS_direkt.mat'
%load HPS_350_09_26.mat
%m = measurements{1};
s=cs2000Spectrum_2_OL490Spectrum(m);
ol490Spec = OL490SpectrumGenerator( s, 0.20, 'C:\Dokumente und Einstellungen\jaw\Desktop\Development\calibrationData.mat', 'background' )
ol490Spec.generateSpectrum( );

 

%prepare spectra
[ inputOutputMatrix,...
            interpolatedSpectralDataMatrix,...
            interpolatedMaxValuesForDimLevelSpectra ] = OL490Calibration.loadCalibrationData( 'C:\Dokumente und Einstellungen\jaw\Desktop\Development\calibrationData.mat' );
           
numberOfLevels = 50;
tao = 15;
steps = 0 : numberOfLevels;
dimValues = exp( -steps / tao );
dimValues = dimValues ./ max( dimValues );
dimValues = 1 - dimValues;
maxFactor = 0.07;
spectra = cell( numberOfLevels, 1 );
for i = 1 : numberOfLevels
    currentDimValue = dimValues( i );
    ol490Spec = OL490SpectrumGenerator( s, currentDimValue * maxFactor, 'C:\Dokumente und Einstellungen\jaw\Desktop\Development\calibrationData.mat' )
    ol490Spec.generateSpectrum(  );%inputOutputMatrix, interpolatedSpectralDataMatrix, interpolatedMaxValuesForDimLevelSpectra
    spectra{i} = ol490Spec;
end

ol490Controller = OL490Controller( 0, 3 );
ol490Controller.init();
ol490Controller.openShutter();
ol490Controller.sendSpectrum( ol490Spec.ol490Spectrum.spectrum );

ol490Controller.closeShutter();
pause(8);
timeForStimuliInS = 10;
ol490Controller.sendSpectrum( spectra{1}.ol490Spectrum.spectrum );
ol490Controller.openShutter();
start = tic();
for i = 1 : numberOfLevels
    timePerStimulus = timeForStimuliInS / numberOfLevels;
    tic();
    ol490Controller.sendSpectrum( spectra{i}.ol490Spectrum.spectrum );
    timePassed = toc();
    if( timePassed < timePerStimulus )
        timeToWait = timePerStimulus - timePassed;
        disp( sprintf( 'waiting %f: s', timeToWait ) );
        pause( timeToWait );
    else
        disp( sprintf( 'too much time passed: %f s', timePassed ) );
    end    
end
disp( sprintf( 'total time elapsed: %f s', toc( start ) ) );

ec = ExperimentController();
ec.calib_background();



ec = ExperimentController();
ec.init();
ec.sendFullOutputToBackgroundOL490();

ec.documentTargetOl490SpectralVariance( m );

im1 = zeros( 684, 608, 3 );
im1 (300:380, 300:380, :) = 255;
imwrite( im1, 'im1.bmp' );
imFile1 = fopen( 'im1.bmp' );
imData1 = fread( imFile1, inf, 'uchar' );
fclose( imFile1 );
%ec.initLightCrafter();
ec.sendImage( imData1 );
ec.sendPositionCalibrationImage();
ec.cleanup();
