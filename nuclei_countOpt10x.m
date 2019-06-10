function [outputImage, number_of_nuclei] = nuclei_counter(sourceImage, threshold)


image = sourceImage;
figure;imshow(image);
title('input image');

total = numel(image);


% applying top hat and bottom hat filter to image
se = strel('disk',30);
tophat = imtophat(image,se);
bottomhat = imbothat(image,se);
filterImage = image + (tophat - bottomhat);
se = strel('disk',15);
tophat = imtophat(filterImage,se);
bottomhat = imbothat(filterImage,se);
filterImage = filterImage + (tophat - bottomhat);


%subtract background to threshold
[counts,x] = imhist(filterImage);
ssum = cumsum(counts);
bg = .225*total;
fg = .99*total;
low = find(ssum>bg, 1, 'first');
high = find(ssum>fg, 1, 'first');
adjustedImage = imadjust(filterImage, [low/255 high/255],[0 1],1.8);  
% image binarization, threshold selected empirically
    matrix = reshape(adjustedImage,total,1);
    matrix = sort(matrix);
    threshold = graythresh(matrix(total*.5:end));
end
binarization = im2bw(adjustedImage,threshold);


%Remove connected components with pixels less than the indicated input
%value in bwareaopen
binarizeSize = bwareaopen(binarization,10);

figure; imshowpair(binarizeSize,binarization,'falsecolor');
title('Subtracting sub 10 pixel-sized connected components');


% figure;
% binarizeClearEdges = imclearborder(binarizeSize);
% imshow(binarizeClearEdges);


% open image and then detect edge using laplacian of gaussian
se2 = strel('disk',3);
afterOpening = imopen(binarizeSize,se2);

D = -bwdist(~afterOpening);
D(~afterOpening) = -Inf; 
L = watershed(D);
L(~afterOpening) = 0;

%pixel cutoff to eliminate components that have been created by segmenting
%lines generated by watershed
H = L>1;
fincomponents = bwareaopen(H,20);

nsize =5; sigma = 3; 
h = fspecial('log',nsize,sigma);
afterLoG = uint8(imfilter(double(fincomponents)*255,h,'same').*(sigma^2)); 


BWSizeSelect = bwareafilt(fincomponents,[1,50000]);

number_of_nuclei = bwconncomp(BWSizeSelect);



labeled = labelmatrix(number_of_nuclei);

labeledImage = label2rgb(labeled);
figure;
imshow(labeledImage)


outputImage = sourceImage + afterLoG*5;
figure;imshow(outputImage);
title('output image');

    