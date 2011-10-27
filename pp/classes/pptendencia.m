classdef pptendencia
    properties
    entrada
    end
    properties (SetAccess = private)
    saida
    end
    methods
        function obj = pptendencia(ent)
          obj.entrada=ent;
        end
        function b=ppteste(ent)
            disp(ent)
        end
    end
end
    
    
    
    