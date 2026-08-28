// cla64_flat.v
module cla64_flat(
  input  [63:0] a,
  input  [63:0] b,
  input         cin,
  output [63:0] sum,
  output        cout
);

  wire [63:0] p, g;
  wire [64:1] c;   // c[1]..c[64] are the 64 carries; think of cin as c[0]

  // Step 1: generate/propagate signals
  genvar i;
  generate
    for (i = 0; i < 64; i = i + 1) begin : gen_pg
      xor #(2) (p[i], a[i], b[i]);
      and #(2) (g[i], a[i], b[i]);
    end
  endgenerate

  // Step 2: Direct carry equations c[1] through c[64]
  assign #(2) c[1]  = g[0]  | (p[0] & cin);
  assign #(2) c[2]  = g[1]  | (p[1] & g[0])  | (p[1] & p[0] & cin);
  assign #(2) c[3]  = g[2]  | (p[2] & g[1])  | (p[2] & p[1] & g[0])  | (p[2] & p[1] & p[0] & cin);
  assign #(2) c[4]  = g[3]  | (p[3] & g[2])  | (p[3] & p[2] & g[1])  | (p[3] & p[2] & p[1] & g[0])  | (p[3] & p[2] & p[1] & p[0] & cin);
  assign #(2) c[5]  = g[4]  | (p[4] & g[3])  | (&p[4:3] & g[2])  | (&p[4:2] & g[1])  | (&p[4:1] & g[0])  | (&p[4:0] & cin);
  assign #(2) c[6]  = g[5]  | (p[5] & g[4])  | (&p[5:4] & g[3])  | (&p[5:3] & g[2])  | (&p[5:2] & g[1])  | (&p[5:1] & g[0])  | (&p[5:0] & cin);
  assign #(2) c[7]  = g[6]  | (p[6] & g[5])  | (&p[6:5] & g[4])  | (&p[6:4] & g[3])  | (&p[6:3] & g[2])  | (&p[6:2] & g[1])  | (&p[6:1] & g[0])  | (&p[6:0] & cin);
  assign #(2) c[8]  = g[7]  | (p[7] & g[6])  | (&p[7:6] & g[5])  | (&p[7:5] & g[4])  | (&p[7:4] & g[3])  | (&p[7:3] & g[2])  | (&p[7:2] & g[1])  | (&p[7:1] & g[0])  | (&p[7:0] & cin);
  assign #(2) c[9]  = g[8]  | (p[8] & g[7])  | (&p[8:7] & g[6])  | (&p[8:6] & g[5])  | (&p[8:5] & g[4])  | (&p[8:4] & g[3])  | (&p[8:3] & g[2])  | (&p[8:2] & g[1])  | (&p[8:1] & g[0])  | (&p[8:0] & cin);
  assign #(2) c[10] = g[9]  | (p[9] & g[8])  | (&p[9:8] & g[7])  | (&p[9:7] & g[6])  | (&p[9:6] & g[5])  | (&p[9:5] & g[4])  | (&p[9:4] & g[3])  | (&p[9:3] & g[2])  | (&p[9:2] & g[1])  | (&p[9:1] & g[0])  | (&p[9:0] & cin);
  assign #(2) c[11] = g[10] | (p[10] & g[9]) | (&p[10:9] & g[8]) | (&p[10:8] & g[7]) | (&p[10:7] & g[6]) | (&p[10:6] & g[5]) | (&p[10:5] & g[4]) | (&p[10:4] & g[3]) | (&p[10:3] & g[2]) | (&p[10:2] & g[1]) | (&p[10:1] & g[0]) | (&p[10:0] & cin);
  assign #(2) c[12] = g[11] | (p[11] & g[10])| (&p[11:10] & g[9])| (&p[11:9] & g[8]) | (&p[11:8] & g[7]) | (&p[11:7] & g[6]) | (&p[11:6] & g[5]) | (&p[11:5] & g[4]) | (&p[11:4] & g[3]) | (&p[11:3] & g[2]) | (&p[11:2] & g[1]) | (&p[11:1] & g[0]) | (&p[11:0] & cin);

  // Generates carries 13 through 64 using reduction AND logic
  generate
    for (i = 13; i <= 64; i = i + 1) begin : gen_carries
      // We concatenate all product terms dynamically
      wire [i:0] p_terms;
      assign p_terms[i] = g[i-1];
      for (genvar j = i-2; j >= 0; j = j - 1) begin : gen_terms
        assign p_terms[j+1] = &p[i-1:j+1] & g[j];
      end
      assign p_terms[0] = &p[i-1:0] & cin;
      assign #(2) c[i] = |p_terms;
    end
  endgenerate

  assign cout = c[64];

  // Step 3: sum bits
  assign #(2) sum = p ^ {c[63:1], cin};

endmodule