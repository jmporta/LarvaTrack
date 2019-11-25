function [xs,ys]=sortPoints(x,y,x1,y1)

  n=length(x);
  
  xs=zeros(n,1);
  ys=zeros(n,1);
  
  dst=sqrt((x1-x).^2+(y1-y).^2);
  [~,k]=min(dst);
  
  xs(1)=x(k);
  ys(1)=y(k);
  
  x(k)=inf;
  y(k)=inf;
  
  for i=2:n
    dst=sqrt((xs(i-1)-x).^2+(ys(i-1)-y).^2);
    [~,k]=min(dst);
    xs(i)=x(k);
    ys(i)=y(k);
    x(k)=inf;
    y(k)=inf;
  end