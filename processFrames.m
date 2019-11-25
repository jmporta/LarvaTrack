function processFrames(folder)

  np=1; % patch number
  foldername=fullfile(folder,['roi_' num2str(np,'%02d')]);
  while isfolder(foldername)
    % Inform
    fprintf('Processing rois: %s\n',foldername);
    fprintf('  Failed frames: ');
    
    ne=0; % Number of error frames
    ns=0;
    
    % results folder
    rfolder=fullfile(foldername,'results');
    if isfolder(rfolder)
      rmdir(rfolder,'s');
    end
    mkdir(rfolder);
    vname=fullfile(rfolder,'output.avi');
    vOut=VideoWriter(vname);
    open(vOut);
    
    % Get the files in the folder
    files=dir(foldername);
    nf=length(files);
    error=true; % set so that the first frame is computed from scratch
    for f=1:nf
      file=files(f).name;
      [~,filename,extension]=fileparts(file);
      if strcmp(extension,'.jpg')
        % A new snapshot
        ns=ns+1;
        
        % Process each file in the folder: binarize, countour, skeleton
        image=imread(fullfile(foldername,file));
        % Images are scaled in 0:255 and the darker pixels are in the
        % larva
        if ~error
          % re-use information from previous patch
          [p1x,p1y,p2x,p2y,p3x,p3y,p4x,p4y,lr,ls,error]=processImage(image,p1x,p1y,lr,ls);
        else
          % Compute from scratch
          [p1x,p1y,p2x,p2y,p3x,p3y,p4x,p4y,lr,ls,error]=processImage(image);
        end
        
        if ~error
          % Display the results
          image=insertShape(image,'Line',[p1x p1y p2x p2y],'Color','r','LineWidth',2);
          image=insertShape(image,'Line',[p2x p2y p3x p3y],'Color','r','LineWidth',2);
          image=insertShape(image,'Line',[p3x p3y p4x p4y],'Color','r','LineWidth',2);
          image=insertShape(image,'Circle',[p1x p1y 3],'Color','g','LineWidth',2);
          
          % Add the frame to the video
          writeVideo(vOut,image);
          
          % Store the image on a separate file
          fname=fullfile(rfolder,[filename '.jpg']);
          imwrite(image,fname,'Quality',100);
        else
          fprintf('%s ',file);
          ne=ne+1;
        end
      end
    end
    close(vOut);
    fprintf('\n  Number of erroneous frames: %u/%u (%.2f%%)\n',ne,ns,ne/ns*100);
    
    % go for the next set of patches, if any
    np=np+1; 
    foldername=fullfile(folder,['roi_' num2str(np,'%02d')]);
  end