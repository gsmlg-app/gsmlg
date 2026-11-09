#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSDictionary<NSString *, id> *webterminal_execute_command(NSString *command, NSDictionary<NSString *, NSString *> *environment);
FOUNDATION_EXPORT BOOL webterminal_set_directory(NSString *path);
FOUNDATION_EXPORT int webterminal_lg2_main(int argc, char **argv);
FOUNDATION_EXPORT int webterminal_git_main(int argc, char **argv);
FOUNDATION_EXPORT int webterminal_md5_main(int argc, char **argv);
