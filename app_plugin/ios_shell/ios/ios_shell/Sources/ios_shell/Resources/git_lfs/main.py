"""Entry point: python3 main.py [--env=NAME=VALUE ...] <subcommand> [args...]"""

import os
import sys
from typing import List, Tuple

ENV_PREFIX = '--env='


def split_env_flags(argv: List[str]) -> Tuple[List[Tuple[str, str]], List[str]]:
    pairs: List[Tuple[str, str]] = []
    index = 0
    while index < len(argv) and argv[index].startswith(ENV_PREFIX):
        name, _sep, value = argv[index][len(ENV_PREFIX):].partition('=')
        if name:
            pairs.append((name, value))
        index += 1
    return pairs, argv[index:]


def main(argv: List[str]) -> int:
    pairs, rest = split_env_flags(argv)
    for name, value in pairs:
        os.environ[name] = value
    package_parent = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    if package_parent not in sys.path:
        sys.path.insert(0, package_parent)
    from git_lfs import commands
    from git_lfs.store import LfsError

    if not rest or rest[0] in ('-h', '--help', 'help'):
        print('usage: git lfs <' + '|'.join(commands.COMMANDS) + '> [args...]')
        return 0 if rest else 2
    command = commands.COMMANDS.get(rest[0])
    if command is None:
        commands.err(f'unknown command "{rest[0]}"')
        return 2
    try:
        return command(os.getcwd(), rest[1:])
    except LfsError as error:
        commands.err(str(error))
        return 1
    except OSError as error:
        commands.err(f'{error.strerror or error}: {error.filename or ""}'.rstrip(': '))
        return 1
    except KeyboardInterrupt:
        return 130


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
