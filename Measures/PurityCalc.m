function [ CP ] = PurityCalc( AD )
%PURITYCALC Calculation of cluster purity
%   Calculates the overall purity of clusters when compared to original
%   class data.
% Inputs:
%   AD: analysis data. 2D array with Cluster information in the last column
%   and original Class information in the 2nd last column.
% Outputs:
%   CP: cluster purity


Cluster = AD(:,end);
Class = AD(:,end-1);
ClusterU = unique(Cluster);
DomTot = 0;
for idxClus = 1:size(ClusterU,1)
    Clus = ClusterU(idxClus);
%      if Clus >0 % do not check outliers
    
        DataClus = Class(Cluster == Clus,:);
        DomNum = 0;
        for idxClass = unique(DataClus)'
            Num =  sum(DataClus == idxClass);
            if Num > DomNum
                DomNum = Num;
            end
        end
        Purity(idxClus) = DomNum / size(DataClus,1);
        DomTot = DomTot + DomNum;
%      end
end
CP = [-9999,ClusterU';DomTot/size(Cluster,1), Purity]; % [Overall Purity, Outlier Purity, Clutser(n) Purity]

end % end function

