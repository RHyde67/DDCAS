function [Clusters, NumClusts]=CODAS2_ver02_Revised(InitRad, MinClusSize, NewSample, Clusters, NumClusts)
% R Hyde 17/03/15
% Copyright R Hyde 2014
% Revised version uses the exact same algorithm code but, rather than use
% persistent variables in he function, the variables 'Clusters' and
% 'NumClusts' are passed back to the calling function. They need to be
% passed back to the CODAS function along with each new daat sample. This
% allows for mutliple calls to the same function.

% Released under the GNU GPLver3.0
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/
% If you use this file please acknowledge the author and cite as a
% reference:
% Hyde, R.; Angelov, P., "A New Local Density Based Approach for
% Clustering Online Data in Arbitrary Shapes Clusters," CYBCONF2015
% doi: 10.1109/CYBConf.2015.7175937
% Downloadable from: http://ieeexplore.ieee.org/stamp/stamp.jsp?arnumber=7175937
%
%
% CODAS function to create cluster regions of arbitrary shapes from online
% data streams in multiple dimensions.
% Use: [clusters)=CODAS2_Function_ver02(ClusterParameters, NewSample)
% Inputs:
%   ClusterParameters: [1x2] array of cluster radius and minimum cluster size
%   InitRad: Initial radius for clusters
%   MinClusSize: minimum number of sample required for micro-cluster to be considered
%   NewSample: row vector of new data sample
% Outputs:
%   Clusters: data structure of micro-cluster information
%     Clusters.Centres: centres of microClusters
%     Clusters.Radius: radii of each micro-cluster
%     Clusters.Count: number of samples assigned to each micro-cluster
%     Clusters.Global: cluster number of each micro-cluster
%
% #############
% EXAMPLE of USE
% #############
% Example Code Copy and paste to new script to run the CODAS2 function
%
%     clear
%     clear CODAS2_Function_ver01
%     %% create random chain link data with noise
%     NP=1000; % number of samples per chain link
%     angles = linspace(0,2*pi,NP)';
%     pt1 =[cos(angles),sin(angles),ones(size(angles,1),1)*0];
%     pt1=pt1+rand(size(pt1,1),3)/3;
%     pt2=pt1(:,[1,3,2]);
%     pt2(:,1)=pt2(:,1)+0.75;
%     % Add noise
%     NumNoise=500; % Number of samples of eandom noise to add
%     Noise=(-1+[bsxfun(@times,[3.25,2.25,2.25],rand(NumNoise,3))]);
%     % Combine data
%     Data=[pt1;pt2;Noise];
%     figure(98)
%     scatter3(Data(:,1),Data(:,2),Data(:,3),20,'b'); % plot raw data
%
%     %% ### Run CODAS ###
%     % Initialise
%     InitRad=0.2; % user parameter
%     MinClusSize=10; % user parameter
%     ClusterParameters=[InitRad, MinClusSize];
%     tic
%     for samplenum=1:size(Data)
%     NewSample=Data(samplenum,:);
%     [Clusters]=CODAS2_ver02(ClusterParameters,NewSample);
%     end
%     toc
% 
%     % ### End CODAS structure 'Clusters' contains the data region information ###
%
%     %%
%     %% Analyse data sample for cluster membership
%     %% Find which data region the samples are in and plot
%     NumGClusts=size(unique(Clusters.Global(Clusters.Count>MinClusSize)),1);
%     CoreGClusts=unique(Clusters.Global(Clusters.Count>MinClusSize));
%     Colours=varycolor(NumGClusts+1); % varycolor by Daniel Helmick downlaoded from: http://uk.mathworks.com/matlabcentral/fileexchange/21050-varycolor
%     % Assign data to global Clusters
%     D2C=pdist2(Data,Clusters.Centre); % distances to cluster centres
%     [D2C,NC]=min(D2C,[],2); % min distances & nearest cluster
%     % Colours for each global cluster
%     GC=Clusters.Global(NC);
%     PlotColour=repmat([0 0 0],size(Data,1),1);
%     CGC=zeros(size(GC,1),1);
%     for idx2=1:size(CoreGClusts,1)
%     [idx,~]=find(GC==CoreGClusts(idx2));
%     PlotColour(idx,:)=repmat([Colours(idx2,:)],size(idx,1),1);
%     CGC(idx,:)=idx2;
%     end
% 
%     %% Plot 3D Data
%     AXSz=[min(Data(:,1)) max(Data(:,1)) min(Data(:,2)) max(Data(:,2)) min(Data(:,3)) max(Data(:,3))];
%     figure(99)
%     hold off
%     scatter3(Data(:,1),Data(:,2),Data(:,3),20,PlotColour(:,:),'o')
%     title('CODAS Cluster Results - Stage 02');
%     axis(AXSz);


% % persistent Clusters NumClusts
% InitRad=varargin{1}(1,1);
% MinClusSize=varargin{1}(1,2);
% NewSample=varargin{2};
% Initialise = varargin{5};
% if Initialise
%     Clusters = varargin{3};
%     NumClusts = varargin{4};
% end
ClusterChanged=0;
   
    if NumClusts>0
        sqDistToAll=sum((repmat(NewSample,NumClusts,1)-Clusters.Centre).^2,2); % find square distance to all centres
        DistToAll=sqrt(sqDistToAll); % find distances to all centres
        
        [MinDist,MinDistIdx]=min(DistToAll); % find minimum distance and index of nearest centre
        
        if MinDist<Clusters.Radius(MinDistIdx) % if in cluster add to cluster
            ClusterChanged=MinDistIdx;
            Clusters.Count(MinDistIdx)=Clusters.Count(MinDistIdx)+1; % update Count of samples assigned to cluster
           
            if MinDist>InitRad*0.5 % if outside cluster core
                %% adjust cluster info
                Clusters.Centre(MinDistIdx,:)=((Clusters.Count(MinDistIdx,:)-1)*Clusters.Centre(MinDistIdx,:)+NewSample)./Clusters.Count(MinDistIdx,:); % update cluster centre to mean of samples
            end
            
        else % create new cluster
            NumClusts=NumClusts+1; % add new cluster
            Clusters.Centre(NumClusts,:)=NewSample;
            Clusters.Radius(NumClusts,:)=InitRad;
            Clusters.Count(NumClusts,:)=1;
            Clusters.Global(NumClusts,:)=NumClusts;
%           ClusteredData=[NewSample,NumClusts]; % ## can used to record cluster assignment of data during run if required ##
        end
        
    else
        NumClusts=1; 
        Clusters.Centre(NumClusts,:)=NewSample;
        Clusters.Radius(NumClusts,:)=InitRad;
        Clusters.Count(NumClusts,:)=1;
        Clusters.Global(NumClusts,:)=NumClusts;
        %     ClusteredData=[NewSample,NumClusts]; % ## can be used to record cluster assignment of data during run if required ##
    end

    if ClusterChanged~=0 && Clusters.Count(ClusterChanged)>MinClusSize
        OrigIntersect=find(Clusters.Global==Clusters.Global(ClusterChanged)); % find current intersections
        DistToAll=sqrt(sum((repmat(Clusters.Centre(ClusterChanged,:),NumClusts,1)-Clusters.Centre).^2,2)); % find square distance to all Centres
        DistToAll(Clusters.Count<MinClusSize)=99; % set all small Clusters to far away so not joined

        Rads=(Clusters.Radius)+Clusters.Radius(ClusterChanged)*0.5; % sum the radii of changed cluster and all other Clusters
        [Intersect,~]=find(DistToAll<Rads); % find where cluster centres are closer than sum of radii

        if isequal(Intersect,OrigIntersect)
            % do nothing
        else
         NewIntersect1=[setdiff(Intersect,OrigIntersect)];
         ExIntersect=setdiff(OrigIntersect,[NewIntersect1;Intersect;ClusterChanged]);
            if isempty(NewIntersect1)
            else
                %% Update newly intersected cluster chain
                
                NewGlobal=max(Clusters.Global)+1;
                if ~isempty(NewIntersect1)
                    NewIntersect1=[NewIntersect1;ClusterChanged];
                for idx=1:size(NewIntersect1,1)
                    OldGlobal=Clusters.Global(NewIntersect1(idx)); % find the global cluster of the newly intersected cluster
                    Clusters.Global(Clusters.Global==OldGlobal)=NewGlobal; % update global cluster number for newly intersected cluster chain
                end
                end
            end
                
                %% update separated cluster
                
                if ~isempty(setdiff(ExIntersect,OrigIntersect))
%                     NewGlobal=max(Clusters.global)+1;
%                       Clusters.global(ExIntersect)=NewGlobal;          
                    for idx3=1:size(ExIntersect,1)
                        NewGlobal=max(Clusters.Global)+1;
                        changed=1;
                        Array=ExIntersect(idx3);
                         while changed==1
                            changed=0;
                            ArrayD=pdist2(Clusters.Centre(Array,:),Clusters.Centre(OrigIntersect,:));
                            ArrayR=[repmat(Clusters.Radius(Array)*0.5,1,size(OrigIntersect,1)) + repmat(Clusters.Radius(OrigIntersect)',size(Array,1),1)];
                            [r,c]=find(ArrayR>ArrayD);
                            Array2=OrigIntersect(unique([r;c]));
                            if ~isequal(Array2,Array)
                                Array=[Array2];
                                changed=1;
                            end
                         end
                         Clusters.Global(Array)=NewGlobal;
                    end  
                
                end
                
            
            %% Renumber Clusters
            ClustNums=unique(Clusters.Global);
            NumGClusts=size(ClustNums,1);
            for idx=1:NumGClusts
                Clusters.Global(Clusters.Global==ClustNums(idx))=idx;
            end
            
        end
        
    end
 
    ClustersOut=Clusters;
end % end main function

