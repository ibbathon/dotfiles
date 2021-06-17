import os

try:
    import IPython
    ipython_available = True
except ModuleNotFoundError:
    ipython_available = False

try:
    __IPYTHON__
    ipython_initialized = True
except NameError:
    ipython_initialized = False

if ipython_available and not ipython_initialized:
    os.environ['PYTHONSTARTUP'] = ''  # Prevent running this again
    IPython.start_ipython()
    raise SystemExit
elif not ipython_available:
    print('ipython not installed')
