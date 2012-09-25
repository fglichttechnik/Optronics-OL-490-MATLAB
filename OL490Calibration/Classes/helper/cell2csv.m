function cell2csv(filename,cellArray,subfolder,delimiter)
% Writes cell array content into a *.csv file.
% 
% CELL2CSV(filename,cellArray,delimiter)
%
% filename  = Name of the file to save. [ i.e. 'text.csv' ]
% cellarray = Name of the Cell Array where the data is in
% subfolder = Name of the subfolder in the programmfolder [ i.e. 'data']
% delimiter = seperating sign, normally:',' (it's default)
%
% by Sylvain Fiedler, KA, 2004
% modified by Rob Kohr, Rutgers, 2005 - changed to english and fixed delimiter
% modified by Marian Leifert, 2012 - subfolder can be used

if nargin<3
    if nargin<4 
    delimiter = ',';
    end
else
    cd ([subfolder '\']);
end
datei = fopen(filename,'w');
for z=1:size(cellArray,1)
    for s=1:size(cellArray,2)
        
        var = eval('cellArray{z,s}');
        
        if size(var,1) == 0
            var = '';
        end
        
        if isnumeric(var) == 1
            var = num2str(var);
        end
        
        fprintf(datei,var);
        
        if s ~= size(cellArray,2)
            fprintf(datei,delimiter);
        end
    end
    fprintf(datei,'\n');
end
fclose(datei);
if nargin>2
    cd ..
end