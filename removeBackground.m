function removeBackground(fname)

  v=VideoReader(fname);
  
  nf=v.Duration*v.FrameRate;
  
  frame=readFrame(v);
  [sx,sy]=size(frame);
  
  frames=uint8(zeros(nf,sx,sy));
  frames(1,:,:)=frame;
  
  cf=2;
  while hasFrame(v)
    frame=readFrame(v);
    frames(cf,:,:)=frame;
    cf=cf+1;
  end
  
  m=max(frames,[],1);
  bg=reshape(m(1,:,:),sx,sy);
  % bgc=median(median(bg));
  
  vout=VideoWriter('clean.avi');
  open(vout);
  v.CurrentTime=0;
  while hasFrame(v)
    frame=readFrame(v);
    cleanFrame=255-(bg-frame);
    cleanFrame=uint8(rescale(cleanFrame,0,255));
    writeVideo(vout,cleanFrame); 
  end
  close(vout);