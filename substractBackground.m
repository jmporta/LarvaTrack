function cleanFrame=substractBackground(frame,bg)
  cleanFrame=255-(bg-frame);
  cleanFrame=uint8(rescale(cleanFrame,0,255));