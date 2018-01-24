function [ handles ] = SetParams( handles )
%SETPARAMS Sets default parameters for test data and display data set.
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
%   Cluster parameters may vary by data set. This function sets default
%   values known to work for the test data sets provided. These parameters
%   can be modified by the user in the GUI, but this may affect the clustering result.
%   A small plot showing the loaded data is also plotted allowing the user
%   to visualize the data input.
% Inputs:
%   handles: GUI handles
% Outputs:
% handles: GUI handles updated

switch handles.popDataSet.Value
    case 1 % Chain Link
        IR = 0.030;
        MT = 3;
        handles.checkClass.Value = 1;
        
    case 2 % Gaussian
        IR = 0.01; % 0.01
        MT = 3; % 3
        handles.checkClass.Value = 1;
        
    case 3 % LAQ
        IR = 0.015  ;% or 0.01/5, or 0.02/3 or 0.01/2
        MT = 2;
        handles.checkClass.Value = 0;
        
    otherwise
        IR = 0.1  ;% or 0.01/5, or 0.02/3 or 0.01/2
        MT = 2;
        handles.checkClass.Value = 0;
        
        
end % end switch

handles.editIR.String = IR;
handles.editMT.String = MT;

StatusOutput( handles, 'Checking data ....')
FName = strcat(handles.popDataSet.String(handles.popDataSet.Value),'.csv');
Check = csvread(char(FName),1);
DMin = min(Check);
DMax = max(Check);

%% Plot sketch raw data
if handles.checkClass.Value
    DMin(:,end)=[];
    DMax(:,end)=[];
    Class = Check(:,end);
    Check(:,end)=[];
    
    AvailCols = distinguishable_colors(20);
    PCols = rem(Class+1, 20)+1;
    
    
    switch size(Check,2)
        case 1

        case 2
            axes(handles.axesRaw)
            scatter(Check(:,1), Check(:,2), 1, AvailCols(PCols,:))
            view(2)
            axis tight
        case 3
            axes(handles.axesRaw)
            scatter3(Check(:,1), Check(:,2), Check(:,3), 1, AvailCols(PCols,:))
            view(3)
            axis tight
            
        otherwise

    end
else
    switch size(Check,2)
        case 1

        case 2
            axes(handles.axesRaw)
            scatter(Check(:,1), Check(:,2), 1)
            axis tight
            view(2)
        case 3
            axes(handles.axesRaw)
            scatter3(Check(:,1), Check(:,2), Check(:,3), 1)
            axis tight
            view(3)
        otherwise

    end
    
end
handles.axesRaw.XTickLabel=[];
handles.axesRaw.YTickLabel=[];
handles.axesRaw.ZTickLabel=[];
            
handles.NumData = size(Check,1);
handles.DataMin = DMin;
handles.DataMax = DMax;
T2min = floor(handles.NumData/4);
T2max = floor(handles.NumData/4*3);
handles.textMaxMin.String = sprintf('Min: %.f   Max: %.f', T2min, T2max);

%% set min max T2 values to avoid end condition effects
if str2double(handles.textT2.String)<T2min
    handles.textT2.String = T2min;
elseif str2double(handles.textT2.String)>T2max
    handles.textT2.String = T2max;
end

StatusOutput( handles, 'Ready ....')    
guidata(handles.figure1,handles);

end % end fuction

