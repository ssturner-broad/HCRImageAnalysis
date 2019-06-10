function [outputImage, number_of_nuclei] = nuclei_countOpt40x(sourceImage, threshold)


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
bg = .215*total;
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
binarizeSize = bwareaopen(binarization1,800);

figure;
imshow(binarizeSize);

% figure;
% binarizeClearEdges = imclearborder(binarizeSize);
% imshow(binarizeClearEdges);

% open image and then detect edge using laplacian of gaussian
se2 = strel('disk',5);
afterOpening = imopen(binarizeSize,se2);
nsize = 5; sigma = 3;
h = fspecial('log',nsize,sigma);
afterLoG = uint8(imfilter(double(afterOpening)*255,h,'same').*(sigma^2)); 


se2 = strel('disk',10);  % modified empirically to structing element of size 10
afterOpening = imopen(binarizeSize,se2);

%Perform final segmentation and obtain count...
D = -bwdist(~afterOpening);
D(~afterOpening) = -Inf;
F = imhmin(D,0.5);
L = watershed(F);
H = L>1;
BWSizeSelect = bwareafilt(H,[10,50000]);

number_of_nuclei = bwconncomp(BWSizeSelect);



labeled = labelmatrix(number_of_nuclei);

labeledImage = label2rgb(labeled);
figure;
imshow(labeledImage)


outputImage = sourceImage + afterLoG*5;
figure;imshow(outputImage);
title('output image');

    
