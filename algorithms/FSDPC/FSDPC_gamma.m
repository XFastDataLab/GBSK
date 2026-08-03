clear
clc

scriptDir = fileparts(mfilename('fullpath'));
repoRoot = fileparts(fileparts(scriptDir));
addpath(genpath(repoRoot));


dataFile = fullfile(repoRoot, 'datasets', 'ConfLong.txt');
if exist(dataFile, 'file')
    data = importdata(dataFile);
else
    error('Dataset not found: %s', dataFile);
end

tic
ND=size(data,1);
N=ND*(ND-1)/2;
K=11;

sim=zeros(ND);
sim(:,:)=inf;

a=-1*ones(1,3);
for i=1:ND
    b(i)=norm(data(i,:)-a);
end
[m,n]=sort(b);

xun=round(0.4*ND);

for i=1:xun-1
    for j=i+1:xun
        sim(n(i),n(j))=norm(data(n(i),:)-data(n(j),:));
        sim(n(j),n(i))=sim(n(i),n(j));
    end
end
for i=2:(ND-xun+1)
    for j=i:(i+xun-2)
        k=i+(xun-1);
        sim(n(j),n(k))=norm(data(n(j),:)-data(n(k),:));
        sim(n(k),n(j))=sim(n(j),n(k));
    end
end

percent=2;
position=round(N*percent/100);
sda=sort((sim(triu(true(size(sim)),1)))');
dc=sda(position);

for i=1:(ND-xun+1)
    cc=0;
    for j=i+xun:ND
        cc=norm(data(n(i),:)-data(n(j),:));
        if cc<=dc
            sim(n(i),n(j))=cc;
            sim(n(j),n(i))=sim(n(i),n(j));
            continue
        end
        break
    end
end

sim(logical(eye(ND)))=0;

t2=cputime;

for i=1:ND
    rho(i)=0;
end

for i=1:ND-1
    for j=i+1:ND
        rho(i)=rho(i)+exp(-(sim(i,j)/dc)^2);
        rho(j)=rho(j)+exp(-(sim(i,j)/dc)^2);
    end
end

maxd=max(max(sda(~isinf(sda))));

[rho_sorted,ordrho]=sort(rho,'descend');
delta(ordrho(1))=-1.;
nneigh(ordrho(1))=0;

for ii=2:ND
    delta(ordrho(ii))=maxd;
    for jj=1:ii-1
        if(sim(ordrho(ii),ordrho(jj))<delta(ordrho(ii)))
            delta(ordrho(ii))=sim(ordrho(ii),ordrho(jj));
            nneigh(ordrho(ii))=ordrho(jj);
        end
    end
end
delta(ordrho(1))=max(delta(:));

e2=cputime-t2;

for i=1:ND
    ind(i)=i;
    gamma(i)=rho(i)*delta(i);
end

[gamma_sorted,ordgamma]= sort(gamma,'descend');
NCLUST=0;
for i=1:ND
    cl(i)=-1;
end
