function tab2roi
%loads text file 'tab.txt', creates NIfTI image 'tab.nii' with appropriate values 
%Beta Weights	ROI
%-0.0945362	186|PSMG_L|posterior middle temporal gyrus left|1
%-0.0852231	31|AG_L|angular gyrus left|1
%-0.0845473	182|PIns_L|posterior insula left|1
%-0.0843379	184|PSTG_L|posterior superior temporal gyrus left|1
%-0.0801668	35|STG_L|superior temporal gyrus left|1

txtname = 'tab.txt';
roi = 'jhu';

if ~exist('nii_roi_list','file'), error('Please put NiiStat in your Path'); end;
[dat, SNames] = tabreadSub(txtname,false);
numObs = size(dat,1); %number of observations (participants)
if numObs < 1
   error('%s unable to find multiple subjects in %s', mfilename, txtname);
end
[kROI, kROINumbers, ROIIndex] = nii_roi_list(roi, false) ;
if (ROIIndex < 1) || (ROIIndex > size(kROI,1)), fprintf('%s Unknown ROI', mfilename); return; end;

ROIname = deblank(kROI(ROIIndex,:));
hdr = spm_vol ([ROIname '.nii']);
img = spm_read_vols (hdr);
nroi = max(img(:));
rois = zeros(nroi,1);
label = labelSub ([ROIname '.txt']);
for i = 1 : numObs
   val = dat(i,1);
   roi = dat(i,2);
   if (roi > nroi), error('Expected ROI number less than %d', nroi); end;
   fprintf('%g = %d -> %s\n', val, roi, label(roi,:));
   rois(roi) = val;
end
fprintf('Please make sure label numbers and names listed above match\n');
[p,n] = fileparts(txtname);
outname = fullfile(p,[n,'.nii']);
nii_array2roi (rois, [ROIname '.nii'], outname)
%end tab2roi()

function label = labelSub (ROIname)
if ~exist(ROIname,'file'), error('Unable to find %s',ROIname); end;
fid = fopen(ROIname);  % Open file
label=[];
tline = fgetl(fid);
while ischar(tline)
    %disp(tline)
    label=strvcat(label,tline); %#ok<REMFF1>
    tline = fgetl(fid);
end
fclose(fid); 
%end labelSub()

function [num,headerRow,headerCol]  = tabreadSub(tabname, ignoreColumnOne)
%read cells from tab based array. 
fid = fopen(tabname);
headerRow = [];
headerCol = [];
num = [];
row = 0;
startCol = 1;
if ~exist('ignoreColumnOne','var'), ignoreColumnOne = true; end;
if (ignoreColumnOne), startCol = 2; end 
while(1) 
	datline = fgetl(fid); % Get second row (first row of data)
	%if (length(datline)==1), break; end
    if(datline==-1), break; end %end of file
    if datline(1)=='#', continue; end; %skip lines that begin with # (comments)
    dat=textscan(datline,'%s','delimiter','| \t','MultipleDelimsAsOne',1);
    if isempty(headerRow)
        for col = startCol : size(dat{1},1) %excel does not put tabs for empty cells (tabN+1)
            headerRow = [headerRow; dat{1}(col)];
        end
        continue;
    end;
    row = row + 1;
    headerCol = [headerCol; dat{1}(1)];
    for col = startCol : size(dat{1},1) %excel does not put tabs for empty cells (tabN+1)
        try
        num(row, col-startCol+1) = str2double(dat{1}{col}); %#ok<AGROW>
        catch
           error('"%s" is not numeric', dat{1}{col}); 
        end
    end
end %while: for whole file
fclose(fid);
%end tabreadSub()