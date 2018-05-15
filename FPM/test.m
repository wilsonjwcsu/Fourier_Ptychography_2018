
filename = "mock_cl_256.mat";
iterations = 20;

[object] = zheng_recon(filename, iterations);
figure(2)
imagesc(abs(object))