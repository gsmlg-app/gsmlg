#ifndef WEB_TERMINAL_PYTHON_H
#define WEB_TERMINAL_PYTHON_H

#ifdef __cplusplus
extern "C" {
#endif

__attribute__((visibility("default")))
int webterminal_python_main(int argc, char **argv);

__attribute__((visibility("default")))
void webterminal_python_cleanup_inputs(void);

#ifdef __cplusplus
}
#endif

#endif
