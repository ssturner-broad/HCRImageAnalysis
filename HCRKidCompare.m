
clear all;
clc;

%path should contain image files for all conditions for a single gene of
%interest.
addpath('/Users/ssturner/Documents/Kidney:Jamie/190521_KidneyCompareImagesFinal/col4a2');

a=dir('Gene/*.tif');

filenum = numel(a);
b = struct2cell(a);
s = size(b);


IntensityArray = cell([filenum 4]);

%Index HCR Images in channel for selected genes...
cd('Gene');

dapicount = 1;
regcount = 1;

for i = 1:s(1,2)
    str = string(b(1,i));
    k = contains(str,'dapi');
    if k == 1
        IntensityArray{dapicount,3} = str;
        DapiImage = imread(char(str));
        imgrayDAPI = rgb2gray(DapiImage);
        [outputImage, number_of_nuclei] = nuclei_countOptFinCheck(imgrayDAPI, 0);%should point to the appropriate estimation
        %script for the field of view collected for your gene of interest
        f = struct2cell(number_of_nuclei)
        nucVal = string(f(3));
        IntensityArray{dapicount,4} = nucVal;
        dapicount = dapicount + 1;
    else
        image1 = imread(char(b(1,i)));
        IntensityArray{regcount,1} = char((b(1,i)));
        imgray = rgb2gray(image1);
        mask = imgray>0.1;
        ImgSubtr = bsxfun(@times, imgray, cast(mask,class(imgray)));
        imshow(ImgSubtr);
        aveframe=mean(mean(ImgSubtr));
        IntensityArray{regcount,2} = aveframe;
        regcount = regcount+1;
    end

end

