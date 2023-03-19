% Read the host image
host_img = imread('LenaRGB.jpg');

% Convert the watermark text to binary
watermark_text = 'raghad dala sajeda'; % replace with your own watermark text
watermark_bin = reshape(dec2bin(watermark_text, 8).'-'0',1,[]);

% Generate random key and convert to binary
key = randi([0 1], 1, numel(host_img)/64); % 1 bit per block
key_bin = dec2bin(key, 3).'-'0';

% Divide host image into 8x8 blocks
blocks = mat2cell(host_img, 8*ones(1,size(host_img,1)/8), 8*ones(1,size(host_img,2)/8), size(host_img,3));

% Embed key bits into each block
for i = 1:numel(blocks)
    if i <= length(key_bin)
        blocks{i}(1,1,:) = bitset(blocks{i}(1,1,:), 1, key_bin(i,1));
        blocks{i}(1,1,:) = bitset(blocks{i}(1,1,:), 2, key_bin(i,2));
        blocks{i}(1,1,:) = bitset(blocks{i}(1,1,:), 3, key_bin(i,3));
    end
end

% Embed watermark using DCT
watermarked_blocks = cell(size(blocks));
for i = 1:numel(blocks)
    block = blocks{i};
    block_dct = dct2(block(:,:,1));
    DC = block_dct(1,1);
    if i <= numel(watermark_bin)/64
        watermark_bits = watermark_bin((i-1)*64+1:i*64);
        for j = 1:numel(watermark_bits)
            bit = watermark_bits(j);
            [m, n] = ind2sub(size(block_dct), j+1);
            if bit == 0
                if block_dct(m,n) > DC
                    block_dct(m,n) = block_dct(m,n) - 1;
                end
            else % bit == 1
                if block_dct(m,n) < DC
                    block_dct(m,n) = block_dct(m,n) + 1;
                end
            end
        end
    end
    block_watermarked = idct2(block_dct);
    block_watermarked = uint8(block_watermarked);
    block_watermarked(:,:,2) = block(:,:,2);
    block_watermarked(:,:,3) = block(:,:,3);
    watermarked_blocks{i} = block_watermarked;
end

% Convert watermarked blocks to image
watermarked_img = cell2mat(watermarked_blocks);
imshow(watermarked_img);