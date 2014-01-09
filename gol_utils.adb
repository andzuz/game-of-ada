with Arrays2D; use Arrays2D;
with Ada.Text_IO; use Ada.Text_IO;

package body Gol_utils is

  procedure Fill_edges_with_zeros(source_board : Array2D; result_board : out Array2D; result_board_size : Integer) is
  begin
    for I in 1..result_board_size loop
      for J in 1..result_board_size loop
        result_board(I,J) := 0.0;
      end loop;
    end loop;

    for I in 2..result_board_size - 1 loop
      for J in 2..result_board_size - 1 loop
        result_board(I, J) := source_board(I-1, J-1);
      end loop;
    end loop;
  end Fill_edges_with_zeros;

  function Get_alive_neighbours_count(board : Array2D; row : Integer; col : Integer) return Integer is
    alive_count : Integer := 0;
  begin
    for I in row-1..row+1 loop
      for J in col-1..col+1 loop
        if not (I = row and J = col) then
          if board(I,J) = 1.0 then
            alive_count := alive_count + 1;
          end if;
        end if;
      end loop;
    end loop;

    return alive_count;
  end Get_alive_neighbours_count;

  function Get_next_iteration_cell_state(current_cell_state : Float; alive_neighbours : Integer) return Float is
  begin
    if current_cell_state = 0.0 and alive_neighbours = 3 then
      return 1.0;
    elsif current_cell_state = 1.0 and (alive_neighbours = 3 or alive_neighbours = 2) then
      return 1.0;
    else
      return 0.0;
    end if;
  end Get_next_iteration_cell_state;

  procedure Apply_gol_logic_to_board(board : out Array2D; rows : Integer; cols : Integer) is
    neighbours : Integer;
    state : Float;
    result_board : Array2D(1..rows, 1..cols) := (others => (others => 0.0));
  begin
    for I in 2..rows-1 loop
      for J in 2..cols-1 loop
        neighbours := Get_alive_neighbours_count(board, I, J);
        state := Get_next_iteration_cell_state(board(I,J), neighbours);
        result_board(I,J) := state;
      end loop;
    end loop;

    board := result_board;
  end Apply_gol_logic_to_board;

  procedure Write_GOL_board_to_file(arr : Array2D; Filename : String; size : Integer) is
     File : File_Type;
   begin
     Create (File, Out_File, Filename);

     for X in 1 .. size loop
         for Y in 1 .. size loop
            Put (File, Integer'Image (Integer'Val(Integer(arr (X, Y)))));
            Put (File, " ");
         end loop;
         Put (File, ASCII.LF);
      end loop;

     Close (File);
   end Write_GOL_board_to_file;

   function Get_GOL_board_from_file(Filename: String; size : Integer) return Array2D is
     File         : File_Type;
     Char         : Character;
     Result_arr   : Array2D(1..size,1..size);
     I            : Integer := 1;
     J            : Integer := 1;
     str          : String(1..1);
   begin
     Open (File, In_File, Filename);

     while not End_of_file(File) loop
       Get(File, Char);
       if Char /= ASCII.LF and Char /= ASCII.CR and Char /= ' ' then
         str(1) := Char;
         Result_arr(I,J) := Float'Value(str);

         J := J + 1;

         if J > size then
           J := 1;
           I := I + 1;
           exit when I > size;
         end if;
       end if;
     end loop;

     Close (File);

     return Result_arr;
   end Get_GOL_board_from_file;

end Gol_utils;
