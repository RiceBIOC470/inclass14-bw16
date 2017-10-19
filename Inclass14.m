%Inclass 14

%Work with the image stemcells_dapi.tif in this folder

% (1) Make a binary mask by thresholding as best you can

img=imread('stemcells_dapi.tif');
figure(1);
imshow(img,[]);

img_mask=img>quantile(quantile(img,0.8),0.8);
figure(2);
imshow(img_mask,[]);

% (2) Try to separate touching objects using watershed. Use two different
% ways to define the basins. (A) With erosion of the mask (B) with a
% distance transform. Which works better in this case?

img2=img_mask;
CC=bwconncomp(img2);
stats=regionprops(CC,'Area');
area3=[stats.Area];
fused=area3>mean(area3)+std(area3);
sublist=CC.PixelIdxList(fused);
sublist=cat(1,sublist{:});
fusedMask=false(size(img2));
fusedMask(sublist)=1;

distt=bwdist(fusedMask);
D=bwdist(~fusedMask);
D=-D;
D(~fusedMask)=-inf;
L=watershed(D);
rgb=label2rgb(L,'jet',[.5 .5 .5 ]);
dmask=L>1 | (img2-fusedMask);
figure (3); 
imshow(dmask, 'InitialMagnification','fit');

s=round(0.75*sqrt(mean(area3))/pi); 
nucmin=imerode(fusedMask,strel('disk',s));

outside= ~imdilate(fusedMask,strel('disk',1));

basin=imcomplement(bwdist(outside));
basin=imimposemin(basin, nucmin | outside);
pcolor (basin); shading flat;

L3=watershed(basin);
newnmask=L3>1 | (img2-fusedMask);
figure(4); 
imshow(newnmask,[]);
