function processVideo(fname)

 v=VideoReader(fname);
 vOut=VideoWriter('output.avi', 'Uncompressed AVI');
 vOut.FrameRate=v.FrameRate;
 open(vOut);
 
 tf=v.FrameRate*v.Duration;
 
 % while hasFrame(v)
 cf=1;
 while hasFrame(v)
   frame=readFrame(v);
   
   fprintf('Processing frame: %d/%d\n',cf,tf);
   
   frameOut=cat(3,frame,frame,frame);
   
   [r0,c0,p]=FindGrid(frame,false);
   
   for k=1:9
     patch=p{k};
     
     BW=~im2bw(patch);
     
     s=regionprops(BW,'Area','PixelIdxList','MajorAxisLength');
     
     ndx=([s.Area]>125 & [s.Area]<250 & [s.MajorAxisLength]<100);
     
     [m,idx]=max(ndx);
     
     if m>0
       %figure(2);
       %BW2=zeros(size(BW));
       %BW2(s(idx).PixelIdxList)=1;
       %imshow(BW2);
       
       [r,c]=ind2sub(size(BW),s(idx).PixelIdxList);
       o=ones(length(r),1);
       frameOut(sub2ind(size(frameOut),r0(k)+r,c0(k)+c,1*o))=255;
       frameOut(sub2ind(size(frameOut),r0(k)+r,c0(k)+c,2*o))=0;
       frameOut(sub2ind(size(frameOut),r0(k)+r,c0(k)+c,3*o))=0;
     end
   end
   writeVideo(vOut,frameOut);
   
   cf=cf+1;
 end
 close(vOut);
 clear v;
 
