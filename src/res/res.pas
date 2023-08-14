unit res;
interface
uses common, res_enum;
const
	SPRITE_AFSPIKE = 0;
	SPRITE_BACK1 = 1;
	SPRITE_BOX_BUB = 2;
	SPRITE_BOX_FIR = 3;
	SPRITE_BOX_RNG = 4;
	SPRITE_BOX_SHI = 5;
	SPRITE_BOX_SPI = 6;
	SPRITE_BOX_ST = 7;
	SPRITE_BPLAT = 8;
	SPRITE_CFP = 9;
	SPRITE_CHILI1 = 10;
	SPRITE_CHILI2 = 11;
	SPRITE_CHILI3 = 12;
	SPRITE_CHILI4 = 13;
	SPRITE_CHILI5 = 14;
	SPRITE_CHILI6 = 15;
	SPRITE_E1 = 16;
	SPRITE_E2 = 17;
	SPRITE_E3 = 18;
	SPRITE_E4 = 19;
	SPRITE_E5 = 20;
	SPRITE_EL1 = 21;
	SPRITE_EL2 = 22;
	SPRITE_EL3 = 23;
	SPRITE_ELL = 24;
	SPRITE_ELR = 25;
	SPRITE_FSPIKE = 26;
	SPRITE_GAMBLE = 27;
	SPRITE_LAVA1 = 28;
	SPRITE_LAVA2 = 29;
	SPRITE_LAVA3 = 30;
	SPRITE_LDN = 31;
	SPRITE_LFLIP1 = 32;
	SPRITE_LFLIP2 = 33;
	SPRITE_LHOR = 34;
	SPRITE_LLT = 35;
	SPRITE_LRT = 36;
	SPRITE_LUP = 37;
	SPRITE_LVER = 38;
	SPRITE_MOSQU1 = 39;
	SPRITE_MOSQU2 = 40;
	SPRITE_MOSQU3 = 41;
	SPRITE_MOSQU4 = 42;
	SPRITE_MPGHOST = 43;
	SPRITE_MPL = 44;
	SPRITE_MPLAT = 45;
	SPRITE_MPR = 46;
	SPRITE_P1 = 47;
	SPRITE_PASSER1 = 48;
	SPRITE_PASSER2 = 49;
	SPRITE_PASSER3 = 50;
	SPRITE_PASSER4 = 51;
	SPRITE_RB1_1 = 52;
	SPRITE_RB1_2 = 53;
	SPRITE_RFLIP1 = 54;
	SPRITE_RFLIP2 = 55;
	SPRITE_RING1 = 56;
	SPRITE_RING2 = 57;
	SPRITE_RING3 = 58;
	SPRITE_RING4 = 59;
	SPRITE_RING5 = 60;
	SPRITE_RING6 = 61;
	SPRITE_RM1 = 62;
	SPRITE_RM2 = 63;
	SPRITE_RM3 = 64;
	SPRITE_SDIE = 65;
	SPRITE_SL1 = 66;
	SPRITE_SL2 = 67;
	SPRITE_SLS = 68;
	SPRITE_SPIKEBL = 69;
	SPRITE_SPIKEDN = 70;
	SPRITE_SPIKELT = 71;
	SPRITE_SPIKERT = 72;
	SPRITE_SPIKEUP = 73;
	SPRITE_SPIN1 = 74;
	SPRITE_SPIN2 = 75;
	SPRITE_SPRINGL1 = 76;
	SPRITE_SPRINGL2 = 77;
	SPRITE_SPRINGR1 = 78;
	SPRITE_SPRINGR2 = 79;
	SPRITE_SR1 = 80;
	SPRITE_SR2 = 81;
	SPRITE_SRS = 82;
	SPRITE_SWAIT1 = 83;
	SPRITE_SWAIT2 = 84;
	SPRITE_T0 = 85;
	SPRITE_T1 = 86;
	SPRITE_T10 = 87;
	SPRITE_T2 = 88;
	SPRITE_WFP = 89;
const
entity_states: array[0..46] of TEntityState = (
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
	(duration: 10; nextState: STATE_SPRING2_IDLE; spriteState: SPRITE_STATE_SPRING_RED2; func: 0)
);
implementation
begin
end.
