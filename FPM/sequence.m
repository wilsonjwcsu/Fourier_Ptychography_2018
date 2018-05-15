function [ seqi,seqj ] = sequence( arraysize )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
seqi = zeros(arraysize,arraysize);  
seqj = zeros(arraysize,arraysize); 
% i(1) = 1+(arraysize-1)/2;
%     j(1) = 1+(arraysize-1)/2;
% seqi(1,1) = i(1)
% seqj(1,1) = j(1)
    for I = 1:arraysize
        for J = 1:arraysize
            %% j counter 
            if J ==1
                j(J) = 1+(arraysize-1)/2-1; 
                seqj(I,J) = j(J);        
            else
            j(J) = j(J-1) +1;        
        if j(J)>arraysize
            j(J) =1;
        end 
    seqj(I,J) = j(J);
            end
            %% i counter 
      if I==1
      i(I) = 1+(arraysize-1)/2-1; 
      seqi(I,J) = i(I);
      else
    i(I) = i(I-1)+1;
    if i(I)>arraysize
            i(I)=1;
    end
    seqi(I,J) = i(I);
        end
        end
        
%     if I>=2
%     i(I) = i(I-1) +1 %tt+(arraysize-1)/2;
%     if i(I)>arraysize
%             ii = 1
%             i(I) =1
%     end
%     end
    end
    
    
end

