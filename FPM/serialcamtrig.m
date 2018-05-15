function serialcamtrig(xmax, wavelength, color, colorsetting, filename);
%% setup variables
% folder should be...
% U:\Senior Design\ptychography\LEDControl
% Save the serial port name in comPort variable.
% define variables
% clear all
%% set variables for size of array
tic
xmin = 0;                           %define starting x for array
ymin = 0;                           %define starting y for array
ymax = xmax;                          %define ending y for array
x = xmax - xmin;
y = ymax - ymin;

% optical parameters
% wavelength = 600e-9;    % wavelength in meters (different for R,G,B)
LED_spacing = 4/1000;     % Distance between LEDs in meters
matrix_spacing = 53/1000; % Distance from matrix to sample in meters
x_offset = 0;             % Distance from center of matrix to optic axis
y_offset =0;              % (in meters)
arraysize = xmax;         % Number of LEDs in one side of the square
No_LEDs = arraysize^2;    % Total number of LEDs (should probably be square)
NA_obj = 0.12;            % Numerical aperture of the objective
px_size = (5.3e-6)/5;     % Pixel spacing projected onto sample (in meters)

% serial and camera parameters
trigger = '1';                      %define serial communication trigger
comPort = 'COM3';                   %define serial port (this may change each time)
%res = 1080;                        %define resolution of camera (may not need to do this)
%exp = 2;                           %define exposure time, may need to change conditionally with x and y
%% setup serial
%It creates a serial element calling the function "serialsetup"
%This should only run if the setup has not been completed before
if(~exist('serialFlag','var'))
    [arduino,serialFlag] = serialsetup(comPort);
end
%% setup camera
%Creates a camera element, and returns the camera information for the
%attached camera
if(~exist('cameraFlag','var'))
    [vid,cameraFlag] = camerasetup();
end

%% single color image aquisition

if colorsetting ==1
color1 = [color(1) color(2) color(3) xmax];

fprintf(arduino,color1)
pause(1)
% light first led
serialpass(arduino,'1');

max_img = [];
mean_img = [];

for i = 1:xmax
    for j = 1:ymax
        pause(.2)
        Image = takephoto(vid,i,j,xmax);
        Image = Image(2:1025,130:1153);
        disp(size(Image))
        Image =  medfilt2(Image);
        %Image = imresize(Image,[1024 1024]);
        max_img = [max_img,max(max(Image))];
        mean_img = [mean_img,mean(mean(Image))];
        %disp(max(m))
        figure(1);
        imagesc(Image);
        axis off;
        colormap gray;
        x1 = 0; y1 =x1;
        text(x1,y1,sprintf('%5.0f', [i,j]),'color', 'r','fontsize', 12)
        % save image for memory conservation
        Images{i,y-j+1} = Image;
        serialpass(arduino,trigger);
    end
end

for i = 1:xmax
    for j = 1:ymax
        Images{i,j} = (Images{i,j})/(max(max_img));
    end
end
        

version = '1';
save(filename,'version', 'LED_spacing',...
     'matrix_spacing', 'x_offset','y_offset', ...
     'wavelength', 'NA_obj','px_size','Images', '-v7');

%% run this section to restart image acquisition
fclose(arduino)
clear cameraFlag;
clear serialFlag;
clear vid;
% %% End the session
% % Clean the drivers off
% % make clean;
% clear 
toc
x = graphfunction(Images, arraysize,99);

end




%% spectral imaging RGB
if colorsetting ==3
    % will image a nxn grig of red then green then blue images 
    
%% red
color_red = [7 0 0 xmax]
fprintf(arduino,color_red)
pause(1)
% light first led
serialpass(arduino,'1');

for i = 1:xmax
    for j = 1:ymax
        Image1_red = takephoto(vid,i,j,xmax);
        Image2_red =  medfilt2(Image1_red);
        Image_red = imresize(Image2_red,[1024 1024]);
%         [i,j]
        figure(1)
        imagesc(Image_red);
        colormap gray;
        axis off
         x1 = 0; y1 =x1;
        text(x1,y1,sprintf('%5.0f', [i,j]),'color', 'r','fontsize', 12)
        % save image for memory conservation

        Images_red{i,y-j+1} = Image_red;
        serialpass(arduino,trigger);
    end
end


%% green
fclose(arduino)
clear serialFlag;
%% resetup serial
%It creates a serial element calling the function "serialsetup"
%This should only run if the setup has not been completed before
if(~exist('serialFlag','var'))
    [arduino,serialFlag] = serialsetup(comPort);
end
clear i j Image_red  Image1_red Image2_red
%% initiate green imaging
color_green = [0 7 0 xmax]
% light first led
fprintf(arduino,color_green)
pause(1)
serialpass(arduino,'1');

for i = 1:xmax
    for j = 1:ymax
        Image1_green = takephoto(vid,i,j,xmax);
        Image2_green =  medfilt2(Image1_green);
        Image_green = imresize(Image2_green,[1024 1024]);
        [i,j];
        figure(1)
        imagesc(Image_green);
        colormap gray;
        axis off
         x1 = 0; y1 =x1;
        text(x1,y1,sprintf('%5.0f', [i,j]),'color', 'g','fontsize', 12)
        % save image for memory conservation
        Images_green{i,y-j+1} = Image_green;
        serialpass(arduino,trigger);
    end
end

%% blue
fclose(arduino)
clear serialFlag;
%% resetup serial
%It creates a serial element calling the function "serialsetup"
%This should only run if the setup has not been completed before
if(~exist('serialFlag','var'))
    [arduino,serialFlag] = serialsetup(comPort);
end
clear i j Image_green Image1_green Image2_green
%% initiate blue imaging
 color_blue = [0 0 7 xmax]
% light first led
fprintf(arduino,color_blue)
pause(2)
serialpass(arduino,'1');

for i = 1:xmax
    for j = 1:ymax
        Image1_blue = takephoto(vid,i,j,xmax);
        Image2_blue =  medfilt2(Image1_blue);
        Image_blue = imresize(Image2_blue,[1024 1024]);
        [i,j];
        figure(1)
        imagesc(Image_blue);
        colormap gray;
        axis off
         x1 = 0; y1 =x1;
        text(x1,y1,sprintf('%5.0f', [i,j]),'color', 'b','fontsize', 12)
        % save image for memory conservation
        Images_blue{i,y-j+1} = Image_blue;
        serialpass(arduino,trigger);
    end
end
toc
%% graph grid of RGB images
x= graphfunction(Images_red, arraysize,96);
x= graphfunction(Images_green, arraysize,97);
x= graphfunction(Images_blue, arraysize,98);

%% save as filename
for i=1:xmax
    for j = 1:xmax
        Images_total{i,j} = Images_red{i,j}+Images_green{i,j}+Images_blue{i,j};
    end
end

version = '1';

save(filename,'version', 'LED_spacing',...
     'matrix_spacing', 'x_offset','y_offset', ...
     'wavelength', 'NA_obj','px_size','Images_total', '-v7');

fclose(arduino)
clear cameraFlag;
clear serialFlag;
clear vid;

end

