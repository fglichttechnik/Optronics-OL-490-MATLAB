
t = TriggerController();
t.init();
l = addlistener( t, 'triggerHitNotification', @triggerHitNotificationCallback);
t.startWaitingForTrigger();
delete( l );
t.cleanUp();

%load 'C:\Dokumente und Einstellungen\jaw\Desktop\spektren\kaarst_47_direkt.mat'
load 'C:\Dokumente und Einstellungen\jaw\Desktop\spektren\neuss_HPS_direkt.mat'
%load HPS_350_09_26.mat
%m = measurements{1};

ol490Spec = OL490SpectrumGenerator( m, 0.3, 'C:\Dokumente und Einstellungen\jaw\Desktop\Development\calibrationData_background.mat' );
ol490Spec.generateSpectrum( );

load 'C:\Dokumente und Einstellungen\jaw\Desktop\spektren\neuss_HPS_direkt.mat'
ec = ExperimentController();
ec.init();
ec.sendRectImage();
ec.sendFullOutputToTargetOL490();

ec.backgroundCalibrationFileName = 'C:\Dokumente und Einstellungen\jaw\Desktop\Development\calibrationData_background.mat';
ec.targetCalibrationFileName = 'C:\Dokumente und Einstellungen\jaw\Desktop\Development\calibrationData_target.mat';
ec.setupCurrentExperimentSettings( 0.3, m );
ec.startExperiment();


ec.sendBackgroundSpectrum( ol490Spec );
ol490Spec.documentSpectralVariance();

ec.documentTargetOl490SpectralVariance(  );

ec.sendFullOutputToTargetOL490();

% ol490Controller = OL490Controller( 0, 3 );
% ol490Controller.init();
% ol490Controller.openShutter();
% ol490Controller.sendSpectrum( ol490Spec.ol490Spectrum.spectrum );



ec = ExperimentController();
ec.calib_background();



ec = ExperimentController();
ec.init();
ec.sendFullOutputToBackgroundOL490();

%ec.documentTargetOl490SpectralVariance( olSpec );

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


plot(interpolatedSpectralDataMatrix(:,500) / max(interpolatedSpectralDataMatrix(:,500)))
hold on;
plot(interpolatedSpectralDataMatrix(:,300) / max(interpolatedSpectralDataMatrix(:,300)))
plot(interpolatedSpectralDataMatrix(:,800 / max(interpolatedSpectralDataMatrix(:,800))))
hold off

plot(inputOutputMatrix(:,500) / max(inputOutputMatrix(:,500)))
hold on;
plot(inputOutputMatrix(:,300) / max(inputOutputMatrix(:,300)))
plot(inputOutputMatrix(:,800 / max(inputOutputMatrix(:,800))))
hold off


