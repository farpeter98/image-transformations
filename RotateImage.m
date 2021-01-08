function [outImage] = RotateImage(image, angle, method)
%RotateImage
%   Rotates the given image by the supplied angle (counter-clockwise)
%   via resampling and interpolating using the given method which can be
%   'nearest' for nearest-neightbour
%   'bilinear', or 'bicubic'

[height,width,channels] = size(image);
R = deg2rad(-angle);

costheta = cos(R);
sintheta = sin(R);
xc = (1+height)/2;
yc = (1+width)/2;

function out = RotatedPosition(x0, y0)
       out = [(x0-xc)*costheta - (y0-yc)*sintheta + xc,...
                 (x0-xc)*sintheta + (y0-yc)*costheta + yc];
end

cornerPositions = arrayfun(@(x) round(x),[RotatedPosition(1,1)
                                          RotatedPosition(1,width)
                                          RotatedPosition(height,width)
                                          RotatedPosition(height,1)]);
newHeight = 1 + max(abs(cornerPositions(1,1) - cornerPositions(3,1)),...
                    abs(cornerPositions(2,1) - cornerPositions(4,1)));
newWidth = 1 + max(abs(cornerPositions(1,2) - cornerPositions(3,2)),...
                   abs(cornerPositions(2,2) - cornerPositions(4,2)));
offsetX = -min(cornerPositions(:,1)) + 1;
offsetY = -min(cornerPositions(:,2)) + 1;

outImage = zeros(newHeight, newWidth, channels, class(image(1,1,1)));
switch method
    case 'nearest'
        for xi = 1:newHeight
            for yi = 1:newWidth
                dblxy = RotatedPosition(xi-offsetX, yi-offsetY);
                if dblxy(1) > 0 && dblxy(1) <= height && dblxy(2) > 0 && dblxy(2) <= width

                    intxy = round(dblxy);
                    if intxy(1) == 0
                        intxy(1) = 1;
                    end
                    if intxy(2) == 0
                        intxy(2) = 1;
                    end
                    for ci = 1:channels
                        outImage(xi,yi,ci) = image(intxy(1),intxy(2),ci);
                    end
                end
            end
        end

    case 'bilinear'
        for xi = 1:newHeight
            for yi = 1:newWidth
                xy = RotatedPosition(xi-offsetX, yi-offsetY);
                if xy(1) > 0 && xy(1) <= height && xy(2) > 0 && xy(2) <= width

                    if xy(1) < 1
                        xy(1) =  1;
                    elseif xy(1) == height
                        xy(1) = height-0.01;
                    end
                    if xy(2) < 1
                        xy(2) = 1;
                    elseif xy(2) == width
                        xy(2) = width-0.01;
                    end

                    x1 = floor(xy(1));
                    x2 = x1 + 1;
                    y1 = floor(xy(2));
                    y2 = y1 + 1;
                    w1 = x2-xy(1);
                    w2 = xy(1)-x1;
                    w3 = y2-xy(2);
                    w4 = xy(2)-y1;

                    for ci = 1:channels
                        v1 = w1*image(x1, y1, ci) + w2*image(x2, y1, ci);
                        v2 = w1*image(x1, y2,ci) + w2*image(x2, y2, ci);
                        outImage(xi, yi, ci) = round(w3*v1 + w4*v2);
                    end
                end
            end
        end

    case 'bicubic'
        for xi = 1:newHeight
            for yi = 1:newWidth
                xy = RotatedPosition(xi-offsetX, yi-offsetY);
                if xy(1) > 0 && xy(1) <= height && xy(2) > 0 && xy(2) <= width

                    if xy(1) < 1
                        xy(1) =  1;
                    elseif xy(1) == height
                        xy(1) = height-0.01;
                    end
                    if xy(2) < 1
                        xy(2) = 1;
                    elseif xy(2) == width
                        xy(2) = width-0.01;
                    end

                    x0 = floor(xy(1))-1;
                    x1 = x0+1;
                    x2 = x1+1;
                    x3 = x2+1;
                    left = [BicubicKernel(xy(1)-x0), BicubicKernel(xy(1)-x1),...
                            BicubicKernel(xy(1)-x2), BicubicKernel(xy(1)-x3)];

                    y0 = floor(xy(2))-1;
                    y1 = y0+1;
                    y2 = y1+1;
                    y3 = y2+1;
                    right = [BicubicKernel(xy(2)-y0); BicubicKernel(xy(2)-y1);...
                             BicubicKernel(xy(2)-y2); BicubicKernel(xy(2)-y3)];

                    if x0 == 0
                        x0 = 1;
                    end
                    if x3 > height
                        x3 = height-1;
                    end
                    if y0 == 0
                        y0 = 1;
                    end
                    if y3 > width
                        y3 = width-1;
                    end
                    for ci = 1:channels
                        pixelValues = double([image(x0,y0,ci), image(x0,y1,ci), image(x0,y2,ci), image(x0,y3,ci);
                                              image(x1,y0,ci), image(x1,y1,ci), image(x1,y2,ci), image(x1,y3,ci);
                                              image(x2,y0,ci), image(x2,y1,ci), image(x2,y2,ci), image(x2,y3,ci);
                                              image(x3,y0,ci), image(x3,y1,ci), image(x3,y2,ci), image(x3,y3,ci)]);
                        outImage(xi, yi, ci) = left*pixelValues*right;
                    end
                end
            end
        end

    otherwise
        error('Unknown interpolation method');
end
end