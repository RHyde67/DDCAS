function [ Assigned ] = PlotData( handles, PD, Clusters, R, MT, PlotAxes, Title, XLabel, YLabel, ZLabel, Graph, Test )
%PLOTDATA Plots clustered data in 2D or 3D
%   Copyright R Hyde 2017
%   Released under the GNU GPLver3.0
%   You should have received a copy of the GNU General Public License
%   along with this program.  If not, see <http://www.gnu.org/licenses/
%   DDCAS_Demo is a GUI for carrying out demonstartion analysis of the
%   DDCAS algorithm.
%   For a detailed description, see:
%   A new algorithm for initialising online and evolving clustering and eliminating start up times
%   R Hyde, R Hossaini, A Leeson, submitted to Data Mining and Knowledge
%   Discovery Jan 2018
%   Plots cluster data in 2D or 3D, displays error if data is
%   incompatible. Not all data is required for each test type.
% Inputs:
%   handles: GUI handles
%   PD: PlotData, data to be plotted
%   Clusters: structure containing key micro-cluster information, Centre,
%       Radius, Count (number of members) and Global (macro-cluster
%       membership)
%   R: Cluster radius
%   MT: minimum threshold to be valid cluster, i.e. not noise
%   Plotaxes: Matlab handle to axes in which to display the plot
%   Title: title for plot
%   XLabel: label for x-axis
%   YLabel: label for y-axis
%   ZLabel: label for z-axis, empty if 2D plot
%   Graph: Graph connections to agglomorate micro-clusters into
%       macro-clusters
%   Test: handle for type of analysis being carried out, selects apprpriate
%       method for finding number of macro-clusters
% Outputs:
%   Assigned: Array of all data samples with cluster assignment append. The
%   2nd to last column is the original class and the end column the cluster
%   assignment.

%% Assign Data to mC
StatusOutput(handles,'Assigning data...')
drawnow

if handles.checkClass.Value
    TD = PD(:,1:end-1);
else
    TD = PD;
end
TD = (TD - handles.DataMin) ./ (handles.DataMax - handles.DataMin);
[dist, mC] = pdist2(Clusters.Centre, TD, 'euclidean', 'smallest', 1);

if Test ~=3
    MC = Clusters.Global(mC);
    MC(dist>R) = -1;
    if handles.checkClass.Value == 0
        Assigned = [PD, nan(size(PD,1),1), MC];
    else
        Assigned = [PD, MC];
    end
else
    MC=conncomp(Graph)';
    MC = MC(mC);
    for idx=unique(MC)'
    tc(idx)=sum(MC==idx);
    end
    [~,idx]=find(tc<MT);
    MC(ismember(MC,idx))=-999;
    if handles.checkClass.Value == 0
        Assigned = [PD, nan(size(PD,1),1), MC];
    else
        Assigned = [PD, MC];
    end
end

%% Plot clustered data
StatusOutput(handles,'Generating display...')
drawnow
NumCols = 25;
AvailCols = distinguishable_colors(NumCols);

axes(PlotAxes);
cla
if size(Assigned,2) == 4
    CA = unique(Assigned(:,end)); % find assigned MC
    
    for idx1 = 1:size(CA,1)
        CP = CA(idx1);
        if CP>0
            pCol = rem(CP,NumCols)+1;
            D2P = Assigned(Assigned(:,end)==CP, 1:3);
            if CP == -1
                scatter(D2P(:,1), D2P(:,2),2, [0 0 0], '+')
            else
                scatter(D2P(:,1), D2P(:,2),2, AvailCols(pCol,:), 'o')
            end
            hold on
        end
    end
    Lims = [handles.DataMin;handles.DataMax];
    axis([Lims(:)]')
    view(2)
    
elseif size(Assigned,2) == 5
    CA = unique(Assigned(:,end)); % find assigned MC
    
    for idx1 = 1:size(CA,1)
        CP = CA(idx1);
        pCol = rem(CP,NumCols)+1;
        D2P = Assigned(Assigned(:,end)==CP, 1:3);
        if CP == -1
            scatter3(D2P(:,1), D2P(:,2),D2P(:,3),2, [0 0 0], '+')
        else
            scatter3(D2P(:,1), D2P(:,2),D2P(:,3),2, AvailCols(pCol,:), 'o')
        end
        hold on
    end
    Lims = [handles.DataMin;handles.DataMax];
    axis([Lims(:)]')
    view(3)
end
title(Title)
xlabel(XLabel)
ylabel(YLabel)
zlabel(ZLabel)

end % end fnction
