function [ ] = PlotClusters( Clusters, R, MT, PlotAxes, Title, XLabel, YLabel, ZLabel, Graph, Test)
%UNTITLED Plots cluster regions in 2D or 3D
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
%   Plots cluster regions in 2D or 3D, displays error if data is
%   incompatible. Not all data is required for each test type.
% Inputs:
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

NumCols = 24;
if size( Clusters.Centre,2) == 2
    axes(PlotAxes);
    cla
    AvailCols = distinguishable_colors(NumCols+1);
    if Test~=3
        PlotCols = rem(Clusters.Global, NumCols) +1;
    elseif Test ==3
        PlotCols=rem(conncomp(Graph),NumCols)+1;
    end
    
    for idx1 = 1: size(Clusters.Centre,1)
        if Clusters.Count(idx1) > MT
            circles(Clusters.Centre(idx1,1),...
                Clusters.Centre(idx1,2),...
                R,...
                'FaceColor', AvailCols(PlotCols(idx1),:),...
                'LineStyle', 'none',...
                'FaceAlpha', 0.4)
            hold on

        % displays cluster number at cluster centre if required, mainly for troubleshooting
%             text(Clusters.Centre(idx1,1),...
%                 Clusters.Centre(idx1,2),num2str(Clusters.Count(idx1)))
        end
    end
    axis([0 1 0 1])
    view(2)
    
elseif size( Clusters.Centre,2) == 3
    axes(PlotAxes);
    cla
    AvailCols = distinguishable_colors(NumCols+1);
    if Test~=3
        PlotCols = rem(Clusters.Global, NumCols) +1;
    elseif Test ==3
        PlotCols=rem(conncomp(Graph),NumCols)+1;
    end
    [X,Y,Z] = sphere();
    for idx1 = 1: size(Clusters.Centre,1)
        if Clusters.Count(idx1) > MT
            surf(X*R+Clusters.Centre(idx1,1),...
                Y*R+Clusters.Centre(idx1,2),...
                Z*R+Clusters.Centre(idx1,3),...
                'FaceColor', AvailCols(PlotCols(idx1),:),...
                'LineStyle', 'none',...
                'FaceAlpha', 0.3)
            hold on
        end
    end
    axis([0 1 0 1 0 1])
    view(3)
    
else
    text(0.5, 0.5, 'Plot Error not 2 or 3 dimensions', 'HorizontalAlignment', 'center')
    axis([0 1 0 1])
    
end % end plots

title(Title)
xlabel(XLabel)
ylabel(YLabel)
zlabel(ZLabel)

end

