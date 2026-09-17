module lfsr #(
    parameter int LFSR_WIDTH = 31,
    parameter int POLYNOMIAL = 31'h04C11DB7,
    parameter bit REVERSE = 1'b1,
    parameter int DATA_WIDTH = 8
) (
    input [DATA_WIDTH-1:0] data_i,
    input [LFSR_WIDTH-1:0] state_i,
    output logic [LFSR_WIDTH-1:0] state_o
);
  typedef logic [DATA_WIDTH+LFSR_WIDTH-1:0] mask_table_t[LFSR_WIDTH];
  typedef logic [DATA_WIDTH+LFSR_WIDTH-1:0] full_mask_table_t[DATA_WIDTH+LFSR_WIDTH];

  function automatic mask_table_t lfsr_mask_gen();
    full_mask_table_t local_table = '{default: '0};

    for (int i = 0; i < DATA_WIDTH + LFSR_WIDTH; i++) begin : mask_init
      local_table[i][i] = 1'b1;
    end

    for (int i = 0; i < DATA_WIDTH; i++) begin : main_gen
      int local_poly = POLYNOMIAL;

      for (int j = 0; j < LFSR_WIDTH - 1; j++) begin : xor_loop
        if ((local_poly >>= 1) & 1) begin
          local_table[j] ^= local_table[LFSR_WIDTH-1];
        end
      end
      // xor new bit
      local_table[DATA_WIDTH+LFSR_WIDTH-1] ^= local_table[LFSR_WIDTH-1];

      // shift state
      for (int j = LFSR_WIDTH - 1; j > 0; j--) begin : shift_state_loop
        local_table[j] = local_table[j-1];
      end
      // shift in new bit
      local_table[0] = local_table[DATA_WIDTH+LFSR_WIDTH-1];
      // shift data
      for (int j = DATA_WIDTH + LFSR_WIDTH - 1; j > LFSR_WIDTH; j--) begin : shift_data_loop
        local_table[j] = local_table[j-1];
      end
    end

    if (REVERSE) begin
      full_mask_table_t temp_table = local_table;

      // reverse state and data in place and then reverse row order
      for (int i = 0; i < LFSR_WIDTH; i++) begin : reverse_loop
        int reversed_i = LFSR_WIDTH - 1 - i;
        local_table[reversed_i] = {
          {<<{temp_table[i][DATA_WIDTH+LFSR_WIDTH-1:LFSR_WIDTH]}},
          {<<{temp_table[i][LFSR_WIDTH-1:0]}}
        };
      end
    end

    return local_table[0:LFSR_WIDTH-1];
  endfunction

  localparam mask_table_t MaskTable = lfsr_mask_gen();

  for (genvar i = 0; i < LFSR_WIDTH; i++) begin : g_state
    assign state_o[i] = ^({data_i, state_i} & MaskTable[i]);
  end
endmodule
