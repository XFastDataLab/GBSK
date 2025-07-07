function [label_all_peaks, peaks, nneigh, ordgamma] = obtain_skeleton2(all_peaks, ball_radius, points_per_ball, k)
    points = all_peaks;

    [x,~]=size(points);
    num= (x*x-x)/2;
    distances=zeros(num,3);

    distMat= pdist2(points,points);
    k2=1;
    loc=1;
    for i=1:x-1
        distances(loc:loc+(x-k2)-1,1)=k2*ones(x-k2,1);
        distances(loc:loc+(x-k2)-1,2)=(k2+1:1:x);
        distances(loc:loc+(x-k2)-1,3)=distMat(k2,k2+1:x)';
        loc=loc+(x-k2);
        k2=k2+1;
    end

    xx=distances;
    ND=max(xx(:,2));
    NL=max(xx(:,1));
    if (NL>ND)   
        ND=NL;
    end
    N=size(xx,1);  
    dist = zeros(ND,ND);
    for i=1:N
        ii=xx(i,1);
        jj=xx(i,2);
        dist(ii,jj)=xx(i,3);
        dist(jj,ii)=xx(i,3);
    end
    
    % 计算平均半径
    average_radius = median(ball_radius);
    
    % 计算密度
    rho = calculateDensity2(ball_radius, points_per_ball, average_radius);

    maxd=max(max(dist));
    [~,ordrho]=sort(rho,'descend');
    delta(ordrho(1))=-1;
    nneigh(ordrho(1))=0;

    for ii=2:ND
        delta(ordrho(ii))=maxd;
        for jj=1:ii-1
            if(dist(ordrho(ii),ordrho(jj))<delta(ordrho(ii)))
                delta(ordrho(ii))=dist(ordrho(ii),ordrho(jj));
                nneigh(ordrho(ii))=ordrho(jj);
            end
        end
    end
    delta(ordrho(1))=max(delta(:));

    for i=1:ND
        ind(i)=i;
        gamma(i)=rho(i)*delta(i);
    end

    [gamma_sorted,ordgamma]= sort(gamma,'descend');  
    index_centers = ordgamma(1:k);
    peaks = all_peaks(index_centers, :);

    NCLUST=0;
    for i=1:ND
        cl(i)=-1;
    end

    for i=1:ND
        if(rho(i)*delta(i)>=gamma_sorted(k))      
            NCLUST=NCLUST+1;
            cl(i)=NCLUST; 
            icl(NCLUST)=i;
        end
    end

    for i=1:ND
        if (cl(ordrho(i))==-1)
            cl(ordrho(i))=cl(nneigh(ordrho(i)));
        end
    end

    label_all_peaks = reshape(cl, length(cl), 1);
end
