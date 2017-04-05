file='D:/Downloads/BJ_Meteorology.h5';
h5disp(file)
tb=table();
tb.date=h5read(file,'/date');
tb.weather=[h5read(file,'/Weather')]';
%%
import NYCTaxi.*
unzipdata('S:\DataBackup\Weather')
%%
