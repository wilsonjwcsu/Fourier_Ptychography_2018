function [object_red] = reconstructRGB(filename, iterations)

%reconstruct: perform fourier ptychographic phase-retrieval using the
%images and data stored in the file <filename>.
% THIS CODE CORRECTS FOR UNKNOWN ABERATIONS AND FINDS A TRUE MINIMUM. 
%    usage:  object = reconstruct(filename, iterations);
%    input:  filename:   the name of the file containing the data to use
%            iterations: the number of iterations to perform
%    output: the reconstructed object

%% import images and other data

import = load(filename);

try
    version = 1;
catch Vexp
    if strcmp(Vexp.identifier,'MATLAB:nonExistentField')
        cause = MException('MATLAB:reconstruct:noVersion', ...
            'File %s contains no version information', filename);
        Vexp = Vexp.addCause(cause);
    end % identifier if
    Vexp.rethrow;
end % version try/catch

if version ~= 1
    error('This algorithm is incompatible with file version %d.', ...
        version);
end % version if

% optical parameters
try
    wavelength_red = import.wavelength(1);
    wavelength_green = import.wavelength(2);
    wavelength_blue = import.wavelength(3);
    LED_spacing = import.LED_spacing;
    matrix_spacing =import.matrix_spacing;
    x_offset = import.x_offset;
    y_offset = import.y_offset;
    NA_obj = import.NA_obj;
    px_size = import.px_size;
    Images_total = import.Images_total;

catch Pexp
    if strcmp(Pexp.identifier,'MATLAB:nonExistentField')
        % find out which parameter is missing
        indices = find(Pexp.message == '''');
        missing_param = Pexp.message(indices(1)+1:indices(2)-1);
        cause = MException('MATLAB:reconstruct:missingParam', ...
            'File %s is missing the %s parameter', filename, missing_param);
        Pexp = Pexp.addCause(cause);
    end % identifier if
    Pexp.rethrow;
end % parameter try/catch

% [m_s,n_s] = size(Images(:,:,1));    % size of sub-images
% [~,~,arraysize] =size(Images)
% arraysize = sqrt(arraysize);
[m_s,n_s] = size(Images_total{1,1});    % size of sub-images
[~,arraysize] =size(Images_total);

    %% Plotting NxN Grid
%   number of LEDs
    No_LEDs = arraysize^2;

%% Calculated parameters

LED_limit = LED_spacing * (arraysize - 1) / 2;
LED_positions = -LED_limit:LED_spacing:LED_limit;   % list of LED positions
%% Pixel Size and NA calculations
px_size_synth = px_size/4;
% calculate subimage size
% size of sub images in pixels
m_r = m_s*(px_size / px_size_synth);
n_r = m_r;

max_offset = max(abs([x_offset, y_offset]));
NA_matrix = sin(atan((LED_limit + max_offset) / matrix_spacing));
%% red constants
k_red = 2 * pi / wavelength_red;    % wavevector magnitude
% lists of transverse wavevectors
kx_list_red = k_red * sin(atan((LED_positions + x_offset) / matrix_spacing));
ky_list_red = k_red * sin(atan((LED_positions + y_offset) / matrix_spacing));
% maximum spatial frequency for sub-image
kt_max_sub_red = k_red * NA_obj;
% and for reconstructed image

% Use synthetic NA plus only the margin needed for subimage oversampling.
% also take matrix offset into account
kt_max_rec_red = k_red * (NA_matrix + NA_obj);
kt_max_obj_red = k_red * NA_obj;  % for objective

% spatial frequency axes for spectrums of images
kx_axis_sub_red = linspace(-kt_max_sub_red,kt_max_sub_red,n_s);
ky_axis_sub_red = linspace(-kt_max_sub_red,kt_max_sub_red,m_s);

% grid of spatial frequencies for each pixel of reconstructed spectrum
% same for subimage spectrum
[kx_g_sub_red,ky_g_sub_red] = meshgrid(kx_axis_sub_red,ky_axis_sub_red);

%% green constants
k_green = 2 * pi / wavelength_green;    % wavevector magnitude
% lists of transverse wavevectors
kx_list_green = k_green * sin(atan((LED_positions + x_offset) / matrix_spacing));
ky_list_green = k_green * sin(atan((LED_positions + y_offset) / matrix_spacing));
% maximum spatial frequency for sub-image
kt_max_sub_green = k_green * NA_obj;
% and for reconstructed image

% Use synthetic NA plus only the margin needed for subimage oversampling.
% also take matrix offset into account
kt_max_rec_green = k_green * (NA_matrix + NA_obj);
kt_max_obj_green = k_green * NA_obj;  % for objective

% spatial frequency axes for spectrums of images
kx_axis_sub_green = linspace(-kt_max_sub_green,kt_max_sub_green,n_s);
ky_axis_sub_green = linspace(-kt_max_sub_green,kt_max_sub_green,m_s);

% grid of spatial frequencies for each pixel of reconstructed spectrum
% same for subimage spectrum
[kx_g_sub_green,ky_g_sub_green] = meshgrid(kx_axis_sub_green,ky_axis_sub_green);

%% blue constants
k_blue = 2 * pi / wavelength_blue;    % wavevector magnitude
% lists of transverse wavevectors
kx_list_blue = k_blue * sin(atan((LED_positions + x_offset) / matrix_spacing));
ky_list_blue = k_blue * sin(atan((LED_positions + y_offset) / matrix_spacing));
% maximum spatial frequency for sub-image
kt_max_sub_blue = k_blue * NA_obj;
% and for reconstructed image

% Use synthetic NA plus only the margin needed for subimage oversampling.
% also take matrix offset into account
kt_max_rec_blue = k_blue * (NA_matrix + NA_obj);
kt_max_obj_blue = k_blue * NA_obj;  % for objective

% spatial frequency axes for spectrums of images
kx_axis_sub_blue = linspace(-kt_max_sub_blue,kt_max_sub_blue,n_s);
ky_axis_sub_blue = linspace(-kt_max_sub_blue,kt_max_sub_blue,m_s);

% grid of spatial frequencies for each pixel of reconstructed spectrum
% same for subimage spectrum
[kx_g_sub_blue,ky_g_sub_blue] = meshgrid(kx_axis_sub_blue,ky_axis_sub_blue);
%% Set up of Iteration Bar

    steps = No_LEDs * iterations;   % number of steps
    step = 0;                       % initialize step counter
    iter = 0;                       % initialize iteration counter
    wait_format = 'Iteration in RGB Reconstruction %d of %d';
    h = waitbar(0,sprintf(wait_format,iter,iterations));
    

%% retrieve phase iteratively
%% red
% initialize object
object_red = complex(ones(m_r,n_r));
objectFT_red = fftshift(fft2(object_red));
% interpolate on-axis image maybe?
% this is equivalent to doing the on-axis image first,
% and will be done eventually if a spiral scheme is used

% only need to generate one CTF, since it will be applied to the
% sub-images after they are extracted from the reconstructed image
% spectrum, and thus will not move around (relative to the sub-image).
CTF_red = ((kx_g_sub_red.^2 + ky_g_sub_red.^2) < kt_max_obj_red^2);

%% green
% initialize object
object_green = complex(ones(m_r,n_r));
objectFT_green = fftshift(fft2(object_green));
% interpolate on-axis image maybe?
% this is equivalent to doing the on-axis image first,
% and will be done eventually if a spiral scheme is used

% only need to generate one CTF, since it will be applied to the
% sub-images after they are extracted from the reconstructed image
% spectrum, and thus will not move around (relative to the sub-image).
CTF_green = ((kx_g_sub_green.^2 + ky_g_sub_green.^2) < kt_max_obj_green^2);

%% blue
% initialize object
object_blue = complex(ones(m_r,n_r));
objectFT_blue = fftshift(fft2(object_blue));
% interpolate on-axis image maybe?
% this is equivalent to doing the on-axis image first,
% and will be done eventually if a spiral scheme is used

% only need to generate one CTF, since it will be applied to the
% sub-images after they are extracted from the reconstructed image
% spectrum, and thus will not move around (relative to the sub-image).
CTF_blue = ((kx_g_sub_blue.^2 + ky_g_sub_blue.^2) < kt_max_obj_blue^2);

%% retrieve phase iteratively
[ seqi,seqj ] = sequence( arraysize )
for iter = 1:iterations         % one per iteration
    for i = 1:(arraysize)         % one per row of LEDs
        for j = 1:(arraysize)     % one per column of LEDs
            % calculate limits
%             sprintf('iteration %d, i %d, j %d ',iter, i,j)
%             i = seqi(i,j);
%             j = seqj(i,j);
            %% red k space
            kx_center_red = round((kx_list_red(j) + kt_max_rec_red) ...
                / 2 / kt_max_rec_red * (n_r - 1)) + 1;
            ky_center_red = round((ky_list_red(i) + kt_max_rec_red) ...
                / 2 / kt_max_rec_red * (m_r - 1)) + 1;
            kx_low_red = round(kx_center_red - (n_s - 1) / 2);
            kx_high_red = round(kx_center_red + (n_s - 1) / 2);
            ky_low_red = round(ky_center_red - (m_s - 1) / 2);
            ky_high_red = round(ky_center_red + (m_s - 1) / 2);
            
            %% green k space
            kx_center_green = round((kx_list_green(j) + kt_max_rec_green) ...
                / 2 / kt_max_rec_green * (n_r - 1)) + 1;
            ky_center_green = round((ky_list_green(i) + kt_max_rec_green) ...
                / 2 / kt_max_rec_green * (m_r - 1)) + 1;
            kx_low_green = round(kx_center_green - (n_s - 1) / 2);
            kx_high_green = round(kx_center_green + (n_s - 1) / 2);
            ky_low_green = round(ky_center_green - (m_s - 1) / 2);
            ky_high_green = round(ky_center_green + (m_s - 1) / 2);
            
            %% blue k space
            kx_center_blue = round((kx_list_blue(j) + kt_max_rec_blue) ...
                / 2 / kt_max_rec_blue * (n_r - 1)) + 1;
            ky_center_blue = round((ky_list_blue(i) + kt_max_rec_blue) ...
                / 2 / kt_max_rec_blue * (m_r - 1)) + 1;
            kx_low_blue = round(kx_center_blue - (n_s - 1) / 2);
            kx_high_blue = round(kx_center_blue + (n_s - 1) / 2);
            ky_low_blue = round(ky_center_blue - (m_s - 1) / 2);
            ky_high_blue = round(ky_center_blue + (m_s - 1) / 2);
            
            
            % extract piece of spectrum
            pieceFT_red = objectFT_red(ky_low_red:ky_high_red, kx_low_red:kx_high_red);
            pieceFT_green = objectFT_green(ky_low_green:ky_high_green, kx_low_green:kx_high_green);
            pieceFT_blue = objectFT_blue(ky_low_blue:ky_high_blue, kx_low_blue:kx_high_blue);
            
            %print(pieceFT)
            pieceFT_constrained_red = (m_s/m_r)^2*pieceFT_red .*CTF_red;   % apply CTF % lowResFT_1
            pieceFT_constrained_green = (m_s/m_r)^2*pieceFT_green .*CTF_green;   % apply CTF % lowResFT_1
            pieceFT_constrained_blue = (m_s/m_r)^2*pieceFT_blue .*CTF_blue;   % apply CTF % lowResFT_1
            
            
            
            % iFFT
            % may need a scale factor here due to size difference
            %piece = ifftn(pieceFT_constrained);
            piece_red = ifft2(ifftshift(pieceFT_constrained_red));
            piece_green = ifft2(ifftshift(pieceFT_constrained_green));
            piece_blue = ifft2(ifftshift(pieceFT_constrained_blue));
            
            RGB_sum = sqrt(abs(piece_red).^2)+sqrt(abs(piece_green).^2)+sqrt(abs(piece_blue).^2);
            
            mi = min(min(RGB_sum));
            ma = max(max(RGB_sum));
            avg = mean2(RGB_sum);
            if avg ==0
                RGB_sum = ones(size(RGB_sum));
            end
            
            
            % Replace intensity
            piece_replaced_red = (m_r/m_s)^2*abs(Images_total{i,j}).*(abs(piece_red)./RGB_sum).* exp(1i*angle(piece_red));
            piece_replaced_green = (m_r/m_s)^2*abs(Images_total{i,j}).*(abs(piece_green)./RGB_sum).* exp(1i*angle(piece_green));
            piece_replaced_blue = (m_r/m_s)^2*abs(Images_total{i,j}).*(abs(piece_blue)./RGB_sum).* exp(1i*angle(piece_blue));

            % also a scale factor here
            piece_replacedFT_red=fftshift(fft2(piece_replaced_red)).*CTF_red;
            piece_replacedFT_green=fftshift(fft2(piece_replaced_green)).*CTF_green;
            piece_replacedFT_blue=fftshift(fft2(piece_replaced_blue)).*CTF_blue;
            
            % put it back
            objectFT_red(ky_low_red:ky_high_red, kx_low_red:kx_high_red) = ...
                piece_replacedFT_red + pieceFT_red.*(1-CTF_red);
            objectFT_green(ky_low_green:ky_high_green, kx_low_green:kx_high_green) = ...
                piece_replacedFT_green + pieceFT_green.*(1-CTF_green);
            objectFT_blue(ky_low_blue:ky_high_blue, kx_low_blue:kx_high_blue) = ...
                piece_replacedFT_blue + pieceFT_blue.*(1-CTF_blue);
%             [ x ] = iterivelygraphphase( objectFT_red, objectFT_green, objectFT_blue );
            step = step + 1;
            waitbar(step/steps,h);

        end % column for
    end % row for
    waitbar(step/steps,h,sprintf(wait_format,iter,iterations));
end % iteration for

close(h);
%% compute reconstructed object
object_red = ifft2(ifftshift(objectFT_red));
object_green = ifft2(ifftshift(objectFT_green));
object_blue = ifft2(ifftshift(objectFT_blue));

figure(175)
subplot(3,1,1)
imagesc(abs(object_red));
title('red Object ');
colormap gray;
subplot(3,1,2)
imagesc(abs(object_green));
title(' green Object ');
colormap gray;
subplot(3,1,3)
imagesc(abs(object_blue));
title('blue Object ');
colormap gray;
end



