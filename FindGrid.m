function rois=FindGrid(frame,clean,show)
  
  if (show)
    figure(10);
    imshow(frame);
    hold on;
  end

  x=FindLines(frame,false,show);
  y=FindLines(frame,true,show);
  
  if show
    rectangle('Position',[x(1) y(1) x(2)-x(1) y(2)-y(1)],'EdgeColor','r','LineWidth',2);
    rectangle('Position',[x(3) y(1) x(4)-x(3) y(2)-y(1)],'EdgeColor','r','LineWidth',2);
    rectangle('Position',[x(5) y(1) x(6)-x(5) y(2)-y(1)],'EdgeColor','r','LineWidth',2);
    
    rectangle('Position',[x(1) y(3) x(2)-x(1) y(4)-y(3)],'EdgeColor','r','LineWidth',2);
    rectangle('Position',[x(3) y(3) x(4)-x(3) y(4)-y(3)],'EdgeColor','r','LineWidth',2);
    rectangle('Position',[x(5) y(3) x(6)-x(5) y(4)-y(3)],'EdgeColor','r','LineWidth',2);
    
    rectangle('Position',[x(1) y(5) x(2)-x(1) y(6)-y(5)],'EdgeColor','r','LineWidth',2);
    rectangle('Position',[x(3) y(5) x(4)-x(3) y(6)-y(5)],'EdgeColor','r','LineWidth',2);
    rectangle('Position',[x(5) y(5) x(6)-x(5) y(6)-y(5)],'EdgeColor','r','LineWidth',2);
  end
  
  rois=cell(1,9);
  rois{1}={ [x(1) x(1) x(2) x(2) x(1)] [y(1) y(2) y(2) y(1) y(1)] };
  rois{2}={ [x(3) x(3) x(4) x(4) x(3)] [y(1) y(2) y(2) y(1) y(1)] };
  rois{3}={ [x(5) x(5) x(6) x(6) x(5)] [y(1) y(2) y(2) y(1) y(1)] };
  
  rois{4}={ [x(1) x(1) x(2) x(2) x(1)] [y(3) y(4) y(4) y(3) y(3)] };
  rois{5}={ [x(3) x(3) x(4) x(4) x(3)] [y(3) y(4) y(4) y(3) y(3)] };
  rois{6}={ [x(5) x(5) x(6) x(6) x(5)] [y(3) y(4) y(4) y(3) y(3)] };
  
  rois{7}={ [x(1) x(1) x(2) x(2) x(1)] [y(5) y(6) y(6) y(5) y(5)] };
  rois{8}={ [x(3) x(3) x(4) x(4) x(3)] [y(5) y(6) y(6) y(5) y(5)] };
  rois{9}={ [x(5) x(5) x(6) x(6) x(5)] [y(5) y(6) y(6) y(5) y(5)] };
  
  
end
  
function x=FindLines(frame,vertical,show)

  if vertical
    BW=im2bw(frame');
  else
    BW=im2bw(frame);
  end
  E=edge(BW,'canny');
  
  % Detect horizontal lines
  [H,theta,rho] = hough(E,'RhoResolution',2.5,'Theta',-10:0.1:10);
  P = houghpeaks(H,75);
  lines = houghlines(E,theta,rho,P);
  
  if show
    for k = 1:length(lines)
      xy = [lines(k).point1; lines(k).point2];
      if vertical
        plot(xy(:,2),xy(:,1),'LineWidth',2,'Color','green');
        
        % Plot beginnings and ends of lines
        plot(xy(1,2),xy(1,1),'x','LineWidth',2,'Color','yellow');
        plot(xy(2,2),xy(2,1),'x','LineWidth',2,'Color','red');
      else
        plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
        
        % Plot beginnings and ends of lines
        plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
        plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
      end
    end
  end
  
  x=[1 511 1 511 1 511];
  for k=1:length(lines)
    
    p1=lines(k).point1;
    p2=lines(k).point2;
    
    if p1(1)<128 && p2(1)<128
      x(1)=max([x(1),p1(1),p2(1)]);
    else
      if p1(1)<256 && p2(1)<256
        x(2)=min([x(2),p1(1),p2(1)]);
        x(3)=max([x(3),p1(1),p2(1)]);
      else
        if  p1(1)<384 && p2(1)<384
          x(4)=min([x(4),p1(1),p2(1)]);
          x(5)=max([x(5),p1(1),p2(1)]);
        else
          x(6)=min([x(6),p1(1),p2(1)]);
        end
      end
    end
  end
  x(1)=max(1,x(1)-5);
  x(2)=(x(2)+x(3))/2-2;
  x(3)=x(2)+4;
  x(4)=(x(4)+x(5))/2-2;
  x(5)=x(4)+4;
  x(6)=min(511,x(6)+5);
  x=int32(x);
end

