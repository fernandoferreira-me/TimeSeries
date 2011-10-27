classdef interface_pp < handle
    properties (SetAccess = private) 
        entrada
    end
    
    %methods
    %   function obj=interface_pp(e)
          obj.entrada=e;
       end
    end
    methods (Abstract)
       ppteste(entrada)
       %pp(entrada)
       %ppinv(entrada)
    end
end
    