function [object] = real_time_recon(filename, iterations)

%reconstruct: perform fourier ptychographic phase-retrieval using the
%images and data stored in the file <filename>.
% THIS CODE CORRECTS FOR UNKNOWN ABERATIONS AND FINDS A TRUE MINIMUM. 
%    usage:  object = reconstruct(filename, iterations);
%    input:  filename:   the name of the file containing the data to use
%            iterations: the number of iterations to perform
%    output: the reconstructed object
%     Includes a Pupil function
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
    wavelength = import.wavelength;
    LED_spacing = import.LED_spacing;
    matrix_spacing = import.matrix_spacing;
    x_offset = import.x_offset;
    y_offset = import.y_offset;
    NA_obj = import.NA_obj;
    px_size = import.px_size;
    Images = import.Images;
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
[m_s,n_s] = size(Images{1,1});    % size of sub-images
[~,arraysize] =size(Images);


%   number of LEDs
    No_LEDs = arraysize^2;

%% Calculated parameters

LED_limit = LED_spacing * (arraysize) / 2;
LED_positions = -LED_limit:LED_spacing:LED_limit;   % list of LED positions
k = 2 * pi / wavelength;    % wavevector magnitude
% lists of transverse wavevectors
kx_list = k * sin(atan((LED_positions + .0037) / matrix_spacing));
ky_list = k * sin(atan((LED_positions + y_offset) / matrix_spacing));

%% Pixel Size and NA calculations
px_size_synth = px_size/4;

% calculate subimage size
% size of sub images in pixels
m_r = m_s*(px_size / px_size_synth);
n_r = m_r;

% maximum spatial frequency for sub-image
kt_max_sub = k * NA_obj;
% and for reconstructed image

% Use synthetic NA plus only the margin needed for subimage oversampling.
% also take matrix offset into account
max_offset = max(abs([x_offset, y_offset]));
NA_matrix = sin(atan((LED_limit + max_offset) / matrix_spacing));
kt_max_rec = k * (NA_matrix + NA_obj);

% spatial frequency axes for spectrums of images
kx_axis_sub = linspace(-kt_max_sub,kt_max_sub,n_s);
ky_axis_sub = linspace(-kt_max_sub,kt_max_sub,m_s);

% grid of spatial frequencies for each pixel of reconstructed spectrum
% same for subimage spectrum
[kx_g_sub,ky_g_sub] = meshgrid(kx_axis_sub,ky_axis_sub);

%% Set up of Iteration Bar

    steps = No_LEDs * iterations;   % number of steps
    step = 0;                       % initialize step counter
    iter = 0;                       % initialize iteration counter
    wait_format = 'Iteration in Real Time Reconstruction %d of %d';
    h = waitbar(0,sprintf(wait_format,iter,iterations));
    

%% retrieve phase iteratively

% initialize object
object = complex(ones(m_r,n_r));
objectFT = gpuArray(fftshift(fft2(object)));
% interpolate on-axis image maybe?
% this is equivalent to doing the on-axis image first,
% and will be done eventually if a spiral scheme is used

% only need to generate one CTF, since it will be applied to the
% sub-images after they are extracted from the reconstructed image
% spectrum, and thus will not move around (relative to the sub-image).
CTF = ((kx_g_sub.^2 + ky_g_sub.^2) < kt_max_sub^2);
pupil = 1;
[ seqi,seqj ] = sequence( arraysize );
for iter = 1:iterations         % one per iteration
    for i = 1:arraysize         % one per row of LEDs
        for j = 1:arraysize     % one per column of LEDs
             i2 = i; %seqi(i,j);
             j2 = j; %seqj(i,j);
            % calculate limits
%             sprintf('iteration %d, i %d, j %d ',iter, i,j)
            
            kx_center = round((kx_list(j2) + kt_max_rec) ...
                / 2 / kt_max_rec * (n_r - 1)) + 1;
            ky_center = round((ky_list(i2) + kt_max_rec) ...
                / 2 / kt_max_rec * (m_r - 1)) + 1;
            kx_low = round(kx_center - (n_s - 1) / 2);
            kx_high = round(kx_center + (n_s - 1) / 2)
            ky_low = round(ky_center - (m_s - 1) / 2);
            ky_high = round(ky_center + (m_s - 1) / 2);
            % extract piece of spectrum
            pieceFT = objectFT(ky_low:ky_high, kx_low:kx_high);
            %print(pieceFT)
            pieceFT_constrained = pieceFT .*CTF;%.*pupil;   % apply CTF % lowResFT_1
            % iFFT
            % may need a scale factor here due to size difference
            %piece = ifftn(pieceFT_constrained);
            piece = ifft2(ifftshift(pieceFT_constrained));
            % Replace intensity
            piece_replaced = sqrt(abs(Images{i2,j2})).* exp(1i*angle(piece));
            % also a scale factor here
            piece_replacedFT=fftshift(fft2(piece_replaced)).*CTF;%.*(1./pupil);
            % put it back
            objectFT(ky_low:ky_high, kx_low:kx_high) = ...
                piece_replacedFT + pieceFT - pieceFT_constrained;

            step = step + 1;
            waitbar(step/steps,h);

           pupil = pupil+ conj(objectFT(ky_low:ky_high,kx_low:kx_high))...
                ./(max(max(abs(objectFT(ky_low:ky_high,kx_low:kx_high)).^2)))...
                .*(piece_replacedFT-pieceFT_constrained);
            
           figure(22);
           subplot(2,2,1);
           imshow(log(abs(objectFT)),[]),title({'Reconstructed','Log Spectral Amplitude'})
            
           object = ifft2(ifftshift(objectFT));
           subplot(2,2,2);
           imshow(abs(object),[]),title({'Reconstructed',' Object Amplitude'})
           subplot(2,2,3);
           imshow(angle(object),[]),title({'Reconstructed',' Object Phase'})

        end % column for
    end % row for
    waitbar(step/steps,h,sprintf(wait_format,iter,iterations));
end % iteration for
close(h);
%% compute reconstructed object
object = ifft2(ifftshift(objectFT));

% 
% figure(1)
% imagesc(abs(object));
% colormap gray
% axis off
% axis image
% 
% figure(2)
% imagesc(angle(object));
% colormap gray
% axis off
% axis image

end





