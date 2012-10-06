AUTHOR: Jan Winter, TU Berlin, FG Lichttechnik,
		j.winter@tu-berlin.de, www.li.tu-berlin.de
LICENSE: free to use at your own risk. Kudos appreciated.

function Lv_photopic = calcPhotopicLuminanceFromSpectrum( spectralRadianceData )
%function Lv_photopic = calcPhotopicLuminanceFromSpectrum( spectralRadianceData )
% calculates the photopic luminance from spectrum prepared for a OL490
% spectralRadianceData has 1024 values ranging from 380 : 780

load 'V_CIE.mat'  %load V_strich and lambda_CIE
fromLambda = 380;
toLambda = 780;
resolution = 1024;
lambda_i = linspace( fromLambda, toLambda, resolution );
V_i = interp1( lambda_CIE, V, lambda_i );
Lv_photopic = 683 * ( toLambda - fromLambda ) / resolution *  sum( V_i .* spectralRadianceData );
end