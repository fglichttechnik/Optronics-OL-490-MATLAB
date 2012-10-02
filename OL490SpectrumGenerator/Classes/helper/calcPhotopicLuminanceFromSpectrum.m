%%calc photopic luminance
function Lv_photopic = calcPhotopicLuminanceFromSpectrum( spectralRadianceData )
load 'V_CIE.mat'  %load V_strich and lambda_CIE
fromLambda = 380;
toLambda = 780;
resolution = 1024;
lambda_i = linspace( fromLambda, toLambda, resolution );
V_i = interp1( lambda_CIE, V, lambda_i );
Lv_photopic = 683 * ( toLambda - fromLambda ) / resolution *  sum( V_i .* spectralRadianceData );
end