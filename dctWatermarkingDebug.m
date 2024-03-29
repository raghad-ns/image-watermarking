clc
clear all
close all 

% Define the key
key = 'hello world !!!!! hello world !!!!!!';

% Convert the key to binary data
binKey = dec2bin(uint8(key), 8);

% Reshape the binary data into a 2D array with 6 columns
binKey = reshape(binKey', [], 3);

% Convert the binary data to numeric data
numKey = bin2dec(binKey);
% disp (numKey);

% Load the image
img = imread('PeppersRGB.jpg');
% Block size
blockSize = 8; 

% pad image to make its size evenly divisible by the block size
padRows = blockSize - mod(size(img,1), blockSize);
padCols = blockSize - mod(size(img,2), blockSize);
img = padarray(img, [padRows padCols], 0, 'post');

% Load the RGB image and separate its color channels

R = img(:,:,1);
G = img(:,:,2);
B = img(:,:,3);

% Convert each color channel into double precision
R_double = im2double(R);
G_double = im2double(G);
B_double = im2double(B);

% Compute the DCT coefficients of each color channel
R_dct = dct2(R_double);
G_dct = dct2(G_double);
B_dct = dct2(B_double);

% Divide the image into blocks
[numRows, numCols] = size(R_dct);
numBlocksRows = floor(numRows / blockSize);
numBlocksCols = floor(numCols / blockSize);

blocks_R = mat2cell(R_dct, blockSize*ones(1,numBlocksRows), blockSize*ones(1,numBlocksCols), 1);
blocks_G = mat2cell(G_dct, blockSize*ones(1,numBlocksRows), blockSize*ones(1,numBlocksCols), 1);
blocks_B = mat2cell(B_dct, blockSize*ones(1,numBlocksRows), blockSize*ones(1,numBlocksCols), 1);

figure;
title('Host Image')
for i = 1:numBlocksRows
    for j = 1:numBlocksCols
        idx = (i-1)*numBlocksCols + j;
        subplot(numBlocksRows, numBlocksCols, idx);
        imshow(blocks_R{i,j});
    end
end

% Load the text to be embedded as a watermark and convert it to a numeric vector of double precision
text = 'Raghad';
text_double = double(text);

% Convert the watermark to binary data
binWatermark = dec2bin(uint8(text), 8);


% Reshape the binary data into array 
binWatermark = reshape(binWatermark', [], 1);


% Compute the DCT coefficients of the text
 text_dct = dct(text_double);

% Normalize the DCT coefficients of the text to the range [-1, 1]
text_norm = 2*text_dct/length(text_dct) - 1;
for i = 1 : numel(numKey)
    numKey(i) = numKey(i) + 1 ;
end


keyIndex = 2;
block_R = blocks_R{1,1};
block_R_int = uint8(block_R); % Cast to integer type
disp(block_R_int);
for k = 1:blockSize
    for l = 1:blockSize
        if keyIndex <= numel(numKey) && numKey(keyIndex) == k && numKey(keyIndex - 1) == l 
            disp(numKey(keyIndex));
            disp(numKey(keyIndex-1));
            pixel_R_new = bitset(block_R_int(k,l), 1, 1); 
            block_R_int(k,l) = pixel_R_new;
            block_R = double(block_R_int);
            blocks_R{1,1} = block_R;
        end
    end
end
           
disp("after embedding : ");
disp(block_R_int);

keyIndex = keyIndex + 2 ;
block_R = blocks_R{1,2};
block_R_int = uint8(block_R); % Cast to integer type
disp(block_R_int);
for k = 1:blockSize
    for l = 1:blockSize
        if keyIndex <= numel(numKey) && numKey(keyIndex) == k && numKey(keyIndex - 1) == l 
            disp(numKey(keyIndex));
            disp(numKey(keyIndex-1));
            pixel_R_new = bitset(block_R_int(k,l), 1, 1); 
            block_R_int(k,l) = pixel_R_new;
            block_R = double(block_R_int);
            blocks_R{1,2} = block_R;
        end
    end
end
           
disp("after embedding : ");
disp(block_R_int);

keyIndex = keyIndex + 2 ;
block_R = blocks_R{1,3};
block_R_int = uint8(block_R); % Cast to integer type
disp(block_R_int);
for k = 1:blockSize
    for l = 1:blockSize
        if keyIndex <= numel(numKey) && numKey(keyIndex) == k && numKey(keyIndex - 1) == l 
            disp(numKey(keyIndex));
            disp(numKey(keyIndex-1));
            pixel_R_new = bitset(block_R_int(k,l), 1, 1); 
            block_R_int(k,l) = pixel_R_new;
            block_R = double(block_R_int);
            blocks_R{1,3} = block_R;
        end
    end
end
           
disp("after embedding : ");
disp(block_R_int);


figure;
title ('Watermarked Image')
for i = 1:numBlocksRows
    for j = 1:numBlocksCols
        idx = (i-1)*numBlocksCols + j;
        subplot(numBlocksRows, numBlocksCols, idx);
        imshow(blocks_R{i,j});
    end
end

% Combine the blocks back into an image
R_dct = cell2mat(blocks_R);
G_dct = cell2mat(blocks_G);
B_dct = cell2mat(blocks_B);

% Compute the inverse DCT of each color channel
R_idct = idct2(R_dct);
G_idct = idct2(G_dct);
B_idct = idct2(B_dct);

% Combine the color channels into an RGB image
img_wm = cat(3, R_idct, G_idct, B_idct);

% Remove the padding
img_wm = img_wm(1:end-padRows, 1:end-padCols, :);
%display the watermarked image 
figure;
imshow(img_wm);
imwrite(img_wm, 'output.jpg', 'jpg');


% function definition for modify_bit
function y = modify_bit(x, b)
    LSB = bitget(uint8(floor(x)), 1);
    if LSB == b
        y = x;
    else
        if b == 0
            y = x - 1;
        else
            y = x + 1;
        end
    end
end
