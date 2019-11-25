function bg=computeBackground(v)

  v.CurrentTime=0;
  bg=readFrame(v);  
  while hasFrame(v)
    frame=readFrame(v);
    bg=max(bg,frame);
  end
  