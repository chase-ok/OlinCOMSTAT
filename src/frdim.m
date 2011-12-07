%compute fractal dimension from image

function res = frdim(imagevar)

imshow(imagevar)
figure
logbw = im2bw(imagevar,0.5);
imshow(logbw)

[xpix,ypix] = size(logbw);
cenx = floor(xpix/2);
ceny = floor(ypix/2);

mass = zeros(floor(min(size(logbw))/20),2);
for i = 1:1:floor(min(size(logbw))/20)
    mass(i,1) = i;
    mass(i,2) = 0;
    for x = cenx-10*i:1:cenx+10*i
        for y = ceny-10*i:1:cenx+10*i
            if sqrt((x-cenx)^2 + (y-ceny)^2)<=10*i
                mass(i,2) = mass(i,2)+logbw(x,y);
            end
        end
    end
end

figure
loglog(mass(:,1),mass(:,2))
res = mass;

