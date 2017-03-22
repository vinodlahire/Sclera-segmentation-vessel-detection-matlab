clc;close all;clear all;warning off;

%%
%User image feature Extraction
[filename,Filepath]=uigetfile('.jpg','select Database image');

filename=strcat(Filepath,filename);
[Database_image,left_crop,right_crop,Ivessel_enhanced_left,Ivessel_enhanced_right,...
    Refined_imag_left,Refined_imag_right]=vessel_detection(filename);


%%

%plot Test result
Database_image=imresize(Database_image,[250 350]);
left_crop=imresize(left_crop,[250 350]);
right_crop=imresize(right_crop,[250 350]);
%Display result
figure(1),drawnow
subplot(1,3,1)
imshow(Database_image),title('Database')
subplot(1,3,2)
imshow(left_crop),title('left crop')
subplot(1,3,3)
imshow(right_crop),title('right crop')

figure(2),imshowpair(Refined_imag_left,Refined_imag_right,'montage'),title('Eye veins Extracted for database image')

