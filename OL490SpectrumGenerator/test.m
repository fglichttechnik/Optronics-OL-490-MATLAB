
%load 'C:\Dokumente und Einstellungen\Buschmann\Desktop\spektren\kaarst_47_direkt.mat'
load 'C:\Dokumente und Einstellungen\Buschmann\Desktop\spektren\neuss_HPS_direkt.mat'
s=cs2000Spectrum_2_OL490Spectrum(m);
ol490Spec = OL490SpectrumGenerator( s, 1.0, 'C:\Dokumente und Einstellungen\Buschmann\Desktop\Development\calibrationData.mat' )
ol490Spec.createAdjustedSpectrum();


ol490Controller = OL490Controller( 0, 3 );
ol490Controller.init();
ol490Controller.openShutter();
ol490Controller.sendSpectrum( ol490Spec.ol490AdjustedSpectrum );


ec = ExperimentController();
ec.calib_background();
