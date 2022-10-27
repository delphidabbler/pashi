         
      
// This file has leading and trailing blank lines and reailing spaces    
// It is to be used to test the various modes of the --trim command
destructor TStdInReader.Destroy;   
begin        
  if not TEncoding.IsStandardEncoding(fEncoding) then        
    fEncoding.Free; 
  inherited;      
end;

      

