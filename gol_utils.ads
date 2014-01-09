with Arrays2D; use Arrays2D;

package Gol_utils is

  procedure Fill_edges_with_zeros(source_board : Array2D; result_board : out Array2D; result_board_size : Integer);
  function Get_alive_neighbours_count(board : Array2D; row : Integer; col : Integer) return Integer;
  function Get_next_iteration_cell_state(current_cell_state : Float; alive_neighbours : Integer) return Float;
  procedure Apply_gol_logic_to_board(board : out Array2D; rows : Integer; cols : Integer);

end Gol_utils;
