`ifndef DEFINE_STATE
`define DEFINE_STATE

typedef enum logic [1:0] {
	R_format, 
	id, 
	sd, 
	beq
} top_control;

typedef enum logic [1:0]{
	R_type, 
	I_type, 
	S_type, 
	SB_type
} reg_control;

`endif
		
