function [] = visualize_frames(settings)

settings.numFramesToShow = 400; % Set how many frames you want to visualize
settings.frameStep = 20; % Show every 5th frame (adjust as needed)

for r1 = settings.FrameInit:settings.frameStep:min(settings.FrameEnd, settings.FrameInit + settings.numFramesToShow * settings.frameStep)
    Im = read(settings.VideoP, r1);
    FrameVideo = double(rgb2gray(Im(settings.PixelInitY:settings.PixelInitY-1+settings.FrameSizeY, settings.PixelInitX:settings.PixelInitX-1+settings.FrameSizeX,:)));

    % Display the frame
    imagesc(FrameVideo);
    colormap gray;
    axis image;
    axis off;
    title(sprintf('Frame %d', r1));
    drawnow;
    
    pause(0.1); % Small pause to allow visualization
end
end