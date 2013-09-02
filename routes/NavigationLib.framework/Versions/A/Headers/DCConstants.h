#ifndef _DC_CONSTANTS_H_
#define _DC_CONSTANTS_H_

typedef enum DCLogLevel
{
	DCLogLevelNone = 0,
	DCLogLevelError,
	DCLogLevelWarn,
	DCLogLevelInfo,
	DCLogLevelDebug,
	DCLogLevelFine,
	
	DCLogLevelCount
}
DCLogLevel;

#endif	// _DC_CONSTANTS_H_
