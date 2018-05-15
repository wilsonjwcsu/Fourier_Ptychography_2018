function[image] = takephoto(vid,i,j,xmax)
%prev = preview(vid);
%mbox_preview = msgbox('Preview looks good, click to take photo');
%uiwait(mbox_preview);
image = step(vid);
if xmax>=7
    if i == 1 || j == 1;
        pause(1) % pause shorter for outer rim
    elseif i == xmax || j == xmax;
        pause(1) % pause shorter for outer rim
    else
        pause(5);
    end
else
    pause(5);
end
exposure = vid.DeviceProperties.ExposureTimeAbs;
% normalize image by exposure, so that all images are equally scaled.
exp_scaled_image = image./exposure;
%mbox_image = msgbox('Camera took a photo,scaled it, and stored it');
%uiwait(mbox_image);
image = exp_scaled_image;
end