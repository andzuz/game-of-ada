package Arrays2D is
   type Array2D is array (Integer range <>, Integer range <>) of Float;
   procedure Initialize_array
     (Array2 : in out Array2D;
      I      : Integer;
      J      : Integer);

   function Get_array_from_file
     (Filename : String;
      I        : Integer;
      J        : Integer)
      return     Array2D;

   procedure Print_array (arr : Array2D; I : Integer; J : Integer);

   procedure write_array_to_file
     (array2   : Array2D;
      Filename : String;
      I        : Integer;
      J        : Integer);
end Arrays2D;
