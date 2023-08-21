//
//  XZRefreshingDefines.h
//  Pods
//
//  Created by Xezun on 2023/8/13.
//

#ifndef XZRefreshingDefines_h
#define XZRefreshingDefines_h

#ifndef XZLog
#ifdef XZ_DEBUG
#if DEBUG
#define XZLog(format, ...) NSLog(@"[XZRefreshing] %@", [NSString stringWithFormat:format, ##__VA_ARGS__])
#else
#define XZLog(...) do{}while(0)
#endif
#else
#define XZLog(...) do{}while(0)
#endif
#endif


#endif /* XZRefreshingDefines_h */
