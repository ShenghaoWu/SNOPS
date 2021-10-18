function dates = get_file_date(filename,max_ind)
root = './q/';
dates = {};

for i = 1:max_ind
    FileInfo = dir(strcat(root,filename,string(i),'_stats.mat'));
    
    if isempty(FileInfo)
        %dates=[dates;i];
        dates{end+1}=i;
    else 
        %dates=[dates;FileInfo.date];
        dates{end+1} = FileInfo.date;
    end
    if (datetime()-datetime(FileInfo.date))>duration([0,30,0])
        
        strcat('id: ',string(i),'; ',FileInfo.date)
    end
    
end


end