clear all;close all;clc;

% Open the ZED
zed = webcam('ZED');
% Set video resolution=720P
zed.Resolution = zed.AvailableResolutions{1};
% Get image size
[height width channels] = size(snapshot(zed));

true = 1;
frame_count = 0;

while true
    %load image
    img = snapshot(zed);
    image_left = img(:, 1 : width/2, :);
    im = image_left;
    frame_count = frame_count + 1;
    if size(im,3) > 1,
        im = rgb2gray(im);
    end
    if resize_image,
        im = imresize(im, 0.5);
    end
    tic()
    if frame_count > 1,
        %obtain a subwindow for detection at the position from last
        %frame_count, and convert to Fourier domain (its size is unchanged)
        patch = get_subwindow(im, pos, window_sz);
        zf = fft2(get_features(patch, features, cell_size, cos_window));

        %calculate response of the classifier at all shifts
        switch kernel.type
        case 'gaussian',
            kzf = gaussian_correlation(zf, model_xf, kernel.sigma);
        case 'polynomial',
            kzf = polynomial_correlation(zf, model_xf, kernel.poly_a, kernel.poly_b);
        case 'linear',
            kzf = linear_correlation(zf, model_xf);
        end
        response = real(ifft2(model_alphaf .* kzf));  %equation for fast detection

        %target location is at the maximum response. we must take into
        %account the fact that, if the target doesn't move, the peak
        %will appear at the top-left corner, not at the center (this is
        %discussed in the paper). the responses wrap around cyclically.
        [vert_delta, horiz_delta] = find(response == max(response(:)), 1);
        if vert_delta > size(zf,1) / 2,  %wrap around to negative half-space of vertical axis
            vert_delta = vert_delta - size(zf,1);
        end
        if horiz_delta > size(zf,2) / 2,  %same for horizontal axis
            horiz_delta = horiz_delta - size(zf,2);
        end
        pos = pos + cell_size * [vert_delta - 1, horiz_delta - 1];
    end

    %obtain a subwindow for training at newly estimated target position
    patch = get_subwindow(im, pos, window_sz);
    xf = fft2(get_features(patch, features, cell_size, cos_window));
    %Kernel Ridge Regression, calculate alphas (in Fourier domain)
    switch kernel.type
    case 'gaussian',
        kf = gaussian_correlation(xf, xf, kernel.sigma);
    case 'polynomial',
        kf = polynomial_correlation(xf, xf, kernel.poly_a, kernel.poly_b);
    case 'linear',
        kf = linear_correlation(xf, xf);
    end
    alphaf = yf ./ (kf + lambda);   %equation for fast training

    if frame_count == 1,  %first frame_count, train with a single image
        model_alphaf = alphaf;
        model_xf = xf;
    else
        %subsequent frames, interpolate model
        model_alphaf = (1 - interp_factor) * model_alphaf + interp_factor * alphaf;
        model_xf = (1 - interp_factor) * model_xf + interp_factor * xf;
    end

    %save position and timing
    positions(frame_count,:) = pos;
    time = time + toc();

    %visualization
    if show_visualization,
        box = [pos([2,1]) - target_sz([2,1])/2, target_sz([2,1])];
        stop = update_visualization(frame_count, box);
        if stop, break, end  %user pressed Esc, stop early

        drawnow
    % 			pause(0.05)  %uncomment to run slower
    end
end