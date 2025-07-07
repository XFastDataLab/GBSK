clear 
clc


t1=cputime;

data=xlsread('spiral.xlsx');
ND = size(data,1);
N=ND*(ND-1)/2;

distM=zeros(ND);
for i=1:ND-1
    for j=i+1:ND
        distM(i,j)=norm(data(i,:)-data(j,:));
        distM(j,i)=distM(i,j);
    end
end

e1=cputime-t1;

t2=cputime;

percent=2;
position=round(N*percent/100);
sda=sort((distM(triu(true(size(distM)),1)))');
dc=sda(position);

for i=1:ND
  rho(i)=0;
end

for i=1:ND-1
  for j=i+1:ND
     rho(i)=rho(i)+exp(-(distM(i,j)/dc)^2);
     rho(j)=rho(j)+exp(-(distM(i,j)/dc)^2);
  end
end



maxd=max(max(distM));


[rho_sorted,ordrho]=sort(rho,'descend');
delta(ordrho(1))=-1.;
nneigh(ordrho(1))=0;

for ii=2:ND
   delta(ordrho(ii))=maxd;
   for jj=1:ii-1
     if(distM(ordrho(ii),ordrho(jj))<delta(ordrho(ii)))
        delta(ordrho(ii))=distM(ordrho(ii),ordrho(jj));
        nneigh(ordrho(ii))=ordrho(jj);
     end
   end
end
delta(ordrho(1))=max(delta(:));

e2=cputime-t2;

figure(1)
tt=plot(rho(:),delta(:),'o','MarkerSize',5,'MarkerFaceColor','k','MarkerEdgeColor','k');
title ('Decision Graph','FontSize',15.0)
xlabel ('\rho')
ylabel ('\delta')


rect = getrect(1);
rhomin=rect(1);
deltamin=rect(2);

t3=cputime;


NCLUST=0;
for i=1:ND
  cl(i)=-1;
end

for i=1:ND
  if ( (rho(i)>rhomin) && (delta(i)>deltamin))
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

for i=1:ND
  halo(i)=cl(i);
end

e3=cputime-t3;

cmap=colormap;
for i=1:NCLUST
   ic=int8((i*64.)/(NCLUST*1.));
   figure(1);
   hold on
   plot(rho(icl(i)),delta(icl(i)),'o','MarkerSize',8,'MarkerFaceColor',cmap(ic,:),'MarkerEdgeColor',cmap(ic,:));
end



figure(2);
plot(data(:,1),data(:,2),'o','MarkerSize',2,'MarkerFaceColor','k','MarkerEdgeColor','k');
title ('Spiral','FontSize',20.0)


for i=1:ND
 A(i,1)=0.;
 A(i,2)=0.;
end
for i=1:NCLUST
  nn=0;
  ic=int8((i*64.)/(NCLUST*1.));
  for j=1:ND
    if (halo(j)==i)
      nn=nn+1;
      A(nn,1)=data(j,1);
      A(nn,2)=data(j,2);
    end
  end
  hold on
  plot(A(1:nn,1),A(1:nn,2),'o','MarkerSize',2,'MarkerFaceColor',cmap(ic,:),'MarkerEdgeColor',cmap(ic,:));
  
%   plot(data(icl,1),data(icl,2),'*','MarkerSize',5);
end


(ND*ND-ND)/2
e1
tt=e1+e2+e3