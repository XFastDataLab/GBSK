function flag=iscontain2( q,front,rear,x )
%这里的q是列向量
flag=0;
for i=front:rear
    if q(i)==x
        flag=1;
        break;
    end
end

end

