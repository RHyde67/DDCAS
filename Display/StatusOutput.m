function [ ] = StatusOutput( handles, NewString )
%STATUSOUTPUT Display current status of the analysis
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
%   Displays a message in the staus window informaingthe user of the
%   current status of the analysis, plots etc.
% Inputs:
%   handles: GUI handles
%   NewString: text to be displayed in the status window
% Outputs:
%   none

if isempty (handles.textStatus.String)
    handles.textStatus.String = cell(5,1);
end

Text = handles.textStatus.String;
Text(1)=[];
Text{end+1} = NewString;
handles.textStatus.String = Text;
drawnow
end

