function validation_results= Validate (Model)
%Validate Validate(Model) returns hold-out test validation_results as a table 
Model.validation=NYCTaxi.metrics( Model.testset.Response, ...
                  Model.predict(Model.testset.Predictors) );
validation_results=Model.validation.results;
end
