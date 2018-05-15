function [ x ] = graphfunction(Images, arraysize,fignumber)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

for i = 1:arraysize
    for j = 1:arraysize
T = j+(i-1)*arraysize;
        
figure(fignumber)
hold on
subplot(arraysize,arraysize,T)
imagesc(abs(Images{i,j}))
colormap gray
x1 = 0; y =x1;
text(x1,y,sprintf('%5.0f', [i,j]),'color', 'r','fontsize', 25)
x = 1;
    end
end

end