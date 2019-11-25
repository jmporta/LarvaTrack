function [epy,epx,sk,error]=simplifySkeleton(sk,min_ls,max_ls)

  error=false;
  
  [bpx,bpy]=find(bwmorph(sk,'branchpoints')>0);
  if ~isempty(bpx)
    
    % Disconnet the different branches in the skeleton
    sk(bpx,bpy)=0;
    CC=bwconncomp(sk);
        
    d=cellfun(@length,CC.PixelIdxList);
    
    [~,ndx]=sort(d,'ascend');
    ok=false;
    i=1;
    while ~ok && i<=CC.NumObjects
      % Remove smaller branches
      sk(CC.PixelIdxList{ndx(i)})=0;
      [epy,epx]=find(bwmorph(sk,'endpoints')>0);
      if length(epy)==2
        ok=true;
      else
        i=i+1;
      end
    end
    if ~ok
      error=true;
    else
      ls=length(find(sk>0));
      error=((ls<min_ls/2)||(ls>max_ls));
    end
  else
    % Here we should have a linear skeleton
    [epy,epx]=find(bwmorph(sk,'endpoints')>0);
    
    if length(epy)~=2
      error=true;
    end
  end