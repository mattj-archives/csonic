unit res;
interface
uses common, res_enum;
const
	SPRITE_AFSPIKE = 1;
	SPRITE_BACK1 = 2;
	SPRITE_BOX_BUB = 3;
	SPRITE_BOX_FIR = 4;
	SPRITE_BOX_RNG = 5;
	SPRITE_BOX_SHI = 6;
	SPRITE_BOX_SPI = 7;
	SPRITE_BOX_ST = 8;
	SPRITE_BPLAT = 9;
	SPRITE_CFP = 10;
	SPRITE_CHILI1 = 11;
	SPRITE_CHILI2 = 12;
	SPRITE_CHILI3 = 13;
	SPRITE_CHILI4 = 14;
	SPRITE_CHILI5 = 15;
	SPRITE_CHILI6 = 16;
	SPRITE_E1 = 17;
	SPRITE_E2 = 18;
	SPRITE_E3 = 19;
	SPRITE_E4 = 20;
	SPRITE_E5 = 21;
	SPRITE_EL1 = 22;
	SPRITE_EL2 = 23;
	SPRITE_EL3 = 24;
	SPRITE_ELL = 25;
	SPRITE_ELR = 26;
	SPRITE_FSPIKE = 27;
	SPRITE_GAMBLE = 28;
	SPRITE_LAVA1 = 29;
	SPRITE_LAVA2 = 30;
	SPRITE_LAVA3 = 31;
	SPRITE_LDN = 32;
	SPRITE_LFLIP1 = 33;
	SPRITE_LFLIP2 = 34;
	SPRITE_LHOR = 35;
	SPRITE_LLT = 36;
	SPRITE_LRT = 37;
	SPRITE_LUP = 38;
	SPRITE_LVER = 39;
	SPRITE_MOSQU1 = 40;
	SPRITE_MOSQU2 = 41;
	SPRITE_MOSQU3 = 42;
	SPRITE_MOSQU4 = 43;
	SPRITE_MPGHOST = 44;
	SPRITE_MPL = 45;
	SPRITE_MPLAT = 46;
	SPRITE_MPR = 47;
	SPRITE_P1 = 48;
	SPRITE_PASSER1 = 49;
	SPRITE_PASSER2 = 50;
	SPRITE_PASSER3 = 51;
	SPRITE_PASSER4 = 52;
	SPRITE_RB1_1 = 53;
	SPRITE_RB1_2 = 54;
	SPRITE_RFLIP1 = 55;
	SPRITE_RFLIP2 = 56;
	SPRITE_RING1 = 57;
	SPRITE_RING2 = 58;
	SPRITE_RING3 = 59;
	SPRITE_RING4 = 60;
	SPRITE_RING5 = 61;
	SPRITE_RING6 = 62;
	SPRITE_RM1 = 63;
	SPRITE_RM2 = 64;
	SPRITE_RM3 = 65;
	SPRITE_SDIE = 66;
	SPRITE_SL1 = 67;
	SPRITE_SL2 = 68;
	SPRITE_SLS = 69;
	SPRITE_SPIKEBL = 70;
	SPRITE_SPIKEDN = 71;
	SPRITE_SPIKELT = 72;
	SPRITE_SPIKERT = 73;
	SPRITE_SPIKEUP = 74;
	SPRITE_SPIN1 = 75;
	SPRITE_SPIN2 = 76;
	SPRITE_SPRINGL1 = 77;
	SPRITE_SPRINGL2 = 78;
	SPRITE_SPRINGR1 = 79;
	SPRITE_SPRINGR2 = 80;
	SPRITE_SR1 = 81;
	SPRITE_SR2 = 82;
	SPRITE_SRS = 83;
	SPRITE_SWAIT1 = 84;
	SPRITE_SWAIT2 = 85;
	SPRITE_T0 = 86;
	SPRITE_T1 = 87;
	SPRITE_T10 = 88;
	SPRITE_T2 = 89;
	SPRITE_WFP = 90;
const
sprite_states: array[0..37] of TSpriteState = (
	(sprites: (0, 0)),
	(sprites: (SPRITE_SL1, SPRITE_SR1)),
	(sprites: (SPRITE_SL2, SPRITE_SR2)),
	(sprites: (SPRITE_SLS, SPRITE_SRS)),
	(sprites: (SPRITE_SWAIT1, SPRITE_SWAIT1)),
	(sprites: (SPRITE_SWAIT2, SPRITE_SWAIT2)),
	(sprites: (SPRITE_SPIN1, SPRITE_SPIN1)),
	(sprites: (SPRITE_SPIN2, SPRITE_SPIN2)),
	(sprites: (SPRITE_E1, SPRITE_E1)),
	(sprites: (SPRITE_E2, SPRITE_E2)),
	(sprites: (SPRITE_E3, SPRITE_E3)),
	(sprites: (SPRITE_E4, SPRITE_E4)),
	(sprites: (SPRITE_E5, SPRITE_E5)),
	(sprites: (SPRITE_CHILI1, SPRITE_CHILI1)),
	(sprites: (SPRITE_CHILI2, SPRITE_CHILI2)),
	(sprites: (SPRITE_CHILI3, SPRITE_CHILI3)),
	(sprites: (SPRITE_CHILI4, SPRITE_CHILI4)),
	(sprites: (SPRITE_CHILI5, SPRITE_CHILI5)),
	(sprites: (SPRITE_CHILI6, SPRITE_CHILI6)),
	(sprites: (SPRITE_MOSQU1, SPRITE_MOSQU2)),
	(sprites: (SPRITE_MOSQU3, SPRITE_MOSQU3)),
	(sprites: (SPRITE_MOSQU4, SPRITE_MOSQU4)),
	(sprites: (SPRITE_RM1, SPRITE_RM1)),
	(sprites: (SPRITE_RM3, SPRITE_RM2)),
	(sprites: (SPRITE_P1, SPRITE_P1)),
	(sprites: (SPRITE_BOX_RNG, SPRITE_BOX_RNG)),
	(sprites: (SPRITE_BOX_ST, SPRITE_BOX_ST)),
	(sprites: (SPRITE_SPRINGL1, SPRITE_SPRINGL1)),
	(sprites: (SPRITE_SPRINGL2, SPRITE_SPRINGL2)),
	(sprites: (SPRITE_SPRINGR1, SPRITE_SPRINGR1)),
	(sprites: (SPRITE_SPRINGR2, SPRITE_SPRINGR2)),
	(sprites: (SPRITE_MPLAT, SPRITE_MPLAT)),
	(sprites: (SPRITE_RING1, SPRITE_RING1)),
	(sprites: (SPRITE_RING2, SPRITE_RING2)),
	(sprites: (SPRITE_RING3, SPRITE_RING3)),
	(sprites: (SPRITE_RING4, SPRITE_RING4)),
	(sprites: (SPRITE_RING5, SPRITE_RING5)),
	(sprites: (SPRITE_RING6, SPRITE_RING6))
);
entity_states: array[0..47] of TEntityState = (
	{ STATE_NONE }
	(duration: 60; nextState: STATE_NONE; spriteState: SPRITE_STATE_NONE; func: 0),
	{ STATE_PLAYER_RUN1 }
	(duration: 2; nextState: STATE_PLAYER_RUN2; spriteState: SPRITE_STATE_PLAYER_RUN1; func: 0),
	{ STATE_PLAYER_RUN2 }
	(duration: 2; nextState: STATE_PLAYER_RUN1; spriteState: SPRITE_STATE_PLAYER_RUN2; func: 0),
	{ STATE_PLAYER_STAND1 }
	(duration: 30; nextState: STATE_PLAYER_STAND1; spriteState: SPRITE_STATE_PLAYER_STAND; func: 0),
	{ STATE_PLAYER_WAIT1 }
	(duration: 6; nextState: STATE_PLAYER_WAIT2; spriteState: SPRITE_STATE_PLAYER_WAIT0; func: 0),
	{ STATE_PLAYER_WAIT2 }
	(duration: 6; nextState: STATE_PLAYER_WAIT1; spriteState: SPRITE_STATE_PLAYER_WAIT1; func: 0),
	{ STATE_PLAYER_SPIN1 }
	(duration: 2; nextState: STATE_PLAYER_SPIN2; spriteState: SPRITE_STATE_PLAYER_SPIN1; func: 0),
	{ STATE_PLAYER_SPIN2 }
	(duration: 2; nextState: STATE_PLAYER_SPIN1; spriteState: SPRITE_STATE_PLAYER_SPIN2; func: 0),
	{ STATE_EXPLODE1 }
	(duration: 4; nextState: STATE_EXPLODE2; spriteState: SPRITE_STATE_EXPLODE5; func: 0),
	{ STATE_EXPLODE2 }
	(duration: 4; nextState: STATE_EXPLODE3; spriteState: SPRITE_STATE_EXPLODE4; func: 0),
	{ STATE_EXPLODE3 }
	(duration: 4; nextState: STATE_EXPLODE4; spriteState: SPRITE_STATE_EXPLODE3; func: 0),
	{ STATE_EXPLODE4 }
	(duration: 4; nextState: STATE_EXPLODE5; spriteState: SPRITE_STATE_EXPLODE2; func: 0),
	{ STATE_EXPLODE5 }
	(duration: 4; nextState: STATE_EXPLODE1; spriteState: SPRITE_STATE_EXPLODE1; func: 999),
	{ STATE_BOX_RING1 }
	(duration: 20; nextState: STATE_BOX_RING2; spriteState: SPRITE_STATE_BOX_RING; func: 0),
	{ STATE_BOX_RING2 }
	(duration: 4; nextState: STATE_BOX_RING1; spriteState: SPRITE_STATE_BOX_STATIC; func: 0),
	{ STATE_BPOT_IDLE }
	(duration: 1; nextState: STATE_BPOT1; spriteState: SPRITE_STATE_BPOT1; func: 0),
	{ STATE_BPOT1 }
	(duration: 10; nextState: STATE_BPOT2; spriteState: SPRITE_STATE_BPOT1; func: 1),
	{ STATE_BPOT2 }
	(duration: 10; nextState: STATE_BPOT3; spriteState: SPRITE_STATE_BPOT1; func: 1),
	{ STATE_BPOT3 }
	(duration: 10; nextState: STATE_BPOT4; spriteState: SPRITE_STATE_BPOT1; func: 1),
	{ STATE_BPOT4 }
	(duration: 10; nextState: STATE_BPOT5; spriteState: SPRITE_STATE_BPOT1; func: 2),
	{ STATE_BPOT5 }
	(duration: 10; nextState: STATE_BPOT6; spriteState: SPRITE_STATE_BPOT1; func: 2),
	{ STATE_BPOT6 }
	(duration: 10; nextState: STATE_BPOT1; spriteState: SPRITE_STATE_BPOT1; func: 2),
	{ STATE_MOSQU_IDLE }
	(duration: 1; nextState: STATE_MOSQU_PATROL; spriteState: SPRITE_STATE_MOSQU_NORMAL; func: 0),
	{ STATE_MOSQU_PATROL }
	(duration: 10; nextState: STATE_MOSQU_PATROL; spriteState: SPRITE_STATE_MOSQU_NORMAL; func: 3),
	{ STATE_MOSQU_ATTACK1 }
	(duration: 10; nextState: STATE_MOSQU_ATTACK2; spriteState: SPRITE_STATE_MOSQU_ATTACK1; func: 0),
	{ STATE_MOSQU_ATTACK2 }
	(duration: 10; nextState: STATE_MOSQU_ATTACK3; spriteState: SPRITE_STATE_MOSQU_ATTACK2; func: 0),
	{ STATE_MOSQU_ATTACK3 }
	(duration: 10; nextState: STATE_MOSQU_ATTACK3; spriteState: SPRITE_STATE_MOSQU_ATTACK2; func: 4),
	{ STATE_MOSQU_ATTACK4 }
	(duration: 60; nextState: STATE_MOSQU_ATTACK4; spriteState: SPRITE_STATE_MOSQU_ATTACK2; func: 0),
	{ STATE_RM_IDLE }
	(duration: 1; nextState: STATE_RM_WAIT; spriteState: SPRITE_STATE_RM_WAIT; func: 0),
	{ STATE_RM_WAIT }
	(duration: 10; nextState: STATE_RM_WAIT; spriteState: SPRITE_STATE_RM_WAIT; func: 5),
	{ STATE_RM_WALK }
	(duration: 10; nextState: STATE_RM_WALK; spriteState: SPRITE_STATE_RM_WALK; func: 5),
	{ STATE_RING1 }
	(duration: 2; nextState: STATE_RING2; spriteState: SPRITE_STATE_RING1; func: 0),
	{ STATE_RING2 }
	(duration: 2; nextState: STATE_RING3; spriteState: SPRITE_STATE_RING2; func: 0),
	{ STATE_RING3 }
	(duration: 2; nextState: STATE_RING4; spriteState: SPRITE_STATE_RING3; func: 0),
	{ STATE_RING4 }
	(duration: 2; nextState: STATE_RING5; spriteState: SPRITE_STATE_RING4; func: 0),
	{ STATE_RING5 }
	(duration: 2; nextState: STATE_RING6; spriteState: SPRITE_STATE_RING5; func: 0),
	{ STATE_RING6 }
	(duration: 2; nextState: STATE_RING1; spriteState: SPRITE_STATE_RING6; func: 0),
	{ STATE_CHILI1 }
	(duration: 2; nextState: STATE_CHILI2; spriteState: SPRITE_STATE_CHILI1; func: 0),
	{ STATE_CHILI2 }
	(duration: 2; nextState: STATE_CHILI3; spriteState: SPRITE_STATE_CHILI2; func: 0),
	{ STATE_CHILI3 }
	(duration: 2; nextState: STATE_CHILI4; spriteState: SPRITE_STATE_CHILI3; func: 0),
	{ STATE_CHILI4 }
	(duration: 2; nextState: STATE_CHILI5; spriteState: SPRITE_STATE_CHILI4; func: 0),
	{ STATE_CHILI5 }
	(duration: 2; nextState: STATE_CHILI6; spriteState: SPRITE_STATE_CHILI5; func: 0),
	{ STATE_CHILI6 }
	(duration: 2; nextState: STATE_CHILI1; spriteState: SPRITE_STATE_CHILI6; func: 0),
	{ STATE_SPRING1_IDLE }
	(duration: 30; nextState: STATE_SPRING1_IDLE; spriteState: SPRITE_STATE_SPRING_YELLOW1; func: 0),
	{ STATE_SPRING1_USE }
	(duration: 10; nextState: STATE_SPRING1_IDLE; spriteState: SPRITE_STATE_SPRING_YELLOW2; func: 0),
	{ STATE_SPRING2_IDLE }
	(duration: 30; nextState: STATE_SPRING2_IDLE; spriteState: SPRITE_STATE_SPRING_RED1; func: 0),
	{ STATE_SPRING2_USE }
	(duration: 10; nextState: STATE_SPRING2_IDLE; spriteState: SPRITE_STATE_SPRING_RED2; func: 0),
	{ STATE_MPLAT }
	(duration: 30; nextState: STATE_MPLAT; spriteState: SPRITE_STATE_MPLAT; func: 0)
);
implementation
begin
end.
