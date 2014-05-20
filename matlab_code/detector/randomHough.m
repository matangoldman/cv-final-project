function [ H_acc,H_radius ] = randomHough(edgesIm,maxR,minR,numItersFactor,numFact)

[Y,X,~] = size(edgesIm);
% numFact = minR;
[mX,mY] = meshgrid(1:X,1:Y);

% get edges indices
[eY,eX] = find(edgesIm>0);

% randomly choose 3 edges each iteration and calculate circle's center
rndSeed = 13;
N_iters = length(eX)*numItersFactor;
RandStream.setGlobalStream(RandStream('mt19937ar','seed',rndSeed));

pS1 = randi( length(eX),1,N_iters);
RandStream.setGlobalStream(RandStream('mt19937ar','seed',2*rndSeed));

pS2 = randi( length(eX),1,N_iters);
RandStream.setGlobalStream(RandStream('mt19937ar','seed',3*rndSeed));

pS3 = randi( length(eX),1,N_iters);

% pre allocation for speed
H_acc     = zeros (Y,X);
H_radius = zeros (Y,X);

for ii=1:N_iters
    % selected indices
    p1= pS1(ii);    p2= pS2(ii);    p3= pS3(ii);
    % edges coordinates
    x1 = eX(p1);    x2 = eX(p2);    x3 = eX(p3);
    y1 = eY(p1);    y2 = eY(p2);    y3 = eY(p3);
    % compute possible circle center-(h,v) and radius-(r) using deteminant method (cramer's rule)
    %    A*[h;v]=b
    
    den=2*((x2-x1)*(y3-y1) - (x3-x1)*(y2-y1)); % detA/2
    % if det == 0 - points are colinear, no circle is found
    if (den == 0)
        continue;
    end
    
    b1 = (x2^2+y2^2) - (x1^2+y1^2)  ;
    b2 = (x3^2+y3^2) - (x1^2+y1^2) ;
    
    % circle parameters
    h=round(((y3-y1)*b1 - (y2-y1)*b2)/den);
    v=round(((x2-x1)*b2 - (x3-x1)*b1)/den);
    r =round( sqrt((x1-h)^2 + (y1-v)^2) );

    % if circle's radius is lower the min_radius go to next iteration
    if (r<minR) || (r>maxR)
        continue;
    end
    
    % if circle's center is out of bounds go to next iteration
    if ( (h<1) || (h >X) || (v<1) || (v>Y) )
        continue;
    end

    % if this circle was already valued go to next iteration
    if H_radius(v,h) == r
        continue;
    end
    
    % check the support level for this circle: counts how many edges are on
    % the circumference
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % limit search space to (v,h) +-r
    xRange =  max(1,(h-(r+1))):min(X,(h+(r+1)));
    yRange =  max(1,(v-(r+1))):min(Y,(v+(r+1)));
    
    xInd =mX(yRange,xRange);
    yInd =mY(yRange,xRange);
    
    % get circle's indices binary matrix
    circleMask = ((xInd-h).^2 +(yInd-v).^2 <= (r+1)^2)  & ((xInd-h).^2 +(yInd-v).^2 >= (r-1)^2);
    circle = edgesIm(yRange,xRange).*circleMask;
    
    % count the number of edges and normalize by r (so that larger circles aren't favored over small ones)
    cnt = sum(sum(circle))/(r+numFact);

    % if circles are concentric, favor the stronger one
    if (cnt>H_acc(v,h))
        H_acc(v,h) = cnt;
        H_radius(v,h) = r;
    end
end
    
