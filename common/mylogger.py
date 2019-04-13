import logging
import sys

LOGFMT="[%(levelname)s]\t%(asctime)s.%(msecs)03d\t[%(pathname)s l.%(lineno)s %(funcName)s]\t%(message)s"
DATEFMT="%Y%m%d %H:%M:%S"

def set():
    logger = logging.getLogger()
    for h in logger.handlers:
        logger.removeHandler(h)
    h = logging.StreamHandler(sys.stdout)
    h.setFormatter(logging.Formatter(LOGFMT, datefmt=DATEFMT))
    logger.addHandler(h)
    logger.setLevel(logging.INFO)
    return logger
