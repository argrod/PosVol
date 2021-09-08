fileloc1 = "/Volumes/GoogleDrive/My Drive/PhD/Data/AokiVolume/170615acousonde/acousonde/";
fileloc2 = "/Volumes/GoogleDrive/My Drive/PhD/Data/AokiVolume/170615acousonde/acousondeX/";
outloc = "/Volumes/GoogleDrive/My Drive/PhD/Data/AokiVolume/ConvertedMT/";

fileloc = "/Volumes/GoogleDrive/My Drive/PhD/Data/AokiVolume/170615acousonde/";
files=dir(fullfile(fileloc,"**/*.MT"));
files = fullfile({files.folder}, {files.name} );

files = files(~contains(files,"._"));

for b = 1:length(files)
    file = convertCharsToStrings(cell2mat(files(b)));
    newStr = split(file,'/');
    newStr = split(newStr(end),".");
    newStr = newStr(1);
    dat = MTRead(cell2mat(files(b)));
    audiowrite(strcat(outloc,newStr,".wav"),dat,254848)
end


convMT2Wav(fileloc1,outloc,254848)
convMT2Wav(fileloc2,outloc,254848)