z1 = 0;
z2 = 1;
r1 = 0.5;
r2 = 1;
theta = linspace(pi/4,3*pi/4,100);
x1 = r1*cos(theta);
y1 = r1*sin(theta);
x2 = r2*cos(theta);
y2 = r2*sin(theta);

figure(1);
hold all;

% bottom face
x = [x1 fliplr(x2) x1(1)];
y = [y1 fliplr(y2) y1(1)];
z = z1*ones(size(x));
fill3(x,y,z,'r');

% top face
x = [x1 fliplr(x2) x1(1)];
y = [y1 fliplr(y2) y1(1)];
z = z2*ones(size(x));
fill3(x,y,z,'r');

% left face
x = [x1(end) x2(end) x2(end) x1(end)];
y = [y1(end) y2(end) y2(end) y1(end)];
z = [z1 z1 z2 z2];
fill3(x,y,z,'r');

% right face
x = [x1(1) x2(1) x2(1) x1(1)];
y = [y1(1) y2(1) y2(1) y1(1)];
z = [z1 z1 z2 z2];
fill3(x,y,z,'r');

% front face
x = [x1 fliplr(x1) x1(1)];
y = [y1 fliplr(y1) y1(1)];
z = [z1*ones(size(x1)) z2*ones(size(x1)) z1];
fill3(x,y,z,'r');

% back face
x = [x2(1:25) x2(25:-1:1) x2(1)];
y = [y2(1:25) y2(25:-1:1) y2(1)];
z = [z1*ones(1,25) z2*ones(1,25) z1];
fill3(x,y,z,'r', 'EdgeColor', 'none');

x = [x2(25:50) x2(50:-1:25) x2(25)];
y = [y2(25:50) y2(50:-1:25) y2(25)];
z = [z1*ones(1,26) z2*ones(1,26) z1];
fill3(x,y,z,'r', 'EdgeColor', 'none');

x = [x2(50:75) x2(75:-1:50) x2(50)];
y = [y2(50:75) y2(75:-1:50) y2(50)];
z = [z1*ones(1,26) z2*ones(1,26) z1];
fill3(x,y,z,'r', 'EdgeColor', 'none');

x = [x2(75:100) x2(100:-1:75) x2(75)];
y = [y2(75:100) y2(100:-1:75) y2(75)];
z = [z1*ones(1,26) z2*ones(1,26) z1];
fill3(x,y,z,'r', 'EdgeColor', 'none');

hold off;