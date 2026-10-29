//
//  ios_shell-Bridging-Header.h
//  ios_shell
//
//  Bridging header to expose command functions from ios_system frameworks
//

#ifndef ios_shell_Bridging_Header_h
#define ios_shell_Bridging_Header_h

#import <ios_system/ios_system.h>

// Command main functions from files framework
extern int ls_main(int argc, char *argv[]);
extern int cat_main(int argc, char *argv[]);
extern int cp_main(int argc, char *argv[]);
extern int mv_main(int argc, char *argv[]);
extern int rm_main(int argc, char *argv[]);
extern int mkdir_main(int argc, char *argv[]);
extern int rmdir_main(int argc, char *argv[]);
extern int touch_main(int argc, char *argv[]);
extern int chmod_main(int argc, char *argv[]);
extern int chown_main(int argc, char *argv[]);
extern int ln_main(int argc, char *argv[]);
extern int df_main(int argc, char *argv[]);
extern int du_main(int argc, char *argv[]);
extern int stat_main(int argc, char *argv[]);
extern int gzip_main(int argc, char *argv[]);
extern int less_main(int argc, char *argv[]);
extern int compress_main(int argc, char *argv[]);

// Command main functions from shell framework
extern int pwd_main(int argc, char *argv[]);
extern int echo_main(int argc, char *argv[]);
extern int env_main(int argc, char *argv[]);
extern int printenv_main(int argc, char *argv[]);
extern int date_main(int argc, char *argv[]);
extern int uname_main(int argc, char *argv[]);
extern int id_main(int argc, char *argv[]);
extern int basename_main(int argc, char *argv[]);
extern int dirname_main(int argc, char *argv[]);
extern int realpath_main(int argc, char *argv[]);
extern int sleep_main(int argc, char *argv[]);
extern int tee_main(int argc, char *argv[]);
extern int find_main(int argc, char *argv[]);
extern int xargs_main(int argc, char *argv[]);

// Command main functions from text framework
extern int cat_main(int argc, char *argv[]);
extern int head_main(int argc, char *argv[]);
extern int tail_main(int argc, char *argv[]);
extern int wc_main(int argc, char *argv[]);
extern int grep_main(int argc, char *argv[]);
extern int sed_main(int argc, char *argv[]);
extern int sort_main(int argc, char *argv[]);
extern int uniq_main(int argc, char *argv[]);
extern int tr_main(int argc, char *argv[]);
extern int diff_main(int argc, char *argv[]);

// Command main functions from tar framework
extern int tar_main(int argc, char *argv[]);

// Command main functions from awk framework
extern int awk_main(int argc, char *argv[]);

#endif /* ios_shell_Bridging_Header_h */
