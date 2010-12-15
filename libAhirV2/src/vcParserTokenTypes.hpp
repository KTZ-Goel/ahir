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
		LIBRARY = 4,
		LBRACE = 5,
		RBRACE = 6,
		DPE = 7,
		PARAMETER = 8,
		LPAREN = 9,
		UINTEGER = 10,
		RPAREN = 11,
		IN = 12,
		OUT = 13,
		COLON = 14,
		TEMPLATE = 15,
		FLOAT = 16,
		LESS = 17,
		SIMPLE_IDENTIFIER = 18,
		GREATER = 19,
		INT = 20,
		REQS = 21,
		ACKS = 22,
		MEMORYSPACE = 23,
		CAPACITY = 24,
		DATAWIDTH = 25,
		ADDRWIDTH = 26,
		OBJECT = 27,
		ASSIGNEQUAL = 28,
		MODULE = 29,
		LINK = 30,
		IMPLIES = 31,
		CONTROLPATH = 32,
		PLACE = 33,
		TRANSITION = 34,
		HIDDEN = 35,
		SERIESBLOCK = 36,
		PARALLELBLOCK = 37,
		BRANCHBLOCK = 38,
		MERGE = 39,
		ENTRY = 40,
		BRANCH = 41,
		EXIT = 42,
		FORKBLOCK = 43,
		JOIN = 44,
		FORK = 45,
		DATAPATH = 46,
		DPEINSTANCE = 47,
		OF = 48,
		MAP = 49,
		PORT = 50,
		LBRACKET = 51,
		RBRACKET = 52,
		WIRE = 53,
		COMMA = 54,
		BINARYSTRING = 55,
		HEXSTRING = 56,
		MINUS = 57,
		LITERAL_C = 58,
		LITERAL_M = 59,
		POINTER = 60,
		HIERARCHICAL_IDENTIFIER = 61,
		ARRAY = 62,
		RECORD = 63,
		ATTRIBUTE = 64,
		QUOTED_STRING = 65,
		WHITESPACE = 66,
		SINGLELINECOMMENT = 67,
		ALPHA = 68,
		DIGIT = 69,
		NULL_TREE_LOOKAHEAD = 3
	};
#ifdef __cplusplus
};
#endif
#endif /*INC_vcParserTokenTypes_hpp_*/