with Ada.Text_IO; use Ada.Text_IO;
with Ada.Float_Text_IO;

package body Arrays2D is

   procedure Initialize_array
     (Array2 : in out Array2D;
      I      : Integer;
      J      : Integer)
   is
   begin
      for X in 1 .. I loop
         for Y in 1 .. J loop
            Array2 (X, Y) := Float (X + Y);
         end loop;
      end loop;
   end Initialize_array;

   procedure Print_array (arr : Array2D; I : Integer; J : Integer) is
   begin
      for X in 1 .. I loop
         for Y in 1 .. J loop
            Put (Integer'Image (Integer (arr (X, Y))));
         end loop;
         Put_Line ("");
      end loop;
   end Print_array;

   function Get_array_from_file
     (Filename : String;
      I        : Integer;
      J        : Integer)
      return     Array2D
   is
      File         : File_Type;
      Result_array : Array2D (1 .. I, 1 .. J);
      Temp_float   : Float;
   begin
      Open (File, In_File, Filename);

      for X in 1 .. I loop
         for Y in 1 .. J loop
            Temp_float          := Float'Value (Get_Line (File));
            Result_array (X, Y) := Temp_float;
         end loop;
      end loop;

      Close (File);
      return Result_array;
   end Get_array_from_file;

   procedure write_array_to_file
     (array2   : Array2D;
      Filename : String;
      I        : Integer;
      J        : Integer)
   is
      File : File_Type;
   begin
      Create (File, Out_File, Filename);

      for X in 1 .. I loop
         for Y in 1 .. J loop
            Put_Line (File, Float'Image (array2 (X, Y)));
         end loop;
      end loop;

      Close (File);
   end write_array_to_file;

end Arrays2D;
