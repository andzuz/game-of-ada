with Arrays2D; use Arrays2D;

-- pakiet przechowujacy logike gry w zycie
package Gol_logic is

   -- funkcja do wydobywania kolumny o danym numerze z tablicy
   procedure Get_specific_column
     (board   : Array2D;
      column  : out Array2D;
      col_num : Integer);

   -- funkcja sluzy do rozsadzania czy dana komorka zyje
   function Is_Alive (cell : Float) return Boolean;

   -- funkcja zwraca ilosc zywych sasiadow komorki (I,J)
   function Get_alive_neighbours_count
     (whole_board      : Array2D;
      worker_number    : Integer;
      board            : Array2D;
      I                : Integer;
      J                : Integer;
      is_by_left_edge  : Boolean := False;
      is_by_right_edge : Boolean := False)
      return             Integer;

   -- funkcja realizjaca logike gry w zycie 23/3
   function Get_updated_cell_state
     (cell_state       : Float;
      alive_neighbours : Integer)
      return             Float;

   -- funkcja sluzaca do synchronizacji miedzy workerami dla kolumn brzegowych
   function Get_edge_alive_neighbours_count
     (whole_board : Array2D;
      col_num     : Integer;
      row_num     : Integer)
      return        Integer;

end Gol_logic;
