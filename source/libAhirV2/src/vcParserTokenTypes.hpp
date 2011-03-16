#ifndef INC_vcParserTokenTypes_hpp_
#define INC_vcParserTokenTypes_hpp_

/* $ANTLR 2.7.7 (2006-11-01): "vc.g" -> "vcParserTokenTypes.hpp"$ */

#ifndef CUSTOM_API
# define CUSTOM_API
#endif

#ifdef __cplusplus
struct CUSTOM_API vcParserTokenTypes {
#endif
	enum {
		EOF_ = 1,
		PIPE = 4,
		UINTEGER = 5,
		MEMORYSPACE = 6,
		LBRACE = 7,
		RBRACE = 8,
		CAPACITY = 9,
		DATAWIDTH = 10,
		ADDRWIDTH = 11,
		OBJECT = 12,
		COLON = 13,
		MODULE = 14,
		SIMPLE_IDENTIFIER = 15,
		EQUIVALENT = 16,
		LPAREN = 17,
		RPAREN = 18,
		OPEN = 19,
		DIV_OP = 20,
		ENTRY = 21,
		EXIT = 22,
		CONTROLPATH = 23,
		PLACE = 24,
		TRANSITION = 25,
		SERIESBLOCK = 26,
		PARALLELBLOCK = 27,
		BRANCHBLOCK = 28,
		MERGE = 29,
		BRANCH = 30,
		FORKBLOCK = 31,
		JOIN = 32,
		FORK = 33,
		DATAPATH = 34,
		PLUS_OP = 35,
		MINUS_OP = 36,
		MUL_OP = 37,
		SHL_OP = 38,
		SHR_OP = 39,
		GT_OP = 40,
		GE_OP = 41,
		EQ_OP = 42,
		LT_OP = 43,
		LE_OP = 44,
		NEQ_OP = 45,
		BITSEL_OP = 46,
		CONCAT_OP = 47,
		OR_OP = 48,
		AND_OP = 49,
		XOR_OP = 50,
		NOR_OP = 51,
		NAND_OP = 52,
		XNOR_OP = 53,
		NOT_OP = 54,
		BRANCH_OP = 55,
		SELECT_OP = 56,
		ASSIGN_OP = 57,
		EQUIVALENCE_OP = 58,
		CALL = 59,
		INLINE = 60,
		IOPORT = 61,
		IN = 62,
		OUT = 63,
		LOAD = 64,
		FROM = 65,
		STORE = 66,
		TO = 67,
		PHI = 68,
		LBRACKET = 69,
		RBRACKET = 70,
		CONSTANT = 71,
		INTERMEDIATE = 72,
		WIRE = 73,
		COMMA = 74,
		BINARYSTRING = 75,
		HEXSTRING = 76,
		MINUS = 77,
		LITERAL_C = 78,
		LITERAL_M = 79,
		INT = 80,
		FLOAT = 81,
		POINTER = 82,
		ARRAY = 83,
		OF = 84,
		RECORD = 85,
		ATTRIBUTE = 86,
		IMPLIES = 87,
		QUOTED_STRING = 88,
		DPE = 89,
		LIBRARY = 90,
		REQS = 91,
		ACKS = 92,
		HIDDEN = 93,
		PARAMETER = 94,
		PORT = 95,
		MAP = 96,
		MIN = 97,
		MAX = 98,
		DPEINSTANCE = 99,
		LINK = 100,
		AT = 101,
		UGT_OP = 102,
		UGE_OP = 103,
		ULT_OP = 104,
		ULE_OP = 105,
		UNORDERED_OP = 106,
		WHITESPACE = 107,
		SINGLELINECOMMENT = 108,
		HIERARCHICAL_IDENTIFIER = 109,
		ALPHA = 110,
		DIGIT = 111,
		NULL_TREE_LOOKAHEAD = 3
	};
#ifdef __cplusplus
};
#endif
#endif /*INC_vcParserTokenTypes_hpp_*/
