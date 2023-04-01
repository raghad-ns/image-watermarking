

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

% Compute the DWT coefficients of each color channel
R_dwt = dwt2(R_double, 'haar');
G_dwt = dwt2(G_double, 'haar');
B_dwt = dwt2(B_double, 'haar');

% Divide the image into blocks
[numRows, numCols] = size(R_dwt);

numBlocksRows = floor(numRows / blockSize);
numBlocksCols = floor(numCols / blockSize);
R_dwt = R_dwt(1:numBlocksRows*blockSize, 1:numBlocksCols*blockSize);
G_dwt = G_dwt(1:numBlocksRows*blockSize, 1:numBlocksCols*blockSize);
B_dwt = B_dwt(1:numBlocksRows*blockSize, 1:numBlocksCols*blockSize);

blocks_R = mat2cell(R_dwt, blockSize*ones(1,numBlocksRows), blockSize*ones(1,numBlocksCols));
blocks_G = mat2cell(G_dwt, blockSize*ones(1,numBlocksRows), blockSize*ones(1,numBlocksCols));
blocks_B = mat2cell(B_dwt, blockSize*ones(1,numBlocksRows), blockSize*ones(1,numBlocksCols));




figure;
title('Host Image')
for i = 1:numBlocksRows
for j = 1:numBlocksCols
idx = (i-1)*numBlocksCols + j;
subplot(numBlocksRows, numBlocksCols, idx);
%imshow(blocks_R{i,j});
end
end

% Load the text to be embedded as a watermark and convert it to a numeric vector of double precision
text = 'Raghad';
text_double = double(text);

% Convert the watermark to binary data
binWatermark = dec2bin(uint8(text), 8);

% Reshape the binary data into array
binWatermark = reshape(binWatermark', [], 1);

% Display the ASCII codes
disp(['The ASCII codes for the characters in the our name are: ' num2str(text_double)]);

% Compute the DWT coefficients of the text
text_dwt = dwt(text_double, 'haar');

% Normalize the DWT coefficients of the text to the range [-1, 1]
text_norm = text_dwt / max(abs(text_dwt));
disp(['The ASCII codes for the characters after DWT: ' num2str(text_norm)]);
for i = 1 : numel(numKey)
numKey(i) = numKey(i) + 1 ;
end

% Traverse through each block and each bit in the block, and embed the
% watermark
keyIndex = 2;
watermarkIndex = 1;

% Main code starts here
for i = 1:numBlocksRows
    for j = 1:numBlocksCols
        block_R = blocks_R{i,j};
        block_G = blocks_G{i,j};
        block_B = blocks_B{i,j};
        
        for k = 1:blockSize
            for l = 1:blockSize
                if keyIndex <= numel(numKey) && numKey(keyIndex) == k && numKey(keyIndex - 1) == l && watermarkIndex <= numel(binWatermark)
                    %disp(block_R(k , l));
                    watermarkBit =uint8(binWatermark(watermarkIndex));
                    % Modify the bit at (k,l) in block_R
                    block_R_int = uint8(block_R); % Cast to integer type
                    block_R_bitset = bitset(reshape(block_R_int, 1, 64), 1, watermarkBit); % Apply bitset
                    block_R_int_modified = typecast(uint8(block_R_bitset), 'uint8'); % Convert back to integer type
                    
                    % Modify the bit at (k,l) in block_G
                    block_G_int = uint8(block_G); % Cast to integer type
                    block_G_bitset = bitset(reshape(block_G_int, 1, 64), 1, watermarkBit); % Apply bitset
                    block_G_int_modified = typecast(uint8(block_G_bitset), 'uint8'); % Convert back to integer type
                    
                    % Modify the bit at (k,l) in block_B
                    block_B_int = uint8(block_B); % Cast to integer type
                    block_B_bitset = bitset(reshape(block_B_int, 1, 64), 1, watermarkBit); % Apply bitset
                    block_B_int_modified = typecast(uint8(block_B_bitset), 'uint8'); % Convert back to integer type

                    %block_R(k,l) = bitset(reshape(uint8(block_R), 1, 64), 1, watermarkBit);

                    % Modify the bit at (k,l) in block_G
                    %block_G(k,l) = bitset(uint8(block_G(k,l)), 1, watermarkBit);
                
                    % Modify the bit at (k,l) in block_B
                    %block_B(k,l) = bitset(uint8(block_B(k,l)), 1, watermarkBit);
                    
                    %update keyIndex & watermarkIndex 
                    keyIndex = keyIndex + 2 ;
                    watermarkIndex = watermarkIndex + 1 ;
                end
            end
        end
        
        % Assign the modified block back to the cell array
        blocks_R{i,j} = block_R;
        blocks_G{i,j} = block_G;
        blocks_B{i,j} = block_B;
    end
end

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
R_dwt = cell2mat(blocks_R);
G_dwt = cell2mat(blocks_G);
B_dwt = cell2mat(blocks_B);


% Compute the inverse DWT of each color channel
R_idwt = idwt2(R_dwt, 'haar');
G_idwt = idwt2(G_dwt, 'haar');
B_idwt = idwt2(B_dwt, 'haar');



% Combine the color channels into an RGB image
img_wm = cat(3, R_idwt, G_idwt, B_idwt);

% Remove the padding
img_wm = img_wm(1:end-padRows, 1:end-padCols, :);
%display the watermarked image 
figure;
imshow(img_wm);
imwrite(img_wm, 'watermarked_dwt.jpg', 'jpg');


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