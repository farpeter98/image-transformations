%% a = -0.5 Kernel
xs = -2:0.05:2;
ys = arrayfun(@(x) TestKernel(x,-0.5), xs);
figure;plot(xs,ys);

%% a = 2 Kernel
xs = -2:0.05:2;
ys = arrayfun(@(x) TestKernel(x,2), xs);
figure;plot(xs,ys);

%% a = -2 Kernel
xs = -2:0.05:2;
ys = arrayfun(@(x) TestKernel(x,-2), xs);
figure;plot(xs,ys);

%% x = [-2,2], a = [-2,2] Kernel felület
x = -2:0.05:2;
a = -2:0.05:2;
[X, Y] = meshgrid(x, a);
Z = zeros(length(x),length(a));
for i = 1:length(a)
    for j = 1:length(x)
        Z(i,j) = TestKernel(x(j),a(i));
    end
end
surf(X, Y, Z);

%%
img = imread('lena.png');
angle = 30;
figure;imshow(RotateImage(img, angle, 'nearest'));
figure;imshow(RotateImage(img, angle, 'bilinear'));
figure;imshow(RotateImage(img, angle, 'bicubic'));

%%
img = imread('lena.png');
scale = 1.5;
figure;imshow(ResizeImage(img, scale, 'nearest'));
figure;imshow(ResizeImage(img, scale, 'bilinear'));
figure;imshow(ResizeImage(img, scale, 'bicubic'));

%%
img = imread('szines.png');
scale = 100;
figure;imshow(ResizeImage(img, scale, 'nearest'));
figure;imshow(ResizeImage(img, scale, 'bilinear'));
figure;imshow(ResizeImage(img, scale, 'bicubic'));


%%
img = imread('csiga.png');
scale = 50;
figure;imshow(ResizeImage(img, scale, 'nearest'));
figure;imshow(ResizeImage(img, scale, 'bilinear'));
figure;imshow(ResizeImage(img, scale, 'bicubic'));

%%
img = imread('pont.png');
figure;imshow(ResizeImage(img, 50, 'bicubic'));