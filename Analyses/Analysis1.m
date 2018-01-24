function [ ] = Analysis1( handles )
%ANALYSIS1 Compares CODAS analysis with Hybrid Analysis
%   Copyright R Hyde 2017
%   Released under the GNU GPLver3.0
%   You should have received a copy of the GNU General Public License
%   along with this program.  If not, see <http://www.gnu.org/licenses/
%   For a detailed description, see:
%   A new algorithm for initialising online and evolving clustering and eliminating start up times
%   R Hyde, R Hossaini, A Leeson, submitted to Data Mining and Knowledge
%   Discovery Jan 2018
% On the seolected data set:
% 1.CODAS is run for the whole dataset, the time at which T2 is reached is
%   noted, together with time to complete analysis to EoF and cluster results
% 2a. DDCAS is run at time T2, and the time to run is noted
% 2b. CODAS is primed with DDCAS results and continued until EoF and the
% time is noted togetehr with results
% 3. Jaccard based imilarity of results if calculated
% 4. Outputs: T2 as %age of data, Siimilarity, DDCAS T2 time, CODAS T2
% time, CODAS total time, Hybrid total time

StatusOutput(handles,'Analysis 1 Started...')
drawnow
%% Run CODAS
StatusOutput(handles,'Running CODAS')
drawnow
% open data file
fName = sprintf('%s.csv',handles.popDataSet.String{handles.popDataSet.Value});
DataIn = csvread(fName,1);
if handles.checkClass.Value
   nCols = size(DataIn,2)-1;
else
    nCols = size(DataIn,2);
end
Data = DataIn(:, 1:nCols);
Data = (Data - handles.DataMin) ./ (handles.DataMax - handles.DataMin); % normalise data 0-1

%% Prepare
IR = str2double(handles.editIR.String); % microC radius
MT = str2double(handles.editMT.String); % Min threshold
T2 = str2double(handles.textT2.String); % read T2
ClustersCODAS=[]; % intialise clusters
NumClusts = 0; % no cluster generated yet
nData = 0; % number of data samples read

tic % start timer
hWB = waitbar(0, 'Running CODAS....');

while nData < handles.NumData && handles.btnGo.Value == 1% until end of file
    % read next sample
    nData = nData + 1;
    Sample = Data(nData,:); % read next line and convert to double
    
    % run CODAS on sample
    [ClustersCODAS, NumClusts] = CODAS2_ver02_Revised( IR, MT, Sample, ClustersCODAS, NumClusts );
    % save CODAS T2 Time
    if nData == T2
        t2CODAS = toc; % save time at T2
    end
    
    if nData/1000 == floor(nData/1000)
        waitbar( nData / handles.NumData)
    end
        
end % end while
tEndCODAS = toc;
close(hWB);


%% Run Hybrid
StatusOutput(handles,'Running Hybrid...')
drawnow

nData = T2;

hWB = waitbar(0, 'Running hybrid (DDCAS)....');
tic
% Run DDCAS
StatusOutput(handles,'Running DDCAS...')
drawnow
[ClustersHybrid, ~]=DDCAS_FixedR(Data(1:T2,:), IR, MT, 0); % run DDCAS and return Clusters
% note DDCAS T2 time
close(hWB)
t2DDCAS = toc;
% Assign outlier data to their own mC for compatibility with CODAS
[a,~]=find(ClustersHybrid.Global==0);
CurrentMax = max(ClustersHybrid.Global);
ClustersHybrid.Global(a)=CurrentMax+1:size(a,1)+CurrentMax;
NumClusts = size (ClustersHybrid.Centre, 1);
StatusOutput(handles,'Running Hybrid CODAS after DDCAS...')
drawnow
hWB = waitbar(0, 'Running hybrid (CODAS)....');
while nData < handles.NumData && handles.btnGo.Value == 1 % until end of file
    % read next sample
    nData = nData + 1;
    Sample = Data(nData, :); % read next line and convert to double
    % run CODAS on sample
    [ClustersHybrid, NumClusts] = CODAS2_ver02_Revised( IR, MT, Sample, ClustersHybrid, NumClusts );
    % save CODAS T2 Time
    
    if nData/1000 == floor(nData/1000)
        waitbar( nData / handles.NumData)
    end
    
end % end while
close(hWB)
tEndHybrid = toc;

if handles.btnGo.Value == 0
    StatusOutput(handles,'User interrupt.')
    return
end

%% Plot Clusters and data
StatusOutput(handles,'Plotting clusters...')
drawnow

PlotClusters(ClustersCODAS, str2double(handles.editIR.String),...
    str2double(handles.editMT.String), handles.axesStdClusters,...
    'Standard Analysis Clusters', 'Normalised X-Data', 'Normalised Y-Data', 'Normalised Z-Data',...
    [], handles.popTestSelect.Value) % plot CODAS mC

PlotClusters(ClustersHybrid, str2double(handles.editIR.String),...
    str2double(handles.editMT.String), handles.axesHybClusters,...
    'Hybrid Analysis Clusters', 'Normalised X-Data', 'Normalised Y-Data', 'Normalised Z-Data',...
    [], handles.popTestSelect.Value) % Plot Hybrid mC
drawnow

StatusOutput(handles,'Plotting data...')
drawnow
[AssignedCODAS] = PlotData(handles, DataIn, ClustersCODAS, IR, MT, handles.axesStdData,...
    'Standard Analysis Clustered Data', 'X-Data', 'Y-Data', 'Z-Data',...
    [], handles.popTestSelect.Value); % Assigned = [Data, Cluster, Class]

[AssignedHybrid] = PlotData(handles, DataIn, ClustersHybrid, IR, MT, handles.axesHybData,...
    'Hybrid Analysis Clustered Data', 'X-Data', 'Y-Data', 'Z-Data',...
    [], handles.popTestSelect.Value); % Assigned = [Data, Cluster, Class]
drawnow

%% Display test results
if handles.checkClass.Value
    StatusOutput(handles,'Calculating purity...')
    [PurityCODAS] = PurityCalc(AssignedCODAS);
    handles.textPurityStd.String = sprintf('%.3f',PurityCODAS(2,PurityCODAS(1,:)==-9999));
    handles.listPurityStd.String = PurityCODAS(2,PurityCODAS(1,:)~=-9999 & PurityCODAS(1,:)~=-1);

    [PurityHyb] = PurityCalc(AssignedHybrid);
    handles.textPurityHyb.String = sprintf('%.3f',PurityHyb(2,PurityHyb(1,:)==-9999));
    handles.listPurityHyb.String = PurityHyb(2,PurityHyb(1,:)~=-9999 & PurityHyb(1,:)~=-1);
else
    handles.textPurityStd.String = sprintf('N/A, No Classes');
    handles.listPurityStd.String = sprintf('N/A, No Classes');
    
    handles.textPurityHyb.String = sprintf('N/A, No Classes');
    handles.listPurityHyb.String = sprintf('N/A, No Classes');
end

StatusOutput(handles,'Calculating Jaccard accuracy...')
if handles.checkClass.Value % if class, then Jaccard CODAS to class
    [JaccardCODAS] = Modified_Jaccard2(AssignedCODAS(AssignedCODAS(:,end-1)~=0,end-1:end)); % pass [class, cluster]
    handles.textJaccardStd.String = sprintf('%.4f',JaccardCODAS);
    [JaccardHybrid] = Modified_Jaccard2(AssignedHybrid(AssignedHybrid(:,end-1)~=0,end-1:end)); % pass [class, cluster]
    handles.textJaccardHyb.String = sprintf('%.4f',JaccardHybrid);
    [JaccardHybStd] = Modified_Jaccard2([AssignedCODAS(AssignedCODAS(:,end-1)~=0,end),...
        AssignedHybrid(AssignedHybrid(:,end-1)~=0,end)]); % pass [class, cluster]
    handles.textJaccardHybStd.String = sprintf('%.4f',JaccardHybStd);
else
    handles.textJaccardStd.String = sprintf('N/A, no classes');
    handles.textJaccardHyb.String = sprintf('N/A, no classes');
    [JaccardHybStd] = Modified_Jaccard2([AssignedCODAS(AssignedCODAS(:,end-1)~=0,end),...
        AssignedHybrid(AssignedCODAS(:,end-1)~=0,end)]); % pass [class, cluster]
    handles.textJaccardHybStd.String = sprintf('%.4f',JaccardHybStd);
end

handles.textStdTime.String = sprintf('T2(CODAS): %.3f\nTotal: %.3f', t2CODAS, tEndCODAS);
handles.textHybridTime.String = sprintf('T2(DDCAS): %.3f\nTotal: %.3f',t2DDCAS, tEndHybrid);

StatusOutput(handles,'Analysis complete!')
StatusOutput(handles,'# # #')

%% Restore controls
set(findall(handles.uipanelSetup, '-property', 'enable'), 'enable', 'on');
end

