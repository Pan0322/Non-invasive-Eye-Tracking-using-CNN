clear
close all

load('output.mat')

file_name = 'IMG_5812.MOV';
frame_rate = 30;

v_r = VideoReader(file_name);
v_w = VideoWriter('face.avi');
open(v_w)

meta = [];

frame_count = 0;
figure
ii = 1;
while hasFrame(v_r)
    % Read this frame
    this_frame = readFrame(v_r);
    
    %To detect Face and eyes
    FaceDetect = vision.CascadeObjectDetector('MinSize', [200, 200]);
    BB_face=step(FaceDetect, this_frame);
    if length(BB_face) ==4 && size(BB_face, 1)==1
        BB_face_upper_left = BB_face;
        BB_face_upper_left(3) = BB_face_upper_left(3)/2;
        BB_face_upper_left(4) = BB_face_upper_left(4)/2;
        BB_face_upper_right = BB_face;
        BB_face_upper_right(3) = BB_face_upper_right(3)/2;
        BB_face_upper_right(4) = BB_face_upper_right(4)/2;
        BB_face_upper_right(1) = BB_face_upper_right(1) +BB_face_upper_right(3)-30;

        LeftEyeDetect = vision.CascadeObjectDetector('LeftEye', 'MaxSize', [100, 100], 'MinSize', [35, 35], 'MergeThreshold', 50, 'UseROI', true);
        RightEyeDetect = vision.CascadeObjectDetector('RightEye', 'MaxSize', [100, 100], 'MinSize', [35, 35], 'MergeThreshold', 10, 'UseROI', true);
        BB_left_eye = step(LeftEyeDetect, this_frame, BB_face_upper_left);
        BB_right_eye = step(RightEyeDetect, this_frame, BB_face_upper_right);
    end
    
    imshow(this_frame);
    hold on
    for i = 1:size(BB_face, 1)
        rectangle('Position',BB_face(i,:),'LineWidth',4,'LineStyle','-','EdgeColor','y');
    end
    for i = 1:size(BB_left_eye, 1)
        rectangle('Position',BB_left_eye(i,:),'LineWidth',4,'LineStyle','-','EdgeColor','y');
    end
    for i = 1:size(BB_right_eye, 1)
        rectangle('Position',BB_right_eye(i,:),'LineWidth',4,'LineStyle','-','EdgeColor','y');
    end

    drawnow
        
%     % Output image frame
%     output_frame_name = char(sprintf("frame_%d.png",frame_count));
%     imwrite(this_frame, output_frame_name);
%     
    % Output face and eye images
    if size(BB_face, 1)==1 && size(BB_left_eye, 1)==1 && size(BB_right_eye, 1)==1
        output_face_name = char(sprintf("./test_video/00002/appleFace/%.5d.jpg",frame_count));
        output_left_eye_name = char(sprintf("./test_video/00002/appleLeftEye/%.5d.jpg",frame_count));
        output_right_eye_name = char(sprintf("./test_video/00002/appleRightEye/%.5d.jpg",frame_count));
        imwrite(imcrop(this_frame, BB_face), output_face_name);
        imwrite(imcrop(this_frame, BB_left_eye), output_left_eye_name);
        imwrite(imcrop(this_frame, BB_right_eye), output_right_eye_name);
        meta = [meta, frame_count];
        
        % Draw eye gaze
%         rectangle('Position', [(A(ii,2)+8)*45,(A(ii,1)+8)*80, 10,10] ,'LineWidth',20,'LineStyle','-','EdgeColor','r');
        ii = ii+1;
    end
    
    title(ii)
    drawnow
    
    % Output video
    F = getframe(gcf);
    writeVideo(v_w, F);
    
    frame_count = frame_count + 1;
end

close(v_w);