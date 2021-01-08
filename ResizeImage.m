function [outImage] = ResizeImage(image, scale, method)
%ResizeImage
%   Resizes the given image by the supplied scale via resampling
%   and interpolating using the given method which can be
%   'nearest' for nearest-neightbour
%   'bilinear', or 'bicubic'

[height,width,channels] = size(image);
newHeight = ceil(height*scale);
newWidth = ceil(width*scale);

outImage = zeros(newHeight, newWidth, channels, class(image));
shift = 0.5*(1-1/scale);

switch method
    case 'nearest'
        for xi = 1:newHeight
            x = round(xi/scale + shift);
            if x == 0
                x = 1;
            elseif x > height
                x = height;
            end
            for yi = 1:newWidth
                y = round(yi/scale + shift);
                if y == 0
                    y = 1;
                elseif y > width
                    y = width;
                end
                for ci = 1:channels
                    outImage(xi,yi,ci) = image(x,y,ci);
                end
            end
        end

    case 'bilinear'
        for xi = 1:newHeight

            x = xi/scale + shift;
            if x < 1
                x = 1;
            elseif x >= height
                x = height-0.01;
            end

            x1 = floor(x);
            x2 = x1+1;
            w1 = x2-x;
            w2 = x-x1;

            for yi = 1:newWidth

                y = yi/scale + shift;
                if y < 1
                    y = 1;
                elseif y >= width
                    y = width-0.01;
                end

                y1 = floor(y);
                y2 = y1 + 1;
                w3 = y2-y;
                w4 = y-y1;
                
                for ci = 1:channels
                    v1 = w1*image(x1, y1, ci) + w2*image(x2, y1, ci);
                    v2 = w1*image(x1, y2,ci) + w2*image(x2, y2, ci);
                    outImage(xi, yi, ci) = round(w3*v1 + w4*v2);
                end
            end
        end

    case 'bicubic'
        for xi = 1:newHeight

            x = xi/scale + shift;
            if x < 1
                x = 1;
            elseif x >= height
                x = height-0.01;
            end

            x0 = floor(x)-1;
            x1 = x0+1;
            x2 = x1+1;
            x3 = x2+1;
            left = [BicubicKernel(x-x0), BicubicKernel(x-x1),...
                    BicubicKernel(x-x2), BicubicKernel(x-x3)];

            if x0 == 0
                x0 = 1;
            end
            if x3 > height
                x3 = height-1;
            end

            for yi = 1:newWidth
                y = yi/scale + shift;
                if y < 1
                    y = 1;
                elseif y >= width
                    y = width-0.01;
                end

                y0 = floor(y)-1;
                y1 = y0+1;
                y2 = y1+1;
                y3 = y2+1;
                right = [BicubicKernel(y-y0); BicubicKernel(y-y1);...
                         BicubicKernel(y-y2); BicubicKernel(y-y3)];
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
    otherwise
        error('Unknown interpolation method');
end
end