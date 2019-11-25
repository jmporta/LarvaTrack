function rois=FindGrid2(frame,clean,show)

  if (show)
    figure(10);
    imshow(frame);
    hold on;
  end

  center=[ 90 250 415  90 250 415  90 250 415;
          100 100 100 260 260 260 425 425 425];
  w=85;  
        
  nc=size(center,2);
  
  rois=cell(1,nc);
  for i=1:nc
    cx=center(1,i);
    cy=center(2,i);
    
    [x1,x2]=FindLinesInPatch(cx,cy,w,frame,true,false);
    [y1,y2]=FindLinesInPatch(cx,cy,w,frame,false,false);
   
    if clean
      % We will clean background -> do not worry to include it in the
      % patches
      marginX=5;
      marginY=5;
    else
      marginX=2;
      marginY=2;
    end
      marginX=0;
      marginY=0;
      
    x1=x1-marginX;
    x2=x2+marginX;
    y1=y1-marginY;
    y2=y2+marginY;
    
    roi={ [x1 x1 x2 x2 x1] [y1 y2 y2 y1 y1] };
    
    if show
      rectangle('Position',[x1 y1 x2-x1 y2-y1],'EdgeColor','r','LineWidth',2);
    end
    
    rois{i}=roi;
  end
  
end

function [x1,x2]=FindLinesInPatch(cx,cy,w,frame,vertical,show)

  p=frame(cy+(-w:w),cx+(-w:w));
  if vertical
    BW=im2bw(p);
  else
    BW=im2bw(p');
  end
  
  E=edge(BW,'canny');
  % Detect horizontal lines
  [H,theta,rho] = hough(E,'RhoResolution',2.5,'Theta',-10:0.1:10);
  P = houghpeaks(H,50);
  lines = houghlines(E,theta,rho,P,'MinLength',w*1.5);
  
  if show
    for k = 1:length(lines)
      if vertical
        xy = [[cx-w cy-w]+lines(k).point1; [cx-w cy-w]+lines(k).point2];
        plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','blue');
      else
        xy = [[cy-w cx-w]+lines(k).point1; [cy-w cx-w]+lines(k).point2];
        plot(xy(:,2),xy(:,1),'LineWidth',2,'Color','green');
      end
    end
  end
  
  x1=0;
  x2=inf;
  for k=1:length(lines)
    
    p1=lines(k).point1;
    p2=lines(k).point2;
    
    if p1(1)<w && p2(1)<w
      x1=max([x1,p1(1),p2(1)]);
    else
      x2=min([x2,p1(1),p2(1)]);
    end
  end
    
  if vertical
    x1=x1+(cx-w);
    x2=x2+(cx-w);
  else
    x1=x1+(cy-w);
    x2=x2+(cy-w);
  end
  
end

