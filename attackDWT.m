clc
close all

% Load the host image and display it
rgbimage=imread('host.jpg');

% Perform DWT on the host image and extract the low-low frequency coefficient
[h_LL,h_LH,h_HL,h_HH]=dwt2(rgbimage,'haar');
img=h_LL;

% Extract the red, green, and blue channels of the low-low frequency coefficient
red1=img(:,:,1);
green1=img(:,:,2);
blue1=img(:,:,3);

% Perform SVD on each channel
[U_imgr1,S_imgr1,V_imgr1]= svd(red1);
[U_imgg1,S_imgg1,V_imgg1]= svd(green1);
[U_imgb1,S_imgb1,V_imgb1]= svd(blue1);

% Load the watermark image and display it
rgbimage=imread('watermark.jpg');



% Perform DWT on the watermark image and extract the low-low frequency coefficient
[w_LL,w_LH,w_HL,w_HH]=dwt2(rgbimage,'haar');
img_wat=w_LL;

% Extract the red, green, and blue channels of the low-low frequency coefficient
red2=img_wat(:,:,1);
green2=img_wat(:,:,2);
blue2=img_wat(:,:,3);

% Perform SVD on each channel
[U_imgr2,S_imgr2,V_imgr2]= svd(red2);
[U_imgg2,S_imgg2,V_imgg2]= svd(green2);
[U_imgb2,S_imgb2,V_imgb2]= svd(blue2);

% Load the watermarked image and display it
key = 10
rgbimage=imread('watermarked.jpg');


% Perform DWT on the watermarked image and extract the low-low frequency coefficient
[wm_LL,wm_LH,wm_HL,wm_HH]=dwt2(rgbimage,'haar');
img_w=wm_LL;

% Extract the red, green, and blue channels of the low-low frequency coefficient
red3=img_w(:,:,1);
green3=img_w(:,:,2);
blue3=img_w(:,:,3);

% Perform SVD on each channel
[U_imgr3,S_imgr3,V_imgr3]= svd(red3);
[U_imgg3,S_imgg3,V_imgg3]= svd(green3);
[U_imgb3,S_imgb3,V_imgb3]= svd(blue3);

% Extract the watermark from the host image
S_ewatr=(S_imgr3-S_imgr1)/(key*0.06);
S_ewatg=(S_imgg3-S_imgg1)/(key*0.06);
S_ewatb=(S_imgb3-S_imgb1)/(key*0.1);

ewatr = U_imgr2*S_ewatr*V_imgr2';
ewatg = U_imgg2*S_ewatg*V_imgg2';
ewatb = U_imgb2*S_ewatb*V_imgb2';

% Combine the extracted watermark channels into a single image
ewat=cat(3,ewatr,ewatg,ewatb);

% Set the low-low frequency coefficients of the watermarked image to the extracted watermark
newwatermark_LL=ewat;

% Reconstruct the watermarked image by performing inverse DWT on the watermarked low-low frequency coefficients along with the high frequency coefficients
rgb2=idwt2(newwatermark_LL,w_LH,w_HL,w_HH,'haar');

%display the Extracted image
imwrite(uint8(rgb2),'EWatermark.jpg');

%-----------------------------------------------------------------
watermarked=imread('watermarked.jpg');
% Add Gaussian noise to the watermarked image
noisy_img = imnoise(watermarked, 'gaussian', 0, 0.01);
figure;
% Display the original, watermarked, and noisy watermarked images side by side
subplot(1, 3, 1);
imshow(original);
title('Original Image');

subplot(1, 3, 2);
imshow(watermarked);
title('Watermarked Image');

subplot(1, 3, 3);
imshow(noisy_img);
title('Noisy Watermarked Image');
%---------------------------------------------------------------------------


% Perform DWT on the host image and extract the low-low frequency coefficient
[h_LL,h_LH,h_HL,h_HH]=dwt2(noisy_img,'haar');
img=h_LL;

% Extract the red, green, and blue channels of the low-low frequency coefficient
red1=img(:,:,1);
green1=img(:,:,2);
blue1=img(:,:,3);

% Perform SVD on each channel
[U_imgr1,S_imgr1,V_imgr1]= svd(red1);
[U_imgg1,S_imgg1,V_imgg1]= svd(green1);
[U_imgb1,S_imgb1,V_imgb1]= svd(blue1);

% Load the watermark image and display it
rgbimage=imread('watermark.jpg');
figure;
imshow(rgbimage);
title('Watermark image');

% Perform DWT on the watermark image and extract the low-low frequency coefficient
[w_LL,w_LH,w_HL,w_HH]=dwt2(rgbimage,'haar');
img_wat=w_LL;

% Extract the red, green, and blue channels of the low-low frequency coefficient
red2=img_wat(:,:,1);
green2=img_wat(:,:,2);
blue2=img_wat(:,:,3);

% Perform SVD on each channel
[U_imgr2,S_imgr2,V_imgr2]= svd(red2);
[U_imgg2,S_imgg2,V_imgg2]= svd(green2);
[U_imgb2,S_imgb2,V_imgb2]= svd(blue2);

% Load the watermarked image and display it
key = 10
rgbimage=imread('watermarked.jpg');
figure;
imshow(rgbimage);
title('Watermarked image');

% Perform DWT on the watermarked image and extract the low-low frequency coefficient
[wm_LL,wm_LH,wm_HL,wm_HH]=dwt2(rgbimage,'haar');
img_w=wm_LL;

% Extract the red, green, and blue channels of the low-low frequency coefficient
red3=img_w(:,:,1);
green3=img_w(:,:,2);
blue3=img_w(:,:,3);

% Perform SVD on each channel
[U_imgr3,S_imgr3,V_imgr3]= svd(red3);
[U_imgg3,S_imgg3,V_imgg3]= svd(green3);
[U_imgb3,S_imgb3,V_imgb3]= svd(blue3);

% Extract the watermark from the host image
S_ewatr=(S_imgr3-S_imgr1)/(key*0.06);
S_ewatg=(S_imgg3-S_imgg1)/(key*0.06);
S_ewatb=(S_imgb3-S_imgb1)/(key*0.1);

ewatr = U_imgr2*S_ewatr*V_imgr2';
ewatg = U_imgg2*S_ewatg*V_imgg2';
ewatb = U_imgb2*S_ewatb*V_imgb2';

% Combine the extracted watermark channels into a single image
ewat=cat(3,ewatr,ewatg,ewatb);

% Set the low-low frequency coefficients of the watermarked image to the extracted watermark
newwatermark_LL=ewat;

% Reconstruct the watermarked image by performing inverse DWT on the watermarked low-low frequency coefficients along with the high frequency coefficients
rgb2=idwt2(newwatermark_LL,w_LH,w_HL,w_HH,'haar');

%display the Extracted image
figure;
imshow(uint8(rgb2));
imwrite(uint8(rgb2),'EWatermark.jpg');
title('Extracted Watermark');