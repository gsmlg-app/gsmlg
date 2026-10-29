#import "WebTerminalPython.h"

#import <Foundation/Foundation.h>
#import <Python/Python.h>
#import <ios_system/ios_system.h>

#include <fcntl.h>
#include <pthread.h>
#include <unistd.h>

static pthread_mutex_t pythonMutex = PTHREAD_MUTEX_INITIALIZER;
static BOOL pythonReady = NO;
static NSString *pythonFailure;
static PyObject *runCommand;
static NSMutableSet<NSValue *> *pendingInputs;

static void rememberRedirectedInput(void) {
    FILE *input = thread_stdin;
    if (input == NULL) return;
    int descriptor = fileno(input);
    if (descriptor < 0 || descriptor == ios_getstdin()
        || descriptor == fileno(stdin) || descriptor == fileno(stdout)
        || descriptor == fileno(stderr)
        || (thread_stdout != NULL && descriptor == fileno(thread_stdout))
        || (thread_stderr != NULL && descriptor == fileno(thread_stderr))) return;
    pthread_mutex_lock(&pythonMutex);
    if (pendingInputs == nil) pendingInputs = [NSMutableSet set];
    [pendingInputs addObject:[NSValue valueWithPointer:input]];
    pthread_mutex_unlock(&pythonMutex);
}

void webterminal_python_cleanup_inputs(void) {
    pthread_mutex_lock(&pythonMutex);
    for (NSValue *input in pendingInputs) fclose(input.pointerValue);
    [pendingInputs removeAllObjects];
    pthread_mutex_unlock(&pythonMutex);
}

static const char *commandBootstrap =
    "import builtins, os, runpy, sys, traceback, types\n"
    "def run_command(mode, operand, arguments, original_arguments, input_stream, output_stream, error_stream):\n"
    "    names = ('stdin', 'stdout', 'stderr', '__stdin__', '__stdout__', '__stderr__', 'argv', 'orig_argv', 'path')\n"
    "    saved = {name: getattr(sys, name) for name in names}\n"
    "    missing = object()\n"
    "    previous_main = sys.modules.get('__main__', missing)\n"
    "    status = 0\n"
    "    try:\n"
    "        sys.stdin = sys.__stdin__ = input_stream\n"
    "        sys.stdout = sys.__stdout__ = output_stream\n"
    "        sys.stderr = sys.__stderr__ = error_stream\n"
    "        sys.argv = arguments\n"
    "        sys.orig_argv = original_arguments\n"
    "        sys.path = list(saved['path'])\n"
    "        sys.path.insert(0, os.path.dirname(os.path.abspath(operand)) if mode == 'script' else '')\n"
    "        main = types.ModuleType('__main__')\n"
    "        main.__dict__['__builtins__'] = builtins\n"
    "        sys.modules['__main__'] = main\n"
    "        if mode == 'module':\n"
    "            runpy.run_module(operand, run_name='__main__', alter_sys=True)\n"
    "        elif mode == 'script':\n"
    "            runpy.run_path(operand, run_name='__main__')\n"
    "        else:\n"
    "            source = input_stream.read() if mode == 'stdin' else operand\n"
    "            filename = '<stdin>' if mode == 'stdin' else '<string>'\n"
    "            exec(compile(source, filename, 'exec'), main.__dict__)\n"
    "    except SystemExit as exception:\n"
    "        if exception.code is None:\n"
    "            status = 0\n"
    "        elif isinstance(exception.code, int):\n"
    "            status = int(exception.code) & 255\n"
    "        else:\n"
    "            print(exception.code, file=error_stream)\n"
    "            status = 1\n"
    "    except BaseException as exception:\n"
    "        traceback.print_exception(exception, file=error_stream)\n"
    "        status = 1\n"
    "    finally:\n"
    "        for stream in (output_stream, error_stream):\n"
    "            try:\n"
    "                if not stream.closed:\n"
    "                    stream.flush()\n"
    "            except BaseException:\n"
    "                status = 1\n"
    "        for stream in (input_stream, output_stream, error_stream):\n"
    "            try:\n"
    "                stream.close()\n"
    "            except BaseException:\n"
    "                status = 1\n"
    "        for name, value in saved.items():\n"
    "            setattr(sys, name, value)\n"
    "        if previous_main is missing:\n"
    "            sys.modules.pop('__main__', None)\n"
    "        else:\n"
    "            sys.modules['__main__'] = previous_main\n"
    "    return status\n";

static BOOL checkStatus(PyStatus status) {
    if (!PyStatus_Exception(status)) return YES;
    pythonFailure = status.err_msg
        ? [NSString stringWithUTF8String:status.err_msg]
        : @"Python initialization failed";
    return NO;
}

static BOOL setConfigString(PyConfig *config, wchar_t **field, NSString *value) {
    return checkStatus(PyConfig_SetBytesString(config, field, value.UTF8String));
}

static BOOL appendSearchPath(PyConfig *config, NSString *path) {
    wchar_t *widePath = Py_DecodeLocale(path.UTF8String, NULL);
    if (widePath == NULL) {
        pythonFailure = @"Unable to decode the Python library path";
        return NO;
    }
    BOOL success = checkStatus(PyWideStringList_Append(&config->module_search_paths, widePath));
    PyMem_RawFree(widePath);
    return success;
}

static void reportException(FILE *errorFile) {
    PyObject *exception = PyErr_GetRaisedException();
    if (exception == NULL) return;
    PyObject *description = PyObject_Str(exception);
    const char *message = description ? PyUnicode_AsUTF8(description) : NULL;
    fprintf(errorFile, "python: %s\n", message ? message : "Unable to report Python error");
    Py_XDECREF(description);
    Py_DECREF(exception);
    PyErr_Clear();
}

static BOOL initializePython(FILE *errorFile) {
    if (pythonReady) return YES;
    if (pythonFailure != nil) return NO;

    NSString *home = [NSBundle.mainBundle.resourcePath stringByAppendingPathComponent:@"python"];
    NSString *version = [NSString stringWithFormat:@"python%d.%d", PY_MAJOR_VERSION, PY_MINOR_VERSION];
    NSString *stdlib = [[home stringByAppendingPathComponent:@"lib"] stringByAppendingPathComponent:version];
    if (![NSFileManager.defaultManager fileExistsAtPath:[stdlib stringByAppendingPathComponent:@"encodings"]]) {
        pythonFailure = @"The bundled Python standard library is missing";
        return NO;
    }

    PyPreConfig preconfig;
    PyPreConfig_InitIsolatedConfig(&preconfig);
    preconfig.utf8_mode = 1;
    if (!checkStatus(Py_PreInitialize(&preconfig))) return NO;

    PyConfig config;
    PyConfig_InitIsolatedConfig(&config);
    config.parse_argv = 0;
    config.install_signal_handlers = 0;
    config.configure_c_stdio = 0;
    config.use_system_logger = 0;
    config.write_bytecode = 0;
    config.site_import = 0;
    config.user_site_directory = 0;
    config.module_search_paths_set = 1;
    BOOL configured = setConfigString(&config, &config.home, home)
        && setConfigString(&config, &config.program_name, @"python3")
        && setConfigString(&config, &config.executable, NSBundle.mainBundle.executablePath)
        && setConfigString(&config, &config.stdio_encoding, @"utf-8")
        && setConfigString(&config, &config.stdio_errors, @"surrogateescape")
        && appendSearchPath(&config, stdlib)
        && appendSearchPath(&config, [stdlib stringByAppendingPathComponent:@"lib-dynload"]);
    BOOL initialized = configured && checkStatus(Py_InitializeFromConfig(&config));
    PyConfig_Clear(&config);
    if (!initialized) return NO;

    PyObject *globals = PyDict_New();
    PyObject *bootstrap = globals
        ? PyRun_StringFlags(commandBootstrap, Py_file_input, globals, globals, NULL)
        : NULL;
    if (bootstrap != NULL) {
        runCommand = PyDict_GetItemString(globals, "run_command");
        Py_XINCREF(runCommand);
    }
    if (runCommand == NULL) {
        reportException(errorFile);
        pythonFailure = @"Unable to initialize the Python command runner";
    }
    Py_XDECREF(bootstrap);
    Py_XDECREF(globals);
    pythonReady = runCommand != NULL;
    PyEval_SaveThread();
    return pythonReady;
}

static PyObject *makeStream(FILE *source, BOOL input) {
    int descriptor;
    if (input && (source == NULL || source == stdin || fileno(source) == fileno(stdin))) {
        descriptor = open("/dev/null", O_RDONLY);
    } else if (source != NULL) {
        if (!input) fflush(source);
        descriptor = dup(fileno(source));
    } else {
        descriptor = -1;
    }
    if (descriptor < 0) return PyErr_SetFromErrno(PyExc_OSError);
    PyObject *stream = PyFile_FromFd(descriptor, NULL, input ? "r" : "w", 1,
                                   "utf-8", "surrogateescape", NULL, 1);
    if (stream == NULL) close(descriptor);
    return stream;
}

static void closeStream(PyObject *stream) {
    if (stream == NULL) return;
    PyObject *closed = PyObject_CallMethod(stream, "close", NULL);
    Py_XDECREF(closed);
    PyErr_Clear();
}

static PyObject *argumentList(int argc, char **argv, int start, const char *first) {
    PyObject *arguments = PyList_New(0);
    if (arguments == NULL) return NULL;
    for (int index = start - (first != NULL); index < argc; index++) {
        const char *argument = (first != NULL && index < start) ? first : argv[index];
        PyObject *value = PyUnicode_DecodeFSDefault(argument);
        int added = value ? PyList_Append(arguments, value) : -1;
        Py_XDECREF(value);
        if (added < 0) {
            Py_DECREF(arguments);
            return NULL;
        }
    }
    return arguments;
}

int webterminal_python_main(int argc, char **argv) {
    @autoreleasepool {
        rememberRedirectedInput();
        FILE *errorFile = thread_stderr ? thread_stderr : stderr;
        FILE *outputFile = thread_stdout ? thread_stdout : stdout;
        if (argc < 2) {
            fprintf(errorFile, "python: interactive mode is unavailable; use -c, -m, or a script file\n");
            return 2;
        }
        const char *option = argv[1];
        if (strcmp(option, "--version") == 0 || strcmp(option, "-V") == 0) {
            fprintf(outputFile, "Python %s\n", PY_VERSION);
            return 0;
        }
        if (strcmp(option, "--help") == 0 || strcmp(option, "-h") == 0) {
            fprintf(outputFile, "usage: python3 [-c code | -m module | script | -] [args ...]\n"
                                "       python3 --version\n"
                                "Runs Python scripts in the app sandbox. Interactive input is unavailable.\n");
            return 0;
        }

        const char *mode;
        const char *operand;
        int argumentStart;
        const char *firstArgument;
        if (strcmp(option, "-c") == 0 || strcmp(option, "-m") == 0) {
            if (argc < 3) {
                fprintf(errorFile, "python: %s requires an argument\n", option);
                return 2;
            }
            mode = strcmp(option, "-c") == 0 ? "command" : "module";
            operand = argv[2];
            argumentStart = 3;
            firstArgument = strcmp(option, "-c") == 0 ? "-c" : argv[2];
        } else if (strcmp(option, "-") == 0) {
            mode = "stdin";
            operand = "";
            argumentStart = 2;
            firstArgument = "-";
        } else if (option[0] == '-') {
            fprintf(errorFile, "python: unsupported option: %s\n", option);
            return 2;
        } else {
            mode = "script";
            operand = option;
            argumentStart = 2;
            firstArgument = option;
        }

        pthread_mutex_lock(&pythonMutex);
        if (!initializePython(errorFile)) {
            fprintf(errorFile, "python: %s\n", pythonFailure.UTF8String);
            pthread_mutex_unlock(&pythonMutex);
            return 1;
        }
        PyGILState_STATE gil = PyGILState_Ensure();
        PyObject *inputStream = makeStream(thread_stdin, YES);
        PyObject *outputStream = inputStream ? makeStream(outputFile, NO) : NULL;
        PyObject *errorStream = outputStream ? makeStream(errorFile, NO) : NULL;
        PyObject *arguments = errorStream ? argumentList(argc, argv, argumentStart, firstArgument) : NULL;
        PyObject *originalArguments = arguments ? argumentList(argc, argv, 0, NULL) : NULL;
        PyObject *modeString = originalArguments ? PyUnicode_FromString(mode) : NULL;
        PyObject *operandString = modeString ? PyUnicode_DecodeFSDefault(operand) : NULL;
        PyObject *returned = operandString
            ? PyObject_CallFunctionObjArgs(runCommand, modeString, operandString,
                                           arguments, originalArguments, inputStream,
                                           outputStream, errorStream, NULL)
            : NULL;
        int status = 1;
        if (returned != NULL) {
            long code = PyLong_AsLong(returned);
            if (!PyErr_Occurred()) status = (int)code;
        }
        if (PyErr_Occurred()) reportException(errorFile);
        closeStream(inputStream);
        closeStream(outputStream);
        closeStream(errorStream);
        Py_XDECREF(returned);
        Py_XDECREF(modeString);
        Py_XDECREF(operandString);
        Py_XDECREF(originalArguments);
        Py_XDECREF(arguments);
        Py_XDECREF(inputStream);
        Py_XDECREF(outputStream);
        Py_XDECREF(errorStream);
        PyGILState_Release(gil);
        pthread_mutex_unlock(&pythonMutex);
        return status;
    }
}
