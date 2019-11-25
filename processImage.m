function [p1x,p1y,p2x,p2y,p3x,p3y,p4x,p4y,lr,ls,error]=processImage(image,varargin)
  
  if ~isempty(varargin)
    % Data from a previous image processing. Given here to add som
    % continuity in the analysis.
    pp1x=varargin{1};
    pp1y=varargin{2};
    pp2x=varargin{3};
    pp2y=varargin{4};
    pp3x=varargin{5};
    pp3y=varargin{6};
    pp4x=varargin{7};
    pp4y=varargin{8};
    plr=varargin{9};
    min_lr=plr-25;
    max_lr=plr+25;
    pls=varargin{10};
    min_ls=pls-10;
    max_ls=pls+10;
  else
    min_ls=30;
    max_ls=80;
    min_lr=150;
    max_lr=300;
  end

  % Size of the image
  sz=size(image);
  
  % Find the darkest pixel in the image. It is on the larva!
  l=find(image==min(image(:)));
  
  % Mask to erode / dilate 
  se1=strel('disk',1); 
  se2=strel('disk',2); 

  % We have to select a region with 150 to 250 pixels and with a skeleton
  % of 30 to 80 pixels.
  % We adjust the threshold (+/-2) 
  bgc=0;
  t=200;
  it=0;
  ok=false;
  while ~ok && it<15
    it=it+1;
    
    % Grow a region from the selected pixel. Select only pixels darker than 't`
    r=regionGrowing(image,l(1),[0,t]);
    
    % Number of pixels in the region
    lr=length(find(r>0));
    
    small=(lr<min_lr);
    large=(lr>max_lr);
    
    if ~small && ~large
      % We have a selected region that looks good
      % Check the skeleton
      r2=imfill(r,'holes');
      r3=imdilate(r2,se2);
      
      % Compute the skeleton of the connected component
      sk=bwskel(r3,'MinBranchLength',10);
      
      % Number of points in the skeleton
      ls=length(find(sk>0));

%       if ls<2
%         % A closed larva can turn into a point-> try with the original region
%         sk=bwskel(r,'MinBranchLength',5);
%         [y,x]=find(sk>0);
%         ls=length(y);
%       end
      
      if ls<5
        % Still closed -> try a erosion on the original region
        r4=imopen(r,se1);
        sk=bwskel(r4,'MinBranchLength',10);
        ls=length(find(sk>0));
      end
      
      small=(ls<min_ls);
      large=(ls>max_ls);
    end
    
    if small
      t=t+3;
    else
      if large
        t=t-3;
      else
        ok=true;
      end
    end
    
    if ~ok && it==15 && bgc==0
      % We do not manage to get proper region. Maybe the larva is too
      % close to a dark border. Enlarge the border and re-start the process
      bgc=255;  %white
      image(1:5,:)=bgc;
      image(end-5:end,:)=bgc;
      image(:,1:5)=bgc;
      image(:,end-5:end)=bgc;
      
      l=find(image==min(min(image)));
      t=200;
      it=1;
    end
  end
   
  if ok

    % Determine the extremes of the skeleton
    [epy,epx,sk,error]=simplifySkeleton(sk,min_ls,max_ls);
    
    if ~error
      if length(epx)==2
        
        [b,a]=ind2sub(sz,l);
        
        %rx=epx(1)+(-5:5);
        %ry=epy(1)+(-5:5);
        % a1=mean(mean(image(ry(ry>0 & ry<sz(1)),rx(rx>0 & rx<sz(2)))));
        a1=norm([epx(1) epy(1)]-[a,b]);
        
        %rx=epx(2)+(-5:5);
        %ry=epy(2)+(-5:5);
        % a2=mean(mean(image(ry(ry>0 & ry<sz(1)),rx(rx>0 & rx<sz(2)))));
        a2=norm([epx(2) epy(2)]-[a,b]);
        
        %if  ~isempty(varargin)
        %  if a1<a2
        %    error=(norm([epx(1) epy(1)]-[pp1x pp1y])<7);
        %  else
        %    error=(norm([epx(2) epy(2)]-[pp1x pp1y])<7);
        %  end
        %end
        
        if ~error
          % Points in the skeleton
          [y,x]=find(sk>0);
          % The darkest extreme is the head. Sort the skeleton from it.
          if a1<a2
            [xs,ys]=sortPoints(x,y,epx(1),epy(1));
          else
            [xs,ys]=sortPoints(x,y,epx(2),epy(2));
          end
        end
      else
        %       if isempty(epx)
        %         % The darkest pixel is probably the head
        %         % Get the 'coordinates' of l
        %         [a,b]=ind2sub(sz,l);
        %         % sortPoints starts by the point closer to [a,b]
        %         [xs,ys]=sortPoints(x,y,a,b);
        %       else
        %         error=true;
        %       end
        error=true;
      end
      
      % If we have 2 end-points is fine
      if ~error
        % Define 4 points along the skeleton
        n=uint32(length(xs)/3);
        p1x=xs(1);
        p1y=ys(1);
        p2x=xs(n);
        p2y=ys(n);
        n=uint32(2*length(xs)/3);
        p3x=xs(n);
        p3y=ys(n);
        p4x=xs(end);
        p4y=ys(end);
        
        % Filter out sudden changes in the points
        if ~isempty(varargin) && ...
          (norm([p1x,p1y]-[pp1x,pp1y])>5 || ...
            norm([p2x,p2y]-[pp2x,pp2y])>7 || ...
            norm([p3x,p3y]-[pp3x,pp3y])>9 || ...
            norm([p4x,p4y]-[pp4x,pp4y])>11) 
          error=true;
        end
      end
    end
  else
    error=true;
  end
  
  if error
    % A branched skeleton
    p1x=0; p1y=0; p2x=0; p2y=0; p3x=0; p3y=0; p4x=0; p4y=0; ls=0; lr=0;
  end