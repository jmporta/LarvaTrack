function varargout = larvaTrack(varargin)
% LARVATRACK MATLAB code for larvaTrack.fig
%      LARVATRACK, by itself, creates a new LARVATRACK or raises the existing
%      singleton*.
%
%      H = LARVATRACK returns the handle to a new LARVATRACK or the handle to
%      the existing singleton*.
%
%      LARVATRACK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LARVATRACK.M with the given input arguments.
%
%      LARVATRACK('Property','Value',...) creates a new LARVATRACK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before larvaTrack_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to larvaTrack_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
  % See also: GUIDE, GUIDATA, GUIHANDLES

  % Edit the above text to modify the response to help larvaTrack
  
  % Last Modified by GUIDE v2.5 16-Oct-2019 15:15:57
  
  % Begin initialization code - DO NOT EDIT
  gui_Singleton = 1;
  gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @larvaTrack_OpeningFcn, ...
    'gui_OutputFcn',  @larvaTrack_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
  if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
  end
  
  if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
  else
    gui_mainfcn(gui_State, varargin{:});
  end
  % End initialization code - DO NOT EDIT
end

% --- Executes just before larvaTrack is made visible.
function larvaTrack_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to larvaTrack (see VARARGIN)

  % Choose default command line output for larvaTrack
  handles.output = hObject;

  set(handles.image,'visible','off');
  set(handles.frames,'visible','off');
  
  % path to the input file
  handles.input_path='';
  
  % The selected ROIs, if any
  handles.nROIs=0;
  handles.ROIs={};
  
  % The video input
  handles.v=0;
  
  % By default we clean backgroud
  set(handles.clean_images,'value',1);
  
  handles=connectAll(handles);
  
  % Update handles structure
  guidata(hObject, handles);
  
  % UIWAIT makes larvaTrack wait for user response (see UIRESUME)
  % uiwait(handles.figure1);

end

% --- Outputs from this function are returned to the command line.
function varargout = larvaTrack_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  % Get default command line output from handles structure
  varargout{1} = handles.output;
end

% --- Executes on button press in select.
function select_Callback(hObject, eventdata, handles)
% hObject    handle to select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles=disconnectAll(handles);
  
  if handles.v==0
    errordlg('Please, select an input video','Error');
  else
    [xi,yi] = getline(handles.image,'closed');
    n=size(xi,1);
    [sy,sx]=size(handles.frame);
    xi=max(xi,ones(n,1));
    xi=min(xi,ones(n,1)*sx);
    yi=max(yi,ones(n,1));
    yi=min(yi,ones(n,1)*sy);
    if ~isempty(xi)
      ndx=find(cellfun(@isempty,handles.ROIs));
      if isempty(ndx)
        handles.ROIs{handles.nROIs+1}={xi,yi};
      else
        handles.ROIs{ndx(1)}={xi,yi};
      end
      handles.nROIs=length(handles.ROIs);
      plotROIs(handles,true);
    end
  end
  
  handles=connectAll(handles);
  guidata(hObjecthandles);

end

% --- Executes on button press in remove.
function remove_Callback(hObject, eventdata, handles)
% hObject    handle to remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  
  handles=disconnectAll(handles);
  
  if handles.v==0
    errordlg('Please, select an input video','Error');
  else
    rect=getrect(handles.image);
    %h=drawrectangle();
    %rect=h.Position;
    %delete(h);

    if ~isempty(rect)
      xl=rect(1);
      yl=rect(2);
      xu=rect(1)+rect(3);
      yu=rect(2)+rect(4);
      deleted=false;
      for i=1:handles.nROIs
        roi=handles.ROIs{i};
        if ~isempty(roi)
          x=roi{1};
          y=roi{2};
          
          x_min=min(x);
          x_max=max(x);
          y_min=min(y);
          y_max=max(y);
          
          if xl<=x_min && x_max<=xu && yl<=y_min && y_max<=yu
            handles.ROIs{i}={};
            deleted=true;
          end
        end
      end
      if deleted
        plotROIs(handles,true);
      end
    end
  end
  
  handles=connectAll(handles);
  guidata(hObject, handles);
end

% --- Executes on button press in quit.
function quit_Callback(hObject, eventdata, handles)
% hObject    handle to quit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  close;
end

% --- Executes on button press in snapshots.
function snapshots_Callback(hObject, eventdata, handles)
% hObject    handle to snapshots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
      
  handles=disconnectAll(handles);
  
  if handles.v==0
    errordlg('Please, select an input video','Error');
  else
    if handles.nROIs==0
      errordlg('Please, define the  ROIs','Error');
    else
      
      folder=uigetdir;
      if folder~=0
        
        cw=get(hObject,'Parent');
        ps=cw.Position;
        fg=uifigure('Position',[ps(1)+ps(3)/2-200 ps(2)+ps(4)/2-53 400 106]);
        ww=uiprogressdlg(fg,'Title','Please Wait','Message','Creating the snapshots...');
        fprintf('Creating the snapshots...\n');
        
        clean=get(handles.clean_images,'value');
        
        if (clean)
          back=computeBackground(handles.v);
        end
        
        vname=get(handles.input_video,'String');
        [~,name,~]=fileparts(vname);
        vfolder=fullfile(folder,name);
        if isfolder(vfolder) || isfile(vfolder)
          fprintf('Cleaning output folder...\n');
          rmdir(vfolder,'s');
        end
          
        [sx,sy]=size(handles.frame);
     
        for i=1:handles.nROIs
          roi=handles.ROIs{i};
          if ~isempty(roi)
            x=roi{1};
            y=roi{2};
            
            x_min=int32(min(x));
            x_max=int32(max(x));
            y_min=int32(min(y));
            y_max=int32(max(y));
            
            mask=poly2mask(x,y,sx,sy);
            
            bg=(mask<1); % pixels out of the patch
            pt=(mask>0); % pixels in the patch
            
            foldername=fullfile(vfolder,['roi_' num2str(i,'%02d')]);
            mkdir(foldername);
            
            text=['Generating snapshots for roi ' num2str(i,'%2d')];
            
            ww.Value = i/handles.nROIs;
            ww.Message = text;
            fprintf('%s\n',text);
            
            handles.v.CurrentTime = 0;
            cf=1;
            while hasFrame(handles.v)
                frame=readFrame(handles.v);
                if clean
                  cleanFrame=substractBackground(frame,back);
                else
                  cleanFrame=frame;
                end
                c=mode(cleanFrame(pt)); % mode color in the patch
                cleanFrame(bg)=c; % remove background
                patch=cleanFrame(y_min:y_max,x_min:x_max);
                nPatch=uint8(rescale(patch,0,255)); % normalized patch
                fname=fullfile(foldername,['frame_' num2str(cf,'%03d') '.jpg']);
                imwrite(nPatch,fname,'Quality',100);
                cf=cf+1;
            end
          end
        end
        close(ww);
        close(fg);
      end
    end
  end
  
  handles=connectAll(handles);
  
end


function input_video_Callback(hObject, eventdata, handles)
% hObject    handle to input_video (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_video as text
%        str2double(get(hObject,'String')) returns contents of input_video as a double


end

% --- Executes during object creation, after setting all properties.
function input_video_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_video (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end
end

% --- Executes on button press in select_input.
function select_input_Callback(hObject, eventdata, handles)
% hObject    handle to select_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles=disconnectAll(handles);
  [file,path]=uigetfile('*.avi');
  if (file~=0)
    handles.input_path=path;
    set(handles.input_video,'String',file);
    handles.v=VideoReader(fullfile(path,file));
    handles.frame=readFrame(handles.v);
     
    % Check if we have a roi file associated with the video
    [~,filename,~]=fileparts(file);
    
    froi=fullfile(path,[filename '_roi.mat']);
   
    if isfile(froi)
      F=load(froi);
      ndx=find(~cellfun(@isempty,F.rois),1);
      if isempty(ndx)
        recompute=true;
      else
        handles.ROIs=F.rois;
        handles.nROIs=length(handles.ROIs);
        plotROIs(handles,false);
        recompute=false;
      end
    else
      recompute=true;
    end
    
    if recompute
      clean=get(handles.clean_images,'value');
    
      handles.ROIs=FindGrid3(handles.frame,clean,false);
      handles.nROIs=length(handles.ROIs);  
      plotROIs(handles,true);
    end
    
    set(handles.frames,'visible','on');
    set(handles.frames,'value',0);
    
  end
  handles=connectAll(handles);
  
  guidata(hObject,handles);
end

% --- Executes on slider movement.
function frames_Callback(hObject, eventdata, handles)
% hObject    handle to frames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

  if handles.v~=0
    val=get(handles.frames,'Value');
    
    t=val*handles.v.Duration;
    if t>handles.v.Duration
      t=handles.v.Duration;
    end
    handles.v.CurrentTime=t;
    % read frome somtimes generates errors without much sense
    % (no more frames when frames must be available). Catch the error
    % to cancel it.
    try
      handles.frame=readFrame(handles.v);
    catch ME
    end
     
    plotROIs(handles,false);
    guidata(hObject,handles);
  end
end

% --- Executes during object creation, after setting all properties.
function frames_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
  if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
  end
end


% --- Executes on button press in process.
function process_Callback(hObject, eventdata, handles)
% hObject    handle to process (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  
  handles=disconnectAll(handles);
    
  folder=uigetdir;
  if folder~=0
    
    [~,idname,~]=fileparts(folder);
    colNames={'t','p1_x','p1_y','p2_x','p2_y','p3_x','p3_y','p4_x','p4_y','alpha','beta','gamma'};
    
    cw=get(hObject,'Parent');
    ps=cw.Position;
    fg=uifigure('Position',[ps(1)+ps(3)/2-200 ps(2)+ps(4)/2-53 400 106]);
      
    np=1; % patch number
    foldername=fullfile(folder,['roi_' num2str(np,'%02d')]);
    while isfolder(foldername)
      % Inform
      fprintf('Processing rois in folder %s\n',foldername);
      fprintf('  Failed frames: ');
      
      ne=0; % Number of error frames
      ns=0;
      
      % results folder
      rfolder=fullfile(foldername,'results');
      if isfolder(rfolder)
        rmdir(rfolder,'s');
      end
      mkdir(rfolder);
      
      ww=uiprogressdlg(fg,'Title','Please Wait','Message',['Processing files in roi_' num2str(np,'%02d')]);      
      
      % Get the files in the folder
      files=dir(foldername);
      nf=length(files);
      error=true; % set so that the first frame is computed from scratch
      
      ok=false(nf,1);
      data=nan(nf,12);

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
            [p1x,p1y,p2x,p2y,p3x,p3y,p4x,p4y,lr,ls,error]=processImage(image,p1x,p1y,p2x,p2y,p3x,p3y,p4x,p4y,lr,ls);
          else
            % Compute from scratch
            [p1x,p1y,p2x,p2y,p3x,p3y,p4x,p4y,lr,ls,error]=processImage(image);
          end
          
          if ~error
            % Save the data
            ok(f)=true;
            alpha=angdiff(atan2(p3y-p2y,p3x-p2x),atan2(p2y-p1y,p2x-p1x))*(180/pi);
            beta =angdiff(atan2(p4y-p3y,p4x-p3x),atan2(p3y-p2y,p3x-p2x))*(180/pi);
            gamma=alpha+beta;
            data(f,:)=[ns p1x,p1y,p2x,p2y,p3x,p3y,p4x,p4y alpha beta gamma];
          else
            % inform that we had troubles processing this frame
            fprintf('%s ',file);
            ne=ne+1;
          end
          
          ww.Value=f/nf;
        end
      end
      
      % Here we can further filter the computed data (global consistency)
      % For instance, we discart results not similar to
      % previous/posterior frames.
      for i=[2,3,8,9]
        m=movmean(data(:,i),10,'omitnan'); % consider 5 frames
        ok=ok&(abs(data(:,i)-m)<10); % do not allow changes of more than 7 pixels;
      end
%       for i=10:11
%         m=movmean(data(:,i),5,'omitnan'); % consider 5 frames
%         ok=ok&(abs(data(:,i)-m)<10); % do not allow changes of more than 10 degrees;
%       end
      
      ng=sum(~ok)-ne;
      fprintf('\n  Number of frames removed at global check: %u\n',ng);
      
      % Update the number of
      ne=ng+ne;
      
      fprintf('  Saving frames and video\n');
      % Save the tagged images and the output video
      vname=fullfile(rfolder,[idname '_video.avi']);
      vOut=VideoWriter(vname);
      vOut.Quality=100;
      open(vOut);
      for f=1:nf
        if ok(f)
          file=files(f).name;
          image=imread(fullfile(foldername,file));
          [~,filename,~]=fileparts(file);
          p1x=data(f,2);
          p1y=data(f,3);
          p2x=data(f,4);
          p2y=data(f,5);
          p3x=data(f,6);
          p3y=data(f,7);
          p4x=data(f,8);
          p4y=data(f,9);
          
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
        end
      end
      close(vOut); % close the output video
      fprintf('  Number of problematic frames: %u/%u (%.2f%%)\n\n',ne,ns,ne/ns*100);
      
      % Save the array of data
      T=array2table(data(ok,:),'VariableNames',colNames);
      writetable(T,fullfile(rfolder,[idname '_results.xlsx']));
      
      close(ww); % close the information window
      
      % go for the next set of patches, if any
      np=np+1;
      foldername=fullfile(folder,['roi_' num2str(np,'%02d')]);
    end
    
    close(fg);
  end
  
  handles=connectAll(handles);
end


function plotROIs(handles,saveROIs)
  if handles.v==0
    errordlg('Please, select an input video','Error');
  else
    % Plot the current set of ROIs
    imshow(handles.frame,'Parent',handles.image);
    [sx,sy]=size(handles.frame);
    for i=1:handles.nROIs
      roi=handles.ROIs{i};
      if ~isempty(roi)
        x=roi{1};
        y=roi{2};
        line(x,y,'color','r','LineWidth',2);
        xm=min(x)+10;
        ym=min(y)+20;
        if xm<sx-20 && 0<ym && ym<sy
          text(xm,ym,num2str(i),'Color','r','FontSize',20,'Parent',handles.image,'clipping','on');
        end
      end
    end
    
    if saveROIs
      % Save the given ROIs to a file
      % Check if we have a roi file associated with the video
      file=get(handles.input_video,'String');
      [~,filename,~]=fileparts(file);
      
      froi=fullfile(handles.input_path,[filename '_roi.mat']);
      
      rois=handles.ROIs;
      save(froi,'rois');
    end
  end
end  


% --- Executes on button press in save_rois.
function save_rois_Callback(hObject, eventdata, handles)
% hObject    handle to save_rois (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  if handles.v==0
    errordlg('Please, select an input video','Error');
  else
    if handles.nROIs==0
      errordlg('No ROIs is defined','Error');
    else
      [fname,path]=uiputfile('*_roi.mat');
      if (fname~=0)
        rois=handles.ROIs;
        ff=fullfile(path,fname);
        fprintf('Saving ROIs to %s\n',ff);
        save(ff,'rois');
      end
    end
  end
end

% --- Executes on button press in load_rois.
function load_rois_Callback(hObject, eventdata, handles)
% hObject    handle to load_rois (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  [file,path]=uigetfile('*_roi.mat');
  if file~=0
    ff=fullfile(path,file);
    fprintf('Loading ROIs from %s\n',ff);
    F=load(ff);
    handles.ROIs=F.rois;
    handles.nROIs=length(handles.ROIs);
    plotROIs(handles,true);
    guidata(hObject,handles);
  end
end


% --- Executes on button press in clean_images.
function clean_images_Callback(hObject, eventdata, handles)
% hObject    handle to clean_images (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of clean_images

  if handles.v~=0
    clean=get(handles.clean_images,'value');
    
    handles.ROIs=FindGrid3(handles.frame,clean,false);
    handles.nROIs=length(handles.ROIs);
    
    plotROIs(handles,true);
  end

end

function handles=disconnectAll(handles)

  set(handles.select_input,'Enable','off');
  set(handles.select,'Enable','off');
  set(handles.remove,'Enable','off');
  set(handles.save_rois,'Enable','off');
  set(handles.load_rois,'Enable','off');
  set(handles.snapshots,'Enable','off');
  set(handles.process,'Enable','off');
  set(handles.quit,'Enable','off');
  set(handles.frames,'Enable','off');
  set(handles.clean_images,'Enable','off');
  
end


function handles=connectAll(handles)

  set(handles.select_input,'Enable','on');
  set(handles.select,'Enable','on');
  set(handles.remove,'Enable','on');
  set(handles.save_rois,'Enable','on');
  set(handles.load_rois,'Enable','on');
  set(handles.snapshots,'Enable','on');
  set(handles.process,'Enable','on');
  set(handles.quit,'Enable','on');
  set(handles.frames,'Enable','on');
  set(handles.clean_images,'Enable','on');
  
end
