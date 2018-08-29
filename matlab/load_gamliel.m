function gamliel_db = load_gamliel (path)

temp = readtable(path,'ReadVariableNames' , 0 , 'TreatAsEmpty',{'NoData'} );
temp.Properties.VariableNames = { 'date'  'rain_rate' };
                                
    gamliel_db.time = datetime(temp.date, 'InputFormat','dd/MM/yyyy HH:mm');
    gamliel_db.rain = double(temp.rain_rate);
end