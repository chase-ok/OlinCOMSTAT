%compute fractal dimension from greyscale image

function res = frdimrev(imagevar)
imagevar = double(imagevar);
imshow(imagevar)

[xpix,ypix] = size(imagevar);
cenx = floor(xpix/2);
ceny = floor(ypix/2);

mass = zeros(floor(min(size(imagevar))/20),2);
for i = 1:1:floor(min(size(imagevar))/20)
    mass(i,1) = i;
    for x = cenx-10*i:1:cenx+10*i
        for y = ceny-10*i:1:cenx+10*i
            if sqrt((x-cenx)^2 + (y-ceny)^2)<=10*i
                mass(i,2) = mass(i,2)+imagevar(x,y);
            end
        end
    end
end

figure
loglog(mass(:,1),mass(:,2))
res = mass;

