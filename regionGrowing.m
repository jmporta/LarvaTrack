function r=regionGrowing(image,pixel,t)

  s=size(image);
  
  % Region array. Each entry can be
  %   0   : pixel not considered so far
  %   n>0 : List of pixels in the border of the region ( 
  %  -1   : A pixel already in the region that can not be expanded
  region=zeros(s); % no pixel in the region
  
  % We set up a stack on the region matrix.
  % Init the stack with 'pixel'
  top=pixel; % top of the stack
  region(pixel)=-1; % end of the stack
         
  while (top>=0)
    % pop an element from the stack
    c=top;
    top=region(top);
    
    % Add 'c' to the region
    region(c)=-1;
    
    % Check if neighbour pixels must be included in the region
    for i=-1:1
      for j=-1:1
        [a,b]=ind2sub(s,c);
        a1=a+i;
        b1=b+j;
        if a1>0 && a1<=s(1) && b1>0 && b1<=s(2)
          n=sub2ind(s,a1,b1);
          if region(n)==0 && image(n)>=t(1) && image(n)<=t(2) % abs(image(n)-image(c))<t
            % push an element with the stack
            region(n)=top;
            top=n;
          end
        end
      end
    end
  end
  
  r=(region<0);
  