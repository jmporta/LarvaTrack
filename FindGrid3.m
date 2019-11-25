function rois=FindGrid3(frame,clean,show)

  if (show)
    figure(10);
    imshow(frame);
    hold on;
  end
  
  roisLines=FindGrid(frame,false,false);
  nc=length(roisLines);
  
  se=strel('disk',1); 
  
  rois=cell(1,nc);
  for i=1:nc
    % Approximation of the arena obtained identifying lines
    roi=roisLines{i};
    % x coordinates
    x=roi{1};
    % y coordinates
    y=roi{2};
    % min-max of the area of interest in X
    min_x=min(x);
    max_x=max(x);
    % min-max of the area of interest in Y
    min_y=min(y);
    max_y=max(y);
    % center of the area of interst in X
    cx=int32((min_x+max_x)/2);
    % center of the area of interst in Y
    cy=int32((min_y+max_y)/2);
    % Width of the area of interet in X and Y
    % We scale since we will fill a small rectangle in the
    % center of the arena with the backgroudn color.
    wx=int32(0.3*(max_x-min_x));
    wy=int32(0.3*(max_y-min_y));
    
    % Sub-image with the arena of interest
    frame1=frame(min_y:max_y,min_x:max_x);
    % background color. We select the mode of the half upper part of
    % the image since in some arenas it is darker
    fh=frame(1:cy);
    bgc=mode(fh(:));
    % The darkest pixel in the image are the eyes of the larva.
    % We have to ensure that the eyes are included in the selecte area.
    black=min(min(frame1));
    [rb,cb]=find(frame1==black,1);
    
    % Shift to select a sub-frame on the input image. This ensures that
    % the selected area is limited to a given window.
    cy=cy-min_y;
    cx=cx-min_x;
    frame1(cy+(-wy:wy),cx+(-wx:wx))=bgc;
    
    % Try to remove the fish from the frame
    rf=regionGrowing(frame1,sub2ind(size(frame1),rb,cb),[black,black+100]);
    frame1(rf>0)=bgc;
    
    % We add a black frame to the selected sub-image 
    frame1(1,:)=0;
    frame1(end,:)=0;
    frame1(:,1)=0;
    frame1(:,end)=0;
    
    % Grow a "white" region from the center of the sub-image with the
    % aim of carefully selecting the arena.
    % We repeate the selection until the area is of the expected size.
    it=1;
    tr=-10;
    sr=100000;
    while sr>23000 && it<10
      r=regionGrowing(frame1,sub2ind(size(frame1),cy,cx),[bgc+tr,255]);
      sr=sum(r(:));
      tr=tr+5;
      it=it+1;
    end
    
    if sr<wx*wy
      % Sometimes when reducing the threshold, the region collapses to null
      r=regionGrowing(frame1,sub2ind(size(frame1),cy,cx),[bgc+tr-10,255]);
    end
    
    % The selected area is a rectangle with possibly some protuberances
    % We try to identify and remove such protuberances. Note that we
    % take care of selecting an area (rows/columns) that, in any case,
    % include the eyes (whose position has been computed above) and
    % a small region around them (+/- 5 pixels)
    [nr,nc]=size(frame1);
    %sr=(sum(r,2)/nc<0.2);
    m=int32(nr/2);
    l=sum(r(m,:)); 
    ndx=find(sum(r,2)>0.7*l);
    sr=false(nr,1);
    sr(1:min(ndx(1),rb-5))=true;
    sr(max(ndx(end),rb+5):nr)=true;
     
    %sc=(sum(r,1)/nr<0.2);
    m=int32(nc/2);
    l=sum(r(:,m)); 
    ndx=find(sum(r,1)>0.7*l);
    sc=false(1,nc);
    sc(1:min(ndx(1),cb)-5)=true;
    sc(max(ndx(end),cb+5):nc)=true;
    
    r(sr,:)=0;
    r(:,sc)=0;
    
    % hull of the selected region
    h=bwconvhull(r);
    
    % erode a bit the selection (may be unnecessary... check it)
    g=imerode(h,se);
    % Identify the edge (the border)
    e=edge(g,'canny');
    
    % the pixels defining the border of the region
    [y,x]=find(e>0);
    
    % Define a polygon with the pixels
    k=boundary(x,y);
    
    % The boundary is define on a sub-image. Change the reference
    % to define in in the input frame
    x=double(min_x)+x(k);
    y=double(min_y)+y(k);
    
    % and define the roi
    if isempty(x)
      rois{i}={};
    else
      roi={ x y };
      
      if show
        plot(x(k),y(k),'r','LineWidth',2);
      end
    end
    rois{i}=roi;
  end
  
end
