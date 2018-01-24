function [ ] = Analysis3( handles )
%ANALYSIS3 Carries out comparison of hybrid and online or evolving analysis
%   Copyright R Hyde 2017
%   Released under the GNU GPLver3.0
%   You should have received a copy of the GNU General Public License
%   along with this program.  If not, see <http://www.gnu.org/licenses/
%   For a detailed description, see:
%   A new algorithm for initialising online and evolving clustering and eliminating start up times
%   R Hyde, R Hossaini, A Leeson, submitted to Data Mining and Knowledge
%   Discovery Jan 2018
%   1. Runs CEDAS to T1
%   2. Runs CEDAS to T2
%   3. Runs DDCAS at T1 to initialise CEDAS
%   4. Runs CEDAS initialised with DDCAS from T1 to T2
%   5. Compares hybrid with simple CEDAS


%% Initialize
IR = str2double(handles.editIR.String); % microC radius
MT = str2double(handles.editMT.String); % Min threshold
T2 = str2double(handles.textT2.String); % read T2
Decay = str2double(handles.editDecay.String); % read Decay value

ClustersCEDAS=[];
OutliersCEDAS=[]; % no outliers exist
GraphCEDAS=graph(); % initialise graph variable to pass to CEDAS

ClustersHybrid=[];
OutliersHybrid=[];
GraphHybrid=graph();
% 
% TestTime = 0;

%% Read data
StatusOutput(handles,'Reading data...')
drawnow
fName = sprintf('%s.csv',handles.popDataSet.String{handles.popDataSet.Value});
DataIn = csvread(fName,1,0); % ignore first line in case of headers
Data = DataIn;
if handles.checkClass.Value
    Class = Data(:,end);
    Data = Data (:,1:end-1); % remove class ID
end
% Normalise data 0-1
Data = (Data - handles.DataMin) ./ (handles.DataMax - handles.DataMin); % normalise data 0-1


%% Run CEDAS
StatusOutput(handles,'Running CEDAS to T1....')
drawnow
idxCEDAS = 0;
hWB = waitbar(0, 'Running CEDAS to T1....');
tic
while idxCEDAS<=T2-Decay && handles.btnGo.Value == 1 % 
    % Read data sample and loop
    idxCEDAS = idxCEDAS+1;
    NewSample = Data( idxCEDAS,:);
    [ClustersCEDAS, OutliersCEDAS, GraphCEDAS]=CEDAS(NewSample,IR,ClustersCEDAS,1/Decay,MT,OutliersCEDAS,GraphCEDAS);
    
    if idxCEDAS/100 == floor(idxCEDAS/100)
        waitbar( idxCEDAS / (T2) )
    end
end
tCEDAS = toc; 
close(hWB);


if handles.btnGo.Value == 0
    StatusOutput(handles,'User interrupt.')
    return
end

%% Run DDCAS
StatusOutput(handles,'Running DDCAS at T1....')
drawnow
TestData = Data(idxCEDAS-(1*Decay):idxCEDAS,:);
tic
[ClustersHybrid, ResultsHybrid]=DDCAS_FixedR(TestData,IR,MT,1);
tDDCAS = toc;
[ClustersHybrid, GraphHybrid, OutliersHybrid] = Convert(ClustersHybrid, ResultsHybrid, TestData, IR, MT);


%% Continue CEDAS
StatusOutput(handles,'Running CEDAS to T2....')
drawnow
hWB = waitbar(0, 'Running CEDAS to T2....');
tic
while idxCEDAS<=T2 && handles.btnGo.Value == 1 % 
    % Read data sample and loop
    idxCEDAS = idxCEDAS+1;
    NewSample = Data( idxCEDAS,:);
    [ClustersCEDAS, OutliersCEDAS, GraphCEDAS]=CEDAS(NewSample,IR,ClustersCEDAS,1/Decay,MT,OutliersCEDAS,GraphCEDAS);
    if idxCEDAS/100 == floor(idxCEDAS/100)
        waitbar( idxCEDAS / (T2) )
    end
end
tCEDAS2 = toc;
tCEDASTot = tCEDAS + tCEDAS2;
close(hWB);

%% Run hybrid
idxCEDAS = T2-Decay;
hWB = waitbar(0, 'Running Hybrid to T2....');
tic
while idxCEDAS<=T2 && handles.btnGo.Value == 1 % 
    %% Read data sample and loop
    idxCEDAS = idxCEDAS+1;
    NewSample = Data( idxCEDAS,:);
    [ClustersHybrid, OutliersHybrid, GraphHybrid]=CEDAS(NewSample,IR,ClustersHybrid,1/Decay,MT,OutliersHybrid,GraphHybrid);
    
    if idxCEDAS/100 == floor(idxCEDAS/100)
        waitbar( idxCEDAS / (T2) )
    end
end
tHybrid = toc; 
tHybridTot = tDDCAS + tHybrid;
close(hWB);


if handles.btnGo.Value == 0
    StatusOutput(handles,'User interrupt.')
    return
end

%% Plot results
TestData = DataIn(idxCEDAS-1*Decay:idxCEDAS,:);

Clrs = distinguishable_colors(20);
ClustersCEDAS.Centre = ClustersCEDAS.C;
ClustersCEDAS.Global = ClustersCEDAS.K;
ClustersCEDAS.Count = ClustersCEDAS.T;

PlotClusters(ClustersCEDAS, str2double(handles.editIR.String),...
    str2double(handles.editMT.String), handles.axesStdClusters,...
    'CEDAS Clusters', 'Normalised X-Data', 'Normalised Y-Data', 'Normalised Z-Data',...
    GraphCEDAS, handles.popTestSelect.Value) % Plot CEDAS mC

ClustersHybrid.Centre = ClustersHybrid.C;
ClustersHybrid.Global = ClustersHybrid.K;
ClustersHybrid.Count = ClustersHybrid.T;

PlotClusters(ClustersHybrid, str2double(handles.editIR.String),...
    str2double(handles.editMT.String), handles.axesHybClusters,...
    'Hybrid Clusters', 'Normalised X-Data', 'Normalised Y-Data', 'Normalised Z-Data',...
    GraphHybrid, handles.popTestSelect.Value) % Plot Hybrid mC

[AssignedCEDAS] = PlotData(handles, TestData, ClustersCEDAS, IR, MT, handles.axesStdData,...
    'CEDAS Data', 'X-Data', 'Y-Data', 'Z-Data',...
    GraphCEDAS, handles.popTestSelect.Value); % Assigned = [Data, Class, Cluster]

[AssignedDDCAS] = PlotData(handles, TestData, ClustersHybrid, IR, MT, handles.axesHybData,...
    'Hybrid Data', 'X-Data', 'Y-Data', 'Z-Data',...
    GraphHybrid, handles.popTestSelect.Value); % Assigned = [Data, Class, Cluster]
drawnow

if handles.checkClass.Value % Purity
    StatusOutput(handles,'Calculating purity...')
    [PurityCEDAS] = PurityCalc(AssignedCEDAS);
    handles.textPurityStd.String = sprintf('%.3f',PurityCEDAS(2,PurityCEDAS(1,:)==-9999));
    handles.listPurityStd.String = PurityCEDAS(2,PurityCEDAS(1,:)~=-999 & PurityCEDAS(1,:)~=-1);

    [PurityDDCAS] = PurityCalc(AssignedDDCAS);
    handles.textPurityHyb.String = sprintf('%.3f',PurityDDCAS(2,PurityDDCAS(1,:)==-9999));
    handles.listPurityHyb.String = PurityDDCAS(2,PurityDDCAS(1,:)~=-999 & PurityDDCAS(1,:)~=-1);
else
    handles.textPurityStd.String = sprintf('N/A, No Classes');
    handles.listPurityStd.String = sprintf('N/A, No Classes');
    
    PurityCompare = [AssignedDDCAS(:,end),AssignedCEDAS(:,end)]; % compare assigned clusters
    PurityCompare( any(PurityCompare==-999,2), :) =[]; % don't compare outliers
    [PurityCompare] = PurityCalc(PurityCompare);
    handles.textPurityHyb.String = sprintf('%.3f',PurityCompare(2,PurityCompare(1,:)==-9999));
    handles.listPurityHyb.String = PurityCompare(2,PurityCompare(1,:)~=-999 & PurityCompare(1,:)~=-1);
end

if handles.checkClass.Value % if class, then Jaccard CODAS to class
    [JaccardCEDAS] = Modified_Jaccard2(AssignedCEDAS(:,end-1:end)); % % pass [class, cluster]
    handles.textJaccardStd.String = sprintf('%.4f',JaccardCEDAS);
    [JaccardDDCAS] = Modified_Jaccard2(AssignedDDCAS(:,end-1:end)); % % pass [class, cluster]
    handles.textJaccardHyb.String = sprintf('%.4f',JaccardDDCAS);
    [JaccardCEDASDDCAS] = Modified_Jaccard2([AssignedDDCAS(:,end),AssignedCEDAS(:,end)]); % pass [class, cluster]
    handles.textJaccardHybStd.String = sprintf('%.4f',JaccardCEDASDDCAS);
else
    handles.textJaccardStd.String = sprintf('N/A, no classes');
    handles.textJaccardHyb.String = sprintf('N/A, no classes');
    [JaccardCEDASDDCAS] = Modified_Jaccard2([AssignedCEDAS(:,end), AssignedDDCAS(:,end)]); % % pass [class, cluster]
    handles.textJaccardHybStd.String = sprintf('%.4f',JaccardCEDASDDCAS);
end

handles.textStdTime.String = sprintf('CEDAS T2: %.3f\nCEDAS Total: %.3f',tCEDAS, tCEDASTot);
handles.textHybridTime.String = sprintf('DDCAS: %.3f\nTotal: %.3f',tDDCAS, tHybridTot);

StatusOutput(handles,'Analysis complete!')
StatusOutput(handles,'# # #')

%% Restore controls
set(findall(handles.uipanelSetup, '-property', 'enable'), 'enable', 'on');
end % end funtion

function [ClustersHybrid, GraphHybrid, OutliersHybrid] = Convert(ClustersHybrid, ResultsHybrid, TestData, IR, MT)
C=ClustersHybrid; % Clusters
% Rename fields to match
C.C = C.Centre;
C.L = ones(size(C.C,1),1);
C.T = C.Count;
C = rmfield(C,{'Centre', 'Radius', 'Global', 'Count'});

Dists = pdist2(TestData, C.C);
C.K = sum(Dists<IR/2,1)';

G=graph(); % Graph structure

% To initialise CEDAS with DDCAS results
ClustersHybrid = C;
GraphHybrid = G;
OutliersHybrid = ResultsHybrid(ResultsHybrid(:,end)==0,1:end-1);

end % end Convert Function

