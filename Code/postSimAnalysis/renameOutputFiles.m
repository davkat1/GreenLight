%RENAMEOUTPUTFILES rename the output files from the old format (May 2020)
%to the new format (Oct 2020)

files = dir(cd);
files = files(3:end);

label = 'warmer';

for k=1:length(files)
    oldName = files(k).name;
    newName = strrep(oldName, ['energyPlus_' label '_'], '');
    if strcmp(oldName(end-7:end-4), 'days')
        newName(end-22:end-4) = 'xxxxxxxxxxxxxxxxxxx';
        newName = strrep(newName, 'xxxxxxxxxxxxxxxxxxx', label);
        movefile(oldName,newName);
    end
end
