% MU1 = [1 2];
MU1 = [1 1];
SIGMA1 = [2 0; 0 .5];
% MU2 = [-3 -5];
MU2 = [-1 -1];
SIGMA2 = [1 0; 0 1];
X = [mvnrnd(MU1,SIGMA1,1000);mvnrnd(MU2,SIGMA2,1000)];

scatter(X(:,1),X(:,2),10,'.')
hold on
options = statset('Display','final');
obj = gmdistribution.fit(X,2,'Options',options);
h = ezcontour(@(x,y)pdf(obj,[x y]),[-8 6],[-8 6]);
hold off
