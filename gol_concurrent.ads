with Ada.Text_IO; use Ada.Text_IO;
with Arrays2D;    use Arrays2D;

package Gol_concurrent is

   MAX_SIZE          : Integer := 4;
   NUMBER_OF_WORKERS : Integer := 2;
   IN_FILENAME       : String  := "matrix.txt";
   OUT_FILENAME      : String  := "matrix_out.txt";

   function Is_Alive (cell : Float) return Boolean;
   function Get_alive_neighbours_count
     (board            : Array2D;
      I                : Integer;
      J                : Integer;
      is_by_left_edge  : Boolean := False;
      is_by_right_edge : Boolean := False)
      return             Integer;
   function Get_updated_cell_state
     (cell_state       : Float;
      alive_neighbours : Integer)
      return             Float;
   function Get_edge_alive_neighbours_count
     (col_num : Integer;
      row_num : Integer)
      return    Integer;

   protected type Shared_board is
      procedure Set (a_board : Array2D);
      procedure Get (a_board : out Array2D);
      function Get_specific_column
        (column  : out Array2D;
         col_num : Integer)
      return Boolean;
   private
      board : Array2D (1 .. MAX_SIZE, 1 .. MAX_SIZE);
   end Shared_board;

   shared_gameboard : Shared_board;

   task type Worker is
      entry fill_board_part
        (board                 : Array2D;
         column_from           : Integer;
         column_to             : Integer;
         current_worker_number : Integer);
      entry process_data;
   end Worker;

   task Supervisor is
      entry on_data_returned
        (data                  : Array2D;
         start_range           : Integer;
         end_range             : Integer;
         current_worker_number : Integer);
   end Supervisor;

end Gol_concurrent;
