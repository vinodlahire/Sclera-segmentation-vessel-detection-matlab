function [img1,left_crop,right_crop,Ivessel_enhanced_left,Ivessel_enhanced_right,Refined_imag_left,Refined_imag_right]=vessel_detection(filename)

img1=imread(filename);
img=imresize(img1,[250 350]);
[row,column,~]=size(img1);
[centers, radii] = imfindcircles(img,[25 1000], 'ObjectPolarity','dark', ...
  'Sensitivity',0.8,'Method','twostage');
x1=round(centers(:,1));
y1=round(x1-radii);
x2=round(centers(:,1));
y2=round(x2+radii);
left_crop=imcrop(img1,[1  1  y1*6.1 column ]);
% figure(1),imshow(left_crop)%,axis on;grid on
right_crop=imcrop(img1,[y2*6 1  column-y2*6  row] );
% figure(2),imshow(right_crop)%,axis on;grid on
left_mask=masking_sclera(left_crop);
right_mask=masking_sclera(right_crop);
[Ivessel_enhanced_left]= vessel_enhancement(left_mask);
[Refined_imag_left]=Extract_edges(Ivessel_enhanced_left);
[Ivessel_enhanced_right]= vessel_enhancement(right_mask);
[Refined_imag_right]=Extract_edges(Ivessel_enhanced_right);

end

function [X1]=masking_sclera(cropped_image) 
X1=cropped_image;[r,c,~]=size(cropped_image);
h = ones(12,12) / 144;
X = imfilter(X1,h);
IDX = otsu(X,3);
IDX(IDX==2)=1;
IDX(IDX==3)=0;
IDX=imresize(IDX,[350 250]);
IDX=bwareaopen(((IDX)), 200);
IDX=imresize(IDX,[r c]);
% Create 3 channel mask
mask_three_chan = logical(repmat(IDX, [1, 1, 3]));
X1((mask_three_chan)) = 0;
end
function[Ivessel_enhanced]= vessel_enhancement(normal_image)
I=rgb2gray(normal_image);
% imshow(X)
Is = imguidedfilter(I);
I=adapthisteq(Is,'clipLimit',0.02,'Distribution','rayleigh');
Ivessel_enhanced=FrangiFilter2D(double(I));
end
function [Refined_imag]=Extract_edges(Ivessel)
[~,colomn,~]=size(Ivessel);
% Ivessel=Ivessel(400:800,200:colomn-200);
Ivessel=Ivessel(400:1000,50:colomn-50);
labeledImage = bwlabel(Ivessel,8);
measurements = regionprops(logical(labeledImage), 'BoundingBox', 'Area');
allAreas = [measurements.Area];
[~, sortingIndexes] = sort(allAreas, 'descend');
Imageindex = sortingIndexes(2:length(measurements));
bw = ismember(labeledImage, Imageindex);
L2 = labelmatrix(bwconncomp(bw));
% s = regionprops(L2, 'Area');
L2(~bw) = 0;
s = regionprops(L2, 'Area');
s_A = [s.Area];
[~, sortingIndexes] = sort(s_A, 'descend');
Major_vessel_area = sortingIndexes(:,1:4);
Refined_imag= ismember(L2, Major_vessel_area );
Refined_imag= bwmorph(Refined_imag,'skel',Inf);
end