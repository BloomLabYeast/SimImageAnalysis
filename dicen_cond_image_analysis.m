function im_props = dicen_cond_image_analysis(directory)

%This function will parse a directory of MicroscopeSimulator 2 generated
%images, pick the in-focus plane of each stack, and measure the major and
%minor axis of a thresholded image.

%% Parse the directory
% get a list of tif files in directory
tif_files = dir(fullfile(directory,'*.tif'));
tif_files = natsortfiles({tif_files.name});
for n = 1:length(tif_files)
    %Parse the 3D stack to a 3D matrix of uint16
    im_cell = bfopen(fullfile(directory,tif_files{n}));
    im = bf2mat(im_cell);
    im_dbl = im2double(im);
    %find the third dimension with the brightest pixel
    [~,max_idx] = max(im_dbl(:));
    [inf_y,inf_x,inf_plane] = ind2sub(size(im_dbl),max_idx);
    im_inf = im_dbl(:,:,inf_plane);
    % Uncomment for visual conformation
%     imshow(im_inf,[]);
%     title('Press Any Button to Continue');
%     waitforbuttonpress;
    %Determine the plasmid signal by using Otsu threshold proximal to the
    %brightest pixel
    if n == 1
        thresh = multithresh(im_inf(inf_y-20:inf_y+20,inf_x-20:inf_x+20));
    end
    im_bin = im_inf > thresh;
    % Uncomment for visual conformation
%     imshow(im_bin,[]);
%     title('Press Any Button to Continue');
%     waitforbuttonpress;
    %use regionprops to determine the major/minor axis, centroid and
    %orientation
    im_props(n)= regionprops(im_bin,'MinorAxisLength','MajorAxisLength',...
        'Centroid','Orientation');
    AspectRatio{n} = ...
        im_props(n).MajorAxisLength/im_props(n).MinorAxisLength;
end
[im_props.AspectRatio] = AspectRatio{:};
end